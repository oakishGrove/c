     1                                  ; Define variables in the data section
     2                                  section .data
     3 00000000 6669626F6E61636920-     	usage:			db 'fibonaci <number>', 10
     3 00000009 3C6E756D6265723E0A 
     4                                  	usageLen:		equ $-usage
     5 00000012 61726731206973206E-     	invalidArgument:	db 'arg1 is not valid number', 10
     5 0000001B 6F742076616C696420-
     5 00000024 6E756D6265720A     
     6                                  	invalidArgumentLen:	equ $-invalidArgument
     7                                  
     8                                  section .bss
     9                                  	
    10 00000000 <res 100h>              output: resb 256 
    11                                  
    12                                  ; Code goes in the text section
    13                                  section .text
    14                                  	global _start 
    15                                  
    16                                  _start:
    17 00000000 55                      	push rbp;
    18 00000001 4889E5                  	mov rbp, rsp
    19                                  
    20 00000004 48837D0801              	cmp qword [rbp+8], 1 ; atleast one program argument is provided
    21 00000009 7502                    	jne Continue
    22 0000000B EB47                    	jmp Usage	     ; display text exit	
    23                                  
    24                                  Continue:
    25 0000000D 488B7518                	mov rsi, qword [rbp+8*3] ; 3 => pushed rbp, program, ${ arg1 }
    26 00000011 E864000000              	call atoi 		 ; ecx = atoi(arg1)
    27                                  	
    28 00000016 4889C0                  	mov rax, rax ; first
    29 00000019 BB01000000              	mov rbx, 1   ; second
    30 0000001E 4831D2                  	xor rdx, rdx ; dx = first + second
    31                                  fibo:	
    32 00000021 4831D2                  	xor rdx, rdx
    33 00000024 4801C2                  	add rdx, rax
    34 00000027 4801DA                  	add rdx, rbx
    35 0000002A 4889D8                  	mov rax, rbx
    36 0000002D 4889D3                  	mov rbx, rdx
    37 00000030 E2EF                    	loop fibo
    38                                  
    39                                  print_answer:
    40 00000032 48BF-                   	mov rdi, output
    40 00000034 [0000000000000000] 
    41 0000003C E86B000000              	call toString
    42                                  	;; cout answer
    43 00000041 B804000000              	mov eax,4            ; 'write' system call = 4
    44 00000046 BB01000000              	mov ebx,1            ; file descriptor 1 = STDOUT
    45 0000004B B9[00000000]            	mov ecx, output        ; string to write
    46                                  	;dx - from toString
    47 00000050 CD80                    	int 80h              ; call the kernel
    48 00000052 EB16                    	jmp Exit
    49                                  
    50                                  Usage:
    51 00000054 B804000000              	mov eax,4            ; 'write' system call = 4
    52 00000059 BB01000000              	mov ebx,1            ; file descriptor 1 = STDOUT
    53 0000005E B9[00000000]            	mov ecx,usage        ; string to write
    54 00000063 BA12000000              	mov edx,usageLen     ; length of string to write
    55 00000068 CD80                    	int 80h              ; call the kernel
    56                                  
    57                                  Exit:
    58                                  	; Terminate program -- from example
    59                                  	; mov rsp, rbp
    60                                  	; pop rbp
    61                                  
    62                                  	; mine - pc still works :)
    63 0000006A 5D                      	pop rbp
    64 0000006B 4889EC                  	mov rsp, rbp
    65                                  
    66 0000006E B801000000              	mov eax,1            ; 'exit' system call
    67 00000073 BB00000000              	mov ebx,0            ; exit with error code 0
    68 00000078 CD80                    	int 80h              ; call the kernel
    69                                  
    70                                  ;; input 
    71                                  ;;	: dx - positive natural numbers
    72                                  ;;	: rsi - string argument terminated using '\0'
    73                                  ; return
    74                                  ;;	: ecx - unsinged value
    75                                  atoi:	
    76 0000007A 31C9                    	xor ecx, ecx
    77                                  	atoi_ok:
    78 0000007C 8A1E                    		mov bl, [rsi]
    79 0000007E 80FB00                  		cmp bl, 0
    80 00000081 7428                    		je atoi_exit   ;; end of string
    81 00000083 48FFC6                  		inc rsi
    82                                  
    83 00000086 80EB30                  		sub bl, '0'
    84 00000089 6BC90A                  		imul ecx, 10
    85 0000008C 01D9                    		add ecx, ebx
    86                                  
    87 0000008E 80FB09                  		cmp bl, 9
    88 00000091 76E9                    		jbe atoi_ok
    89                                  
    90                                  		;; current char is not digit,
    91                                  		;; display error and exit
    92                                  	atoi_error:
    93 00000093 B804000000              		mov eax,4        	    ; 'write' system call = 4
    94 00000098 BB01000000              		mov ebx,1 	            ; file descriptor 1 = STDOUT
    95 0000009D B9[12000000]            		mov ecx, invalidArgument        ; string to write
    96 000000A2 BA19000000              		mov edx, invalidArgumentLen     ; length of string to write
    97 000000A7 CD80                    		int 80h              	    ; call the kernel
    98 000000A9 EBBF                    		jmp Exit
    99                                  	atoi_exit:
   100 000000AB C3                      		ret
   101                                  
   102                                  ;; input 
   103                                  ;;	: dx - positive natural numbers
   104                                  ;;	: rdi - string destination buffer
   105                                  ;; return
   106                                  ;;	: dx - string length?
   107                                  toString:
   108 000000AC 4889D0                  	mov rax, rdx
   109 000000AF 4831C9                  	xor rcx, rcx ;; lenght counter
   110 000000B2 BB0A000000              	mov rbx, 10
   111                                  	
   112                                  	;; forms string in reverse
   113 000000B7 48BF-                   	mov rdi, output
   113 000000B9 [0000000000000000] 
   114                                  	toStringHelper:
   115 000000C1 4831D2                  		xor rdx, rdx
   116 000000C4 F7F3                    		div ebx
   117 000000C6 4883C230                		add rdx, '0'
   118 000000CA 488917                  		mov [rdi], rdx
   119 000000CD 48FFC7                  		inc rdi
   120 000000D0 48FFC1                  		inc rcx
   121 000000D3 4883F800                		cmp rax, 0
   122 000000D7 75E8                    		jne toStringHelper
   123                                  
   124                                  		;; rdi points to string terminator
   125 000000D9 C6070A                  		mov [rdi], byte 10
   126 000000DC C6470100                		mov [rdi + 1], byte 0
   127 000000E0 48FFC1                  		inc rcx
   128                                  				
   129 000000E3 48FFCF                  		dec rdi ;; rdi points to last char of string
   130 000000E6 48BE-                   		mov rsi, output
   130 000000E8 [0000000000000000] 
   131                                  	swap:
   132 000000F0 4839FE                  		cmp rsi, rdi
   133 000000F3 7D10                    		jge exitToString
   134                                  		; rdi points to end of string output to beginning
   135 000000F5 8A1E                    		mov bl, [rsi]
   136 000000F7 8A17                    		mov dl, [rdi]
   137 000000F9 8816                    		mov [rsi], dl
   138 000000FB 881F                    		mov [rdi], bl
   139 000000FD 48FFC6                  		inc rsi
   140 00000100 48FFCF                  		dec rdi
   141 00000103 EBEB                    		jmp swap
   142                                  exitToString:
   143 00000105 89CA                    	mov edx, ecx
   144 00000107 C3                      	ret
