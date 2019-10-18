! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: generator
USING: arrays generic kernel kernel-internals math memory
namespaces sequences ;

! Does the assembler emit bytes or cells?
DEFER: code-format ( -- byte# )

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
G: load-literal ( obj vreg -- ) 1 standard-combination ;

DEFER: load-indirect ( obj reg -- )

DEFER: stack-frame ( frame-size -- n )

: stack-frame* ( -- n )
    \ stack-frame get stack-frame ;

! Set up caller stack frame
DEFER: %prologue ( n -- )

: %prologue-later \ %prologue-later , ;

! Tear down stack frame
DEFER: %epilogue ( -- )

: %epilogue-later \ %epilogue-later , ;

! Call another word
DEFER: %call ( label -- )

! Local jump for branches
DEFER: %jump-label ( label -- )

! Tail call another word
: %jump ( label -- ) %epilogue-later %jump-label ;

! Test if vreg is 'f' or not
DEFER: %jump-t ( label -- )

! We pass the offset of the jump table start in the world table
DEFER: %call-dispatch ( word-table# -- )

DEFER: %jump-dispatch ( word-table# -- )

! Return to caller
DEFER: %return ( -- )

! Change datastack height
DEFER: %inc-d ( n -- )

! Change callstack height
DEFER: %inc-r ( n -- )

! Load stack into vreg
GENERIC: (%peek) ( vreg loc reg-class -- )
: %peek ( vreg loc -- ) over (%peek) ;

! Store vreg to stack
GENERIC: (%replace) ( vreg loc reg-class -- )
: %replace ( vreg loc -- ) over (%replace) ;

! Move one vreg to another
DEFER: %move-int>int ( dst src -- )
DEFER: %move-int>float ( dst src -- )
DEFER: %move-float>int ( dst src -- )

! FFI stuff

! Is this integer small enough to appear in value template
! slots?
DEFER: small-enough? ( n -- ? )

! Is this structure small enough to be returned in registers?
DEFER: struct-small-enough? ( size -- ? )

! Do we pass explode value structs?
DEFER: value-structs? ( -- ? )

! If t, fp parameters are shadowed by dummy int parameters
: fp-shadows-int? ( -- ? ) f ;

DEFER: %prepare-unbox ( -- )

DEFER: %unbox ( n reg-class func -- )

DEFER: %unbox-long-long ( n func -- )

DEFER: %unbox-small-struct ( size -- )

DEFER: %unbox-large-struct ( n size -- )

DEFER: %box ( n reg-class func -- )

DEFER: %box-long-long ( n func -- )

DEFER: %prepare-box-struct ( size -- )

DEFER: %box-small-struct ( size -- )

DEFER: %box-large-struct ( n size -- )

GENERIC: %save-param-reg ( stack reg reg-class -- )

GENERIC: %load-param-reg ( stack reg reg-class -- )

DEFER: %alien-invoke ( library function -- )

DEFER: %cleanup ( alien-node -- )

DEFER: %alien-callback ( quot -- )

DEFER: %callback-value ( ctype -- )

! Return to caller with stdcall unwinding (only for x86)
: %unwind ( n -- ) drop %return ;

DEFER: %prepare-alien-indirect ( -- )

DEFER: %alien-indirect ( -- )

M: stack-params param-reg drop ;

GENERIC: v>operand ( obj -- operand )

M: integer v>operand tag-bits get shift ;

M: f v>operand drop object tag-number ;

M: object load-literal v>operand load-indirect ;

PREDICATE: integer small-slot cells small-enough? ;

PREDICATE: integer small-tagged v>operand small-enough? ;

PREDICATE: integer inline-array 32 < ;

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

: operand ( var -- op ) get v>operand ; inline

: unique-operands ( operands quot -- )
    >r [ operand ] map prune r> each ; inline
