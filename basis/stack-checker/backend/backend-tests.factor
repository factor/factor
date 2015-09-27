USING: accessors classes.tuple compiler.tree stack-checker.backend tools.test
kernel namespaces stack-checker.state stack-checker.values
stack-checker.visitor sequences assocs ;
IN: stack-checker.backend.tests

{ } [
    V{ } clone (meta-d) set
    V{ } clone (meta-r) set
    V{ } clone literals set
    H{ } clone known-values set
    0 input-count set
    0 inner-d-index set
] unit-test

{ 0 } [ 0 ensure-d length ] unit-test

{ 2 } [ 2 ensure-d length ] unit-test

{ t } [ meta-d [ known-values get at input-parameter? ] all? ] unit-test

{ 2 } [ meta-d length ] unit-test

{ 3 } [ 3 ensure-d length ] unit-test
{ 3 } [ meta-d length ] unit-test

{ 1 } [ 1 ensure-d length ] unit-test
{ 3 } [ meta-d length ] unit-test

{ } [ 1 consume-d drop ] unit-test

{
    V{ 3 9 8 }
    H{ { 8 input-parameter } { 9 input-parameter } { 3 input-parameter } }
} [
    init-known-values
    V{ } clone stack-visitor set
    V{ 3 9 8 } introduce-values
    stack-visitor get first out-d>>
    known-values get
] unit-test

{ V{ 1 2 3 4 5 } } [
    0 \ <value> set-global init-inference 5 ensure-d
] unit-test

{ V{ 9 7 3 } } [
    V{ } clone stack-visitor set
    V{ 9 7 3 } (meta-d) set
    end-infer
    stack-visitor get first in-d>>
] unit-test

! Because node is an identity-tuple
: node-seqs-eq? ( seq1 seq2 -- ? )
    [ [ tuple-slots ] map concat ] bi@ = ;

! pop-d
{ t } [
    0 \ <value> set-global [
        V{ } clone stack-visitor set pop-d
    ] with-infer 2nip
    V{ T{ #introduce { out-d { 1 } } } T{ #return { in-d V{ } } } }
    node-seqs-eq?
] unit-test

: foo ( x -- )
    drop ;

{ t } [
    0 \ <value> set-global [
        V{ } clone stack-visitor set
        [ foo ] <literal> infer-literal-quot
    ] with-infer nip
    V{
        T{ #introduce { out-d { 1 } } }
        T{ #call { word foo } { in-d V{ 1 } } { out-d { } } }
        T{ #return { in-d V{ } } }
    } node-seqs-eq?
] unit-test
