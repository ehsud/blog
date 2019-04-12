---
layout: post
title: 使用 ffmpeg 的 2pass 两边编码模式进行视频转码
description: 介绍如何使用 ffmpeg 的 2pass 模式对视频进行转码
categories: [ffmpeg]
tags: [ffmpeg, 2pass, h264]
---

ffmpeg 当中有 5 种 H264 的码率控制方案，当然今天介绍 ffmpeg 的 2pass 两遍编码模式。 2pass 两遍编码是指需要执行两次操作才能完成视频转码。第 1 遍主要分析视频当中的场景变化，以及不同场景大概所需要的码率，第 2 遍才开始真正的编码转换和码率分配工作，2pass 是一种对码率有所要求，而又需要尽可能的保证最好的画质的一种方案。

### 一些准备工作

如果不了解 ffmpeg 或者想了解如何安装 ffmpeg 工具可以参考这个视频教程：
- bilibili 视频地址：[ffmpeg视频转码神器！](https://www.bilibili.com/video/av25487080)

### ffmpeg 的 2pass 视频转码实例

所有实例使用 ffmpeg 命令行方式操作，将不同格式的视频转码成 H264 编码，mp4 封装格式的视频

#### 1. 将一个视频素材转码成 码率为 5000k 的 MP4 格式的视频

比如我们有一个原始视频素材 vlog.mov，将其以 5000k 的码率转码成 h264 编码 mp4 的封装格式

    $ ffmpeg -y -i vlog.mov -c:v libx264 -preset slow -pix_fmt yuv420p -vb 5000k -pass 1 -c:a aac -ab 320k -f mp4 nul
    $ ffmpeg -y -i vlog.mov -c:v libx264 -preset slow -pix_fmt yuv420p -vb 5000k -pass 2 -c:a aac -ab 320k -f mp4 vlog.mp4

- *-c:v* 指定要转换的编码格式，这里指 H264 编码
- *-preset* 表示转码的参数预设，不同参数预设会影响转码的速度和画质
- *pix_fmt* 视频像素格式，一般 PC 和手机设备播放都是使用 yuv420p 格式
- *-vb* 指定视频的码率值，当然这个是平均码率值
- *-pass* 指定 2pass 两遍编码模式编号，`1` 表示第 1 步分析视频，`2` 表示第 2 步开始真正的转码
- *-c:a* 表示音频编码格式，这里使用常用的 aac 编码格式
- *-ab* 音频的码率，这里以 320k 为例
- *-f* 指定视频的封装格式，这里指定为 mp4 格式

- 第 1 次分析视频，最后不需要输出文件，所以指定为 nul 空文件
- 第 2 次转码视频，最后需要指定输出的新文件名称，所以指定为 vlog.mp4 即可

#### 2. 如何限制视频的码率在一个最小值和最大值之间

通常我们使用 `-vb` 参数来给视频指定码率值，但视频中每个画面的码率并不都是保持你设定的这个码率值，实际上会有上下波动，简单画面场景的码率可能小于这个值，复杂场景的码率可能大于这个值。我们可以通过 `-minrate` 和 `-maxrate` 两个参数来限制码率波动

    $ ffmpeg -y -i vlog.mov -c:v libx264 -preset slow -pix_fmt yuv420p -vb 5000k -minrate 5000k -maxrate 5000k -bufsize 5000k -pass 1 -c:a aac -ab 320k -f mp4 nul
    $ ffmpeg -y -i vlog.mov -c:v libx264 -preset slow -pix_fmt yuv420p -vb 5000k -minrate 5000k -maxrate 5000k -bufsize 5000k -pass 2 -c:a aac -ab 320k -f mp4 vlog.mp4

- *-minrate* 指定码率的最小值，最小码率限制
- *-maxrate* 指定码率的最大值，最大码率限制
- *-bufsize* 指定编码缓冲区大小，如果不指定这个缓冲区大小，最大码率限制可能会不起作用

### 使用 ffmpeg 一键转码脚本自动转码

可能对那些新手，特别是对计算机操作不太了解的人来说，使用命令行操作会有些难度，所以我们写了一个在 Windows 下使用的一键自动转码的批处理脚本程序

下载地址：[ffmpeg 一键转码 2pass 版本.bat](/script/2pass.bat)

使用方法很简单，只需要将你要转码的视频素材拖放到这个下载好的 `2pass.bat` 上即可自动转码。当然使用这个脚本之前，你需要确保你的电脑已经安装了 ffmpeg 工具。

当然你可能需要自定义码率参数，直接修改这个 2pass.bat 文件中的参数即可

- `set bitrate=5000k` 这行参数中的 `5000k` 就是码率值
