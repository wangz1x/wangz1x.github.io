---
title: Streamlink + VLC：在终端里看直播的正确姿势
date: 2026-05-20 15:00:00
tags:
- streamlink
- VLC
- tools
- macOS
---

如果你经常看直播，可能会遇到这样的痛点：浏览器里开直播网页，弹幕窗口占一半屏幕，广告弹窗时不时冒出来，内存占用居高不下——明明只是想看个画面而已，为什么要开整个浏览器？

[Streamlink](https://streamlink.github.io/) 就是解决这个问题的工具。它是一个命令行程序，可以从各种直播平台提取视频流，然后直接发送到你喜欢的播放器中播放。配合 [VLC](https://www.videolan.org/) 这款经典播放器，你就能在终端里轻松观看直播，无需打开浏览器。

<!--more-->

## 为什么是 Streamlink + VLC？

先说说各自的定位：

- **Streamlink**：不是播放器，而是「流提取器」。它负责从直播平台（Twitch、YouTube、Bilibili 等）解析出真实的视频流地址，然后通过管道或 HTTP 传给播放器。
- **VLC**：不是浏览器，而是纯播放器。它只负责播放视频，没有网页渲染、没有 JavaScript、没有广告——干净利落。

两者结合的好处：

1. **省资源**：不需要启动浏览器，内存占用从 GB 级降到百 MB 级
2. **无广告**：纯视频流播放，没有网页广告和弹窗干扰
3. **灵活控制**：通过命令行参数精确控制画质、缓存、录制等行为
4. **支持平台广**：Streamlink 内置 100+ 平台插件，Twitch、YouTube、Bilibili、抖音等主流平台均支持

## 安装

### macOS（Apple Silicon）

```bash
# 安装 Streamlink
brew install streamlink

# 安装 VLC
brew install --cask vlc
```

安装完成后验证：

```bash
streamlink --version
# streamlink 7.6.0

# 确认 VLC 已安装
ls /Applications/VLC.app
```

### 其他平台

```bash
# Linux (pip)
pip install streamlink

# Windows (pip)
pip install streamlink
```

VLC 请前往 [videolan.org](https://www.videolan.org/) 下载对应平台的安装包。

## 基本使用

### 最简单的命令

```bash
streamlink <直播地址> best
```

这行命令会自动提取指定直播间的最高画质流，并调用 VLC 播放。例如：

```bash
# Twitch 直播
streamlink https://www.twitch.tv/shroud best

# YouTube 直播
streamlink https://www.youtube.com/watch?v=xxx best
```

### 查看可用画质

不确定有哪些画质可选？去掉画质参数就行：

```bash
streamlink https://www.twitch.tv/shroud
```

输出类似：

```
[cli][info] Found matching plugin twitch for URL ...
Available streams: audio_only, 160p, 360p, 480p, 720p, 720p60, 1080p60 (best)
```

然后选择你想要的画质：

```bash
streamlink https://www.twitch.tv/shroud 720p60
```

也可以用 `best`（最高画质）和 `worst`（最低画质）作为快捷关键词，还可以用逗号指定备选：

```bash
# 优先 1080p60，没有就选 best
streamlink https://www.twitch.tv/shroud 1080p60,best
```

### Bilibili 直播

Streamlink 同样支持 Bilibili：

```bash
streamlink https://live.bilibili.com/6 best
```

## 进阶配置

### 配置文件

Streamlink 支持两种配置文件，可以设置默认参数，避免每次手动输入。

| 文件 | 说明 |
|------|------|
| `~/.streamlink/config` | 通用配置文件（推荐） |
| `~/.streamlinkrc` | 另一种配置文件，支持按平台分段设置 |

> **区别**：`~/.streamlink/config` 是纯键值对，适合全局默认参数；`~/.streamlinkrc` 支持 `[plugin]` 段落，可以为不同平台设置不同的参数（比如给 Bilibili 单独配 Cookie），功能更灵活。

#### 使用 `~/.streamlink/config`

```bash
mkdir -p ~/.streamlink
cat > ~/.streamlink/config << 'EOF'
# 默认播放器（如果 VLC 不在 PATH 中，写绝对路径）
player=/Applications/VLC.app/Contents/MacOS/VLC

# 默认画质
default-stream=best

# 播放器参数：降低网络缓存到 2 秒，减少直播延迟
player-args=--network-caching=2000

# VLC 播完自动退出
player-args=--play-and-exit

# 环形缓冲区大小（默认 16M，网络不稳定可调大）
ringbuffer-size=32M
EOF
```

> **注意**：如果 `player-args` 出现多次，以最后一次为准。如果需要同时传递多个参数，写在一行里即可，如 `player-args=--network-caching=2000 --play-and-exit`。

#### 使用 `~/.streamlinkrc`（按平台配置）

`~/.streamlinkrc` 的最大优势是支持 `[plugin]` 段落，可以对特定平台做定制化配置。一个典型的使用场景：**Bilibili 直播需要登录 Cookie 才能获取高清流**，这时可以在 `~/.streamlinkrc` 中单独为 Bilibili 配置认证信息：

```ini
# 全局默认配置
player=/Applications/VLC.app/Contents/MacOS/VLC
default-stream=best
ringbuffer-size=32M

# 以下是为 Bilibili 专门配置的参数
[bilibili.com]
# 通过 HTTP Header 注入 Cookie，解决未登录无法获取直播流的问题
http-header=Cookie=SESSDATA=你的SESSDATA值
```

获取 SESSDATA 的方法：

1. 在浏览器中登录 [bilibili.com](https://www.bilibili.com)
2. 按 `F12` 打开开发者工具 → Application（应用）→ Cookies
3. 找到 `SESSDATA` 字段，复制其值
4. 粘贴到 `~/.streamlinkrc` 中

> **安全提醒**：SESSDATA 等同于登录凭证，请勿分享或公开。建议对 `~/.streamlinkrc` 设置文件权限：`chmod 600 ~/.streamlinkrc`

配置好之后，直接运行 `streamlink https://live.bilibili.com/6 best` 即可，不需要每次手动传 Cookie。

### 播放器参数详解

通过 `--player-args` 可以向 VLC 传递任意参数。以下是一些实用的 VLC 参数：

| 参数 | 作用 |
|------|------|
| `--network-caching=2000` | 网络缓存设为 2 秒（默认 1 秒），减少直播延迟 |
| `--play-and-exit` | 播放结束自动退出 VLC |
| `--fullscreen` | 全屏播放 |
| `--no-video-title-show` | 不在画面上方显示视频标题 |
| `--repeat` | 重复播放当前项 |
| `--loop` | 循环播放全部 |

使用示例：

```bash
streamlink https://live.bilibili.com/6 best \
  --player-args="--network-caching=2000 --play-and-exit --fullscreen"
```

### 设置窗口标题

Streamlink 支持自定义 VLC 的窗口标题，使用 `--title` 参数：

```bash
streamlink --title "{author} - {category} - {title}" \
  https://www.twitch.tv/shroud best
```

可用的元数据变量因平台而异，常见的有：

- `{author}`：主播名
- `{category}`：直播分类
- `{title}`：直播标题

### 录制直播流

边看边录，使用 `--record` 参数：

```bash
streamlink https://www.twitch.tv/shroud best \
  --record "~/Recordings/{author}-{time:%Y%m%d_%H%M%S}.ts"
```

如果只想录制不播放，用 `--output` 替代：

```bash
streamlink https://www.twitch.tv/shroud best \
  --output "~/Recordings/{author}-{time:%Y%m%d_%H%M%S}.ts"
```

`{time:...}` 支持 strftime 格式，可以根据时间自动命名文件。

## 实用技巧

### 1. 降低直播延迟

看直播时，延迟是最让人头疼的问题。Streamlink 本身对直播流的处理延迟很低，大部分延迟来自播放器的缓存。调整 VLC 的网络缓存可以有效降低延迟：

```bash
streamlink https://www.twitch.tv/shroud best \
  --player-args="--network-caching=1000"
```

将缓存设为 1 秒（1000ms），可以获得接近实时的体验。如果网络不稳定导致频繁缓冲，可以适当增大到 2000-3000ms。

对于 Twitch 低延迟流，还可以配合 Streamlink 的 `--twitch-low-latency` 选项：

```bash
streamlink --twitch-low-latency \
  --player-args="--network-caching=1000" \
  https://www.twitch.tv/shroud best
```

### 2. 后台播放（只要声音不要画面）

如果你只需要听直播的声音（比如听播客、听音乐直播），可以让 VLC 不显示视频窗口：

```bash
streamlink https://www.twitch.tv/shroud audio_only \
  --player-args="--intf dummy --no-video"
```

`audio_only` 是 Twitch 提供的纯音频流，配合 VLC 的 `--no-video` 参数，可以实现纯后台音频播放。

### 3. 多开直播

每个终端窗口运行一个 Streamlink 实例即可：

```bash
# 终端 1
streamlink https://www.twitch.tv/shroud 480p

# 终端 2
streamlink https://www.twitch.tv/summit1g 480p
```

选择较低画质可以降低带宽和资源占用。

### 4. 外部 HTTP 模式

想让局域网内的其他设备（手机、平板、电视盒子）也能看？使用 `--player-external-http`：

```bash
streamlink --player-external-http \
  --player-external-http-port 8080 \
  https://www.twitch.tv/shroud best
```

启动后，同一局域网内的设备在浏览器中打开 `http://<你的IP>:8080` 即可观看。

### 5. 写成 Shell 函数方便调用

在 `~/.zshrc` 或 `~/.bashrc` 中添加快捷函数：

```bash
# 快速看直播
live() {
  streamlink "$1" "${2:-best}" \
    --player-args="--network-caching=2000 --play-and-exit"
}

# Twitch 低延迟模式
twitch() {
  streamlink --twitch-low-latency \
    --player-args="--network-caching=1000" \
    "https://www.twitch.tv/$1" "${2:-best}"
}

# Bilibili 直播
bili() {
  streamlink "https://live.bilibili.com/$1" "${2:-best}" \
    --player-args="--network-caching=2000 --play-and-exit"
}
```

使用方式：

```bash
live https://live.bilibili.com/6
twitch shroud 720p60
bili 6
```

## 常见问题

### Q: 提示找不到 VLC？

如果 VLC 不在系统 PATH 中，Streamlink 可能找不到它。有两种解决方法：

1. 在配置文件中指定 VLC 的完整路径（macOS 示例）：
   ```
   player=/Applications/VLC.app/Contents/MacOS/VLC
   ```

2. 创建符号链接：
   ```bash
   sudo ln -s /Applications/VLC.app/Contents/MacOS/VLC /usr/local/bin/vlc
   ```

### Q: Bilibili 直播打不开？

Bilibili 的直播流需要登录 Cookie 才能获取。最推荐的方式是在 `~/.streamlinkrc` 中配置（详见上方「使用 `~/.streamlinkrc`」段落），配置一次后无需每次手动传参。

如果只是临时使用，也可以通过命令行参数传入：

```bash
streamlink --http-header="Cookie=SESSDATA=你的SESSDATA值" \
  https://live.bilibili.com/6 best
```

### Q: 画质选项里没有高清？

可能的原因：
1. 主播没有开启高画质推流
2. 部分平台的高画质需要登录或会员
3. 网络环境导致 Streamlink 检测不到某些画质档位

### Q: 直播频繁缓冲怎么办？

1. 降低画质（如从 `best` 改为 `720p` 或 `480p`）
2. 增大 VLC 的网络缓存：`--player-args="--network-caching=5000"`
3. 增大 Streamlink 的环形缓冲区：`--ringbuffer-size=64M`
4. 检查网络连接，特别是跨境直播时的网络状况

## 总结

Streamlink + VLC 的组合，本质上是把「看直播」这件事回归到最简单的形态：提取流、播放流。没有浏览器、没有网页、没有广告——只有纯粹的视频播放。

如果你经常看直播，尤其是 Twitch 或 Bilibili 上的长时间直播，这套工具链能显著降低系统资源占用，同时提供更灵活的控制能力。配置好之后，一条命令就能开始观看，比打开浏览器再找到直播间要快得多。

赶紧试试吧 🎬
