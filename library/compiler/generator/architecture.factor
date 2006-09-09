IN: compiler
USING: arrays generic kernel kernel-internals math memory
namespaces sequences ;

! Does the assembler emit bytes or cells?
DEFER: code-format ( -- byte# )

! A scratch register for computations
TUPLE: vreg n ;

C: vreg ( n reg-class -- vreg )
    [ set-delegate ] keep [ set-vreg-n ] keep ;

! Register classes
TUPLE: int-regs ;
TUPLE: float-regs size ;

: <int-vreg> ( n -- vreg ) T{ int-regs } <vreg> ;
: <float-vreg> ( n -- vreg ) T{ float-regs f 8 } <vreg> ;

! A pseudo-register class for parameters spilled on the stack
TUPLE: stack-params ;

! Return values of this class go here
GENERIC: return-reg ( register-class -- reg )

! Sequence of registers used for parameter passing in class
GENERIC: fastcall-regs ( register-class -- regs )

! Sequence mapping vreg-n to native assembler registers
GENERIC: vregs ( register-class -- regs )

! Map a sequence of literals to f or float
DEFER: literal-template ( literals -- template )

! Load a literal (immediate or indirect)
G: load-literal ( obj vreg -- ) 1 standard-combination ;

! Set up caller stack frame (PowerPC and AMD64)
: %prologue ( n -- ) drop ; inline

! Tear down stack frame (PowerPC and AMD64)
: %epilogue ( -- ) ; inline

! Tail call another word
DEFER: %jump ( label -- )

! Call another word
DEFER: %call ( label -- )

! Local jump for branches or tail calls in nested #label
DEFER: %jump-label ( label -- )

! Test if vreg is 'f' or not
DEFER: %jump-t ( label vreg -- )

! Jump table of addresses (one cell each) is right after this
DEFER: %dispatch ( vreg -- )

! Jump table entry
DEFER: %target ( label -- )

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

: %move ( dst src -- )
    2dup = [
        2drop
    ] [
        2dup [ delegate class ] 2apply 2array {
            { [ dup { int-regs int-regs } = ] [ drop %move-int>int ] }
            { [ dup { float-regs int-regs } = ] [ drop %move-int>float ] }
        } cond
    ] if ;

! FFI stuff
DEFER: %unbox ( n reg-class func -- )

DEFER: %unbox-struct ( n size -- )

DEFER: %box ( n reg-class func -- )

DEFER: %box-struct ( n size -- )

GENERIC: %freg>stack ( stack reg reg-class -- )

GENERIC: %stack>freg ( stack reg reg-class -- )

DEFER: %alien-invoke ( library function -- )

DEFER: %cleanup ( n -- )

DEFER: %alien-callback ( quot -- )

DEFER: %callback-value ( reg-class func -- )

DEFER: %alien-indirect ( -- )

M: stack-params fastcall-regs drop 0 ;

GENERIC: reg-size ( register-class -- n )

GENERIC: inc-reg-class ( register-class -- )

M: int-regs reg-size drop cell ;

: (inc-reg-class)
    dup class inc
    macosx? [ reg-size stack-params +@ ] [ drop ] if ;

M: int-regs inc-reg-class
    (inc-reg-class) ;

M: float-regs reg-size float-regs-size ;

M: float-regs inc-reg-class
    dup (inc-reg-class)
    macosx? [ reg-size 4 / int-regs +@ ] [ drop ] if ;

GENERIC: v>operand ( obj -- operand )
M: integer v>operand tag-bits shift ;
M: vreg v>operand dup vreg-n swap vregs nth ;
M: f v>operand drop object-tag ;
