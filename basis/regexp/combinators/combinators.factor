! Copyright (C) 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel regexp regexp.ast regexp.classes
sequences strings ;
IN: regexp.combinators

<PRIVATE

: modify-regexp ( regexp raw-quot tree-quot -- new-regexp )
    [ '[ raw>> @ ] ]
    [ '[ parse-tree>> @ ] ] bi* bi
    make-regexp ; inline

PRIVATE>

CONSTANT: <nothing> R/ (?~.*)/s

: <literal> ( string -- regexp )
    [ "\\Q" "\\E" surround ] [ <concatenation> ] bi make-regexp ; foldable

: <char-range> ( char1 char2 -- regexp )
    [ [ 1string ] bi@ [ "[" "-" surround ] [ "]" append ] bi* append ]
    [ <range-class> ] 2bi make-regexp ;

: <or> ( regexps -- disjunction )
    [ [ raw>> "(" ")" surround ] map "|" join ]
    [ [ parse-tree>> ] map <alternation> ] bi
    make-regexp ; foldable

: <any-of> ( strings -- regexp )
    [ <literal> ] map <or> ; foldable

: <sequence> ( regexps -- regexp )
    [ [ raw>> ] map concat ]
    [ [ parse-tree>> ] map <concatenation> ] bi
    make-regexp ; foldable

: <not> ( regexp -- not-regexp )
    [ "(?~" ")" surround ]
    [ <negation> ] modify-regexp ; foldable

: <and> ( regexps -- conjunction )
    [ <not> ] map <or> <not> ; foldable

: <zero-or-more> ( regexp -- regexp* )
    [ "(" ")*" surround ]
    [ <star> ] modify-regexp ; foldable

: <one-or-more> ( regexp -- regexp+ )
    [ "(" ")+" surround ]
    [ <plus> ] modify-regexp ; foldable

: <option> ( regexp -- regexp? )
    [ "(" ")?" surround ]
    [ <maybe> ] modify-regexp ; foldable
