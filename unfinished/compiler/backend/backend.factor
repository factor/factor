! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs arrays generic kernel kernel.private
math memory namespaces make sequences layouts system hashtables
classes alien byte-arrays combinators words ;
IN: compiler.backend

! Labels
TUPLE: label offset ;

: <label> ( -- label ) label new ;
: define-label ( name -- ) <label> swap set ;
: resolve-label ( label/name -- ) dup label? [ get ] unless , ;

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

! Load a literal (immediate or indirect)
GENERIC# load-literal 1 ( obj reg -- )

HOOK: load-indirect cpu ( obj reg -- )

HOOK: stack-frame-size cpu ( frame-size -- n )

! Set up caller stack frame
HOOK: %prologue cpu ( n -- )

! Tear down stack frame
HOOK: %epilogue cpu ( n -- )

! Call another word
HOOK: %call cpu ( word -- )

! Local jump for branches
HOOK: %jump-label cpu ( label -- )

! Test if vreg is 'f' or not
HOOK: %jump-f cpu ( label reg -- )

! Test if vreg is 't' or not
HOOK: %jump-t cpu ( label reg -- )

HOOK: %dispatch cpu ( -- )

HOOK: %dispatch-label cpu ( word -- )

! Return to caller
HOOK: %return cpu ( -- )

! Change datastack height
HOOK: %inc-d cpu ( n -- )

! Change callstack height
HOOK: %inc-r cpu ( n -- )

! Load stack into vreg
HOOK: %peek cpu ( reg loc -- )

! Store vreg to stack
HOOK: %replace cpu ( reg loc -- )

! Copy values between vregs
HOOK: %copy cpu ( dst src -- )
HOOK: %copy-float cpu ( dst src -- )

! Box and unbox floats
HOOK: %unbox-float cpu ( dst src -- )
HOOK: %box-float cpu ( dst src -- )

! FFI stuff

! Is this integer small enough to appear in value template
! slots?
HOOK: small-enough? cpu ( n -- ? )

! Is this structure small enough to be returned in registers?
HOOK: struct-small-enough? cpu ( heap-size -- ? )

! Do we pass explode value structs?
HOOK: value-structs? cpu ( -- ? )

! If t, fp parameters are shadowed by dummy int parameters
HOOK: fp-shadows-int? cpu ( -- ? )

HOOK: %prepare-unbox cpu ( -- )

HOOK: %unbox cpu ( n reg-class func -- )

HOOK: %unbox-long-long cpu ( n func -- )

HOOK: %unbox-small-struct cpu ( c-type -- )

HOOK: %unbox-large-struct cpu ( n c-type -- )

HOOK: %box cpu ( n reg-class func -- )

HOOK: %box-long-long cpu ( n func -- )

HOOK: %prepare-box-struct cpu ( size -- )

HOOK: %box-small-struct cpu ( c-type -- )

HOOK: %box-large-struct cpu ( n c-type -- )

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

M: stack-params param-regs drop f ;

M: object load-literal load-indirect ;

PREDICATE: small-slot < integer cells small-enough? ;

PREDICATE: small-tagged < integer tag-fixnum small-enough? ;

: if-small-struct ( n size true false -- ? )
    [ over not over struct-small-enough? and ] 2dip
    [ [ nip ] prepose ] dip if ;
    inline

: %unbox-struct ( n c-type -- )
    [
        %unbox-small-struct
    ] [
        %unbox-large-struct
    ] if-small-struct ;

: %box-struct ( n c-type -- )
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

! Allocation
HOOK: %allot cpu ( dst size type tag temp -- )

HOOK: %write-barrier cpu ( src temp -- )

! GC check
HOOK: %gc cpu ( -- )
