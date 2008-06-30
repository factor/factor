USING: kernel layouts math math.order namespaces sequences
sequences.private accessors ;
IN: math.ranges

TUPLE: range
{ from read-only: t }
{ length read-only: t }
{ step read-only: t } ;

: <range> ( a b step -- range )
    >r over - r>
    [ / 1+ 0 max >integer ] keep
    range boa ;

M: range length ( seq -- n )
    length>> ;

M: range nth-unsafe ( n range -- obj )
    [ step>> * ] keep from>> + ;

INSTANCE: range immutable-sequence

: twiddle 2dup > -1 1 ? ; inline

: (a, dup roll + -rot ; inline

: ,b) dup neg rot + swap ; inline

: [a,b] ( a b -- range ) twiddle <range> ; foldable

: (a,b] ( a b -- range ) twiddle (a, <range> ; foldable

: [a,b) ( a b -- range ) twiddle ,b) <range> ; foldable

: (a,b) ( a b -- range ) twiddle (a, ,b) <range> ; foldable

: [0,b] ( b -- range ) 0 swap [a,b] ; foldable

: [1,b] ( b -- range ) 1 swap [a,b] ; foldable

: [0,b) ( b -- range ) 0 swap [a,b) ; foldable

: range-increasing? ( range -- ? )
    step>> 0 > ;

: range-decreasing? ( range -- ? )
    step>> 0 < ;

: first-or-peek ( seq head? -- elt )
    [ first ] [ peek ] if ;

: range-min ( range -- min )
    dup range-increasing? first-or-peek ;

: range-max ( range -- max )
    dup range-decreasing? first-or-peek ;

: clamp-to-range ( n range -- n )
    [ range-min max ] [ range-max min ] bi ;

: sequence-index-range  ( seq -- range )
    length [0,b) ;
