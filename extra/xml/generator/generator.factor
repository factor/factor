! Copyright (C) 2006, 2007 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces kernel xml.data xml.utilities assocs splitting
sequences parser quotations sequences.lib ;
IN: xml.generator

: comment, ( string -- ) <comment> , ;
: directive, ( string -- ) <directive> , ;
: instruction, ( string -- ) <instruction> , ;
: nl, ( -- ) "\n" , ;

: (tag,) ( name attrs quot -- tag )
    -rot >r >r V{ } make r> r> rot <tag> ; inline
: tag*, ( name attrs quot -- )
    (tag,) , ; inline

: contained*, ( name attrs -- )
    f <tag> , ;

: tag, ( name quot -- ) f swap tag*, ; inline
: contained, ( name -- ) f contained*, ; inline

: make-xml* ( name attrs quot -- xml )
    (tag,) build-xml ; inline
: make-xml ( name quot -- xml )
    f swap make-xml* ; inline

SYMBOL: namespace-table
: with-namespaces ( table quot -- )
    >r H{ } assoc-like namespace-table r> with-variable ; inline

: parsed-name ( accum -- accum )
    scan ":" split1 [ f <name> ] [ <name-tag> ] if* parsed ;

: run-combinator ( accum quot1 quot2 -- accum )
    >r [ ] like parsed r> [ parsed ] each ;

: parse-tag-contents ( accum contained? -- accum )
    [ \ contained*, parsed ] [
        scan-word \ [ =
        [ POSTPONE: [ \ tag*, parsed ]
        [ "Expected [ missing" <parse-error> throw ] if
    ] if ;

DEFER: >>

: attributes-parsed ( accum quot -- accum )
    dup empty? [ drop f parsed ] [
        >r \ >r parsed r> parsed
        [ H{ } make-assoc r> swap ] [ parsed ] each
    ] if ;

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
