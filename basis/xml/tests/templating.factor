USING: kernel xml sequences assocs tools.test io arrays namespaces fry
accessors xml.data xml.traversal xml.writer generic sequences.deep multiline ;
IN: xml.tests

CONSTANT: sub-tag
    T{ name f f "sub" "http://littledan.onigirihouse.com/namespaces/replace" }

SYMBOL: ref-table

GENERIC: (r-ref) ( xml -- )
M: tag (r-ref)
    dup sub-tag attr [
        ref-table get at
        >>children drop
    ] [ drop ] if* ;
M: object (r-ref) drop ;

: template ( xml -- )
    [ (r-ref) ] deep-each ;

! Example

STRING: sample-doc
<html xmlns:f='http://littledan.onigirihouse.com/namespaces/replace'>
<body>
<span f:sub='foo'/>
<div f:sub='bar'/>
<p f:sub='baz'>paragraph</p>
</body></html>
;

STRING: expected-result
<?xml version="1.0" encoding="UTF-8"?>
<html xmlns:f="http://littledan.onigirihouse.com/namespaces/replace">
  <body>
    <span f:sub="foo">
      foo
    </span>
    <div f:sub="bar">
      blah
      <a/>
    </div>
    <p f:sub="baz"/>
  </body>
</html>
;

: test-refs ( -- string )
    [
        H{
            { "foo" { "foo" } }
            { "bar" { "blah" T{ tag f T{ name f "" "a" "" } T{ attrs } f } } }
            { "baz" f }
        } ref-table set
        sample-doc string>xml dup template pprint-xml>string
    ] with-scope ;

expected-result '[ _ ] [ test-refs ] unit-test
