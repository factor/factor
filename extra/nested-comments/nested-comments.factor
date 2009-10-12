! Copyright (C) 2009 blei, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences math locals make multiline ;
IN: nested-comments

: (count-subsequences) ( count substring string n -- count' )
    [ 2dup ] dip start* [
        pick length +
        [ 1 + ] 3dip (count-subsequences)
    ] [
        2drop
    ] if* ;

: count-subsequences ( subseq seq -- n )
    [ 0 ] 2dip 0 (count-subsequences) ;

: parse-nestable-comment ( parsed-vector left-to-parse -- parsed-vector )
    1 - "*)" parse-multiline-string
    [ "(*" ] dip
    count-subsequences + dup 0 > [ parse-nestable-comment ] [ drop ] if ;

SYNTAX: (* 1 parse-nestable-comment ;
