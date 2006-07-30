USING: io kernel math namespaces prettyprint sequences strings ;
IN: hexdump-internals
	
: .header ( len -- )
    "Length: " write dup unparse write ", " write >hex write "h" write terpri ;

: .offset ( lineno -- ) 16 * >hex 8 CHAR: 0 pad-left write "h: " write ;
: .h-pad ( digit -- ) >hex 2 CHAR: 0 pad-left write ;
: .line ( str n -- )
    .offset [ [ .h-pad " " write ] each ] keep
    16 over length - [ "   " write ] times
    [ dup printable? [ drop CHAR: . ] unless ch>string write ] each
    terpri ;

IN: hexdump
: hexdump ( str -- str )
    #! Write hexdump to a string
    [
        dup length .header
        16 group dup length [ .line ] 2each
    ] string-out ;

: .hexdump ( str -- )
    #! Print hexdump
    hexdump write ;

