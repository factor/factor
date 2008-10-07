! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors namespaces math kernel alien classes ;
IN: compiler.cfg.registers

! Virtual CPU registers, used by CFG and machine IRs

MIXIN: value

GENERIC: >vreg ( obj -- vreg )
GENERIC: set-value-class ( class obj -- )
GENERIC: value-class* ( operand -- class )

: value-class ( operand -- class ) value-class* object or ;

M: value >vreg drop f ;
M: value set-value-class 2drop ;
M: value value-class* drop f ;

! Register classes
SINGLETON: int-regs
SINGLETON: single-float-regs
SINGLETON: double-float-regs
UNION: float-regs single-float-regs double-float-regs ;
UNION: reg-class int-regs float-regs ;

! Virtual registers
TUPLE: vreg reg-class n ;
SYMBOL: vreg-counter
: next-vreg ( reg-class -- vreg ) \ vreg-counter counter vreg boa ;

M: vreg >vreg ;

INSTANCE: vreg value

! Stack locations
TUPLE: loc n class ;

! A data stack location.
TUPLE: ds-loc < loc ;
: <ds-loc> ( n -- loc ) f ds-loc boa ;

TUPLE: rs-loc < loc ;
: <rs-loc> ( n -- loc ) f rs-loc boa ;

INSTANCE: loc value

! A stack location which has been loaded into a register. To
! read the location, we just read the register, but when time
! comes to save it back to the stack, we know the register just
! contains a stack value so we don't have to redundantly write
! it back.
TUPLE: cached loc vreg ;
C: <cached> cached

M: cached set-value-class vreg>> set-value-class ;
M: cached value-class* vreg>> value-class* ;
M: cached >vreg vreg>> >vreg ;

INSTANCE: cached value

! A tagged pointer
TUPLE: tagged vreg class ;
: <tagged> ( vreg -- tagged ) f tagged boa ;

M: tagged set-value-class (>>class) ;
M: tagged value-class* class>> ;
M: tagged >vreg vreg>> ;

INSTANCE: tagged value

! Unboxed value
TUPLE: unboxed vreg ;
C: <unboxed> unboxed

M: unboxed >vreg vreg>> ;

INSTANCE: unboxed value

! Unboxed alien pointer
TUPLE: unboxed-alien < unboxed ;
C: <unboxed-alien> unboxed-alien

M: unboxed-alien value-class* drop simple-alien ;

! Untagged byte array pointer
TUPLE: unboxed-byte-array < unboxed ;
C: <unboxed-byte-array> unboxed-byte-array

M: unboxed-byte-array value-class* drop c-ptr ;

! A register set to f
TUPLE: unboxed-f < unboxed ;
C: <unboxed-f> unboxed-f

M: unboxed-f value-class* drop \ f ;

! An alien, byte array or f
TUPLE: unboxed-c-ptr < unboxed ;
C: <unboxed-c-ptr> unboxed-c-ptr

M: unboxed-c-ptr value-class* drop c-ptr ;

! A constant value
TUPLE: constant value ;
C: <constant> constant

M: constant value-class* value>> class ;

INSTANCE: constant value
