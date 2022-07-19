[org 0x1000]

dw 0x55aa;magic number 用于判断错误


mov si, loading
call print


detect_memory:
    xchg bx, bx
    xor ebx, ebx

    ;es:di 结构体缓存位置
    mov ax, 0
    mov es, ax
    mov edi, ards_buffer

    mov edx, 0x534d4150;固定签名
.next:
    ;子功能号
    mov eax, 0xe820
    ; ards 结构体的大小
    mov ecx, 20
    ;调用 0x15 系统调用
    int 0x15
    ;如果 cf 置位表示出错
    jc error

    ;将缓存指针指向下一个结构体
    add di, cx
    ;结构体数量加1
    inc word [ards_count]

    cmp ebx, 0
    jnz .next

    mov si, detecting
    call print

    xchg bx, bx
    jmp prepare_protected_mode

print:
    mov ah, 0x0e;INT 10h / AH = 0Eh - teletype output.
.next:
    mov al, [si]
    cmp al, 0
    jz .done
    int 0x10
    inc si
    jmp .next
.done:
    ret
loading:
    db "Loading Onix...", 10, 13, 0;
detecting:
    db "Detecting memory success...", 10, 13, 0;

error:
    mov si, .msg
    call print
    hlt
    jmp $
    .msg db "Loading Error", 10, 13, 0;\n\r

prepare_protected_mode:
    cli;关闭中断
    ;打开 A20 地址线
    in al, 0x92
    or al, 0b10
    out 0x92, al
    ;加载 gdt
    lgdt [gdt_ptr]

    ;启动保护模式
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    ;用跳转来刷新缓存，启用保护模式
    jmp dword code_selector:protect_mode

[bits 32]
protect_mode:
    xchg bx, bx
    mov ax, data_selector
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    mov esp, 0x10000;修改栈顶

    mov edi, 0x10000; 读取到的目标内存
    mov ecx, 10;起始扇区
    mov bl, 200;扇区数量

    call read_disk

    jmp dword code_selector:0x10000
    
    ud2; 表示出错

read_disk:
    ;设置读写扇区的数量
    mov dx, 0x1f2
    mov al, bl
    out dx, al

    inc dx;0x1f3
    mov al, cl;低8位
    out dx, al

    inc dx;0x1f4
    shr ecx, 8
    mov al, cl;中8位
    out dx, al

    inc dx;0x1f5
    shr ecx, 8
    mov al, cl;高8位
    out dx, al

    inc dx;0x1f6
    shr ecx, 8
    and cl, 0b1111; 高4位置为 0

    mov al, 0b1110_0000
    or al, cl
    out dx, al;主盘 LBA 模式

    inc dx;0x1f7
    mov al, 0x20 ;读硬盘
    out dx, al

    xor ecx, ecx
    mov cl, bl;得到读取扇区的数量

    .read:
        push cx
        call .waits;等待数据准备完毕
        call .reads;读取一个扇区
        pop cx
        loop .read
    ret

    .waits:
        mov dx, 0x1f7
        .check:
            in al, dx
            jmp $+2; nop
            jmp $+2; nop
            jmp $+2; nop
            and al, 0b1000_1000;获取第3位和第7位的值
            cmp al, 0b0000_1000
            jnz .check
        ret
    .reads:
        mov dx, 0x1f0
        mov cx, 256;一个扇区256个字
        .readw:
            in ax, dx
            jmp $+2;nop
            jmp $+2;nop
            jmp $+2;nop
            mov [edi], ax
            add edi, 2
            loop .readw
        ret


code_selector equ (1<<3) ;index 1 位置
data_selector equ (2<<3) ;index 2 位置

memory_base equ 0;内存开始的位置：基地址
;内存界限：4G/4k - 1
memory_limit equ (4 * 1024 * 1024 * 1024)/(4 * 1024) - 1

gdt_ptr:
    dw (gdt_end - gdt_base) - 1
    dd gdt_base
gdt_base:
    dd 0, 0; NULL 描述符 8个字节
gdt_code:
    dw memory_limit & 0xffff;段长度 0-15
    dw memory_base & 0xffff;基地址 16-31
    db (memory_base >> 16) & 0xff;基地址 32-39
    db 0b_1_00_1_1_0_1_0
    db 0b1_1_0_0_0000
    db (memory_base >> 24) &0xff; 基地址 57-63
gdb_data:
    dw memory_limit & 0xffff;段长度 0-15
    dw memory_base & 0xffff;基地址 16-31
    db (memory_base >> 16) & 0xff;基地址 32-39
    db 0b_1_00_1_0_0_1_0; 40-47
    db 0b1_1_0_0_0000;48-56
    db (memory_base >> 24) &0xff; 基地址 57-63
gdt_end:


ards_count:
    dw 0
ards_buffer:
    
