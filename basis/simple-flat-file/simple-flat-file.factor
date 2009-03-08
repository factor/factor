! Copyright (C) 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: sequences splitting kernel math.parser io.files io.encodings.ascii biassocs ;
IN: simple-flat-file

: drop-comments ( seq -- newseq )
    [ "#" split1 drop ] map harvest ;

: split-column ( line -- columns )
    " \t" split harvest 2 head ;

: parse-hex ( s -- n )
    2 short tail hex> ;

: parse-line ( line -- code-unicode )
    split-column [ parse-hex ] map ;

: process-codetable-lines ( lines -- assoc )
    drop-comments [ parse-line ] map ; 

: flat-file>biassoc ( filename -- biassoc )
    ascii file-lines process-codetable-lines >biassoc ;

