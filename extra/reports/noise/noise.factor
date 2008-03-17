USING: assocs math kernel shuffle combinators.lib
words quotations arrays combinators sequences math.vectors
io.styles combinators.cleave prettyprint vocabs sorting io
generic locals.private ;
IN: reports.noise

: badness ( word -- n )
    H{
        { -nrot 5 }
        { -roll 4 }
        { -rot 3 }
        { 2apply 1 }
        { 2curry 1 }
        { 2drop 1 }
        { 2dup 2 }
        { 2keep 2 }
        { 2nip 3 }
        { 2over 4 }
        { 2slip 2 }
        { 2swap 3 }
        { 2with 2 }
        { 2with* 3 }
        { 3apply 1/2 }
        { 3curry 2 }
        { 3drop 1 }
        { 3dup 2 }
        { 3keep 3 }
        { 3nip 4 }
        { 3slip 3 }
        { 3with 3 }
        { 3with* 4 }
        { 4drop 2 }
        { 4dup 3 }
        { 4slip 4 }
        { compose 1/2 }
        { curry 1/2 }
        { dip 1 }
        { dipd 2 }
        { drop 1/2 }
        { dup 1/2 }
        { keep 1 }
        { napply 2 }
        { ncurry 3 }
        { ndip 5 }
        { ndrop 2 }
        { ndup 3 }
        { nip 2 }
        { nipd 3 }
        { nkeep 5 }
        { npick 6 }
        { nrev 5 }
        { nrot 5 }
        { nslip 5 }
        { ntuck 6 }
        { nwith 4 }
        { over 2 }
        { pick 4 }
        { roll 4 }
        { rot 3 }
        { slip 1 }
        { spin 3 }
        { swap 1 }
        { swapd 3 }
        { tuck 2 }
        { tuckd 3 }
        { with 1 }
        { with* 2 }
        { r> 1/2 }
        { >r 1/2 }

        { bi 1/2 }
        { tri 1 }
        { bi* 1/2 }
        { tri* 1 }

        { cleave 2 }
        { spread 2 }
    } at 0 or ;

: vsum { 0 0 } [ v+ ] reduce ;

GENERIC: noise ( obj -- pair )

M: word noise badness 1 2array ;

M: wrapper noise wrapped noise ;

M: let noise let-body noise ;

M: wlet noise wlet-body noise ;

M: lambda noise lambda-body noise ;

M: object noise drop { 0 0 } ;

M: quotation noise [ noise ] map vsum { 1/3 0 } v+ ;

M: array noise [ noise ] map vsum { 1/3 0 } v+ ;

: quot-noise-factor ( quot -- n )
    #! For very short words, noise doesn't count so much
    #! (so dup foo swap bar isn't penalized as badly).
    noise first2 15 max / 100 * >integer ;

GENERIC: word-noise-factor ( word -- factor )

M: word word-noise-factor
    word-def quot-noise-factor ;

M: lambda-word word-noise-factor
    "lambda" word-prop quot-noise-factor ;

: noisy-words ( -- alist )
    all-words [
        dup generic? [ methods values ] [ 1array ] if
    ] map concat [ dup word-noise-factor ] { } map>assoc
    sort-values reverse ;

: noisy-words. ( alist -- )
    standard-table-style [
        [
            [ [ pprint-cell ] [ pprint-cell ] bi* ] with-row
        ] assoc-each
    ] tabular-output ;

: noise-report ( -- )
    noisy-words 40 head noisy-words. ;

MAIN: noise-report
