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

TUPLE: prefixes seq ;
C: <prefixes> prefixes
M: prefixes length seq>> length ;
M: prefixes nth-unsafe seq>> swap 1 + head-slice ;
INSTANCE: prefixes immutable-sequence

: all-prefixes ( seq -- array )
    [ <prefixes> ] [ [ like ] curry map ] bi ;

TUPLE: suffixes seq ;
C: <suffixes> suffixes
M: suffixes length seq>> length ;
M: suffixes nth-unsafe seq>> swap tail-slice ;
INSTANCE: suffixes immutable-sequence

: all-suffixes ( seq -- array )
    [ <suffixes> ] [ [ like ] curry map ] bi ;

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
    seq length dup n assert-positive /mod :> ( len step j )
    0 n [| i |
        dup len < [
            dup step + i j < [ 1 + ] when
            [ seq <slice> ] 1check
        ] [ f ] if
    ] map-integers nip ;

: n-group ( seq n -- groups )
    [ <n-groups> ] map-like ;
