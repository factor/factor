! Copyright (C) 2026 Zoltán Kéri <z@zolk3ri.name>
! See https://factorcode.org/license.txt for BSD license.

USING: help.markup help.syntax byte-arrays ;
IN: crypto.poly1305

ARTICLE: "crypto.poly1305" "Poly1305 message authentication code"
"Poly1305 is a message authentication code (MAC) designed by Daniel J. Bernstein and specified in RFC 8439. It provides strong authentication guarantees when used with a unique, unpredictable 32-byte key per message."
$nl
"Poly1305 is typically paired with ChaCha20, as in the ChaCha20-Poly1305 AEAD construction defined in RFC 8439. The pairing is used in TLS 1.3, WireGuard, and SSH."
$nl
"This implementation follows RFC 8439. It evaluates the message as a polynomial modulo the prime 2^130-5 over 16-byte blocks and produces a 128-bit (16-byte) authentication tag."
$nl
{ $heading "Security notes" }
{ $list
  { "The 32-byte key MUST be unique and unpredictable for each message. Two messages authenticated with the same key are enough for an attacker to recover the key and forge tags." }
  { "Poly1305 authenticates but does not encrypt. For authenticated encryption, use an AEAD construction like ChaCha20-Poly1305." }
  { "Tag verification compares tags in constant time. The tag computation uses bignum arithmetic, which is not constant-time, so it can leak timing information about the key (see RFC 8439 Sections 3 and 4)." }
}
$nl
{ $subheading "Computing MACs" }
{ $subsections poly1305-mac }
{ $subheading "Verifying MACs" }
{ $subsections poly1305-verify }
{ $heading "Further reading" }
{ $url "https://cr.yp.to/mac.html" } $nl
{ $url "https://www.rfc-editor.org/rfc/rfc8439.html" } ;

HELP: poly1305-mac
{ $values
  { "message" byte-array }
  { "key" "32-byte one-time key" }
  { "tag" "16-byte authentication tag" }
}
{ $description "Computes a Poly1305 authentication tag for the given message using a 32-byte one-time key. The key is split into two 16-byte parts: 'r' (clamped per RFC 8439) and 's'." }
{ $warning "The key MUST be unique for each message. Never reuse a Poly1305 key." }
{ $examples
  { $unchecked-example
    "USING: byte-arrays crypto.poly1305 ;"
    "\"Hello\" >byte-array"
    "B{ 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16"
    "   17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 }"
    "poly1305-mac"
    "! => B{ 205 107 36 196 87 50 35 27 200 16 3 251 167 240 226 90 }"
  }
} ;

HELP: poly1305-verify
{ $values
  { "message" byte-array }
  { "key" "32-byte one-time key" }
  { "expected-tag" "16-byte expected tag" }
  { "?" "t if the tag matches, f otherwise" }
}
{ $description "Verifies that the expected tag matches the computed Poly1305 tag for the message and key. The comparison is constant-time, and a tag of the wrong length never matches. Returns " { $link t } " if the tag is valid, " { $link f } " otherwise." }
{ $examples
  { $example
    "USING: byte-arrays crypto.poly1305 prettyprint ;"
    "\"Hello\" >byte-array"
    "B{ 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16"
    "   17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 }"
    "B{ 205 107 36 196 87 50 35 27 200 16 3 251 167 240 226 90 }"
    "poly1305-verify ."
    "t"
  }
} ;

ABOUT: "crypto.poly1305"
