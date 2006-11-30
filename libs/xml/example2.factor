IN: templating
USING: kernel xml sequences hashtables tools io arrays namespaces generic ;

SYMBOL: ref-table

: replace ( ref -- object )
    reference-name ref-table get hash call ;

: ref-string ( seq -- seq )
    [
        dup reference? [ replace ] when
    ] map ;

GENERIC: (r-ref) ( xml -- object )
M: any-tag (r-ref)
    dup tag-props dup [
        dup [ ref-string swap set ] hash-each 
    ] bind over set-tag-props ;
M: reference (r-ref)
    replace ;
M: object (r-ref) ;

: template ( xml -- xml )
    [ (r-ref) ] xml-map ;

! Example

: test-refs
    H{
        { "foo" [ "foo" ] }
        { "bar" [ [ .s ] string-out ] }
        { "baz" [ "<a/>" string>xml delegate ] }
    } ref-table set
    "<x>%foo;<y prop='blah%foo;'>%bar;</y>%baz;</x>" string>xml
    template ;

