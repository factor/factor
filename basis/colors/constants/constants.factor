! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel assocs math math.parser memoize
io.encodings.ascii io.files lexer parser
colors sequences splitting combinators.smart ascii ;
IN: colors.constants

<PRIVATE

: parse-color ( line -- name color )
    [
        [ [ string>number 255 /f ] tri@ 1.0 <rgba> ] dip
        [ blank? ] trim-head { { CHAR: \s CHAR: - } } substitute swap
    ] input<sequence ;

: parse-rgb.txt ( lines -- assoc )
    [ "!" head? not ] filter
    [ 11 cut [ " \t" split harvest ] dip suffix ] map
    [ parse-color ] H{ } map>assoc ;

MEMO: rgb.txt ( -- assoc )
    "resource:basis/colors/constants/rgb.txt" ascii file-lines parse-rgb.txt ;

PRIVATE>

: named-colors ( -- keys ) rgb.txt keys ;

ERROR: no-such-color name ;

: named-color ( name -- color )
    dup rgb.txt at [ ] [ no-such-color ] ?if ;

: COLOR: scan named-color parsed ; parsing