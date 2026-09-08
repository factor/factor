USING: accessors alien alien.c-types alien.private kernel
kernel.private literals math namespaces sequences stack-checker.alien
stack-checker.state stack-checker.values system threads.private
tools.test ;
IN: stack-checker.alien.tests

! The internal callback entry carries the five native cursor fields. The
! public quotation receives the single cursor constructed by its wrapper.
{ 7 1 } [
    alien-callback-params new int >>return { int double } >>parameters
    t >>varargs? stack-shape
] unit-test

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

USING: cpu.architecture system ;
[
    alien-invoke-params new { int } >>parameters -1 >>varargs? prepare-varargs
] [ invalid-varargs-count? ] must-fail-with
[
    alien-invoke-params new { int } >>parameters 2 >>varargs? prepare-varargs
] [ invalid-varargs-count? ] must-fail-with
cpu arm.64? os macos? and [
    [ alien-invoke-params new { int } >>parameters t >>varargs? prepare-varargs ]
    [ missing-varargs-count? ] must-fail-with
] when

USE: math.floats.small.c-types
! Windows leaves half/BF16 payload types intact; argument allocation moves
! them into GP registers for both named and anonymous arguments.
{ t } [
    alien-invoke-params new { half bfloat } >>parameters 1 >>varargs?
    prepare-varargs parameters>> length 2 =
] unit-test
