org 0x8000

mov ah, 0x06
mov al, 0x00
mov cl, 0x00
mov dh, 0x19
mov bh, 0x1f
int 0x10

mov ah, 0x0e
mov bx, info_system
write_ik:
    mov al, [bx]
    cmp al, 0x00
    je finish
    add bx, 1
    int 0x10
    jmp write_ik

finish:
    mov ah, 0x00
    int 0x16
    mov ah, 0x00
    mov al, 0x00
    int 0x10

sys:
    mov ah, 0x0e
    mov bx, ready_info
ready_loop:
    mov al, [bx]
    cmp al, 0x00
    je loop_system_finish
    add bx, 1
    int 0x10
    jmp ready_loop


loop_system_finish:
    mov dh, [count_line]
    inc dh
    mov [count_line], dh
    mov ah, 0x02
    mov bh, 0x00
    mov dh, [count_line]
    mov dl, 0x00
    int 0x10
    mov ah, 0x0e
    mov al, '>'
    int 0x10

;START
start_input:
    mov bx, 0

main_input:
    mov ah, 0x00
    int 0x16
    cmp al, 0x0d
    je enter_input
    cmp al, 0x08
    je backspace
    jmp write

write:
    mov ah, 0x0e
    mov [input + bx], al
    int 0x10
    inc bx
    jmp main_input

backspace:
	cmp byte [input], 0x00
	je main_input
    dec bx 
    mov byte [input + bx], 0x00 
    mov ah, 0x0e
	mov al, 0x08
	int 0x10
	mov ah, 0x0e
	mov al, ''
	int 0x10
	mov ah, 0x0e
	mov al, 0x08
	int 0x10
	cmp bx, 0
	jmp main_input

enter_input:
    mov bx, 0

query:
	mop_query:
    	mov al, [mop + bx]
    	cmp al, [input + bx]
    	je mop_match
    sysinfo_query:
    	mov al, [sysinfo + bx]
    	cmp al, [input + bx]
    	je sysinfo_match
    po_query:
    	mov al, [po + bx]
    	cmp al, [input + bx]
    	je po_match
    reboot_query:
    	mov al, [reboot + bx]
    	cmp al, [input + bx]
    	je reboot_match
    output_query:
    	mov al, [output + bx]
    	cmp al, [input + bx]
    	je output_match
    	jmp re_input
		
re_input:
	add dh, 1
    mov [count_line], dh
    mov ah, 0x02
    mov bh, 0x00
    mov dh, [count_line]
    mov dl, 0x00
    int 0x10
	mov ah, 0x0e
	mov bx, command_nf
	write_command_nf:
	    mov al, [bx]
	    cmp al, 0x00
	    je nf_finish
	    add bx, 1
	    int 0x10
	    jmp write_command_nf
		nf_finish:
    		call clean_buffer
    		jmp down_line

down_line:
    inc dh
    mov [count_line], dh
    mov ah, 0x02
    mov bh, 0x00
    mov dh, [count_line]
    mov dl, 0x00
    int 0x10
    mov ah, 0x0e
    mov al, '>'
    int 0x10
    jmp start_input

;matchs
;matchs - TTY
sysinfo_match:
	add bx, 1
	cmp bx, 7
	je sysinfo_match_success
	jmp sysinfo_query
	
sysinfo_match_success:
	mov bx, sysinfo_info
	mov ah, 0x0e
	info_sysloop:
		mov al, [bx]
		add bx, 1
		cmp al, 0x00
		je nf_finish
		int 0x10
		jmp info_sysloop
			
mop_match:
	add bx, 1
	cmp bx, 3
    je mop_match_success
    jmp query

mop_match_success:
    mov dh, 0x00
    mov byte [count_line], 0x00
    mov ah, 0x00
    mov al, 0x00
    int 0x10
    jmp sys

output_match: ;!ALWAYS END
	add bx, 1
	cmp bx, 7
	je output_match_success
	jmp output_query 

output_match_success: ;!ALWAYS END
	add dh, 1
    mov [count_line], dh
    mov ah, 0x02
    mov bh, 0x00
    mov dh, [count_line]
    mov dl, 0x00
    int 0x10
    mov ah, 0x0e
	write_output:
		mov al, [input + bx]
		int 0x10
		cmp al, 0x00
		je nf_finish
		add bx, 1
	    jmp write_output

;matchs - system management
po_match:
	add bx, 1 
	cmp bx, 2
	je po_match_success
	jmp po_query

po_match_success:
    mov ax, 0x5307
    mov bx, 0x0001
    mov cx, 0x0003
    int 0x15

reboot_match:
	add bx, 1
	cmp bx, 6
	je reboot_match_success
	jmp reboot_query

reboot_match_success:
    db 0x0ea
    dw 0x0000
    dw 0xffff

;word key
sysinfo:
	db 'sysinfo'

mop:
    db 'mop'

po:
	db 'po'
	
reboot:
    db 'reboot'

output:
	db 'output '

;informations
sysinfo_info:
	db ' V010', 0x00

ready_info:
    db 'SYSTEM READY', 0x00

command_nf:
	db 'command not found', 0x00

info_system:
    db 'STATUS=LOADED', 0x00


;clear buffers
clean_buffer:
    mov si, input
    mov cx, 128  
clear_loop:
    mov byte [si], 0x00
    inc si
    loop clear_loop
    ret

clean_buffer_bx:
    mov si, [bx]
    mov cx, 128  
clear_loop_bx:
    mov byte [si], 0x00
    inc si
    loop clear_loop_bx
    ret

;bytes

input db 0
count_line db 0x00 

