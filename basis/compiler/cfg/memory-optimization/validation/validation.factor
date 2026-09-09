! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators compiler.units kernel locals math math.bitwise sequences
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

! Runtime arguments prevent constructor/constant propagation from deleting
! the field accesses before the memory pass. Compile the typed body as well
! as its wrapper when measuring this word.
TYPED:: memory-loop-work ( cell: memory-cell n: fixnum -- result: fixnum )
    0 :> checksum!
    n [| i |
        cell i 1 bitand zero? memory-branch checksum bitxor checksum!
    ] each-integer
    checksum ;

:: memory-loop-answer ( value n -- result )
    value value 3 bitand bitxor :> even-result
    value value 1 bitand bitxor :> odd-result
    n 4 mod {
        { 0 [ 0 ] }
        { 1 [ even-result ] }
        { 2 [ even-result odd-result bitxor ] }
        { 3 [ odd-result ] }
    } case ;

: fresh-memory-word ( quot -- word )
    [ dup infer define-temp ] with-compilation-unit ;
