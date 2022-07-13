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

; 阻塞(无限循环)
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

booting:
    db "Booting Onix...", 10, 13, 0 ;\n\r

; 填充 0
times 510 - ($ - $$) db 0

; MBR 签名
db 0x55, 0xaa
