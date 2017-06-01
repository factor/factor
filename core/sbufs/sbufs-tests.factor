USING: classes kernel math namespaces sbufs sequences
sequences.private strings tools.test ;

{ 5 } [ "Hello" >sbuf length ] unit-test

{ "Hello" } [
    100 <sbuf> "buf" set
    "Hello" "buf" get push-all
    "buf" get clone "buf-clone" set
    "World" "buf-clone" get push-all
    "buf" get >string
] unit-test

{ CHAR: h } [ 0 SBUF" hello world" nth ] unit-test
{ CHAR: H } [
    CHAR: H 0 SBUF" hello world" [ set-nth ] keep first
] unit-test

{ SBUF" x" } [ 1 <sbuf> CHAR: x >bignum suffix! ] unit-test

{ fixnum } [ 1 >bignum SBUF" " new-sequence length class-of ] unit-test

{ fixnum } [ 1 >bignum <iota> [ ] SBUF" " map-as length class-of ] unit-test

[ 1.5 SBUF" " new-sequence ] must-fail

[ CHAR: A 0.5 0.5 SBUF" a" set-nth-unsafe ] must-fail
