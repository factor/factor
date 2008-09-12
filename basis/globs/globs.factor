! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: parser-combinators regexp lists sequences kernel
promises strings unicode.case ;
IN: globs

<PRIVATE

: 'char' ( -- parser )
    [ ",*?" member? not ] satisfy ;

: 'string' ( -- parser )
    'char' <+> [ >lower token ] <@ ;

: 'escaped-char' ( -- parser )
    "\\" token any-char-parser &> [ 1token ] <@ ;

: 'escaped-string' ( -- parser )
    'string' 'escaped-char' <|> ;

DEFER: 'term'

: 'glob' ( -- parser )
    'term' <*> [ <and-parser> ] <@ ;

: 'union' ( -- parser )
    'glob' "," token nonempty-list-of "{" "}" surrounded-by
    [ <or-parser> ] <@ ;

LAZY: 'term' ( -- parser )
    'union'
    'character-class' <|>
    "?" token [ drop any-char-parser ] <@ <|>
    "*" token [ drop any-char-parser <*> ] <@ <|>
    'escaped-string' <|> ;

PRIVATE>

: <glob> ( string -- glob ) 'glob' just parse-1 just ;

: glob-matches? ( input glob -- ? )
    [ >lower ] [ <glob> ] bi* parse nil? not ;
