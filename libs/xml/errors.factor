USING: xml-data kernel generic io prettyprint math errors sequences ;
IN: xml-errors

TUPLE: xml-error line column line-str ;
! <xml-error> is ( -- xml-error ), see state-parser.factor

: xml-error. ( xml-error -- )
    "XML error" print
    "Line: " write dup xml-error-line .
    dup xml-error-line-str [
        write xml-error-column 1- [ " " write ] times
        "^" print
    ] [ drop "At the end of the document" print ] if* ;

TUPLE: expected should-be was ;
C: expected ( should-be was -- error )
    [ <xml-error> swap set-delegate ] keep
    [ set-expected-was ] keep
    [ set-expected-should-be ] keep ;
M: expected error.
    dup xml-error.
    "Token expected: " write dup expected-should-be print
    "Token present: " write expected-was print ;

TUPLE: no-entity thing ;
C: no-entity ( string -- entitiy )
    [ <xml-error> swap set-delegate ] keep
    [ set-no-entity-thing ] keep ;
M: no-entity error.
    dup xml-error.
    "Entity does not exist: &" write no-entity-thing write ";" print ;

TUPLE: xml-string-error string ;
C: xml-string-error ( string -- xml-string-error )
    [ set-xml-string-error-string ] keep
    [ <xml-error> swap set-delegate ] keep ;
M: xml-string-error error.
    dup xml-error.
    xml-string-error-string print ;

TUPLE: bad-name string ;
C: bad-name ( string -- bad-name )
    <xml-error> over set-delegate
    tuck set-bad-name-string ;
M: bad-name error.
    dup xml-error.
    "Bad name in XML entity or reference: " write
    bad-name-string print ;

TUPLE: mismatched open close ;
C: mismatched
    [ <xml-error> swap set-delegate ] keep
    [ set-mismatched-close ] keep
    [ set-mismatched-open ] keep ;
! M: mismatched error. is defined in writer.factor

TUPLE: unclosed tags ;
! <unclosed> is ( -- unclosed ), see presentation.factor
! M: unclosed error. is defined in writer.factor

TUPLE: bad-uri string ;
C: bad-uri ( string -- bad-uri )
    <xml-error> over set-delegate
    tuck set-bad-uri-string ;
M: bad-uri error.
    ! this should print out the URI, not the internal representation
    dup xml-error.
    "Bad URI:" print bad-uri-string . ;

TUPLE: nonexist-ns name ;
C: nonexist-ns ( name-string -- nonexist-ns )
    [ set-nonexist-ns-name ] keep
    [ <xml-error> swap set-delegate ] keep ;
M: nonexist-ns error.
    dup xml-error.
    "Namespace " write nonexist-ns-name write " has not been declared" print ;

TUPLE: unopened ;
C: unopened ( -- unopened )
    <xml-error> over set-delegate ;
M: unopened error.
    xml-error.
    "Closed an unopened tag" print ;

TUPLE: not-yes/no text ;
C: not-yes/no ( text -- not-yes/no )
    <xml-error> over set-delegate
    tuck set-not-yes/no-text ;
M: not-yes/no error.
    dup xml-error.
    "standalone must be either yes or no, not \"" write
    not-yes/no-text write "\"." print ;

TUPLE: extra-attrs attrs ;
C: extra-attrs ( attrs -- extra-attrs )
    <xml-error> over set-delegate
    tuck set-extra-attrs-attrs ;
M: extra-attrs error.
    dup xml-error.
    "Extra attributes included in xml version declaration:" print
    extra-attrs-attrs . ;

TUPLE: bad-version num ;
M: bad-version error.
    "XML version must be \"1.0\" or \"1.1\". Version here was " write
    bad-version-num . ;

TUPLE: notags ;
M: notags error.
    drop "XML document lacks a main tag" print ;

TUPLE: multitags ;
M: multitags error.
    drop "XML document contains multiple main tags" print ;

TUPLE: bad-prolog string ;
C: bad-prolog ( string -- bad-prolog )
    <xml-error> over set-delegate
    tuck set-bad-prolog-string ;
M: bad-prolog error.
    dup xml-error.
    "Malformed or misplaced XML prelude" print
    "<?" write bad-prolog-string write "?>" print ;

TUPLE: pre/post-content string pre? ;
M: pre/post-content error.
    "The text string:" print
    dup pre/post-content-string .
    "was used " write
    pre/post-content-pre? "before" "after" ? write
    " the main tag." print ;

UNION: xml-parse-error multitags notags xml-error extra-attrs nonexist-ns
       not-yes/no unclosed mismatched xml-string-error expected no-entity
       bad-name bad-prolog ;
