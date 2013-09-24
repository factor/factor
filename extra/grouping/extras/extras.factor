USING: accessors combinators fry grouping.private kernel macros
math math.ranges sequences sequences.generalizations
sequences.private ;

IN: grouping.extras

: 2clump-map ( seq quot: ( elt1 elt2 -- newelt ) -- seq' )
    [ dup 1 short tail-slice ] dip { } 2map-as ; inline

: 3clump-map ( seq quot: ( elt1 elt2 elt3 -- newelt ) -- seq' )
    [
        dup [ 1 short tail-slice ] [ 2 short tail-slice ] bi
    ] dip { } 3map-as ; inline

MACRO: nclump-map ( seq quot n -- result )
    [ [1,b) [ [ short tail-slice ] curry ] map swap ] keep
    '[ _ dup _ cleave _ { } _ nmap-as ] ;

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
