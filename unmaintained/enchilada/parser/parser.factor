! Copyright (C) 2007 Robbert van Dalen.
! See http://factorcode.org/license.txt for BSD license.

IN: enchilada.parser
USING: strings sequences kernel promises lazy-lists parser-combinators parser-combinators.simple isequences.interface isequences.base enchilada.engine ;

USE: lazy-lists
USE: parser-combinators

DEFER: e-expression

LAZY: e/- ( -- parser )
    "-" token [ drop <.-> ] <@ ;

LAZY: e/# ( -- parser )
    "#" token [ drop <.#> ] <@ ;

LAZY: e/^ ( -- parser )
    "^" token [ drop <.^> ] <@ ;

LAZY: e/` ( -- parser )
    "`" token [ drop <.`> ] <@ ;

LAZY: e/: ( -- parser )
    ":" token [ drop <.:> ] <@ ;

LAZY: e/~ ( -- parser )
    "~" token [ drop <.~> ] <@ ;

LAZY: e/$ ( -- parser )
    "$" token [ drop <.$> ] <@ ;

LAZY: e/! ( -- parser )
    "!" token [ drop <.!> ] <@ ;

LAZY: e/\ ( -- parser )
    "\\" token [ drop <.\> ] <@ ;

LAZY: e/+ ( -- parser )
    "+" token [ drop <.+> ] <@ ;

LAZY: e/| ( -- parser )
    "|" token [ drop <.|> ] <@ ;

LAZY: e/& ( -- parser )
    "&" token [ drop <.&> ] <@ ;

LAZY: e/* ( -- parser )
    "*" token [ drop <.*> ] <@ ;

LAZY: e// ( -- parser )
    "/" token [ drop <./> ] <@ ;

LAZY: e/< ( -- parser )
    "<" token [ drop <.<> ] <@ ;

LAZY: e/> ( -- parser )
    ">" token [ drop <.>> ] <@ ;

LAZY: e/@ ( -- parser )
    "@" token [ drop <.@> ] <@ ;

LAZY: e/? ( -- parser )
    "?" token [ drop <.?> ] <@ ;

LAZY: e/% ( -- parser )
    "%" token [ drop <.%> ] <@ ;

LAZY: e-monadic ( -- parser )
    e/- e/# <|> e/^ <|> e/` <|> e/: <|> e/~ <|> e/$ <|> e/! <|> e/\ <|> ;

LAZY: e-dyadic ( -- parser )
    e/+ e/* <|> e/& <|> e/| <|> e// <|> e/< <|> e/> <|> e/@ <|> e/? <|> e/% <|> ;

LAZY: e-number ( -- parser )
    'integer' ;

LAZY: e-letter ( -- parser )
    [ letter? ] satisfy [ 1 swap <string> ] <@ ;

LAZY: e-digit ( -- parser )
    [ digit? ] satisfy [ 1 swap <string> ] <@ ;

LAZY: e-alphanumeric-char ( -- parser )
    e-letter e-digit <|> ;

LAZY: e-alphanumeric-symbol ( -- parser )
    e-letter e-alphanumeric-char <!*> <&> [ dup first swap second "" [ append ] reduce append ] <@ ;

LAZY: e-symbol ( -- parser )
    e-alphanumeric-symbol 'string' <|> sp [ <esymbol> ] <@ ;

LAZY: e-symbol-list ( -- parser )
    e-symbol <!+> [ { } [ ++ ] reduce ] <@ ;

LAZY: e-macro-expression ( -- parser )
    "=" token "=" token <?> <&> sp e-expression <&> [ dup 1 tail swap first second [ t ] [ f ] if add ] <@ ;

LAZY: e-macro ( -- parser )
    "{" token sp e-symbol-list &> e-macro-expression <?> <&> "}" token sp <& 
    [ dup first swap second dup [ first ] [ drop { 0 f } ] if dup first swap second <e-macro> ] <@ ;

LAZY: e-right-expression ( -- parser )
    "=" token e-expression &> ;

: create-e-item ( pair -- e-item )
    dup first swap second dup [ first ] [ drop 0 ] if <i-dual-sided> <i> ;
 
LAZY: e-item ( -- parser )
e-expression e-right-expression <?> <&> [ create-e-item ] <@ ;

LAZY: e-rest ( -- parser )
";" token sp e-item &> <!*> [ { } [ ++ ] reduce ] <@ ;

LAZY: e-contents ( -- parser )
e-item e-rest <&> [ dup first swap second ++ ] <@ ;

LAZY: e-non-empty ( -- parser )
"[" token e-contents &> "]" token sp <& ;

LAZY: e-empty ( -- parser )
    "[" token "]" token <&> [ drop 0 ] <@ ;

LAZY: e-sequence ( -- parser )
    e-empty e-non-empty <|> e-number <|> ;

LAZY: e-operand ( -- parser )
    "_" token <?> e-sequence <&> [ dup second swap first [ -- ] when <i> ] <@ ;

LAZY: e-operator ( -- parser )
    e-monadic e-dyadic <|> e-macro <|>  ;

LAZY: e-element ( -- parser )
    e-operator e-operand <|> e-symbol <|> sp ;

LAZY: e-expression ( -- parser )
    e-element <!*> [ { } [ ++ ] reduce ] <@ ;

: e-parse  ( string -- result ) e-expression parse car parse-result-parsed ;
