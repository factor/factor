! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces make math math.parser sequences accessors
kernel kernel.private layouts assocs words summary arrays
combinators classes.algebra alien alien.c-types alien.structs
alien.strings alien.arrays sets threads libc continuations.private
fry cpu.architecture
compiler.errors
compiler.alien
compiler.cfg
compiler.cfg.instructions
compiler.cfg.registers
compiler.cfg.builder
compiler.codegen.fixup ;
IN: compiler.codegen

GENERIC: generate-insn ( insn -- )

SYMBOL: registers

: register ( vreg -- operand )
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

M: ##load-immediate generate-insn
    [ dst>> register ] [ obj>> ] bi %load-immediate ;

M: ##load-indirect generate-insn
    [ dst>> register ] [ obj>> ] bi %load-indirect ;

M: ##peek generate-insn
    [ dst>> register ] [ loc>> ] bi %peek ;

M: ##replace generate-insn
    [ src>> register ] [ loc>> ] bi %replace ;

M: ##inc-d generate-insn n>> %inc-d ;

M: ##inc-r generate-insn n>> %inc-r ;

M: ##call generate-insn word>> [ add-call ] [ %call ] bi ;

M: ##jump generate-insn word>> [ add-call ] [ %jump-label ] bi ;

M: ##return generate-insn drop %return ;

M: ##dispatch-label generate-insn label>> %dispatch-label ;

M: ##dispatch generate-insn
    [ src>> register ] [ temp>> register ] bi %dispatch ;

: >slot<
    {
        [ dst>> register ]
        [ obj>> register ]
        [ slot>> dup vreg? [ register ] when ]
        [ tag>> ]
    } cleave ; inline

M: ##slot generate-insn >slot< %slot ;

M: ##slot-imm generate-insn >slot< %slot-imm ;

: >set-slot<
    {
        [ src>> register ]
        [ obj>> register ]
        [ slot>> dup vreg? [ register ] when ]
        [ tag>> ]
    } cleave ; inline

M: ##set-slot generate-insn >set-slot< %set-slot ;

M: ##set-slot-imm generate-insn >set-slot< %set-slot-imm ;

: dst/src ( insn -- dst src )
    [ dst>> register ] [ src>> register ] bi ; inline

: dst/src1/src2 ( insn -- dst src1 src2 )
    [ dst>> register ] [ src1>> register ] [ src2>> register ] tri ; inline

M: ##add     generate-insn dst/src1/src2 %add     ;
M: ##add-imm generate-insn dst/src1/src2 %add-imm ;
M: ##sub     generate-insn dst/src1/src2 %sub     ;
M: ##sub-imm generate-insn dst/src1/src2 %sub-imm ;
M: ##mul     generate-insn dst/src1/src2 %mul     ;
M: ##mul-imm generate-insn dst/src1/src2 %mul-imm ;
M: ##and     generate-insn dst/src1/src2 %and     ;
M: ##and-imm generate-insn dst/src1/src2 %and-imm ;
M: ##or      generate-insn dst/src1/src2 %or      ;
M: ##or-imm  generate-insn dst/src1/src2 %or-imm  ;
M: ##xor     generate-insn dst/src1/src2 %xor     ;
M: ##xor-imm generate-insn dst/src1/src2 %xor-imm ;
M: ##shl-imm generate-insn dst/src1/src2 %shl-imm ;
M: ##shr-imm generate-insn dst/src1/src2 %shr-imm ;
M: ##sar-imm generate-insn dst/src1/src2 %sar-imm ;
M: ##not     generate-insn dst/src       %not     ;

: dst/src/temp ( insn -- dst src temp )
    [ dst/src ] [ temp>> register ] bi ; inline

M: ##integer>bignum generate-insn dst/src/temp %integer>bignum ;
M: ##bignum>integer generate-insn dst/src %bignum>integer ;

M: ##add-float generate-insn dst/src1/src2 %add-float ;
M: ##sub-float generate-insn dst/src1/src2 %sub-float ;
M: ##mul-float generate-insn dst/src1/src2 %mul-float ;
M: ##div-float generate-insn dst/src1/src2 %div-float ;

M: ##integer>float generate-insn dst/src/temp %integer>float ;
M: ##float>integer generate-insn dst/src %float>integer ;

M: ##copy             generate-insn dst/src %copy             ;
M: ##copy-float       generate-insn dst/src %copy-float       ;
M: ##unbox-float      generate-insn dst/src %unbox-float      ;
M: ##unbox-f          generate-insn dst/src %unbox-f          ;
M: ##unbox-alien      generate-insn dst/src %unbox-alien      ;
M: ##unbox-byte-array generate-insn dst/src %unbox-byte-array ;
M: ##unbox-any-c-ptr  generate-insn dst/src %unbox-any-c-ptr  ;
M: ##box-float        generate-insn dst/src/temp %box-float   ;
M: ##box-alien        generate-insn dst/src/temp %box-alien   ;

M: ##alien-unsigned-1 generate-insn dst/src %alien-unsigned-1 ;
M: ##alien-unsigned-2 generate-insn dst/src %alien-unsigned-2 ;
M: ##alien-unsigned-4 generate-insn dst/src %alien-unsigned-4 ;
M: ##alien-signed-1   generate-insn dst/src %alien-signed-1   ;
M: ##alien-signed-2   generate-insn dst/src %alien-signed-2   ;
M: ##alien-signed-3   generate-insn dst/src %alien-signed-3   ;
M: ##alien-cell       generate-insn dst/src %alien-cell       ;
M: ##alien-float      generate-insn dst/src %alien-float      ;
M: ##alien-double     generate-insn dst/src %alien-double     ;

: >alien-setter< [ src>> register ] [ value>> register ] bi ;

M: ##set-alien-integer-1 generate-insn >alien-setter< %set-alien-integer-1 ;
M: ##set-alien-integer-2 generate-insn >alien-setter< %set-alien-integer-2 ;
M: ##set-alien-integer-4 generate-insn >alien-setter< %set-alien-integer-4 ;
M: ##set-alien-cell      generate-insn >alien-setter< %set-alien-cell      ;
M: ##set-alien-float     generate-insn >alien-setter< %set-alien-float     ;
M: ##set-alien-double    generate-insn >alien-setter< %set-alien-double    ;

M: ##allot generate-insn
    {
        [ dst>> register ]
        [ size>> ]
        [ type>> ]
        [ tag>> ]
        [ temp>> register ]
    } cleave
    %allot ;

M: ##write-barrier generate-insn
    [ src>> register ]
    [ card#>> register ]
    [ table>> register ]
    tri %write-barrier ;

M: ##gc generate-insn drop %gc ;

! ##alien-invoke
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
    r> '[ alloc-parameter _ execute ] each-parameter ;
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
        dupd '[ _ dlsym ] contains?
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
        { [ dup large-struct? ] [ heap-size '[ _ memcpy ] ] }
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

M: _prologue generate-insn
    stack-frame>> [ stack-frame set ] [ total-size>> %prologue ] bi ;

M: _epilogue generate-insn
    stack-frame>> total-size>> %epilogue ;

M: _label generate-insn
    id>> lookup-label , ;

M: _branch generate-insn
    label>> lookup-label %jump-label ;

: >binary-branch< ( insn -- label src1 src2 cc )
    {
        [ label>> lookup-label ]
        [ src1>> register ]
        [ src2>> dup vreg? [ register ] when ]
        [ cc>> ]
    } cleave ;

M: _binary-branch generate-insn
    >binary-branch< %binary-branch ;

M: _binary-imm-branch generate-insn
    >binary-branch< %binary-imm-branch ;

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
