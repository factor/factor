! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays generic kernel kernel.private math memory
namespaces sequences layouts system hashtables classes alien
byte-arrays combinators words sets ;
IN: cpu.architecture

! Register classes
SINGLETON: int-regs
SINGLETON: single-float-regs
SINGLETON: double-float-regs
UNION: float-regs single-float-regs double-float-regs ;
UNION: reg-class int-regs float-regs ;

! A pseudo-register class for parameters spilled on the stack
SINGLETON: stack-params

! Return values of this class go here
GENERIC: return-reg ( register-class -- reg )

! Sequence of registers used for parameter passing in class
GENERIC: param-regs ( register-class -- regs )

GENERIC: param-reg ( n register-class -- reg )

M: object param-reg param-regs nth ;

! Sequence mapping vreg-n to native assembler registers
GENERIC: vregs ( register-class -- regs )

! Load a literal (immediate or indirect)
GENERIC# load-literal 1 ( obj vreg -- )

HOOK: load-indirect cpu ( obj reg -- )

HOOK: stack-frame cpu ( frame-size -- n )

: stack-frame* ( -- n )
    \ stack-frame get stack-frame ;

! Set up caller stack frame
HOOK: %prologue cpu ( n -- )

: %prologue-later ( -- ) \ %prologue-later , ;

! Tear down stack frame
HOOK: %epilogue cpu ( n -- )

: %epilogue-later ( -- ) \ %epilogue-later , ;

! Store word XT in stack frame
HOOK: %save-word-xt cpu ( -- )

! Store dispatch branch XT in stack frame
HOOK: %save-dispatch-xt cpu ( -- )

M: object %save-dispatch-xt %save-word-xt ;

! Call another word
HOOK: %call cpu ( word -- )

! Local jump for branches
HOOK: %jump-label cpu ( label -- )

! Test if vreg is 'f' or not
HOOK: %jump-f cpu ( label -- )

HOOK: %dispatch cpu ( -- )

HOOK: %dispatch-label cpu ( word -- )

! Return to caller
HOOK: %return cpu ( -- )

! Change datastack height
HOOK: %inc-d cpu ( n -- )

! Change callstack height
HOOK: %inc-r cpu ( n -- )

! Load stack into vreg
HOOK: %peek cpu ( vreg loc -- )

! Store vreg to stack
HOOK: %replace cpu ( vreg loc -- )

! Box and unbox floats
HOOK: %unbox-float cpu ( dst src -- )
HOOK: %box-float cpu ( dst src -- )

! FFI stuff

! Is this integer small enough to appear in value template
! slots?
HOOK: small-enough? cpu ( n -- ? )

! Is this structure small enough to be returned in registers?
HOOK: struct-small-enough? cpu ( size -- ? )

! Do we pass explode value structs?
HOOK: value-structs? cpu ( -- ? )

! If t, fp parameters are shadowed by dummy int parameters
HOOK: fp-shadows-int? cpu ( -- ? )

HOOK: %prepare-unbox cpu ( -- )

HOOK: %unbox cpu ( n reg-class func -- )

HOOK: %unbox-long-long cpu ( n func -- )

HOOK: %unbox-small-struct cpu ( size -- )

HOOK: %unbox-large-struct cpu ( n size -- )

HOOK: %box cpu ( n reg-class func -- )

HOOK: %box-long-long cpu ( n func -- )

HOOK: %prepare-box-struct cpu ( size -- )

HOOK: %box-small-struct cpu ( size -- )

HOOK: %box-large-struct cpu ( n size -- )

GENERIC: %save-param-reg ( stack reg reg-class -- )

GENERIC: %load-param-reg ( stack reg reg-class -- )

HOOK: %prepare-alien-invoke cpu ( -- )

HOOK: %prepare-var-args cpu ( -- )

M: object %prepare-var-args ;

HOOK: %alien-invoke cpu ( function library -- )

HOOK: %cleanup cpu ( alien-node -- )

HOOK: %alien-callback cpu ( quot -- )

HOOK: %callback-value cpu ( ctype -- )

! Return to caller with stdcall unwinding (only for x86)
HOOK: %unwind cpu ( n -- )

HOOK: %prepare-alien-indirect cpu ( -- )

HOOK: %alien-indirect cpu ( -- )

M: stack-params param-reg drop ;

GENERIC: v>operand ( obj -- operand )

M: integer v>operand tag-fixnum ;

M: f v>operand drop \ f tag-number ;

M: object load-literal v>operand load-indirect ;

PREDICATE: small-slot < integer cells small-enough? ;

PREDICATE: small-tagged < integer v>operand small-enough? ;

PREDICATE: inline-array < integer 32 < ;

: if-small-struct ( n size true false -- ? )
    >r >r over not over struct-small-enough? and
    [ nip r> call r> drop ] [ r> drop r> call ] if ;
    inline

: %unbox-struct ( n size -- )
    [
        %unbox-small-struct
    ] [
        %unbox-large-struct
    ] if-small-struct ;

: %box-struct ( n size -- )
    [
        %box-small-struct
    ] [
        %box-large-struct
    ] if-small-struct ;

! Alien accessors
HOOK: %unbox-byte-array cpu ( dst src -- )

HOOK: %unbox-alien cpu ( dst src -- )

HOOK: %unbox-f cpu ( dst src -- )

HOOK: %unbox-any-c-ptr cpu ( dst src -- )

HOOK: %box-alien cpu ( dst src -- )

! GC check
HOOK: %gc cpu ( -- )

: operand ( var -- op ) get v>operand ; inline

: unique-operands ( operands quot -- )
    >r [ operand ] map prune r> each ; inline
