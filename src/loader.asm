[org 0x1000]

dw 0x55aa;magic number 用于判断错误

xchg bx, bx

mov si, loading
call print

xchg bx, bx

detect_memory:
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

    ; cx 表示结构体数量
    mov cx, [ards_count]
    ; 结构体指针
    mov si, 0
.show:
    mov eax, [si + ards_buffer]
    mov ebx, [si + ards_buffer + 8]
    mov edx, [si + ards_buffer + 16]
    xchg bx, bx
    loop .show;loop的次数放在 cx 中


jmp $

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

ards_count:
    dw 0
ards_buffer:
    
