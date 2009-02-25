! Copyright (C) 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: regexp sequences kernel regexp.negation regexp.ast
accessors fry ;
IN: regexp.combinators

: <nothing> ( -- regexp )
    R/ (?~.*)/ ;

: <literal> ( string -- regexp )
    [ "\\Q" "\\E" surround ] [ <concatenation> ] bi make-regexp ;

: <or> ( regexps -- disjunction )
    [ [ raw>> "(" ")" surround ] map "|" join ]
    [ [ parse-tree>> ] map <alternation> ] bi
    make-regexp ;

: <any-of> ( strings -- regexp )
    [ <literal> ] map <or> ;

: <sequence> ( regexps -- regexp )
    [ [ raw>> ] map concat ]
    [ [ parse-tree>> ] map <concatenation> ] bi
    make-regexp ;

: modify-regexp ( regexp raw-quot tree-quot -- new-regexp )
    [ '[ raw>> @ ] ]
    [ '[ parse-tree>> @ ] ] bi* bi
    make-regexp ; inline

: <not> ( regexp -- not-regexp )
    [ "(?~" ")" surround ]
    [ <negation> ] modify-regexp ;

: <and> ( regexps -- conjunction )
    [ <not> ] map <or> <not> ;

: <zero-or-more> ( regexp -- regexp* )
    [ "(" ")*" surround ]
    [ <star> ] modify-regexp ;

: <one-or-more> ( regexp -- regexp+ )
    [ "(" ")+" surround ]
    [ <plus> ] modify-regexp ;

: <option> ( regexp -- regexp? )
    [ "(" ")?" surround ]
    [ <maybe> ] modify-regexp ;
