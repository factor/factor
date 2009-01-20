USING: accessors assocs combinators continuations fry generalizations
io.pathnames kernel macros sequences stack-checker tools.test xml
xml.utilities xml.writer ;
IN: xml.tests.suite

TUPLE: test id uri sections description type ;

: >test ( tag -- test )
    test new swap {
        [ "TYPE" swap at >>type ]
        [ "ID" swap at >>id ]
        [ "URI" swap at >>uri ]
        [ "SECTIONS" swap at >>sections ]
        [ children>> xml-chunk>string >>description ]
    } cleave ;

: parse-tests ( xml -- tests )
    "TEST" tags-named [ >test ] map ;

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

: run-test ( test -- )
    [ type>> '[ _ ] ]
    [ '[ _ uri>> base swap append-path well-formed? ] ] bi
    unit-test ;

: run-tests ( -- )
    base "xmltest.xml" append-path file>xml
    parse-tests [ run-test ] each ;