USING: accessors alien.c-types compiler.cfg.instructions
compiler.cfg.intrinsics.strings compiler.test cpu.architecture kernel make
sequences tools.test ;
IN: compiler.cfg.intrinsics.strings.tests

{
    V{
        T{ ##tagged>integer { dst 4 } { src 3 } }
        T{ ##add { dst 5 } { src1 4 } { src2 2 } }
        T{ ##store-memory-imm
           { src 1 }
           { base 5 }
           { offset "varies" }
           { rep int-rep }
           { c-type uchar }
        }
    }
} [
    [ emit-set-string-nth-fast ] V{ } make
    dup third "varies" >>offset drop
] cfg-unit-test
