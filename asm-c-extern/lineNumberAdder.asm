S_IRUSR     equ     00400q
S_IWUSR     equ     00200q
MAX_INPUT_BUFFER equ 255

section .data

extern myStringLength
extern printUsage
extern puts
extern readLine

section .text

global main
main:
    push rbp
    mov rbp, rsp

    sub rsp, 276               ; 4 - inputFd
                               ; 4 - outputFd
                               ; 8 line number
                               ; 4 - bufferLen
                               ; 256 - buffer
    push r12

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
    mov [rbp+0], eax

    ;; create desitination file
    mov rax, 85         ; create file
    mov rdi, [r12+16]
    mov rsi,  0400q | 0200q; read, write premission
    syscall
    cmp rax, 0
    jl closeSourceBeforeExiting
    mov [rbp+4], eax

    ;; set line counter = 0
    mov [rbp+8], dword 0



;           rdi - file fd
;           rsi - rez buffer
;           rdx - maxLength
    xor rdi, rdi
    mov edi, dword [rbp]
    mov rsi, rbp
    add rsi, 20
    mov rdx, MAX_INPUT_BUFFER
    call readLine
    mov [rbp+16], eax

    call readLine
    mov [rbp+16], eax

    mov rax, 1
    mov rdi, 0
    mov rsi, rbp
    add rsi, 20
    mov rdx, 7
    ;xor rdx, rdx
    ;mov edx, [rbp+16]
    syscall




    mov rax, 1
    mov rdi, [rbp+4]
    mov rsi, [rbp+20]
    mov rdx, [rbp+16]
    syscall
;   xor rbx, rbx
;   mov rdi, [rsi+rbx*8]
;   call puts
;
;   inc rbx
;   mov rdi, [rsi+rbx*8]
;   call puts
;


    ;; closing input file??
    mov rax, 3
    mov rdi, [rbp + 0]
    syscall
    ;;closing output file
    mov rax, 3
    mov rdi, [rbp + 4]
    syscall
    jmp exit
closeSourceBeforeExiting: ;; counldn't create output file close input
    mov rax, 3
    mov rdi, [rbp]
    syscall
    jmp exit
couldNotOpenSourceFile: ;; couln't open first file
    jmp exit

usage:
    call printUsage
exit:
    pop r12
    mov rsp, rbp
    pop rbp

    mov eax, 60
    mov rdi, 0
    syscall
