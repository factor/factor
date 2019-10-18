USING: accessors sequences tools.test hashcash ;

[ t ] [ "foo@bar.com" mint check-stamp ] unit-test

[ t ] [ 
    <hashcash> 
        "foo@bar.com" >>resource 
        16 >>bits 
    mint* check-stamp ] unit-test

[ t ] [ 
    "1:20:040927:mertz@gnosis.cx::odVZhQMP:7ca28" check-stamp
] unit-test

[ 8 ] [ 8 salt length ] unit-test
