! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators.short-circuit kernel
math sequences sequences.private ;
IN: sequences.product

TUPLE: product-sequence
    { sequences array read-only }
    { lengths array read-only } ;

: <product-sequence> ( sequences -- product-sequence )
    >array dup [ length ] map product-sequence boa ;

INSTANCE: product-sequence sequence

M: product-sequence length lengths>> product ;

<PRIVATE

: product-ns ( n lengths -- ns )
    <reversed> [ /mod ] map nip <reversed> ; inline

: product-nths ( ns seqs -- nths )
    [ nth-unsafe ] { } 2map-as ; inline

PRIVATE>

M: product-sequence nth
    [ lengths>> product-ns ] [ sequences>> product-nths ] bi ;

<PRIVATE

: product-length ( sequences -- length )
    [ length ] [ * ] map-reduce integer>fixnum-strict ; inline

:: (product-each) ( ... ns sequences k quot: ( ... seq -- ... ) -- ... )
    k sequences length 1 - = :> done?
    k sequences nth-unsafe [
        k ns set-nth-unsafe
        ns done? quot [
            sequences k 1 + quot (product-each)
        ] if
    ] each ; inline recursive

PRIVATE>

:: product-each ( ... sequences quot: ( ... seq -- ... ) -- ... )
    sequences [ empty? ] any? [
        sequences length f <array>
        sequences >array 0 quot (product-each)
    ] unless ; inline

:: product-map-as ( ... sequences quot: ( ... seq -- ... value ) exemplar -- ... sequence )
    sequences >array :> sequences
    0 sequences product-length exemplar
    [| result |
        sequences
        [ clone swap quot dip [ result set-nth-unsafe ] [ 1 + ] bi ]
        product-each
        result
    ] new-like nip ; inline

: product-map ( ... sequences quot: ( ... seq -- ... value ) -- ... sequence )
    over product-map-as ; inline

: all-products ( sequences -- sequences )
    [ ] product-map ;

:: product-map>assoc ( ... sequences quot: ( ... seq -- ... key value ) exemplar -- ... assoc )
    0 sequences product-length { }
    [| result |
        sequences
        [ clone swap [ quot call 2array ] dip [ result set-nth-unsafe ] [ 1 + ] bi ]
        product-each
        result
    ] new-like exemplar assoc-like nip ; inline

<PRIVATE

:: (product-find) ( ... ns sequences k quot: ( ... seq -- ... ? ) -- ... ? )
    k sequences length 1 - = :> done?
    k sequences nth-unsafe [
        k ns set-nth-unsafe
        ns done? quot [
            sequences k 1 + quot (product-find)
        ] if
    ] find drop ; inline recursive

PRIVATE>

:: product-find ( ... sequences quot: ( ... seq -- ... ? ) -- ... sequence )
    sequences { [ empty? ] [ [ empty? ] any? ] } 1|| [ f ] [
        sequences length f <array>
        [ sequences >array 0 quot (product-find) ]  1guard
    ] if ; inline
