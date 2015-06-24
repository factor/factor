USING: accessors arrays assocs compiler.tree
compiler.tree.propagation.constraints compiler.tree.propagation.copy
compiler.tree.propagation.info compiler.tree.propagation.simple kernel math
math.intervals math.private namespaces sequences system tools.test words ;
IN: compiler.tree.propagation.simple.tests

: fixnum-value-infos ( -- infos )
    {
        H{
            {
                1
                T{ value-info-state
                   { class fixnum }
                   { interval
                     T{ interval
                        { from { 56977 t } }
                        { to { 56977 t } }
                     }
                   }
                   { literal 56977 }
                   { literal? t }
                }
            }
            {
                2
                T{ value-info-state
                   { class fixnum }
                   { interval
                     T{ interval
                        { from { 8098 t } }
                        { to { 8098 t } }
                     }
                   }
                   { literal 8098 }
                   { literal? t }
                }
            }
        }
    } ;

: object-value-infos ( -- infos )
    {
        H{
            {
                1
                T{ value-info-state
                   { class object }
                   { interval full-interval }
                }
            }
            {
                2
                T{ value-info-state
                   { class object }
                   { interval full-interval }
                }
            }
        }
    } ;

: setup-value-infos ( value-infos -- )
    value-infos set
    H{ { 1 1 } { 2 2 } { 3 3 } } copies set ;

: #call-fixnum* ( -- node )
    T{ #call { word fixnum* } { in-d V{ 1 2 } } { out-d { 3 } } } ;

: #call-fixnum/mod ( -- node )
    T{ #call { word fixnum/mod } { in-d V{ 1 2 } } { out-d { 4 5 } } } ;

{ } [
    fixnum-value-infos setup-value-infos
    #call-fixnum* dup word>> "input-classes" word-prop
    propagate-input-classes
] unit-test

{ t } [
    fixnum-value-infos setup-value-infos 1 value-info literal?>>
] unit-test

{
    {
        T{ value-info-state
           { class fixnum }
           { interval
             T{ interval { from { 7 t } } { to { 7 t } } }
           }
           { literal 7 }
           { literal? t }
        }
        T{ value-info-state
           { class fixnum }
           { interval
             T{ interval { from { 0 t } } { to { 8097 t } } }
           }
        }
    }
} [
    fixnum-value-infos setup-value-infos
    #call-fixnum/mod dup word>> call-outputs-quot
] unit-test

! The result of fixnum-mod should always be a fixnum.
cpu x86.64? [
    {
        {
            T{ value-info-state
               { class fixnum }
               { interval
                 T{ interval
                    { from { -576460752303423488 t } }
                    { to { 576460752303423487 t } }
                 }
               }
            }
        }
    } [
        object-value-infos setup-value-infos
        T{ #call { word fixnum-mod } { in-d V{ 1 2 } } { out-d { 4 } } }
        dup word>> call-outputs-quot
    ] unit-test
] when
