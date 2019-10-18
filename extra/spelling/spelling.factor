USING: arrays ascii assocs combinators combinators.smart fry
http.client io.encodings.ascii io.files io.files.temp kernel
literals locals math math.ranges math.statistics memoize
sequences sequences.private sets sorting splitting strings urls ;
IN: spelling

! http://norvig.com/spell-correct.html

CONSTANT: ALPHABET "abcdefghijklmnopqrstuvwxyz"

: deletes ( word -- edits )
    [ length <iota> ] keep '[ _ remove-nth ] map ;

: transposes ( word -- edits )
    [ length [1,b) ] keep '[
        dup 1 - _ clone [ exchange-unsafe ] keep
    ] map ;

: replaces ( word -- edits )
    [ length <iota> ] keep '[
        ALPHABET [
            swap _ clone [ set-nth-unsafe ] keep
        ] with { } map-as
    ] map concat ;

: inserts ( word -- edits )
    [ length [0,b] ] keep '[
        CHAR: ? over _ insert-nth ALPHABET swap [
            swapd clone [ set-nth-unsafe ] keep
        ] curry with { } map-as
    ] map concat ;

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
    [ dictionary at ] sort-with reverse! ;

: words ( string -- words )
    >lower [ letter? not ] split-when harvest ;

: load-dictionary ( file -- assoc )
    ascii file-contents words histogram ;

MEMO: default-dictionary ( -- counts )
    URL" http://norvig.com/big.txt" "big.txt" temp-file
    [ ?download-to ] [ load-dictionary ] bi ;

: (correct) ( word dictionary -- word/f )
    corrections ?first ;

: correct ( word -- word/f )
    default-dictionary (correct) ;
