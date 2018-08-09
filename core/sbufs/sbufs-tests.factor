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

{ ch'h } [ 0 sbuf"hello world" nth ] unit-test
{ ch'H } [
    ch'H 0 sbuf"hello world" [ set-nth ] keep first
] unit-test

{ sbuf"x" } [ 1 <sbuf> ch'x >bignum suffix! ] unit-test

{ fixnum } [ 1 >bignum sbuf"" new-sequence length class-of ] unit-test

{ fixnum } [ 1 >bignum <iota> [ ] sbuf"" map-as length class-of ] unit-test

[ 1.5 sbuf"" new-sequence ] must-fail

[ ch'A 0.5 0.5 sbuf"a" set-nth-unsafe ] must-fail
