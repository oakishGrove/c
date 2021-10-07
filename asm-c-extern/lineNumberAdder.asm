S_IRUSR     equ     00400q
S_IWUSR     equ     00200q
MAX_INPUT_BUFFER equ 255

section .data

extern printErrorOverflown
extern printUsage
extern puts
extern readLine
extern digitCount

section .text

global main
main:
    push rbp
    mov rbp, rsp

    sub rsp, 288               ;   -4 4 - inputFd
                               ;   -8 4 - outputFd
                               ;  -16 8 - line number
                               ;  -20 4 - bufferLen
                               ; -276 256 - buffer
                               ; 12 - padding for rsp % 16 == 0
                               ; ..., compiler aligs it befero calls
    push r12
    push r13
    ;; correct number of program arguments
    cmp rdi, 3
    je openInputFile
    jmp usage
openInputFile:

    mov r12, rsi
    mov rdi, [r12+0]
    add rdi, 1
    call puts

    ;; open source file
    mov rax, 2
    mov rdi, [r12+8]
    mov rsi, 0x0        ;read only
    syscall
    cmp rax, 0
    jl couldNotOpenSourceFile
    mov [rbp-4], eax

    ;; create desitination file
    mov rax, 85         ; create file
    mov rdi, [r12+16]
    mov rsi,  0400q | 0200q; read, write user premissions
    syscall
    cmp rax, 0
    jl closeSourceBeforeExiting
    mov [rbp-8], eax

    ;; set line counter = 0
    mov [rbp-16], dword 1

mainLoop:

    ;;calculate digit count of line counter
    xor rdi, rdi
    mov edi, dword [rbp - 16]
    call digitCount
    mov r13, rax
    inc rax ;; leave space for ' '

;           rdi - file fd
;           rsi - rez buffer
;           rdx - maxLength
    xor rdi, rdi
    mov edi, dword [rbp-4]
    mov rsi, rbp
    sub rsi, 276
    add rsi, rax ; space for line number
    mov rdx, MAX_INPUT_BUFFER
    sub rdx, rax
    call readLine ;; << -----------------

    mov [rbp-20], eax
    add [rbp-20], dword r13d
    jo errorOverflown
    cmp eax, 0
    jz eofReached


    ;; append '\n' to output line
    mov rdi, rbp
    sub rdi, 276
    xor rcx, rcx
    mov ecx, dword [rbp-20] ; input line length including '\0'
    add rdi, rcx
    mov [rdi], byte 10
    inc dword [rbp-20]      ; input line added space for '\n'

    mov ecx, MAX_INPUT_BUFFER
    cmp ecx, dword [rbp-20]
    jl correctClose
    inc rdi
    mov [rdi], byte 0


    ;; write digits chars to beginning of output line
    mov rcx, r13 ; digit count
    mov rdi, rbp
    sub rdi, 276
    add rdi, r13    ; place of last digit
    mov [rdi], byte ' '
    dec rdi


    mov eax, dword [rbp - 16] ; line counter
    xor edx, edx
    mov ebx, 10
numberLoop:
    div ebx
    add edx, '0'
    mov [rdi], dl
    dec rdi
    xor edx, edx
    loop numberLoop



    ;; print to file
    mov rax, 1
    xor rdi, rdi
    mov edi, [rbp-8]
    mov rsi, rbp
    sub rsi, 276
    xor rdx, rdx
    mov edx, [rbp-20]
    syscall

    inc dword [rbp - 16] ;; increase line counter
    cmp rax, 0 ;; checking write byte count
    jg mainLoop

correctClose:
eofReached:
    mov rax, 3
    mov rdi, [rbp-4]
    syscall
closeSourceBeforeExiting: ;; counldn't create output file close input
    mov rax, 3
    mov rdi, [rbp-4]
    syscall
    jmp exit
couldNotOpenSourceFile: ;; couln't open first file
    jmp exit

errorOverflown:
    call printErrorOverflown
    jmp exit
usage:
    call printUsage
exit:
    pop r13
    pop r12
    mov rsp, rbp
    pop rbp

    mov eax, 60
    mov rdi, 0
    syscall
