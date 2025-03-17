[BITS 16]
[org 0x7c00]

mov ah, 0x06
mov dx, 0x184f
mov bh, 0x1f
int 0x10

mov ah, 0x0e
mov bx, info

write_boot:
	mov al, [bx]
	cmp al, 0x00
    	je finish_boot
	add bx, 1
	int 0x10
	jmp write_boot	

finish_boot:
	mov ah, 0x02 
    	mov al, 0x01 
    	mov ch, 0x00
    	mov cl, 0x02 
    	mov dh, 0x00
    	mov dl, 0x80 
    	mov bx, 0x8000
    	int 0x13
    
	jmp 0x8000 ; LOAD SYSTEM

info:
	db 'BOOTING ERROR', 0x00

loop:
	jmp loop

times 510 - ($ - $$) db 0x00
dw 0xaa55
