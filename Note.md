# 笔记

## 多道程序os

### 多道程序os vs 批处理os

- 批处理os
  - 内存中同时最多只能驻留一个应用。
  - 一个程序运行完成后，加载并运行下一个程序。
- 多道程序os
  - 内存中同时驻留多个程序。
  - 一个程序让出CPU时，运行其它程序。
  - 只有一个地址空间，因此每个程序使用不同的起始地址。

### 多道程序加载

执行流程：

- SBI
- 内核：入口
  - 初始化
    - KERNEL_STACK：TrapContext （其实，在应用对应的内核栈顶，激活应用时取出消耗掉，挂起应用时放入保存）
      - 32个通用寄存器=0
      - sstatus 读取当前sstatus，然后把SPP位置为User（用于后续恢复时切换到用户态）
      - sepc 应用恢复后，执行的指令地址
    - TASK_MANAGE：TaskContext
      - ra=__restore
      - sp=应用对应的KERNEL_STACK的地址
      - s0~s11=0
  - 切换到应用A
    - 切换到应用A方法状态（TaskContext） __switch
      - 保存方法状态（s0~s11、sp、ra），第一次没啥用，除了作用域就释放了。仅仅是为了少写代码……
      - 恢复应用A的方法状态，并返回到应用A对应的ra（__restore）。
    - 恢复应用A状态（TrapContext） __restore
      - 恢复32个通用寄存器
      - 恢复sstatus
      - 恢复sepc
      - sp写入sscratch
      - sret S模式中从例外返回，返回到 sstatus.SPP也就是用户态，pc置为sepc（也就是下一条指令从pc/sepc处执行）
- 应用A执行
  - 系统调用或异常，进入trap
- 内核Trap：
  - 入口：__alltraps
    - 保存应用A的环境（TrapContext）
      - 32个通用寄存器
      - sstatus
      - sepc
    - 调用 trap_handler
  - trap_handler
    - 具体业务：操作系统
    - 切换应用B
      - 切换到应用B方法状态（TaskContext） __switch
        - 保存应用A的方法状态（s0~s11、sp、ra）
        - 恢复应用B的方法状态，并返回到应用B对应的ra（__restore）。
      - 恢复应用B状态（TrapContext） __restore
        - 恢复32个通用寄存器
        - 恢复sstatus
        - 恢复sepc
        - sp写入sscratch
        - sret S模式中从例外返回，返回到 sstatus.SPP也就是用户态，pc置为sepc（也就是下一条指令从pc/sepc处执行）
- 应用B执行
  - 系统调用或异常，进入trap
- 内核Trap：
  - 入口：__alltraps
    - 保存应用B的环境（TrapContext）
      - 32个通用寄存器
      - sstatus
      - sepc
    - 调用 trap_handler
  - trap_handler
    - 具体业务：操作系统
    - 切换应用B
      - 切换到应用B方法状态（TaskContext） __switch
        - 保存应用A的方法状态（s0~s11、sp、ra）
        - 恢复应用B的方法状态，并返回到应用B对应的ra（__restore）。
      - 恢复应用B状态（TrapContext） __restore
        - 恢复32个通用寄存器
        - 恢复sstatus
        - 恢复sepc
        - sp写入sscratch
        - sret S模式中从例外返回，返回到 sstatus.SPP也就是用户态，pc置为sepc（也就是下一条指令从pc/sepc处执行）
