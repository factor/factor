! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: parser-combinators regexp lazy-lists sequences kernel
promises strings ;
IN: globs

<PRIVATE

: 'char' [ ",*?" member? not ] satisfy ;

: 'string' 'char' <+> [ >lower token ] <@ ;

: 'escaped-char' "\\" token any-char-parser &> [ 1token ] <@ ;

: 'escaped-string' 'string' 'escaped-char' <|> ;

DEFER: 'term'

: 'glob' ( -- parser )
    'term' <*> [ <and-parser> ] <@ ;

: 'union' ( -- parser )
    'glob' "," token nonempty-list-of "{" "}" surrounded-by
    [ <or-parser> ] <@ ;

LAZY: 'term'
    'union'
    'character-class' <|>
    "?" token [ drop any-char-parser ] <@ <|>
    "*" token [ drop any-char-parser <*> ] <@ <|>
    'escaped-string' <|> ;

PRIVATE>

: <glob> 'glob' just parse-1 just ;

: glob-matches? ( input glob -- ? )
    >r >lower r> <glob> parse nil? not ;
