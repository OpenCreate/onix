# ELF 文件格式
Executable and Linkable Format

1. 可执行程序 / python / bash / gcc
2. 可重定位文件 / gcc -c `.o` / 静态库 ar `.a`
3. 共享的目标文件 / 动态链接库 `.so`

## 可执行程序

1. 代码 .text 段 section ELF / segment CPU
2. 数据：
    1. .data section / 已经初始化过的数据
    2. .bss 未初始化过的数据 Block Started by Symbol

## 程序分析

```c
#include <stdio.h>
char msg[] = "Hello World!!!"; // .data
char buf[16]; // .bss

int main()
{
    printf("hello world!!!\n");
    return 0;
}
```

编译成为 32 位的程序

    gcc -m32 -static hello.c -o hello

---

    readelf -e hello

## 参考文献

><https://refspecs.linuxfoundation.org/elf/elf.pdf>