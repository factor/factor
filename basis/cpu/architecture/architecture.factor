! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays generic kernel kernel.private math
memory namespaces make sequences layouts system hashtables
classes alien byte-arrays combinators words sets fry ;
IN: cpu.architecture

! Representations -- these are like low-level types

! Unknown representation; this is used for ##copy instructions which
! get eliminated later
SINGLETON: any-rep

! Integer registers can contain data with one of these three representations
! tagged-rep: tagged pointer or fixnum
! int-rep: untagged fixnum, not a pointer
SINGLETONS: tagged-rep int-rep ;

! Floating point registers can contain data with
! one of these representations
SINGLETONS: single-float-rep double-float-rep ;

UNION: representation any-rep tagged-rep int-rep single-float-rep double-float-rep ;

! Register classes
SINGLETONS: int-regs float-regs ;

UNION: reg-class int-regs float-regs ;
CONSTANT: reg-classes { int-regs float-regs }

! A pseudo-register class for parameters spilled on the stack
SINGLETON: stack-params

: reg-class-of ( rep -- reg-class )
    {
        { tagged-rep [ int-regs ] }
        { int-rep [ int-regs ] }
        { single-float-rep [ float-regs ] }
        { double-float-rep [ float-regs ] }
        { stack-params [ stack-params ] }
    } case ;

: rep-size ( rep -- n )
    {
        { tagged-rep [ cell ] }
        { int-rep [ cell ] }
        { single-float-rep [ 4 ] }
        { double-float-rep [ 8 ] }
        { stack-params [ cell ] }
    } case ;

! Mapping from register class to machine registers
HOOK: machine-registers cpu ( -- assoc )

HOOK: two-operand? cpu ( -- ? )

HOOK: %load-immediate cpu ( reg obj -- )
HOOK: %load-reference cpu ( reg obj -- )

HOOK: %peek cpu ( vreg loc -- )
HOOK: %replace cpu ( vreg loc -- )
HOOK: %inc-d cpu ( n -- )
HOOK: %inc-r cpu ( n -- )

HOOK: stack-frame-size cpu ( stack-frame -- n )
HOOK: %call cpu ( word -- )
HOOK: %jump cpu ( word -- )
HOOK: %jump-label cpu ( label -- )
HOOK: %return cpu ( -- )

HOOK: %dispatch cpu ( src temp -- )

HOOK: %slot cpu ( dst obj slot tag temp -- )
HOOK: %slot-imm cpu ( dst obj slot tag -- )
HOOK: %set-slot cpu ( src obj slot tag temp -- )
HOOK: %set-slot-imm cpu ( src obj slot tag -- )

HOOK: %string-nth cpu ( dst obj index temp -- )
HOOK: %set-string-nth-fast cpu ( ch obj index temp -- )

HOOK: %add     cpu ( dst src1 src2 -- )
HOOK: %add-imm cpu ( dst src1 src2 -- )
HOOK: %sub     cpu ( dst src1 src2 -- )
HOOK: %sub-imm cpu ( dst src1 src2 -- )
HOOK: %mul     cpu ( dst src1 src2 -- )
HOOK: %mul-imm cpu ( dst src1 src2 -- )
HOOK: %and     cpu ( dst src1 src2 -- )
HOOK: %and-imm cpu ( dst src1 src2 -- )
HOOK: %or      cpu ( dst src1 src2 -- )
HOOK: %or-imm  cpu ( dst src1 src2 -- )
HOOK: %xor     cpu ( dst src1 src2 -- )
HOOK: %xor-imm cpu ( dst src1 src2 -- )
HOOK: %shl     cpu ( dst src1 src2 -- )
HOOK: %shl-imm cpu ( dst src1 src2 -- )
HOOK: %shr     cpu ( dst src1 src2 -- )
HOOK: %shr-imm cpu ( dst src1 src2 -- )
HOOK: %sar     cpu ( dst src1 src2 -- )
HOOK: %sar-imm cpu ( dst src1 src2 -- )
HOOK: %not     cpu ( dst src -- )
HOOK: %log2    cpu ( dst src -- )

HOOK: %fixnum-add cpu ( label dst src1 src2 -- )
HOOK: %fixnum-sub cpu ( label dst src1 src2 -- )
HOOK: %fixnum-mul cpu ( label dst src1 src2 -- )

HOOK: %integer>bignum cpu ( dst src temp -- )
HOOK: %bignum>integer cpu ( dst src temp -- )

HOOK: %add-float cpu ( dst src1 src2 -- )
HOOK: %sub-float cpu ( dst src1 src2 -- )
HOOK: %mul-float cpu ( dst src1 src2 -- )
HOOK: %div-float cpu ( dst src1 src2 -- )
HOOK: %sqrt cpu ( dst src -- )

HOOK: %integer>float cpu ( dst src -- )
HOOK: %float>integer cpu ( dst src -- )

HOOK: %copy cpu ( dst src rep -- )
HOOK: %unbox-float cpu ( dst src -- )
HOOK: %unbox-any-c-ptr cpu ( dst src temp -- )
HOOK: %box-float cpu ( dst src temp -- )
HOOK: %box-alien cpu ( dst src temp -- )
HOOK: %box-displaced-alien cpu ( dst displacement base temp -- )

HOOK: %alien-unsigned-1 cpu ( dst src -- )
HOOK: %alien-unsigned-2 cpu ( dst src -- )
HOOK: %alien-unsigned-4 cpu ( dst src -- )
HOOK: %alien-signed-1   cpu ( dst src -- )
HOOK: %alien-signed-2   cpu ( dst src -- )
HOOK: %alien-signed-4   cpu ( dst src -- )
HOOK: %alien-cell       cpu ( dst src -- )
HOOK: %alien-float      cpu ( dst src -- )
HOOK: %alien-double     cpu ( dst src -- )

HOOK: %set-alien-integer-1 cpu ( ptr value -- )
HOOK: %set-alien-integer-2 cpu ( ptr value -- )
HOOK: %set-alien-integer-4 cpu ( ptr value -- )
HOOK: %set-alien-cell      cpu ( ptr value -- )
HOOK: %set-alien-float     cpu ( ptr value -- )
HOOK: %set-alien-double    cpu ( ptr value -- )

HOOK: %alien-global cpu ( dst symbol library -- )

HOOK: %allot cpu ( dst size class temp -- )
HOOK: %write-barrier cpu ( src card# table -- )

! GC checks
HOOK: %check-nursery cpu ( label temp1 temp2 -- )
HOOK: %save-gc-root cpu ( gc-root register -- )
HOOK: %load-gc-root cpu ( gc-root register -- )
HOOK: %call-gc cpu ( gc-root-count -- )

HOOK: %prologue cpu ( n -- )
HOOK: %epilogue cpu ( n -- )

HOOK: %compare cpu ( dst temp cc src1 src2 -- )
HOOK: %compare-imm cpu ( dst temp cc src1 src2 -- )
HOOK: %compare-float cpu ( dst temp cc src1 src2 -- )

HOOK: %compare-branch cpu ( label cc src1 src2 -- )
HOOK: %compare-imm-branch cpu ( label cc src1 src2 -- )
HOOK: %compare-float-branch cpu ( label cc src1 src2 -- )

HOOK: %spill cpu ( src n rep -- )
HOOK: %reload cpu ( dst n rep -- )

HOOK: %loop-entry cpu ( -- )

! FFI stuff

! Return values of this class go here
GENERIC: return-reg ( reg-class -- reg )

! Sequence of registers used for parameter passing in class
GENERIC: param-regs ( reg-class -- regs )

M: stack-params param-regs drop f ;

GENERIC: param-reg ( n reg-class -- reg )

M: reg-class param-reg param-regs nth ;

M: stack-params param-reg drop ;

! Is this integer small enough to appear in value template
! slots?
HOOK: small-enough? cpu ( n -- ? )

! Is this structure small enough to be returned in registers?
HOOK: return-struct-in-registers? cpu ( c-type -- ? )

! Do we pass this struct by value or hidden reference?
HOOK: value-struct? cpu ( c-type -- ? )

! If t, all parameters are shadowed by dummy stack parameters
HOOK: dummy-stack-params? cpu ( -- ? )

! If t, all FP parameters are shadowed by dummy int parameters
HOOK: dummy-int-params? cpu ( -- ? )

! If t, all int parameters are shadowed by dummy FP parameters
HOOK: dummy-fp-params? cpu ( -- ? )

HOOK: %prepare-unbox cpu ( -- )

HOOK: %unbox cpu ( n rep func -- )

HOOK: %unbox-long-long cpu ( n func -- )

HOOK: %unbox-small-struct cpu ( c-type -- )

HOOK: %unbox-large-struct cpu ( n c-type -- )

HOOK: %box cpu ( n rep func -- )

HOOK: %box-long-long cpu ( n func -- )

HOOK: %prepare-box-struct cpu ( -- )

HOOK: %box-small-struct cpu ( c-type -- )

HOOK: %box-large-struct cpu ( n c-type -- )

HOOK: %save-param-reg cpu ( stack reg rep -- )

HOOK: %load-param-reg cpu ( stack reg rep -- )

HOOK: %prepare-alien-invoke cpu ( -- )

HOOK: %prepare-var-args cpu ( -- )

M: object %prepare-var-args ;

HOOK: %alien-invoke cpu ( function library -- )

HOOK: %cleanup cpu ( params -- )

M: object %cleanup ( params -- ) drop ;

HOOK: %prepare-alien-indirect cpu ( -- )

HOOK: %alien-indirect cpu ( -- )

HOOK: %alien-callback cpu ( quot -- )

HOOK: %callback-value cpu ( ctype -- )

! Return to caller with stdcall unwinding (only for x86)
HOOK: %callback-return cpu ( params -- )

M: object %callback-return drop %return ;
