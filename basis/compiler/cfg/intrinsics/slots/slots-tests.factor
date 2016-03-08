USING: accessors arrays compiler.cfg compiler.cfg.builder.blocks
compiler.cfg.instructions compiler.cfg.intrinsics.slots compiler.test
compiler.tree compiler.tree.propagation.info kernel layouts literals
make math math.intervals sequences slots.private tools.test ;
IN: compiler.cfg.intrinsics.slots.tests

: call-node-1 ( -- node )
    T{ #call
       { word set-slot }
       { in-d V{ 9133848 9133849 9133850 } }
       { out-d { } }
       { info
         H{
             {
                 9133848
                 T{ value-info-state
                    { class object }
                    { interval full-interval }
                 }
             }
             {
                 9133849
                 T{ value-info-state
                    { class object }
                    { interval full-interval }
                 }
             }
             {
                 9133850
                 T{ value-info-state
                    { class object }
                    { interval full-interval }
                 }
             }
         }
       }
    } ;

: call-node-2 ( -- node )
    T{ #call
       { word set-slot }
       { in-d V{ 1 2 3 } }
       { out-d { } }
       { info
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
                    { class array }
                    { interval full-interval }
                 }
             }
             {
                 3
                 T{ value-info-state
                    { class object }
                    { interval full-interval }
                 }
             }
         }
       }
    } ;

: call-node-3 ( -- node )
    T{ #call
       { word set-slot }
       { in-d V{ 1 2 3 } }
       { out-d { } }
       { info
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
                    { class array }
                    { interval full-interval }
                 }
             }
             {
                 3
                 T{ value-info-state
                    { class fixnum }
                    { interval
                      T{ interval
                         { from { 9 t } }
                         { to { 9 t } }
                      }
                    }
                    { literal 9 }
                    { literal? t }
                 }
             }
         }
       }
    } ;

! emit-set-slot
{
    V{ T{ ##call { word set-slot } } T{ ##branch } }
} [
    <basic-block> dup set-basic-block
    call-node-1 [ emit-set-slot ] V{ } make drop
    predecessors>> first instructions>>
] cfg-unit-test

{
    V{
        T{ ##set-slot
           { src 1 }
           { obj 2 }
           { slot 3 }
           { scale $[ cell log2 ] }
           { tag 2 }
        }
        T{ ##write-barrier
           { src 2 }
           { slot 3 }
           { scale $[ cell log2 ] }
           { tag 2 }
           { temp1 4 }
           { temp2 5 }
        }
    }
} [
    call-node-2 [ emit-set-slot ] V{ } make
] cfg-unit-test

{
    V{
        T{ ##set-slot-imm { src 1 } { obj 2 } { slot 9 } { tag 2 } }
        T{ ##write-barrier-imm
           { src 2 }
           { slot 9 }
           { tag 2 }
           { temp1 3 }
           { temp2 4 }
        }
    }
} [
    call-node-3 [ emit-set-slot ] V{ } make
] cfg-unit-test

! immediate-slot-offset?
{ t f } [
    33 immediate-slot-offset?
    "foo" immediate-slot-offset?
] unit-test

! node>set-slot-data
{
    t f f
    t 2 f
    t 2 9
} [
    call-node-1 node>set-slot-data
    call-node-2 node>set-slot-data
    call-node-3 node>set-slot-data
] unit-test
