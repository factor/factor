! Copyright (C) 2005, 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: xml.data xml.writer kernel generic io prettyprint math 
debugger sequences xml.state-parser accessors summary
namespaces io.streams.string xml.backend ;
IN: xml.errors

ERROR: multitags ;

M: multitags summary ( obj -- str )
    drop "XML document contains multiple main tags" ;

ERROR: pre/post-content string pre? ;

M: pre/post-content summary ( obj -- str )
    [
        "The text string:" print
        dup string>> .
        "was used " write
        pre?>> "before" "after" ? write
        " the main tag." print
    ] with-string-writer ;

TUPLE: no-entity < parsing-error thing ;

: no-entity ( string -- * )
    \ no-entity parsing-error swap >>thing throw ;

M: no-entity summary ( obj -- str )
    [
        dup call-next-method write
        "Entity does not exist: &" write thing>> write ";" print
    ] with-string-writer ;

TUPLE: mismatched < parsing-error open close ;

: mismatched ( open close -- * )
    \ mismatched parsing-error swap >>close swap >>open throw ;

M: mismatched summary ( obj -- str )
    [
        dup call-next-method write
        "Mismatched tags" print
        "Opening tag: <" write dup open>> print-name ">" print
        "Closing tag: </" write close>> print-name ">" print
    ] with-string-writer ;

TUPLE: unclosed < parsing-error tags ;

: unclosed ( -- * )
    \ unclosed parsing-error
        xml-stack get rest-slice [ first name>> ] map >>tags
    throw ;

M: unclosed summary ( obj -- str )
    [
        dup call-next-method write
        "Unclosed tags" print
        "Tags: " print
        tags>> [ "  <" write print-name ">" print ] each
    ] with-string-writer ;

TUPLE: bad-uri < parsing-error string ;

: bad-uri ( string -- * )
    \ bad-uri parsing-error swap >>string throw ;

M: bad-uri summary ( obj -- str )
    [
        dup call-next-method write
        "Bad URI:" print string>> .
    ] with-string-writer ;

TUPLE: nonexist-ns < parsing-error name ;

: nonexist-ns ( name-string -- * )
    \ nonexist-ns parsing-error swap >>name throw ;

M: nonexist-ns summary ( obj -- str )
    [
        dup call-next-method write
        "Namespace " write name>> write " has not been declared" print
    ] with-string-writer ;

TUPLE: unopened < parsing-error ; ! this should give which tag was unopened

: unopened ( -- * )
    \ unopened parsing-error throw ;

M: unopened summary ( obj -- str )
    [
        call-next-method write
        "Closed an unopened tag" print
    ] with-string-writer ;

TUPLE: not-yes/no < parsing-error text ;

: not-yes/no ( text -- * )
    \ not-yes/no parsing-error swap >>text throw ;

M: not-yes/no summary ( obj -- str )
    [
        dup call-next-method write
        "standalone must be either yes or no, not \"" write
        text>> write "\"." print
    ] with-string-writer ;

! this should actually print the names
TUPLE: extra-attrs < parsing-error attrs ;

: extra-attrs ( attrs -- * )
    \ extra-attrs parsing-error swap >>attrs throw ;

M: extra-attrs summary ( obj -- str )
    [
        dup call-next-method write
        "Extra attributes included in xml version declaration:" print
        attrs>> .
    ] with-string-writer ;

TUPLE: bad-version < parsing-error num ;

: bad-version ( num -- * )
    \ bad-version parsing-error swap >>num throw ;

M: bad-version summary ( obj -- str )
    [
        "XML version must be \"1.0\" or \"1.1\". Version here was " write
        num>> .
    ] with-string-writer ;

ERROR: notags ;

M: notags summary ( obj -- str )
    drop "XML document lacks a main tag" ;

TUPLE: bad-prolog < parsing-error prolog ;

: bad-prolog ( prolog -- * )
    \ bad-prolog parsing-error swap >>prolog throw ;

M: bad-prolog summary ( obj -- str )
    [
        dup call-next-method write
        "Misplaced XML prolog" print
        prolog>> write-prolog nl
    ] with-string-writer ;

TUPLE: capitalized-prolog < parsing-error name ;

: capitalized-prolog ( name -- capitalized-prolog )
    \ capitalized-prolog parsing-error swap >>name throw ;

M: capitalized-prolog summary ( obj -- str )
    [
        dup call-next-method write
        "XML prolog name was partially or totally capitalized, using" print
        "<?" write name>> write "...?>" write
        " instead of <?xml...?>" print
    ] with-string-writer ;

TUPLE: versionless-prolog < parsing-error ;

: versionless-prolog ( -- * )
    \ versionless-prolog parsing-error throw ;

M: versionless-prolog summary ( obj -- str )
    [
        call-next-method write
        "XML prolog lacks a version declaration" print
    ] with-string-writer ;

TUPLE: bad-instruction < parsing-error instruction ;

: bad-instruction ( instruction -- * )
    \ bad-instruction parsing-error swap >>instruction throw ;

M: bad-instruction summary ( obj -- str )
    [
        dup call-next-method write
        "Misplaced processor instruction:" print
        instruction>> write-xml-chunk nl
    ] with-string-writer ;

TUPLE: bad-directive < parsing-error dir ;

: bad-directive ( directive -- * )
    \ bad-directive parsing-error swap >>dir throw ;

M: bad-directive summary ( obj -- str )
    [
        dup call-next-method write
        "Unknown directive:" print
        dir>> write
    ] with-string-writer ;

TUPLE: bad-decl < parsing-error ;

: bad-decl ( -- * )
    \ bad-decl parsing-error throw ;

M: bad-decl summary ( obj -- str )
    call-next-method "\nExtra content in directive" append ;

TUPLE: bad-external-id < parsing-error ;

: bad-external-id ( -- * )
    \ bad-external-id parsing-error throw ;

M: bad-external-id summary ( obj -- str )
    call-next-method "\nBad external ID" append ;

TUPLE: misplaced-directive < parsing-error dir ;

: misplaced-directive ( directive -- * )
    \ misplaced-directive parsing-error swap >>dir throw ;

M: misplaced-directive summary ( obj -- str )
    [
        dup call-next-method write
        "Misplaced directive:" print
        dir>> write-xml-chunk nl
    ] with-string-writer ;

TUPLE: bad-name < parsing-error name ;

: bad-name ( name -- * )
    \ bad-name parsing-error swap >>name throw ;

M: bad-name summary ( obj -- str )
    [ call-next-method ]
    [ "Invalid name: " swap name>> "\n" 3append ]
    bi append ;

TUPLE: unclosed-quote < parsing-error ;

: unclosed-quote ( -- * )
    \ unclosed-quote parsing-error throw ;

M: unclosed-quote summary
    call-next-method
    "XML document ends with quote still open\n" append ;

TUPLE: quoteless-attr < parsing-error ;

: quoteless-attr ( -- * )
    \ quoteless-attr parsing-error throw ;

M: quoteless-attr summary
    call-next-method "Attribute lacks quotes around value\n" append ;

TUPLE: attr-w/< < parsing-error ;

: attr-w/< ( value -- * )
    \ attr-w/< parsing-error throw ;

M: attr-w/< summary
    call-next-method
    "Attribute value contains literal <" append ;

TUPLE: text-w/]]> < parsing-error ;

: text-w/]]> ( text -- * )
    \ text-w/]]> parsing-error throw ;

M: text-w/]]> summary
    call-next-method
    "Text node contains ']]>'" append ;

TUPLE: disallowed-char < parsing-error char ;

: disallowed-char ( char -- * )
    \ disallowed-char parsing-error swap >>char throw ;

M: disallowed-char summary
    [ call-next-method ]
    [ char>> "Disallowed character in XML document: " swap suffix ] bi
    append ;

TUPLE: duplicate-attr < parsing-error key values ;

: duplicate-attr ( key values -- * )
    \ duplicate-attr parsing-error
    swap >>values swap >>key throw ;

M: duplicate-attr summary
    call-next-method "\nDuplicate attribute" append ;

UNION: xml-parse-error
    multitags notags extra-attrs nonexist-ns bad-decl
    not-yes/no unclosed mismatched expected no-entity
    bad-prolog versionless-prolog capitalized-prolog bad-instruction
    bad-directive bad-name unclosed-quote quoteless-attr
    attr-w/< text-w/]]> duplicate-attr ;
