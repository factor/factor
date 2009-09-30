USING: help.markup help.syntax kernel math sequences quotations
math.private byte-arrays strings ;
IN: checksums

HELP: checksum
{ $class-description "The class of checksum algorithms." } ;

HELP: hex-string
{ $values { "seq" "a sequence" } { "str" "a string" } }
{ $description "Converts a sequence of values from 0-255 to a string of hex numbers from 0-ff." }
{ $examples
    { $example "USING: checksums io ;" "B{ 1 2 3 4 } hex-string print" "01020304" }
}
{ $notes "Numbers are zero-padded on the left." } ;

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
"""{
    "Take me out to the ball game"
    "Take me out with the crowd"
} crc32 checksum-lines ."""
        "B{ 111 205 9 27 }"
    }
} ;

HELP: checksum-file
{ $values { "path" "a pathname specifier" } { "checksum" "a checksum specifier" } { "value" byte-array } }
{ $contract "Computes the checksum of all data in a file." }
{ $examples
    { $example
        "USING: checksums checksums.crc32 prettyprint ;"
        """"resource:license.txt" crc32 checksum-file ."""
        "B{ 100 139 199 92 }"
    }
} ;

ARTICLE: "checksums" "Checksums"
"A " { $emphasis "checksum" } " is a function mapping sequences of bytes to fixed-length strings. While checksums are not one-to-one, a good checksum should have a low probability of collision. Additionally, some checksum algorithms are designed to be hard to reverse, in the sense that finding an input string which hashes to a given checksum string requires a brute-force search."
$nl
"Checksums are instances of a class:"
{ $subsection checksum }
"Operations on checksums:"
{ $subsection checksum-bytes }
{ $subsection checksum-stream }
{ $subsection checksum-lines }
"Checksums should implement at least one of " { $link checksum-bytes } " and " { $link checksum-stream } ". Implementing " { $link checksum-lines } " is optional."
$nl
"Utilities:"
{ $subsection checksum-file }
{ $subsection hex-string }
"Checksum implementations:"
{ $subsection "checksums.crc32" }
{ $vocab-subsection "MD5 checksum" "checksums.md5" }
{ $vocab-subsection "SHA checksums" "checksums.sha" }
{ $vocab-subsection "Adler-32 checksum" "checksums.adler-32" }
{ $vocab-subsection "OpenSSL checksums" "checksums.openssl" } ;

ABOUT: "checksums"
