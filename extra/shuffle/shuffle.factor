! Copyright (C) 2007 Chris Double, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences namespaces math inference.transforms
       combinators macros quotations math.ranges bake ;

IN: shuffle

MACRO: npick ( n -- ) 1- dup saver [ dup ] rot [ r> swap ] n*quot 3append ;

MACRO: ndup ( n -- ) dup [ npick ] curry n*quot ;

MACRO: nrot ( n -- ) 1- dup saver swap [ r> swap ] n*quot append ;

MACRO: -nrot ( n -- ) 1- dup [ swap >r ] n*quot swap restorer append ;

MACRO: ndrop ( n -- ) [ drop ] n*quot ;

: nnip ( n -- ) swap >r ndrop r> ; inline

MACRO: ntuck ( n -- ) 2 + [ dup , -nrot ] bake ;

: 2swap ( x y z t -- z t x y ) rot >r rot r> ; inline

: 2over ( a b c -- a b c a b ) pick pick ; inline

: nipd ( a b c -- b c ) rot drop ; inline

: 3nip ( a b c d -- d ) 3 nnip ; inline

: 4dup ( a b c d -- a b c d a b c d ) 4 ndup ; inline

: tuckd ( x y z -- z x y z ) 2 ntuck ; inline
