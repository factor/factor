USING: help.syntax help.markup strings unicode ;
IN: unicode.normalize

ABOUT: "unicode.normalize"

ARTICLE: "unicode.normalize" "Unicode normalization"
"The " { $vocab-link "unicode.normalize" } " vocabulary defines words for normalizing Unicode strings."
$nl
"In Unicode, it is often possible to have multiple sequences of characters which really represent exactly the same thing. For example, to represent e with an acute accent above, there are two possible strings: " { $snippet "\"e\\u000301\"" } " (the e character, followed by the combining acute accent character) and " { $snippet "\"\\u0000e9\"" } " (a single character, e with an acute accent)."
$nl
"There are four normalization forms: NFD, NFC, NFKD, and NFKC. Basically, in NFD and NFKD, everything is expanded, whereas in NFC and NFKC, everything is contracted. In NFKD and NFKC, more things are expanded and contracted. This is a process which loses some information, so it should be done only with care."
$nl
"Most of the world uses NFC to communicate, but for many purposes, NFD/NFKD is easier to process. For more information, see Unicode Standard Annex #15 and section 3 of the Unicode standard."
{ $subsections
    nfc
    nfd
    nfkc
    nfkd
} ;

HELP: nfc
{ $values { "string" string } { "nfc" "a string in NFC" } }
{ $description "Converts a string to Normalization Form C." } ;

HELP: nfd
{ $values { "string" string } { "nfd" "a string in NFD" } }
{ $description "Converts a string to Normalization Form D." } ;

HELP: nfkc
{ $values { "string" string } { "nfkc" "a string in NFKC" } }
{ $description "Converts a string to Normalization Form KC." } ;

HELP: nfkd
{ $values { "string" string } { "nfkd" "a string in NFKD" } }
{ $description "Converts a string to Normalization Form KD." } ;
