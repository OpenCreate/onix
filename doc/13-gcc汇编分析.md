# gcc 汇编分析
## CFI
Call Frame Infomation 调用栈信息
一种 DWARF 信息，用于调试，获得调用异常

`-fno-asynchronous-unwind-tables`
## PIC
Position Independent Code

获取调用时 `epi` 的值
得到 `_GLOBAL_OFFSET_TABLE_` 里面存储了 符号的地址信息

`-fno-pic`

## indent
gcc 版本信息

## 栈对齐
字节对齐到 16 字节，访问内存更加高效，使用更少的时钟周期；
`-mpreferred-stack-boundary=2`

## 栈帧
```s
pushl	%ebp
movl	%esp, %ebp

leave
movl	%ebp, %esp
popl $ebp

-fomit-frame-pointer
```

