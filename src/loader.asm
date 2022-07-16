[org 0x1000]

dw 0x55aa;magic number 用于判断错误

xchg bx, bx

mov si, loading
call print

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