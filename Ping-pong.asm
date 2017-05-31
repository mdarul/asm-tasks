data segment
	ball_position_x dw 50 ; ball's left corner x
	ball_position_y dw 50 ; left corner y
	ball_vector_x dw 1 ; if 1, then ball moves right, if -1 left
	ball_vector_y dw -1 ; if -1, then ball moves down, if 1 - up
	paddle_position dw 140 ; paddle's left corner's x position (y is const)
	game_over_communicate db 'Game Over!!!', 10, 13, '$'
data ends


code segment
.286
start:
	; stack initialization
	mov ax, seg stack_pointer
	mov ss, ax
	mov sp, offset stack_pointer
	; ds initialization
	mov ax, seg data
	mov ds, ax
	
	call set_graphic_mode
	call clear_screen
	
	game:
		call sleep
		call move_paddle
		continue_game:
			call move_ball
			call check_collisions
			call clear_screen
			call print_paddle
			call print_ball
		jmp game
	
	call sleep
	call program_end

	

;##################
;#####PROCEDURES#####
;##################


sleep:
	pusha
	xor cx, cx
	mov dx, 15000
	mov ah, 86h
	int 15h
	popa
	ret
	

set_graphic_mode:
	push ax
	mov ah, 0h
	mov al, 13h
	int 10h
	mov ax, 0a000h
	mov es, ax
	pop ax
	ret

	
set_normal_mode:
	push ax
	mov ax, 03h
	int 10h
	pop ax
	ret

	
clear_screen:
	pusha
	xor cx, cx
	xor bx, bx
	mov dx, 6399
	mov al, 00h ; 00h = clear entire window
	mov ah, 06h
	int 10h
	popa
	ret
	
	
print_paddle:
	pusha
	mov bx, word ptr ds:[paddle_position]
	; paddle will be written in lines 195-199
	mov dx, 195
	mov ah, 0Ch
	mov ax, bx
	; 30p - length of paddle
	add ax, 30
	print_paddle_ext:
		mov cx, bx
		print_paddle_int:
			push ax
			; al==3 - some kind of cyan color
			mov al, 3
			mov ah, 0Ch
			int 10h
			pop ax
			inc cx
			cmp cx, ax
			jb print_paddle_int
		inc dx
		cmp dx, 199
		jbe print_paddle_ext
	popa
	ret

	
move_paddle:
	;if no key has been pressed gp back (jz - jump if previous arithmetic operation's result was 0, so we will use it to check if any key was pressed)
	xor ax, ax
	mov ah,01h
	int 16h	
	jz continue_game
	; if pressed
	mov ah, 01h
	xor ax, ax
	int 16h
	; if ESC
	cmp ah, 01h
	je program_end
	; if <-
	cmp ah, 4Bh
	je move_paddle_left
	; if ->
	cmp ah, 4Dh
	je move_paddle_right	
	ret
	

move_paddle_left:
	mov bx, word ptr ds:[paddle_position]
	cmp bx, 0
	je move_paddle
	; we move paddle 10p to the left
	sub bx, 10
	mov word ptr ds:[paddle_position], bx
	ret
	
	
move_paddle_right:
	mov bx, word ptr ds:[paddle_position]
	cmp bx, 290
	jae move_paddle
	; we move paddle 10p to the right
	add bx, 10
	mov word ptr ds:[paddle_position], bx
	ret	
		

print_ball:
	pusha
	xor dx, dx
	xor cx, cx
	
	mov dx, word ptr ds:[ball_position_y]
	mov cx, word ptr ds:[ball_position_x]
	
	; ax - lines to print, bx - pixels to pring
	mov ax, dx
	add ax, 5
	mov bx, cx
	add bx, 5
	
	print_ball_ext:
		push ax
		; we will use cx to count up amount of pixels already written
		mov cx, bx
		; we have to clear pixels after previous loop (or initialization)
		sub cx, 5
		print_ball_int:
			mov al, 4
			mov ah, 0Ch
			int 10h			
			inc cx
			cmp cx, bx
			jbe print_ball_int
		inc dx
		pop ax
		cmp dx, ax
		jbe print_ball_ext
	popa
	ret


move_ball:
	pusha
	;move_ball_x
		xor bx, bx
		mov bx, word ptr ds:[ball_vector_x]
		cmp bx, 1
		je move_ball_right
		;move_ball_left
			mov bx, word ptr ds:[ball_position_x]
			dec bx
			mov word ptr ds:[ball_position_x], bx
			jmp move_ball_y
		
		move_ball_right:
			mov bx, word ptr ds:[ball_position_x]
			inc bx
			mov word ptr ds:[ball_position_x], bx
			
	move_ball_y:
		xor bx, bx
		mov bx, word ptr ds:[ball_vector_y]
		cmp bx, -1
		je move_ball_down
		;move_ball_up
			mov bx, word ptr ds:[ball_position_y]
			sub bx, 1
			mov word ptr ds:[ball_position_y], bx
			jmp move_ball_end
		
		move_ball_down:
			mov bx, word ptr ds:[ball_position_y]
			inc bx
			mov word ptr ds:[ball_position_y], bx
	move_ball_end:
	popa
	ret
	
	
check_collisions:
	; firstly we check if it is not game over
	mov bx, word ptr ds:[ball_position_y]
	cmp bx, 194 ; if y==194 it means that ball's lower side will touch the end of the screen in the next move, so it's game over
	je program_end

	; check if paddle has been hit
	check_paddle_collision:
		; firstly we check Y
		mov bx, word ptr ds:[ball_position_y]
		cmp bx, 189 ; 5 pixels of square + 5 pixels of paddle length == 199 max
		jne next1
		; lastly we check y
			mov bx, word ptr ds:[ball_position_x] ; ball furthest (on left) X pixel position
			mov dx, word ptr ds:[paddle_position] ; paddle furthest (on left) X pixel position
			; checking if ball is not before paddle's left border
			add bx, 4 ; now in bx we have most left possible position of ball in which it can still hit the paddle (not 5, because 1 is need to determine a connectrion)
			cmp bx, dx ; if bx is lower, break checking paddle collision
			jb next1
				; now we check if ball is not beyond paddle's right border
				sub bx, 4 ; back to base position
				sub bx, 26 ; 30p of paddle length - 4p of square length (not 5, because 1 is need to determine a connectrion) most right possible position of the paddle
				cmp bx, dx
				jnb next1
				; if all conditions are passed, then we've hit the paddle and we have to change vecot
				mov bx, 1
				mov word ptr ds:[ball_vector_y], bx
	next1:
	mov bx, word ptr ds:[ball_position_x]
	cmp bx, 0
	jne next2
	; if x==0 we reverse vector
		push bx
		mov bx, 1
		mov word ptr ds:[ball_vector_x], bx
		pop bx
	next2:
	cmp bx, 314 ; 314, because square is 5p long, and 319 (320, but 0 counts) is X limit
	jne next3
	; if x==319 we reverse vector
		mov bx, -1
		mov word ptr ds:[ball_vector_x], bx
	; check Y collisions
	next3:
	mov bx, word ptr ds:[ball_position_y]
	cmp bx, 0
	jne next4
	; if y==0 we reverse vector
		push bx
		mov bx, -1
		mov word ptr ds:[ball_vector_y], bx
		pop bx
	next4:
	cmp bx, 194 ; 194 because square is 5p long, and 199 (200, but 0 counts) is Y limit
	jne check_collisions_end
	; if y==199
		mov bx, 1
		mov word ptr ds:[ball_vector_y], bx
	check_collisions_end:	
	ret


program_end:
	call set_normal_mode
	
	mov dx, offset game_over_communicate
	mov ax, seg game_over_communicate
	mov ds, ax
	mov ah, 09h
	int 21h
	
	mov ah, 4Ch
	int 21h
	
code ends


stack1 segment stack
	stack_pointer dw ?
	dw 200 dup(?)
stack1 ends

end start