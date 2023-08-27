! Copyright (C) 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax strings byte-arrays io.encodings.string ;
IN: quoted-printable

ABOUT: "quoted-printable"

ARTICLE: "quoted-printable" "Quoted printable encoding"
"The " { $vocab-link "quoted-printable" } " vocabulary implements RFC 2045 part 6.7, providing words for reading and generating quotable printed text."
{ $subsections
    >quoted
    >quoted-lines
    quoted>
} ;

HELP: >quoted
{ $values { "byte-array" byte-array } { "string" string } }
{ $description "Encodes a byte array as quoted printable, on a single line." }
{ $warning "To encode a string in quoted printable, first use the " { $link encode } " word." } ;

HELP: >quoted-lines
{ $values { "byte-array" byte-array } { "string" string } }
{ $description "Encodes a byte array as quoted printable, with soft line breaks inserted so the output lines are no longer than 76 characters." }
{ $warning "To encode a string in quoted printable, first use the " { $link encode } " word with a specific encoding." } ;

HELP: quoted>
{ $values { "string" string } { "byte-array" byte-array } }
{ $description "Decodes a quoted printable string into an array of the bytes represented." }
{ $warning "When decoding something in quoted printable form and using it as a string, be sure to use the " { $link decode } " word rather than simply converting the byte array to a string." } ;
