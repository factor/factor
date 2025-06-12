IN: persistent.hashtables.identity.tests
USING: assocs hashtables.identity kernel literals namespaces persistent.assocs
persistent.hashtables.identity random sequences tools.test ;


! NOTE: copy-pasted from persistent hashtables more or less

! FROM: persistent.hashtables.identity.test => B ;

<<
TUPLE: foo
    val ;

CONSTANT: tuple-a T{ foo f "a" }
CONSTANT: tuple-b T{ foo f "a" }
SYMBOLS: A B C D E F ;
>>

{ t } [ IPH{ } assoc-empty? ] unit-test

{ IPH{ { A B } } } [ IPH{ } B A rot new-at ] unit-test

{ B } [ A IPH{ { A B } } at ] unit-test

{ f } [ "X" IPH{ { A B } } at ] unit-test

{ } [
    IPH{ }
    "a" 1 rot new-at
    "b" 2 rot new-at
    "nph" set
] unit-test

{
    IH{
        { 1 "a" }
        { 2 "b" }
    }
} [ "nph" get >identity-hashtable ] unit-test

{ } [
    IPH{ }
    "a" tuple-a rot new-at
    "b" tuple-b rot new-at
    "ph" set
] unit-test

{
    IH{
        { $ tuple-a "a" }
        { $ tuple-b "b" }
    }
} [ "ph" get >identity-hashtable ] unit-test

{
    IH{
        { $ tuple-b "b" }
    }
} [ "ph" get tuple-a swap pluck-at >identity-hashtable ] unit-test

{
    IH{
        { $ tuple-a "a" }
    }
} [ "ph" get tuple-b swap pluck-at >identity-hashtable ] unit-test

{
    IH{
        { $ tuple-a "a" }
        { $ tuple-b "b" }
    }
} [ "ph" get "X" swap pluck-at >identity-hashtable ] unit-test

{ } [
    IPH{ }
    B A rot new-at
    D C rot new-at
    "ph" set
] unit-test

{ IH{ { A B } { C D } } } [
    "ph" get >identity-hashtable
] unit-test

{ IH{ { C D } } } [
    "ph" get A swap pluck-at >identity-hashtable
] unit-test

{ IH{ { A B } { C D } { E F } } } [
    "ph" get F E rot new-at >identity-hashtable
] unit-test

{ IH{ { C D } { E F } } } [
    "ph" get F E rot new-at A swap pluck-at >identity-hashtable
] unit-test

: random-string ( -- str )
    1000000 random ;
    ! [ CHAR: a CHAR: z [a..b] random ] "" replicate-as ;

: random-assocs ( n -- hash phash )
    [ random-string ] replicate
    [ H{ } clone [ '[ swap _ set-at ] each-index ] keep ]
    [ IPH{ } clone swap [| ph elt i | i elt ph new-at ] each-index ]
    bi ;

: ok? ( assoc1 assoc2 -- ? )
    [ assoc= ] [ [ assoc-size ] same? ] 2bi and ;

: test-persistent-hashtables-1 ( n -- ? )
    random-assocs ok? ;

{ t } [ 10 test-persistent-hashtables-1 ] unit-test
{ t } [ 20 test-persistent-hashtables-1 ] unit-test
{ t } [ 30 test-persistent-hashtables-1 ] unit-test
{ t } [ 50 test-persistent-hashtables-1 ] unit-test
{ t } [ 100 test-persistent-hashtables-1 ] unit-test
{ t } [ 500 test-persistent-hashtables-1 ] unit-test
{ t } [ 1000 test-persistent-hashtables-1 ] unit-test
{ t } [ 5000 test-persistent-hashtables-1 ] unit-test
{ t } [ 10000 test-persistent-hashtables-1 ] unit-test
{ t } [ 50000 test-persistent-hashtables-1 ] unit-test

: test-persistent-hashtables-2 ( n -- ? )
    random-assocs
    dup keys [
        [ nip over delete-at ] [ swap pluck-at nip ] 3bi
        2dup ok?
    ] all? 2nip ;

{ t } [ 6000 test-persistent-hashtables-2 ] unit-test
