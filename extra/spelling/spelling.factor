! Copyright (C) 2010 John Benediktsson
! See https://factorcode.org/license.txt for BSD license
USING: arrays ascii assocs combinators combinators.smart
http.download io.encodings.ascii io.files io.files.temp kernel
math math.statistics ranges sequences sequences.private sorting
splitting urls ;
IN: spelling

! https://norvig.com/spell-correct.html

CONSTANT: ALPHABET "abcdefghijklmnopqrstuvwxyz"

: deletes ( word -- edits )
    [ length <iota> ] keep '[ _ remove-nth ] map ;

: transposes ( word -- edits )
    [ length [1..b) ] keep
    '[ dup 1 - _ clone [ exchange-unsafe ] keep ] map ;

: replace1 ( i word -- words )
    [ ALPHABET ] 2dip bounds-check
    '[ _ _ clone [ set-nth-unsafe ] keep ] { } map-as ;

: replaces ( word -- edits )
    [ length <iota> ] keep '[ _ replace1 ] map concat ;

: inserts ( word -- edits )
    [ length [0..b] ] keep
    '[ CHAR: ? over _ insert-nth replace1 ] map concat ;

: edits1 ( word -- edits )
    [
        {
            [ deletes ]
            [ transposes ]
            [ replaces ]
            [ inserts ]
        } cleave
    ] append-outputs ;

: edits2 ( word -- edits )
    edits1 [ edits1 ] map concat ;

: filter-known ( edits dictionary -- words )
    '[ _ key? ] filter ;

:: corrections ( word dictionary -- words )
    word 1array dictionary filter-known
    [ word edits1 dictionary filter-known ] when-empty
    [ word edits2 dictionary filter-known ] when-empty
    [ dictionary at ] sort-by reverse! ;

: words ( string -- words )
    >lower [ letter? not ] split-when harvest ;

: load-dictionary ( file -- assoc )
    ascii file-contents words histogram ;

MEMO: default-dictionary ( -- counts )
    URL" https://norvig.com/big.txt" "big.txt" temp-file
    download-to load-dictionary ;

: (correct) ( word dictionary -- word/f )
    corrections ?first ;

: correct ( word -- word/f )
    default-dictionary (correct) ;
