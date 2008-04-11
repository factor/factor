USING: accessors arrays combinators kernel math sequences namespaces ;

IN: unionfind

<PRIVATE

TUPLE: unionfind parents ranks counts ;

SYMBOL: uf

: count ( a -- n )
    uf get counts>> nth ;

: add-count ( p a -- )
    count [ + ] curry uf get counts>> swap change-nth ;

: parent ( a -- p )
    uf get parents>> nth ;

: set-parent ( p a -- )
    uf get parents>> set-nth ;

: link-sets ( p a -- )
    [ set-parent ]
    [ add-count ] 2bi ;

: rank ( a -- r )
    uf get ranks>> nth ;

: inc-rank ( a -- )
    uf get ranks>> [ 1+ ] change-nth ;

: topparent ( a -- p )
    [ parent ] keep
    2dup = [
        [ topparent ] dip
        2dup set-parent
    ] unless drop ;

PRIVATE>

: <unionfind> ( n -- unionfind )
    [ >array ]
    [ 0 <array> ]
    [ 1 <array> ] tri
    unionfind construct-boa ;

: equiv-set-size ( a uf -- n )
    uf [ topparent count ] with-variable ;

: equiv? ( a b uf -- ? )
    uf [ [ topparent ] bi@ = ] with-variable ;

: equate ( a b uf -- )
    uf [
        [ topparent ] bi@
        2dup [ rank ] compare sgn
        {
            { -1 [ swap link-sets ] }
            {  1 [ link-sets ] }
            {  0 [
                    2dup =
                    [ 2drop ]
                    [
                        [ link-sets ]
                        [ drop inc-rank ] 2bi
                    ] if
                 ]
            }
        } case
    ] with-variable ;
