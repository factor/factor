USING: ranges kernel random sequences arrays combinators ;
IN: chess960

SYMBOLS: pawn rook knight bishop queen king ;

: all-positions ( -- range ) 8 [0..b) ;

: black-bishop-positions ( -- range ) 0 6 2 <range> ;
: white-bishop-positions ( -- range ) 1 7 2 <range> ;

: frisk ( position positions -- position positions' )
    [ drop ] [ remove ] 2bi ;

: white-bishop ( positions -- position positions' )
    [ white-bishop-positions random ] dip frisk ;
: black-bishop ( positions -- position positions' )
    [ black-bishop-positions random ] dip frisk ;

: random-position ( positions -- position positions' )
    [ random ] keep frisk ;

: make-position ( white-bishop black-bishop knight knight queen {r,k,r} -- position )
    first3
    8 f <array> {
        [ [ rook ] 2dip set-nth ]
        [ [ king ] 2dip set-nth ]
        [ [ rook ] 2dip set-nth ]
        [ [ queen ] 2dip set-nth ]
        [ [ knight ] 2dip set-nth ]
        [ [ knight ] 2dip set-nth ]
        [ [ bishop ] 2dip set-nth ]
        [ [ bishop ] 2dip set-nth ]
        [ ]
    } cleave ;

: chess960-position ( -- position )
    all-positions
    white-bishop
    black-bishop
    random-position
    random-position
    random-position
    make-position ;
