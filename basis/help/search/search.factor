! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: fry help help.markup help.topics io kernel memoize
sequences sequences.deep sorting splitting strings unicode.case
unicode.categories ;

IN: help.search

<PRIVATE

: (article-words) ( name -- words )
    article-content [ string? ] filter
    [ >lower [ blank? ] split-when ] map concat
    [ CHAR: - over member? [ "-" split ] when ] map
    flatten harvest ;

MEMO: article-words ( name -- words )
    (article-words) [
        dup [ letter? not ] any? [
            [ [ letter? ] [ digit? ] bi or not ] split-when
        ] when
    ] map flatten [ [ digit? ] all? not ] filter harvest ;

PRIVATE>

: search-docs ( string -- seq' )
    [ all-articles ] dip >lower [ blank? ] split-when
    '[ article-words [ _ member? ] any? ] filter
    [ article-name ] sort-with ;

: search-docs. ( string -- )
    search-docs [ ($link) nl ] each ;
