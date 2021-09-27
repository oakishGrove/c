; Define variables in the data section
section .data
	usage:			db 'fibonaci <number>', 10
	usageLen:		equ $-usage
	invalidArgument:	db 'arg1 is not valid number', 10
	invalidArgumentLen:	equ $-invalidArgument

section .bss
	
output: resb 32

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
	mov rdi, qword [rbp+8*3] ; 3 => pushed rbp |  program, ${ arg1 }, ...
	call atoi 		 ; rax = atoi(arg1)
	mov rcx, rax
	
	mov rax, 0   ; first
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
	mov rsi, rdx
	call toString
	;; cout answer
	mov rdx, rax          ; rax - string length
	mov eax, 4            ; 'write' system call = 4
	mov ebx, 1            ; file descriptor 1 = STDOUT
	mov ecx, output       ; string to write
	int 80h              ; call the kernel
	jmp Exit

Usage:
	mov eax,4            ; 'write' system call = 4
	mov ebx,1            ; file descriptor 1 = STDOUT
	mov ecx,usage        ; string to write
	mov edx,usageLen     ; length of string to write
	int 80h              ; call the kernel

Exit:
	; mov rsp, rbp       ; clear local variables
	pop rbp

	mov eax,1            ; 'exit' system call
	mov ebx,0            ; exit with error code 0
	int 80h              ; call the kernel

;; input 
;;	: rdi - string to number source
; return
;;	: rax - unsinged value
atoi:	
	push rbx  		;; function calling rules - preserved reg's
	xor rax, rax
	atoi_ok:
		mov bl, [rdi]
		cmp bl, 0
		je atoi_exit   ;; end of string
		inc rdi

		sub bl, '0'
		imul rax, 10
		add eax, ebx

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
		pop rbx 
		ret

;; input 
;;	: rdi - string destination buffer
;;	: rsi - positive natural numbers
;; return
;;	: rax - string length
toString:
	push rbx;

	mov rax, rsi
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
	mov eax, ecx
	pop rbx
	ret
