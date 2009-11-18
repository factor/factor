! (c)2009 Joe Groff bsd license
USING: assocs biassocs byte-arrays byte-arrays.hex classes
compiler.cfg.instructions compiler.cfg.intrinsics.simd
compiler.cfg.registers compiler.cfg.stacks.local compiler.tree
compiler.tree.propagation.info cpu.architecture fry kernel
locals make namespaces sequences system tools.test words ;
IN: compiler.cfg.intrinsics.simd.tests

:: 1test-node ( rep    -- node  ) 
    T{ #call
        { in-d  { 1 2 3 4 } }
        { out-d { 5 } }
        { info H{
            { 1 T{ value-info { class byte-array } } }
            { 2 T{ value-info { class byte-array } } }
            { 3 T{ value-info { class byte-array } } }
            { 4 T{ value-info { class word } { literal? t } { literal rep } } }
            { 5 T{ value-info { class byte-array } } }
        } }
    } ;
:: 2test-node ( rep cc -- node )
    T{ #call
        { in-d  { 1 2 3 4 5 } }
        { out-d { 6 } }
        { info H{
            { 1 T{ value-info { class byte-array } } }
            { 2 T{ value-info { class byte-array } } }
            { 3 T{ value-info { class byte-array } } }
            { 4 T{ value-info { class word } { literal? t } { literal rep } } }
            { 5 T{ value-info { class word } { literal? t } { literal cc  } } }
            { 6 T{ value-info { class byte-array } } }
        } }
    } ;

: test-compiler-env ( -- x )
    H{ } clone
        T{ current-height { d 0 } { r 0 } { emit-d 0 } { emit-r 0 } } \ current-height pick set-at
        H{ } clone \ local-peek-set pick set-at
        H{ } clone \ replace-mapping pick set-at
        H{ } <biassoc> \ locs>vregs pick set-at ;

: make-classes ( quot -- seq )
    { } make [ class ] map ; inline

: 1test-emit ( cpu rep quot -- node )
    [
        [ new \ cpu ] 2dip '[
            test-compiler-env [ _ 1test-node @ ] bind
        ] with-variable
    ] make-classes ; inline

: 2test-emit ( cpu rep cc quot -- node )
    [
        [ new \ cpu ] 3dip '[
            test-compiler-env [ _ _ 2test-node @ ] bind
        ] with-variable
    ] make-classes ; inline

TUPLE: scalar-cpu ;

TUPLE: simple-ops-cpu ;
M: simple-ops-cpu %zero-vector-reps { int-4-rep float-4-rep } ;
M: simple-ops-cpu %add-vector-reps  { int-4-rep float-4-rep } ;
M: simple-ops-cpu %sub-vector-reps  { int-4-rep float-4-rep } ;
M: simple-ops-cpu %mul-vector-reps  { int-4-rep float-4-rep } ;
M: simple-ops-cpu %div-vector-reps  {           float-4-rep } ;
M: simple-ops-cpu %not-vector-reps  { int-4-rep float-4-rep } ;
M: simple-ops-cpu %andn-vector-reps { int-4-rep float-4-rep } ;
M: simple-ops-cpu %and-vector-reps  { int-4-rep float-4-rep } ;
M: simple-ops-cpu %or-vector-reps   { int-4-rep float-4-rep } ;
M: simple-ops-cpu %xor-vector-reps  { int-4-rep float-4-rep } ;

! v+
[ { ##add-vector } ]
[ simple-ops-cpu float-4-rep [ emit-simd-v+ ] 1test-emit ]
unit-test

! v-
[ { ##sub-vector } ]
[ simple-ops-cpu float-4-rep [ emit-simd-v- ] 1test-emit ]
unit-test

! vneg
[ { ##load-constant ##sub-vector } ]
[ simple-ops-cpu float-4-rep [ emit-simd-vneg ] 1test-emit ]
unit-test

[ { ##zero-vector ##sub-vector } ]
[ simple-ops-cpu int-4-rep [ emit-simd-vneg ] 1test-emit ]
unit-test

! v*
[ { ##mul-vector } ]
[ simple-ops-cpu float-4-rep [ emit-simd-v* ] 1test-emit ]
unit-test

! v/
[ { ##div-vector } ]
[ simple-ops-cpu float-4-rep [ emit-simd-v/ ] 1test-emit ]
unit-test

TUPLE: addsub-cpu < simple-ops-cpu ;
M: addsub-cpu %add-sub-vector-reps { int-4-rep float-4-rep } ;

! v+-
[ { ##add-sub-vector } ]
[ addsub-cpu float-4-rep [ emit-simd-v+- ] 1test-emit ]
unit-test

[ { ##load-constant ##xor-vector ##add-vector } ]
[ simple-ops-cpu float-4-rep [ emit-simd-v+- ] 1test-emit ]
unit-test

[ { ##load-constant ##xor-vector ##sub-vector ##add-vector } ]
[ simple-ops-cpu int-4-rep [ emit-simd-v+- ] 1test-emit ]
unit-test

