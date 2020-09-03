---
layout: post
title: ffmpeg 批量下载 m3u8 视频 windows 版
description: ffmpeg 批量下载 m3u8 视频 windows 版脚本
categories: [ffmpeg]
tags: [ffmpeg, m3u8, windows]
---


这个批处理脚本的功能是使用 ffmpeg 来批量下载视频网站上的 m3u8 视频文件，此批处理脚本适用于 Windows 系统

### ffmpeg 脚本使用方法

> 在运行此脚本之前，请确保你的电脑已经安装了 ffmpeg 工具，否则此脚本无法运行

这些脚本的使用方法很简单，首先将你的所有 m3u8 视频地址，按照一行一个地址存放到一个 txt 文本文件中，例如下面的例子

```
http://live.bilibili.com/live/1f5w1f621f41f.m3u8
http://live.bilibili.com/live/2kifjrefjojfre.m3u8
http://live.bilibili.com/live/32rk0ff3621f41f.m3u8
http://live.bilibili.com/live/32f16535w1f621f41f.m3u8
http://live.bilibili.com/live/fkwe5w1f621f41f.m3u8
http://live.bilibili.com/live/1f5wwfe45f41f.m3u8
http://live.bilibili.com/live/1f5w0051151f41f.m3u8
```

然后将保存有 m3u8 视频地址列表的 txt 文件拖放至下载好的脚本程序上即可，下载完成的视频保存在与 txt 文件同一目录下的 video 文件夹下

### ffmpeg 脚本下载地址

- [ffget.bat](/script/ffget.bat) ffmpeg 批量下载脚本 windows 版

注意此脚本使用 GPL V3 开源协议发布，此脚本适用于那些公开的视频资源，对于那些加密、需要付费或者需要登录的视频无法使用此脚本
