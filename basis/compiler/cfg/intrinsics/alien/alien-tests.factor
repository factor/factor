USING: accessors alien alien.accessors compiler.cfg
compiler.cfg.builder.blocks compiler.cfg.instructions
compiler.cfg.intrinsics.alien compiler.test compiler.tree
compiler.tree.propagation.info cpu.architecture kernel make
math.intervals sequences ;
IN: compiler.cfg.intrinsics.alien.tests

! emit-<displaced-alien>

: call-<displaced-alien> ( -- #call )
    T{ #call
       { word <displaced-alien> }
       { in-d V{ 8583268 8583269 } }
       { out-d { 8583267 } }
       { info
         H{
             {
                 8583267
                 T{ value-info-state
                    { class object }
                    { interval full-interval }
                 }
             }
             {
                 8583268
                 T{ value-info-state
                    { class object }
                    { interval full-interval }
                 }
             }
             {
                 8583269
                 T{ value-info-state
                    { class object }
                    { interval full-interval }
                 }
             }
         }
       }
    } ;

{
    V{
        T{ ##call { word <displaced-alien> } }
        T{ ##branch }
    }
} [
    <basic-block> dup set-basic-block
    call-<displaced-alien> emit-<displaced-alien>
    predecessors>> first instructions>>
] cfg-unit-test

! emit-alien-cell
{
    V{
        T{ ##load-integer { dst 3 } { val 0 } }
        T{ ##add { dst 4 } { src1 3 } { src2 2 } }
        T{ ##load-memory-imm
           { dst 5 }
           { base 4 }
           { offset 0 }
           { rep int-rep }
        }
        T{ ##box-alien { dst 7 } { src 5 } { temp 6 } }
    }
} [
    <basic-block>
    T{ #call
       { word alien-cell }
       { in-d V{ 10 20 } }
       { out-d { 30 } }
    } [ emit-alien-cell drop ] V{ } make
] cfg-unit-test
