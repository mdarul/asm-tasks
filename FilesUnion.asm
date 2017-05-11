;######################################################
;#####											DATA										   #####
;######################################################

data segment
	help db "Example program call - proj2.exe [-h] [-i entry_file_1] ... [-i entry_file_N] [-o output_file] [-t separation_sign]", 10, 13, '$'
	commandline_syntax_exception db "Wrong program execution syntax!", 10, 13, '$'
	
data ends


;######################################################
;#####											MAIN										   #####
;######################################################

code segment
.286
start:
	
	call initializeStackAndDX
	xor cx,cx ; zerowanie rejestru licznikowego
	
	;linia komend znajduje sie w es, jej dlugosc w es:[80h]
	mov cl,es:[80h] ; umieszczam dlugosc linii komend w rejestrze licznikowym
	cmp cl,0	; sprawdzam, czy linia komend nie jest pusta
	je syntax_exception ; jesli jest, wyswietl komunikat bledu i zakoncz
	
	Comment @
	mov cmdlength,cx ; zachowuje dlugosc linii komend w zmiennej
	xor si,si ; zeruje rejestry si i ah
	xor ah,ah
	
	
	copy_cmd:  ; przepisz linie komend do zmiennej cmdline
		mov ah,es:[81h+si]
		mov byte ptr ds:[cmdline+si],ah
		inc si
		loop copy_cmd
	@
	call programEnd
	
	
;######################################################
;#####											MACROS									   #####
;######################################################
Comment @
; printing a string with address ds:x, where x is macro argument
print macro x
	mov dx, x
	mov ah, 9h
	int 21h
endm
@
;######################################################
;#####										PROCEDURED								   #####
;######################################################
	
	
initializeStackAndDX:
	mov sp, offset stack_pointer
	mov ax, seg stack_pointer
	mov ss, ax
	mov ax, seg data
	mov dx, ax
	ret
	
	
print:
	push ax
	mov ah, 9h
	int 21h
	pop ax
	ret
	

syntax_exception:
	mov dx, offset commandline_syntax_exception
	mov ax, seg commandline_syntax_exception
	mov ds, ax
	call print
	jmp programEnd 
	
programEnd:
	mov ah, 4ch
	int 21h

	
code ends

stack1 segment stack
				 dw	200 dup(?)
	stack_pointer dw 	?
stack1 ends

end start
