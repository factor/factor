! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays generic kernel kernel.private math
memory namespaces make sequences layouts system hashtables
classes alien byte-arrays combinators words sets fry ;
IN: cpu.architecture

! Labels
TUPLE: label offset ;

: <label> ( -- label ) label new ;
: define-label ( name -- ) <label> swap set ;
: resolve-label ( label/name -- ) dup label? [ get ] unless , ;

! Register classes
SINGLETON: int-regs
SINGLETON: single-float-regs
SINGLETON: double-float-regs
UNION: float-regs single-float-regs double-float-regs ;
UNION: reg-class int-regs float-regs ;

! Mapping from register class to machine registers
HOOK: machine-registers cpu ( -- assoc )

! A pseudo-register class for parameters spilled on the stack
SINGLETON: stack-params

! Return values of this class go here
GENERIC: return-reg ( register-class -- reg )

! Sequence of registers used for parameter passing in class
GENERIC: param-regs ( register-class -- regs )

GENERIC: param-reg ( n register-class -- reg )

M: object param-reg param-regs nth ;

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

HOOK: %dispatch cpu ( src temp offset -- )
HOOK: %dispatch-label cpu ( word -- )

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
HOOK: %shl-imm cpu ( dst src1 src2 -- )
HOOK: %shr-imm cpu ( dst src1 src2 -- )
HOOK: %sar-imm cpu ( dst src1 src2 -- )
HOOK: %not     cpu ( dst src -- )
HOOK: %log2    cpu ( dst src -- )

HOOK: %fixnum-add cpu ( src1 src2 -- )
HOOK: %fixnum-add-tail cpu ( src1 src2 -- )
HOOK: %fixnum-sub cpu ( src1 src2 -- )
HOOK: %fixnum-sub-tail cpu ( src1 src2 -- )
HOOK: %fixnum-mul cpu ( src1 src2 temp1 temp2 -- )
HOOK: %fixnum-mul-tail cpu ( src1 src2 temp1 temp2 -- )

HOOK: %integer>bignum cpu ( dst src temp -- )
HOOK: %bignum>integer cpu ( dst src temp -- )

HOOK: %add-float cpu ( dst src1 src2 -- )
HOOK: %sub-float cpu ( dst src1 src2 -- )
HOOK: %mul-float cpu ( dst src1 src2 -- )
HOOK: %div-float cpu ( dst src1 src2 -- )

HOOK: %integer>float cpu ( dst src -- )
HOOK: %float>integer cpu ( dst src -- )

HOOK: %copy cpu ( dst src -- )
HOOK: %copy-float cpu ( dst src -- )
HOOK: %unbox-float cpu ( dst src -- )
HOOK: %unbox-any-c-ptr cpu ( dst src temp -- )
HOOK: %box-float cpu ( dst src temp -- )
HOOK: %box-alien cpu ( dst src temp -- )

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
HOOK: %gc cpu ( -- )

HOOK: %prologue cpu ( n -- )
HOOK: %epilogue cpu ( n -- )

HOOK: %compare cpu ( dst temp cc src1 src2 -- )
HOOK: %compare-imm cpu ( dst temp cc src1 src2 -- )
HOOK: %compare-float cpu ( dst temp cc src1 src2 -- )

HOOK: %compare-branch cpu ( label cc src1 src2 -- )
HOOK: %compare-imm-branch cpu ( label cc src1 src2 -- )
HOOK: %compare-float-branch cpu ( label cc src1 src2 -- )

HOOK: %spill-integer cpu ( src n -- )
HOOK: %spill-float cpu ( src n -- )
HOOK: %reload-integer cpu ( dst n -- )
HOOK: %reload-float cpu ( dst n -- )

HOOK: %loop-entry cpu ( -- )

! FFI stuff

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

HOOK: %unbox cpu ( n reg-class func -- )

HOOK: %unbox-long-long cpu ( n func -- )

HOOK: %unbox-small-struct cpu ( c-type -- )

HOOK: %unbox-large-struct cpu ( n c-type -- )

HOOK: %box cpu ( n reg-class func -- )

HOOK: %box-long-long cpu ( n func -- )

HOOK: %prepare-box-struct cpu ( -- )

HOOK: %box-small-struct cpu ( c-type -- )

HOOK: %box-large-struct cpu ( n c-type -- )

GENERIC: %save-param-reg ( stack reg reg-class -- )

GENERIC: %load-param-reg ( stack reg reg-class -- )

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

M: stack-params param-reg drop ;

M: stack-params param-regs drop f ;
