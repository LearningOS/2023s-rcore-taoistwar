# 实验报告

## 简答作业

1. 正确进入 U 态后，程序的特征还应有：使用 S 态特权指令，访问 S 态寄存器后会报错。 请同学们可以自行测试这些内容 (运行 Rust 三个 bad 测例 (ch2b_bad_*.rs) ， 注意在编译时至少需要指定 LOG=ERROR 才能观察到内核的报错信息) ， 描述程序出错行为，同时注意注明你使用的 sbi 及其版本。

    > [kernel] PageFault in application, bad addr = 0x0, bad instruction    = 0x80400414, kernel killed it.
    > [kernel] IllegalInstruction in application, kernel killed it.
    > [kernel] IllegalInstruction in application, kernel killed it.
    > [kernel] Panicked at src/trap/mod.rs:73 Unsupported trap Exception(LoadFault), stval = 0x28!

2. 深入理解 trap.S 中两个函数 __alltraps 和__restore 的作用，并回答如下问题:
    1. L40：刚进入 __restore 时，a0 代表了什么值。请指出__restore 的两种使用情景
        > __restore是从__switch中进去的，a0没有重置，所以当前应用的TaskContext
        > 启动第一个应用时，使用__restore
    2. L43-L48：这几行汇编代码特殊处理了哪些寄存器？这些寄存器的的值对于进入用户态有何意义？请分别解释。
        >ld t0, 32*8(sp)  # 32是TrapContext中变量数，代表应用sstatus加载到t0寄存器
        >ld t1, 33*8(sp)  # 33是TrapContext中变量数，代表应用sepc加载到t1寄存器
        >ld t2, 2*8(sp)   # 2是TrapContext中变量数，代表应用x2=ra加载到t2寄存器
        >csrw sstatus, t0   # 将寄存器t0的值，写入到 sstatus 寄存器中。 sret时，
        >csrw sepc, t1      # 将寄存器t1的值，写入到 sepc 寄存器中。  sret时，重置pc值，也就是下一条要执行的指令的地址。
        >csrw sscratch, t2  # 将寄存器t2的值，写入到 sscratch 寄存器中。  给__alltraps使用
    3. L50-L56：为何跳过了 x2 和 x4？
        > ld x1, 1*8(sp)
        > ld x3, 3*8(sp)
        > .set n, 5
        > .rept 27
        >    LOAD_GP %n
        >    .set n, n+1
        > .endr
        因为x2=sp,x4=tp，一直在使用sp
    4. L60：该指令之后，sp 和 sscratch 中的值分别有什么意义？
        > csrrw sp, sscratch, sp
        互换，之后sscratch代表内核栈sp，sp代表用户栈sp
    5. __restore：中发生状态切换在哪一条指令？为何该指令执行之后会进入用户态？
        sret，因为sstatus.SPP=USER
    6. L13：该指令之后，sp 和 sscratch 中的值分别有什么意义？
       将sp切换为应用对应的内核栈，将寄存器的值保存到其中。
    7. 从 U 态进入 S 态是哪一条指令发生的？
      ecall、时钟自动触发

## 说明

荣誉准则

1. 在完成本次实验的过程（含此前学习的过程）中，我曾分别与 以下各位 就（与本次实验相关的）以下方面做过交流，还在代码中对应的位置以注释形式记录了具体的交流对象及内容：
    >《你交流的对象说明》
2. 此外，我也参考了 以下资料 ，还在代码中对应的位置以注释形式记录了具体的参考来源及内容：
    > 《你参考的资料说明》
3. 我独立完成了本次实验除以上方面之外的所有工作，包括代码与文档。 我清楚地知道，从以上方面获得的信息在一定程度上降低了实验难度，可能会影响起评分。
4. 我从未使用过他人的代码，不管是原封不动地复制，还是经过了某些等价转换。 我未曾也不会向他人（含此后各届同学）复制或公开我的实验代码，我有义务妥善保管好它们。 我提交至本实验的评测系统的代码，均无意于破坏或妨碍任何计算机系统的正常运转。 我清楚地知道，以上情况均为本课程纪律所禁止，若违反，对应的实验成绩将按“-100”分计。
