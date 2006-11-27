IN: ref-template
USING: kernel xml sequences hashtables tools io arrays namespaces generic ;

SYMBOL: ref-table

: replace-ref ( ref -- object )
    reference-name ref-table get hash call ;

: r-ref-string ( xml-string -- xml-string )
    xml-string-array [
        dup reference? [ replace-ref ] when
    ] map <xml-string> ;

GENERIC: (r-ref) ( xml -- object )
M: any-tag (r-ref)
    dup tag-props dup [
        dup [ r-ref-string swap set ] hash-each 
    ] bind over set-tag-props ;
M: reference (r-ref)
    replace-ref ;
M: object (r-ref) ;

: replace-refs ( xml -- xml )
    [ (r-ref) ] xml-map ;

! Example

: test-refs
    H{
        { "foo" [ "foo" ] }
        { "bar" [ [ .s ] string-out ] }
        { "baz" [ "<a/>" string>xml delegate ] }
    } ref-table set
    "<x>%foo;<y prop='blah%foo;'>%bar;</y>%baz;</x>" string>xml
    replace-refs ;

