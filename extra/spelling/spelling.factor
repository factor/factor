USING: arrays ascii assocs combinators combinators.smart fry
http.client io.encodings.ascii io.files io.files.temp kernel
literals locals math math.ranges math.statistics memoize
sequences sets sorting splitting strings urls ;
IN: spelling

! http://norvig.com/spell-correct.html

CONSTANT: ALPHABET $[
    "abcdefghijklmnopqrstuvwxyz" [ 1string ] { } map-as
]

: splits ( word -- splits )
    dup length [0,b] [ cut 2array ] with map ;

: deletes ( splits -- edits )
    [ second length 0 > ] filter [ first2 rest append ] map ;

: transposes ( splits -- edits )
    [ second length 1 > ] filter
    [ first2 2 cut swap reverse! glue ] map ;

: replaces ( splits -- edits )
    [ second length 0 > ] filter ALPHABET
    [ [ first2 rest ] [ glue ] bi* ] cartesian-map concat ;

: inserts ( splits -- edits )
    ALPHABET [ [ first2 ] [ glue ] bi* ] cartesian-map concat ;

: edits1 ( word -- edits )
    [
        splits {
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
    "big.txt" temp-file dup exists?
    [ URL" http://norvig.com/big.txt" over download-to ] unless
    load-dictionary ;

: (correct) ( word dictionary -- word/f )
    corrections ?first ;

: correct ( word -- word/f )
    default-dictionary (correct) ;
