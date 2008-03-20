USING: sequences kernel namespaces splitting math ;
IN: wrap

! Very stupid word wrapping/line breaking
! This will be replaced by a Unicode-aware method,
! which works with variable-width fonts

SYMBOL: width

: line-chunks ( string -- words-lines )
    "\n" split [ " \t" split [ empty? not ] subset ] map ;

: (split-chunk) ( words -- )
    -1 over [ length + 1+ dup width get > ] find drop nip
    [ 1 max cut-slice swap , (split-chunk) ] [ , ] if* ;

: split-chunk ( words -- lines )
    [ (split-chunk) ] { } make ;

: join-spaces ( words-seqs -- lines )
    [ [ " " join ] map ] map concat ;

: broken-lines ( string width -- lines )
    width [
        line-chunks [ split-chunk ] map join-spaces
    ] with-variable ;

: line-break ( string width -- newstring )
    broken-lines "\n" join ;

: indented-break ( string width indent -- newstring )
    [ length - broken-lines ] keep [ prepend ] curry map "\n" join ;
