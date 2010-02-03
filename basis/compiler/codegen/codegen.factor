! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces make math math.order math.parser sequences accessors
kernel kernel.private layouts assocs words summary arrays
combinators classes.algebra alien alien.c-types
alien.strings alien.arrays alien.complex alien.libraries sets libc
continuations.private fry cpu.architecture classes classes.struct locals
source-files.errors slots parser generic.parser strings
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
IN: compiler.codegen

SYMBOL: insn-counts

H{ } clone insn-counts set-global

GENERIC: generate-insn ( insn -- )

! Mapping _label IDs to label instances
SYMBOL: labels

: generate ( mr -- code )
    dup label>> [
        H{ } clone labels set
        instructions>> [
            [ class insn-counts get inc-at ]
            [ generate-insn ]
            bi
        ] each
    ] with-fixup ;

: lookup-label ( id -- label )
    labels get [ drop <label> ] cache ;

! Special cases
M: ##no-tco generate-insn drop ;

M: _dispatch-label generate-insn
    label>> lookup-label
    cell 0 <repetition> %
    rc-absolute-cell label-fixup ;

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

CODEGEN: ##load-immediate %load-immediate
CODEGEN: ##load-reference %load-reference
CODEGEN: ##load-constant %load-reference
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
CODEGEN: ##string-nth %string-nth
CODEGEN: ##set-string-nth-fast %set-string-nth-fast
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
CODEGEN: ##alien-unsigned-1 %alien-unsigned-1
CODEGEN: ##alien-unsigned-2 %alien-unsigned-2
CODEGEN: ##alien-unsigned-4 %alien-unsigned-4
CODEGEN: ##alien-signed-1 %alien-signed-1
CODEGEN: ##alien-signed-2 %alien-signed-2
CODEGEN: ##alien-signed-4 %alien-signed-4
CODEGEN: ##alien-cell %alien-cell
CODEGEN: ##alien-float %alien-float
CODEGEN: ##alien-double %alien-double
CODEGEN: ##alien-vector %alien-vector
CODEGEN: ##set-alien-integer-1 %set-alien-integer-1
CODEGEN: ##set-alien-integer-2 %set-alien-integer-2
CODEGEN: ##set-alien-integer-4 %set-alien-integer-4
CODEGEN: ##set-alien-cell %set-alien-cell
CODEGEN: ##set-alien-float %set-alien-float
CODEGEN: ##set-alien-double %set-alien-double
CODEGEN: ##set-alien-vector %set-alien-vector
CODEGEN: ##allot %allot
CODEGEN: ##write-barrier %write-barrier
CODEGEN: ##write-barrier-imm %write-barrier-imm
CODEGEN: ##compare %compare
CODEGEN: ##compare-imm %compare-imm
CODEGEN: ##compare-float-ordered %compare-float-ordered
CODEGEN: ##compare-float-unordered %compare-float-unordered
CODEGEN: ##save-context %save-context
CODEGEN: ##vm-field-ptr %vm-field-ptr

CODEGEN: _fixnum-add %fixnum-add
CODEGEN: _fixnum-sub %fixnum-sub
CODEGEN: _fixnum-mul %fixnum-mul
CODEGEN: _label resolve-label
CODEGEN: _branch %jump-label
CODEGEN: _compare-branch %compare-branch
CODEGEN: _compare-imm-branch %compare-imm-branch
CODEGEN: _compare-float-ordered-branch %compare-float-ordered-branch
CODEGEN: _compare-float-unordered-branch %compare-float-unordered-branch
CODEGEN: _test-vector-branch %test-vector-branch
CODEGEN: _dispatch %dispatch
CODEGEN: _spill %spill
CODEGEN: _reload %reload

! ##gc
: wipe-locs ( locs temp -- )
    '[
        _
        [ 0 %load-immediate ]
        [ swap [ %replace ] with each ] bi
    ] unless-empty ;

GENERIC# save-gc-root 1 ( gc-root operand temp -- )

M:: spill-slot save-gc-root ( gc-root operand temp -- )
    temp int-rep operand %reload
    gc-root temp %save-gc-root ;

M: object save-gc-root drop %save-gc-root ;

: save-gc-roots ( gc-roots temp -- ) '[ _ save-gc-root ] assoc-each ;

: save-data-regs ( data-regs -- ) [ first3 %spill ] each ;

GENERIC# load-gc-root 1 ( gc-root operand temp -- )

M:: spill-slot load-gc-root ( gc-root operand temp -- )
    gc-root temp %load-gc-root
    temp int-rep operand %spill ;

M: object load-gc-root drop %load-gc-root ;

: load-gc-roots ( gc-roots temp -- ) '[ _ load-gc-root ] assoc-each ;

: load-data-regs ( data-regs -- ) [ first3 %reload ] each ;

M: ##gc generate-insn
    "no-gc" define-label
    {
        [ [ "no-gc" get ] dip [ size>> ] [ temp1>> ] [ temp2>> ] tri %check-nursery ]
        [ [ uninitialized-locs>> ] [ temp1>> ] bi wipe-locs ]
        [ data-values>> save-data-regs ]
        [ [ tagged-values>> ] [ temp1>> ] bi save-gc-roots ]
        [ [ temp1>> ] [ temp2>> ] bi %save-context ]
        [ [ tagged-values>> length ] [ temp1>> ] bi %call-gc ]
        [ [ tagged-values>> ] [ temp1>> ] bi load-gc-roots ]
        [ data-values>> load-data-regs ]
    } cleave
    "no-gc" resolve-label ;

M: _loop-entry generate-insn drop %loop-entry ;

M: ##alien-global generate-insn
    [ dst>> ] [ symbol>> ] [ library>> ] tri
    %alien-global ;

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

GENERIC: reg-class-full? ( reg-class -- ? )

M: stack-params reg-class-full? drop t ;

M: reg-class reg-class-full?
    [ get ] [ param-regs length ] bi >= ;

: alloc-stack-param ( rep -- n reg-class rep )
    stack-params get
    [ rep-size cell align stack-params +@ ] dip
    stack-params dup ;

: alloc-fastcall-param ( rep -- n reg-class rep )
    [ [ reg-class-of get ] [ reg-class-of ] [ next-fastcall-param ] tri ] keep ;

: alloc-parameter ( parameter -- reg rep )
    c-type-rep dup reg-class-of reg-class-full?
    [ alloc-stack-param ] [ alloc-fastcall-param ] if
    [ param-reg ] dip ;

: (flatten-int-type) ( type -- seq )
    stack-size cell align cell /i void* c-type <repetition> ;

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
    [ alien-parameters flatten-value-types ]
    [ '[ alloc-parameter _ execute ] ]
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

: stdcall-mangle ( params -- symbols )
    [ function>> ] [ parameters>> parameter-offsets drop number>string ] bi
    [ drop ] [ "@" glue ] [ "@" glue "_" prepend ] 2tri
    3array ;

: alien-invoke-dlsym ( params -- symbols dll )
    [ dup abi>> "stdcall" = [ stdcall-mangle ] [ function>> ] if ]
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
        %nest-stacks
        box-parameters
    ] with-param-regs ;

TUPLE: callback-context ;

: current-callback ( -- id ) 2 special-object ;

: wait-to-return ( token -- )
    dup current-callback eq? [
        drop
    ] [
        yield-hook get call( -- ) wait-to-return
    ] if ;

: do-callback ( quot token -- )
    init-catchstack
    [ 2 set-special-object call ] keep
    wait-to-return ; inline

: callback-return-quot ( ctype -- quot )
    return>> {
        { [ dup void? ] [ drop [ ] ] }
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

M: ##alien-callback generate-insn
    params>>
    [ registers>objects ]
    [ wrap-callback-quot %alien-callback ]
    [ alien-return [ %unnest-stacks ] [ %callback-value ] if-void ]
    tri ;
