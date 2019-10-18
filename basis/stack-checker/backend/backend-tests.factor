USING: accessors assocs classes.tuple compiler.tree kernel namespaces
sequences stack-checker.backend stack-checker.dependencies
stack-checker.state stack-checker.values stack-checker.visitor
tools.test ;
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
    H{ } clone known-values set
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

! apply-object
SYMBOL: sam-sum

{ H{ } } [
    H{ } clone dependencies set
    H{ } clone known-values set
    init-inference
    [ \ sam-sum ] first apply-object
    dependencies get
] unit-test

{ V{ "abc" } } [
    H{ } clone known-values set
    init-inference
    "abc" apply-object
    literals get
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

! pop-literal
{
    2
} [
    V{ 1 2 } clone literals set pop-literal
] unit-test

{
    4321
} [
    init-inference 4321 <literal> make-known push-d pop-literal
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
