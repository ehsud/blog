---
layout: default
title: sed 命令使用教程
description: 一个 sed 命令工具使用教程
copyleft: true
---

##### sed 命令的使用

sed 是 Linux 和 Unix 上的一种轻量级流编辑器，主要用来处理文本文件内容，它可以查找，替换和修改文本文件。你可能觉得这家伙跟 Vim 和 Emacs 有什么不一样，sed 与其他编辑器不一样的地方就是 "快"，有一句话叫做：天下武功为快不破。sed 在处理一个文件的时候，不需要像 Vim 和 Emacs 一样需要进入到全局交互编辑模式，而是直接在命令行上一句话就能搞定，sed 的这种特性在一些无需人工干预的自动化任务处理场景下非常有用。

##### sed 的基本使用格式

    sed [option] 'script' file

`option` 表示一些可选的参数和选项

`script` 表示一些脚本和可执行命令

`file`   表示需要被 sed 处理的文件，可同时指定多个文件
   
**sed 的 option 参数选项**
   
`-n` 默认 sed 会输出文件所有行内容，加上这个参数就表示只输出被 sed 处理过的行

`-i` 默认 sed 修改文件内容后并不会真的去修改原文件，这个参数表示让 sed 真的去修改源文件
   
**sed 的 script 脚本动作**

`a` 表示在文件中追加一行文本内容

`c` 表示对文件的某一行进行内容替换

`d` 表示删除文件的某行内容

`i` 表示在文件中插入一行文本内容

`p` 表示打印输出文件的某行内容

`s` 表示文本字符串替换，默认只替换 1 次

`g` 配合 s 动作使用，表示全局替换，将所有匹配到的字符串都替换

> 默认情况下 sed 修改文件后，只会将修改后的内容输出到 stdout 标准输出，而不会真的去修改原文件。

> 在 sed 中，可以同时执行多个动作指令，多个动作指令之间用分号 `;` 隔开即可，也就是可以一次性处理多个不同的内容

**sed 的工作方式**

sed 会从一个指定的文件或者 `stdio` 标准输入读取内容，然后每次按顺序读取内容中的一行，再然后对读取到的那一行进行相关的动作处理，直到文件内容读取完毕

##### 一些 sed 使用示例

比如现在有这么一个文件 company.txt 内容如下

    yahoo 1995 this is yahoo inc
    google 1997 this is google inc
    twitter 2008 this is twitter inc

**文本字符串替换**
   
我们想将 company.txt 文件中的 yahoo 替换成 baidu

    $ sed 's/yahoo/baidu/' company.txt
    baidu 1995 this is yahoo inc
    google 1997 this is google inc
    twitter 2008 this is twitter inc

`s` 表示字符串替换，你会发现文件中第一行的第一个 yahoo 被替换成了 baidu 而同一行中后面的 yahoo 没有被替换，也就是说同一个字符串 sed 默认只替换一次。这特么也太坑爹了，做个大保健还不来全套的，真是大杀风景。。。
   
使用 sed 进行全局字符串替换
   
    $ sed 's/yahoo/baidu/g' company.txt
    baidu 1995 this is baidu inc
    google 1997 this is google inc
    twitter 2008 this is twitter inc

`s` 表示字符串替换，后面的 `g` 就表示全局替换，会将所有 yahoo 替换成 baidu，而不是只替换一次。此刻是不是觉得就像喝了一瓶 82 年的雪碧，爽。。

在某一行中寻找字符串进行替换

    $ sed '3s/2008/1990/' company.txt
    yahoo 1995 this is yahoo inc
    google 1997 this is google inc
    twitter 1990 this is twitter inc

`s` 表示字符串替换， `3s` 就表示在文件的第 3 行中寻找字符串 2008 然后用字符串 1990 来替换之。

    $ echo 'one two three hello' | sed -e 's/one/this/;s/hello/robot/'

上面这个 's/one/this/;s/hello/robot/' 指令会将字符串 one 替换成 this，然后会将字符串 hello 替换成 robot，也就是一次性执行了多个内容替换动作

**输出文件的某行内容**
   
打印输出文件中的第 2 行内容

    $ sed -n '2p' company.txt
    google 1997 this is google inc

动作 `p` 表示打印，在这个例子中表示打印输出文件中的第 2 行内容， `-n` 表示只输出被 sed 处理过的行，也就是第 2 行被打印输出动作处理过

	$ sed -n '1p;2p;3p' company.txt
	yahoo 1995 this is yahoo inc
    google 1997 this is google inc
    twitter 2008 this is twitter inc

上面这个例子表示，同时使用多个 'p' 打印输出动作来打印文件中的第 1 行、第 2 行和第 3 行内容。还有一个更加简单的方法来打印输出一些连续的行，例如下面这个例子

	$ sed -n '1,3p' company.txt

上面这个表示打印输出 company.txt 文件中的第 1 行到第 3 行之间的内容，而在 `1,3p` 中，逗号 `,` 表示一个范围区间

**删除文件的某行内容**

删除文件中的第 1 和第 3 行内容

    $ sed '1d;3d' company.txt
    google 1997 this is google inc

`d` 表示删除某些行，这个例子中表示删除第 1 行和第 3 行内容。

    $ sed '1,3d' company.txt

上面这个例子表示删除 company.txt 文件中的第 1 行到第 3 行之间的内容，也就是包括中间的第 2 行内容

**在文件中追加一行内容**

在文件中的第 2 行后面追加一行文本内容

    $ sed '2a baidu 2000 this is baidu inc' company.txt
    yahoo 1995 this is yahoo inc
    google 1997 this is google inc
    baidu 2000 this is baidu inc
    twitter 2008 this is twitter inc

`a` 表示追加文本行内容，也就是在文件中的第 2 行后面追加了一行内容 "baidu 2000 this is baidu inc"
   
**在文件中插入一行内容**

在文件中的第 2 行前面插入一行文本内容

    $ sed '2i baidu 2000 this is baidu inc' company.txt
    yahoo 1995 this is yahoo inc
    baidu 2000 this is baidu inc
    google 1997 this is google inc
    twitter 2008 this is twitter inc
   
`i` 表示插入文本行内容，也就是在文件中的第 2 行前面插入了一行内容 "baidu 2000 this is baidu inc"
   
**替换文件的某行内容**

替换文件中的第 3 行内容

    $ sed '3c baidu 2000 this is baidu inc' company.txt
    yahoo 1995 this is yahoo inc
    google 1997 this is google inc
    baidu 2000 this is baidu inc

`c` 表示行内容替换，上面这个意思就是将文件中第 3 行内容替换成 "baidu 2000 this is baidu inc"
   
**从文件中读取处理动作指令**

一般我们处理简单的任务时，是直接在 sed 命令行写处理指令，当处理指令很多的时候我们可以使用 -f 参数来从一个文件中读取 sed 的处理指令

    $ sed -f script.txt company.txt

`-f` 参数表示从一个文件读取 script 脚本指令

