! Copyright (C) 2008, 2011 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors compiler.cfg.instructions.syntax kernel math
namespaces ;
IN: compiler.cfg.instructions

<<
SYMBOL: insn-classes
V{ } clone insn-classes set-global
>>

: new-insn ( ... class -- insn ) f swap boa ; inline

TUPLE: insn ;

TUPLE: vreg-insn < insn ;

TUPLE: flushable-insn < vreg-insn ;

TUPLE: foldable-insn < flushable-insn ;

! Constants
FOLDABLE-INSN: ##load-integer
def: dst/int-rep
literal: val ;

FOLDABLE-INSN: ##load-reference
def: dst/tagged-rep
literal: obj ;

! These four are inserted by representation selection
FLUSHABLE-INSN: ##load-tagged
def: dst/tagged-rep
literal: val ;

FLUSHABLE-INSN: ##load-float
def: dst/float-rep
literal: val ;

FLUSHABLE-INSN: ##load-double
def: dst/double-rep
literal: val ;

FLUSHABLE-INSN: ##load-vector
def: dst
literal: val rep ;

! Stack operations
FLUSHABLE-INSN: ##peek
def: dst/tagged-rep
literal: loc ;

VREG-INSN: ##replace
use: src/tagged-rep
literal: loc ;

INSN: ##replace-imm
literal: src loc ;

INSN: ##clear
literal: loc ;

INSN: ##inc
literal: loc ;

! Subroutine calls
INSN: ##call
literal: word ;

INSN: ##jump
literal: word ;

INSN: ##prologue ;

INSN: ##epilogue ;

INSN: ##return ;

INSN: ##safepoint ;

INSN: ##no-tco ;

! Jump tables
VREG-INSN: ##dispatch
use: src/int-rep
temp: temp/int-rep ;

! Slot access
FLUSHABLE-INSN: ##slot
def: dst/tagged-rep
use: obj/tagged-rep slot/int-rep
literal: scale tag ;

FLUSHABLE-INSN: ##slot-imm
def: dst/tagged-rep
use: obj/tagged-rep
literal: slot tag ;

VREG-INSN: ##set-slot
use: src/tagged-rep obj/tagged-rep slot/int-rep
literal: scale tag ;

VREG-INSN: ##set-slot-imm
use: src/tagged-rep obj/tagged-rep
literal: slot tag ;

! Register transfers
FOLDABLE-INSN: ##copy
def: dst
use: src
literal: rep ;

! Only used by compiler.cfg.cssa
FLUSHABLE-INSN: ##parallel-copy
literal: values ;

FOLDABLE-INSN: ##tagged>integer
def: dst/int-rep
use: src/tagged-rep ;

! Integer arithmetic
FOLDABLE-INSN: ##add
def: dst/int-rep
use: src1/int-rep src2/int-rep ;

FOLDABLE-INSN: ##add-imm
def: dst/int-rep
use: src1/int-rep
literal: src2 ;

FOLDABLE-INSN: ##sub
def: dst/int-rep
use: src1/int-rep src2/int-rep ;

FOLDABLE-INSN: ##sub-imm
def: dst/int-rep
use: src1/int-rep
literal: src2 ;

FOLDABLE-INSN: ##mul
def: dst/int-rep
use: src1/int-rep src2/int-rep ;

FOLDABLE-INSN: ##mul-imm
def: dst/int-rep
use: src1/int-rep
literal: src2 ;

FOLDABLE-INSN: ##and
def: dst/int-rep
use: src1/int-rep src2/int-rep ;

FOLDABLE-INSN: ##and-imm
def: dst/int-rep
use: src1/int-rep
literal: src2 ;

FOLDABLE-INSN: ##or
def: dst/int-rep
use: src1/int-rep src2/int-rep ;

FOLDABLE-INSN: ##or-imm
def: dst/int-rep
use: src1/int-rep
literal: src2 ;

FOLDABLE-INSN: ##xor
def: dst/int-rep
use: src1/int-rep src2/int-rep ;

FOLDABLE-INSN: ##xor-imm
def: dst/int-rep
use: src1/int-rep
literal: src2 ;

FOLDABLE-INSN: ##shl
def: dst/int-rep
use: src1/int-rep src2/int-rep ;

FOLDABLE-INSN: ##shl-imm
def: dst/int-rep
use: src1/int-rep
literal: src2 ;

FOLDABLE-INSN: ##shr
def: dst/int-rep
use: src1/int-rep src2/int-rep ;

FOLDABLE-INSN: ##shr-imm
def: dst/int-rep
use: src1/int-rep
literal: src2 ;

FOLDABLE-INSN: ##sar
def: dst/int-rep
use: src1/int-rep src2/int-rep ;

FOLDABLE-INSN: ##sar-imm
def: dst/int-rep
use: src1/int-rep
literal: src2 ;

FOLDABLE-INSN: ##min
def: dst/int-rep
use: src1/int-rep src2/int-rep ;

FOLDABLE-INSN: ##max
def: dst/int-rep
use: src1/int-rep src2/int-rep ;

FOLDABLE-INSN: ##not
def: dst/int-rep
use: src/int-rep ;

FOLDABLE-INSN: ##neg
def: dst/int-rep
use: src/int-rep ;

FOLDABLE-INSN: ##log2
def: dst/int-rep
use: src/int-rep ;

FOLDABLE-INSN: ##bit-count
def: dst/int-rep
use: src/int-rep ;

FOLDABLE-INSN: ##bit-test
def: dst/tagged-rep
use: src1/int-rep src2/int-rep
temp: temp/int-rep ;

! Float arithmetic
FOLDABLE-INSN: ##add-float
def: dst/double-rep
use: src1/double-rep src2/double-rep ;

FOLDABLE-INSN: ##sub-float
def: dst/double-rep
use: src1/double-rep src2/double-rep ;

FOLDABLE-INSN: ##mul-float
def: dst/double-rep
use: src1/double-rep src2/double-rep ;

FOLDABLE-INSN: ##div-float
def: dst/double-rep
use: src1/double-rep src2/double-rep ;

FOLDABLE-INSN: ##min-float
def: dst/double-rep
use: src1/double-rep src2/double-rep ;

FOLDABLE-INSN: ##max-float
def: dst/double-rep
use: src1/double-rep src2/double-rep ;

FOLDABLE-INSN: ##sqrt
def: dst/double-rep
use: src/double-rep ;

! Single/double float conversion
FOLDABLE-INSN: ##single>double-float
def: dst/double-rep
use: src/float-rep ;

FOLDABLE-INSN: ##double>single-float
def: dst/float-rep
use: src/double-rep ;

! Float/integer conversion
FOLDABLE-INSN: ##float>integer
def: dst/int-rep
use: src/double-rep ;

FOLDABLE-INSN: ##integer>float
def: dst/double-rep
use: src/int-rep ;

! SIMD operations
FOLDABLE-INSN: ##zero-vector
def: dst
literal: rep ;

FOLDABLE-INSN: ##fill-vector
def: dst
literal: rep ;

FOLDABLE-INSN: ##gather-vector-2
def: dst
use: src1/scalar-rep src2/scalar-rep
literal: rep ;

FOLDABLE-INSN: ##gather-int-vector-2
def: dst
use: src1/int-rep src2/int-rep
literal: rep ;

FOLDABLE-INSN: ##gather-vector-4
def: dst
use: src1/scalar-rep src2/scalar-rep src3/scalar-rep src4/scalar-rep
literal: rep ;

FOLDABLE-INSN: ##gather-int-vector-4
def: dst
use: src1/int-rep src2/int-rep src3/int-rep src4/int-rep
literal: rep ;

FOLDABLE-INSN: ##select-vector
def: dst/int-rep
use: src
literal: n rep ;

FOLDABLE-INSN: ##shuffle-vector
def: dst
use: src shuffle
literal: rep ;

FOLDABLE-INSN: ##shuffle-vector-halves-imm
def: dst
use: src1 src2
literal: shuffle rep ;

FOLDABLE-INSN: ##shuffle-vector-imm
def: dst
use: src
literal: shuffle rep ;

FOLDABLE-INSN: ##tail>head-vector
def: dst
use: src
literal: rep ;

FOLDABLE-INSN: ##merge-vector-head
def: dst
use: src1 src2
literal: rep ;

FOLDABLE-INSN: ##merge-vector-tail
def: dst
use: src1 src2
literal: rep ;

FOLDABLE-INSN: ##float-pack-vector
def: dst
use: src
literal: rep ;

FOLDABLE-INSN: ##signed-pack-vector
def: dst
use: src1 src2
literal: rep ;

FOLDABLE-INSN: ##unsigned-pack-vector
def: dst
use: src1 src2
literal: rep ;

FOLDABLE-INSN: ##unpack-vector-head
def: dst
use: src
literal: rep ;

FOLDABLE-INSN: ##unpack-vector-tail
def: dst
use: src
literal: rep ;

FOLDABLE-INSN: ##integer>float-vector
def: dst
use: src
literal: rep ;

FOLDABLE-INSN: ##float>integer-vector
def: dst
use: src
literal: rep ;

FOLDABLE-INSN: ##compare-vector
def: dst
use: src1 src2
literal: rep cc ;

FOLDABLE-INSN: ##move-vector-mask
def: dst/int-rep
use: src
literal: rep ;

FOLDABLE-INSN: ##test-vector
def: dst/tagged-rep
use: src1
temp: temp/int-rep
literal: rep vcc ;

VREG-INSN: ##test-vector-branch
use: src1
temp: temp/int-rep
literal: rep vcc ;

FOLDABLE-INSN: ##add-vector
def: dst
use: src1 src2
literal: rep ;

FOLDABLE-INSN: ##saturated-add-vector
def: dst
use: src1 src2
literal: rep ;

FOLDABLE-INSN: ##add-sub-vector
def: dst
use: src1 src2
literal: rep ;

FOLDABLE-INSN: ##sub-vector
def: dst
use: src1 src2
literal: rep ;

FOLDABLE-INSN: ##saturated-sub-vector
def: dst
use: src1 src2
literal: rep ;

FOLDABLE-INSN: ##mul-vector
def: dst
use: src1 src2
literal: rep ;

FOLDABLE-INSN: ##mul-high-vector
def: dst
use: src1 src2
literal: rep ;

FOLDABLE-INSN: ##mul-horizontal-add-vector
def: dst
use: src1 src2
literal: rep ;

FOLDABLE-INSN: ##saturated-mul-vector
def: dst
use: src1 src2
literal: rep ;

FOLDABLE-INSN: ##div-vector
def: dst
use: src1 src2
literal: rep ;

FOLDABLE-INSN: ##min-vector
def: dst
use: src1 src2
literal: rep ;

FOLDABLE-INSN: ##max-vector
def: dst
use: src1 src2
literal: rep ;

FOLDABLE-INSN: ##avg-vector
def: dst
use: src1 src2
literal: rep ;

FOLDABLE-INSN: ##dot-vector
def: dst/scalar-rep
use: src1 src2
literal: rep ;

FOLDABLE-INSN: ##sad-vector
def: dst
use: src1 src2
literal: rep ;

FOLDABLE-INSN: ##horizontal-add-vector
def: dst
use: src1 src2
literal: rep ;

FOLDABLE-INSN: ##horizontal-sub-vector
def: dst
use: src1 src2
literal: rep ;

FOLDABLE-INSN: ##horizontal-shl-vector-imm
def: dst
use: src1
literal: src2 rep ;

FOLDABLE-INSN: ##horizontal-shr-vector-imm
def: dst
use: src1
literal: src2 rep ;

FOLDABLE-INSN: ##abs-vector
def: dst
use: src
literal: rep ;

FOLDABLE-INSN: ##sqrt-vector
def: dst
use: src
literal: rep ;

FOLDABLE-INSN: ##and-vector
def: dst
use: src1 src2
literal: rep ;

FOLDABLE-INSN: ##andn-vector
def: dst
use: src1 src2
literal: rep ;

FOLDABLE-INSN: ##or-vector
def: dst
use: src1 src2
literal: rep ;

FOLDABLE-INSN: ##xor-vector
def: dst
use: src1 src2
literal: rep ;

FOLDABLE-INSN: ##not-vector
def: dst
use: src
literal: rep ;

FOLDABLE-INSN: ##shl-vector-imm
def: dst
use: src1
literal: src2 rep ;

FOLDABLE-INSN: ##shr-vector-imm
def: dst
use: src1
literal: src2 rep ;

FOLDABLE-INSN: ##shl-vector
def: dst
use: src1 src2/int-scalar-rep
literal: rep ;

FOLDABLE-INSN: ##shr-vector
def: dst
use: src1 src2/int-scalar-rep
literal: rep ;

! Scalar/vector conversion
FOLDABLE-INSN: ##scalar>integer
def: dst/int-rep
use: src
literal: rep ;

FOLDABLE-INSN: ##integer>scalar
def: dst
use: src/int-rep
literal: rep ;

FOLDABLE-INSN: ##vector>scalar
def: dst/scalar-rep
use: src
literal: rep ;

FOLDABLE-INSN: ##scalar>vector
def: dst
use: src/scalar-rep
literal: rep ;

! Boxing and unboxing aliens
FOLDABLE-INSN: ##box-alien
def: dst/tagged-rep
use: src/int-rep
temp: temp/int-rep ;

FOLDABLE-INSN: ##box-displaced-alien
def: dst/tagged-rep
use: displacement/int-rep base/tagged-rep
temp: temp/int-rep
literal: base-class ;

FOLDABLE-INSN: ##unbox-any-c-ptr
def: dst/int-rep
use: src/tagged-rep ;

FOLDABLE-INSN: ##unbox-alien
def: dst/int-rep
use: src/tagged-rep ;

! Zero-extending and sign-extending integers
FOLDABLE-INSN: ##convert-integer
def: dst/int-rep
use: src/int-rep
literal: c-type ;

! Raw memory accessors
FLUSHABLE-INSN: ##load-memory
def: dst
use: base/int-rep displacement/int-rep
literal: scale offset rep c-type ;

FLUSHABLE-INSN: ##load-memory-imm
def: dst
use: base/int-rep
literal: offset rep c-type ;

VREG-INSN: ##store-memory
use: src base/int-rep displacement/int-rep
literal: scale offset rep c-type ;

VREG-INSN: ##store-memory-imm
use: src base/int-rep
literal: offset rep c-type ;

! Memory allocation
FLUSHABLE-INSN: ##allot
def: dst/tagged-rep
literal: size class-of
temp: temp/int-rep ;

VREG-INSN: ##write-barrier
use: src/tagged-rep slot/int-rep
literal: scale tag
temp: temp1/int-rep temp2/int-rep ;

VREG-INSN: ##write-barrier-imm
use: src/tagged-rep
literal: slot tag
temp: temp1/int-rep temp2/int-rep ;

FLUSHABLE-INSN: ##alien-global
def: dst/int-rep
literal: symbol library ;

FLUSHABLE-INSN: ##vm-field
def: dst/tagged-rep
literal: offset ;

VREG-INSN: ##set-vm-field
use: src/tagged-rep
literal: offset ;

! FFI
FOLDABLE-INSN: ##unbox
def: dst
use: src/tagged-rep
literal: unboxer rep ;

FOLDABLE-INSN: ##unbox-long-long
def: dst1/int-rep dst2/int-rep
use: src/tagged-rep
literal: unboxer ;

FLUSHABLE-INSN: ##local-allot
def: dst/int-rep
literal: size align offset ;

FOLDABLE-INSN: ##box
def: dst/tagged-rep
use: src
literal: boxer rep gc-map ;

FOLDABLE-INSN: ##box-long-long
def: dst/tagged-rep
use: src1/int-rep src2/int-rep
literal: boxer gc-map ;

! Alien call inputs and outputs are arrays of triples with shape
! { vreg rep stack#/reg }

VREG-INSN: ##alien-invoke
literal: varargs? reg-inputs stack-inputs reg-outputs dead-outputs cleanup stack-size symbols dll gc-map ;

VREG-INSN: ##alien-indirect
use: src/int-rep
literal: varargs? reg-inputs stack-inputs reg-outputs dead-outputs cleanup stack-size gc-map ;

VREG-INSN: ##alien-assembly
literal: varargs? reg-inputs stack-inputs reg-outputs dead-outputs cleanup stack-size quot ;

VREG-INSN: ##callback-inputs
literal: reg-outputs stack-outputs ;

VREG-INSN: ##callback-outputs
literal: reg-inputs ;

! Control flow
FLUSHABLE-INSN: ##phi
def: dst
literal: inputs ;

INSN: ##branch ;

! Tagged conditionals
VREG-INSN: ##compare-branch
use: src1/tagged-rep src2/tagged-rep
literal: cc ;

VREG-INSN: ##compare-imm-branch
use: src1/tagged-rep
literal: src2 cc ;

FOLDABLE-INSN: ##compare
def: dst/tagged-rep
use: src1/tagged-rep src2/tagged-rep
literal: cc
temp: temp/int-rep ;

FOLDABLE-INSN: ##compare-imm
def: dst/tagged-rep
use: src1/tagged-rep
literal: src2 cc
temp: temp/int-rep ;

! Integer conditionals
VREG-INSN: ##compare-integer-branch
use: src1/int-rep src2/int-rep
literal: cc ;

VREG-INSN: ##compare-integer-imm-branch
use: src1/int-rep
literal: src2 cc ;

VREG-INSN: ##test-branch
use: src1/int-rep src2/int-rep
literal: cc ;

VREG-INSN: ##test-imm-branch
use: src1/int-rep
literal: src2 cc ;

FOLDABLE-INSN: ##compare-integer
def: dst/tagged-rep
use: src1/int-rep src2/int-rep
literal: cc
temp: temp/int-rep ;

FOLDABLE-INSN: ##compare-integer-imm
def: dst/tagged-rep
use: src1/int-rep
literal: src2 cc
temp: temp/int-rep ;

FOLDABLE-INSN: ##test
def: dst/tagged-rep
use: src1/int-rep src2/int-rep
literal: cc
temp: temp/int-rep ;

FOLDABLE-INSN: ##test-imm
def: dst/tagged-rep
use: src1/int-rep
literal: src2 cc
temp: temp/int-rep ;

! Float conditionals
VREG-INSN: ##compare-float-ordered-branch
use: src1/double-rep src2/double-rep
literal: cc ;

VREG-INSN: ##compare-float-unordered-branch
use: src1/double-rep src2/double-rep
literal: cc ;

FOLDABLE-INSN: ##compare-float-ordered
def: dst/tagged-rep
use: src1/double-rep src2/double-rep
literal: cc
temp: temp/int-rep ;

FOLDABLE-INSN: ##compare-float-unordered
def: dst/tagged-rep
use: src1/double-rep src2/double-rep
literal: cc
temp: temp/int-rep ;

! Overflowing arithmetic
VREG-INSN: ##fixnum-add
def: dst/tagged-rep
use: src1/tagged-rep src2/tagged-rep
literal: cc ;

VREG-INSN: ##fixnum-sub
def: dst/tagged-rep
use: src1/tagged-rep src2/tagged-rep
literal: cc ;

VREG-INSN: ##fixnum-mul
def: dst/tagged-rep
use: src1/tagged-rep src2/int-rep
literal: cc ;

VREG-INSN: ##save-context
temp: temp1/int-rep temp2/int-rep ;

! GC checks
VREG-INSN: ##check-nursery-branch
literal: size cc
temp: temp1/int-rep temp2/int-rep ;

INSN: ##call-gc
literal: gc-map ;

! Spills and reloads, inserted by register allocator
TUPLE: spill-slot { n integer } ;
C: <spill-slot> spill-slot

VREG-INSN: ##spill
use: src
literal: rep dst ;

VREG-INSN: ##reload
def: dst
literal: rep src ;

UNION: allocation-insn
    ##allot
    ##box-alien
    ##box-displaced-alien ;

UNION: conditional-branch-insn
    ##compare-branch
    ##compare-imm-branch
    ##compare-integer-branch
    ##compare-integer-imm-branch
    ##test-branch
    ##test-imm-branch
    ##compare-float-ordered-branch
    ##compare-float-unordered-branch
    ##test-vector-branch
    ##check-nursery-branch
    ##fixnum-add
    ##fixnum-sub
    ##fixnum-mul ;

! For alias analysis
UNION: read-insn ##slot ##slot-imm ##vm-field ##alien-global ;
UNION: write-insn ##set-slot ##set-slot-imm ##set-vm-field ;

UNION: alien-call-insn
    ##alien-assembly
    ##alien-indirect
    ##alien-invoke ;

UNION: gc-map-insn
    ##call-gc
    ##box
    ##box-long-long
    ##alien-indirect
    ##alien-invoke ;

M: gc-map-insn clone call-next-method [ clone ] change-gc-map ;

TUPLE: gc-map gc-roots derived-roots ;

: <gc-map> ( -- gc-map ) gc-map new ;

UNION: def-is-use-insn
    ##box-alien
    ##box-displaced-alien
    ##unbox-any-c-ptr ;
