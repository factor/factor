! Copyright (C) 2005, 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: xml.data xml.writer kernel generic io prettyprint math 
debugger sequences xml.state accessors summary
namespaces io.streams.string ;
IN: xml.errors

TUPLE: xml-error-at line column ;

: xml-error-at ( class -- obj )
    new
        get-line >>line
        get-column >>column ;
M: xml-error-at summary ( obj -- str )
    [
        "XML parsing error" print
        "Line: " write dup line>> .
        "Column: " write column>> .
    ] with-string-writer ;

TUPLE: expected < xml-error-at should-be was ;
: expected ( should-be was -- * )
    \ expected xml-error-at
        swap >>was
        swap >>should-be throw ;
M: expected summary ( obj -- str )
    [
        dup call-next-method write
        "Token expected: " write dup should-be>> print
        "Token present: " write was>> print
    ] with-string-writer ;

TUPLE: unexpected-end < xml-error-at ;
: unexpected-end ( -- * ) \ unexpected-end xml-error-at throw ;
M: unexpected-end summary ( obj -- str )
    [
        call-next-method write
        "File unexpectedly ended." print
    ] with-string-writer ;

TUPLE: missing-close < xml-error-at ;
: missing-close ( -- * ) \ missing-close xml-error-at throw ;
M: missing-close summary ( obj -- str )
    [
        call-next-method write
        "Missing closing token." print
    ] with-string-writer ;

TUPLE: disallowed-char < xml-error-at char ;

: disallowed-char ( char -- * )
    \ disallowed-char xml-error-at swap >>char throw ;

M: disallowed-char summary
    [ call-next-method ]
    [ char>> "Disallowed character in XML document: " swap suffix ] bi
    append ;

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

TUPLE: no-entity < xml-error-at thing ;

: no-entity ( string -- * )
    \ no-entity xml-error-at swap >>thing throw ;

M: no-entity summary ( obj -- str )
    [
        dup call-next-method write
        "Entity does not exist: &" write thing>> write ";" print
    ] with-string-writer ;

TUPLE: mismatched < xml-error-at open close ;

: mismatched ( open close -- * )
    \ mismatched xml-error-at swap >>close swap >>open throw ;

M: mismatched summary ( obj -- str )
    [
        dup call-next-method write
        "Mismatched tags" print
        "Opening tag: <" write dup open>> print-name ">" print
        "Closing tag: </" write close>> print-name ">" print
    ] with-string-writer ;

TUPLE: unclosed < xml-error-at tags ;

: unclosed ( -- * )
    \ unclosed xml-error-at
        xml-stack get rest-slice [ first name>> ] map >>tags
    throw ;

M: unclosed summary ( obj -- str )
    [
        dup call-next-method write
        "Unclosed tags" print
        "Tags: " print
        tags>> [ "  <" write print-name ">" print ] each
    ] with-string-writer ;

TUPLE: bad-uri < xml-error-at string ;

: bad-uri ( string -- * )
    \ bad-uri xml-error-at swap >>string throw ;

M: bad-uri summary ( obj -- str )
    [
        dup call-next-method write
        "Bad URI:" print string>> .
    ] with-string-writer ;

TUPLE: nonexist-ns < xml-error-at name ;

: nonexist-ns ( name-string -- * )
    \ nonexist-ns xml-error-at swap >>name throw ;

M: nonexist-ns summary ( obj -- str )
    [
        dup call-next-method write
        "Namespace " write name>> write " has not been declared" print
    ] with-string-writer ;

TUPLE: unopened < xml-error-at ; ! this should give which tag was unopened

: unopened ( -- * )
    \ unopened xml-error-at throw ;

M: unopened summary ( obj -- str )
    [
        call-next-method write
        "Closed an unopened tag" print
    ] with-string-writer ;

TUPLE: not-yes/no < xml-error-at text ;

: not-yes/no ( text -- * )
    \ not-yes/no xml-error-at swap >>text throw ;

M: not-yes/no summary ( obj -- str )
    [
        dup call-next-method write
        "standalone must be either yes or no, not \"" write
        text>> write "\"." print
    ] with-string-writer ;

! this should actually print the names
TUPLE: extra-attrs < xml-error-at attrs ;

: extra-attrs ( attrs -- * )
    \ extra-attrs xml-error-at swap >>attrs throw ;

M: extra-attrs summary ( obj -- str )
    [
        dup call-next-method write
        "Extra attributes included in xml version declaration:" print
        attrs>> .
    ] with-string-writer ;

TUPLE: bad-version < xml-error-at num ;

: bad-version ( num -- * )
    \ bad-version xml-error-at swap >>num throw ;

M: bad-version summary ( obj -- str )
    [
        "XML version must be \"1.0\" or \"1.1\". Version here was " write
        num>> .
    ] with-string-writer ;

ERROR: notags ;

M: notags summary ( obj -- str )
    drop "XML document lacks a main tag" ;

TUPLE: bad-prolog < xml-error-at prolog ;

: bad-prolog ( prolog -- * )
    \ bad-prolog xml-error-at swap >>prolog throw ;

M: bad-prolog summary ( obj -- str )
    [
        dup call-next-method write
        "Misplaced XML prolog" print
        prolog>> write-xml nl
    ] with-string-writer ;

TUPLE: capitalized-prolog < xml-error-at name ;

: capitalized-prolog ( name -- capitalized-prolog )
    \ capitalized-prolog xml-error-at swap >>name throw ;

M: capitalized-prolog summary ( obj -- str )
    [
        dup call-next-method write
        "XML prolog name was partially or totally capitalized, using" print
        "<?" write name>> write "...?>" write
        " instead of <?xml...?>" print
    ] with-string-writer ;

TUPLE: versionless-prolog < xml-error-at ;

: versionless-prolog ( -- * )
    \ versionless-prolog xml-error-at throw ;

M: versionless-prolog summary ( obj -- str )
    [
        call-next-method write
        "XML prolog lacks a version declaration" print
    ] with-string-writer ;

TUPLE: bad-directive < xml-error-at dir ;

: bad-directive ( directive -- * )
    \ bad-directive xml-error-at swap >>dir throw ;

M: bad-directive summary ( obj -- str )
    [
        dup call-next-method write
        "Unknown directive:" print
        dir>> write
    ] with-string-writer ;

TUPLE: bad-decl < xml-error-at ;

: bad-decl ( -- * )
    \ bad-decl xml-error-at throw ;

M: bad-decl summary ( obj -- str )
    call-next-method "\nExtra content in directive" append ;

TUPLE: bad-external-id < xml-error-at ;

: bad-external-id ( -- * )
    \ bad-external-id xml-error-at throw ;

M: bad-external-id summary ( obj -- str )
    call-next-method "\nBad external ID" append ;

TUPLE: misplaced-directive < xml-error-at dir ;

: misplaced-directive ( directive -- * )
    \ misplaced-directive xml-error-at swap >>dir throw ;

M: misplaced-directive summary ( obj -- str )
    [
        dup call-next-method write
        "Misplaced directive:" print
        dir>> write-xml nl
    ] with-string-writer ;

TUPLE: bad-name < xml-error-at name ;

: bad-name ( name -- * )
    \ bad-name xml-error-at swap >>name throw ;

M: bad-name summary ( obj -- str )
    [ call-next-method ]
    [ "Invalid name: " swap name>> "\n" 3append ]
    bi append ;

TUPLE: unclosed-quote < xml-error-at ;

: unclosed-quote ( -- * )
    \ unclosed-quote xml-error-at throw ;

M: unclosed-quote summary
    call-next-method
    "XML document ends with quote still open\n" append ;

TUPLE: quoteless-attr < xml-error-at ;

: quoteless-attr ( -- * )
    \ quoteless-attr xml-error-at throw ;

M: quoteless-attr summary
    call-next-method "Attribute lacks quotes around value\n" append ;

TUPLE: attr-w/< < xml-error-at ;

: attr-w/< ( -- * )
    \ attr-w/< xml-error-at throw ;

M: attr-w/< summary
    call-next-method
    "Attribute value contains literal <" append ;

TUPLE: text-w/]]> < xml-error-at ;

: text-w/]]> ( -- * )
    \ text-w/]]> xml-error-at throw ;

M: text-w/]]> summary
    call-next-method
    "Text node contains ']]>'" append ;

TUPLE: duplicate-attr < xml-error-at key values ;

: duplicate-attr ( key values -- * )
    \ duplicate-attr xml-error-at
    swap >>values swap >>key throw ;

M: duplicate-attr summary
    call-next-method "\nDuplicate attribute" append ;

TUPLE: bad-cdata < xml-error-at ;

: bad-cdata ( -- * )
    \ bad-cdata xml-error-at throw ;

M: bad-cdata summary
    call-next-method "\nCDATA occurs before or after main tag" append ;

TUPLE: not-enough-characters < xml-error-at ;
: not-enough-characters ( -- * )
    \ not-enough-characters xml-error-at throw ;
M: not-enough-characters summary ( obj -- str )
    [
        call-next-method write
        "Not enough characters" print
    ] with-string-writer ;

TUPLE: bad-doctype < xml-error-at contents ;
: bad-doctype ( contents -- * )
    \ bad-doctype xml-error-at swap >>contents throw ;
M: bad-doctype summary
    call-next-method "\nDTD contains invalid object" append ;

UNION: xml-error
    multitags notags pre/post-content xml-error-at ;
