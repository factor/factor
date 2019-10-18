! Based on
! http://cat-language.googlecode.com/svn/trunk/CatPointFreeForm.cs
USING: kernel namespaces arrays sequences sequences-internals
math inference parser words quotations ;
IN: locals

: arg-list, ( n -- )
    dup , [ f <array> ] %
    <reversed> [ , [ swapd pick set-nth-unsafe ] % ] each ;

: arg-n, ( n -- ) , [ r> dup >r nth-unsafe ] % ;

: localize ( args obj -- )
    tuck swap index [ arg-n, ] [ , ] ?if ;

: point-free ( quot args -- newquot )
    [
        dup length arg-list,
        \ >r , swap [ localize ] each-with [ r> drop ] %
    ] [ ] make ;

: with-locals ( quot locals -- ) point-free call ;

\ with-locals 2 [ point-free ] define-transform

DEFER: |LOCALS delimiter

: LOCALS|
    #! Syntax: LOCALS| a b c | ... a ... b ... c ... |LOCALS
    "|" parse-tokens
    [ create-in dup define-symbol ] map >r
    \ |LOCALS parse-until >quotation parsed
    r> parsed
    \ with-locals parsed ; parsing

: quadratic LOCALS| x a b c | a x sq * b x * + c + |LOCALS ;

PROVIDE: libs/locals ;
