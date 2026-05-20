---
title: 这个博客是怎么跑起来的：Hexo、双分支与 GitHub Actions 自动发布
date: 2026-05-20 17:00:00
tags:
- Hexo
- GitHub Actions
- blog
- devops
---

你可能好奇这个博客是怎么搭建和运维的——写一篇文章，推一下代码，网页就自动更新了，看起来很魔法。其实背后的架构非常简单，只用到了三个东西：[Hexo](https://hexo.io/)、Git 双分支和 [GitHub Actions](https://github.com/features/actions)。这篇文章就来拆解一下这个博客的技术栈。

<!--more-->

## Hexo：用 Markdown 写博客

[Hexo](https://hexo.io/) 是一个基于 Node.js 的静态博客框架。它的核心理念很简单：你用 Markdown 写文章，Hexo 帮你生成一整套静态 HTML 页面。

### 为什么选 Hexo？

选择 Hexo 的理由其实很朴素：

- **Markdown 写作**：文章就是 `.md` 文件，版本管理自然就用 Git，不用额外折腾数据库
- **生成速度快**：Hexo 用 Node.js 驱动，生成数百篇文章也就几秒钟的事
- **主题丰富**：本站用的是 [NexT](https://theme-next.js.org/) 主题的 Gemini 方案，简洁大方，开箱即用
- **插件生态**：搜索、分类、标签、SEO 这些都有现成插件

### 项目结构

Hexo 项目的核心目录长这样：

```
├── _config.yml          # 站点配置（标题、URL、部署等）
├── _config.next.yml     # 主题配置（NexT 主题的专属配置）
├── package.json         # Node.js 依赖
├── scaffolds/           # 文章模板
├── source/              # 博客源文件
│   ├── _posts/          # 文章（Markdown）
│   ├── categories/      # 分类页
│   └── tags/            # 标签页
└── themes/              # 主题文件
    └── next/
```

其中 `_config.yml` 是整个站点的配置中心，包括站点名称、URL 格式、每页文章数、部署目标等。`_config.next.yml` 则是 NexT 主题的配置，采用 Hexo 推荐的 Alternate Theme Config 方式，把主题配置和站点配置分开管理，升级主题时不会冲突。

写新文章只需要在 `source/_posts/` 下新建一个 Markdown 文件，加上 front-matter 头信息：

```yaml
---
title: 文章标题
date: 2026-05-20 17:00:00
tags:
- tag1
- tag2
---
```

然后 `hexo generate` 就能生成对应的 HTML 页面。

## 双分支设计：源码与发布分离

这个仓库用了两个分支，分工明确：

### `hexo` 分支——源码分支

这是仓库的默认分支，存放博客的「源代码」：

- `_config.yml`、`_config.next.yml` 等配置文件
- `source/_posts/` 下的所有文章 Markdown
- `themes/` 下的主题文件
- `package.json` 和 `package-lock.json`
- `.github/workflows/` 下的 CI/CD 配置

所有写作和配置的变更都在这个分支上进行。你看到的每一篇文章、每一项配置，都来自这个分支。

### `master` 分支——发布分支

这个分支只存放 `hexo generate` 生成的静态文件（HTML、CSS、JS 等）。GitHub Pages 直接从这个分支读取内容，对外提供网站服务。

这个分支的内容完全由自动化流程生成，**不需要也不应该手动修改**。每次发布都会用 `force_orphan` 模式覆写，确保发布分支的提交历史干净——只有一个提交，代表最新一次发布。

### 为什么要分成两个分支？

1. **关注点分离**：源码分支关注「内容」，发布分支关注「展示」。写作时不用管生成后的 HTML 长什么样，部署时也不需要关心 Markdown 的内容
2. **版本管理**：文章的修改历史在 `hexo` 分支上清晰可溯，而 `master` 分支每次部署都是全新生成，不会积累无意义的提交历史
3. **安全隔离**：发布分支只有静态文件，不会意外泄露源码或配置中的敏感信息

## GitHub Actions：推代码即发布

手动 `hexo deploy` 当然可以，但每次写完文章都要自己跑一遍命令，时间久了难免忘记或者嫌麻烦。GitHub Actions 解决了这个问题——只要代码推到 `hexo` 分支，自动完成构建和部署。

### 工作流配置

整个 CI/CD 流程定义在 `.github/workflows/deploy.yml` 中，核心逻辑如下：

```yaml
name: Deploy Hexo Blog

on:
  push:
    branches:
      - hexo    # 监听 hexo 分支的 push 事件

jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - name: Checkout source       # 1. 拉取 hexo 分支源码
        uses: actions/checkout@v4
        with:
          ref: hexo

      - name: Setup Node.js         # 2. 配置 Node.js 18 环境
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'

      - name: Install dependencies  # 3. 安装依赖
        run: npm install

      - name: Generate static files # 4. 生成静态文件
        run: npx hexo generate

      - name: Deploy to master      # 5. 部署到 master 分支
        uses: peaceiris/actions-gh-pages@v4
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_branch: master
          publish_dir: ./public
          force_orphan: true
          commit_message: 'deploy: ${{ github.event.head_commit.message }}'
```

### 流程详解

整个流程可以用一张图概括：

```
推送代码到 hexo 分支
        │
        ▼
GitHub Actions 触发
        │
        ▼
Checkout 源码 ──→ 安装依赖 ──→ hexo generate
                                    │
                                    ▼
                          生成 ./public 目录
                                    │
                                    ▼
                    peaceiris/actions-gh-pages
                    将 public/ 推送到 master 分支
                                    │
                                    ▼
                          GitHub Pages 更新
                                    │
                                    ▼
                          https://wangz1x.github.io 生效
```

几个值得注意的细节：

- **`force_orphan: true`**：每次部署都创建一个全新的孤立提交，而不是在 master 分支的历史上追加。这样 master 分支永远只有一个提交，保持干净
- **`github_token`**：使用 GitHub 自动提供的 `GITHUB_TOKEN`，不需要额外配置个人访问令牌，开箱即用
- **`cache: 'npm'`**：利用 GitHub Actions 的缓存机制加速 `npm install`，不用每次都从零下载所有依赖
- **Node.js 18**：Hexo 6.x 兼容的 Node.js 版本，同时也是 LTS 版本，稳定可靠

### 写作 → 发布的完整流程

有了这套自动化，日常写博客的流程变得极简：

1. 在 `source/_posts/` 下新建 Markdown 文件
2. 写好内容，`git commit` + `git push` 到 `hexo` 分支
3. GitHub Actions 自动完成剩下的所有事情

从推代码到网站更新，通常只需 1-2 分钟。你完全可以推完代码就去干别的，回来时博客已经更新好了。

## 总结

这个博客的架构可以用三句话概括：

- **Hexo** 负责把 Markdown 变成静态网页
- **双分支** 把源码和发布产物隔离开来
- **GitHub Actions** 让推代码和网站更新之间的所有步骤全自动

没有服务器、没有数据库、没有运维——只是一个 Git 仓库和几个配置文件。简单、可靠、免费，个人博客该有的样子。
