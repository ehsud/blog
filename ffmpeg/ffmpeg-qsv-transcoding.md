---
layout: post
title: ffmpeg 使用 QSV 硬件加速视频转码
description: 讲解 ffmpeg 使用 QSV 进行视频转码
categories: [ffmpeg]
tags: [ffmpeg, intel, windows]
---

平时我们会遇到很多视频转码需求，因为通常使用 CPU 来进行转码不如 GPU 效率高。所以目前大部分都使用 GPU 显卡硬件来加速视频转码，我们以 Windows 平台为例，介绍如何在 ffmpeg 中使用 QSV 进行视频转码加速

### 什么是 QSV 它有什么用？

QSV 是 Intel 公司的 Quick Sync Video 快速视频同步技术，主要用于视频处理与转码，市面上大部分最新的因特尔 CPU 都内置了 QSV 模块，它就像一个 CPU 内置的 GPU 显卡模块。你不需要单独购买或安装它。只要你用的是因特尔的 CPU 你就拥有她。QSV 模块可以用来快速的编码和解码 H264 视频数据，也就是说在 ffmpeg 中可以使用它来进行视频硬件加速转码

### ffmpeg 使用 QSV 进行视频解码

查看 ffmpeg 中支持 qsv 解码的视频格式有哪些

    ffmpeg -decoders | findstr qsv

将一个 H264 编码的视频转码成 yuv420p 像素格式的 RAW 文件

    ffmpeg -hwaccel qsv -c:v h264_qsv -i input.mp4 -vf hwdownload,format=nv12 -pix_fmt yuv420p output.yuv

使用 qsv 解码一个 H264 的视频文件，并且使用 sdl 进行视频播放

    ffmpeg -hwaccel qsv -c:v h264_qsv -i input.mp4 -vf hwdownload,format=nv12 -pix_fmt yuv420p -f sdl -

使用 qsv 对视频进行解码，但不会生成转码文件，仅用于转码测试用

    ffmpeg -hwaccel qsv -c:v h264_qsv -i input.mp4 -f null -

使用 qsv 将一个 H265 的视频素材解码并转码为一个 H265 10比特，像素格式为 p010le 的 RAW 格式文件

    ffmpeg -hwaccel qsv -c:v hevc_qsv -load_plugin hevc_hw -i input.mp4 -vf hwdownload,format=p010 -pix_fmt p010le output.yuv

### ffmpeg 使用 QSV 进行视频编码

查看 ffmpeg 中支持 qsv 编码的视频格式有哪些

    ffmpeg -encoders | findstr qsv

查看 ffmpeg 中 H264 编码格式中 QSV 的编码参数有哪些

    ffmpeg -h encoder=h264_qsv

使用 VBR 模式，将一个 YUV RAW 格式的视频编码为 1080p 并且码率为 5Mbps 的视频文件

    ffmpeg -init_hw_device qsv=hw -filter_hw_device hw -f rawvideo -pix_fmt yuv420p -s:v 1920x1080 -i input.yuv -vf hwupload=extra_hw_frames=64,format=qsv -c:v h264_qsv -b:v 5M output.mp4

### 在 ffmpeg 中使用 QSV 进行视频转码

使用 CBR 模式对一个 H264 视频以 5Mbps 的码率进行转码

    ffmpeg -init_hw_device qsv=hw -filter_hw_device hw -i input.mp4 -vf hwupload=extra_hw_frames=64,format=qsv -c:v h264_qsv -b:v 5M -maxrate 5M output.mp4

使用 CQP 模式对一个 H264 视频进行转码

    ffmpeg -init_hw_device qsv=hw -filter_hw_device hw -i input.mp4 -vf hwupload=extra_hw_frames=64,format=qsv -c:v h264_qsv -q 25 output.mp4

### ffmpeg 在多个 GPU 设备上的使用

ffmpeg 当中可以使用 `-qsv_device` 参数设置默认使用哪个 GPU 设备，比如当你的系统中拥有 Intel、 AMD 或者 Nvidia 等多个设备时，可能需要这个自定义设置参数。例如指定一个 `/dev/dri/renderD128` 设备为 QSV 的默认 GPU 设备来进行转码

    fmpeg -hwaccel qsv -qsv_device /dev/dri/renderD128 -c:v h264_qsv -i input.mp4 -c:v h264_qsv output.mp4

### 参考文档 Reference

ffmpeg 官方文档 [https://trac.ffmpeg.org/wiki/Hardware/QuickSync](https://trac.ffmpeg.org/wiki/Hardware/QuickSync)
