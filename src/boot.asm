[org 0x7c00]

; 设置屏幕模式为文本模式，清除屏幕
mov ax, 3
int 0x10

; 初始化段寄存器
mov ax, 0
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0x7c00


;断点
xchg bx, bx

mov si, booting
call print

mov edi, 0x1000;读取到的目的内存
mov ecx, 0;起始扇区
mov bl, 1;扇区的数量

call read_disk

xchg bx, bx

mov edi, 0x1000;读取的起始地址
mov ecx, 1;起始扇区
mov bl, 1;扇区的数量
call write_disk

; 阻塞(无限循环)
jmp $

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


write_disk:
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
    mov al, 0x30 ;写硬盘
    out dx, al

    xor ecx, ecx
    mov cl, bl;得到写扇区的数量

    .write:
        push cx
        call .writes;写一个扇区
        call .waits;等待数据写入完毕
        
        pop cx
        loop .write
    ret

    .waits:
        mov dx, 0x1f7
        .check:
            in al, dx
            jmp $+2; nop
            jmp $+2; nop
            jmp $+2; nop
            and al, 0b1000_0000
            cmp al, 0
            jnz .check
        ret
    .writes:
        mov dx, 0x1f0
        mov cx, 256;一个扇区256个字
        .writew:
            mov ax, [edi]
            out dx, ax
            jmp $+2;nop
            jmp $+2;nop
            jmp $+2;nop
            add edi, 2
            loop .writew
        ret

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

booting:
    db "Booting Onix...", 10, 13, 0 ;\n\r

error:
    mov si, .msg
    call print
    hlt
    jmp $
    .msg db "Booting Error", 10, 13, 0;\n\r

; 填充 0
times 510 - ($ - $$) db 0

; MBR 签名
db 0x55, 0xaa
