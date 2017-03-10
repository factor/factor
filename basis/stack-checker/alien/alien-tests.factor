USING: accessors alien alien.c-types alien.private kernel
kernel.private literals math namespaces stack-checker.alien
stack-checker.state stack-checker.values system threads.private
tools.test ;
IN: stack-checker.alien.tests

! alien-inputs/outputs
{
    V{ 31 32 }
    { 33 }
} [
    0 inner-d-index set
    V{ } clone (meta-d) set
    H{ } clone known-values set
    V{ } clone literals set
    30 \ <value> set-global
    alien-node-params new int >>return { int int } >>parameters
    inputs/outputs
] unit-test

{
    V{ 31 32 33 }
    { 34 }
} [
    0 inner-d-index set
    V{ } clone (meta-d) set
    H{ } clone known-values set
    V{ } clone literals set
    30 \ <value> set-global
    alien-indirect-params new int >>return { int int } >>parameters
    inputs/outputs
] unit-test

! wrap-callback-quot
${
    cpu x86.32?
    [
        [
            { integer integer } declare [ [ ] dip ] dip
            "hello" >integer
        ] [
            dup current-callback eq?
            [ drop ] [ wait-for-callback ] if
        ] do-callback
    ]
    [
        [
            { fixnum fixnum } declare [ [ ] dip ] dip
            "hello" >fixnum
        ] [
            dup current-callback eq?
            [ drop ] [ wait-for-callback ] if
        ] do-callback
    ] ?
} [
    int { int int } cdecl f alien-node-params boa
    [ "hello" ] wrap-callback-quot
] unit-test
