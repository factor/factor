! by blei on #concatenative
USING: kernel sequences math locals make multiline ;
IN: nested-comments

:: (subsequences-at) ( sseq seq n -- )
    sseq seq n start*
    [ dup , sseq length + [ sseq seq ] dip (subsequences-at) ]
    when* ;

: subsequences-at ( sseq seq -- indices )
    [ 0 (subsequences-at) ] { } make ;

: count-subsequences ( sseq seq -- i )
    subsequences-at length ;

: parse-all-(* ( parsed-vector left-to-parse -- parsed-vector )
    1 - "*)" parse-multiline-string [ "(*" ] dip
    count-subsequences + dup 0 > [ parse-all-(* ] [ drop ] if ;

SYNTAX: (* 1 parse-all-(* ;