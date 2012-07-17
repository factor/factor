! Copyright (C) 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: sequences splitting kernel math.parser io.files io.encodings.utf8
biassocs ascii namespaces arrays make assocs interval-maps sets ;
IN: simple-flat-file

: drop-comments ( seq -- newseq )
    [ "#@" split1 drop ] map harvest ;

: split-column ( line -- columns )
    " \t" split harvest 2 short head 2 f pad-tail ;

: parse-hex ( s -- n )
    dup [
        "0x" ?head [ "U+" ?head [ "Missing 0x or U+" throw ] unless ] unless
        hex>
    ] when ;

: parse-line ( line -- code-unicode )
    split-column [ parse-hex ] map ;

: process-codetable-lines ( lines -- assoc )
    drop-comments [ parse-line ] map ; 

: flat-file>biassoc ( filename -- biassoc )
    utf8 file-lines process-codetable-lines >biassoc ;

: split-; ( line -- array )
    ";" split [ [ blank? ] trim ] map ;

: data ( filename -- data )
    utf8 file-lines drop-comments [ split-; ] map ;

SYMBOL: interned

: range, ( value key -- )
    swap interned get
    [ = ] with find nip 2array , ;

: expand-ranges ( assoc -- interval-map )
    [
        [
            swap CHAR: . over member? [
                ".." split1 [ hex> ] bi@ 2array
            ] [ hex> ] if range,
        ] assoc-each
    ] { } make <interval-map> ;

: process-interval-file ( ranges -- table )
    dup values members interned
    [ expand-ranges ] with-variable ;

: load-interval-file ( filename -- table )
    data process-interval-file ;
