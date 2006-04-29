IN: compiler
USING: generic kernel kernel-internals math memory namespaces
sequences ;

! A scratch register for computations
TUPLE: vreg n ;

! Register classes
TUPLE: int-regs ;
TUPLE: float-regs size ;

! A pseudo-register class for parameters spilled on the stack
TUPLE: stack-params ;

! Return values of this class go here
GENERIC: return-reg ( register-class -- reg )

! Sequence of registers used for parameter passing in class
GENERIC: fastcall-regs ( register-class -- regs )

! Sequence mapping vreg-n to native assembler registers
DEFER: vregs ( -- regs )

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

! Return to caller
DEFER: %return ( -- )

! Change datastack height
DEFER: %inc-d ( n -- )

! Change callstack height
DEFER: %inc-r ( n -- )

! Load stack into vreg
DEFER: %peek ( vreg loc -- )

! Store vreg to stack
DEFER: %replace ( vreg loc -- )

! FFI stuff
DEFER: %unbox ( n reg-class func -- )

DEFER: %unbox-struct ( n reg-class size -- )

DEFER: %box ( n reg-class func -- )

DEFER: %box-struct ( n reg-class size -- )

DEFER: %alien-invoke ( library function -- )

DEFER: %alien-callback ( quot -- )

DEFER: %callback-value ( reg-class func -- )

! A few FFI operations have default implementations
: %cleanup ( n -- ) drop ;

: %stack>freg ( n reg reg-class -- ) 3drop ;

: %freg>stack ( n reg reg-class -- ) 3drop ;

! Some stuff probably not worth redefining in other backends
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

GENERIC: v>operand

M: integer v>operand tag-bits shift ;

M: vreg v>operand vreg-n vregs nth ;

M: f v>operand address ;
