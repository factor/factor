USING: accessors arrays variants combinators io.styles
kernel math parser sequences fry ;
IN: fonts.syntax

VARIANT: fontname serif monospace ;

: install ( object quot -- quot/? ) over [ curry ] [ 2drop [ ] ] if ;

: >>name* ( object fontname -- object ) name>> >>name ;

SYNTAX: FONT: \ ; parse-until {
    [ [ number? ] find nip [ >>size ] install ]
    [ [ italic = ] find nip [ >>italic? ] install ]
    [ [ bold = ] find nip [ >>bold? ] install ]
    [ [ fontname? ] find nip [ >>name* ] install ]
} cleave 4array concat '[ dup font>> @ drop ] append! ;
