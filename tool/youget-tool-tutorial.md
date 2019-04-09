---
layout: default
title: you-get 工具安装及使用教程
copyleft: true
---

you-get 是一个使用 python 开发的开源视频下载工具，目前支持大部分国内外的主流视频平台的视频下载，本文档基于 Windows 系统平台，讲解如何安装和使用 you-get 工具

##### 安装方法

1. 进入 https://www.python.org/downloads 官方网站，下载并安装 python

2. 打开命令行终端，使用 pip3 命令来安装 you-get 工具

```
C:\> pip3 install you-get
```

B站视频教程：[https://www.bilibili.com/video/av40055245](https://www.bilibili.com/video/av40055245)

##### 基本使用方法

- 例如下载B站这个视频 https://www.bilibili.com/video/av25487080

```
C:\> you-get https://www.bilibili.com/video/av25487080
```  


##### 高级使用实例

- 使用 `-i` 参数可以列出视频有哪些清晰度的格式

```
C:\> you-get -i https://www.bilibili.com/video/av25487080
```  

- 假如视频需要密码才能访问，可使用 `-P` 参数来指定密码

```
C:\> you-get -P 123456 http://v.youku.com/v_show/id_XMzg1NTk1NzI2OA==.html
```  

- 如果是多P视频，可使用 `-l` 参数来自动下载连续的多个视频列表

```
C:\> you-get -l https://www.bilibili.com/video/av4050443
```  

- 使用 http 代理下载一个视频

```
C:\> you-get -x 127.0.0.1:80 https://www.youtube.com/watch?v=0xf74982a
```

- 使用 socks 代理下载一个视频

```
C:\> you-get -s 127.0.0.1:233 https://www.youtube.com/watch?v=0xf74982a
```

##### 如何下载那些需要登录才能下载的视频

1. 首先需要使用 firefox 火狐浏览器事先登录视频网站平台账号  

2. 在开始运行中输入 `%appdata%/Mozilla/firefox/profiles` 确定，会显示类似下面这样的文件夹

```
5vucqwst.default-1528101192336     // 每个人的文件夹名称可能不一样
```

这个文件夹下会有一个 cookies.sqlite 文件，其完整文件路径如下

```
C:\Users\Administrator\AppData\Roaming\Mozilla\Firefox\Profiles\5vucqwst.default-1528101192336\cookies.sqlite
```

3.然后使用 you-get 工具的 `-c` 参数加载 cookie 文件，便可下载视频

```
C:\> set cookie=C:\Users\Administrator\AppData\Roaming\Mozilla\Firefox\Profiles\5vucqwst.default-1528101192336\cookies.sqlite
C:\> you-get -c %cookie% http://v.youku.com/v_show/id_XMzg1NTk1NzI2OA==.html
```

