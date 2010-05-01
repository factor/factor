! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces make math math.order math.parser sequences
accessors kernel layouts assocs words summary arrays combinators
classes.algebra alien alien.private alien.c-types alien.strings
alien.arrays alien.complex alien.libraries sets libc
continuations.private fry cpu.architecture classes
classes.struct locals source-files.errors slots parser
generic.parser strings quotations
compiler.errors
compiler.alien
compiler.constants
compiler.cfg
compiler.cfg.instructions
compiler.cfg.stack-frame
compiler.cfg.registers
compiler.cfg.builder
compiler.codegen.fixup
compiler.utilities ;
FROM: namespaces => set ;
FROM: compiler.errors => no-such-symbol ;
IN: compiler.codegen

SYMBOL: insn-counts

H{ } clone insn-counts set-global

GENERIC: generate-insn ( insn -- )

! Mapping _label IDs to label instances
SYMBOL: labels

: lookup-label ( id -- label )
    labels get [ drop <label> ] cache ;

: generate ( mr -- code )
    dup label>> [
        H{ } clone labels set
        instructions>> [
            [ class insn-counts get inc-at ]
            [ generate-insn ]
            bi
        ] each
    ] with-fixup ;

! Special cases
M: ##no-tco generate-insn drop ;

M: _prologue generate-insn
    stack-frame>> [ stack-frame set ] [ total-size>> %prologue ] bi ;

M: _epilogue generate-insn
    stack-frame>> total-size>> %epilogue ;

M: _spill-area-size generate-insn drop ;

! Some meta-programming to generate simple code generators, where
! the instruction is unpacked and then a %word is called
<<

: insn-slot-quot ( spec -- quot )
    name>> [ reader-word ] [ "label" = ] bi
    [ \ lookup-label [ ] 2sequence ] [ [ ] 1sequence ] if ;

: codegen-method-body ( class word -- quot )
    [
        "insn-slots" word-prop
        [ insn-slot-quot ] map cleave>quot
    ] dip suffix ;

SYNTAX: CODEGEN:
    scan-word [ \ generate-insn create-method-in ] keep scan-word
    codegen-method-body define ;

>>

CODEGEN: ##load-integer %load-immediate
CODEGEN: ##load-tagged %load-immediate
CODEGEN: ##load-reference %load-reference
CODEGEN: ##load-double %load-double
CODEGEN: ##load-vector %load-vector
CODEGEN: ##peek %peek
CODEGEN: ##replace %replace
CODEGEN: ##inc-d %inc-d
CODEGEN: ##inc-r %inc-r
CODEGEN: ##call %call
CODEGEN: ##jump %jump
CODEGEN: ##return %return
CODEGEN: ##slot %slot
CODEGEN: ##slot-imm %slot-imm
CODEGEN: ##set-slot %set-slot
CODEGEN: ##set-slot-imm %set-slot-imm
CODEGEN: ##add %add
CODEGEN: ##add-imm %add-imm
CODEGEN: ##sub %sub
CODEGEN: ##sub-imm %sub-imm
CODEGEN: ##mul %mul
CODEGEN: ##mul-imm %mul-imm
CODEGEN: ##and %and
CODEGEN: ##and-imm %and-imm
CODEGEN: ##or %or
CODEGEN: ##or-imm %or-imm
CODEGEN: ##xor %xor
CODEGEN: ##xor-imm %xor-imm
CODEGEN: ##shl %shl
CODEGEN: ##shl-imm %shl-imm
CODEGEN: ##shr %shr
CODEGEN: ##shr-imm %shr-imm
CODEGEN: ##sar %sar
CODEGEN: ##sar-imm %sar-imm
CODEGEN: ##min %min
CODEGEN: ##max %max
CODEGEN: ##not %not
CODEGEN: ##neg %neg
CODEGEN: ##log2 %log2
CODEGEN: ##copy %copy
CODEGEN: ##tagged>integer %tagged>integer
CODEGEN: ##add-float %add-float
CODEGEN: ##sub-float %sub-float
CODEGEN: ##mul-float %mul-float
CODEGEN: ##div-float %div-float
CODEGEN: ##min-float %min-float
CODEGEN: ##max-float %max-float
CODEGEN: ##sqrt %sqrt
CODEGEN: ##unary-float-function %unary-float-function
CODEGEN: ##binary-float-function %binary-float-function
CODEGEN: ##single>double-float %single>double-float
CODEGEN: ##double>single-float %double>single-float
CODEGEN: ##integer>float %integer>float
CODEGEN: ##float>integer %float>integer
CODEGEN: ##zero-vector %zero-vector
CODEGEN: ##fill-vector %fill-vector
CODEGEN: ##gather-vector-2 %gather-vector-2
CODEGEN: ##gather-vector-4 %gather-vector-4
CODEGEN: ##shuffle-vector-imm %shuffle-vector-imm
CODEGEN: ##shuffle-vector %shuffle-vector
CODEGEN: ##tail>head-vector %tail>head-vector
CODEGEN: ##merge-vector-head %merge-vector-head
CODEGEN: ##merge-vector-tail %merge-vector-tail
CODEGEN: ##signed-pack-vector %signed-pack-vector
CODEGEN: ##unsigned-pack-vector %unsigned-pack-vector
CODEGEN: ##unpack-vector-head %unpack-vector-head
CODEGEN: ##unpack-vector-tail %unpack-vector-tail
CODEGEN: ##integer>float-vector %integer>float-vector
CODEGEN: ##float>integer-vector %float>integer-vector
CODEGEN: ##compare-vector %compare-vector
CODEGEN: ##test-vector %test-vector
CODEGEN: ##add-vector %add-vector
CODEGEN: ##saturated-add-vector %saturated-add-vector
CODEGEN: ##add-sub-vector %add-sub-vector
CODEGEN: ##sub-vector %sub-vector
CODEGEN: ##saturated-sub-vector %saturated-sub-vector
CODEGEN: ##mul-vector %mul-vector
CODEGEN: ##mul-high-vector %mul-high-vector
CODEGEN: ##mul-horizontal-add-vector %mul-horizontal-add-vector
CODEGEN: ##saturated-mul-vector %saturated-mul-vector
CODEGEN: ##div-vector %div-vector
CODEGEN: ##min-vector %min-vector
CODEGEN: ##max-vector %max-vector
CODEGEN: ##avg-vector %avg-vector
CODEGEN: ##dot-vector %dot-vector
CODEGEN: ##sad-vector %sad-vector
CODEGEN: ##sqrt-vector %sqrt-vector
CODEGEN: ##horizontal-add-vector %horizontal-add-vector
CODEGEN: ##horizontal-sub-vector %horizontal-sub-vector
CODEGEN: ##horizontal-shl-vector-imm %horizontal-shl-vector-imm
CODEGEN: ##horizontal-shr-vector-imm %horizontal-shr-vector-imm
CODEGEN: ##abs-vector %abs-vector
CODEGEN: ##and-vector %and-vector
CODEGEN: ##andn-vector %andn-vector
CODEGEN: ##or-vector %or-vector
CODEGEN: ##xor-vector %xor-vector
CODEGEN: ##not-vector %not-vector
CODEGEN: ##shl-vector-imm %shl-vector-imm
CODEGEN: ##shr-vector-imm %shr-vector-imm
CODEGEN: ##shl-vector %shl-vector
CODEGEN: ##shr-vector %shr-vector
CODEGEN: ##integer>scalar %integer>scalar
CODEGEN: ##scalar>integer %scalar>integer
CODEGEN: ##vector>scalar %vector>scalar
CODEGEN: ##scalar>vector %scalar>vector
CODEGEN: ##box-alien %box-alien
CODEGEN: ##box-displaced-alien %box-displaced-alien
CODEGEN: ##unbox-alien %unbox-alien
CODEGEN: ##unbox-any-c-ptr %unbox-any-c-ptr
CODEGEN: ##load-memory %load-memory
CODEGEN: ##load-memory-imm %load-memory-imm
CODEGEN: ##store-memory %store-memory
CODEGEN: ##store-memory-imm %store-memory-imm
CODEGEN: ##allot %allot
CODEGEN: ##write-barrier %write-barrier
CODEGEN: ##write-barrier-imm %write-barrier-imm
CODEGEN: ##compare %compare
CODEGEN: ##compare-imm %compare-imm
CODEGEN: ##compare-integer %compare
CODEGEN: ##compare-integer-imm %compare-imm
CODEGEN: ##compare-float-ordered %compare-float-ordered
CODEGEN: ##compare-float-unordered %compare-float-unordered
CODEGEN: ##save-context %save-context
CODEGEN: ##vm-field %vm-field
CODEGEN: ##set-vm-field %set-vm-field
CODEGEN: ##alien-global %alien-global
CODEGEN: ##call-gc %call-gc
CODEGEN: ##spill %spill
CODEGEN: ##reload %reload
CODEGEN: ##dispatch %dispatch

: %dispatch-label ( label -- )
    cell 0 <repetition> %
    rc-absolute-cell label-fixup ;

CODEGEN: _label resolve-label
CODEGEN: _dispatch-label %dispatch-label
CODEGEN: _branch %jump-label
CODEGEN: _loop-entry %loop-entry

GENERIC: generate-conditional-insn ( label insn -- )

<<

SYNTAX: CONDITIONAL:
    scan-word [ \ generate-conditional-insn create-method-in ] keep scan-word
    codegen-method-body define ;

>>

CONDITIONAL: ##compare-branch %compare-branch
CONDITIONAL: ##compare-imm-branch %compare-imm-branch
CONDITIONAL: ##compare-integer-branch %compare-branch
CONDITIONAL: ##compare-integer-imm-branch %compare-imm-branch
CONDITIONAL: ##compare-float-ordered-branch %compare-float-ordered-branch
CONDITIONAL: ##compare-float-unordered-branch %compare-float-unordered-branch
CONDITIONAL: ##test-vector-branch %test-vector-branch
CONDITIONAL: ##check-nursery-branch %check-nursery-branch
CONDITIONAL: ##fixnum-add %fixnum-add
CONDITIONAL: ##fixnum-sub %fixnum-sub
CONDITIONAL: ##fixnum-mul %fixnum-mul

M: _conditional-branch generate-insn
    [ label>> lookup-label ] [ insn>> ] bi generate-conditional-insn ;

! ##alien-invoke
GENERIC: next-fastcall-param ( rep -- )

: ?dummy-stack-params ( rep -- )
    dummy-stack-params? [ rep-size cell align stack-params +@ ] [ drop ] if ;

: ?dummy-int-params ( rep -- )
    dummy-int-params? [ rep-size cell /i 1 max int-regs +@ ] [ drop ] if ;

: ?dummy-fp-params ( rep -- )
    drop dummy-fp-params? [ float-regs inc ] when ;

M: int-rep next-fastcall-param
    int-regs inc [ ?dummy-stack-params ] [ ?dummy-fp-params ] bi ;

M: float-rep next-fastcall-param
    float-regs inc [ ?dummy-stack-params ] [ ?dummy-int-params ] bi ;

M: double-rep next-fastcall-param
    float-regs inc [ ?dummy-stack-params ] [ ?dummy-int-params ] bi ;

GENERIC# reg-class-full? 1 ( reg-class abi -- ? )

M: stack-params reg-class-full? 2drop t ;

M: reg-class reg-class-full?
    [ get ] swap '[ _ param-regs length ] bi >= ;

: alloc-stack-param ( rep -- n reg-class rep )
    stack-params get
    [ rep-size cell align stack-params +@ ] dip
    stack-params dup ;

: alloc-fastcall-param ( rep -- n reg-class rep )
    [ [ reg-class-of get ] [ reg-class-of ] [ next-fastcall-param ] tri ] keep ;

:: alloc-parameter ( parameter abi -- reg rep )
    parameter c-type-rep dup reg-class-of abi reg-class-full?
    [ alloc-stack-param ] [ alloc-fastcall-param ] if
    [ abi param-reg ] dip ;

SYMBOL: (stack-value)
<< void* c-type clone \ (stack-value) define-primitive-type
stack-params \ (stack-value) c-type (>>rep) >>

: ((flatten-type)) ( type to-type -- seq )
    [ stack-size cell align cell /i ] dip c-type <repetition> ; inline

: (flatten-int-type) ( type -- seq )
    void* ((flatten-type)) ;
: (flatten-stack-type) ( type -- seq )
    (stack-value) ((flatten-type)) ;

GENERIC: flatten-value-type ( type -- types )

M: object flatten-value-type 1array ;
M: struct-c-type flatten-value-type (flatten-int-type) ;
M: long-long-type flatten-value-type (flatten-int-type) ;
M: c-type-name flatten-value-type c-type flatten-value-type ;

: flatten-value-types ( params -- params )
    #! Convert value type structs to consecutive void*s.
    [
        0 [
            c-type
            [ parameter-align cell /i void* c-type <repetition> % ] keep
            [ stack-size cell align + ] keep
            flatten-value-type %
        ] reduce drop
    ] { } make ;

: each-parameter ( parameters quot -- )
    [ [ parameter-offsets nip ] keep ] dip 2each ; inline

: reset-fastcall-counts ( -- )
    { int-regs float-regs stack-params } [ 0 swap set ] each ;

: with-param-regs ( quot -- )
    #! In quot you can call alloc-parameter
    [ reset-fastcall-counts call ] with-scope ; inline

: move-parameters ( node word -- )
    #! Moves values from C stack to registers (if word is
    #! %load-param-reg) and registers to C stack (if word is
    #! %save-param-reg).
    [ [ alien-parameters flatten-value-types ] [ abi>> ] bi ]
    [ '[ _ alloc-parameter _ execute ] ]
    bi* each-parameter ; inline

: reverse-each-parameter ( parameters quot -- )
    [ [ parameter-offsets nip ] keep ] dip 2reverse-each ; inline

: prepare-unbox-parameters ( parameters -- offsets types indices )
    [ parameter-offsets nip ] [ ] [ length iota <reversed> ] tri ;

: unbox-parameters ( offset node -- )
    parameters>> swap
    '[ prepare-unbox-parameters [ %pop-stack [ _ + ] dip unbox-parameter ] 3each ]
    [ length neg %inc-d ]
    bi ;

: prepare-box-struct ( node -- offset )
    #! Return offset on C stack where to store unboxed
    #! parameters. If the C function is returning a structure,
    #! the first parameter is an implicit target area pointer,
    #! so we need to use a different offset.
    return>> large-struct?
    [ %prepare-box-struct cell ] [ 0 ] if ;

: objects>registers ( params -- )
    #! Generate code for unboxing a list of C types, then
    #! generate code for moving these parameters to registers on
    #! architectures where parameters are passed in registers.
    [
        [ prepare-box-struct ] keep
        [ unbox-parameters ] keep
        \ %load-param-reg move-parameters
    ] with-param-regs ;

: box-return* ( node -- )
    return>> [ ] [ box-return %push-stack ] if-void ;

GENERIC# dlsym-valid? 1 ( symbols dll -- ? )

M: string dlsym-valid? dlsym ;

M: array dlsym-valid? '[ _ dlsym ] any? ;

: check-dlsym ( symbols dll -- )
    dup dll-valid? [
        dupd dlsym-valid?
        [ drop ] [ compiling-word get no-such-symbol ] if
    ] [
        dll-path compiling-word get no-such-library drop
    ] if ;

: decorated-symbol ( params -- symbols )
    [ function>> ] [ parameters>> parameter-offsets drop number>string ] bi
    {
        [ drop ]
        [ "@" glue ]
        [ "@" glue "_" prepend ]
        [ "@" glue "@" prepend ]
    } 2cleave
    4array ;

: alien-invoke-dlsym ( params -- symbols dll )
    [ dup abi>> callee-cleanup? [ decorated-symbol ] [ function>> ] if ]
    [ library>> load-library ]
    bi 2dup check-dlsym ;

M: ##alien-invoke generate-insn
    params>>
    ! Unbox parameters
    dup objects>registers
    %prepare-var-args
    ! Call function
    dup alien-invoke-dlsym %alien-invoke
    ! Box return value
    dup %cleanup
    box-return* ;

M: ##alien-assembly generate-insn
    params>>
    ! Unbox parameters
    dup objects>registers
    %prepare-var-args
    ! Generate assembly
    dup quot>> call( -- )
    ! Box return value
    box-return* ;

! ##alien-indirect
M: ##alien-indirect generate-insn
    params>>
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
    alien-parameters [ box-parameter %push-context-stack ] each-parameter ;

: registers>objects ( node -- )
    ! Generate code for boxing input parameters in a callback.
    [
        dup \ %save-param-reg move-parameters
        %begin-callback
        box-parameters
    ] with-param-regs ;

: callback-return-quot ( ctype -- quot )
    return>> {
        { [ dup void? ] [ drop [ ] ] }
        { [ dup large-struct? ] [ heap-size '[ _ memcpy ] ] }
        [ c-type c-type-unboxer-quot ]
    } cond ;

: callback-prep-quot ( params -- quot )
    parameters>> [ c-type c-type-boxer-quot ] map spread>quot ;

: wrap-callback-quot ( params -- quot )
    [ callback-prep-quot ] [ quot>> ] [ callback-return-quot ] tri 3append
     yield-hook get
     '[ _ _ do-callback ]
     >quotation ;

M: ##alien-callback generate-insn
    params>>
    [ registers>objects ]
    [ wrap-callback-quot %alien-callback ]
    [ alien-return [ %end-callback ] [ %end-callback-value ] if-void ] tri ;
