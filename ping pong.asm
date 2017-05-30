data segment
	x	dw ?
data ends


code segment
.286
start:
	mov ax, seg stack_pointer
	mov ss, ax
	mov sp, offset stack_pointer
	mov ax, seg data
	mov ds, ax
	
	mov bx, 85
	
	call set_graphic_mode
	call set_screen
	
	call print_paddle
	
	
	jmp move_paddle
	
	call sleep
	call program_end
	
	
;############
;###MACROS###
;############


;###############
;###PROCEDURES###
;###############

sleep:
	mov cx, 100
	mov dx, 100000
	mov ah, 86h
	int 15h
	ret
	

set_graphic_mode:
	mov ah, 0h
	mov al, 13h
	int 10h
	mov ax, 0a000h
	mov es, ax
	ret

	
set_normal_mode:
	mov ax, 03h
	int 10h
	ret

	
set_screen:
	pusha
	xor cx, cx
	xor dx, dx
	ext_loop:
		mov dx, 0
		in_loop:
			mov ah, 0Ch
			mov al, 0
			int 10h
			inc dx
			cmp dx, 200
			jne in_loop
		inc cx
		cmp cx, 320
		jne ext_loop
	popa
	ret
	
	
print_paddle:
	push dx
	push ax
	push cx
	
	mov dx, 195
	mov ah, 0Ch
	mov ax, bx
	add ax, 30
	print_paddle_ext:
		mov cx, bx
		print_paddle_in:
			push ax
			mov al, 3
			mov ah, 0Ch
			int 10h
			pop ax
			inc cx
			cmp cx, ax
			jbe print_paddle_in
		inc dx
		cmp dx, 199
		jbe print_paddle_ext
		pop dx
		pop ax
		pop cx
	ret
	
	
	
	
move_paddle:
	mov ah, 01h
	xor ax, ax
	int 16h
	cmp ah, 01h
	je program_end
	cmp ah, 4Bh
	je move_left
	cmp ah, 4Dh
	je move_right	
	jmp move_paddle
	

move_left:
	cmp bx, 0
	je move_paddle
	sub bx, 5
	call print_paddle
	jmp move_paddle
	
	
move_right:
	cmp bx, 169
	je move_paddle
	add bx, 5
	call print_paddle
	jmp move_paddle
		
		
program_end:
	call set_normal_mode
	mov ah, 4Ch
	int 21h
	
code ends


stack1 segment stack
	stack_pointer dw ?
	dw 200 dup(?)
stack1 ends

end start