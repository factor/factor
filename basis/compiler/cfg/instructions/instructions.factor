! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs accessors arrays kernel sequences namespaces words
math math.order layouts classes.algebra alien byte-arrays
compiler.constants combinators compiler.cfg.registers
compiler.cfg.instructions.syntax ;
IN: compiler.cfg.instructions

: new-insn ( ... class -- insn ) [ f f ] dip boa ; inline

! Virtual CPU instructions, used by CFG and machine IRs
TUPLE: insn ;

! Instruction with no side effects; if 'out' is never read, we
! can eliminate it.
TUPLE: ##flushable < insn { dst vreg } ;

! Instruction which is referentially transparent; we can replace
! repeated computation with a reference to a previous value
TUPLE: ##pure < ##flushable ;

TUPLE: ##unary < ##pure { src vreg } ;
TUPLE: ##unary/temp < ##unary { temp vreg } ;
TUPLE: ##binary < ##pure { src1 vreg } { src2 vreg } ;
TUPLE: ##binary-imm < ##pure { src1 vreg } { src2 integer } ;
TUPLE: ##commutative < ##binary ;
TUPLE: ##commutative-imm < ##binary-imm ;

! Instruction only used for its side effect, produces no values
TUPLE: ##effect < insn { src vreg } ;

! Read/write ops: candidates for alias analysis
TUPLE: ##read < ##flushable ;
TUPLE: ##write < ##effect ;

TUPLE: ##alien-getter < ##flushable { src vreg } ;
TUPLE: ##alien-setter < ##effect { value vreg } ;

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
INSN: ##stack-frame stack-frame ;
INSN: ##call word { height integer } ;
INSN: ##jump word ;
INSN: ##return ;

! Jump tables
INSN: ##dispatch src temp ;

! Slot access
INSN: ##slot < ##read { obj vreg } { slot vreg } { tag integer } { temp vreg } ;
INSN: ##slot-imm < ##read { obj vreg } { slot integer } { tag integer } ;
INSN: ##set-slot < ##write { obj vreg } { slot vreg } { tag integer } { temp vreg } ;
INSN: ##set-slot-imm < ##write { obj vreg } { slot integer } { tag integer } ;

! String element access
INSN: ##string-nth < ##flushable { obj vreg } { index vreg } { temp vreg } ;
INSN: ##set-string-nth-fast < ##effect { obj vreg } { index vreg } { temp vreg } ;

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
INSN: ##shl-imm < ##binary-imm ;
INSN: ##shr-imm < ##binary-imm ;
INSN: ##sar-imm < ##binary-imm ;
INSN: ##not < ##unary ;
INSN: ##log2 < ##unary ;

! Overflowing arithmetic
TUPLE: ##fixnum-overflow < insn src1 src2 ;
INSN: ##fixnum-add < ##fixnum-overflow ;
INSN: ##fixnum-add-tail < ##fixnum-overflow ;
INSN: ##fixnum-sub < ##fixnum-overflow ;
INSN: ##fixnum-sub-tail < ##fixnum-overflow ;
INSN: ##fixnum-mul < ##fixnum-overflow temp1 temp2 ;
INSN: ##fixnum-mul-tail < ##fixnum-overflow temp1 temp2 ;

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

! Float/integer conversion
INSN: ##float>integer < ##unary ;
INSN: ##integer>float < ##unary ;

! Boxing and unboxing
INSN: ##copy < ##unary ;
INSN: ##copy-float < ##unary ;
INSN: ##unbox-float < ##unary ;
INSN: ##unbox-any-c-ptr < ##unary/temp ;
INSN: ##box-float < ##unary/temp ;
INSN: ##box-alien < ##unary/temp ;

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
INSN: ##allot < ##flushable size class { temp vreg } ;

UNION: ##allocation ##allot ##box-float ##box-alien ##integer>bignum ;

INSN: ##write-barrier < ##effect card# table ;

INSN: ##alien-global < ##flushable symbol library ;

! FFI
INSN: ##alien-invoke params ;
INSN: ##alien-indirect params ;
INSN: ##alien-callback params ;
INSN: ##callback-return params ;

! Instructions used by CFG IR only.
INSN: ##prologue ;
INSN: ##epilogue ;

INSN: ##branch ;

INSN: ##loop-entry ;

INSN: ##phi < ##pure inputs ;

! Condition codes
SYMBOL: cc<
SYMBOL: cc<=
SYMBOL: cc=
SYMBOL: cc>
SYMBOL: cc>=
SYMBOL: cc/=

: negate-cc ( cc -- cc' )
    H{
        { cc< cc>= }
        { cc<= cc> }
        { cc> cc<= }
        { cc>= cc< }
        { cc= cc/= }
        { cc/= cc= }
    } at ;

: evaluate-cc ( result cc -- ? )
    H{
        { cc<  { +lt+           } }
        { cc<= { +lt+ +eq+      } }
        { cc=  {      +eq+      } }
        { cc>= {      +eq+ +gt+ } }
        { cc>  {           +gt+ } }
        { cc/= { +lt+      +gt+ } }
    } at memq? ;

TUPLE: ##conditional-branch < insn { src1 vreg } { src2 vreg } cc ;

INSN: ##compare-branch < ##conditional-branch ;
INSN: ##compare-imm-branch { src1 vreg } { src2 integer } cc ;

INSN: ##compare < ##binary cc temp ;
INSN: ##compare-imm < ##binary-imm cc temp ;

INSN: ##compare-float-branch < ##conditional-branch ;
INSN: ##compare-float < ##binary cc temp ;

INSN: ##gc { temp1 vreg } { temp2 vreg } live-registers live-spill-slots ;

! Instructions used by machine IR only.
INSN: _prologue stack-frame ;
INSN: _epilogue stack-frame ;

INSN: _label id ;

INSN: _branch label ;

INSN: _dispatch src temp ;
INSN: _dispatch-label label ;

TUPLE: _conditional-branch < insn label { src1 vreg } { src2 vreg } cc ;

INSN: _compare-branch < _conditional-branch ;
INSN: _compare-imm-branch label { src1 vreg } { src2 integer } cc ;

INSN: _compare-float-branch < _conditional-branch ;

TUPLE: spill-slot n ; C: <spill-slot> spill-slot

INSN: _gc { temp1 vreg } { temp2 vreg } gc-roots gc-root-count gc-root-size ;

! These instructions operate on machine registers and not
! virtual registers
INSN: _spill src class n ;
INSN: _reload dst class n ;
INSN: _copy dst src class ;
INSN: _spill-counts counts ;

SYMBOL: temp-spill
