! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays generic kernel kernel.private math memory
namespaces sequences layouts system hashtables classes alien
byte-arrays bit-arrays float-arrays combinators words ;
IN: cpu.architecture

SYMBOL: compiler-backend

! A pseudo-register class for parameters spilled on the stack
TUPLE: stack-params ;

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

HOOK: load-indirect compiler-backend ( obj reg -- )

HOOK: stack-frame compiler-backend ( frame-size -- n )

: stack-frame* ( -- n )
    \ stack-frame get stack-frame ;

! Set up caller stack frame
HOOK: %prologue compiler-backend ( n -- )

: %prologue-later \ %prologue-later , ;

! Tear down stack frame
HOOK: %epilogue compiler-backend ( n -- )

: %epilogue-later \ %epilogue-later , ;

! Store word XT in stack frame
HOOK: %save-word-xt compiler-backend ( -- )

! Store dispatch branch XT in stack frame
HOOK: %save-dispatch-xt compiler-backend ( -- )

M: object %save-dispatch-xt %save-word-xt ;

! Call another word
HOOK: %call compiler-backend ( word -- )

! Local jump for branches
HOOK: %jump-label compiler-backend ( label -- )

! Test if vreg is 'f' or not
HOOK: %jump-t compiler-backend ( label -- )

HOOK: %dispatch compiler-backend ( -- )

HOOK: %dispatch-label compiler-backend ( word -- )

! Return to caller
HOOK: %return compiler-backend ( -- )

! Change datastack height
HOOK: %inc-d compiler-backend ( n -- )

! Change callstack height
HOOK: %inc-r compiler-backend ( n -- )

! Load stack into vreg
HOOK: %peek compiler-backend ( vreg loc -- )

! Store vreg to stack
HOOK: %replace compiler-backend ( vreg loc -- )

! Box and unbox floats
HOOK: %unbox-float compiler-backend ( dst src -- )
HOOK: %box-float compiler-backend ( dst src -- )

! FFI stuff

! Is this integer small enough to appear in value template
! slots?
HOOK: small-enough? compiler-backend ( n -- ? )

! Is this structure small enough to be returned in registers?
HOOK: struct-small-enough? compiler-backend ( size -- ? )

! Do we pass explode value structs?
HOOK: value-structs? compiler-backend ( -- ? )

! If t, fp parameters are shadowed by dummy int parameters
HOOK: fp-shadows-int? compiler-backend ( -- ? )

HOOK: %prepare-unbox compiler-backend ( -- )

HOOK: %unbox compiler-backend ( n reg-class func -- )

HOOK: %unbox-long-long compiler-backend ( n func -- )

HOOK: %unbox-small-struct compiler-backend ( size -- )

HOOK: %unbox-large-struct compiler-backend ( n size -- )

HOOK: %box compiler-backend ( n reg-class func -- )

HOOK: %box-long-long compiler-backend ( n func -- )

HOOK: %prepare-box-struct compiler-backend ( size -- )

HOOK: %box-small-struct compiler-backend ( size -- )

HOOK: %box-large-struct compiler-backend ( n size -- )

GENERIC: %save-param-reg ( stack reg reg-class -- )

GENERIC: %load-param-reg ( stack reg reg-class -- )

HOOK: %prepare-alien-invoke compiler-backend ( -- )

HOOK: %prepare-var-args compiler-backend ( -- )

M: object %prepare-var-args ;

HOOK: %alien-invoke compiler-backend ( function library -- )

HOOK: %cleanup compiler-backend ( alien-node -- )

HOOK: %alien-callback compiler-backend ( quot -- )

HOOK: %callback-value compiler-backend ( ctype -- )

! Return to caller with stdcall unwinding (only for x86)
HOOK: %unwind compiler-backend ( n -- )

HOOK: %prepare-alien-indirect compiler-backend ( -- )

HOOK: %alien-indirect compiler-backend ( -- )

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
HOOK: %unbox-byte-array compiler-backend ( dst src -- )

HOOK: %unbox-alien compiler-backend ( dst src -- )

HOOK: %unbox-f compiler-backend ( dst src -- )

HOOK: %unbox-any-c-ptr compiler-backend ( dst src -- )

HOOK: %box-alien compiler-backend ( dst src -- )

: operand ( var -- op ) get v>operand ; inline

: unique-operands ( operands quot -- )
    >r [ operand ] map prune r> each ; inline
