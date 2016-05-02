! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel assocs math math.parser memoize io.encodings.utf8
io.files lexer parser colors sequences splitting ascii ;
IN: colors.constants

<PRIVATE

: parse-color ( line -- name color )
    first4
    [ [ string>number 255 /f ] tri@ 1.0 <rgba> ] dip
    [ blank? ] trim-head H{ { CHAR: \s CHAR: - } } substitute swap ;

: parse-colors ( lines -- assoc )
    [ "!" head? ] reject
    [ 11 cut [ " \t" split harvest ] dip suffix ] map
    [ parse-color ] H{ } map>assoc ;

MEMO: colors ( -- assoc )
    "resource:basis/colors/constants/rgb.txt"
    "resource:basis/colors/constants/factor-colors.txt"
    "resource:basis/colors/constants/solarized-colors.txt"
    [ utf8 file-lines parse-colors ] tri@ assoc-union assoc-union ;

PRIVATE>

: named-colors ( -- keys ) colors keys ;

ERROR: no-such-color name ;

: named-color ( name -- color )
    dup colors at [ ] [ no-such-color ] ?if ;

SYNTAX: COLOR: scan-token named-color suffix! ;
