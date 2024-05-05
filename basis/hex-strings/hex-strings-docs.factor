! Copyright (C) 2024 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: byte-arrays help.markup help.syntax kernel sequences
strings ;
IN: hex-strings

HELP: hex-digit?
{ $values
    { "ch" "a character" }
    { "?" boolean }
}
{ $description "Checks if a digit is in hexadecimal format, e.g. a-f A-F and 0-9" }
{ $examples
    { $example "USING: hex-strings prettyprint ;" "CHAR: a hex-digit? ." "t" }
    { $example "USING: hex-strings prettyprint ;" "CHAR: z hex-digit? ." "f" }
} ;

HELP: hex-string?
{ $values
    { "str" string }
    { "?" boolean }
}
{ $description "Tests if a string is a valid hexadecimal string." }
{ $examples
    { $example "USING: hex-strings prettyprint ;" "\"abcdef\" hex-string? ." "t" }
    { $example "USING: hex-strings prettyprint ;" "\"meow\" hex-string? ." "f" }
} ;

HELP: bytes>hex-string
{ $values { "bytes" sequence } { "hex-string" string } }
{ $description "Converts a sequence of bytes (integers in the range [0,255]) to a string of hex numbers in the range [00,ff]." }
{ $examples
    { $example "USING: hex-strings prettyprint ;" "B{ 1 2 3 4 } bytes>hex-string ." "\"01020304\"" }
}
{ $notes "Numbers are zero-padded on the left." } ;

HELP: hex-string>bytes
{ $values { "hex-string" sequence } { "bytes" byte-array } }
{ $description "Converts a sequence of hex numbers in the range [00,ff] to a sequence of bytes (integers in the range [0,255])." }
{ $examples
    { $example "USING: hex-strings prettyprint ;" "\"cafebabe\" hex-string>bytes ." "B{ 202 254 186 190 }" }
} ;

{ bytes>hex-string hex-string>bytes } related-words

ARTICLE: "hex-strings" "Hex Strings"
"The " { $vocab-link "hex-strings" } " vocabulary provides words for converting between byte sequences and hexadecimal strings. It also provides predicate words for checking if a string is a valid hexadecimal string for various checksums." $nl
"Converting between byte sequences and hexadecimal strings:"
{ $subsections
    bytes>hex-string
    hex-string>bytes
}
"Check if a string is a known checksum hex string:"
{ $subsections
    md5-string? 
    sha1-string?
    sha224-string?
    sha256-string?
    sha384-string?
    sha512-string?
} ;

ABOUT: "hex-strings"
