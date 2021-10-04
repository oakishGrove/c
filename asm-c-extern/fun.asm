;; readLine function
;           rdi - file fd
;           rsi - rez buffer
;           rdx - maxLength
;; returns rax - read count, if end of file reached ZF - flag set
    BUFFER_MAX_SIZE equ 128

section .data
    bufferIndex dd 0
    bufferLength dd 0
    ;buffer db BUFFER_MAX_SIZE
section .bss
    buffer resb BUFFER_MAX_SIZE

section .text
    global readLine
readLine:
    push r12
    push r13
    push r14
    push r15

    mov r12, rdi ; input fd
    mov r13, rsi ; rez buffer
    mov r14, rdx ; rez max len
    mov r15, 0   ; write bites

    xor rcx, rcx
readLineInitCheck:
    mov ecx, [bufferLength]
    sub ecx, [bufferIndex]
    jz readLineUpdateBuffer
;; ------------
    ;rcx = bufLen - bufIndex
    cmp rcx, r14
    jge readLineDoElse
    jmp readLineDots
readLineDoElse: ;; else
    mov rcx, r14

readLineDots: ;;

    mov rbx, rcx  ;; save counter
    mov rsi, buffer
    add esi, dword [bufferIndex]
    mov rdi, r13
    add rdi, r15 ;; skip chars writen in previous pass
    xor rax, rax ;; counts bufferIndex increment
    xor rdx, rdx
readLineDotsLoop:
    ;mov rsi, buffer
    mov dl, [rsi]
    cmp dl, 10 ; '\n' folowing posix standart each lines ends with '\n'
    je readLineOk
    mov [rdi], dl
    inc r15
    inc rsi
    inc rdi
    inc rax
    loop readLineDotsLoop

    ; didn't found '\n' in first pass
    sub r14, rbx
    cmp r14, 0
    jle readLineSetOF ;;
    add [bufferIndex], eax
    jmp readLineInitCheck


;outer:
; <...>
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
    mov rdi, r12
    mov rsi, buffer
    mov rdx, BUFFER_MAX_SIZE
    syscall

    cmp rax, 0
    jl readLineErrorReading
    je readLineEof
    mov [bufferLength], eax
    mov [bufferIndex], dword 0
    jmp readLineInitCheck


readLineSetOF:
    mov al, 0x7f
    inc al
readLineErrorReading:
    mov rax, 0xffffffffffffffff
    jmp readLineExit

readLineEof:
    inc r15
    cmp r15, r14
    je readLineSetOF;; no space for '\0' set OF

    add r13, r15
    mov [r13], byte 0
    mov rax, r15
    xor rax, rax
    jmp readLineExit

readLineOk:
    inc r15
    cmp r15, r14
    je readLineSetOF;; no space for '\0' set OF
readLineOkLast:
    mov [rdi], byte 0
    inc rax ;; main loops skips '\n'
    add [bufferIndex], rax
    mov rax, r15
readLineExit:
    pop r15
    pop r14
    pop r13
    pop r12
    ret
