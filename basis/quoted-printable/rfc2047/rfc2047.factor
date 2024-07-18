! Copyright (C) 2024 Alex Maestas.
! See https://factorcode.org/license.txt for BSD license.
USING: ascii base64 io.encodings.iana io.encodings.strict
io.encodings.string kernel multiline peg.ebnf quoted-printable
sequences splitting ;
QUALIFIED-WITH: io.encodings.ascii a
IN: quoted-printable.rfc2047
ERROR: unrecognized-charset ;

: >strict-ascii ( bytes -- string )
    a:ascii strict decode ;

<PRIVATE

: (internet-name>charset) ( str -- enc )
    [ >upper ] [ >lower ]
    [ call name>encoding ] bi-curry@ bi
    or ;

PRIVATE>

: internet-name>charset ( str -- enc )
    (internet-name>charset)
    [ unrecognized-charset ] unless* ;

<PRIVATE

: (replace-underscores) ( bytes -- bytes )
    "_" " " replace ;

! guaranteed to either be Q or B by parser
: (decode-text) ( encoding text -- bytes )
    swap "Q" =
    [ (replace-underscores) quoted> ] [ base64> ] if ;

PRIVATE>

EBNF: rfc2047-encoded-word
[=[
     leader="=?"~
     separator="?"~
     trailer="?="~
     charset=[^? ]+ => [[ >strict-ascii internet-name>charset ]]
     encoding= "Q" | "B" | "q" | "b" => [[ >upper ]]
     text=[^? ]* => [[ >strict-ascii ]]
     token=leader charset separator encoding separator text trailer
]=]

: rfc2047> ( str -- str )
    rfc2047-encoded-word first3 (decode-text)
    swap decode ;
