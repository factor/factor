USING: xml-rpc test ;

[ T{ rpc-method f "blah" { 1 H{ { "2" 3 } { "5" "foobar" } } } } ]
[ "blah" { 1 H{ { "2" 3 } { "5" "foobar" } } }
    <rpc-method> send-rpc receive-rpc ] unit-test 
