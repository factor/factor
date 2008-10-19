! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces make math math.parser sequences accessors
kernel kernel.private layouts assocs words summary arrays
combinators classes.algebra alien alien.c-types alien.structs
alien.strings alien.arrays sets threads libc continuations.private
cpu.architecture
compiler.errors
compiler.alien
compiler.codegen.fixup
compiler.cfg
compiler.cfg.instructions
compiler.cfg.registers
compiler.cfg.builder ;
IN: compiler.codegen

GENERIC: generate-insn ( insn -- )

GENERIC: v>operand ( obj -- operand )

SYMBOL: registers

M: constant v>operand
    value>> [ tag-fixnum ] [ \ f tag-number ] if* ;

M: value v>operand
    registers get at [ "Bad value" throw ] unless* ;

: generate-insns ( insns -- code )
    [
        [
            dup regs>> registers set
            generate-insn
        ] each
    ] { } make fixup ;

TUPLE: asm label code calls ;

SYMBOL: calls

: add-call ( word -- )
    #! Compile this word later.
    calls get push ;

SYMBOL: compiling-word

: compiled-stack-traces? ( -- ? ) 59 getenv ;

! Mapping _label IDs to label instances
SYMBOL: labels

: init-generator ( word -- )
    H{ } clone labels set
    V{ } clone literal-table set
    V{ } clone calls set
    compiling-word set
    compiled-stack-traces? compiling-word get f ? add-literal drop ;

: generate ( mr -- asm )
    [
        [ label>> ]
        [ word>> init-generator ]
        [ instructions>> generate-insns ] tri
        calls get
        asm boa
    ] with-scope ;

: lookup-label ( id -- label )
    labels get [ drop <label> ] cache ;

M: _label generate-insn
    id>> lookup-label , ;

M: _prologue generate-insn
    stack-frame>> [ stack-frame set ] [ total-size>> %prologue ] bi ;

M: _epilogue generate-insn
    stack-frame>> total-size>> %epilogue ;

M: ##load-literal generate-insn
    [ obj>> ] [ dst>> v>operand ] bi load-literal ;

M: ##peek generate-insn
    [ dst>> v>operand ] [ loc>> ] bi %peek ;

M: ##replace generate-insn
    [ src>> v>operand ] [ loc>> ] bi %replace ;

M: ##inc-d generate-insn n>> %inc-d ;

M: ##inc-r generate-insn n>> %inc-r ;

M: ##return generate-insn drop %return ;

M: ##call generate-insn word>> [ add-call ] [ %call ] bi ;

M: ##jump generate-insn word>> [ add-call ] [ %jump-label ] bi ;

SYMBOL: operands

: init-intrinsic ( insn -- )
    [ defs-vregs>> ] [ uses-vregs>> ] bi append operands set ;

M: ##intrinsic generate-insn
    [ init-intrinsic ] [ quot>> call ] bi ;

: (operand) ( name -- operand )
    operands get at* [ "Bad operand name" throw ] unless ;

: literal ( name -- value )
    (operand) value>> ;

: operand ( name -- operand )
    (operand) v>operand ;

: operand-class ( var -- class )
    (operand) value-class ;

: operand-tag ( operand -- tag/f )
    operand-class dup [ class-tag ] when ;

: operand-immediate? ( operand -- ? )
    operand-class immediate class<= ;

: unique-operands ( operands quot -- )
    >r [ operand ] map prune r> each ; inline

M: _if-intrinsic generate-insn
    [ init-intrinsic ]
    [ [ label>> lookup-label ] [ quot>> ] bi call ] bi ;

M: _branch generate-insn
    label>> lookup-label %jump-label ;

M: _branch-f generate-insn
    [ label>> lookup-label ] [ src>> v>operand ] bi %jump-f ;

M: _branch-t generate-insn
    [ label>> lookup-label ] [ src>> v>operand ] bi %jump-t ;

M: ##dispatch-label generate-insn label>> %dispatch-label ;

M: ##dispatch generate-insn
    [ src>> v>operand ] [ temp>> v>operand ] bi %dispatch ;

: dst/src ( insn -- dst src )
    [ dst>> v>operand ] [ src>> v>operand ] bi ;

M: ##copy generate-insn dst/src %copy ;

M: ##copy-float generate-insn dst/src %copy-float ;

M: ##unbox-float generate-insn dst/src %unbox-float ;

M: ##unbox-f generate-insn dst/src %unbox-f ;

M: ##unbox-alien generate-insn dst/src %unbox-alien ;

M: ##unbox-byte-array generate-insn dst/src %unbox-byte-array ;

M: ##unbox-any-c-ptr generate-insn dst/src %unbox-any-c-ptr ;

: dst/src/temp ( insn -- dst src temp )
    [ dst/src ] [ temp>> v>operand ] bi ;

M: ##box-float generate-insn dst/src/temp %box-float ;

M: ##box-alien generate-insn dst/src/temp %box-alien ;

M: ##allot generate-insn
    {
        [ dst>> v>operand ]
        [ size>> ]
        [ type>> ]
        [ tag>> ]
        [ temp>> v>operand ]
    } cleave
    %allot ;

M: ##write-barrier generate-insn
    [ src>> v>operand ]
    [ card#>> v>operand ]
    [ table>> v>operand ]
    tri %write-barrier ;

M: ##gc generate-insn drop %gc ;

! #alien-invoke
GENERIC: reg-size ( register-class -- n )

M: int-regs reg-size drop cell ;

M: single-float-regs reg-size drop 4 ;

M: double-float-regs reg-size drop 8 ;

M: stack-params reg-size drop "void*" heap-size ;

GENERIC: reg-class-variable ( register-class -- symbol )

M: reg-class reg-class-variable ;

M: float-regs reg-class-variable drop float-regs ;

GENERIC: inc-reg-class ( register-class -- )

M: reg-class inc-reg-class
    dup reg-class-variable inc
    fp-shadows-int? [ reg-size stack-params +@ ] [ drop ] if ;

M: float-regs inc-reg-class
    dup call-next-method
    fp-shadows-int? [ reg-size cell /i int-regs +@ ] [ drop ] if ;

GENERIC: reg-class-full? ( class -- ? )

M: stack-params reg-class-full? drop t ;

M: object reg-class-full?
    [ reg-class-variable get ] [ param-regs length ] bi >= ;

: spill-param ( reg-class -- n reg-class )
    stack-params get
    >r reg-size stack-params +@ r>
    stack-params ;

: fastcall-param ( reg-class -- n reg-class )
    [ reg-class-variable get ] [ inc-reg-class ] [ ] tri ;

: alloc-parameter ( parameter -- reg reg-class )
    c-type-reg-class dup reg-class-full?
    [ spill-param ] [ fastcall-param ] if
    [ param-reg ] keep ;

: (flatten-int-type) ( size -- seq )
    cell /i "void*" c-type <repetition> ;

GENERIC: flatten-value-type ( type -- types )

M: object flatten-value-type 1array ;

M: struct-type flatten-value-type ( type -- types )
    stack-size cell align (flatten-int-type) ;

M: long-long-type flatten-value-type ( type -- types )
    stack-size cell align (flatten-int-type) ;

: flatten-value-types ( params -- params )
    #! Convert value type structs to consecutive void*s.
    [
        0 [
            c-type
            [ parameter-align (flatten-int-type) % ] keep
            [ stack-size cell align + ] keep
            flatten-value-type %
        ] reduce drop
    ] { } make ;

: each-parameter ( parameters quot -- )
    >r [ parameter-sizes nip ] keep r> 2each ; inline

: reverse-each-parameter ( parameters quot -- )
    >r [ parameter-sizes nip ] keep r> 2reverse-each ; inline

: reset-freg-counts ( -- )
    { int-regs float-regs stack-params } [ 0 swap set ] each ;

: with-param-regs ( quot -- )
    #! In quot you can call alloc-parameter
    [ reset-freg-counts call ] with-scope ; inline

: move-parameters ( node word -- )
    #! Moves values from C stack to registers (if word is
    #! %load-param-reg) and registers to C stack (if word is
    #! %save-param-reg).
    >r
    alien-parameters
    flatten-value-types
    r> [ >r alloc-parameter r> execute ] curry each-parameter ;
    inline

: unbox-parameters ( offset node -- )
    parameters>> [
        %prepare-unbox >r over + r> unbox-parameter
    ] reverse-each-parameter drop ;

: prepare-box-struct ( node -- offset )
    #! Return offset on C stack where to store unboxed
    #! parameters. If the C function is returning a structure,
    #! the first parameter is an implicit target area pointer,
    #! so we need to use a different offset.
    return>> large-struct?
    [ %prepare-box-struct cell ] [ 0 ] if ;

: objects>registers ( params -- )
    #! Generate code for unboxing a list of C types, then
    #! generate code for moving these parameters to register on
    #! architectures where parameters are passed in registers.
    [
        [ prepare-box-struct ] keep
        [ unbox-parameters ] keep
        \ %load-param-reg move-parameters
    ] with-param-regs ;

: box-return* ( node -- )
    return>> [ ] [ box-return ] if-void ;

TUPLE: no-such-library name ;

M: no-such-library summary
    drop "Library not found" ;

M: no-such-library compiler-error-type
    drop +linkage+ ;

: no-such-library ( name -- )
    \ no-such-library boa
    compiling-word get compiler-error ;

TUPLE: no-such-symbol name ;

M: no-such-symbol summary
    drop "Symbol not found" ;

M: no-such-symbol compiler-error-type
    drop +linkage+ ;

: no-such-symbol ( name -- )
    \ no-such-symbol boa
    compiling-word get compiler-error ;

: check-dlsym ( symbols dll -- )
    dup dll-valid? [
        dupd [ dlsym ] curry contains?
        [ drop ] [ no-such-symbol ] if
    ] [
        dll-path no-such-library drop
    ] if ;

: stdcall-mangle ( symbol node -- symbol )
    "@"
    swap parameters>> parameter-sizes drop
    number>string 3append ;

: alien-invoke-dlsym ( params -- symbols dll )
    dup function>> dup pick stdcall-mangle 2array
    swap library>> library dup [ dll>> ] when
    2dup check-dlsym ;

M: ##alien-invoke generate-insn
    params>>
    ! Save registers for GC
    %prepare-alien-invoke
    ! Unbox parameters
    dup objects>registers
    %prepare-var-args
    ! Call function
    dup alien-invoke-dlsym %alien-invoke
    ! Box return value
    dup %cleanup
    box-return* ;

! ##alien-indirect
M: ##alien-indirect generate-insn
    params>>
    ! Save registers for GC
    %prepare-alien-invoke
    ! Save alien at top of stack to temporary storage
    %prepare-alien-indirect
    ! Unbox parameters
    dup objects>registers
    %prepare-var-args
    ! Call alien in temporary storage
    %alien-indirect
    ! Box return value
    dup %cleanup
    box-return* ;

! ##alien-callback
: box-parameters ( params -- )
    alien-parameters [ box-parameter ] each-parameter ;

: registers>objects ( node -- )
    [
        dup \ %save-param-reg move-parameters
        "nest_stacks" f %alien-invoke
        box-parameters
    ] with-param-regs ;

TUPLE: callback-context ;

: current-callback 2 getenv ;

: wait-to-return ( token -- )
    dup current-callback eq? [
        drop
    ] [
        yield wait-to-return
    ] if ;

: do-callback ( quot token -- )
    init-catchstack
    dup 2 setenv
    slip
    wait-to-return ; inline

: callback-return-quot ( ctype -- quot )
    return>> {
        { [ dup "void" = ] [ drop [ ] ] }
        { [ dup large-struct? ] [ heap-size [ memcpy ] curry ] }
        [ c-type c-type-unboxer-quot ]
    } cond ;

: callback-prep-quot ( params -- quot )
    parameters>> [ c-type c-type-boxer-quot ] map spread>quot ;

: wrap-callback-quot ( params -- quot )
    [
        [ callback-prep-quot ]
        [ quot>> ]
        [ callback-return-quot ] tri 3append ,
        [ callback-context new do-callback ] %
    ] [ ] make ;

: %unnest-stacks ( -- ) "unnest_stacks" f %alien-invoke ;

M: ##callback-return generate-insn
    #! All the extra book-keeping for %unwind is only for x86.
    #! On other platforms its an alias for %return.
    params>> %callback-return ;

M: ##alien-callback generate-insn
    params>>
    [ registers>objects ]
    [ wrap-callback-quot %alien-callback ]
    [ alien-return [ %unnest-stacks ] [ %callback-value ] if-void ]
    tri ;

M: _spill generate-insn
    [ src>> ] [ n>> ] [ class>> ] tri {
        { int-regs [ %spill-integer ] }
        { double-float-regs [ %spill-float ] }
    } case ;

M: _reload generate-insn
    [ dst>> ] [ n>> ] [ class>> ] tri {
        { int-regs [ %reload-integer ] }
        { double-float-regs [ %reload-float ] }
    } case ;

M: _spill-counts generate-insn drop ;
