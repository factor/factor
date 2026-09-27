! Copyright (C) 2026 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: help.markup help.syntax kernel math sequences strings ;
IN: sqids

ABOUT: "sqids"

ARTICLE: "sqids" "Sqids: encode numbers into short, unique, URL-safe IDs"
"The " { $vocab-link "sqids" } " vocabulary encodes sequences of non-negative integers into short strings and decodes them back. The default alphabet produces URL-safe IDs; custom alphabets determine their own output characters. See " { $url "https://sqids.org" } " for more information."
$nl
"Creating an encoder:"
{ $subsections <default-sqids> <sqids> }
"Encoding and decoding:"
{ $subsections sqids-encode sqids-decode }
"Defaults used by " { $link <default-sqids> } ":"
{ $subsections default-alphabet default-min-length default-blocklist } ;

HELP: <default-sqids>
{ $values { "sqids" "a sqids encoder" } }
{ $description "Returns a sqids encoder configured with " { $link default-alphabet } ", " { $link default-min-length } ", and " { $link default-blocklist } "." } ;

HELP: <sqids>
{ $values
    { "alphabet" string }
    { "min-length" "an integer from 0 to 255" }
    { "blocklist" sequence }
    { "sqids" "a sqids encoder" }
}
{ $description "Builds a sqids encoder with the given configuration. The alphabet must contain at least three unique ASCII characters and is shuffled deterministically. The blocklist replaces the default and is filtered to contain only words of at least three characters that occur in the alphabet, ignoring case. Words are lowercased and duplicates removed." }
{ $errors { $subsections alphabet-multibyte-char alphabet-too-short alphabet-duplicate-chars invalid-min-length } } ;

HELP: sqids-encode
{ $values { "sqids" "a sqids encoder" } { "numbers" sequence } { "str" string } }
{ $description "Encodes a sequence of non-negative integers into an ID. Factor integers have no upper limit. Empty input produces an empty string, regardless of the minimum length. Otherwise, the minimum length controls padding and never truncates the encoded numbers. If the ID matches the blocklist, encoding retries with a different offset." }
{ $errors { $subsections number-out-of-range max-attempts-reached } } ;

HELP: sqids-decode
{ $values { "sqids" "a sqids encoder" } { "id" string } { "numbers" sequence } }
{ $description "Decodes an ID back into the original sequence of non-negative integers, using the same alphabet as the encoder. Returns an empty sequence if the ID is empty or contains a character not in the encoder's alphabet. Decoding does not enforce the blocklist or minimum length, and multiple IDs can decode to the same numbers. Re-encode the result and compare it with the original ID to check whether it is canonical for the current configuration." } ;

HELP: default-alphabet
{ $var-description "The default 62-character URL-safe alphabet (lowercase, uppercase, digits)." } ;

HELP: default-min-length
{ $var-description "The default minimum ID length (" { $snippet "0" } ")." } ;

HELP: default-blocklist
{ $var-description "The default blocklist, matched without regard to case. Three-character words must match the entire ID. Longer words containing digits match only at the beginning or end; other longer words match anywhere in the ID." } ;

HELP: alphabet-multibyte-char
{ $error-description "Thrown by " { $link <sqids> } " when the alphabet contains a character outside of 7-bit ASCII." } ;

HELP: alphabet-too-short
{ $error-description "Thrown by " { $link <sqids> } " when the alphabet has fewer than 3 characters." } ;

HELP: alphabet-duplicate-chars
{ $error-description "Thrown by " { $link <sqids> } " when the alphabet contains duplicate characters." } ;

HELP: invalid-min-length
{ $error-description "Thrown by " { $link <sqids> } " when the min-length argument is not an integer between 0 and 255." } ;

HELP: number-out-of-range
{ $error-description "Thrown by " { $link sqids-encode } " when an input is not a non-negative integer. The error records the offending value." } ;

HELP: max-attempts-reached
{ $error-description "Thrown by " { $link sqids-encode } " when the blocklist forces more re-generation attempts than the alphabet length allows." } ;
