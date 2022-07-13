# 实模式 print

int 0x10 指令参考文献[http://www.ablmcc.edu.hk/~scy/CIT/8086_bios_and_dos_interrupts.htm](http://www.ablmcc.edu.hk/~scy/CIT/8086_bios_and_dos_interrupts.htm)

本次用到的：
```x86asm
INT 10h / AH = 0Eh - teletype output.

input:
AL = character to write.
this functions displays a character on the screen, advancing the cursor and scrolling the screen as necessary. the printing is always done to current active page.

example:

	mov al, 'a'
	mov ah, 0eh
	int 10h

	; note: on specific systems this
	; function may not be supported in graphics mode. 
```

>xchg bx, bx;  bochs 魔术断点

print功能的实现
```s
mov si, booting
call print

; 阻塞
jmp $

print:
    mov ah, 0x0e
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
    db "Booting Onix...", 10, 13, 0; \n\r
```