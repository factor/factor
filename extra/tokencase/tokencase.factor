! Copyright (C) 2022 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: combinators kernel sequences splitting strings unicode ;

IN: tokencase

<PRIVATE

: case-index ( str -- i/f )
    dup [ lower? ] find [
        swap [ lower? not ] find-from drop
    ] [ nip ] if ;

: split-case ( str -- words )
    >graphemes [ dup empty? not ] [
        dup [ case-index ] [ length or ] bi
        cut-slice swap concat
    ] produce nip ;

: split-tokens ( str -- words )
    " -_." split [ split-case ] map concat ;

: case1 ( str quot glue -- str' )
    [ split-tokens ] [ map ] [ join ] tri* ; inline

: case2 ( str first-quot rest-quot glue -- str' )
    {
        [ split-tokens 0 over ]
        [ change-nth dup rest-slice ]
        [ map! drop ]
        [ join ]
    } spread ; inline

PRIVATE>

: >camelcase ( str -- str' ) [ >lower ] [ >title ] "" case2 ;

: >pascalcase ( str -- str' ) [ >title ] "" case1 ;

: >snakecase ( str -- str' ) [ >lower ] "_" case1 ;

: >adacase ( str -- str' ) [ >title ] "_" case1 ;

: >macrocase ( str -- str' ) [ >upper ] "_" case1 ;

: >kebabcase ( str -- str' ) [ >lower ] "-" case1 ;

: >traincase ( str -- str' ) [ >title ] "-" case1 ;

: >cobolcase ( str -- str' ) [ >upper ] "-" case1 ;

: >lowercase ( str -- str' ) [ >lower ] " " case1 ;

: >uppercase ( str -- str' ) [ >upper ] " " case1 ;

: >titlecase ( str -- str' ) [ >title ] " " case1 ;

: >sentencecase ( str -- str' ) [ >title ] [ >lower ] " " case2 ;

: >dotcase ( str -- str' ) [ >lower ] "." case1 ;
