;######################################################
;#####											DATA										   #####
;######################################################

data segment
	entry1		   				   db		'Program reads hexadecimal digit from the keyboard and', 10, 13, '$'
	entry2		  				   db		'makes a binary banner of it. Please enter a character',10, 13, '$'
	entry3		   				   db		'(small letters are also supported).',10, 13, '$'
	enteredDigit   				   db		'Entered character: $'
	bannerAnnoucement		   db		'Created banner:', 10, 13, '$'
	stringOne 	   				   db		'   #   $', '  ##   $', ' # #   $', '   #   $', '   #   $', '   #   $', ' ##### $' 
	stringZero      				   db		'  ###  $', ' #   # $', '#     #$', '#     #$', '#     #$', ' #   # $', '  ###  $'
	errorInfo			   			   db		'Invalid character!$'
	newlLine	   	   				   db      10, 13, '$'
data ends


;######################################################
;#####											MAIN										   #####
;######################################################

code segment
.286
start:
	
	call initializeStack
	call printNewLine	
	call printEntry
	call readDigit
	call printDigit
	call compareAndRun


;######################################################
;#####										PROCEDURED								   #####
;######################################################
	
	
initializeStack:
	mov sp, offset stack_pointer
	mov ax, seg stack_pointer
	mov ss, ax
	ret
	
	
print:
	push ax
	mov ah, 9h
	int 21h
	pop ax
	ret
	
	
printNewLine:
	pusha
	mov dx, offset newlLine
	mov ax, seg newlLine
	mov ds, ax
	call print
	popa
	ret
	
printEntry:
	mov dx, offset entry1
	mov ax, seg entry1
	mov ds, ax
	call print
	mov dx, offset entry2
	mov ax, seg entry2
	mov ds, ax
	call print
	mov dx, offset entry3
	mov ax, seg entry3
	mov ds, ax
	call print
	ret
	

readDigit:;reading digit from the keyboard
	mov ah, 08h
	int 21h	
	ret
	
	
printDigit:
	call printNewLine
	push ax
	mov dx, offset enteredDigit
	mov ax, seg enteredDigit
	mov ds, ax
	call print
	
	; print the digit in quotes
	mov dl, '"'
	mov ah, 02h
	int 21h
	
	pop ax
	mov dl, al
	push ax
	mov ah, 02h
	int 21h
	
	mov dl, '"'
	mov ah, 02h
	int 21h
	
	call printNewLine
	
	pop ax
	ret

	
printBannerAnnoucement:
	pusha
	mov dx, offset bannerAnnoucement
	mov ax, seg bannerAnnoucement
	mov ds, ax
	call print
	call printNewLine
	popa
	ret
	
	
compareAndRun:; checking, wheter the passed ASCII character is correct
	; character's ASCII code is lesser then the code of '0'
	cmp al, '0'
	jb error
	
	; interval <'0', '9'>
	cmp al, '9'
	jbe convertDigit
	
	; interval ('0', 'A')
	cmp al, 'A'
	jb error
	
	; przedział <'A', 'F'>
	cmp al, 'F'
	jbe convertLargeLetter
	
	; interval ('f', 'a')
	cmp al, 'a'
	jb error
	
	; interval ('a', 'f')
	cmp al, 'f'
	jbe convertSmallLetter
	
	; greater then 'f'
	cmp al, 'f'
	ja error
	

;#####		CONVERTERS		#####

; simple ASCII operation
convertDigit:
	sub al, 48d ; -ASCII(0) (-48)
	call draw

convertLargeLetter:
	sub al, 55d ; -ASCII(A) + 10d (65-10), because A - in the program - stands for 10d
	call draw

convertSmallLetter: ; -ASCII(a) + 10d (97-10), because a - in our program - stands for 10d
	sub al, 87d
	call draw
;########################


draw: 
	call printBannerAnnoucement
	mov cx, 7 ; 7 lines to print, counter of external loop
	mov bx, 0 ; we start with 0 index of each table (stringZero, stringOne), later on we will move it by 8 (to the next string)
	; we move digit from 4 lower bytes to 4 higher bytes
	push cx
	mov cl, 4
	shl al, cl
	pop cx
	
	printBanner:
		push cx ; we put the counter of external loop
		push ax ; we push digit on stack, because we'll do some operations on it, and later on we'll need it unchanged
		mov cx, 4 ; in internal loop we'll evaluate 4 elements of banner in every line
		
		printLine:
			shl al, 1
			jc printOne
			jnc printZero
		continue:
		loop printLine
		call printNewLine
		add bx, 8 ; move to the next element of a table
		pop ax
		pop cx
	loop printBanner
	call programEnd

printOne:
	push ax
	mov ax, seg stringOne
	mov ds, ax
	pop ax
	mov si, offset stringOne
	mov dx, 0
	add dx, si
	add dx, bx
	call print
	jmp continue


printZero:
	push ax
	mov ax, seg stringZero
	mov ds, ax
	pop ax
	mov si, offset stringZero
	mov dx, 0
	add dx, si
	add dx, bx
	call print
	jmp continue


error:
	mov dx, offset errorInfo
	mov ax, seg errorInfo
	mov ds, ax
	call print
	call printNewLine
	call programEnd
	
	
programEnd:
	mov ah, 4ch
	int 21h

	
code ends

stack1 segment stack
				 dw	200 dup(?)
	stack_pointer dw 	?
stack1 ends

end start