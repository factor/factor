IN: temporary
USING: kernel namespaces sequences strings test ;

[ "Hello" ] [
    100 <sbuf> "buf" set
    "Hello" "buf" get sbuf-append
    "buf" get sbuf-clone "buf-clone" set
    "World" "buf-clone" get sbuf-append
    "buf" get sbuf>string
] unit-test

[ CHAR: h ] [ 0 SBUF" hello world" nth ] unit-test
[ CHAR: H ] [
    CHAR: H 0 SBUF" hello world" [ set-nth ] keep 0 swap nth
] unit-test
