! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs accessors arrays kernel sequences namespaces words
math math.order layouts classes.algebra alien byte-arrays
compiler.constants combinators compiler.cfg.registers
compiler.cfg.instructions.syntax ;
IN: compiler.cfg.instructions

: new-insn ( ... class -- insn ) f swap boa ; inline

! Virtual CPU instructions, used by CFG and machine IRs
TUPLE: insn ;

! Instruction with no side effects; if 'out' is never read, we
! can eliminate it.
TUPLE: ##flushable < insn dst ;

! Instruction which is referentially transparent; we can replace
! repeated computation with a reference to a previous value
TUPLE: ##pure < ##flushable ;

TUPLE: ##unary < ##pure src ;
TUPLE: ##unary/temp < ##unary temp ;
TUPLE: ##binary < ##pure src1 src2 ;
TUPLE: ##binary-imm < ##pure src1 { src2 integer } ;
TUPLE: ##commutative < ##binary ;
TUPLE: ##commutative-imm < ##binary-imm ;

! Instruction only used for its side effect, produces no values
TUPLE: ##effect < insn src ;

! Read/write ops: candidates for alias analysis
TUPLE: ##read < ##flushable ;
TUPLE: ##write < ##effect ;

TUPLE: ##alien-getter < ##flushable src ;
TUPLE: ##alien-setter < ##effect value ;

! Stack operations
INSN: ##load-immediate < ##pure { val integer } ;
INSN: ##load-reference < ##pure obj ;

GENERIC: ##load-literal ( dst value -- )

M: fixnum ##load-literal tag-fixnum ##load-immediate ;
M: f ##load-literal drop \ f tag-number ##load-immediate ;
M: object ##load-literal ##load-reference ;

INSN: ##peek < ##flushable { loc loc } ;
INSN: ##replace < ##effect { loc loc } ;
INSN: ##inc-d { n integer } ;
INSN: ##inc-r { n integer } ;

! Subroutine calls
INSN: ##call word ;
INSN: ##jump word ;
INSN: ##return ;

! Dummy instruction that simply inhibits TCO
INSN: ##no-tco ;

! Jump tables
INSN: ##dispatch src temp ;

! Slot access
INSN: ##slot < ##read obj slot { tag integer } temp ;
INSN: ##slot-imm < ##read obj { slot integer } { tag integer } ;
INSN: ##set-slot < ##write obj slot { tag integer } temp ;
INSN: ##set-slot-imm < ##write obj { slot integer } { tag integer } ;

! String element access
INSN: ##string-nth < ##flushable obj index temp ;
INSN: ##set-string-nth-fast < ##effect obj index temp ;

! Integer arithmetic
INSN: ##add < ##commutative ;
INSN: ##add-imm < ##commutative-imm ;
INSN: ##sub < ##binary ;
INSN: ##sub-imm < ##binary-imm ;
INSN: ##mul < ##commutative ;
INSN: ##mul-imm < ##commutative-imm ;
INSN: ##and < ##commutative ;
INSN: ##and-imm < ##commutative-imm ;
INSN: ##or < ##commutative ;
INSN: ##or-imm < ##commutative-imm ;
INSN: ##xor < ##commutative ;
INSN: ##xor-imm < ##commutative-imm ;
INSN: ##shl < ##binary ;
INSN: ##shl-imm < ##binary-imm ;
INSN: ##shr < ##binary ;
INSN: ##shr-imm < ##binary-imm ;
INSN: ##sar < ##binary ;
INSN: ##sar-imm < ##binary-imm ;
INSN: ##min < ##binary ;
INSN: ##max < ##binary ;
INSN: ##not < ##unary ;
INSN: ##log2 < ##unary ;

: ##tag-fixnum ( dst src -- ) tag-bits get ##shl-imm ; inline
: ##untag-fixnum ( dst src -- ) tag-bits get ##sar-imm ; inline

! Bignum/integer conversion
INSN: ##integer>bignum < ##unary/temp ;
INSN: ##bignum>integer < ##unary/temp ;

! Float arithmetic
INSN: ##add-float < ##commutative ;
INSN: ##sub-float < ##binary ;
INSN: ##mul-float < ##commutative ;
INSN: ##div-float < ##binary ;
INSN: ##min-float < ##binary ;
INSN: ##max-float < ##binary ;
INSN: ##sqrt < ##unary ;

! libc intrinsics
INSN: ##unary-float-function < ##unary func ;
INSN: ##binary-float-function < ##binary func ;

! Float/integer conversion
INSN: ##float>integer < ##unary ;
INSN: ##integer>float < ##unary ;

! Boxing and unboxing
INSN: ##copy < ##unary rep ;
INSN: ##unbox-float < ##unary ;
INSN: ##unbox-any-c-ptr < ##unary/temp ;
INSN: ##box-float < ##unary/temp ;
INSN: ##box-alien < ##unary/temp ;
INSN: ##box-displaced-alien < ##binary temp1 temp2 base-class ;

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
INSN: ##alien-unsigned-1 < ##alien-getter ;
INSN: ##alien-unsigned-2 < ##alien-getter ;
INSN: ##alien-unsigned-4 < ##alien-getter ;
INSN: ##alien-signed-1 < ##alien-getter ;
INSN: ##alien-signed-2 < ##alien-getter ;
INSN: ##alien-signed-4 < ##alien-getter ;
INSN: ##alien-cell < ##alien-getter ;
INSN: ##alien-float < ##alien-getter ;
INSN: ##alien-double < ##alien-getter ;

INSN: ##set-alien-integer-1 < ##alien-setter ;
INSN: ##set-alien-integer-2 < ##alien-setter ;
INSN: ##set-alien-integer-4 < ##alien-setter ;
INSN: ##set-alien-cell < ##alien-setter ;
INSN: ##set-alien-float < ##alien-setter ;
INSN: ##set-alien-double < ##alien-setter ;

! Memory allocation
INSN: ##allot < ##flushable size class temp ;

UNION: ##allocation
##allot
##box-float
##box-alien
##box-displaced-alien
##integer>bignum ;

INSN: ##write-barrier < ##effect card# table ;

INSN: ##alien-global < ##flushable symbol library ;

! FFI
INSN: ##alien-invoke params stack-frame ;
INSN: ##alien-indirect params stack-frame ;
INSN: ##alien-callback params stack-frame ;
INSN: ##callback-return params ;

! Instructions used by CFG IR only.
INSN: ##prologue ;
INSN: ##epilogue ;

INSN: ##branch ;

INSN: ##phi < ##pure inputs ;

! Conditionals
TUPLE: ##conditional-branch < insn src1 src2 cc ;

INSN: ##compare-branch < ##conditional-branch ;
INSN: ##compare-imm-branch src1 { src2 integer } cc ;

INSN: ##compare < ##binary cc temp ;
INSN: ##compare-imm < ##binary-imm cc temp ;

INSN: ##compare-float-branch < ##conditional-branch ;
INSN: ##compare-float < ##binary cc temp ;

! Overflowing arithmetic
TUPLE: ##fixnum-overflow < insn dst src1 src2 ;
INSN: ##fixnum-add < ##fixnum-overflow ;
INSN: ##fixnum-sub < ##fixnum-overflow ;
INSN: ##fixnum-mul < ##fixnum-overflow ;

INSN: ##gc temp1 temp2 data-values tagged-values uninitialized-locs ;

! Instructions used by machine IR only.
INSN: _prologue stack-frame ;
INSN: _epilogue stack-frame ;

INSN: _label id ;

INSN: _branch label ;
INSN: _loop-entry ;

INSN: _dispatch src temp ;
INSN: _dispatch-label label ;

TUPLE: _conditional-branch < insn label src1 src2 cc ;

INSN: _compare-branch < _conditional-branch ;
INSN: _compare-imm-branch label src1 { src2 integer } cc ;

INSN: _compare-float-branch < _conditional-branch ;

! Overflowing arithmetic
TUPLE: _fixnum-overflow < insn label dst src1 src2 ;
INSN: _fixnum-add < _fixnum-overflow ;
INSN: _fixnum-sub < _fixnum-overflow ;
INSN: _fixnum-mul < _fixnum-overflow ;

TUPLE: spill-slot n ; C: <spill-slot> spill-slot

INSN: _gc temp1 temp2 data-values tagged-values uninitialized-locs ;

! These instructions operate on machine registers and not
! virtual registers
INSN: _spill src rep n ;
INSN: _reload dst rep n ;
INSN: _spill-area-size n ;

! Instructions that use vregs
UNION: vreg-insn
    ##flushable
    ##write-barrier
    ##dispatch
    ##effect
    ##fixnum-overflow
    ##conditional-branch
    ##compare-imm-branch
    ##phi
    ##gc
    _conditional-branch
    _compare-imm-branch
    _dispatch ;

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

! Instructions that output floats
UNION: output-float-insn
    ##add-float
    ##sub-float
    ##mul-float
    ##div-float
    ##min-float
    ##max-float
    ##sqrt
    ##unary-float-function
    ##binary-float-function
    ##integer>float
    ##unbox-float
    ##alien-float
    ##alien-double ;

! Instructions that take floats as inputs
UNION: input-float-insn
    ##add-float
    ##sub-float
    ##mul-float
    ##div-float
    ##min-float
    ##max-float
    ##sqrt
    ##unary-float-function
    ##binary-float-function
    ##float>integer
    ##box-float
    ##set-alien-float
    ##set-alien-double
    ##compare-float
    ##compare-float-branch ;

! Smackdown
INTERSECTION: ##unary-float ##unary input-float-insn ;
INTERSECTION: ##binary-float ##binary input-float-insn ;

! Instructions that have complex expansions and require that the
! output registers are not equal to any of the input registers
UNION: def-is-use-insn
    ##integer>bignum
    ##bignum>integer
    ##unbox-any-c-ptr ;