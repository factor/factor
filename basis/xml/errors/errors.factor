! Copyright (C) 2005, 2006 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: accessors classes classes.tuple classes.tuple.parser
classes.tuple.private combinators generalizations kernel math
namespaces parser sequences vocabs.loader words xml.state ;
IN: xml.errors

<<

PREDICATE: generated-xml-error < tuple class-of "xml-error-class" word-prop ;

: define-xml-error-class ( class superclass slots -- )
    { "line" "column" } prepend error-slots {
        [ define-tuple-class ]
        [ 2drop reset-generic ]
        [ 2drop t "error-class" set-word-prop ]
        [ 2drop t "xml-error-class" set-word-prop ]
        [
            [
                length 1 - nip dupd
                [ [ get-line get-column ] swap ndip boa throw ]
                2curry
            ]
            [ 2drop all-slots 2 head* thrower-effect ] 3bi define-declared
        ]
    } 3cleave ;

SYNTAX: XML-ERROR:
    parse-tuple-definition pick save-location
    define-xml-error-class ;

>>

XML-ERROR: expected should-be was ;

XML-ERROR: unexpected-end ;

XML-ERROR: missing-close ;

XML-ERROR: disallowed-char char ;

ERROR: multitags ;

ERROR: pre/post-content string pre? ;

XML-ERROR: no-entity thing ;

XML-ERROR: mismatched open close ;

TUPLE: unclosed line column tags ;

: throw-unclosed ( -- * )
    get-line get-column
    xml-stack get rest-slice [ first name>> ] map
    unclosed boa throw ;

XML-ERROR: bad-uri string ;

XML-ERROR: nonexist-ns name ;

! this should give which tag was unopened
XML-ERROR: unopened ;

XML-ERROR: not-yes/no text ;

! this should actually print the names
XML-ERROR: extra-attrs attrs ;

XML-ERROR: bad-version num ;

ERROR: notags ;

XML-ERROR: bad-prolog prolog ;

XML-ERROR: capitalized-prolog name ;

XML-ERROR: versionless-prolog ;

XML-ERROR: bad-directive dir ;

XML-ERROR: bad-decl ;

XML-ERROR: bad-external-id ;

XML-ERROR: misplaced-directive dir ;

XML-ERROR: bad-name name ;

XML-ERROR: unclosed-quote ;

XML-ERROR: quoteless-attr ;

XML-ERROR: attr-w/< ;

XML-ERROR: text-w/]]> ;

XML-ERROR: duplicate-attr key values ;

XML-ERROR: bad-cdata ;

XML-ERROR: not-enough-characters ;

XML-ERROR: bad-doctype read-contents ;

XML-ERROR: bad-encoding encoding ;

UNION: xml-error
    unclosed multitags notags pre/post-content generated-xml-error ;

{ "xml.errors" "debugger" } "xml.errors.debugger" require-when
