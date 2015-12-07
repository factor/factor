USING: accessors arrays combinators fry kernel layouts math
math.bitwise sequences ;
IN: tools.image-analyzer.ref-fixer
QUALIFIED-WITH: tools.image-analyzer.vm vm

: update-ref ( val rel-base -- val' )
    [ 15 unmask ] dip - ;

: update-data-ref ( val rel-base -- val' )
    over 1 = [ 2drop 1 ] [ update-ref ] if ;

: update-ep-ref ( val rel-base -- val' )
    update-ref 4 cell * - ;


GENERIC# fix-data-reference 1 ( struct rel-base -- )

M: vm:word fix-data-reference ( word rel-base -- )
    '[ _ update-data-ref ]
    {
        [ change-name drop ]
        [ change-vocabulary drop ]
        [ change-def drop ]
        [ change-props drop ]
    } 2cleave ;

M: vm:code-block fix-data-reference ( quotation rel-base -- )
    '[ _ update-data-ref ]
    [ change-owner drop ]
    [ change-relocation drop ]
    [ change-parameters drop ] 2tri ;

M: object fix-data-reference ( object rel-base -- )
    2drop ;

: fix-data-references ( heap-nodes rel-base -- )
    '[ object>> _ fix-data-reference ] each ;

GENERIC# fix-code-reference 1 ( struct rel-base -- )

M: vm:word fix-code-reference ( word rel-base -- )
    '[ _ update-ep-ref ] change-entry_point drop ;

M: vm:quotation fix-code-reference ( quotation rel-base -- )
    '[ _ update-ep-ref ] change-entry_point drop ;

M: object fix-code-reference ( object rel-base -- )
    2drop ;

CONSTANT: code-heap-shift 65536

: shift-code-addresses ( heap-nodes -- )
    [ dup object>> vm:code-block? [
        [ code-heap-shift + ] change-address ] when drop
    ] each ;

: shift-code-heap ( heap-nodes header -- )
    [ shift-code-addresses ] [
        [ code-heap-shift - ] change-code-relocation-base drop
    ] bi* ;

: fix-code-references ( heap-nodes rel-base -- )
    '[ object>> _ fix-code-reference ] each ;

: fix-references ( heap-nodes header -- )
    2dup shift-code-heap
    [ data-relocation-base>> fix-data-references ]
    [ code-relocation-base>> fix-code-references ] 2bi ;
