; Define variables in the data section
section .data
	usage:			db 'fibonaci <number>', 10
	usageLen:		equ $-usage
	invalidArgument:	db 'arg1 is not valid number', 10
	invalidArgumentLen:	equ $-invalidArgument

section .bss
	
output: resb 256 

; Code goes in the text section
section .text
	global _start 

_start:
	push rbp;
	mov rbp, rsp

	cmp qword [rbp+8], 1 ; atleast one program argument is provided
	jne Continue
	jmp Usage	     ; display text exit	

Continue:
	mov rsi, qword [rbp+8*3] ; 3 => pushed rbp, program, ${ arg1 }
	call atoi 		 ; ecx = atoi(arg1)
	
	mov rax, rax ; first
	mov rbx, 1   ; second
	xor rdx, rdx ; dx = first + second
fibo:	
	xor rdx, rdx
	add rdx, rax
	add rdx, rbx
	mov rax, rbx
	mov rbx, rdx
	loop fibo

print_answer:
	mov rdi, output
	call toString
	;; cout answer
	mov eax,4            ; 'write' system call = 4
	mov ebx,1            ; file descriptor 1 = STDOUT
	mov ecx, output        ; string to write
	;dx - from toString
	int 80h              ; call the kernel
	jmp Exit

Usage:
	mov eax,4            ; 'write' system call = 4
	mov ebx,1            ; file descriptor 1 = STDOUT
	mov ecx,usage        ; string to write
	mov edx,usageLen     ; length of string to write
	int 80h              ; call the kernel

Exit:
	pop rbp

	mov eax,1            ; 'exit' system call
	mov ebx,0            ; exit with error code 0
	int 80h              ; call the kernel

;; input 
;;	: dx - positive natural numbers
;;	: rsi - string argument terminated using '\0'
; return
;;	: ecx - unsinged value
atoi:	
	xor ecx, ecx
	atoi_ok:
		mov bl, [rsi]
		cmp bl, 0
		je atoi_exit   ;; end of string
		inc rsi

		sub bl, '0'
		imul ecx, 10
		add ecx, ebx

		cmp bl, 9
		jbe atoi_ok

		;; current char is not digit,
		;; display error and exit
	atoi_error:
		mov eax,4        	    ; 'write' system call = 4
		mov ebx,1 	            ; file descriptor 1 = STDOUT
		mov ecx, invalidArgument        ; string to write
		mov edx, invalidArgumentLen     ; length of string to write
		int 80h              	    ; call the kernel
		jmp Exit
	atoi_exit:
		ret

;; input 
;;	: dx - positive natural numbers
;;	: rdi - string destination buffer
;; return
;;	: dx - string length?
toString:
	mov rax, rdx
	xor rcx, rcx ;; lenght counter
	mov rbx, 10
	
	;; forms string in reverse
	mov rdi, output
	toStringHelper:
		xor rdx, rdx
		div ebx
		add rdx, '0'
		mov [rdi], rdx
		inc rdi
		inc rcx
		cmp rax, 0
		jne toStringHelper

		;; rdi points to string terminator
		mov [rdi], byte 10
		mov [rdi + 1], byte 0
		inc rcx
				
		dec rdi ;; rdi points to last char of string
		mov rsi, output
	swap:
		cmp rsi, rdi
		jge exitToString
		; rdi points to end of string output to beginning
		mov bl, [rsi]
		mov dl, [rdi]
		mov [rsi], dl
		mov [rdi], bl
		inc rsi
		dec rdi
		jmp swap
exitToString:
	mov edx, ecx
	ret
