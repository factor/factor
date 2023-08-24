! Copyright (C) 2005, 2006 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: accessors debugger io kernel prettyprint sequences
xml.errors xml.writer ;
IN: xml.errors.debugger

M: xml-error error.
    "XML parsing error" print
    "Line: " write dup line>> .
    "Column: " write column>> . ;

M: expected error.
    dup call-next-method
    "Token expected: " write dup should-be>> print
    "Token present: " write was>> print ;

M: unexpected-end error.
    call-next-method
    "File unexpectedly ended." print ;

M: missing-close error.
    call-next-method
    "Missing closing token." print ;

M: disallowed-char error.
    dup call-next-method
    "Disallowed character in XML document: " write
    char>> write1 nl ;

M: multitags error.
    drop "XML document contains multiple main tags" print ;

M: pre/post-content error.
    "The text string:" print
    dup string>> .
    "was used " write
    pre?>> "before" "after" ? write
    " the main tag." print ;

M: no-entity error.
    dup call-next-method
    "Entity does not exist: &" write thing>> write ";" print ;

M: mismatched error.
    dup call-next-method
    "Mismatched tags" print
    "Opening tag: <" write dup open>> print-name ">" print
    "Closing tag: </" write close>> print-name ">" print ;

M: unclosed error.
    dup call-next-method
    "Unclosed tags" print
    "Tags: " print
    tags>> [ "  <" write print-name ">" print ] each ;

M: bad-uri error.
    dup call-next-method
    "Bad URI:" print string>> . ;

M: nonexist-ns error.
    dup call-next-method
    "Namespace " write name>> write " has not been declared" print ;

M: unopened error.
    call-next-method
    "Closed an unopened tag" print ;

M: not-yes/no error.
    dup call-next-method
    "standalone must be either yes or no, not \"" write
    text>> write "\"." print ;

M: extra-attrs error.
    dup call-next-method
    "Extra attributes included in xml version declaration:" print
    attrs>> . ;

M: bad-version error.
    "XML version must be \"1.0\" or \"1.1\". Version here was " write
    num>> . ;

M: notags error.
    drop "XML document lacks a main tag" print ;

M: bad-prolog error.
    dup call-next-method
    "Misplaced XML prolog" print
    prolog>> write-xml nl ;

M: capitalized-prolog error.
    dup call-next-method
    "XML prolog name was partially or totally capitalized, using" print
    "<?" write name>> write "...?>" write
    " instead of <?xml...?>" print ;

M: versionless-prolog error.
    call-next-method
    "XML prolog lacks a version declaration" print ;

M: bad-directive error.
    dup call-next-method
    "Unknown directive:" print
    dir>> print ;

M: bad-decl error.
    call-next-method "Extra content in directive" print ;

M: bad-external-id error.
    call-next-method "Bad external ID" print ;

M: misplaced-directive error.
    dup call-next-method
    "Misplaced directive:" print
    dir>> write-xml nl ;

M: bad-name error.
    dup call-next-method
    "Invalid name: " write name>> print ;

M: unclosed-quote error.
    call-next-method
    "XML document ends with quote still open" print ;

M: quoteless-attr error.
    call-next-method "Attribute lacks quotes around value" print ;

M: attr-w/< error.
    call-next-method
    "Attribute value contains literal <" print ;

M: text-w/]]> error.
    call-next-method
    "Text node contains ']]>'" print ;

M: duplicate-attr error.
    call-next-method "Duplicate attribute" print ;

M: bad-cdata error.
    call-next-method "CDATA occurs before or after main tag" print ;

M: not-enough-characters error.
    call-next-method
    "Not enough characters" print ;

M: bad-doctype error.
    call-next-method "DTD contains invalid object" print ;

M: bad-encoding error.
    call-next-method
    "Encoding in XML document does not exist" print ;
