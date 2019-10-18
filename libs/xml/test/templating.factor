IN: templating
USING: kernel xml sequences hashtables tools io arrays namespaces
    xml-data generic xml-utils xml-writer test ;

SYMBOL: ref-table

: replace ( ref -- object )
    entity-name ref-table get hash call ;

: ref-string ( seq -- seq )
    [
        dup entity? [ replace ] when
    ] map ;

GENERIC: (r-ref) ( xml -- object )
M: tag (r-ref)
    dup tag-props dup [
        dup [ ref-string swap set ] hash-each 
    ] bind over set-tag-props ;
M: entity (r-ref)
    replace ;
M: object (r-ref) ;

: template ( xml -- xml )
    [ (r-ref) ] xml-map ;

: template2 ( xml -- )
    ! template but in place
    [ (r-ref) ] xml-inject ;

! Example

: test-refs ( quot -- string )
    [
        H{
            { "foo" [ "foo" ] }
            { "bar" [ [ .s ] string-out ] }
            { "baz" [ "<a/>" string>xml delegate ] }
        } ref-table set
        "<x>&foo;<y prop='blah&foo;'>&bar;</y>&baz;</x>"
        string>xml swap call xml>string
    ] with-scope ;

[ "<?xml version=\"1.0\" encoding=\"iso-8859-1\" standalone=\"no\"?><x>foo<y prop=\"blahfoo\"></y><a/></x>\n" ] [
    [ template ] test-refs
] unit-test
! [ "<?xml version=\"1.0\" encoding=\"iso-8859-1\" standalone=\"no\"?><x>foo<y prop=\"blahfoo\"></y><a/></x>\n" ] [
!    [ dup template ] test-refs
! ] unit-test
