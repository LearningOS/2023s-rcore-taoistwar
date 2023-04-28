    .section .text.entry
    .globl _start
_start:
    la sp, boot_stack_top
    call rust_main

    .section .bss.stack
    .globl boot_stack_lower_bound
boot_stack_lower_bound: #我们尝试将其放置到全局数据 .data 段中但最后未能成功，因此才决定将其放置到 .bss 段中。
    .space 4096 * 16
    .globl boot_stack_top
boot_stack_top: