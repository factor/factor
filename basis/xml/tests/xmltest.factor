USING: accessors assocs combinators continuations fry generalizations
io.pathnames kernel macros sequences stack-checker tools.test xml
xml.utilities xml.writer arrays ;
IN: xml.tests.suite

TUPLE: xml-test id uri sections description type ;

: >xml-test ( tag -- test )
    xml-test new swap {
        [ "TYPE" swap at >>type ]
        [ "ID" swap at >>id ]
        [ "URI" swap at >>uri ]
        [ "SECTIONS" swap at >>sections ]
        [ children>> xml-chunk>string >>description ]
    } cleave ;

: parse-tests ( xml -- tests )
    "TEST" tags-named [ >xml-test ] map ;

: base "resource:basis/xml/tests/xmltest/" ;

MACRO: drop-output ( quot -- newquot )
    dup infer out>> '[ @ _ ndrop ] ;

MACRO: drop-input ( quot -- newquot )
    infer in>> '[ _ ndrop ] ;

: fails? ( quot -- ? )
    [ '[ _ drop-output f ] ]
    [ '[ drop _ drop-input t ] ] bi recover ; inline

: well-formed? ( uri -- answer )
    [ file>xml ] fails? "not-wf" "valid" ? ;

: test-quots ( test -- result quot )
    [ type>> '[ _ ] ]
    [ '[ _ uri>> base swap append-path well-formed? ] ] bi ;

: xml-tests ( -- tests )
    base "xmltest.xml" append-path file>xml
    parse-tests [ test-quots 2array ] map ;

: run-xml-tests ( -- )
    xml-tests [ unit-test ] assoc-each ;

: works? ( result quot -- ? )
    [ first ] [ call ] bi* = ;

: partition-xml-tests ( -- successes failures )
    xml-tests [ first2 works? ] partition ;

: failing-valids ( -- tests )
    partition-xml-tests nip [ second first ] map [ type>> "valid" = ] filter ;
