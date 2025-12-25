! Copyright (C) 2025 Zoltán Kéri <z@zolk3ri.name>
! See https://factorcode.org/license.txt for BSD license.

USING: help.markup help.syntax byte-arrays strings ;
IN: crypto.chacha20

ARTICLE: "crypto.chacha20" "ChaCha20 stream cipher"
"ChaCha20 is a stream cipher designed by Daniel J. Bernstein and standardized in RFC 8439. It improves upon the earlier Salsa20 design, providing increased per-round diffusion with no cost to performance."
$nl
"ChaCha20 is lightweight and well suited to fast, constant-time software implementations. It is widely deployed in modern security protocols and systems, including TLS 1.3 (via ChaCha20-Poly1305), WireGuard, SSH, and as the basis for the CSPRNG in OpenBSD, FreeBSD, and the Linux kernel, among others."
$nl
"This implementation follows the IETF ChaCha20 variant defined in RFC 8439, using a 256-bit key, a 96-bit nonce, and a 32-bit block counter. This permits encryption of up to 256 GiB of data per key/nonce pair; exceeding this limit or reusing a nonce with the same key is insecure."
$nl
{ $heading "Security note" }
"ChaCha20 by itself provides confidentiality only and does not offer message authentication. An attacker can modify ciphertext without detection. For authenticated encryption, use an AEAD construction such as ChaCha20-Poly1305."
$nl
{ $subheading "High-level API (u32 arrays)" }
{ $subsections chacha20-crypt }
{ $subheading "Byte API (byte arrays)" }
{ $subsections chacha20-crypt-bytes }
{ $subheading "String helpers" }
{ $subsections
  chacha20-encrypt-string
  chacha20-decrypt-string
}
{ $heading "Further reading" }
{ $url "https://cr.yp.to/chacha.html" } $nl
{ $url "https://www.rfc-editor.org/rfc/rfc8439.html" } ;

HELP: chacha20-crypt
{ $values
  { "data" byte-array }
  { "key" "8 u32 values (256 bits)" }
  { "nonce" "3 u32 values (96 bits)" }
  { "counter" "starting block counter" }
  { "result" byte-array }
}
{ $description "Encrypts or decrypts data using ChaCha20. XOR is symmetric, so the same function works for both encryption and decryption." }
{ $examples
  { $unchecked-example
    "USING: byte-arrays crypto.chacha20 ;"
    "\"Hello\" >byte-array 8 0 <array> 3 0 <array> 1 chacha20-crypt"
    "8 0 <array> 3 0 <array> 1 chacha20-crypt >string"
    "! => \"Hello\""
  }
} ;

HELP: chacha20-crypt-bytes
{ $values
  { "data" byte-array }
  { "key-bytes" "32-byte array" }
  { "nonce-bytes" "12-byte array" }
  { "counter" "starting block counter" }
  { "result" byte-array }
}
{ $description "Encrypts or decrypts data using ChaCha20 with raw byte keys and nonces. Converts bytes to u32 arrays internally." }
{ $examples
  { $unchecked-example
    "USING: byte-arrays crypto.chacha20 ;"
    "\"Hello\" >byte-array 32 <byte-array> 12 <byte-array> 1 chacha20-crypt-bytes"
    "32 <byte-array> 12 <byte-array> 1 chacha20-crypt-bytes >string"
    "! => \"Hello\""
  }
} ;

HELP: chacha20-encrypt-string
{ $values
  { "string" string }
  { "key-bytes" "32-byte array" }
  { "nonce-bytes" "12-byte array" }
  { "counter" "starting block counter" }
  { "ciphertext" byte-array }
}
{ $description "Encrypts a string using ChaCha20, returning ciphertext bytes." }
{ $examples
  { $unchecked-example
    "USING: byte-arrays crypto.chacha20 ;"
    "\"Hello\" 32 <byte-array> 12 <byte-array> 1 chacha20-encrypt-string"
    "! => B{ 215 98 139 210 58 }"
  }
} ;

HELP: chacha20-decrypt-string
{ $values
  { "ciphertext" byte-array }
  { "key-bytes" "32-byte array" }
  { "nonce-bytes" "12-byte array" }
  { "counter" "starting block counter" }
  { "string" string }
}
{ $description "Decrypts ciphertext bytes using ChaCha20, returning a string." }
{ $examples
  { $unchecked-example
    "USING: byte-arrays crypto.chacha20 ;"
    "\"Hello\" 32 <byte-array> 12 <byte-array> 1 chacha20-encrypt-string"
    "32 <byte-array> 12 <byte-array> 1 chacha20-decrypt-string"
    "! => \"Hello\""
  }
} ;

ABOUT: "crypto.chacha20"
