USING: accessors arrays assocs compiler.tree
compiler.tree.propagation.constraints compiler.tree.propagation.copy
compiler.tree.propagation.info compiler.tree.propagation.simple hashtables
kernel math math.intervals math.private namespaces sequences system tools.test
words ;
IN: compiler.tree.propagation.simple.tests

: make-value-infos ( classes intervals -- seq )
    [ <class/interval-info>  ] 2map ;

: fixnum-value-infos ( -- infos )
    { fixnum fixnum } 56977 [a,a] 8098 [a,a] 2array make-value-infos ;

: object-value-infos ( -- infos )
    { object object } { full-interval full-interval } make-value-infos ;

: bignum-value-infos ( -- infos )
    { bignum bignum } full-interval 20 [a,a] 2array
    make-value-infos ;

: full-interval-and-bignum-literal ( -- infos )
    { object bignum } full-interval 20 [a,a] 2array
    make-value-infos ;

: indexize ( seq -- assoc )
    [ swap 2array ] map-index ;

: setup-value-infos ( value-infos -- )
    indexize >hashtable 1array value-infos set
    H{ { 0 0 } { 1 1 } { 2 2 } } copies set ;

: #call-fixnum* ( -- node )
    T{ #call { word fixnum* } { in-d V{ 0 1 } } { out-d { 3 } } } ;

: call-outputs-quot-of-word ( inputs outputs word -- value-infos )
    <#call> dup word>> call-outputs-quot ;

{ } [
    fixnum-value-infos setup-value-infos
    #call-fixnum* dup word>> word>input-infos propagate-input-infos
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
    V{ 0 1 } V{ 2 3 } \ fixnum/mod call-outputs-quot-of-word
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
        V{ 0 1 } V{ 2 } \ fixnum-mod call-outputs-quot-of-word
    ] unit-test
] when

! Downgrading should do its thing here.
{
    {
        T{ value-info-state
           { class fixnum }
           { interval
             T{ interval { from { -19 t } } { to { 19 t } } }
           }
        }
    }
} [
    bignum-value-infos setup-value-infos
    V{ 0 1 } V{ 2 } \ mod call-outputs-quot-of-word
] unit-test

! But not here because the argument to mod might be a real.
{
    {
        T{ value-info-state
           { class real }
           { interval
             T{ interval { from { -20 f } } { to { 20 f } } }
           }
        }
    }
} [
    full-interval-and-bignum-literal setup-value-infos
    V{ 0 1 } V{ 2 } \ mod call-outputs-quot-of-word
] unit-test

! (fold-call)
{
    {
        T{ value-info-state
           { class fixnum }
           { interval
             T{ interval { from { 5 t } } { to { 5 t } } }
           }
           { literal 5 }
           { literal? t }
        }
    }
} [
    { 2 3 "hello" } [ <literal-info> ] map setup-value-infos
    { 0 1 } { 2 } \ + <#call> dup word>> (fold-call)
] unit-test

{
    {
        T{ value-info-state
           { class object }
           { interval full-interval }
        }
    }
} [
    { 2 "hello" } [ <literal-info> ] map setup-value-infos { 0 1 } { 2 } \ +
    <#call> dup word>> (fold-call)
] unit-test

! foldable-call?
{ t f f t } [
    { 2 3 "hello" } [ <literal-info> ] map setup-value-infos
    { 0 1 } { 2 } \ + <#call> dup word>> foldable-call?
    { 0 2 } { 2 } \ + <#call> dup word>> foldable-call?
    number <class-info> 1array setup-value-infos
    { 0 } { 1 } \ >fixnum <#call> dup word>> foldable-call?
    "mamma mia" <literal-info> 1array setup-value-infos
    { 0 } { 1 } \ >fixnum <#call> dup word>> foldable-call?
] unit-test
