! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces make math math.order math.parser sequences accessors
kernel kernel.private layouts assocs words summary arrays
combinators classes.algebra alien alien.c-types alien.structs
alien.strings alien.arrays alien.complex alien.libraries sets libc
continuations.private fry cpu.architecture classes locals
source-files.errors
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

TUPLE: asm label code calls ;

SYMBOL: calls

: add-call ( word -- )
    #! Compile this word later.
    calls get push ;

SYMBOL: compiling-word

: compiled-stack-traces? ( -- ? ) 67 getenv ;

! Mapping _label IDs to label instances
SYMBOL: labels

: init-generator ( word -- )
    H{ } clone labels set
    V{ } clone calls set
    compiling-word set
    compiled-stack-traces? [ compiling-word get add-literal ] when ;

: generate-insns ( asm -- code )
    [
        [ word>> init-generator ]
        [
            instructions>>
            [
                [ class insn-counts get inc-at ]
                [ generate-insn ]
                bi
            ] each
        ] bi
    ] with-fixup ;

: generate ( mr -- asm )
    [
        [ label>> ] [ generate-insns ] bi calls get
        asm boa
    ] with-scope ;

: lookup-label ( id -- label )
    labels get [ drop <label> ] cache ;

M: ##no-tco generate-insn drop ;

M: ##load-immediate generate-insn
    [ dst>> ] [ val>> ] bi %load-immediate ;

M: ##load-reference generate-insn
    [ dst>> ] [ obj>> ] bi %load-reference ;

M: ##peek generate-insn
    [ dst>> ] [ loc>> ] bi %peek ;

M: ##replace generate-insn
    [ src>> ] [ loc>> ] bi %replace ;

M: ##inc-d generate-insn n>> %inc-d ;

M: ##inc-r generate-insn n>> %inc-r ;

M: ##call generate-insn
    word>> dup sub-primitive>>
    [ first % ] [ [ add-call ] [ %call ] bi ] ?if ;

M: ##jump generate-insn word>> [ add-call ] [ %jump ] bi ;

M: ##return generate-insn drop %return ;

M: _dispatch generate-insn
    [ src>> ] [ temp>> ] bi %dispatch ;

M: _dispatch-label generate-insn
    label>> lookup-label
    cell 0 <repetition> %
    rc-absolute-cell label-fixup ;

: >slot< ( insn -- dst obj slot tag )
    { [ dst>> ] [ obj>> ] [ slot>> ] [ tag>> ] } cleave ; inline

M: ##slot generate-insn
    [ >slot< ] [ temp>> ] bi %slot ;

M: ##slot-imm generate-insn
    >slot< %slot-imm ;

: >set-slot< ( insn -- src obj slot tag )
    { [ src>> ] [ obj>> ] [ slot>> ] [ tag>> ] } cleave ; inline

M: ##set-slot generate-insn
    [ >set-slot< ] [ temp>> ] bi %set-slot ;

M: ##set-slot-imm generate-insn
    >set-slot< %set-slot-imm ;

M: ##string-nth generate-insn
    { [ dst>> ] [ obj>> ] [ index>> ] [ temp>> ] } cleave %string-nth ;

M: ##set-string-nth-fast generate-insn
    { [ src>> ] [ obj>> ] [ index>> ] [ temp>> ] } cleave %set-string-nth-fast ;

: dst/src ( insn -- dst src )
    [ dst>> ] [ src>> ] bi ; inline

: dst/src1/src2 ( insn -- dst src1 src2 )
    [ dst>> ] [ src1>> ] [ src2>> ] tri ; inline

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
M: ##shl     generate-insn dst/src1/src2 %shl     ;
M: ##shl-imm generate-insn dst/src1/src2 %shl-imm ;
M: ##shr     generate-insn dst/src1/src2 %shr     ;
M: ##shr-imm generate-insn dst/src1/src2 %shr-imm ;
M: ##sar     generate-insn dst/src1/src2 %sar     ;
M: ##sar-imm generate-insn dst/src1/src2 %sar-imm ;
M: ##not     generate-insn dst/src       %not     ;
M: ##log2    generate-insn dst/src       %log2    ;

: label/dst/src1/src2 ( insn -- label dst src1 src2 )
    [ label>> lookup-label ] [ dst/src1/src2 ] bi ; inline

M: _fixnum-add generate-insn label/dst/src1/src2 %fixnum-add ;
M: _fixnum-sub generate-insn label/dst/src1/src2 %fixnum-sub ;
M: _fixnum-mul generate-insn label/dst/src1/src2 %fixnum-mul ;

: dst/src/temp ( insn -- dst src temp )
    [ dst/src ] [ temp>> ] bi ; inline

M: ##integer>bignum generate-insn dst/src/temp %integer>bignum ;
M: ##bignum>integer generate-insn dst/src/temp %bignum>integer ;

M: ##add-float generate-insn dst/src1/src2 %add-float ;
M: ##sub-float generate-insn dst/src1/src2 %sub-float ;
M: ##mul-float generate-insn dst/src1/src2 %mul-float ;
M: ##div-float generate-insn dst/src1/src2 %div-float ;

M: ##integer>float generate-insn dst/src %integer>float ;
M: ##float>integer generate-insn dst/src %float>integer ;

M: ##copy generate-insn [ dst/src ] [ rep>> ] bi %copy ;

M: ##unbox-float     generate-insn dst/src %unbox-float ;
M: ##unbox-any-c-ptr generate-insn dst/src/temp %unbox-any-c-ptr ;
M: ##box-float       generate-insn dst/src/temp %box-float ;
M: ##box-alien       generate-insn dst/src/temp %box-alien ;

M: ##alien-unsigned-1 generate-insn dst/src %alien-unsigned-1 ;
M: ##alien-unsigned-2 generate-insn dst/src %alien-unsigned-2 ;
M: ##alien-unsigned-4 generate-insn dst/src %alien-unsigned-4 ;
M: ##alien-signed-1   generate-insn dst/src %alien-signed-1   ;
M: ##alien-signed-2   generate-insn dst/src %alien-signed-2   ;
M: ##alien-signed-4   generate-insn dst/src %alien-signed-4   ;
M: ##alien-cell       generate-insn dst/src %alien-cell       ;
M: ##alien-float      generate-insn dst/src %alien-float      ;
M: ##alien-double     generate-insn dst/src %alien-double     ;

: >alien-setter< ( insn -- src value )
    [ src>> ] [ value>> ] bi ; inline

M: ##set-alien-integer-1 generate-insn >alien-setter< %set-alien-integer-1 ;
M: ##set-alien-integer-2 generate-insn >alien-setter< %set-alien-integer-2 ;
M: ##set-alien-integer-4 generate-insn >alien-setter< %set-alien-integer-4 ;
M: ##set-alien-cell      generate-insn >alien-setter< %set-alien-cell      ;
M: ##set-alien-float     generate-insn >alien-setter< %set-alien-float     ;
M: ##set-alien-double    generate-insn >alien-setter< %set-alien-double    ;

M: ##allot generate-insn
    {
        [ dst>> ]
        [ size>> ]
        [ class>> ]
        [ temp>> ]
    } cleave
    %allot ;

M: ##write-barrier generate-insn
    [ src>> ]
    [ card#>> ]
    [ table>> ]
    tri %write-barrier ;

! GC checks
: wipe-locs ( locs temp -- )
    '[
        _
        [ 0 %load-immediate ]
        [ swap [ %replace ] with each ] bi
    ] unless-empty ;

GENERIC# save-gc-root 1 ( gc-root operand temp -- )

M:: spill-slot save-gc-root ( gc-root operand temp -- )
    temp operand n>> int-rep %reload
    gc-root temp %save-gc-root ;

M: object save-gc-root drop %save-gc-root ;

: save-gc-roots ( gc-roots temp -- ) '[ _ save-gc-root ] assoc-each ;

: save-data-regs ( data-regs -- ) [ first3 %spill ] each ;

GENERIC# load-gc-root 1 ( gc-root operand temp -- )

M:: spill-slot load-gc-root ( gc-root operand temp -- )
    gc-root temp %load-gc-root
    temp operand n>> int-rep %spill ;

M: object load-gc-root drop %load-gc-root ;

: load-gc-roots ( gc-roots temp -- ) '[ _ load-gc-root ] assoc-each ;

: load-data-regs ( data-regs -- ) [ first3 %reload ] each ;

M: _gc generate-insn
    "no-gc" define-label
    {
        [ [ "no-gc" get ] dip [ temp1>> ] [ temp2>> ] bi %check-nursery ]
        [ [ uninitialized-locs>> ] [ temp1>> ] bi wipe-locs ]
        [ data-values>> save-data-regs ]
        [ [ tagged-values>> ] [ temp1>> ] bi save-gc-roots ]
        [ tagged-values>> length %call-gc ]
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

M: single-float-rep next-fastcall-param
    float-regs inc [ ?dummy-stack-params ] [ ?dummy-int-params ] bi ;

M: double-float-rep next-fastcall-param
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
    [ [ parameter-sizes nip ] keep ] dip 2each ; inline

: reverse-each-parameter ( parameters quot -- )
    [ [ parameter-sizes nip ] keep ] dip 2reverse-each ; inline

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

: unbox-parameters ( offset node -- )
    parameters>> [
        %prepare-unbox [ over + ] dip unbox-parameter
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
    #! generate code for moving these parameters to registers on
    #! architectures where parameters are passed in registers.
    [
        [ prepare-box-struct ] keep
        [ unbox-parameters ] keep
        \ %load-param-reg move-parameters
    ] with-param-regs ;

: box-return* ( node -- )
    return>> [ ] [ box-return ] if-void ;

: check-dlsym ( symbols dll -- )
    dup dll-valid? [
        dupd '[ _ dlsym ] any?
        [ drop ] [ compiling-word get no-such-symbol ] if
    ] [
        dll-path compiling-word get no-such-library drop
    ] if ;

: stdcall-mangle ( symbol params -- symbol )
    parameters>> parameter-sizes drop number>string "@" glue ;

: alien-invoke-dlsym ( params -- symbols dll )
    [ [ function>> dup ] keep stdcall-mangle 2array ]
    [ library>> library dup [ dll>> ] when ]
    bi 2dup check-dlsym ;

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
    ! Generate code for boxing input parameters in a callback.
    [
        dup \ %save-param-reg move-parameters
        "nest_stacks" f %alien-invoke
        box-parameters
    ] with-param-regs ;

TUPLE: callback-context ;

: current-callback ( -- id ) 2 getenv ;

: wait-to-return ( token -- )
    dup current-callback eq? [
        drop
    ] [
        yield-hook get call( -- ) wait-to-return
    ] if ;

: do-callback ( quot token -- )
    init-catchstack
    [ 2 setenv call ] keep
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
    id>> lookup-label resolve-label ;

M: _branch generate-insn
    label>> lookup-label %jump-label ;

: >compare< ( insn -- dst temp cc src1 src2 )
    {
        [ dst>> ]
        [ temp>> ]
        [ cc>> ]
        [ src1>> ]
        [ src2>> ]
    } cleave ; inline

M: ##compare generate-insn >compare< %compare ;
M: ##compare-imm generate-insn >compare< %compare-imm ;
M: ##compare-float generate-insn >compare< %compare-float ;

: >binary-branch< ( insn -- label cc src1 src2 )
    {
        [ label>> lookup-label ]
        [ cc>> ]
        [ src1>> ]
        [ src2>> ]
    } cleave ; inline

M: _compare-branch generate-insn
    >binary-branch< %compare-branch ;

M: _compare-imm-branch generate-insn
    >binary-branch< %compare-imm-branch ;

M: _compare-float-branch generate-insn
    >binary-branch< %compare-float-branch ;

M: _spill generate-insn
    [ src>> ] [ n>> ] [ rep>> ] tri %spill ;

M: _reload generate-insn
    [ dst>> ] [ n>> ] [ rep>> ] tri %reload ;

M: _spill-area-size generate-insn drop ;
