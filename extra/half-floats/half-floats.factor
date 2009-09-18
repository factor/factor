! (c)2009 Joe Groff bsd license
USING: accessors alien.c-types alien.data alien.syntax kernel math math.order ;
IN: half-floats

: half>bits ( float -- bits )
    float>bits
    [ -31 shift 15 shift ] [
        HEX: 7fffffff bitand
        dup zero? [
            dup HEX: 7f800000 >= [ -13 shift HEX: 7fff bitand ] [
                -13 shift
                112 10 shift -
                0 HEX: 7c00 clamp
            ] if
        ] unless
    ] bi bitor ;

: bits>half ( bits -- float )
    [ -15 shift 31 shift ] [
        HEX: 7fff bitand
        dup zero? [
            dup HEX: 7c00 >= [ 13 shift HEX: 7f800000 bitor ] [
                13 shift
                112 23 shift + 
            ] if
        ] unless
    ] bi bitor bits>float ;

C-STRUCT: half { "ushort" "(bits)" } ;

<<

"half" c-type
    [ half>bits <ushort> ] >>unboxer-quot
    [ *ushort bits>half ] >>boxer-quot
    drop

>>
