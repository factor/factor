! Copyright (C) 2016 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs hashtables io io.encodings.utf8 io.files
io.streams.string json kernel math namespaces sequences strings
;
IN: json.prettyprint

<PRIVATE
SYMBOL: indent-level
CONSTANT: nspaces 2

GENERIC: pprint-json* ( obj -- )

: write-spaces ( -- )
    indent-level get 0 > [
        indent-level get nspaces *
        CHAR: \s
        <string> write
    ] when ;

M: object pprint-json* write-json ;
M: string pprint-json* write-json ;
M: f pprint-json* write-json ;

M: sequence pprint-json*
    [
        "[ ]" write
    ] [
        "[" print
        indent-level inc
        [ "," print ] [ write-spaces pprint-json* ] interleave  nl
        indent-level dec
        write-spaces "]" write
    ] if-empty ;

M: assoc pprint-json*
    dup assoc-empty? [
        drop "{ }" write
    ] [
        "{" print
        indent-level inc
        >alist
        [ "," print ] [
            first2 [ write-spaces pprint-json* ": " write ] [ pprint-json* ] bi*
        ] interleave nl
        indent-level dec
        write-spaces "}" write
    ] if ;

PRIVATE>

: pprint-json ( obj -- )
    [ 0 indent-level ] dip '[ _ pprint-json* ] with-variable ;

: pprint-json>path ( json path -- ) utf8 [ pprint-json ] with-file-writer ;
: pprint-json>string ( json -- string ) [ pprint-json ] with-string-writer ;
: pprint-json-file ( path -- ) [ path>json ] [ pprint-json>path ] bi ;
