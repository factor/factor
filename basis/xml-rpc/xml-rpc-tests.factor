USING: xml-rpc tools.test ;

{ T{ rpc-method f "blah" { 1 H{ { "2" 3 } { "5" t } } } } }
[ "blah" { 1 H{ { "2" 3 } { "5" t } } }
    <rpc-method> send-rpc receive-rpc ] unit-test
