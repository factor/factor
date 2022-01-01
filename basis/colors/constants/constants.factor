! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors ascii assocs colors io.encodings.utf8 io.files
kernel lexer math math.parser sequences splitting vocabs.loader
;

IN: colors.constants

<PRIVATE

: parse-color ( line -- name color )
    first4
    [ [ string>number 255 /f ] tri@ 1.0 <rgba> ] dip
    [ ascii:blank? ] trim-head H{ { CHAR: \s CHAR: - } } substitute swap ;

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

: lookup-color ( name -- color )
    dup colors at [ ] [ no-such-color ] ?if ;

TUPLE: named-color < color name value ;

M: named-color >rgba value>> >rgba ;

SYNTAX: COLOR: scan-token dup lookup-color named-color boa suffix! ;

{ "colors.constants" "prettyprint" } "colors.constants.prettyprint" require-when
