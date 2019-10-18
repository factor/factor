! Copyright (C) 2006 Matthew Willis. All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
!
USING: parser-combinators kernel sequences lazy-lists
namespaces strings arrays math io errors ;

IN: farkup
LAZY: <(*)> ( parser -- parser ) 
    ! kleene star matching, but take shortest match first
    { } succeed swap dup <(*)> <&:> <|> ;

LAZY: <(+)> ( parser -- parser )
    dup <(*)> <&:> ;

LAZY: 'consume1' ( -- parser ) [ CHAR: \n = not ] satisfy ;

LAZY: '\n' ( -- parser ) [ CHAR: \n = ] satisfy ;

: open-tag ( text -- tag ) [ CHAR: < , , CHAR: > , ] { } make ;

: close-tag ( text -- tag ) [ "</" , , CHAR: > , ] { } make ;

: both-tags ( text -- open-tag close-tag ) dup open-tag swap close-tag ;

DEFER: 'inline'
LAZY: simple-tag ( start end html -- parser )
     both-tags [ \ drop , , ] [ ] make rot token swap <@ >r
     [ \ drop , , ] [ ] make swap token swap <@
     'inline' <(+)> <&> r> <&> ;

LAZY: prefix-tag ( pre html -- parser )
    >r 'inline' <!*> >r token r> &>
    r> both-tags [ swap , \ swap , , \ 3array , ] [ ] make <@ ;
    
LAZY: 'strong' ( -- parser ) "*" "*" "strong" simple-tag ;

LAZY: 'link' ( -- parser )
    "[" token [ drop "<a href=\"" ] <@ 'consume1' <(+)> <&> 
    "," token [ drop "\">" ] <@ <&>
    'consume1' <(+)> <&> "]" token [ drop "</a>" ] <@ <&> ;

LAZY: 'inline' ( -- parser )
    'strong' 
    'link' <|>
    'consume1' <|> ;

LAZY: 'h1' ( -- parser ) "=" "h1" prefix-tag ;
LAZY: 'h2' ( -- parser ) "==" "h2" prefix-tag ;
LAZY: 'h3' ( -- parser ) "===" "h3" prefix-tag ;
LAZY: 'h4' ( -- parser ) "====" "h4" prefix-tag ;
LAZY: 'h5' ( -- parser ) "=====" "h5" prefix-tag ;
LAZY: 'h6' ( -- parser ) "======" "h6" prefix-tag ;

LAZY: 'blockquote' ( -- parser ) "[\"" "\"]" "blockquote" simple-tag ;

LAZY: 'block' ( -- parser )
    'h6' 'h5' 'h4' 'h3' 'h2' 'h1' <|> <|> <|> <|> <|>
    'blockquote' <|>
    'inline' <!+> [ "<p>" swap "</p>" 3array ] <@ <|> ;

LAZY: 'farkup' ( -- parser )
    'block' '\n' <!+> 'block' <&> <!*> <&> ;

GENERIC: tree-write ( object -- )

PREDICATE: sequence non-leaf dup number? swap string? or not ;
M: non-leaf tree-write ( sequence -- ) [ tree-write ] each ;
    
M: string tree-write ( string -- ) write ;

M: number tree-write ( char -- ) write1 ;

: farkup ( str -- html )
    'farkup' parse dup nil? 
    [ error ] [ car parse-result-parsed [ tree-write ] string-out ] if ;

! useful debugging code below

: farkup-backtracks ( wiki -- backtracks )
    ! for debugging and optimization only
    'farkup' parse list>array length ;

: farkup-parsed ( wiki -- all-parses )
    ! for debugging and optimization only
    'farkup' parse list>array 
    [ parse-result-parsed [ tree-write ] string-out ] map ;