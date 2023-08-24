! Copyright (C) 2019 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel random strings ;
IN: random.passwords

ABOUT: "random.passwords"

ARTICLE: "random.passwords" "Generating random passwords"
"The " { $vocab-link "random.passwords" } " vocab provides functions for generation of random passwords."
$nl
"Generate password of a given length from some often used character sets:"
{ $subsections alnum-password hex-password ascii-password }
"Generate a password from a custom character set:"
{ $subsections password }
;

HELP: password
{ $values
    { "n" "password length" }
    { "charset" string }
    { "string" string }
}
{ $description "Generate a password of length " { $snippet "n" } " by randomly selecting characters from the " { $snippet "charset" } " string. All characters of the " { $snippet "charset" } " have equal probability of appearing at any position of the result."
$nl
"If " { $snippet "n" } " = 0, return empty string. If " { $snippet "n" } " < 0, throw an error."
$nl
{ $link secure-random-generator } " is used as the randomness source." } ;

HELP: alnum-password
{ $values
    { "n" "password length" }
    { "string" string }
}
{ $description "Generate a random password consisting of " { $snippet "n" } " alphanumeric characters (0..9, A..Z, a..z)." } ;

HELP: ascii-password
{ $values
    { "n" "password length" }
    { "string" string }
}
{ $description "Generate a random password consisting of " { $snippet "n" } " printable ASCII characters." } ;

HELP: hex-password
{ $values
    { "n" "password length" }
    { "string" string }
}
{ $description "Generate a random password consisting of " { $snippet "n" } " hexadecimal characters (0..9, A..F)." } ;
