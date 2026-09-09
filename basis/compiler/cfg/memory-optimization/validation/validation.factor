! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors compiler.units kernel locals math math.bitwise sequences
stack-checker typed words ;
IN: compiler.cfg.memory-optimization.validation

TUPLE: memory-cell { value fixnum } ;
C: <memory-cell> memory-cell

! A mutable field is read on both sides of a real control-flow join.
TYPED:: memory-branch ( cell: memory-cell flag: boolean -- result: fixnum )
    cell value>> :> before
    flag [ before 3 bitand ] [ before 1 bitand ] if :> bits
    cell value>> bits bitxor ; inline

! Neither separate arguments nor separate SSA values prove disjoint objects.
TYPED:: memory-alias-branch ( a: memory-cell b: memory-cell flag: boolean -- result: fixnum )
    a value>> :> before
    flag [ b 91 >>value drop ] when
    before a value>> bitxor ; inline

TYPED:: memory-alias-loop ( a: memory-cell b: memory-cell n: fixnum -- result: fixnum )
    a value>> :> before
    n [| i | b i >>value drop ] each-integer
    before a value>> bitxor ; inline

: fresh-memory-word ( quot -- word )
    [ dup infer define-temp ] with-compilation-unit ;
