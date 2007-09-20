! Copyright (C) 2005, 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: xml.data xml.writer kernel generic io prettyprint math 
debugger sequences state-parser ;
IN: xml.errors

TUPLE: no-entity thing ;
: <no-entity> ( string -- error )
    { set-no-entity-thing } no-entity construct-parsing-error ;
M: no-entity error.
    dup parsing-error.
    "Entity does not exist: &" write no-entity-thing write ";" print ;

TUPLE: xml-string-error string ; ! this should not exist
: <xml-string-error> ( string -- xml-string-error )
    { set-xml-string-error-string }
    xml-string-error construct-parsing-error ;
M: xml-string-error error.
    dup parsing-error.
    xml-string-error-string print ;

TUPLE: mismatched open close ;
: <mismatched>
    { set-mismatched-open set-mismatched-close }
    mismatched construct-parsing-error ;
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
: <bad-uri> ( string -- bad-uri )
    { set-bad-uri-string } bad-uri construct-parsing-error ;
M: bad-uri error.
    dup parsing-error.
    "Bad URI:" print bad-uri-string . ;

TUPLE: nonexist-ns name ;
: <nonexist-ns> ( name-string -- nonexist-ns )
    { set-nonexist-ns-name }
    nonexist-ns construct-parsing-error ;
M: nonexist-ns error.
    dup parsing-error.
    "Namespace " write nonexist-ns-name write " has not been declared" print ;

TUPLE: unopened ; ! this should give which tag was unopened
: <unopened> ( -- unopened )
    { } unopened construct-parsing-error ;
M: unopened error.
    parsing-error.
    "Closed an unopened tag" print ;

TUPLE: not-yes/no text ;
: <not-yes/no> ( text -- not-yes/no )
    { set-not-yes/no-text } not-yes/no construct-parsing-error ;
M: not-yes/no error.
    dup parsing-error.
    "standalone must be either yes or no, not \"" write
    not-yes/no-text write "\"." print ;

TUPLE: extra-attrs attrs ; ! this should actually print the names
: <extra-attrs> ( attrs -- extra-attrs )
    { set-extra-attrs-attrs }
    extra-attrs construct-parsing-error ;
M: extra-attrs error.
    dup parsing-error.
    "Extra attributes included in xml version declaration:" print
    extra-attrs-attrs . ;

TUPLE: bad-version num ;
: <bad-version>
    { set-bad-version-num }
    bad-version construct-parsing-error ;
M: bad-version error.
    "XML version must be \"1.0\" or \"1.1\". Version here was " write
    bad-version-num . ;

TUPLE: notags ;
C: <notags> notags
M: notags error.
    drop "XML document lacks a main tag" print ;

TUPLE: multitags ;
C: <multitags> multitags
M: multitags error.
    drop "XML document contains multiple main tags" print ;

TUPLE: bad-prolog prolog ;
: <bad-prolog> ( prolog -- bad-prolog )
    { set-bad-prolog-prolog }
    bad-prolog construct-parsing-error ;
M: bad-prolog error.
    dup parsing-error.
    "Misplaced XML prolog" print
    bad-prolog-prolog write-prolog nl ;

TUPLE: capitalized-prolog name ;
: <capitalized-prolog> ( name -- capitalized-prolog )
    { set-capitalized-prolog-name }
    capitalized-prolog construct-parsing-error ;
M: capitalized-prolog error.
    dup parsing-error.
    "XML prolog name was partially or totally capitalized, using" print
    "<?" write capitalized-prolog-name write "...?>" write
    " instead of <?xml...?>" print ;

TUPLE: pre/post-content string pre? ;
C: <pre/post-content> pre/post-content
M: pre/post-content error.
    "The text string:" print
    dup pre/post-content-string .
    "was used " write
    pre/post-content-pre? "before" "after" ? write
    " the main tag." print ;

TUPLE: versionless-prolog ;
: <versionless-prolog> ( -- versionless-prolog )
    { } versionless-prolog construct-parsing-error ;
M: versionless-prolog error.
    parsing-error.
    "XML prolog lacks a version declaration" print ;

TUPLE: bad-instruction inst ;
: <bad-instruction> ( instruction -- bad-instruction )
    { set-bad-instruction-inst }
    bad-instruction construct-parsing-error ;
M: bad-instruction error.
    dup parsing-error.
    "Misplaced processor instruction:" print
    bad-instruction-inst write-item nl ;

TUPLE: bad-directive dir ;
: <bad-directive> ( directive -- bad-directive )
    { set-bad-directive-dir }
    bad-directive construct-parsing-error ;
M: bad-directive error.
    dup parsing-error.
    "Misplaced directive:" print
    bad-directive-dir write-item nl ;

UNION: xml-parse-error multitags notags extra-attrs nonexist-ns
       not-yes/no unclosed mismatched xml-string-error expected no-entity
       bad-prolog versionless-prolog capitalized-prolog bad-instruction
       bad-directive ;
