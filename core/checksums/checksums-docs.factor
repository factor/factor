USING: byte-arrays help.markup help.syntax ;
IN: checksums

HELP: checksum
{ $class-description "The class of checksum algorithms." } ;

HELP: checksum-stream
{ $values { "stream" "an input stream" } { "checksum" "a checksum specifier" } { "value" byte-array } }
{ $contract "Computes the checksum of all data read from the stream." }
{ $side-effects "stream" } ;

HELP: checksum-bytes
{ $values { "bytes" "a sequence of bytes" } { "checksum" "a checksum specifier" } { "value" byte-array } }
{ $contract "Computes the checksum of all data in a sequence." }
{ $examples
    { $example
        "USING: checksums checksums.crc32 prettyprint ;"
        "B{ 1 10 100 } crc32 checksum-bytes ."
        "B{ 78 179 254 238 }"
    }
} ;

HELP: checksum-lines
{ $values { "lines" "a sequence of sequences of bytes" } { "checksum" "a checksum specifier" } { "value" byte-array } }
{ $contract "Computes the checksum of all data in a sequence." }
{ $examples
    { $example
        "USING: checksums checksums.crc32 prettyprint ;"
"{
    \"Take me out to the ball game\"
    \"Take me out with the crowd\"
} crc32 checksum-lines ."
        "B{ 111 205 9 27 }"
    }
} ;

HELP: checksum-file
{ $values { "path" "a pathname specifier" } { "checksum" "a checksum specifier" } { "value" byte-array } }
{ $description "Computes the checksum of all data in a file." }
{ $examples
    { $unchecked-example
        ! This example fails on Windows if you ``git clone`` with Windows line-endings
        ! Issue #2276
        "USING: checksums checksums.crc32 prettyprint ;"
        "\"resource:core/checksums/crc32/crc-me.txt\" crc32 checksum-file ."
        "B{ 196 202 117 155 }"
    }
} ;

ARTICLE: "checksums" "Checksums"
"A " { $emphasis "checksum" } " is a function mapping sequences of bytes to fixed-length strings. While checksums are not one-to-one, a good checksum should have a low probability of collision. Additionally, some checksum algorithms are designed to be hard to reverse, in the sense that finding an input string which hashes to a given checksum string requires a brute-force search."
$nl
"Checksums are instances of a class:"
{ $subsections checksum }
"Operations on checksums:"
{ $subsections
    checksum-bytes
    checksum-stream
    checksum-lines
    checksum-file
}
"Checksums should implement at least one of " { $link checksum-bytes } " and " { $link checksum-stream } ". Implementing " { $link checksum-lines } " is optional."
$nl
"Checksums can also implement a stateful checksum protocol that allows users to push bytes when needed and then at a later point request the checksum value. The default implementation is not very efficient, storing all of the bytes and then calling " { $link checksum-bytes } " when " { $link get-checksum } " is requested."
$nl
{ $subsections
    initialize-checksum-state
    add-checksum-bytes
    add-checksum-stream
    add-checksum-lines
    add-checksum-file
    get-checksum
}
"Checksum implementations:"
{ $vocab-subsections
    { "CRC32 checksum" "checksums.crc32" }
    { "MD5 checksum" "checksums.md5" }
    { "SHA checksums" "checksums.sha" }
    { "Adler-32 checksum" "checksums.adler-32" }
    { "OpenSSL checksums" "checksums.openssl" }
    { "Internet checksum" "checksums.internet" }
    { "Checksum using an external utility" "checksums.process" }
} ;

ABOUT: "checksums"
