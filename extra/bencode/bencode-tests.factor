USING: bencode tools.test ;

{ "i42e" } [ 42 >bencode ] unit-test
{ "i0e" } [ 0 >bencode ] unit-test
{ "i-42e" } [ -42 >bencode ] unit-test

{ "4:spam" } [ "spam" >bencode ] unit-test

{ { "spam" 42 } } [ "l4:spami42ee" bencode> ] unit-test

{ H{ { "bar" "spam" } { "foo" 42 } } } [
    "d3:bar4:spam3:fooi42ee" bencode>
] unit-test
