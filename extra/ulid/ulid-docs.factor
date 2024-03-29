! Copyright (C) 2019 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: byte-arrays help.markup help.syntax kernel math strings
ulid.private ;
IN: ulid

ABOUT: "ulid"

ARTICLE: "ulid" "Universally Unique Lexicographically Sortable Identifier"
"The " { $vocab-link "ulid" } " vocab implements the Universally Unique Lexicographically Sortable Identifier gereration according to the specification: " { $url "https://github.com/ulid/spec" } ". The main word to call is:"
{ $subsections ulid }
"Binary convertion interface:"
{ $subsections ulid>bytes bytes>ulid }
"Helpers:"
{ $subsections normalize-ulid }
;

HELP: bytes>ulid
{ $values
    { "byte-array" byte-array }
    { "ulid" string }
}
{ $description "Convert a binary ULID to its string representation using the Crockford's base32 " { $link encoding } ". The " { $snippet "byte-array" } " must be exactly 16 bytes long, the resulting " { $snippet "ulid" } " string is always 26 characters long." }
{ $errors { $subsections bytes>ulid-bad-length } } ;

HELP: bytes>ulid-bad-length
{ $values
    { "n" number }
}
{ $description "Throws a " { $link bytes>ulid-bad-length } " error." }
{ $error-description "This error is thrown if the input array for the " { $link bytes>ulid } " conversion has length " { $snippet "n" } " instead of 16." } ;

HELP: normalize-ulid
{ $values
    { "str" string }
    { "str'" string }
}
{ $description "Convert the " { $snippet "str" } " to upper-case and substitute some ambiguous characters according to the Crockford's convention: \"L\" and \"I\" -> \"1\", \"O\" -> \"0\". This may be useful to run on a user-provided string to make sure it was typed in correctly. Subsequent " { $link ulid>bytes } " conversion could be used to make sure the decoded contents constitute a valid ULID." } ;

HELP: ulid
{ $values
    { "ulid" string }
}
{ $description "Generate a new 128-bit ULID using and return its string representation in the Crockford's base32 " { $link encoding } ". The current system time is encoded in the high 48 bits as the Unix time in milliseconds, the low 80 bits are random."
$nl
"At the time of this writing the Factor implementation is not able to produce multiple ULIDs within less than one millisecond of each other, but a provision is made to make sure that if that ever happens in the future, the subsequent ULIDs inside of a millisecond will be an increment of the previous ones to guarentee the sorting order of the identifiers, as per the specification." }
{ $errors "In case an overflow happens during such incrementing, the " { $link ulid-overflow } " error will be thrown." } ;

HELP: ulid-overflow
{ $description "Throws an " { $link ulid-overflow } " error." }
{ $error-description "This error is thrown if by chance the 80-bit random number generated by the " { $link ulid } " word matches " { $link 80-bits } ", and a new ULID is requested " { $strong "within the same millisecond." } " In this case the specification requires an error to be thrown, because it was not possible to produce two ULIDs, while guarenteeing their sorting order. The best course of action is to retry ULID generation when the next millisecond is on the system clock." } ;

HELP: ulid>bytes
{ $values
    { "ulid" string }
    { "byte-array" byte-array }
}
{ $description "Convert a string " { $snippet "ulid" } " into its binary representation." }
{ $errors { $subsections ulid>bytes-bad-length ulid>bytes-bad-character ulid>bytes-overflow } } ;

HELP: ulid>bytes-bad-character
{ $values
    { "ch" "a character" }
}
{ $description "Throws a " { $link ulid>bytes-bad-character } " error." }
{ $error-description "This error is thrown if during ULID to byte-array conversion a character " { $snippet "ch" } " is encountered in the input string, which is not part of the supported " { $link encoding } ". Try using " { $link normalize-ulid } " before the conversion." } ;

HELP: ulid>bytes-bad-length
{ $values
    { "n" number }
}
{ $description "Throws a " { $link ulid>bytes-bad-length } " error." }
{ $error-description "This error is thrown if the input string has length " { $snippet "n" } " instead of 26." } ;

HELP: ulid>bytes-overflow
{ $description "Throws a " { $link ulid>bytes-overflow } " error." }
{ $error-description "This error is thrown if the first character of the ULID string is greater than \"7\" in the " { $link encoding } ". This can only mean that the input string is not a valid ULID according to the specification." } ;
