! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators combinators.short-circuit arrays
fry kernel layouts math namespaces sequences cpu.architecture
math.bitwise math.order classes
vectors locals make alien.c-types io.binary grouping
math.vectors.simd
compiler.cfg
compiler.cfg.registers
compiler.cfg.comparisons
compiler.cfg.instructions
compiler.cfg.value-numbering.expressions
compiler.cfg.value-numbering.graph
compiler.cfg.value-numbering.rewrite
compiler.cfg.value-numbering.simplify ;
IN: compiler.cfg.value-numbering.simd

M: ##alien-vector rewrite rewrite-alien-addressing ;
M: ##set-alien-vector rewrite rewrite-alien-addressing ;

! Some lame constant folding for SIMD intrinsics. Eventually this
! should be redone completely.

: rewrite-shuffle-vector-imm ( insn expr -- insn' )
    2dup [ rep>> ] bi@ eq? [
        [ [ dst>> ] [ src>> vn>vreg ] bi* ]
        [ [ shuffle>> ] bi@ nths ]
        [ drop rep>> ]
        2tri \ ##shuffle-vector-imm new-insn
    ] [ 2drop f ] if ;

: (fold-shuffle-vector-imm) ( shuffle bytes -- bytes' )
    2dup length swap length /i group nths concat ;

: fold-shuffle-vector-imm ( insn expr -- insn' )
    [ [ dst>> ] [ shuffle>> ] bi ] dip value>>
    (fold-shuffle-vector-imm) \ ##load-constant new-insn ;

M: ##shuffle-vector-imm rewrite
    dup src>> vreg>expr {
        { [ dup shuffle-vector-imm-expr? ] [ rewrite-shuffle-vector-imm ] }
        { [ dup reference-expr? ] [ fold-shuffle-vector-imm ] }
        { [ dup constant-expr? ] [ fold-shuffle-vector-imm ] }
        [ 2drop f ]
    } cond ;

: (fold-scalar>vector) ( insn bytes -- insn' )
    [ [ dst>> ] [ rep>> rep-length ] bi ] dip <repetition> concat
    \ ##load-constant new-insn ;

: fold-scalar>vector ( insn expr -- insn' )
    value>> over rep>> {
        { float-4-rep [ float>bits 4 >le (fold-scalar>vector) ] }
        { double-2-rep [ double>bits 8 >le (fold-scalar>vector) ] }
        [ [ untag-fixnum ] dip rep-component-type heap-size >le (fold-scalar>vector) ]
    } case ;

M: ##scalar>vector rewrite
    dup src>> vreg>expr dup constant-expr?
    [ fold-scalar>vector ] [ 2drop f ] if ;

M: ##xor-vector rewrite
    dup [ src1>> vreg>vn ] [ src2>> vreg>vn ] bi eq?
    [ [ dst>> ] [ rep>> ] bi \ ##zero-vector new-insn ] [ drop f ] if ;

: vector-not? ( expr -- ? )
    {
        [ not-vector-expr? ]
        [ {
            [ xor-vector-expr? ]
            [ [ src1>> ] [ src2>> ] bi [ vn>expr fill-vector-expr? ] either? ]
        } 1&& ]
    } 1|| ;

GENERIC: vector-not-src ( expr -- vreg )
M: not-vector-expr vector-not-src src>> vn>vreg ;
M: xor-vector-expr vector-not-src
    dup src1>> vn>expr fill-vector-expr? [ src2>> ] [ src1>> ] if vn>vreg ;

M: ##and-vector rewrite 
    {
        { [ dup src1>> vreg>expr vector-not? ] [
            {
                [ dst>> ]
                [ src1>> vreg>expr vector-not-src ]
                [ src2>> ]
                [ rep>> ]
            } cleave \ ##andn-vector new-insn
        ] }
        { [ dup src2>> vreg>expr vector-not? ] [
            {
                [ dst>> ]
                [ src2>> vreg>expr vector-not-src ]
                [ src1>> ]
                [ rep>> ]
            } cleave \ ##andn-vector new-insn
        ] }
        [ drop f ]
    } cond ;

M: ##andn-vector rewrite
    dup src1>> vreg>expr vector-not? [
        {
            [ dst>> ]
            [ src1>> vreg>expr vector-not-src ]
            [ src2>> ]
            [ rep>> ]
        } cleave \ ##and-vector new-insn
    ] [ drop f ] if ;

M: scalar>vector-expr simplify*
    src>> vn>expr {
        { [ dup vector>scalar-expr? ] [ src>> ] }
        [ drop f ]
    } cond ;

M: shuffle-vector-imm-expr simplify*
    [ src>> ] [ shuffle>> ] [ rep>> rep-length iota ] tri
    sequence= [ drop f ] unless ;

