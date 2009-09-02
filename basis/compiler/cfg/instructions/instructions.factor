! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs accessors arrays kernel sequences namespaces words
math math.order layouts classes.algebra classes.union
compiler.units alien byte-arrays compiler.constants combinators
compiler.cfg.registers compiler.cfg.instructions.syntax ;
IN: compiler.cfg.instructions

<<
SYMBOL: insn-classes
V{ } clone insn-classes set-global
>>

: new-insn ( ... class -- insn ) f swap boa ; inline

! Virtual CPU instructions, used by CFG and machine IRs
TUPLE: insn ;

! Instructions which are referentially transparent; used for
! value numbering
TUPLE: pure-insn < insn ;

! Stack operations
INSN: ##load-immediate
def: dst/int-rep
constant: val ;

INSN: ##load-reference
def: dst/int-rep
constant: obj ;

INSN: ##peek
def: dst/int-rep
literal: loc ;

INSN: ##replace
use: src/int-rep
literal: loc ;

INSN: ##inc-d
literal: n ;

INSN: ##inc-r
literal: n ;

! Subroutine calls
INSN: ##call
literal: word ;

INSN: ##jump
literal: word ;

INSN: ##return ;

! Dummy instruction that simply inhibits TCO
INSN: ##no-tco ;

! Jump tables
INSN: ##dispatch
use: src/int-rep
temp: temp/int-rep ;

! Slot access
INSN: ##slot
def: dst/int-rep
use: obj/int-rep slot/int-rep
literal: tag
temp: temp/int-rep ;

INSN: ##slot-imm
def: dst/int-rep
use: obj/int-rep
literal: slot tag ;

INSN: ##set-slot
use: src/int-rep obj/int-rep slot/int-rep
literal: tag
temp: temp/int-rep ;

INSN: ##set-slot-imm
use: src/int-rep obj/int-rep
literal: slot tag ;

! String element access
INSN: ##string-nth
def: dst/int-rep
use: obj/int-rep index/int-rep
temp: temp/int-rep ;

INSN: ##set-string-nth-fast
use: src/int-rep obj/int-rep index/int-rep
temp: temp/int-rep ;

! Integer arithmetic
PURE-INSN: ##add
def: dst/int-rep
use: src1/int-rep src2/int-rep ;

PURE-INSN: ##add-imm
def: dst/int-rep
use: src1/int-rep
constant: src2 ;

PURE-INSN: ##sub
def: dst/int-rep
use: src1/int-rep src2/int-rep ;

PURE-INSN: ##sub-imm
def: dst/int-rep
use: src1/int-rep
constant: src2 ;

PURE-INSN: ##mul
def: dst/int-rep
use: src1/int-rep src2/int-rep ;

PURE-INSN: ##mul-imm
def: dst/int-rep
use: src1/int-rep
constant: src2 ;

PURE-INSN: ##and
def: dst/int-rep
use: src1/int-rep src2/int-rep ;

PURE-INSN: ##and-imm
def: dst/int-rep
use: src1/int-rep
constant: src2 ;

PURE-INSN: ##or
def: dst/int-rep
use: src1/int-rep src2/int-rep ;

PURE-INSN: ##or-imm
def: dst/int-rep
use: src1/int-rep
constant: src2 ;

PURE-INSN: ##xor
def: dst/int-rep
use: src1/int-rep src2/int-rep ;

PURE-INSN: ##xor-imm
def: dst/int-rep
use: src1/int-rep
constant: src2 ;

PURE-INSN: ##shl
def: dst/int-rep
use: src1/int-rep src2/int-rep ;

PURE-INSN: ##shl-imm
def: dst/int-rep
use: src1/int-rep
constant: src2 ;

PURE-INSN: ##shr
def: dst/int-rep
use: src1/int-rep src2/int-rep ;

PURE-INSN: ##shr-imm
def: dst/int-rep
use: src1/int-rep
constant: src2 ;

PURE-INSN: ##sar
def: dst/int-rep
use: src1/int-rep src2/int-rep ;

PURE-INSN: ##sar-imm
def: dst/int-rep
use: src1/int-rep
constant: src2 ;

PURE-INSN: ##min
def: dst/int-rep
use: src1/int-rep src2/int-rep ;

PURE-INSN: ##max
def: dst/int-rep
use: src1/int-rep src2/int-rep ;

PURE-INSN: ##not
def: dst/int-rep
use: src/int-rep ;

PURE-INSN: ##log2
def: dst/int-rep
use: src/int-rep ;

! Bignum/integer conversion
PURE-INSN: ##integer>bignum
def: dst/int-rep
use: src/int-rep
temp: temp/int-rep ;

PURE-INSN: ##bignum>integer
def: dst/int-rep
use: src/int-rep
temp: temp/int-rep ;

! Float arithmetic
PURE-INSN: ##add-float
def: dst/double-float-rep
use: src1/double-float-rep src2/double-float-rep ;

PURE-INSN: ##sub-float
def: dst/double-float-rep
use: src1/double-float-rep src2/double-float-rep ;

PURE-INSN: ##mul-float
def: dst/double-float-rep
use: src1/double-float-rep src2/double-float-rep ;

PURE-INSN: ##div-float
def: dst/double-float-rep
use: src1/double-float-rep src2/double-float-rep ;

PURE-INSN: ##min-float
def: dst/double-float-rep
use: src1/double-float-rep src2/double-float-rep ;

PURE-INSN: ##max-float
def: dst/double-float-rep
use: src1/double-float-rep src2/double-float-rep ;

PURE-INSN: ##sqrt
def: dst/double-float-rep
use: src/double-float-rep ;

! libc intrinsics
PURE-INSN: ##unary-float-function
def: dst/double-float-rep
use: src/double-float-rep
literal: func ;

PURE-INSN: ##binary-float-function
def: dst/double-float-rep
use: src1/double-float-rep src2/double-float-rep
literal: func ;

! Float/integer conversion
PURE-INSN: ##float>integer
def: dst/int-rep
use: src/double-float-rep ;

PURE-INSN: ##integer>float
def: dst/double-float-rep
use: src/int-rep ;

! Boxing and unboxing
PURE-INSN: ##copy
def: dst
use: src
literal: rep ;

PURE-INSN: ##unbox-float
def: dst/double-float-rep
use: src/int-rep ;

PURE-INSN: ##unbox-any-c-ptr
def: dst/int-rep
use: src/int-rep
temp: temp/int-rep ;

PURE-INSN: ##box-float
def: dst/int-rep
use: src/double-float-rep
temp: temp/int-rep ;

PURE-INSN: ##box-alien
def: dst/int-rep
use: src/int-rep
temp: temp/int-rep ;

PURE-INSN: ##box-displaced-alien
def: dst/int-rep
use: displacement/int-rep base/int-rep
temp: temp1/int-rep temp2/int-rep
literal: base-class ;

: ##unbox-f ( dst src -- ) drop 0 ##load-immediate ;
: ##unbox-byte-array ( dst src -- ) byte-array-offset ##add-imm ;
: ##unbox-alien ( dst src -- ) 3 object tag-number ##slot-imm ;

: ##unbox-c-ptr ( dst src class temp -- )
    {
        { [ over \ f class<= ] [ 2drop ##unbox-f ] }
        { [ over simple-alien class<= ] [ 2drop ##unbox-alien ] }
        { [ over byte-array class<= ] [ 2drop ##unbox-byte-array ] }
        [ nip ##unbox-any-c-ptr ]
    } cond ;

! Alien accessors
INSN: ##alien-unsigned-1
def: dst/int-rep
use: src/int-rep ;

INSN: ##alien-unsigned-2
def: dst/int-rep
use: src/int-rep ;

INSN: ##alien-unsigned-4
def: dst/int-rep
use: src/int-rep ;

INSN: ##alien-signed-1
def: dst/int-rep
use: src/int-rep ;

INSN: ##alien-signed-2
def: dst/int-rep
use: src/int-rep ;

INSN: ##alien-signed-4
def: dst/int-rep
use: src/int-rep ;

INSN: ##alien-cell
def: dst/int-rep
use: src/int-rep ;

INSN: ##alien-float
def: dst/double-float-rep
use: src/int-rep ;

INSN: ##alien-double
def: dst/double-float-rep
use: src/int-rep ;

INSN: ##set-alien-integer-1
use: src/int-rep value/int-rep ;

INSN: ##set-alien-integer-2
use: src/int-rep value/int-rep ;

INSN: ##set-alien-integer-4
use: src/int-rep value/int-rep ;

INSN: ##set-alien-cell
use: src/int-rep value/int-rep ;

INSN: ##set-alien-float
use: src/int-rep value/double-float-rep ;

INSN: ##set-alien-double
use: src/int-rep value/double-float-rep ;

! Memory allocation
INSN: ##allot
def: dst/int-rep
literal: size class
temp: temp/int-rep ;

INSN: ##write-barrier
use: src/int-rep
temp: card#/int-rep table/int-rep ;

INSN: ##alien-global
def: dst/int-rep
literal: symbol library ;

! FFI
INSN: ##alien-invoke
literal: params stack-frame ;

INSN: ##alien-indirect
literal: params stack-frame ;

INSN: ##alien-callback
literal: params stack-frame ;

INSN: ##callback-return
literal: params ;

! Instructions used by CFG IR only.
INSN: ##prologue ;
INSN: ##epilogue ;

INSN: ##branch ;

INSN: ##phi
def: dst
literal: inputs ;

! Conditionals
INSN: ##compare-branch
use: src1/int-rep src2/int-rep
literal: cc ;

INSN: ##compare-imm-branch
use: src1/int-rep
constant: src2
literal: cc ;

PURE-INSN: ##compare
def: dst/int-rep
use: src1/int-rep src2/int-rep
literal: cc
temp: temp/int-rep ;

PURE-INSN: ##compare-imm
def: dst/int-rep
use: src1/int-rep
constant: src2
literal: cc
temp: temp/int-rep ;

INSN: ##compare-float-branch
use: src1/double-float-rep src2/double-float-rep
literal: cc ;

PURE-INSN: ##compare-float
def: dst/int-rep
use: src1/double-float-rep src2/double-float-rep
literal: cc
temp: temp/int-rep ;

! Overflowing arithmetic
INSN: ##fixnum-add
def: dst/int-rep
use: src1/int-rep src2/int-rep ;

INSN: ##fixnum-sub
def: dst/int-rep
use: src1/int-rep src2/int-rep ;

INSN: ##fixnum-mul
def: dst/int-rep
use: src1/int-rep src2/int-rep ;

INSN: ##gc
temp: temp1/int-rep temp2/int-rep
literal: data-values tagged-values uninitialized-locs ;

! Instructions used by machine IR only.
INSN: _prologue
literal: stack-frame ;

INSN: _epilogue
literal: stack-frame ;

INSN: _label
literal: label ;

INSN: _branch
literal: label ;

INSN: _loop-entry ;

INSN: _dispatch
use: src/int-rep
temp: temp ;

INSN: _dispatch-label
literal: label ;

INSN: _compare-branch
literal: label
use: src1/int-rep src2/int-rep
literal: cc ;

INSN: _compare-imm-branch
literal: label
use: src1/int-rep
constant: src2
literal: cc ;

INSN: _compare-float-branch
literal: label
use: src1/int-rep src2/int-rep
literal: cc ;

! Overflowing arithmetic
INSN: _fixnum-add
literal: label
def: dst/int-rep
use: src1/int-rep src2/int-rep ;

INSN: _fixnum-sub
literal: label
def: dst/int-rep
use: src1/int-rep src2/int-rep ;

INSN: _fixnum-mul
literal: label
def: dst/int-rep
use: src1/int-rep src2/int-rep ;

TUPLE: spill-slot n ; C: <spill-slot> spill-slot

INSN: _gc
temp: temp1 temp2
literal: data-values tagged-values uninitialized-locs ;

! These instructions operate on machine registers and not
! virtual registers
INSN: _spill
use: src
literal: rep n ;

INSN: _reload
def: dst
literal: rep n ;

INSN: _spill-area-size
literal: n ;

UNION: ##allocation
##allot
##box-float
##box-alien
##box-displaced-alien
##integer>bignum ;

! For alias analysis
UNION: ##read ##slot ##slot-imm ;
UNION: ##write ##set-slot ##set-slot-imm ;

! Instructions that kill all live vregs but cannot trigger GC
UNION: partial-sync-insn
##unary-float-function
##binary-float-function ;

! Instructions that kill all live vregs
UNION: kill-vreg-insn
##call
##prologue
##epilogue
##alien-invoke
##alien-indirect
##alien-callback ;

! Instructions that have complex expansions and require that the
! output registers are not equal to any of the input registers
UNION: def-is-use-insn
##integer>bignum
##bignum>integer
##unbox-any-c-ptr ;

SYMBOL: vreg-insn

[
    vreg-insn
    insn-classes get [
        "insn-slots" word-prop [ type>> { def use temp } memq? ] any?
    ] filter
    define-union-class
] with-compilation-unit