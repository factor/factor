! Copyright (C) 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: lexer parser splitting kernel quotations namespaces
sequences assocs sequences.lib xml.generator xml.utilities
xml.data ;
IN: xml.syntax

: parsed-name ( accum -- accum )
    scan ":" split1 [ f <name> ] [ <simple-name> ] if* parsed ;

: run-combinator ( accum quot1 quot2 -- accum )
    >r [ ] like parsed r> [ parsed ] each ;

: parse-tag-contents ( accum contained? -- accum )
    [ \ contained*, parsed ] [
        scan-word \ [ =
        [ POSTPONE: [ \ tag*, parsed ]
        [ "Expected [ missing" throw ] if
    ] if ;

DEFER: >>

: attributes-parsed ( accum quot -- accum )
    [ f parsed ] [
        >r \ >r parsed r> parsed
        [ H{ } make-assoc r> swap ] [ parsed ] each
    ] if-empty ;

: <<
    parsed-name [
        \ >> parse-until >quotation
        attributes-parsed \ contained? get
    ] with-scope parse-tag-contents ; parsing

: ==
    \ call parsed parsed-name \ set parsed ; parsing

: //
    \ contained? on ; parsing

: parse-special ( accum end-token word -- accum )
    >r parse-tokens " " join parsed r> parsed ;

: <!-- "-->" \ comment, parse-special ; parsing

: <!  ">" \ directive, parse-special ; parsing

: <? "?>" \ instruction, parse-special ; parsing

: >xml-document ( seq -- xml )
    dup first prolog? [ unclip-slice ] [ standard-prolog ] if swap
    [ tag? ] split-around <xml> ;

DEFER: XML>

: <XML
    \ XML> [ >quotation ] parse-literal
    { } parsed \ make parsed \ >xml-document parsed ; parsing
