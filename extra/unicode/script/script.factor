USING: unicode.syntax.backend kernel sequences assocs io.files
io.encodings ascii math.ranges io splitting math.parser 
namespaces byte-arrays locals math sets io.encodings.ascii
words compiler.units ;
IN: unicode.script

<PRIVATE
VALUE: char>num-table
VALUE: num>name-table

: parse-script ( stream -- assoc )
    ! assoc is code point/range => name
    lines [ "#" split1 drop ] map [ empty? not ] filter [
        ";" split1 [ [ blank? ] trim ] bi@
    ] H{ } map>assoc ;

: set-if ( value var -- )
    dup 500000 < [ set ] [ 2drop ] if ;

: expand-ranges ( assoc -- char-assoc )
    ! char-assoc is code point => name
    [ [
        CHAR: . pick member? [
            swap ".." split1 [ hex> ] bi@ [a,b]
            [ set-if ] with each
        ] [ swap hex> set-if ] if
    ] assoc-each ] H{ } make-assoc ;

: hash>byte-array ( hash -- byte-array )
    [ keys supremum 1+ <byte-array> dup ] keep
    [ -rot set-nth ] with assoc-each ;

: make-char>num ( assoc -- char>num-table )
    expand-ranges
    [ num>name-table index ] assoc-map
    hash>byte-array ;

: >symbols ( strings -- symbols )
    [
        [ "unicode.script" create dup define-symbol ] map
    ] with-compilation-unit ;

: process-script ( ranges -- )
    [ values prune \ num>name-table set-value ]
    [ make-char>num \ char>num-table set-value ] bi
    num>name-table >symbols \ num>name-table set-value ;

: load-script ( -- )
    "resource:extra/unicode/script/Scripts.txt"
    ascii <file-reader> parse-script process-script ;

load-script
PRIVATE>

: script-of ( char -- script )
    char>num-table nth num>name-table nth ;
