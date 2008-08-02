TUPLE: declared-fixnum { x fixnum } ;

[ t ] [
    [ { declared-fixnum } declare [ 1 + ] change-x ]
    { + fixnum+ >fixnum } inlined?
] unit-test

[ t ] [
    [ { declared-fixnum } declare x>> drop ]
    { slot } inlined?
] unit-test

[ t ] [
    [ hashtable new ] \ new inlined?
] unit-test

[ t ] [
    [ dup hashtable eq? [ new ] when ] \ new inlined?
] unit-test

[ f ] [
    [ { integer } declare -63 shift 4095 bitand ]
    \ shift inlined?
] unit-test

[ t ] [
    [ { integer } declare 127 bitand 3 + ]
    { + +-integer-fixnum +-integer-fixnum-fast bitand } inlined?
] unit-test

[ f ] [
    [ { integer } declare 127 bitand 3 + ]
    { >fixnum } inlined?
] unit-test

[ t ] [
    [
        { integer } declare
        dup 0 >= [
            615949 * 797807 + 20 2^ mod dup 19 2^ -
        ] [ dup ] if
    ] { * + shift mod fixnum-mod fixnum* fixnum+ fixnum- } inlined?
] unit-test

[ t ] [
    [
        { fixnum } declare
        615949 * 797807 + 20 2^ mod dup 19 2^ -
    ] { >fixnum } inlined?
] unit-test

[ t ] [
    [
        { integer } declare 0 swap
        [
            drop 615949 * 797807 + 20 2^ rem dup 19 2^ -
        ] map
    ] { * + shift rem mod fixnum-mod fixnum* fixnum+ fixnum- } inlined?
] unit-test

[ t ] [
    [
        { fixnum } declare 0 swap
        [
            drop 615949 * 797807 + 20 2^ rem dup 19 2^ -
        ] map
    ] { * + shift rem mod fixnum-mod fixnum* fixnum+ fixnum- >fixnum } inlined?
] unit-test

[ t ] [
    [ { string sbuf } declare ] \ push-all def>> append \ + inlined?
] unit-test

[ t ] [
    [ { string sbuf } declare ] \ push-all def>> append \ fixnum+ inlined?
] unit-test

[ t ] [
    [ { string sbuf } declare ] \ push-all def>> append \ >fixnum inlined?
] unit-test



[ t ] [
    [
        { integer } declare [ 256 mod ] map
    ] { mod fixnum-mod } inlined?
] unit-test


[ f ] [
    [
        256 mod
    ] { mod fixnum-mod } inlined?
] unit-test

[ f ] [
    [
        dup 0 >= [ 256 mod ] when
    ] { mod fixnum-mod } inlined?
] unit-test

[ t ] [
    [
        { integer } declare dup 0 >= [ 256 mod ] when
    ] { mod fixnum-mod } inlined?
] unit-test

[ t ] [
    [
        { integer } declare 256 rem
    ] { mod fixnum-mod } inlined?
] unit-test

[ t ] [
    [
        { integer } declare [ 256 rem ] map
    ] { mod fixnum-mod rem } inlined?
] unit-test
