
;; readLine function
;           rdi - file fd
;           rsi - rez buffer
;           rdx - maxLength
;; returns rax - read count, if end of file reached ZF - flag set
    BUFFER_MAX_SIZE equ 128

section .data
    bufferIndex dd 0
    bufferLength dd 0
    buffer db BUFFER_MAX_SIZE
;section .bss
;    buffer resb BUFFER_MAX_SIZE

section .text
    global readLine
readLine:

    push r12
    push r13
    push r14
    mov r12, rsi
    mov r13, rdx

    xor rdx, rdx
    xor r14, r14
    xor rcx, rcx
readLineDo: ;; init check
    mov ecx, [bufferLength]
    ;movzx rcx, dword [bufferLength]
    sub ecx, [bufferIndex]
    jz readLineUpdateBuffer ;; rax = 0 rcx????

readLineDo1:
    ;cx = to_end
    xor rcx, rcx
    mov ecx, [bufferLength]
    sub ecx, [bufferIndex]
    cmp rcx, r13
    jge readLineDoElse
    jmp readLineDots
readLineDoElse: ;; else
    mov rcx, r13
readLineDots: ;;

    mov rbx, rcx
    mov rsi, buffer
    add esi, dword [bufferIndex]
    mov rdi, r12
    add rdi, r14
readLineDotsLoop:
    ;mov rsi, buffer
    mov dl, [rsi]
    cmp dl, 10 ; '\n'
    je readLineOk
    cmp dl, 0
    je readLineEof
    mov [rdi], dl
    inc r14
    inc rsi
    inc rdi
    loop readLineDotsLoop

    sub r13, rbx
    jle readLineExit
    jmp readLineUpdateBuffer


;(ecx)to_end = len - index
;if (to_end < rez_size)
;    rcx = to_end
;    ....
;    rez_size -= to_end
;    goto outer
;else {
;    rcx = rez_size
;    ....
;}

readLineUpdateBuffer:
    mov rax, 0
    mov rsi, buffer
    mov rdx, BUFFER_MAX_SIZE
    syscall

    cmp rax, 0
    jl readLineErrorReading
    mov [bufferLength], eax
    mov [bufferIndex], dword 0
    ; rdi file descriptor
    jmp readLineDo1


readLineSetOF:
    mov al, 0x7f
    inc al
readLineErrorReading:
    mov rax, 0xffffffffffffffff
    jmp readLineExit


readLineEof:
    inc r14
    cmp r14, r13
    je readLineSetOF;; no space for '\0' set OF
    ; else
    dec r14
    ;; set ZF
    xor rax, rax
    jmp readLineOkLast

readLineOk:
    inc r14
    cmp r14, r13
    je readLineSetOF;; no space for '\0' set OF
    ; else
    dec r14
readLineOkLast:
    mov [rdi], byte 0
    add [bufferIndex], r14
    mov rax, r14
readLineExit:
    pop r14
    pop r13
    pop r12
    ret
