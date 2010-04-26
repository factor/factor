! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs accessors arrays kernel sequences namespaces words
math math.order layouts classes.union compiler.units alien
byte-arrays combinators compiler.cfg.registers
compiler.cfg.instructions.syntax ;
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

! Constants
INSN: ##load-integer
def: dst/int-rep
literal: val ;

INSN: ##load-reference
def: dst/tagged-rep
literal: obj ;

! These two are inserted by representation selection
INSN: ##load-tagged
def: dst/tagged-rep
literal: val ;

INSN: ##load-double
def: dst/double-rep
literal: val ;

! Stack operations
INSN: ##peek
def: dst/tagged-rep
literal: loc ;

INSN: ##replace
use: src/tagged-rep
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
def: dst/tagged-rep
use: obj/tagged-rep slot/int-rep
literal: scale tag ;

INSN: ##slot-imm
def: dst/tagged-rep
use: obj/tagged-rep
literal: slot tag ;

INSN: ##set-slot
use: src/tagged-rep obj/tagged-rep slot/int-rep
literal: scale tag ;

INSN: ##set-slot-imm
use: src/tagged-rep obj/tagged-rep
literal: slot tag ;

! Register transfers
INSN: ##copy
def: dst
use: src
literal: rep ;

PURE-INSN: ##tagged>integer
def: dst/int-rep
use: src/tagged-rep ;

! Integer arithmetic
PURE-INSN: ##add
def: dst/int-rep
use: src1/int-rep src2/int-rep ;

PURE-INSN: ##add-imm
def: dst/int-rep
use: src1/int-rep
literal: src2 ;

PURE-INSN: ##sub
def: dst/int-rep
use: src1/int-rep src2/int-rep ;

PURE-INSN: ##sub-imm
def: dst/int-rep
use: src1/int-rep
literal: src2 ;

PURE-INSN: ##mul
def: dst/int-rep
use: src1/int-rep src2/int-rep ;

PURE-INSN: ##mul-imm
def: dst/int-rep
use: src1/int-rep
literal: src2 ;

PURE-INSN: ##and
def: dst/int-rep
use: src1/int-rep src2/int-rep ;

PURE-INSN: ##and-imm
def: dst/int-rep
use: src1/int-rep
literal: src2 ;

PURE-INSN: ##or
def: dst/int-rep
use: src1/int-rep src2/int-rep ;

PURE-INSN: ##or-imm
def: dst/int-rep
use: src1/int-rep
literal: src2 ;

PURE-INSN: ##xor
def: dst/int-rep
use: src1/int-rep src2/int-rep ;

PURE-INSN: ##xor-imm
def: dst/int-rep
use: src1/int-rep
literal: src2 ;

PURE-INSN: ##shl
def: dst/int-rep
use: src1/int-rep src2/int-rep ;

PURE-INSN: ##shl-imm
def: dst/int-rep
use: src1/int-rep
literal: src2 ;

PURE-INSN: ##shr
def: dst/int-rep
use: src1/int-rep src2/int-rep ;

PURE-INSN: ##shr-imm
def: dst/int-rep
use: src1/int-rep
literal: src2 ;

PURE-INSN: ##sar
def: dst/int-rep
use: src1/int-rep src2/int-rep ;

PURE-INSN: ##sar-imm
def: dst/int-rep
use: src1/int-rep
literal: src2 ;

PURE-INSN: ##min
def: dst/int-rep
use: src1/int-rep src2/int-rep ;

PURE-INSN: ##max
def: dst/int-rep
use: src1/int-rep src2/int-rep ;

PURE-INSN: ##not
def: dst/int-rep
use: src/int-rep ;

PURE-INSN: ##neg
def: dst/int-rep
use: src/int-rep ;

PURE-INSN: ##log2
def: dst/int-rep
use: src/int-rep ;

! Float arithmetic
PURE-INSN: ##add-float
def: dst/double-rep
use: src1/double-rep src2/double-rep ;

PURE-INSN: ##sub-float
def: dst/double-rep
use: src1/double-rep src2/double-rep ;

PURE-INSN: ##mul-float
def: dst/double-rep
use: src1/double-rep src2/double-rep ;

PURE-INSN: ##div-float
def: dst/double-rep
use: src1/double-rep src2/double-rep ;

PURE-INSN: ##min-float
def: dst/double-rep
use: src1/double-rep src2/double-rep ;

PURE-INSN: ##max-float
def: dst/double-rep
use: src1/double-rep src2/double-rep ;

PURE-INSN: ##sqrt
def: dst/double-rep
use: src/double-rep ;

! libc intrinsics
PURE-INSN: ##unary-float-function
def: dst/double-rep
use: src/double-rep
literal: func ;

PURE-INSN: ##binary-float-function
def: dst/double-rep
use: src1/double-rep src2/double-rep
literal: func ;

! Single/double float conversion
PURE-INSN: ##single>double-float
def: dst/double-rep
use: src/float-rep ;

PURE-INSN: ##double>single-float
def: dst/float-rep
use: src/double-rep ;

! Float/integer conversion
PURE-INSN: ##float>integer
def: dst/int-rep
use: src/double-rep ;

PURE-INSN: ##integer>float
def: dst/double-rep
use: src/int-rep ;

! SIMD operations
PURE-INSN: ##zero-vector
def: dst
literal: rep ;

PURE-INSN: ##fill-vector
def: dst
literal: rep ;

PURE-INSN: ##gather-vector-2
def: dst
use: src1/scalar-rep src2/scalar-rep
literal: rep ;

PURE-INSN: ##gather-vector-4
def: dst
use: src1/scalar-rep src2/scalar-rep src3/scalar-rep src4/scalar-rep
literal: rep ;

PURE-INSN: ##shuffle-vector
def: dst
use: src shuffle
literal: rep ;

PURE-INSN: ##shuffle-vector-imm
def: dst
use: src
literal: shuffle rep ;

PURE-INSN: ##tail>head-vector
def: dst
use: src
literal: rep ;

PURE-INSN: ##merge-vector-head
def: dst
use: src1 src2
literal: rep ;

PURE-INSN: ##merge-vector-tail
def: dst
use: src1 src2
literal: rep ;

PURE-INSN: ##signed-pack-vector
def: dst
use: src1 src2
literal: rep ;

PURE-INSN: ##unsigned-pack-vector
def: dst
use: src1 src2
literal: rep ;

PURE-INSN: ##unpack-vector-head
def: dst
use: src
literal: rep ;

PURE-INSN: ##unpack-vector-tail
def: dst
use: src
literal: rep ;

PURE-INSN: ##integer>float-vector
def: dst
use: src
literal: rep ;

PURE-INSN: ##float>integer-vector
def: dst
use: src
literal: rep ;

PURE-INSN: ##compare-vector
def: dst
use: src1 src2
literal: rep cc ;

PURE-INSN: ##test-vector
def: dst/tagged-rep
use: src1
temp: temp/int-rep
literal: rep vcc ;

INSN: ##test-vector-branch
use: src1
temp: temp/int-rep
literal: rep vcc ;

INSN: _test-vector-branch
literal: label
use: src1
temp: temp/int-rep
literal: rep vcc ;

PURE-INSN: ##add-vector
def: dst
use: src1 src2
literal: rep ;

PURE-INSN: ##saturated-add-vector
def: dst
use: src1 src2
literal: rep ;

PURE-INSN: ##add-sub-vector
def: dst
use: src1 src2
literal: rep ;

PURE-INSN: ##sub-vector
def: dst
use: src1 src2
literal: rep ;

PURE-INSN: ##saturated-sub-vector
def: dst
use: src1 src2
literal: rep ;

PURE-INSN: ##mul-vector
def: dst
use: src1 src2
literal: rep ;

PURE-INSN: ##mul-high-vector
def: dst
use: src1 src2
literal: rep ;

PURE-INSN: ##mul-horizontal-add-vector
def: dst
use: src1 src2
literal: rep ;

PURE-INSN: ##saturated-mul-vector
def: dst
use: src1 src2
literal: rep ;

PURE-INSN: ##div-vector
def: dst
use: src1 src2
literal: rep ;

PURE-INSN: ##min-vector
def: dst
use: src1 src2
literal: rep ;

PURE-INSN: ##max-vector
def: dst
use: src1 src2
literal: rep ;

PURE-INSN: ##avg-vector
def: dst
use: src1 src2
literal: rep ;

PURE-INSN: ##dot-vector
def: dst/scalar-rep
use: src1 src2
literal: rep ;

PURE-INSN: ##sad-vector
def: dst
use: src1 src2
literal: rep ;

PURE-INSN: ##horizontal-add-vector
def: dst
use: src1 src2
literal: rep ;

PURE-INSN: ##horizontal-sub-vector
def: dst
use: src1 src2
literal: rep ;

PURE-INSN: ##horizontal-shl-vector-imm
def: dst
use: src1
literal: src2 rep ;

PURE-INSN: ##horizontal-shr-vector-imm
def: dst
use: src1
literal: src2 rep ;

PURE-INSN: ##abs-vector
def: dst
use: src
literal: rep ;

PURE-INSN: ##sqrt-vector
def: dst
use: src
literal: rep ;

PURE-INSN: ##and-vector
def: dst
use: src1 src2
literal: rep ;

PURE-INSN: ##andn-vector
def: dst
use: src1 src2
literal: rep ;

PURE-INSN: ##or-vector
def: dst
use: src1 src2
literal: rep ;

PURE-INSN: ##xor-vector
def: dst
use: src1 src2
literal: rep ;

PURE-INSN: ##not-vector
def: dst
use: src
literal: rep ;

PURE-INSN: ##shl-vector-imm
def: dst
use: src1
literal: src2 rep ;

PURE-INSN: ##shr-vector-imm
def: dst
use: src1
literal: src2 rep ;

PURE-INSN: ##shl-vector
def: dst
use: src1 src2/int-scalar-rep
literal: rep ;

PURE-INSN: ##shr-vector
def: dst
use: src1 src2/int-scalar-rep
literal: rep ;

! Scalar/vector conversion
PURE-INSN: ##scalar>integer
def: dst/int-rep
use: src
literal: rep ;

PURE-INSN: ##integer>scalar
def: dst
use: src/int-rep
literal: rep ;

PURE-INSN: ##vector>scalar
def: dst/scalar-rep
use: src
literal: rep ;

PURE-INSN: ##scalar>vector
def: dst
use: src/scalar-rep
literal: rep ;

! Boxing and unboxing aliens
PURE-INSN: ##box-alien
def: dst/tagged-rep
use: src/int-rep
temp: temp/int-rep ;

PURE-INSN: ##box-displaced-alien
def: dst/tagged-rep
use: displacement/int-rep base/tagged-rep
temp: temp/int-rep
literal: base-class ;

PURE-INSN: ##unbox-any-c-ptr
def: dst/int-rep
use: src/tagged-rep ;

PURE-INSN: ##unbox-alien
def: dst/int-rep
use: src/tagged-rep ;

! Raw memory accessors
INSN: ##load-memory
def: dst
use: base/int-rep displacement/int-rep
literal: scale offset rep c-type ;

INSN: ##load-memory-imm
def: dst
use: base/int-rep
literal: offset rep c-type ;

INSN: ##store-memory
use: src base/int-rep displacement/int-rep
literal: scale offset rep c-type ;

INSN: ##store-memory-imm
use: src base/int-rep
literal: offset rep c-type ;

! Memory allocation
INSN: ##allot
def: dst/tagged-rep
literal: size class
temp: temp/int-rep ;

INSN: ##write-barrier
use: src/tagged-rep slot/int-rep
literal: scale tag
temp: temp1/int-rep temp2/int-rep ;

INSN: ##write-barrier-imm
use: src/tagged-rep
literal: slot tag
temp: temp1/int-rep temp2/int-rep ;

INSN: ##alien-global
def: dst/int-rep
literal: symbol library ;

INSN: ##vm-field
def: dst/tagged-rep
literal: offset ;

INSN: ##set-vm-field
use: src/tagged-rep
literal: offset ;

! FFI
INSN: ##alien-invoke
literal: params stack-frame ;

INSN: ##alien-indirect
literal: params stack-frame ;

INSN: ##alien-assembly
literal: params stack-frame ;

INSN: ##alien-callback
literal: params stack-frame ;

! Instructions used by CFG IR only.
INSN: ##prologue ;
INSN: ##epilogue ;

INSN: ##branch ;

INSN: ##phi
def: dst
literal: inputs ;

! Tagged conditionals
INSN: ##compare-branch
use: src1/tagged-rep src2/tagged-rep
literal: cc ;

INSN: ##compare-imm-branch
use: src1/tagged-rep
literal: src2 cc ;

PURE-INSN: ##compare
def: dst/tagged-rep
use: src1/tagged-rep src2/tagged-rep
literal: cc
temp: temp/int-rep ;

PURE-INSN: ##compare-imm
def: dst/tagged-rep
use: src1/tagged-rep
literal: src2 cc
temp: temp/int-rep ;

! Integer conditionals
INSN: ##compare-integer-branch
use: src1/int-rep src2/int-rep
literal: cc ;

INSN: ##compare-integer-imm-branch
use: src1/int-rep
literal: src2 cc ;

PURE-INSN: ##compare-integer
def: dst/tagged-rep
use: src1/int-rep src2/int-rep
literal: cc
temp: temp/int-rep ;

PURE-INSN: ##compare-integer-imm
def: dst/tagged-rep
use: src1/int-rep
literal: src2 cc
temp: temp/int-rep ;

! Float conditionals
INSN: ##compare-float-ordered-branch
use: src1/double-rep src2/double-rep
literal: cc ;

INSN: ##compare-float-unordered-branch
use: src1/double-rep src2/double-rep
literal: cc ;

PURE-INSN: ##compare-float-ordered
def: dst/tagged-rep
use: src1/double-rep src2/double-rep
literal: cc
temp: temp/int-rep ;

PURE-INSN: ##compare-float-unordered
def: dst/tagged-rep
use: src1/double-rep src2/double-rep
literal: cc
temp: temp/int-rep ;

! Overflowing arithmetic
INSN: ##fixnum-add
def: dst/tagged-rep
use: src1/tagged-rep src2/tagged-rep ;

INSN: ##fixnum-sub
def: dst/tagged-rep
use: src1/tagged-rep src2/tagged-rep ;

INSN: ##fixnum-mul
def: dst/tagged-rep
use: src1/tagged-rep src2/int-rep ;

INSN: ##gc
temp: temp1/int-rep temp2/int-rep
literal: size data-values tagged-values uninitialized-locs ;

INSN: ##save-context
temp: temp1/int-rep temp2/int-rep ;

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
use: src
temp: temp ;

INSN: _dispatch-label
literal: label ;

INSN: _compare-branch
literal: label
use: src1 src2
literal: cc ;

INSN: _compare-imm-branch
literal: label
use: src1
literal: src2 cc ;

INSN: _compare-float-unordered-branch
literal: label
use: src1 src2
literal: cc ;

INSN: _compare-float-ordered-branch
literal: label
use: src1 src2
literal: cc ;

! Overflowing arithmetic
INSN: _fixnum-add
literal: label
def: dst
use: src1 src2 ;

INSN: _fixnum-sub
literal: label
def: dst
use: src1 src2 ;

INSN: _fixnum-mul
literal: label
def: dst
use: src1 src2 ;

TUPLE: spill-slot { n integer } ;
C: <spill-slot> spill-slot

INSN: _spill
use: src
literal: rep dst ;

INSN: _reload
def: dst
literal: rep src ;

INSN: _spill-area-size
literal: n ;

! For GC check insertion
UNION: ##allocation
##allot
##box-alien
##box-displaced-alien ;

! For alias analysis
UNION: ##read ##slot ##slot-imm ##vm-field ##alien-global ;
UNION: ##write ##set-slot ##set-slot-imm ##set-vm-field ;

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
##box-alien
##box-displaced-alien
##unbox-any-c-ptr ;

SYMBOL: vreg-insn

[
    vreg-insn
    insn-classes get [
        "insn-slots" word-prop [ type>> { def use temp } member-eq? ] any?
    ] filter
    define-union-class
] with-compilation-unit
