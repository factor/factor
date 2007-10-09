USING: kernel math namespaces sequences sbufs strings
tools.test classes ;
IN: temporary

[ 5 ] [ "Hello" >sbuf length ] unit-test

[ "Hello" ] [
    100 <sbuf> "buf" set
    "Hello" "buf" get push-all
    "buf" get clone "buf-clone" set
    "World" "buf-clone" get push-all
    "buf" get >string
] unit-test

[ CHAR: h ] [ 0 SBUF" hello world" nth ] unit-test
[ CHAR: H ] [
    CHAR: H 0 SBUF" hello world" [ set-nth ] keep first
] unit-test

[ SBUF" x" ] [ 1 <sbuf> CHAR: x >bignum over push ] unit-test

[ fixnum ] [ 1 >bignum SBUF" " new length class ] unit-test

[ fixnum ] [ 1 >bignum [ ] SBUF" " map-as length class ] unit-test
