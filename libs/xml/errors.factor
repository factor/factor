! Copyright (C) 2005, 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: xml-data kernel generic io prettyprint math errors sequences xml-writer 
    state-parser ;
IN: xml-errors

TUPLE: no-entity thing ;
C: no-entity ( string -- entitiy )
    [ <parsing-error> swap set-delegate ] keep
    [ set-no-entity-thing ] keep ;
M: no-entity error.
    dup parsing-error.
    "Entity does not exist: &" write no-entity-thing write ";" print ;

TUPLE: xml-string-error string ; ! this should not exist
C: xml-string-error ( string -- xml-string-error )
    [ set-xml-string-error-string ] keep
    [ <parsing-error> swap set-delegate ] keep ;
M: xml-string-error error.
    dup parsing-error.
    xml-string-error-string print ;

TUPLE: mismatched open close ;
C: mismatched
    [ <parsing-error> swap set-delegate ] keep
    [ set-mismatched-close ] keep
    [ set-mismatched-open ] keep ;
M: mismatched error.
    dup parsing-error.
    "Mismatched tags" print
    "Opening tag: <" write dup mismatched-open print-name ">" print
    "Closing tag: </" write mismatched-close print-name ">" print ;

TUPLE: unclosed tags ;
! <unclosed> is ( -- unclosed ), see presentation.factor
M: unclosed error.
    "Unclosed tags" print
    "Tags: " print
    unclosed-tags [ "  <" write print-name ">" print ] each ;

TUPLE: bad-uri string ;
C: bad-uri ( string -- bad-uri )
    <parsing-error> over set-delegate
    tuck set-bad-uri-string ;
M: bad-uri error.
    dup parsing-error.
    "Bad URI:" print bad-uri-string . ;

TUPLE: nonexist-ns name ;
C: nonexist-ns ( name-string -- nonexist-ns )
    [ set-nonexist-ns-name ] keep
    [ <parsing-error> swap set-delegate ] keep ;
M: nonexist-ns error.
    dup parsing-error.
    "Namespace " write nonexist-ns-name write " has not been declared" print ;

TUPLE: unopened ; ! this should give which tag was unopened
C: unopened ( -- unopened )
    <parsing-error> over set-delegate ;
M: unopened error.
    parsing-error.
    "Closed an unopened tag" print ;

TUPLE: not-yes/no text ;
C: not-yes/no ( text -- not-yes/no )
    <parsing-error> over set-delegate
    tuck set-not-yes/no-text ;
M: not-yes/no error.
    dup parsing-error.
    "standalone must be either yes or no, not \"" write
    not-yes/no-text write "\"." print ;

TUPLE: extra-attrs attrs ; ! this should actually print the names
C: extra-attrs ( attrs -- extra-attrs )
    <parsing-error> over set-delegate
    tuck set-extra-attrs-attrs ;
M: extra-attrs error.
    dup parsing-error.
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

TUPLE: bad-prolog prolog ;
C: bad-prolog ( prolog -- bad-prolog )
    <parsing-error> over set-delegate
    tuck set-bad-prolog-prolog ;
M: bad-prolog error.
    dup parsing-error.
    "Misplaced XML prolog" print
    bad-prolog-prolog xml-preamble terpri ;

TUPLE: capitalized-prolog name ;
C: capitalized-prolog ( name -- capitalized-prolog )
    <parsing-error> over set-delegate
    tuck set-capitalized-prolog-name ;
M: capitalized-prolog error.
    dup parsing-error.
    "XML prolog name was partially or totally capitalized, using" print
    "<?" write capitalized-prolog-name write "...?>" write
    " instead of <?xml...?>" print ;

TUPLE: pre/post-content string pre? ;
M: pre/post-content error.
    "The text string:" print
    dup pre/post-content-string .
    "was used " write
    pre/post-content-pre? "before" "after" ? write
    " the main tag." print ;

TUPLE: versionless-prolog ;
C: versionless-prolog ( -- versionless-prolog )
    <parsing-error> over set-delegate ;
M: versionless-prolog error.
    parsing-error.
    "XML prolog lacks a version declaration" print ;

TUPLE: bad-instruction inst ;
C: bad-instruction ( instruction -- bad-instruction )
    <parsing-error> over set-delegate
    tuck set-bad-instruction-inst ;
M: bad-instruction error.
    dup parsing-error.
    "Misplaced processor instruction:" print
    bad-instruction-inst write-item terpri ;

TUPLE: bad-directive dir ;
C: bad-directive ( directive -- bad-directive )
    <parsing-error> over set-delegate
    tuck set-bad-directive-dir ;
M: bad-directive error.
    dup parsing-error.
    "Misplaced directive:" print
    bad-directive-dir write-item terpri ;

UNION: xml-parse-error multitags notags extra-attrs nonexist-ns
       not-yes/no unclosed mismatched xml-string-error expected no-entity
       bad-prolog versionless-prolog capitalized-prolog bad-instruction
       bad-directive ;
