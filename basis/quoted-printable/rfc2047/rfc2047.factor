! Copyright (C) 2024 Alex Maestas.
! See https://factorcode.org/license.txt for BSD license.
USING: base64 io.encodings io.encodings.iana io.encodings.strict
io.encodings.string kernel multiline peg.ebnf quoted-printable
sequences splitting unicode ;
QUALIFIED-WITH: io.encodings.ascii a
IN: quoted-printable.rfc2047
ERROR: unrecognized-charset ;

: >strict-ascii ( bytes -- string )
    a:ascii strict decode ;

: internet-name>charset ( str -- enc )
    dup "iso-" head? [ >upper ] when
    name>encoding [ unrecognized-charset ] unless* ;

<PRIVATE

: (replace-underscores) ( bytes -- bytes )
    "_" " "  ! underscore is space in Q-encoding
    replace ;

! guaranteed to either be Q or B by parser
: (decode-text) ( encoding text -- bytes )
    swap "Q" = [ (replace-underscores) quoted> ] [ base64> ] if ;

PRIVATE>

EBNF: rfc2047-encoded-word
[=[
     leader="=?"~
     separator="?"~
     trailer="?="~
     charset=[^? ]+ => [[ >strict-ascii internet-name>charset ]]
     encoding= "Q" | "B"
     text=[^? ]* => [[ >strict-ascii ]]
     token=leader charset separator encoding separator text trailer
]=]

: rfc2047> ( str -- str )
    rfc2047-encoded-word first3 (decode-text)
    swap decode ;
