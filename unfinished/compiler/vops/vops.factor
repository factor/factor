! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: parser prettyprint.backend kernel accessors math
math.order sequences namespaces arrays assocs ;
IN: compiler.vops

TUPLE: vreg n ;

: VREG: scan-word vreg boa parsed ; parsing

M: vreg pprint* \ VREG: pprint-word n>> pprint* ;

SYMBOL: vreg-counter

: init-counter ( -- )
    { 0 } clone vreg-counter set ;

: next-vreg ( -- n )
    0 vreg-counter get [ dup 1+ ] change-nth vreg boa ;

: emit ( ... class -- ) boa , ; inline

! ! ! Instructions. Those prefixed with %% are high level
! ! ! instructions eliminated during the elaboration phase.
TUPLE: vop ;

! Instruction which does not touch vregs.
TUPLE: nullary-op < vop ;

! Does nothing
TUPLE: nop < nullary-op ;

: nop ( -- vop ) T{ nop } ;

: ?nop ( vop ? -- vop/nop ) [ drop nop ] unless ;

! Instruction with no side effects; if 'out' is never read, we
! can eliminate it.
TUPLE: flushable-op < vop out ;

! Instruction which is referentially transparent; we can replace
! repeated computation with a reference to a previous value
TUPLE: pure-op < flushable-op ;

! Instruction only used for its side effect, produces no values
TUPLE: effect-op < vop in ;

TUPLE: binary-op < pure-op in1 in2 ;

: inputs ( insn -- in1 in2 ) [ in1>> ] [ in2>> ] bi ; inline

: in/out ( insn -- in out ) [ in>> ] [ out>> ] bi ; inline

TUPLE: unary-op < pure-op in ;

! Merge point; out is a sequence of vregs in a sequence of
! sequences of vregs
TUPLE: %phi < pure-op in ;

! Integer, floating point, condition register copy
TUPLE: %copy < unary-op ;

! Constants
TUPLE: constant-op < pure-op value ;

TUPLE: %iconst < constant-op ; ! Integer
TUPLE: %fconst < constant-op ; ! Float
TUPLE: %cconst < constant-op ; ! Comparison result, +lt+ +eq+ +gt+

! Load address of literal table into out
TUPLE: %literal-table < pure-op ;

! Load object literal from table.
TUPLE: %literal < unary-op object ;

! Read/write ops: candidates for alias analysis
TUPLE: read-op < flushable-op ;
TUPLE: write-op < effect-op ;

! Stack shuffling
SINGLETON: %data
SINGLETON: %retain

TUPLE: %peek < read-op n stack ;
TUPLE: %replace < write-op n stack ;
TUPLE: %height < nullary-op n stack ;

: stack-loc ( insn -- pair ) [ n>> ] [ stack>> ] bi 2array ;

TUPLE: commutative-op < binary-op ;

! Integer arithmetic
TUPLE: %iadd < commutative-op ;
TUPLE: %isub < binary-op ;
TUPLE: %imul < commutative-op ;
TUPLE: %idiv < binary-op ;
TUPLE: %imod < binary-op ;
TUPLE: %icmp < binary-op ;

! Bitwise ops
TUPLE: %not < unary-op ;
TUPLE: %and < commutative-op ;
TUPLE: %or  < commutative-op ;
TUPLE: %xor < commutative-op ;
TUPLE: %shl < binary-op ;
TUPLE: %shr < binary-op ;
TUPLE: %sar < binary-op ;

! Float arithmetic
TUPLE: %fadd < commutative-op ;
TUPLE: %fsub < binary-op ;
TUPLE: %fmul < commutative-op ;
TUPLE: %fdiv < binary-op ;
TUPLE: %fcmp < binary-op ;

! Float/integer conversion
TUPLE: %f>i < unary-op ;
TUPLE: %i>f < unary-op ;

! Float boxing/unboxing
TUPLE: %%box-float < unary-op ;
TUPLE: %%unbox-float < unary-op ;

! High level slot accessors for alias analysis
! tag is f; if its not f, we can generate a faster sequence
TUPLE: %%slot < read-op obj slot tag ;
TUPLE: %%set-slot < write-op obj slot tag ;

TUPLE: %write-barrier < effect-op ;

! Memory
TUPLE: %load < unary-op ;
TUPLE: %store < effect-op addr ;

! Control flow; they jump to either the first or second successor
! of the BB

! Unconditional transfer to first successor
TUPLE: %b < nullary-op ;

SYMBOL: cc<
SYMBOL: cc<=
SYMBOL: cc=
SYMBOL: cc>
SYMBOL: cc>=
SYMBOL: cc/=

: evaluate-cc ( result cc -- ? )
    H{
        { cc<  { +lt+           } }
        { cc<= { +lt+ +eq+      } }
        { cc=  {      +eq+      } }
        { cc>= {      +eq+ +gt+ } }
        { cc>  {           +gt+ } }
        { cc/= { +lt+      +gt+ } }
    } at memq? ;

TUPLE: cond-branch < effect-op code ;

TUPLE: %bi < cond-branch ;
TUPLE: %bf < cond-branch ;

! Convert condition register to a boolean
TUPLE: boolean-op < unary-op code ;

TUPLE: %%iboolean < boolean-op ;
TUPLE: %%fboolean < boolean-op ;

! Dispatch table, jumps to successor 0..n-1 depending value of
! in, which must be in the range [0,n)
TUPLE: %dispatch < effect-op ;

! Procedures
TUPLE: %return < nullary-op ;
TUPLE: %prolog < nullary-op ;
TUPLE: %epilog < nullary-op ;
TUPLE: %jump < nullary-op word ;
TUPLE: %call < nullary-op word ;

! Heap allocation
TUPLE: %%allot < flushable-op size tag type ;
