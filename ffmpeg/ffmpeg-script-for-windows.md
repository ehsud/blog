---
layout: post
title: ffmpeg 一键自动转码脚本 windows 版
description: 一些便携 ffmpeg 自动转码处理脚本
categories: [ffmpeg]
tags: [ffmpeg, windows]
---


这些批处理脚本适用于 Windows 系统，一共 5 种脚本，对应 ffmpeg 的 5 种 H264 转码方式。当然这些脚本都是针对 H264 编码的，也就是使用这些脚本可以将任何格式的视频转码成 H264 编码的视频

### ffmpeg 脚本使用方法
这些脚本的使用方法很简单，只需将要转码的视频文件，拖放至下载好的脚本程序上即可，转码完成后会在原视频素材目录下生成新的转码后的视频文件。

### ffmpeg 脚本下载地址

- [CQP 转码模式.bat](/script/cqp.bat) ffmpeg cqp 转码模式
- [ABR 转码模式.bat](/script/abr.bat) ffmpeg abr 转码模式
- [CRF 转码模式.bat](/script/crf.bat) ffmpeg crf 转码模式
- [VBR 转码模式.bat](/script/vbr.bat) ffmpeg vbr 转码模式
- [2PASS 转码模式.bat](/script/2pass.bat) ffmpeg 2pass 转码模式

### 如何修改脚本中的视频转码参数

每个脚本都有默认配置的转码参数，例如码率，音频格式，像素格式等等，如果需要自定义这些参数，只需要使用记事本编辑这些脚本文件，修改里面的参数即可，例如 crf.bat 转码脚本为例

    cd /d %~dp1
    
    :: 原文件名称
    set in=%~nx1
    :: 输出文件名称
    set out=%~n1-crf.mov
    :: crf 画质级别，值越小越好，但不要太小
    set crf=16
    :: 通用参数选项
    set opt=-preset slow -pix_fmt yuv420p -movflags faststart
    
    :: 调用 ffmpeg 进行编码
    ffmpeg -y -i %in% -vcodec libx264 -crf %crf% %opt% -acodec aac -ab 320k %out%
    
    pause

脚本里面以 `::` 开头的表示参数说明，表示这个参数做什么用的，比如你要修改 crf 转码模式下的视频画质级别，直接修改 `crf=16` 的数字值即可。再比如要修改音频码率，修改 `-ab 320k` 参数即可，例如 `-ab 128k` 就表示音频码率为 128k，依次类推。。

