! Copyright (C) 2005, 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel namespaces sequences vocabs.loader
xml.state ;
IN: xml.errors

TUPLE: xml-error-at line column ;

: xml-error-at ( class -- obj )
    new
        get-line >>line
        get-column >>column ;

TUPLE: expected < xml-error-at should-be was ;

: expected ( should-be was -- * )
    \ expected xml-error-at
        swap >>was
        swap >>should-be throw ;

TUPLE: unexpected-end < xml-error-at ;

: unexpected-end ( -- * ) \ unexpected-end xml-error-at throw ;

TUPLE: missing-close < xml-error-at ;

: missing-close ( -- * ) \ missing-close xml-error-at throw ;

TUPLE: disallowed-char < xml-error-at char ;

: disallowed-char ( char -- * )
    \ disallowed-char xml-error-at swap >>char throw ;

ERROR: multitags ;

ERROR: pre/post-content string pre? ;

TUPLE: no-entity < xml-error-at thing ;

: no-entity ( string -- * )
    \ no-entity xml-error-at swap >>thing throw ;

TUPLE: mismatched < xml-error-at open close ;

: mismatched ( open close -- * )
    \ mismatched xml-error-at swap >>close swap >>open throw ;

TUPLE: unclosed < xml-error-at tags ;

: unclosed ( -- * )
    \ unclosed xml-error-at
        xml-stack get rest-slice [ first name>> ] map >>tags
    throw ;

TUPLE: bad-uri < xml-error-at string ;

: bad-uri ( string -- * )
    \ bad-uri xml-error-at swap >>string throw ;

TUPLE: nonexist-ns < xml-error-at name ;

: nonexist-ns ( name-string -- * )
    \ nonexist-ns xml-error-at swap >>name throw ;

! this should give which tag was unopened
TUPLE: unopened < xml-error-at ;

: unopened ( -- * )
    \ unopened xml-error-at throw ;

TUPLE: not-yes/no < xml-error-at text ;

: not-yes/no ( text -- * )
    \ not-yes/no xml-error-at swap >>text throw ;

! this should actually print the names
TUPLE: extra-attrs < xml-error-at attrs ;

: extra-attrs ( attrs -- * )
    \ extra-attrs xml-error-at swap >>attrs throw ;

TUPLE: bad-version < xml-error-at num ;

: bad-version ( num -- * )
    \ bad-version xml-error-at swap >>num throw ;

ERROR: notags ;

TUPLE: bad-prolog < xml-error-at prolog ;

: bad-prolog ( prolog -- * )
    \ bad-prolog xml-error-at swap >>prolog throw ;

TUPLE: capitalized-prolog < xml-error-at name ;

: capitalized-prolog ( name -- capitalized-prolog )
    \ capitalized-prolog xml-error-at swap >>name throw ;

TUPLE: versionless-prolog < xml-error-at ;

: versionless-prolog ( -- * )
    \ versionless-prolog xml-error-at throw ;

TUPLE: bad-directive < xml-error-at dir ;

: bad-directive ( directive -- * )
    \ bad-directive xml-error-at swap >>dir throw ;

TUPLE: bad-decl < xml-error-at ;

: bad-decl ( -- * )
    \ bad-decl xml-error-at throw ;

TUPLE: bad-external-id < xml-error-at ;

: bad-external-id ( -- * )
    \ bad-external-id xml-error-at throw ;

TUPLE: misplaced-directive < xml-error-at dir ;

: misplaced-directive ( directive -- * )
    \ misplaced-directive xml-error-at swap >>dir throw ;

TUPLE: bad-name < xml-error-at name ;

: bad-name ( name -- * )
    \ bad-name xml-error-at swap >>name throw ;

TUPLE: unclosed-quote < xml-error-at ;

: unclosed-quote ( -- * )
    \ unclosed-quote xml-error-at throw ;

TUPLE: quoteless-attr < xml-error-at ;

: quoteless-attr ( -- * )
    \ quoteless-attr xml-error-at throw ;

TUPLE: attr-w/< < xml-error-at ;

: attr-w/< ( -- * )
    \ attr-w/< xml-error-at throw ;

TUPLE: text-w/]]> < xml-error-at ;

: text-w/]]> ( -- * )
    \ text-w/]]> xml-error-at throw ;

TUPLE: duplicate-attr < xml-error-at key values ;

: duplicate-attr ( key values -- * )
    \ duplicate-attr xml-error-at
    swap >>values swap >>key throw ;

TUPLE: bad-cdata < xml-error-at ;

: bad-cdata ( -- * )
    \ bad-cdata xml-error-at throw ;

TUPLE: not-enough-characters < xml-error-at ;

: not-enough-characters ( -- * )
    \ not-enough-characters xml-error-at throw ;

TUPLE: bad-doctype < xml-error-at contents ;

: bad-doctype ( contents -- * )
    \ bad-doctype xml-error-at swap >>contents throw ;

TUPLE: bad-encoding < xml-error-at encoding ;

: bad-encoding ( encoding -- * )
    \ bad-encoding xml-error-at
        swap >>encoding
    throw ;

UNION: xml-error
    multitags notags pre/post-content xml-error-at ;

{ "xml.errors" "debugger" } "xml.errors.debugger" require-when
