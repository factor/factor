USING: accessors arrays combinators fry grouping
grouping.private kernel locals macros math math.ranges sequences
sequences.generalizations sequences.private vectors ;

IN: grouping.extras

: 2clump-map-as ( seq quot: ( elt1 elt2 -- newelt ) exemplar -- seq' )
    [ dup 1 short tail-slice ] 2dip 2map-as ; inline

: 2clump-map ( seq quot: ( elt1 elt2 -- newelt ) -- seq' )
    { } 2clump-map-as ; inline

: 3clump-map-as ( seq quot: ( elt1 elt2 elt3 -- newelt ) exemplar -- seq' )
    [
        dup [ 1 short tail-slice ] [ 2 short tail-slice ] bi
    ] 2dip 3map-as ; inline

: 3clump-map ( seq quot: ( elt1 elt2 elt3 -- newelt ) -- seq' )
    { } 3clump-map-as ; inline

MACRO: nclump-map-as ( seq quot exemplar n -- result )
    [ nip [1,b) [ [ short tail-slice ] curry ] map swap ] 2keep
    '[ _ dup _ cleave _ _ _ nmap-as ] ;

: nclump-map ( seq quot n -- result )
    { } swap nclump-map-as ; inline

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
