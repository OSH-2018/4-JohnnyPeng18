# Lab 04

### Meltdown漏洞实践

###实验环境

**操作系统：Ubuntu 16.04 LTS**

###实验准备

**1、用meltdown漏洞检查工具检测meltdown漏洞是否已经被修复，如被修复应该关闭Meltdown漏洞补丁pti**

**关闭后，再次检测meltdown漏洞如下图所示：**

![image](https://github.com/OSH-2018/4-JohnnyPeng18/blob/master/3.png)

**2、为了更加方便的读取物理内存空间，应该将kaslr也关闭**

**关闭pti和kaslr的方法是在/boot/grub/grub.cfg中找到linux /boot/vmlinuz-4.13.0-45-generic.efi.signed root=UUID=.....   后面加上nopti 和 nokaslr**

**如图所示：**

![image](https://github.com/OSH-2018/4-JohnnyPeng18/blob/master/4.png)

### 实验前测试

**首先用meltdown官方论文提供的demo^[1]^检测是否可以进行meltdown漏洞攻击:**

**检测结果如图所示：**

![image](https://github.com/OSH-2018/4-JohnnyPeng18/blob/master/2.png)

**由图可以看出攻击的成功率约为60%。**

**这一成功率在不同的电脑上可能不同，因为meltdown的攻击依赖于硬件。**

###Meltdown攻击原理^[2]^

**有时候CPU执行单元在执行的时候会需要等待操作结果，例如加载内存数据到寄存器这样的操作。为了提高性能，CPU并不是进入stall状态，而是采用了乱序执行的方法，继续处理后续指令并调度该指令去空闲的执行单元去执行。然而，这种操作常常有不必要的副作用，而通过这些执行指令时候的副作用，例如时序方面的差异，我们可以窃取到相关的信息。虽然性能提升了，但是从安全的角度来看却存在问题，关键点在于：在乱序执行下，被攻击的CPU可以运行未授权的进程从一个需要特权访问的地址上读出数据并加载到一个临时的寄存器中。CPU甚至可以基于该临时寄存器的值执行进一步的计算，例如，基于该寄存器的值来访问数组。当然，CPU最终还是会发现这个异常的地址访问，并丢弃了计算的结果（例如将已经修改的寄存器值）。虽然那些异常之后的指令被提前执行了，但是最终CPU还是力挽狂澜，清除了执行结果，因此看起来似乎什么也没有发生过。这也保证了从CPU体系结构角度来看，不存在任何的安全问题。然而，我们可以观察乱序执行对cache的影响，从而根据这些cache提供的侧信道信息来发起攻击。具体的攻击是这样的：攻击者利用CPU的乱序执行的特性来读取需要特权访问的内存地址并加载到临时寄存器，程序会利用保存在该寄存器的数据来影响cache的状态。然后攻击者搭建隐蔽通道（例如，Flush+Reload）把数据传递出来，在隐蔽信道的接收端，重建寄存器值。因此，在CPU微架构（和实际的CPU硬件实现相关）层面上看的确是存在安全问题。**

### 实验内容

**1、编写一个内核模块，其中包含一个proc接口，将一个private_key(0x2333233323332333)放入其中，作为获取目标。^[3]^**

**2、编写一个meltdown攻击程序，获取该private_key。**

### 实验操作

**源文件包含Makefile、attack.sh、meltdown.c、proc.c**

**一般情况下执行attack.sh文件即可**

###实验结果

![image](https://github.com/OSH-2018/4-JohnnyPeng18/blob/master/1.png)

**从图中可以看出，攻击程序成功从内核空间0xffffffffc0790000中获取了private_key：0x2333233323332333。**

### 参考资料

**【1】https://github.com/IAIK/meltdown**

**【2】Meltdown **

**Moritz Lipp1, Michael Schwarz1, Daniel Gruss1, Thomas Prescher2, Werner Haas2, Stefan Mangard1, Paul Kocher3, Daniel Genkin4, Yuval Yarom5, Mike Hamburg6 1 Graz University of Technology  2 Cyberus Technology GmbH  3 Independent  4 University of Pennsylvania and University of Maryland  5 University of Adelaide and Data61  6 Rambus, Cryptography Research Division **

**代码参考在源文件中注释**