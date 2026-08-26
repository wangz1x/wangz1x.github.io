---
title: 从一段对话到用户画像：拆解 L0→L3 四层记忆流水线
date: 2026-08-26 15:00:00
tags:
- AI Memory
- LLM
- 架构
- 源码阅读
---

你和一个 AI Agent 聊完一轮，点下回车，发生了一件你没察觉的事：这段对话被悄悄记下、提炼、聚合，最终变成"你是什么样的人"这样一份画像，在下次对话时又自动喂回给 Agent。整个过程在后台跑，用户完全无感。

最近我在读 [TencentDB Agent Memory](https://github.com/Tencent/TencentDB-Agent-Memory) 这套记忆系统的源码，把它的核心——从 L0 到 L3 的四层记忆流水线——摸了个遍。这篇文章把这条链拆开：每一层在什么时机触发、吃什么输入、吐什么输出，而且**每一层都给你看真实的数据样例**，不玩抽象。

<!--more-->

## 先用一个场景串起全链

假设你和一个叫"bug-fix engineer"的 Agent 聊这么一句：

> **你**：登录接口老报 401，我查了 token 过期没自动刷新，帮我看看
> **Agent**：先确认下，401 是 access_token 过期还是 refresh_token 也挂了？你用的 pnpm 还是 npm 跑的？

就这么一轮对话，会触发完整的 L0→L3 流水线。下面每一层，我都告诉你它什么时候动、吃进什么、吐出什么，并贴出真实的存储样例。

## L0：把对话录下来（同步入口）

**触发时机**：Agent 答完你这句的瞬间（`agent_end` 事件），立刻录。不是等会话结束，是**每答完一句就录一次**。

**输入**：这一轮的对话消息（你的提问 + Agent 的回答 + 中间任何工具调用）。

**输出**：两份存储——

第一份是 JSONL 日志（按天分文件、append-only，每行一条消息带租户标签）：

```jsonl
{"id":"l0_a3f7-0","sessionKey":"对话A","userId":"u1","agentId":"bug-fix","role":"user","content":"登录接口老报401，我查了token过期没自动刷新","timestamp":1693017600000}
{"id":"l0_a3f7-1","sessionKey":"对话A","userId":"u1","agentId":"bug-fix","role":"assistant","content":"先确认下，401是access_token过期还是refresh_token也挂了？你用的pnpm还是npm？","timestamp":1693017660000}
```

第二份是向量库的 L0 表（元数据 + 向量 + 全文索引），供语义/关键词检索用——内容同上，但多了 embedding 字段（一串数字，语义指纹）。

**关键设计**：录完只做"记录 + 报数"，**不做任何提炼**。它给调度器发个信号"又聊完一轮了"，然后立刻返回。向量计算这种慢活（2-3 秒）要么扔后台，要么靠服务端嵌入，绝不阻塞用户。所以 L0 录完你就感觉不到，能立刻接着聊。

L0 的职责就一句话：**干净增量地把对话存成可检索的真相源**。

## L1：从对话抽出原子记忆（异步沉淀开始）

**触发时机**：由调度器的计数器/idle 定时器决定，**不是 L0 直接触发**。比如默认"攒满 5 轮"或"闲够 10 分钟"才跑。这是异步的——L0 录完用户就走了，L1 在后台慢慢抽。

**输入**：L0 对话（按 `last_l1_cursor` 游标增量查，只处理没抽过的新对话）。比如这一轮的上面两条 L0 消息。

**输出**：原子记忆——每条带 `type`、`priority`、`scene_name` 的结构化记录。看真实的 `MemoryRecord` 长啥样：

```jsonl
{"id":"mem_x1","content":"用户偏好用 pnpm 而非 npm 管理 Node 依赖","type":"persona","priority":75,"scene_name":"backend-bug-fixing","source_message_ids":["l0_a3f7-0"],"timestamps":["2026-08-26T15:00:00Z"],"createdAt":"2026-08-26T15:02:00Z","updatedAt":"2026-08-26T15:02:00Z","version":1}
{"id":"mem_x2","content":"登录接口 401 错误，根因是 access_token 过期后未自动用 refresh_token 刷新","type":"episodic","priority":70,"scene_name":"backend-bug-fixing","source_message_ids":["l0_a3f7-0","l0_a3f7-1"],"timestamps":["2026-08-26T15:00:00Z"],"createdAt":"2026-08-26T15:02:00Z","updatedAt":"2026-08-26T15:02:00Z","version":1}
```

注意它不是"这段对话讲了什么"的笼统总结，而是**拆成两条独立事实**：一条是用户偏好（persona 类），一条是这次 bug 事件（episodic 类）。每条带优先级、归属场景、来源消息 ID、版本号。

**核心机制**：LLM 抽取（靠提示词指挥产出 JSON）+ **去重**（和已有记忆比对，判定 store/update/merge/skip）+ 落库（带 embedding，可语义检索）。比如你之前已经有一条"用户偏好 npm"，这次新抽"偏好 pnpm"，去重时 LLM 判定这是 `update`（更新成 pnpm），不是再加一条。

## L2：把原子聚合成场景（沙箱 LLM 写文件）

**触发时机**：L1 完成后链式推进——设个下行定时器（只提前不推后），延迟后触发 L2。

**输入**：L1 原子记忆 + 现有的场景文件清单。比如把上面 `scene_name: "backend-bug-fixing"` 的那几条原子，聚进对应场景。

**输出**：`scene_blocks/*.md`（每个文件一个场景，人可读的 Markdown 白盒），最多 15 个。看真实的场景文件长啥样：

```markdown
-----META-START-----
created: 2026-08-20T10:00:00Z
updated: 2026-08-26T15:05:00Z
summary: 用户的后端 bug 修复习惯与偏好
heat: 5
-----META-END-----

# 后端 Bug 修复

用户偏好用 pnpm 管理依赖，遇到 401 这类认证错误时会先定位 token 过期与刷新机制……
```

文件分两部分：开头的 **META 头**（程序读的元数据：建/更新时间、摘要、热度）+ 后面的**正文**（人/LLM 看的场景叙事）。

**核心机制**：这层和 L1 范式完全不同——**它是个沙箱 LLM agent**。给 LLM 一组文件工具（read/write/edit），工作目录限定在 `scene_blocks/`，LLM 自己读 L1、决定"建新场景 / 更新现有 / 合并相似的"，**直接写 .md 文件**，不靠程序解析 JSON 落盘。默认策略是 UPDATE（往现有场景加），不是 CREATE（轻易建新）。

这层工程细节很考究：LLM 不能真删文件，只能写个 `[DELETED]` 标记，程序代删；写前先备份，写坏了能回滚；场景数到上限就禁止新建，只能合并；提示词里处处是"CREATE 前必须先 read 两个最相似的验证"这类踩坑约束。

## L3：从场景综合成用户画像（链的终点）

**触发时机**：L2 完成后触发，但**不是每次都真跑**——要先过 5 个条件判定：

1. **P1 显式请求**：LLM 在 L2 时觉得画像该更新，输出 `[PERSONA_UPDATE_REQUEST]` 信号
2. **P2 冷启动**：首次有场景了，还没画像
3. **P2.5 恢复**：画像文件损坏/丢失
4. **P3 首场景**：第一个场景刚建好
5. **P4 阈值**：攒够 N 条新记忆

**输入**：**变化的 L2 场景**（增量——按 `last_persona_time` 只看上次画像之后更新过的场景，不每次读全部）。

**输出**：单个 `persona.md`（用户画像）。看真实样例：

```markdown
-----META-START-----
created: 2026-08-20T10:00:00Z
updated: 2026-08-26T15:08:00Z
-----META-END-----

# 用户画像

## 核心特征
- 偏后端开发，主要做认证/鉴权相关
- 注重工程规范，偏好用 pnpm 等现代工具链
- 遇到问题习惯先定位根因（token 过期机制）再动手

## 场景导航
- 后端 Bug 修复（heat: 5）
- 前端 Code Review（heat: 2）
```

文件分两部分：**画像正文**（LLM 综合所有场景生成的"用户是谁"）+ **场景导航**（程序追加的"有哪些场景"列表）。

**核心机制**：和 L2 同款"沙箱 LLM 写文件"，LLM 直接写画像正文；程序后处理追加场景导航。L3 全局互斥——同时只跑一个，因为画像是 team+agent 级的。P1 那条特别有意思——**LLM 能在 L2 时主动请求刷新画像**，不靠死阈值，是 LLM 自驱的画像更新。

## 这条链怎么闭环：recall 把记忆喂回去

沉淀链产出的东西，最终在 recall 时用上——每轮对话**前**，自动检索相关记忆注入 prompt：

- **L1 原子**：混合检索（关键词 BM25 + 向量余弦 + RRF 融合），注入到 user prompt 前缀的 `<relevant-memories>`（每轮都变，所以放动态区，不破坏 system prompt 缓存）
- **L3 persona**：读 `persona.md` 画像正文，注入到 system prompt 的 `<user-persona>`（稳定区，可被 Anthropic/OpenAI 的 prompt cache 缓存省 token）
- **L2 场景导航**：注入到 system prompt 的 `<scene-navigation>`（告诉 Agent 有哪些场景维度）

于是闭环成立：**L0 录对话 → L1/L2/L3 沉淀 → recall 注入 → Agent 用记忆答 → 新对话又进 L0**。每轮对话都是这个环的一次循环，记忆边聊边沉淀、边沉淀边用。

## 一个贯穿全链的设计哲学

拆完这四层，你会发现它们共享同一个原则：**慢活扔后台、同步入口立刻返回、数据靠游标增量、存储双写（真相源 + 检索引擎）**。

- L0 的向量计算扔后台，`agent_end` 立刻返回，用户不卡
- L1/L2/L3 全是调度器异步触发，不阻塞对话
- 每层都有游标（`last_captured_timestamp` / `last_l1_cursor` / `last_persona_time`），只处理增量
- L0/L1 双写 JSONL（不丢可重建）+ 库表（快查），L2/L3 双写 .md（人可读）+ 索引（程序快查）

这套"分层提炼 + 异步沉淀 + 双写存储 + 白盒可调试"的设计，是这套记忆系统最值得学的地方——它把"让 AI 记住用户"这件听起来很玄的事，拆成了一条清晰、可调试、可追溯的数据流水线。下次你用 Agent 感觉它"记得你"，背后多半就是这条 L0→L3 的链在默默运转。

> 这篇是读 [TencentDB Agent Memory](https://github.com/Tencent/TencentDB-Agent-Memory) 源码的总结，源码在 `MemoryCore/src/core/` 下，按 `conversation/` `record/` `scene/` `persona/` 四个目录分层，对应 L0→L3。
