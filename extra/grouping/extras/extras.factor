USING: accessors arrays grouping grouping.private kernel math
sequences sequences.generalizations sequences.private vectors ;

IN: grouping.extras

:: clump-map-as ( seq quot exemplar n -- result )
    seq n <clumps> [ n firstn-unsafe quot call ] exemplar map-as ; inline

: clump-map ( seq quot n -- result )
    { } swap clump-map-as ; inline

:: pad-groups ( seq n elt -- padded )
    seq dup length dup n mod [ drop ] [ n swap - + elt pad-tail ] if-zero ;

:: short-groups ( seq n -- seq' )
    seq dup length dup n mod [ drop ] [ - head-slice ] if-zero ;

:: group-map-as ( seq quot exemplar n -- result )
    seq n short-groups n <groups>
    [ n firstn-unsafe quot call ] exemplar map-as ; inline

: group-map ( seq quot n -- result )
    { } swap group-map-as ; inline

TUPLE: head-clumps seq ;
C: <head-clumps> head-clumps
M: head-clumps length seq>> length ;
M: head-clumps nth-unsafe seq>> swap 1 + head-slice ;
INSTANCE: head-clumps immutable-sequence

: head-clump ( seq -- array )
    [ <head-clumps> ] [ [ like ] curry map ] bi ;

TUPLE: tail-clumps seq ;
C: <tail-clumps> tail-clumps
M: tail-clumps length seq>> length ;
M: tail-clumps nth-unsafe seq>> swap tail-slice ;
INSTANCE: tail-clumps immutable-sequence

: tail-clump ( seq -- array )
    [ <tail-clumps> ] [ [ like ] curry map ] bi ;

: clump-as ( seq n exemplar -- array )
    [ <clumps> ] dip [ like ] curry map ;

: group-as ( seq n exemplar -- array )
    [ <groups> ] dip [ like ] curry map ;

<PRIVATE

: (group-by) ( groups elt key -- groups )
    pick [ t ] [ last first dupd = not ] if-empty [
        swap 1vector 2array over push
    ] [
        drop over last last push
    ] if ; inline

PRIVATE>

: group-by ( seq quot: ( elt -- key ) -- groups )
    '[ dup _ call( x -- y ) (group-by) ] V{ } clone swap reduce ;

:: <n-groups> ( seq n -- groups )
    seq length :> len
    len n /mod :> ( step rem! )
    0 n [
        dup len < [
            dup step + rem zero? [ 1 + rem 1 - rem! ] unless
            [ seq <slice> ] keep swap
        ] [ f ] if
    ] replicate nip ;

: n-group ( seq n -- groups )
    [ <n-groups> ] map-like ;
