---
layout: default
title: PostgreSQL 性能优化
---

**配置文件参数单位说明**

    内存单位：    kB = 千字节   MB = 兆字节   GB = 千兆字节  TB = 兆兆字节
    时间单位：    ms = 毫秒     s =  秒      min = 分钟     h = 小时   d = 天

##### 内存相关优化

**shared_buffers = 128MB**

PostgreSQL 能使用的共享内存大小,增大这个值可有效提高性能。合理的值为当前系统总内存的 25%，但如果超过 40% 并不会有更好的性能提升，而且同时还需要相应的增加 max_wal_size 值

**huge_pages = try**

设置启用或禁用大页内存功能，可选值为 try(默认)，on (开启)，off(关闭)，这个选项只有在 Linux 下才可用，默认为 try 时会自动尝试启用大页内存，如果失败会自动转为正常模式。当设置为 on 开启时，如果失败则无法启动 PostgreSQL 服务器

**temp_buffers = 8MB**

设置每个数据库会话使用的临时缓冲区的最大使用内存大小

**work_mem = 4MB**

用于 postgresql 内部排序操作和哈希表使用的内存大小，如果有一些复杂查询，可能会同时有多个并行的排序或者哈希操作，而每个并行的操作会占用同样 work_mem 大小的内存，也就是可能会占用超过 work_mem 设置大小的数倍以上的内存

**maintenance_work_mem = 32MB**

指定 VACUUM、CREATE INDEX、ALTER TABLE ADD FOREIGN KEY 等操作时的可用最大内存数，当执行 autovacuum 自动清理操作时可能会占用超过 autovacuum_max_workers 倍的内存大小，所以这个参数不宜设置过大

**max_files_per_process = 1000**

设置 PostgreSQL 每个进程能够打开的最大文件数，其值默认为 1000，但不要超过操作系统的内核参数 `unlimit -n` 的大小。如果遇到 "Too many open files" 错误，可尝试减小这个值

