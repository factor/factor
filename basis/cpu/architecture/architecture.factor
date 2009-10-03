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
SINGLETONS: float-rep double-rep ;

! On x86, floating point registers are really vector registers
SINGLETONS:
char-16-rep
uchar-16-rep
short-8-rep
ushort-8-rep
int-4-rep
uint-4-rep
longlong-2-rep
ulonglong-2-rep ;

! Scalar values in the high component of a vector register
SINGLETONS:
char-scalar-rep
uchar-scalar-rep
short-scalar-rep
ushort-scalar-rep
int-scalar-rep
uint-scalar-rep
longlong-scalar-rep
ulonglong-scalar-rep ;

SINGLETONS:
float-4-rep
double-2-rep ;

UNION: int-vector-rep
char-16-rep
uchar-16-rep
short-8-rep
ushort-8-rep
int-4-rep
uint-4-rep
longlong-2-rep
ulonglong-2-rep ;

UNION: scalar-rep
char-scalar-rep
uchar-scalar-rep
short-scalar-rep
ushort-scalar-rep
int-scalar-rep
uint-scalar-rep
longlong-scalar-rep
ulonglong-scalar-rep ;

UNION: float-vector-rep
float-4-rep
double-2-rep ;

UNION: vector-rep
int-vector-rep
float-vector-rep ;

UNION: representation
any-rep
tagged-rep
int-rep
float-rep
double-rep
vector-rep
scalar-rep ;

! Register classes
SINGLETONS: int-regs float-regs ;

UNION: reg-class int-regs float-regs ;
CONSTANT: reg-classes { int-regs float-regs }

! A pseudo-register class for parameters spilled on the stack
SINGLETON: stack-params

! On x86, vectors and floats are stored in the same register bank
! On PowerPC they are distinct
HOOK: vector-regs cpu ( -- reg-class )

GENERIC: reg-class-of ( rep -- reg-class )

M: tagged-rep reg-class-of drop int-regs ;
M: int-rep reg-class-of drop int-regs ;
M: float-rep reg-class-of drop float-regs ;
M: double-rep reg-class-of drop float-regs ;
M: vector-rep reg-class-of drop vector-regs ;
M: scalar-rep reg-class-of drop vector-regs ;
M: stack-params reg-class-of drop stack-params ;

GENERIC: rep-size ( rep -- n ) foldable

M: tagged-rep rep-size drop cell ;
M: int-rep rep-size drop cell ;
M: float-rep rep-size drop 4 ;
M: double-rep rep-size drop 8 ;
M: stack-params rep-size drop cell ;
M: vector-rep rep-size drop 16 ;
M: char-scalar-rep rep-size drop 1 ;
M: uchar-scalar-rep rep-size drop 1 ;
M: short-scalar-rep rep-size drop 2 ;
M: ushort-scalar-rep rep-size drop 2 ;
M: int-scalar-rep rep-size drop 4 ;
M: uint-scalar-rep rep-size drop 4 ;
M: longlong-scalar-rep rep-size drop 8 ;
M: ulonglong-scalar-rep rep-size drop 8 ;

GENERIC: rep-component-type ( rep -- n )

! Methods defined in alien.c-types

GENERIC: scalar-rep-of ( rep -- rep' )

M: float-4-rep scalar-rep-of drop float-rep ;
M: double-2-rep scalar-rep-of drop double-rep ;
M: char-16-rep scalar-rep-of drop char-scalar-rep ;
M: uchar-16-rep scalar-rep-of drop uchar-scalar-rep ;
M: short-8-rep scalar-rep-of drop short-scalar-rep ;
M: ushort-8-rep scalar-rep-of drop ushort-scalar-rep ;
M: int-4-rep scalar-rep-of drop int-scalar-rep ;
M: uint-4-rep scalar-rep-of drop uint-scalar-rep ;
M: longlong-2-rep scalar-rep-of drop longlong-scalar-rep ;
M: ulonglong-2-rep scalar-rep-of drop ulonglong-scalar-rep ;

! Mapping from register class to machine registers
HOOK: machine-registers cpu ( -- assoc )

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

HOOK: %slot cpu ( dst obj slot -- )
HOOK: %slot-imm cpu ( dst obj slot tag -- )
HOOK: %set-slot cpu ( src obj slot -- )
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
HOOK: %min     cpu ( dst src1 src2 -- )
HOOK: %max     cpu ( dst src1 src2 -- )
HOOK: %not     cpu ( dst src -- )
HOOK: %neg     cpu ( dst src -- )
HOOK: %log2    cpu ( dst src -- )

HOOK: %copy cpu ( dst src rep -- )

HOOK: %fixnum-add cpu ( label dst src1 src2 -- )
HOOK: %fixnum-sub cpu ( label dst src1 src2 -- )
HOOK: %fixnum-mul cpu ( label dst src1 src2 -- )

HOOK: %add-float cpu ( dst src1 src2 -- )
HOOK: %sub-float cpu ( dst src1 src2 -- )
HOOK: %mul-float cpu ( dst src1 src2 -- )
HOOK: %div-float cpu ( dst src1 src2 -- )
HOOK: %min-float cpu ( dst src1 src2 -- )
HOOK: %max-float cpu ( dst src1 src2 -- )
HOOK: %sqrt cpu ( dst src -- )
HOOK: %unary-float-function cpu ( dst src func -- )
HOOK: %binary-float-function cpu ( dst src1 src2 func -- )

HOOK: %single>double-float cpu ( dst src -- )
HOOK: %double>single-float cpu ( dst src -- )

HOOK: %integer>float cpu ( dst src -- )
HOOK: %float>integer cpu ( dst src -- )

HOOK: %zero-vector cpu ( dst rep -- )
HOOK: %fill-vector cpu ( dst rep -- )
HOOK: %gather-vector-2 cpu ( dst src1 src2 rep -- )
HOOK: %gather-vector-4 cpu ( dst src1 src2 src3 src4 rep -- )
HOOK: %shuffle-vector cpu ( dst src shuffle rep -- )
HOOK: %compare-vector cpu ( dst src1 src2 temp rep cc -- )
HOOK: %test-vector cpu ( dst src1 temp rep vcc -- )
HOOK: %test-vector-branch cpu ( label src1 temp rep vcc -- )
HOOK: %add-vector cpu ( dst src1 src2 rep -- )
HOOK: %saturated-add-vector cpu ( dst src1 src2 rep -- )
HOOK: %add-sub-vector cpu ( dst src1 src2 rep -- )
HOOK: %sub-vector cpu ( dst src1 src2 rep -- )
HOOK: %saturated-sub-vector cpu ( dst src1 src2 rep -- )
HOOK: %mul-vector cpu ( dst src1 src2 rep -- )
HOOK: %saturated-mul-vector cpu ( dst src1 src2 rep -- )
HOOK: %div-vector cpu ( dst src1 src2 rep -- )
HOOK: %min-vector cpu ( dst src1 src2 rep -- )
HOOK: %max-vector cpu ( dst src1 src2 rep -- )
HOOK: %dot-vector cpu ( dst src1 src2 rep -- )
HOOK: %sqrt-vector cpu ( dst src rep -- )
HOOK: %horizontal-add-vector cpu ( dst src rep -- )
HOOK: %horizontal-sub-vector cpu ( dst src rep -- )
HOOK: %abs-vector cpu ( dst src rep -- )
HOOK: %and-vector cpu ( dst src1 src2 rep -- )
HOOK: %andn-vector cpu ( dst src1 src2 rep -- )
HOOK: %or-vector cpu ( dst src1 src2 rep -- )
HOOK: %xor-vector cpu ( dst src1 src2 rep -- )
HOOK: %not-vector cpu ( dst src rep -- )
HOOK: %shl-vector cpu ( dst src1 src2 rep -- )
HOOK: %shr-vector cpu ( dst src1 src2 rep -- )
HOOK: %horizontal-shl-vector cpu ( dst src1 src2 rep -- )
HOOK: %horizontal-shr-vector cpu ( dst src1 src2 rep -- )

HOOK: %integer>scalar cpu ( dst src rep -- )
HOOK: %scalar>integer cpu ( dst src rep -- )
HOOK: %vector>scalar cpu ( dst src rep -- )
HOOK: %scalar>vector cpu ( dst src rep -- )

HOOK: %zero-vector-reps cpu ( -- reps )
HOOK: %fill-vector-reps cpu ( -- reps )
HOOK: %gather-vector-2-reps cpu ( -- reps )
HOOK: %gather-vector-4-reps cpu ( -- reps )
HOOK: %shuffle-vector-reps cpu ( -- reps )
HOOK: %compare-vector-reps cpu ( cc -- reps )
HOOK: %test-vector-reps cpu ( -- reps )
HOOK: %add-vector-reps cpu ( -- reps )
HOOK: %saturated-add-vector-reps cpu ( -- reps )
HOOK: %add-sub-vector-reps cpu ( -- reps )
HOOK: %sub-vector-reps cpu ( -- reps )
HOOK: %saturated-sub-vector-reps cpu ( -- reps )
HOOK: %mul-vector-reps cpu ( -- reps )
HOOK: %saturated-mul-vector-reps cpu ( -- reps )
HOOK: %div-vector-reps cpu ( -- reps )
HOOK: %min-vector-reps cpu ( -- reps )
HOOK: %max-vector-reps cpu ( -- reps )
HOOK: %dot-vector-reps cpu ( -- reps )
HOOK: %sqrt-vector-reps cpu ( -- reps )
HOOK: %horizontal-add-vector-reps cpu ( -- reps )
HOOK: %horizontal-sub-vector-reps cpu ( -- reps )
HOOK: %abs-vector-reps cpu ( -- reps )
HOOK: %and-vector-reps cpu ( -- reps )
HOOK: %andn-vector-reps cpu ( -- reps )
HOOK: %or-vector-reps cpu ( -- reps )
HOOK: %xor-vector-reps cpu ( -- reps )
HOOK: %not-vector-reps cpu ( -- reps )
HOOK: %shl-vector-reps cpu ( -- reps )
HOOK: %shr-vector-reps cpu ( -- reps )
HOOK: %horizontal-shl-vector-reps cpu ( -- reps )
HOOK: %horizontal-shr-vector-reps cpu ( -- reps )

HOOK: %unbox-alien cpu ( dst src -- )
HOOK: %unbox-any-c-ptr cpu ( dst src temp -- )
HOOK: %box-alien cpu ( dst src temp -- )
HOOK: %box-displaced-alien cpu ( dst displacement base temp1 temp2 base-class -- )

HOOK: %alien-unsigned-1 cpu ( dst src offset -- )
HOOK: %alien-unsigned-2 cpu ( dst src offset -- )
HOOK: %alien-unsigned-4 cpu ( dst src offset -- )
HOOK: %alien-signed-1   cpu ( dst src offset -- )
HOOK: %alien-signed-2   cpu ( dst src offset -- )
HOOK: %alien-signed-4   cpu ( dst src offset -- )
HOOK: %alien-cell       cpu ( dst src offset -- )
HOOK: %alien-float      cpu ( dst src offset -- )
HOOK: %alien-double     cpu ( dst src offset -- )
HOOK: %alien-vector     cpu ( dst src offset rep -- )

HOOK: %set-alien-integer-1 cpu ( ptr offset value -- )
HOOK: %set-alien-integer-2 cpu ( ptr offset value -- )
HOOK: %set-alien-integer-4 cpu ( ptr offset value -- )
HOOK: %set-alien-cell      cpu ( ptr offset value -- )
HOOK: %set-alien-float     cpu ( ptr offset value -- )
HOOK: %set-alien-double    cpu ( ptr offset value -- )
HOOK: %set-alien-vector    cpu ( ptr offset value rep -- )

HOOK: %alien-global cpu ( dst symbol library -- )
HOOK: %vm-field-ptr cpu ( dst fieldname -- )

HOOK: %allot cpu ( dst size class temp -- )
HOOK: %write-barrier cpu ( src card# table -- )

! GC checks
HOOK: %check-nursery cpu ( label temp1 temp2 -- )
HOOK: %save-gc-root cpu ( gc-root register -- )
HOOK: %load-gc-root cpu ( gc-root register -- )
HOOK: %call-gc cpu ( gc-root-count temp1 -- )

HOOK: %prologue cpu ( n -- )
HOOK: %epilogue cpu ( n -- )

HOOK: %compare cpu ( dst temp cc src1 src2 -- )
HOOK: %compare-imm cpu ( dst temp cc src1 src2 -- )
HOOK: %compare-float-ordered cpu ( dst temp cc src1 src2 -- )
HOOK: %compare-float-unordered cpu ( dst temp cc src1 src2 -- )

HOOK: %compare-branch cpu ( label cc src1 src2 -- )
HOOK: %compare-imm-branch cpu ( label cc src1 src2 -- )
HOOK: %compare-float-ordered-branch cpu ( label cc src1 src2 -- )
HOOK: %compare-float-unordered-branch cpu ( label cc src1 src2 -- )

HOOK: %spill cpu ( src rep dst -- )
HOOK: %reload cpu ( dst rep src -- )

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

HOOK: %save-context cpu ( temp1 temp2 callback-allowed? -- )

HOOK: %prepare-var-args cpu ( -- )

M: object %prepare-var-args ;

HOOK: %alien-invoke cpu ( function library -- )

HOOK: %cleanup cpu ( params -- )

M: object %cleanup ( params -- ) drop ;

HOOK: %prepare-alien-indirect cpu ( -- )

HOOK: %alien-indirect cpu ( -- )

HOOK: %alien-callback cpu ( quot -- )

HOOK: %callback-value cpu ( ctype -- )

HOOK: %nest-stacks cpu ( -- )

HOOK: %unnest-stacks cpu ( -- )

! Return to caller with stdcall unwinding (only for x86)
HOOK: %callback-return cpu ( params -- )

M: object %callback-return drop %return ;
