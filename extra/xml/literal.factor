USING: peg peg.ebnf kernel strings sequences combinators.lib ;
IN: xml.literal

! EBNF-based XML generation syntax
! This is a terrible grammar for XML, only suitable for literals like this

: &ident ( -- parser )
    [ {
        [ printable? ]
        [ blank? not ]
        [ "<>" member? not ]
    } <-&& ] satisfy ;

: make-name ( str/3array -- name )
    dup array? [ first3 nip f <name> ] [ name-tag ] if ; 

<EBNF
&name = ident | ident ':' ident => make-name
EBNF>
