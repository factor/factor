! Testing templates machinery without compiling anything
IN: temporary
USING: compiler generator generator.registers
generator.registers.private tools.test namespaces sequences
words kernel math effects ;

[
    [ ] [ init-templates ] unit-test
    
    [ V{ 3 } ] [ 3 fresh-object fresh-objects get ] unit-test
    
    [ ] [ 0 <int-vreg> phantom-push ] unit-test
    
    [ ] [ compute-free-vregs ] unit-test
    
    [ f ] [ 0 <int-vreg> T{ int-regs } free-vregs member? ] unit-test
    
    [ f ] [
        [
            copy-templates
            1 <int-vreg> phantom-push
            compute-free-vregs
            1 <int-vreg> T{ int-regs } free-vregs member?
        ] with-scope
    ] unit-test
    
    [ t ] [ 1 <int-vreg> T{ int-regs } free-vregs member? ] unit-test
] with-scope

[
    [ ] [ init-templates ] unit-test
    
    [ ] [ T{ effect f 3 { 1 2 0 } f } phantom-shuffle ] unit-test
    
    [ 3 ] [ live-locs length ] unit-test
    
    [ ] [ T{ effect f 2 { 1 0 } f } phantom-shuffle ] unit-test
    
    [ 2 ] [ live-locs length ] unit-test
] with-scope

[
    [ ] [ init-templates ] unit-test

    [ ] [ init-generator ] unit-test

    [ t ] [ [ end-basic-block ] { } make empty? ] unit-test

    3 fresh-object

    [ f ] [ [ end-basic-block ] { } make empty? ] unit-test
] with-scope

[
    [ ] [ init-templates ] unit-test
    
    H{
        { +input+ { { f "x" } } }
    } clone [
        [ 1 0 ] [ +input+ get { } { } guess-vregs ] unit-test
        [ ] [ 1 0 ensure-vregs ] unit-test
        ! [ t ] [ +input+ get phantom-d get compatible? ] unit-test
        [ ] [ finalize-contents ] unit-test
        [ ] [ [ template-inputs ] { } make drop ] unit-test
    ] bind
] with-scope

! Test template picking strategy
SYMBOL: template-chosen

: template-test ( a b -- c ) + ;

\ template-test {
    {
        [
            1 template-chosen get push
        ] H{
            { +input+ { { f "obj" } { [ ] "n" } } }
            { +output+ { "obj" } }
        }
    }
    {
        [
            2 template-chosen get push
        ] H{
            { +input+ { { f "obj" } { f "n" } } }
            { +output+ { "obj" } }
        }
    }
} define-intrinsics

[ V{ 2 } ] [
    V{ } clone template-chosen set
    [ template-test ] compile-quot drop
    template-chosen get
] unit-test

[ V{ 1 } ] [
    V{ } clone template-chosen set
    [ dup 0 template-test ] compile-quot drop
    template-chosen get
] unit-test

[ V{ 1 } ] [
    V{ } clone template-chosen set
    [ 0 template-test ] compile-quot drop
    template-chosen get
] unit-test

! Regression
[
    [ ] [ init-templates ] unit-test

    ! dup dup
    [ ] [
        T{ effect f { "x" } { "x" "x" } } phantom-shuffle
        T{ effect f { "x" } { "x" "x" } } phantom-shuffle
    ] unit-test

    ! This is not empty since a load instruction is emitted
    [ f ] [
        [ { { f "x" } } fast-input ] { } make empty?
    ] unit-test

    ! This is empty since we already loaded the value
    [ t ] [
        [ { { f "x" } } fast-input ] { } make empty?
    ] unit-test

    ! This is empty since we didn't change the stack
    [ t ] [ [ end-basic-block ] { } make empty? ] unit-test
] with-scope
