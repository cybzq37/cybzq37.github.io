## [iostat](https://zhida.zhihu.com/search?content_id=734041830&content_type=Answer&match_order=1&q=iostat&zhida_source=entity)

iostat 是一个用于报告磁盘 I/O 统计信息的命令，属于 [sysstat](https://zhida.zhihu.com/search?content_id=734041830&content_type=Answer&match_order=1&q=sysstat&zhida_source=entity) 软件包的一部分。我们可以根据系统环境使用 yum 等工具安装 sysstat：

```text
# rpm -q sysstat 
sysstat-10.1.5-17.el7.x86_64
```

iostat 汇总并展示每个磁盘的 I/O 统计信息，提供包括 IOPS、吞吐量、I/O 请求等待时间和设备利用率等关键指标。它可以由任意用户执行，通常是命令行中监控磁盘 I/O 性能和排查相关问题的首选工具。

iostat 支持多种自定义输出选项。常用组合为 -dxz 1，其中：

- -d：仅显示磁盘统计信息
- -x：显示扩展统计列
- -z：跳过所有值为零的设备
- 1：每秒刷新输出一次

```text
# iostat -dxz 1
Linux 3.10.0-1062.9.1.el7.x86_64 (rhel-fews-cc)         01/07/2020      _x86_64_        (32 CPU)

Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await r_await w_await  svctm  %util
sda               0.28     1.35    2.34    8.52    36.45   510.13   100.68     0.06    5.36    3.79    5.79   0.17   0.18
dm-0              0.00     0.00    0.95    0.06     3.81     0.23     8.00     0.00    2.10    1.60   10.66   0.62   0.06
dm-1              0.00     0.00    1.65    9.81    30.58   509.90    94.31     0.06    5.32    6.07    5.19   0.12   0.14
dm-2              0.00     0.00    1.65    9.81    30.58   509.90    94.31     0.06    5.32    6.07    5.19   0.12   0.14
dm-3              0.00     0.00    1.65    9.80    30.63   508.68    94.17    10.69  933.11   12.15 1088.51   0.16   0.18
```

其输出包含以下列信息：

- Device: 设备名称
- rrqm/s: 每秒合并的读请求数：内核尝试将相邻的读请求合并成一个，以减少 I/O 负载
- wrqm/s: 每秒合并的写请求数，合并写请求以优化性能
- r/s: 每秒发出的读请求数
- w/s: 每秒发出的写请求数
- rkB/s: 每秒读取的数据量，单位为千字节
- wkB/s: 每秒写入的数据量，单位为千字节
- avgrq-sz: 平均每次I/O请求的数据大小单位为扇区（通常一个扇区是 512 字节）
- avgqu-sz: 平均等待处理的 I/O 请求队列长度，反映设备负载
- await: 平均I/O请求等待时间（毫秒）
- r_await: 读请求的平均等待时间（毫秒）
- w_await: 写请求的平均等待时间（毫秒）
- svctm: 设备平均每个请求的服务时间，单位为毫秒。理论上应小于 await
- %util: 设备忙碌时间占总时间的百分比，100% 表示设备一直被占用

这些列反映了各个设备在指定时间段内的 I/O 活动情况。要了解每一列的具体含义，可以使用 man iostat 查看官方手册：

```text
man iostat
```

## [vmstat](https://zhida.zhihu.com/search?content_id=734041830&content_type=Answer&match_order=1&q=vmstat&zhida_source=entity)

vmstat 是另一个常用的系统监控工具，用于报告虚拟内存的统计信息。它属于 [procps-ng](https://zhida.zhihu.com/search?content_id=734041830&content_type=Answer&match_order=1&q=procps-ng&zhida_source=entity) 软件包的一部分，该软件包通常在大多数 Linux 系统中默认安装，当然我们也可以使用 yum 手动安装：

```text
# rpm -q procps-ng 
procps-ng-3.3.10-23.el7.x86_64
```

vmstat 提供关于进程、内存、分页、块 I/O、中断、CPU 活动等方面的信息。在这里，我们主要使用它来监控 Linux 系统中的磁盘 I/O 性能。

可以使用如下命令以 1 秒为间隔采样一次磁盘 I/O 情况：

```text
# vmstat -d 1 1
disk- ------------reads------------ ------------writes----------- -----IO------
       total merged sectors      ms  total merged sectors      ms    cur    sec
sda   667530  12447 7660380 2108711 91090178 3458386 12047478760 1506891675      0  11791
dm-0  607338      0 4858728 1760585 206130      0 1649040 5723571      0   1245
dm-1   72135      0 2626562  466444 94344918      0 12045847864 1574232872      0  11050
dm-2   72135      0 2626562  466583 94344918      0 12045847864 1574410699      0  11050
dm-3   72240      0 2630178  905647 94422613      0 12046752440 3064011073      9  12087
dm-4       0      0       0       0      0      0       0       0      0      0
```

其输出包含以下列信息：

- total: 设备从系统启动以来累计的读或写操作总次数，表示多少次I/O请求被发出
- merged: 在内核I/O调度过程中被合并的连续读或写请求次数，合并后可减少I/O操作次数，提高效率
- sectors: 读或写的扇区总数，1个扇区通常为512字节，表示磁盘数据传输量大小
- ms: 设备处理这些读或写操作所花费的总时间，单位是毫秒，反映磁盘I/O的响应时间
- cur: 当前时刻正在进行的I/O操作数量，表示设备的实时负载
- sec: 自系统启动以来磁盘参与I/O操作的总秒数，用于评估磁盘的活跃时间占比

此外，还可以使用 -D 选项来获取磁盘 I/O 的摘要统计信息：

```text
# vmstat -D 1 1
            6 disks
            3 partitions
      1492064 total reads
        12447 merged reads
     20407898 read sectors
      5711511 milli reading
    374572389 writes
      3460667 merged writes
  48208708608 written sectors
   7759736862 milli writing
            0 inprogress IO
        47247 milli spent IO
```

## [iotop](https://zhida.zhihu.com/search?content_id=734041830&content_type=Answer&match_order=1&q=iotop&zhida_source=entity)

iotop 是一个专门用于监控磁盘 I/O 活动的工具，属于 iotop 软件包的一部分。我们可以根据系统环境使用 yum 或其他工具安装它：

```text
# rpm -q iotop
iotop-0.6-4.el7.noarch
```

iotop 依赖 Linux 内核（版本需为 2.6.20 或更高）提供的 I/O 使用信息，并以表格形式显示系统中各个进程或线程当前的磁盘 I/O 使用情况。

我们可以使用 iotop 选项只显示那些实际执行 I/O 操作的进程或线程，而不是列出所有进程。这样可以更方便地定位和监控磁盘 I/O 性能瓶颈。

```text
# iotop --only
Total DISK READ :       0.00 B/s | Total DISK WRITE :    1103.25 M/s
Actual DISK READ:       0.00 B/s | Actual DISK WRITE:     699.93 K/s
  TID  PRIO  USER     DISK READ  DISK WRITE  SWAPIN     IO>    COMMAND
15091 be/4 root        0.00 B/s  965.33 M/s  0.00 % 99.99 % cp loadfile loadfile1
29926 be/4 root        0.00 B/s    0.00 B/s  0.00 % 15.49 % [kworker/u64:0]
 3312 be/3 root        0.00 B/s  137.92 M/s  0.00 %  0.09 % [jbd2/dm-3-]
```

其输出包含以下信息：

- TID: 线程 ID，表示正在进行磁盘 I/O 操作的线程编号
- PRIO: 线程优先级和调度策略，例如 be/4 表示后台调度策略且优先级为 4
- USER: 线程所属用户，显示执行该线程的用户名称
- DISK READ: 线程当前的磁盘读取速率，单位如字节/秒（B/s，KB/s，MB/s）
- DISK WRITE: 线程当前的磁盘写入速率，单位同上
- SWAPIN: 线程由于等待交换空间（swap）数据而被阻塞的时间百分比
- IO>: 线程当前磁盘 I/O 的活动百分比，表示该线程占用的 I/O 资源比例
- COMMAND: 线程所属的命令或程序名称及其参数

## [nmon](https://zhida.zhihu.com/search?content_id=734041830&content_type=Answer&match_order=1&q=nmon&zhida_source=entity)

nmon 是另一款用于监控系统状态的工具。在 RHEL/CentOS 的默认仓库中不可用，但可以通过 EPEL 仓库进行安装。

在 RHEL/CentOS 7 上安装 EPEL 仓库：

```text
# rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
```

在 RHEL/CentOS 8 上安装 EPEL 仓库：

```text
# rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
```

安装完成后，可使用 yum 安装 nmon：

```text
# yum install nmon
```

也可以选择手动安装：

```text
# rpm -Uvh https://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/n/nmon-16g-3.el7.x86_64.rpm
```

nmon 能够显示包括 CPU、内存、网络、磁盘（图形或数字形式）、文件系统、NFS、顶级进程、系统资源（如 Linux 版本和处理器）以及 Power 微分区等信息。

从终端执行以下命令启动 nmon：

```text
# nmon
```

在运行界面中，按下 D 键即可仅查看磁盘使用情况统计信息。

```text
┌nmon─16g─────────────────────Hostname=rhel-fews-cc─Refresh= 2secs ───18:29.30──────────┐
│ Disk I/O ──/proc/diskstats────mostly in KB/s─────Warning:contains duplicates──────────│
│DiskName Busy    Read    Write       Xfers   Size  Peak%  Peak=R+W    InFlight         │
│sda       61%     62.0 240088.7KB/s 3712.48 64.7KB  580% 3316396.1KB/s148              │
│sda1       0%      0.0      0.0KB/s    0.0   0.0KB    0%       0.0KB/s  0              │
│sda2       0%      0.0      0.0KB/s    0.0   0.0KB    0%       0.0KB/s  0              │
│sda3      61%     62.0 240088.7KB/s 3712.48 64.7KB  580% 3316396.1KB/s148              │
│dm-0       0%     62.0      0.0KB/s   15.5   4.0KB   58%    1559.6KB/s  0              │
│dm-1      61%      0.0 242871.9KB/s 3794.90 64.0KB  580% 3314548.6KB/s218              │
│dm-2      61%      0.0 242871.9KB/s 3794.90 64.0KB  580% 3314548.6KB/s218              │
│dm-3      61%      0.0  14779.6KB/s  230.92 64.0KB  580% 3145026.3KB/s2181             │
│Totals Read-MB/s=0.2      Writes-MB/s=957.7    Transfers/sec=15261.0                   │
└───────────────────────────────────────────────────────────────────────────────────────┘
```

其输出包含以下信息：

- DiskName: 磁盘或分区名称，如 sda、sda1、dm-0 等
- Busy: 磁盘或分区的忙碌百分比，表示设备在进行 I/O 操作的时间比例
- Read: 读操作速率，单位为 KB/s（千字节每秒）
- Write: 写操作速率，单位为 KB/s
- Xfers: 每秒传输次数（I/O 请求数），即 I/O 操作的频率
- Size: 平均每次 I/O 传输的数据大小，单位为 KB
- Peak%: 当前采样周期内的峰值利用率百分比，表示负载峰值，可能超过 100%（显示累积或叠加效应）
- Peak=R+W: 读写操作峰值数据总和，单位为 KB/s
- InFlight: 当前尚未完成的 I/O 请求数，表示正在进行中的 I/O 数量
- Totals Read-MB/s: 所有监控磁盘的总读速率，单位为 MB/s（兆字节每秒）
- Totals Writes-MB/s: 所有监控磁盘的总写速率，单位为 MB/s
- Transfers/sec: 所有磁盘的总 I/O 请求次数每秒，整体传输频率

如果需要用图表显示磁盘使用情况统计信息，按 d 键。

```text
┌nmon─16g──────[H for help]───Hostname=rhel-fews-cc─Refresh= 2secs ───18:25.12──────────┐
│ Disk I/O ──/proc/diskstats────mostly in KB/s─────Warning:contains duplicates──────────│
│DiskName Busy  Read WriteMB|0          |25         |50          |75       100|         │
│sda       60%    0.4  563.8|RWWWWWWWWWWWWWWWWWWWWWWWWWWWW>                   |         │
│sda1       0%    0.0    0.0|>                                                |         │
│sda2       0%    0.0    0.0|>                                                |         │
│sda3      59%    0.4  563.8|RWWWWWWWWWWWWWWWWWWWWWWWWWWWW>                   |         │
│dm-0      22%    0.4    0.0|RRRRRRRRRRR>                                     |         │
│dm-1      41%    0.0  568.0|WWWWWWWWWWWWWWWWWWWW>                            |         │
│dm-2      41%    0.0  568.0|WWWWWWWWWWWWWWWWWWWW>                            |         │
│dm-3      60%    0.0  511.9|WWWWWWWWWWWWWWWWWWWWWWWWWWWWW>                   |         │
│Totals Read-MB/s=1.1      Writes-MB/s=2775.4   Transfers/sec=44468.8                   │
└───────────────────────────────────────────────────────────────────────────────────────┘
```

## [atop](https://zhida.zhihu.com/search?content_id=734041830&content_type=Answer&match_order=1&q=atop&zhida_source=entity)

atop 是一款高级系统和进程监视工具，可用于检查和监控 Linux 系统中的磁盘 I/O 性能。我们可以使用 yum 安装 atop（前提是已配置好 EPEL 仓库），也可以手动安装：

```text
# rpm -Uvh https://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/a/atop-2.4.0-4.el7.x86_64.rpm
```

atop 是一个交互式监控程序，能够查看系统整体负载情况，并支持进程级的磁盘 I/O 活动监控。同时，它还会显示 CPU、内存、磁盘、网络等关键硬件资源的使用状态，为系统性能分析提供了全面的信息。

运行以下命令进入监控界面：

```text
# atop
```

在运行界面中，按下 Shift + D 可切换到磁盘活动视图，随后按 c 键可显示完整的进程命令名称，从而更方便地识别具体执行 I/O 操作的进程。

```text
PRC |  sys    6.08s |  user   0.05s  | #proc    398  |  #tslpu     1 |  #zombie    0  | #exit      4  |
CPU |  sys      54% |  user      1%  | irq       6%  |  idle   3026% |  wait    114%  | ipc     0.80  |
CPL |  avg1    0.99 |  avg5   43.05  | avg15 866.47  |  csw   122763 |  intr   90675  | numcpu    32  |
MEM |  tot   125.8G |  free  105.4G  | cache  17.8G  |  buff  230.0M |  slab  938.9M  | hptot   0.0M  |
SWP |  tot     3.7G |  free    3.7G  |               |               |  vmcom   2.7G  | vmlim  66.6G  |
LVM |     rhel-root |  busy     69%  | read       0  |  write  65586 |  MBw/s  409.6  | avio 0.10 ms  |
LVM |  pool00_tdata |  busy     66%  | read       0  |  write  63780 |  MBw/s  398.3  | avio 0.10 ms  |
LVM |  pool00-tpool |  busy     66%  | read       0  |  write  63780 |  MBw/s  398.3  | avio 0.10 ms  |
LVM |  pool00_tmeta |  busy      9%  | read     494  |  write      0 |  MBw/s    0.0  | avio 1.87 ms  |
DSK |           sda |  busy     69%  | read     494  |  write  61302 |  MBw/s  398.5  | avio 0.11 ms  |
NET |  transport    |  tcpi       3  | tcpo       2  |  udpi       0 |  udpo       0  | tcpao      0  |

  PID   TID S  DSK COMMAND-LINE (horizontal scroll with <- and -> keys)                             1/4
12652     - S  76% -bash
 3312     - S  24% jbd2/dm-3-8
27272     - S   0% kworker/u64:3
16016     - D   0% kworker/u64:1
29926     - S   0% kworker/u64:0
16287     - E   0% cp
16290     - E   0% cp
```

## [collectl](https://zhida.zhihu.com/search?content_id=734041830&content_type=Answer&match_order=1&q=collectl&zhida_source=entity)

collectl 是一款用于收集和报告当前系统状态数据的工具。在 CentOS/RHEL 的默认仓库中不可用，因此需要先安装 EPEL 仓库，然后通过 yum 安装 collectl，也可以选择手动安装：

```text
# rpm -Uvh https://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/c/collectl-4.3.0-5.el7.noarch.rpm
```

collectl 可用于检查和监控 Linux 系统中的磁盘 I/O 性能。它能够采集系统在各方面的详细运行状态数据。

以下命令可用于报告 CPU 和磁盘 I/O 的统计信息，其中 c 表示 CPU，d 表示磁盘：

```text
# collectl -scd
waiting for 1 second sample...
#<----CPU[HYPER]-----><----------Disks----------->
#cpu sys inter  ctxsw KBRead  Reads KBWrit Writes
   0   0  7406   3895     92     23 342208   5347
   3   3  2616   2540     20      5  98436    657
   0   0  8802   3496    272     68 516096   8064
   0   0  1174    620     36      9  65536   1024
   2   2  7302   3290    184     46 368640   5760
   2   2 17221   6692    500    125 962688  14885
```

其输出包含以下信息：

- cpu: CPU 编号，表示对应的处理器核心
- sys: CPU 在系统态（内核态）下的时间百分比
- inter: CPU 每秒中断次数
- ctxsw: 每秒上下文切换次数，表示 CPU 线程切换的频率
- KBRead: 每秒从磁盘读取的数据量，单位是千字节（KB）
- Reads: 每秒完成的读 I/O 请求次数
- KBWrit: 每秒写入磁盘的数据量，单位是千字节（KB）
- Writes: 每秒完成的写 I/O 请求次数

命令执行后将以每秒为周期输出 CPU 与磁盘的相关指标，如中断数、上下文切换次数、读写速率和读写次数等，有助于我们全面掌握系统的运行状态和磁盘 I/O 活动情况。

## [sar](https://zhida.zhihu.com/search?content_id=734041830&content_type=Answer&match_order=1&q=sar&zhida_source=entity)

sar 是另一款著名且广泛使用的系统监控工具，属于 sysstat 软件包的一部分。我们可以根据系统环境通过 yum 或其他工具安装 sysstat：

```text
# rpm -q sysstat
sysstat-10.1.5-17.el7.x86_64
```

sar 功能强大，可用于监控各类系统资源。针对磁盘 I/O 性能监控，可以使用 -d 选项配合采样间隔参数。例如，以下命令以 1 秒为间隔、采集 1 次磁盘 I/O 数据：

```text
# sar -d 1 1
Linux 3.10.0-1062.9.1.el7.x86_64 (rhel-fews-cc)         01/07/2020      _x86_64_        (32 CPU)

06:43:44 PM       DEV       tps  rd_sec/s  wr_sec/s  avgrq-sz  avgqu-sz     await     svctm     %util
06:43:45 PM    dev8-0   6274.00    400.00 796672.00    127.04    142.20     22.64      0.16    100.00
06:43:45 PM  dev253-0     50.00    400.00      0.00      8.00      0.00      0.08      0.08      0.40
06:43:45 PM  dev253-1   6225.00      0.00 796800.00    128.00    143.10     22.96      0.16    100.00
06:43:45 PM  dev253-2   6225.00      0.00 796800.00    128.00    143.11     22.96      0.16    100.00
06:43:45 PM  dev253-3      0.00      0.00      0.00      0.00   4285.03      0.00      0.00    100.00
```

其输出包含以下信息：

- DEV: 设备名称
- tps: 每秒传输的 I/O 请求次数（Transactions Per Second）
- rd_sec/s: 每秒读取的扇区数（1扇区通常为512字节）
- wr_sec/s: 每秒写入的扇区数
- avgrq-sz: 平均每次 I/O 请求的数据大小（以扇区数为单位）
- avgqu-sz: 平均等待队列长度，表示等待处理的 I/O 请求数
- await: 平均每次 I/O 请求的等待时间（毫秒），包括排队和服务时间
- svctm: 平均每次 I/O 请求的服务时间（毫秒），仅指设备处理时间
- %util: 设备的使用率，表示设备繁忙时间占总时间的百分比，100% 表示设备全负荷运行

该命令输出各设备的 I/O 请求次数（tps）、读写扇区数、平均请求大小、I/O 等待时间、服务时间以及设备利用率等关键指标，有助于快速掌握磁盘使用情况。

## blktrace

blktrace 是一款专门用于跟踪块设备 I/O 事件的实用工具，属于 blktrace 软件包的一部分，通常在系统的默认仓库中可用。我们可以根据系统环境使用 yum 或其他工具进行安装：

```text
# rpm -qa | grep blktrace
blktrace-1.0.5-8.el7.x86_64
```

blktrace 能够详细记录磁盘 I/O 操作的各个事件，并支持按进程监控磁盘 I/O 活动。每次 I/O 操作通常会输出多行事件信息，主要包括以下列：

- 设备主、次设备号
- CPU 编号
- 序列号
- 事件发生时间（单位：秒）
- 进程 ID
- 动作标识符（例如：Q 表示排队、G 表示获取请求、P 表示插入、M 表示合并、D 表示发出、C 表示完成等，详见 blkparse(1)）
- RWBS 描述（例如：W 表示写、S 表示同步等）
- 地址和大小信息（包含设备）

```text
# btrace /dev/sda
  8,3    3    50080    29.219400645 24545  A   W 86921600 + 128 <- (253,1) 85174656
  8,0    3    50081    29.219400796 24545  A   W 95783296 + 128 <- (8,3) 86921600
  8,0    3    50082    29.219400987 24545  Q   W 95783296 + 128 [kworker/u64:3]
  8,0    3    50083    29.219401336 24545  G   W 95783296 + 128 [kworker/u64:3]
  8,0    3    50084    29.219401617 24545  I   W 95783296 + 128 [kworker/u64:3]
  8,0    3    50085    29.219401811 24545  D   W 95783296 + 128 [kworker/u64:3]

<Output trimmed>
CPU0 (8,0):
 Reads Queued:         312,    9,460KiB  Writes Queued:       1,430,   91,400KiB
 Read Dispatches:      198,    9,460KiB  Write Dispatches:    1,430,   91,460KiB
 Reads Requeued:         0               Writes Requeued:         0
 Reads Completed:      198,    9,460KiB  Writes Completed:    1,430,   91,460KiB
 Read Merges:          114,    5,176KiB  Write Merges:            0,        0KiB
 Read depth:            34               Write depth:           255
 IO unplugs:           167               Timer unplugs:           0

<Output trimmed>

Throughput (R/W): 3,714KiB/s / 67,320KiB/s
Events (8,0): 227,220 entries
Skips: 0 forward (0 -   0.0%)
```

在执行结束后，blktrace 还会输出一个磁盘统计信息摘要，展示各类读写操作的吞吐量及事件统计。

## perf-tools
![](assets/Pasted%20image%2020250628231847.png)

### iolatency

iolatency 是 perf-tools 工具集中的一个脚本，用于将块设备的 I/O 延迟以直方图的形式汇总展示。可通过以下命令从官方仓库下载该脚本：

```text
# wget https://raw.githubusercontent.com/brendangregg/perf-tools/master/iolatency
```

下载完成后，需要为脚本添加可执行权限：

```text
# chmod u+x iolatency
```

接下来，使用 -Q 选项运行脚本以启用排队延迟的跟踪。该选项会基于 block_rq_insert 事件进行跟踪，从而捕捉 I/O 请求进入队列后的排队延迟，而不是基于 block_rq_issue 的提交延迟，这样可以更准确地反映排队阶段的性能状况。

```text
# ./iolatency -Q
Tracing block I/O. Output every 1 seconds. Ctrl-C to end.

  >=(ms) .. <(ms) : I/O |Distribution | 0 -> 1       : 32       |#                                     |
       1 -> 2       : 0        |                                      |
       2 -> 4       : 0        |                                      |
       4 -> 8       : 0        |                                      |
       8 -> 16      : 0        |                                      |
      16 -> 32      : 5605     |######################################|
      32 -> 64      : 156      |##                                    |
^C
Ending tracing...
```

如上例所示，大多数磁盘 I/O 延迟集中在 16 到 32 毫秒之间。

### iosnoop

iosnoop 是 perf-tools 工具集中的另一个脚本，用于跟踪磁盘 I/O 的详细信息，包括每次操作的延迟。可通过以下命令从官方仓库下载脚本：

```text
# wget https://raw.githubusercontent.com/brendangregg/perf-tools/master/iosnoop
```

下载完成后，需要为脚本添加可执行权限：

```text
# chmod u+x iosnoop
```

该工具支持通过进程 ID 监控磁盘 I/O。使用 -p 选项指定 进程号，例如针对 cp 命令的 PID，iosnoop 将实时输出该进程的 I/O 延迟信息，便于按进程粒度分析磁盘性能。

```text
# ./iosnoop -p $(pidof cp)
Tracing block I/O issued by PID 14823. Ctrl-C to end.
COMM         PID    TYPE DEV      BLOCK        BYTES     LATms
cp           8893   W    8,0      1214026496   524288    24.65
cp           8893   W    8,0      1214027520   524288    24.74
cp           8893   W    8,0      1214028544   524288    24.82
cp           8893   W    8,0      1214029568   524288    24.90
cp           8893   W    8,0      1214030592   524288    24.99
^C
Ending tracing...
```

其输出包含以下信息：

- COMM: 进程名称
- PID: 进程ID
- TYPE: I/O 类型（W=写，R=读）
- DEV: 设备主次编号（major, minor）
- BLOCK: 块设备上的起始块号（block address）
- BYTES: 本次 I/O 操作的数据大小（字节数）
- LATms: 本次 I/O 操作的延迟时间（毫秒）

每条记录展示了进程名、PID、I/O 类型、设备号、块号、字节数以及操作延迟（单位为毫秒）。结束跟踪后，按 Ctrl-C 终止即可。

## BPF Tools

传统的性能分析工具通常只能提供关于存储 I/O 的基本指标，如 IOPS 速率、平均延迟、队列长度，以及按进程统计的 I/O 活动情况。

相比之下，基于 BPF 的跟踪工具在此基础上可进一步提供更深入的磁盘统计信息，用于更细粒度地分析 Linux 系统中的磁盘 I/O 性能。
![](assets/Pasted%20image%2020250628231904.png)

要使用 BPF 工具，需先安装以下 RPM 包：

- bcc
- bpftool
- bpftrace

其中，bcc 可直接通过系统仓库安装，但需确保所安装的 bcc RPM 与当前加载的内核版本兼容，以避免潜在的兼容性问题：

```text
# yum install bcc kernel
```

接下来，为了使用 bpftools 和 bpftrace 监控磁盘 I/O 性能，需要添加对应的仓库配置文件：

```text
# curl https://repos.baslab.org/bpftools.repo
```

完成后，即可通过以下命令安装：

```text
# yum install bpftool bpftrace
```

安装完成后，便可使用 BPF 工具对磁盘 I/O 进行深入的监控与分析。

### biolatency

biolatency 是一款基于 BCC 的 bpftrace 工具，可用于以直方图的形式展示磁盘 I/O 的延迟统计信息。这里的设备延迟是指从请求发出到设备，再到请求完成所经历的总时间，其中也包括操作系统中的排队时间。

使用 biolatency 可以检查磁盘状态并监控磁盘 I/O 性能。通过 -D 选项，biolatency 会分别展示每个设备的延迟直方图，有助于了解不同类型 I/O 的性能分布。

```text
# /usr/share/bcc/tools/biolatency -D
Tracing block device I/O... Hit Ctrl-C to end.
^C  <-- Press Ctrl+C after waiting for few seconds/minutes disk = 'sda' usecs : count distribution 0 -> 1          : 0        |                                        |
         2 -> 3          : 0        |                                        |
         4 -> 7          : 0        |                                        |
         8 -> 15         : 0        |                                        |
        16 -> 31         : 0        |                                        |
        32 -> 63         : 127      |                                        |
        64 -> 127        : 1101     |                                        |
       128 -> 255        : 3190     |**                                      |
       256 -> 511        : 3855     |**                                      |
       512 -> 1023       : 5222     |***                                     |
      1024 -> 2047       : 9027     |*****                                   |
      2048 -> 4095       : 23773    |***************                         |
      4096 -> 8191       : 1256     |                                        |
```

运行一段时间后按 Ctrl+C 结束，输出结果会显示 /dev/sda 磁盘的 I/O 延迟分布情况。

从结果中可以看出，这个例子的大部分 I/O 延迟集中在 128 到 4095 微秒之间。

### biosnoop

biosnoop 是一款基于 BCC 的 bpftrace 工具，用于打印每条磁盘 I/O 的摘要信息，每条记录以一行的形式展示，涵盖了从请求发出到完成的详细延迟信息，

通过 biosnoop，我们可以更细致地分析磁盘 I/O 性能。

```text
# /usr/share/bcc/tools/biosnoop -Q
TIME(s)     COMM           PID    DISK    T SECTOR     BYTES  QUE(ms) LAT(ms)
0.000000    kworker/u64:1  4434   sda     W 708680704  65536     0.00  101.43
0.000097    kworker/u64:1  4434   sda     W 708680832  65536     0.00  101.52
0.000190    kworker/u64:1  4434   sda     W 708680960  65536     0.00  101.61
0.000252    kworker/u64:1  4434   sda     W 708681088  65536     0.00  101.66
0.000265    kworker/u64:1  4434   sda     W 708681216  65536     0.00  101.67
0.000285    kworker/u64:1  4434   sda     W 708681344  65536     0.00  101.68
```

其输出包含以下列信息：

- TIME(s)：I/O 完成的时间（单位：秒）
- COMM：发起 I/O 的进程名称
- PID：进程 ID
- DISK：磁盘设备名称
- T：I/O 类型，R 表示读取，W 表示写入
- SECTOR：I/O 所访问的扇区号（以 512 字节为单位）
- BYTES：本次 I/O 的数据量
- LAT(ms)：从 I/O 请求发出到完成所经历的总时间（毫秒）
- QUE(ms)：排队等待时间（毫秒）

### biotop

biotop 是一款类似于 top 的 BCC 工具，用于实时查看 Linux 系统中各进程的磁盘 I/O 活动与状态，其基本用法如下：

```text
biotop [options] [interval [count]]
```

它提供了一些常用选项，例如：

- -C：不清除屏幕，保留之前的输出内容
- -r ROWS：指定要显示的行数

```text
# /usr/share/bcc/tools/biotop -C
Tracing... Output every 1 secs. Hit Ctrl-C to end

23:23:37 loadavg: 2.17 1.58 0.91 4/630 6711

PID    COMM             D MAJ MIN DISK       I/O  Kbytes  AVGms
5702   kworker/u64:2    W 8   0   sda       3285  210240   2.62
6120   kworker/u64:0    W 8   0   sda        486   31104  23.37
6709   cp               W 8   0   sda         18    9088  39.43
5702   kworker/u64:2    R 8   0   sda         36     144   1.48
```

输出中各列的含义：

- PID：进程 ID
- COMM：进程名称
- D：操作类型（R 读，W 写）
- MAJ/MIN：设备的主、次设备号
- DISK：磁盘设备名
- I/O：I/O 操作次数
- Kbytes：传输的数据总量（以 KB 为单位）
- AVGms：平均延迟时间（单位：毫秒）

从输出可见，kworker 线程排在顶部，说明当前主要的磁盘写入操作由内核后台线程执行，这属于内核的写入刷新机制。在这种情况下，尚无法直接判断是哪一个用户进程最初触发了页面写入（即标记为“脏”页）。

### bitesize

bitesize 是一个基于 BCC 和 bpftrace 的工具，用于统计和展示磁盘 I/O 操作中数据传输的大小分布情况。

```text
# /usr/share/bcc/tools/bitesize
Tracing block I/O... Hit Ctrl-C to end.
^C
Process Name = kworker/u65:0
     Kbytes              : count     distribution
         0 -> 1          : 8        |****************************************|

Process Name = jbd2/dm-3-8
     Kbytes              : count     distribution
         0 -> 1          : 6        |****************************************|
```

每个进程的 I/O 操作按数据大小（单位为 KB）进行了归类和计数，从输出中可以看出，kworker/u65:0 和 jbd2/dm-3-8 这两个进程的大多数磁盘操作数据量都在 1KB 以下，且分别发生了 8 次和 6 次。这种统计方式有助于了解系统中不同进程的磁盘 I/O 负载特征。

### ext4slower

ext4slower 是一款基于 BCC 的工具，用于跟踪在 ext4 文件系统中耗时超过 10 毫秒的操作，帮助识别潜在的性能瓶颈。

```text
# /usr/share/bcc/tools/ext4slower
Tracing ext4 operations slower than 10 ms
TIME     COMM           PID    T BYTES   OFF_KB   LAT(ms) FILENAME
16:55:38 dd             23317  W 512     319      18446744073708.55 dummy_file
```

其输出包含以下信息：

- TIME: 操作发生的时间
- COMM: 发起操作的进程名称
- PID: 进程ID
- T: 操作类型（R=读取，W=写入）
- BYTES: 操作的数据大小（字节数）
- OFF_KB: 文件中的偏移量（单位：KB）
- LAT(ms): 操作延迟时间（毫秒）
- FILENAME: 操作的文件名

在这个例子中，dd 进程执行了一次写入操作，延迟超过了 10 毫秒，说明该 I/O 操作存在较高延迟，值得进一步关注和分析。