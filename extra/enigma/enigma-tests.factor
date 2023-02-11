
USING: enigma kernel math sequences sorting tools.test ;

{ t } [ <reflector> sort 26 <iota> sequence= ] unit-test

{ "" } [ "" 4 <enigma> encode ] unit-test

{ "hello, world" } [
    "hello, world" 4 <enigma> [ encode ] keep reset-cogs encode
] unit-test
