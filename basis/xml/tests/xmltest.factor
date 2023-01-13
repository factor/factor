USING: accessors assocs combinators combinators.smart
continuations fry generalizations io.pathnames kernel macros
sequences stack-checker tools.test xml xml.traversal xml.writer
arrays xml.data ;
IN: xml.tests.suite

TUPLE: xml-test id uri sections description type ;

: >xml-test ( tag -- test )
    xml-test new swap {
        [ "TYPE" attr >>type ]
        [ "ID" attr >>id ]
        [ "URI" attr >>uri ]
        [ "SECTIONS" attr >>sections ]
        [ children>> xml>string >>description ]
    } cleave ;

: parse-tests ( xml -- tests )
    "TEST" tags-named [ >xml-test ] map ;

CONSTANT: base "vocab:xml/tests/xmltest/"

: fails? ( quot -- ? )
    [ drop-outputs f ] [ nip drop-inputs t ] bi-curry recover ; inline

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
    [ first ] [ call( -- result ) ] bi* = ;

: partition-xml-tests ( -- successes failures )
    xml-tests [ first2 works? ] partition ;

: failing-valids ( -- tests )
    partition-xml-tests nip [ second first ] map [ type>> "valid" = ] filter ;

{ } [ partition-xml-tests 2drop ] unit-test
