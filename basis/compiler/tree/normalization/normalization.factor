! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators compiler.tree
compiler.tree.normalization.introductions
compiler.tree.normalization.renaming compiler.utilities fry
kernel math math.order namespaces sequences
stack-checker.backend stack-checker.branches ;
IN: compiler.tree.normalization

GENERIC: normalize* ( node -- node' )

SYMBOL: introduction-stack

: pop-introduction ( -- value )
    introduction-stack [ unclip-last swap ] change ;

: pop-introductions ( n -- values )
    introduction-stack [ swap cut* swap ] change ;

M: #introduce normalize*
    out-d>> [ length pop-introductions ] keep add-renamings f ;

SYMBOL: remaining-introductions

M: #branch normalize*
    [
        [
            [
                [ normalize* ] map-flat
                introduction-stack get
                2array
            ] with-scope
        ] map unzip swap
    ] change-children swap
    [ remaining-introductions set ]
    [ [ length ] [ min ] map-reduce introduction-stack [ swap head ] change ]
    bi ;

: eliminate-phi-introductions ( introductions seq terminated -- seq' )
    [
        [ nip ] [
            dup [ +top+ eq? ] trim-head
            [ 2length - tail* ] keep append
        ] if
    ] 3map ;

M: #phi normalize*
    remaining-introductions get swap dup terminated>>
    '[ _ eliminate-phi-introductions ] change-phi-in-d ;

: (normalize) ( nodes introductions -- nodes )
    introduction-stack [
        [ normalize* ] map-flat
    ] with-variable ;

M: #recursive normalize*
    [ [ child>> first ] [ in-d>> ] bi >>in-d drop ]
    [ dup label>> introductions>> make-values '[ _ (normalize) ] change-child ]
    bi ;

M: #enter-recursive normalize*
    [ introduction-stack get prepend ] change-out-d
    dup [ label>> ] keep >>enter-recursive drop
    dup [ label>> ] [ out-d>> ] bi >>enter-out drop ;

: unchanged-underneath ( #call-recursive -- n )
    [ out-d>> length ] [ label>> return>> in-d>> length ] bi - ;

: call<return ( #call-recursive n -- nodes )
    neg dup make-values [
        [ pop-introductions '[ _ prepend ] change-in-d ]
        [ '[ _ prepend ] change-out-d ]
        bi*
    ] [ introduction-stack [ prepend ] change ] bi ;

: call>return ( #call-recursive n -- #call-recursive )
    [ [ [ in-d>> ] [ out-d>> ] bi ] [ '[ _ head ] ] bi* bi@ add-renamings ]
    [ '[ _ tail ] [ change-in-d ] [ change-out-d ] bi ]
    2bi ;

M: #call-recursive normalize*
    dup unchanged-underneath {
        { [ dup 0 < ] [ call<return ] }
        { [ dup 0 = ] [ drop ] }
        { [ dup 0 > ] [ call>return ] }
    } cond ;

M: node normalize* ;

: normalize ( nodes -- nodes' )
    [
        dup count-introductions make-values
        H{ } clone rename-map set
        [ (normalize) ] [ nip ] 2bi
        [ <#introduce> prefix ] unless-empty
        rename-node-values
    ] with-scope ;

M: #alien-callback normalize*
    [ normalize ] change-child ;
