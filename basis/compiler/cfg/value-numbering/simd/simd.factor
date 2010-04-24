! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators combinators.short-circuit arrays
fry kernel layouts math namespaces sequences cpu.architecture
math.bitwise math.order classes
vectors locals make alien.c-types io.binary grouping
math.vectors.simd.intrinsics
compiler.cfg
compiler.cfg.registers
compiler.cfg.utilities
compiler.cfg.comparisons
compiler.cfg.instructions
compiler.cfg.value-numbering.math
compiler.cfg.value-numbering.graph
compiler.cfg.value-numbering.expressions
compiler.cfg.value-numbering.rewrite ;
IN: compiler.cfg.value-numbering.simd

! Some lame constant folding for SIMD intrinsics. Eventually this
! should be redone completely.

: useless-shuffle-vector-imm? ( insn -- ? )
    [ shuffle>> ] [ rep>> rep-length iota ] bi sequence= ;

: compose-shuffle-vector-imm ( outer inner -- insn' )
    2dup [ rep>> ] bi@ eq? [
        [ [ dst>> ] [ src>> ] bi* ]
        [ [ shuffle>> ] bi@ nths ]
        [ drop rep>> ]
        2tri \ ##shuffle-vector-imm new-insn
    ] [ 2drop f ] if ;

: (fold-shuffle-vector-imm) ( shuffle bytes -- bytes' )
    2dup length swap length /i group nths concat ;

: fold-shuffle-vector-imm ( outer inner -- insn' )
    [ [ dst>> ] [ shuffle>> ] bi ] [ obj>> ] bi*
    (fold-shuffle-vector-imm) \ ##load-reference new-insn ;

M: ##shuffle-vector-imm rewrite
    dup src>> vreg>insn {
        { [ over useless-shuffle-vector-imm? ] [ drop [ dst>> ] [ src>> ] bi <copy> ] }
        { [ dup ##shuffle-vector-imm? ] [ compose-shuffle-vector-imm ] }
        { [ dup ##load-reference? ] [ fold-shuffle-vector-imm ] }
        [ 2drop f ]
    } cond ;

: (fold-scalar>vector) ( insn bytes -- insn' )
    [ [ dst>> ] [ rep>> rep-length ] bi ] dip <repetition> concat
    \ ##load-reference new-insn ;

: fold-scalar>vector ( outer inner -- insn' )
    obj>> over rep>> {
        { float-4-rep [ float>bits 4 >le (fold-scalar>vector) ] }
        { double-2-rep [ double>bits 8 >le (fold-scalar>vector) ] }
        [ [ untag-fixnum ] dip rep-component-type heap-size >le (fold-scalar>vector) ]
    } case ;

M: ##scalar>vector rewrite
    dup src>> vreg>insn {
        { [ dup ##load-reference? ] [ fold-scalar>vector ] }
        { [ dup ##vector>scalar? ] [ [ dst>> ] [ src>> ] bi* <copy> ] }
        [ 2drop f ]
    } cond ;

M: ##xor-vector rewrite
    dup diagonal?
    [ [ dst>> ] [ rep>> ] bi \ ##zero-vector new-insn ] [ drop f ] if ;

: vector-not? ( insn -- ? )
    {
        [ ##not-vector? ]
        [ {
            [ ##xor-vector? ]
            [ [ src1>> ] [ src2>> ] bi [ vreg>insn ##fill-vector? ] either? ]
        } 1&& ]
    } 1|| ;

GENERIC: vector-not-src ( insn -- vreg )

M: ##not-vector vector-not-src
    src>> ;

M: ##xor-vector vector-not-src
    dup src1>> vreg>insn ##fill-vector? [ src2>> ] [ src1>> ] if ;

M: ##and-vector rewrite 
    {
        { [ dup src1>> vreg>insn vector-not? ] [
            {
                [ dst>> ]
                [ src1>> vreg>insn vector-not-src ]
                [ src2>> ]
                [ rep>> ]
            } cleave \ ##andn-vector new-insn
        ] }
        { [ dup src2>> vreg>insn vector-not? ] [
            {
                [ dst>> ]
                [ src2>> vreg>insn vector-not-src ]
                [ src1>> ]
                [ rep>> ]
            } cleave \ ##andn-vector new-insn
        ] }
        [ drop f ]
    } cond ;

M: ##andn-vector rewrite
    dup src1>> vreg>insn vector-not? [
        {
            [ dst>> ]
            [ src1>> vreg>insn vector-not-src ]
            [ src2>> ]
            [ rep>> ]
        } cleave \ ##and-vector new-insn
    ] [ drop f ] if ;
