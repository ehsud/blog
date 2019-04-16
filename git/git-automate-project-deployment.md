---
layout: post
title: 如何使用 git 自动部署 web 项目到服务器
description: 讲解如何使用 git 的 hook 特效自动化部署 web 项目到服务器
category: [git]
tags: [git, linux, deploy]
---

如今 git 的应用已经非常广泛了，今天我们来讲解如何使用 git 工具来将项目代码自动部署到远程 Web 服务器。其原理是基于 git 的 hooks 来实现的，官方文档称其为 “钩子”。但我觉得这个翻译没有一点高端大气上档次的赶脚！ git 的 hooks 是指每次你执行的 git 各种命令时自动触发执行的一些脚本，这些脚本可以帮助你做一些额外的自定义任务，比如当有新的代码更新时来自动发送邮件通知某个人等等。我们就是利用这个功能来实现代码自动部署。


### 什么是 git hooks ？

什么是 git hooks 上面已经讲过了，事实上 git hooks 是一些会被 git 自动调用的 shell 脚本程序，它可以是 sh、bash、perl、lua、甚至是 php 编写的任何脚本程序，当然执行了不同的 git 命令会调用不同的 hooks 脚本，而脚本又分为客户端执行的和服务器端执行的。例如下面这些例子

**客户端执行的**

- `pre-commit`   在创建提交信息之前执行
- `post-commit`  在整个提交过程完成后运行 
- `pre-rebase`   此 hook 会在 `git rebase` 命令之前运行
- `....`         其他的一些 hook 省略...

**服务器端执行的**

- `pre-receive`  当客户端推送代码到服务器时最先被执行的脚本
- `post-receive` 在客户端完成整个推送过程之后执行的脚本
- `update`       这个与上面的 pre-receive 脚本有些类似，但它会为每一个准备更新的分支各运行一次
- `...`          其他的一些 hook 省略...

当然具体详细的所有 git 的 hook 脚本可参考官方文档

官方文档：[https://git-scm.com/docs/githooks](https://git-scm.com/docs/githooks)

### 使用 git 自动代码部署准备

- **client** 表示客户端，也就是代码开发的本地仓库机器
- **server** 表示服务器，这里 web 服务器和远程 git 仓库在同一机器上

使用 git 自动部署 web 项目是使用的 git 的 post-receive 钩子脚本，这种钩子是使用的 304 食品级不锈钢制作，嗯！少废话，事实上 post-receive 钩子脚本会在客户端推送代码到服务器完成后，在服务器端会自动执行的脚本。原来是这样的思密达！我们开始干吧。

### Server 服务器端配置

先创建一个 /var/repos 目录，用来存放所有项目仓库

    $ mkdir /var/repos

再在上面的 /var/repos 目录下创建一个空的 demo.git 项目仓库

    $ cd /var/repos
    $ git init --bare demo.git

其中 `--bare` 表示创建一个不含工作区的裸仓库，服务器端仓库必须这样做

开始创建自动部署 hook 脚本文件，在仓库目录下的 hooks 文件夹下

    $ cd demo.git
    $ emacs hooks/post-receive

这里我们使用 emacs 编辑 post-receive 文件，内容如下

    #!/bin/sh
    git --work-tree=/var/www checkout -f master
    echo "The project has been successfully deployed to this server!"

其中第 2 行，就表示当客户端推送代码到服务器完成后，将代码更新到网站根目录 /var/www 下

- `--work-tree` 参数表示你的 web 服务器的网站根目录，最后的 master 表示将 master 分支的代码部署到网站根目录

最后使用 echo 命令，在完成代码部署之后，向客户端输出一条消息以告知代码部署完成！

    ssh://root@10.10.10.10/var/repos/demo.git

以上为 demo 项目仓库的完整地址，当然我们使用 ssh 协议的方式，因为简单，简单到爆炸，炸到飞起！

### Client 客户端配置

接下来就是客户端需要做的事情了，先创建一个项目仓库

    $ git init demo

然后随便写点代码，什么 hello world 这样高端的程序，完全不在话下，提起裤子就是干！

    $ echo "hello world" > readme.md
    $ git add .
    $ git commit -m "First code commit"

接下来将之前服务器端的 demo.git 仓库地址添加到本地仓库作为上游远程仓库

    $ git remote add web ssh://root@10.10.10.10/var/repos/demo.git

为了区分 web 服务器部署仓库，我们将远程服务器仓库取名为 web，以便好记。

    $ git push web master

最后使用 git push 将 master 分支的代码推送到服务器上去 OK 搞定！就这么简单。