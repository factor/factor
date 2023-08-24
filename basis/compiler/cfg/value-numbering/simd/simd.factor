! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types combinators
combinators.short-circuit compiler.cfg.instructions
compiler.cfg.utilities compiler.cfg.value-numbering.graph
compiler.cfg.value-numbering.math
compiler.cfg.value-numbering.rewrite cpu.architecture
endian generalizations grouping kernel make math sequences ;
IN: compiler.cfg.value-numbering.simd

! Some lame constant folding for SIMD intrinsics. Eventually this
! should be redone completely.

: useless-shuffle-vector-imm? ( insn -- ? )
    [ shuffle>> ] [ rep>> rep-length <iota> ] bi sequence= ;

: compose-shuffle-vector-imm ( outer inner -- insn' )
    2dup [ rep>> ] bi@ eq? [
        [ [ dst>> ] [ src>> ] bi* ]
        [ [ shuffle>> ] bi@ nths ]
        [ drop rep>> ]
        2tri ##shuffle-vector-imm new-insn
    ] [ 2drop f ] if ;

: (fold-shuffle-vector-imm) ( shuffle bytes -- bytes' )
    2dup length swap length /i group nths concat ;

: fold-shuffle-vector-imm ( outer inner -- insn' )
    [ [ dst>> ] [ shuffle>> ] bi ] [ obj>> ] bi*
    (fold-shuffle-vector-imm) ##load-reference new-insn ;

M: ##shuffle-vector-imm rewrite
    dup src>> vreg>insn {
        { [ over useless-shuffle-vector-imm? ] [ drop [ dst>> ] [ src>> ] bi <copy> ] }
        { [ dup ##shuffle-vector-imm? ] [ compose-shuffle-vector-imm ] }
        { [ dup ##load-reference? ] [ fold-shuffle-vector-imm ] }
        [ 2drop f ]
    } cond ;

: scalar-value ( literal-insn rep -- byte-array )
    {
        { float-4-rep [ obj>> float>bits 4 >le ] }
        { double-2-rep [ obj>> double>bits 8 >le ] }
        [ [ val>> ] [ rep-component-type heap-size ] bi* >le ]
    } case ;

: (fold-scalar>vector) ( insn bytes -- insn' )
    [ [ dst>> ] [ rep>> rep-length ] bi ] dip <repetition> concat
    ##load-reference new-insn ;

: fold-scalar>vector ( outer inner -- insn' )
    over rep>> scalar-value (fold-scalar>vector) ;

M: ##scalar>vector rewrite
    dup src>> vreg>insn {
        { [ dup literal-insn? ] [ fold-scalar>vector ] }
        { [ dup ##vector>scalar? ] [ [ dst>> ] [ src>> ] bi* <copy> ] }
        [ 2drop f ]
    } cond ;

:: fold-gather-vector-2 ( insn src1 src2 -- insn )
    insn dst>>
    src1 src2 [ insn rep>> scalar-value ] bi@ append
    ##load-reference new-insn ;

: rewrite-gather-vector-2 ( insn -- insn/f )
    dup [ src1>> vreg>insn ] [ src2>> vreg>insn ] bi {
        { [ 2dup [ literal-insn? ] both? ] [ fold-gather-vector-2 ] }
        [ 3drop f ]
    } cond ;

M: ##gather-vector-2 rewrite rewrite-gather-vector-2 ;

M: ##gather-int-vector-2 rewrite rewrite-gather-vector-2 ;

:: fold-gather-vector-4 ( insn src1 src2 src3 src4 -- insn )
    insn dst>>
    [
        src1 src2 src3 src4
        [ insn rep>> scalar-value % ] 4 napply
    ] B{ } make
    ##load-reference new-insn ;

: rewrite-gather-vector-4 ( insn -- insn/f )
    dup { [ src1>> ] [ src2>> ] [ src3>> ] [ src4>> ] } cleave [ vreg>insn ] 4 napply
    {
        { [ 4dup [ literal-insn? ] 4 napply and and and ] [ fold-gather-vector-4 ] }
        [ 5drop f ]
    } cond ;

M: ##gather-vector-4 rewrite rewrite-gather-vector-4 ;

M: ##gather-int-vector-4 rewrite rewrite-gather-vector-4 ;

: fold-shuffle-vector ( insn src1 src2 -- insn )
    [ dst>> ] [ obj>> ] [ obj>> ] tri*
    swap nths ##load-reference new-insn ;

M: ##shuffle-vector rewrite
    dup [ src>> vreg>insn ] [ shuffle>> vreg>insn ] bi
    {
        { [ 2dup [ ##load-reference? ] both? ] [ fold-shuffle-vector ] }
        [ 3drop f ]
    } cond ;

M: ##xor-vector rewrite
    dup diagonal?
    [ [ dst>> ] [ rep>> ] bi ##zero-vector new-insn ] [ drop f ] if ;

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
            } cleave ##andn-vector new-insn
        ] }
        { [ dup src2>> vreg>insn vector-not? ] [
            {
                [ dst>> ]
                [ src2>> vreg>insn vector-not-src ]
                [ src1>> ]
                [ rep>> ]
            } cleave ##andn-vector new-insn
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
        } cleave ##and-vector new-insn
    ] [ drop f ] if ;
