USING: accessors arrays classes.algebraic combinators io.styles
kernel math parser sequences fry ;
IN: fonts.syntax

DATA: fontname serif | monospace ;

: install ( object quot -- quot/? ) over [ curry ] [ 2drop [ ] ] if ;

: >>name* ( object fontname -- object ) name>> >>name ;

SYNTAX: FONT: \ ; parse-until {
    [ [ number? ] find nip [ >>size ] install ]
    [ [ italic = ] find nip [ >>italic? ] install ]
    [ [ bold = ] find nip [ >>bold? ] install ]
    [ [ fontname? ] find nip [ >>name* ] install ]
} cleave 4array concat '[ dup font>> @ drop ] over push-all ;
