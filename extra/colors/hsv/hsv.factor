! Copyright (C) 2003, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences math ;
IN: colors.hsv

<PRIVATE

: f_ >r swap rot >r 2dup r> 6 * r> - ;
: p ( v s x -- v p x ) >r dupd neg 1 + * r> ;
: q ( v s f -- q ) * neg 1 + * ;
: t_ ( v s f -- t_ ) neg 1 + * neg 1 + * ;

PRIVATE>

: mod-cond ( p vector -- )
    #! Call p mod q'th entry of the vector of quotations, where
    #! q is the length of the vector. The value q remains on the
    #! stack.
    [ dupd length mod ] keep nth call ;

: hsv>rgb ( h s v -- r g b )
    pick 6 * >fixnum {
        [ f_ t_ p swap     ] ! v p t
        [ f_ q  p -rot     ] ! q v p
        [ f_ t_ p swapd    ] ! p v t
        [ f_ q  p rot      ] ! p q v
        [ f_ t_ p swap rot ] ! t p v
        [ f_ q  p          ] ! v p q
    } mod-cond ;
