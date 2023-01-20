! Copyright (C) 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: arrays ascii assocs biassocs interval-maps
io.encodings.utf8 io.files kernel math.parser sequences sets
splitting ;
IN: simple-flat-file

: drop-comment ( line -- line' )
    dup [ "#@" member? ] find drop [ head ] when* ;

: drop-comments ( seq -- newseq )
    [ drop-comment ] map harvest ;

: split-column ( line -- columns )
    " \t" split harvest 2 index-or-length head 2 f pad-tail ;

: parse-hex ( s -- n )
    dup [
        "0x" ?head [ "U+" ?head [ "Missing 0x or U+" throw ] unless ] unless
        hex>
    ] when ;

: parse-line ( line -- code-unicode )
    split-column [ parse-hex ] map! ;

: process-codetable-lines ( lines -- assoc )
    drop-comments [ parse-line ] map! ;

: load-codetable-file ( filename -- biassoc )
    utf8 file-lines process-codetable-lines >biassoc ;

: split-; ( line -- array )
    ";" split [ [ blank? ] trim ] map! ; inline

: load-data-file ( filename -- data )
    utf8 file-lines drop-comments [ split-; ] map! ;

: expand-range ( range -- range' )
    ".." split1 [ hex> ] bi@ [ 2array ] when* ;

: expand-ranges ( ranges -- table )
    [ [ expand-range ] dip ] assoc-map <interval-map> ;

: intern ( value values -- value' )
    [ = ] with find nip ;

: intern-values ( assoc -- assoc' )
    dup values members [ intern ] curry assoc-map ;

: load-interval-file ( filename -- table )
    load-data-file intern-values expand-ranges ;
