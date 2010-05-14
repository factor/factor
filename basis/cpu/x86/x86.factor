! Copyright (C) 2005, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs alien alien.c-types arrays strings
cpu.x86.assembler cpu.x86.assembler.private cpu.x86.assembler.operands
cpu.x86.features cpu.x86.features.private cpu.architecture kernel
kernel.private math memory namespaces make sequences words system
layouts combinators math.order math.vectors fry locals compiler.constants
byte-arrays io macros quotations classes.algebra compiler
compiler.units init vm
compiler.cfg.registers
compiler.cfg.instructions
compiler.cfg.intrinsics
compiler.cfg.comparisons
compiler.cfg.stack-frame
compiler.codegen.fixup ;
QUALIFIED-WITH: alien.c-types c
FROM: layouts => cell ;
FROM: math => float ;
IN: cpu.x86

! Add some methods to the assembler to be more useful to the backend
M: label JMP 0 JMP rc-relative label-fixup ;
M: label JUMPcc [ 0 ] dip JUMPcc rc-relative label-fixup ;

M: x86 vector-regs float-regs ;

HOOK: stack-reg cpu ( -- reg )

HOOK: frame-reg cpu ( -- reg )

HOOK: reserved-stack-space cpu ( -- n )

HOOK: extra-stack-space cpu ( stack-frame -- n )

: stack@ ( n -- op ) stack-reg swap [+] ;

: special-offset ( m -- n )
    stack-frame get extra-stack-space +
    reserved-stack-space + ;

: special@ ( n -- op ) special-offset stack@ ;

: spill@ ( n -- op ) spill-offset special@ ;

: param@ ( n -- op ) reserved-stack-space + stack@ ;

: gc-root-offsets ( seq -- seq' )
    [ n>> spill-offset special-offset cell + ] map f like ;

: decr-stack-reg ( n -- )
    dup 0 = [ drop ] [ stack-reg swap SUB ] if ;

: incr-stack-reg ( n -- )
    dup 0 = [ drop ] [ stack-reg swap ADD ] if ;

: align-stack ( n -- n' ) 16 align ;

M: x86 stack-frame-size ( stack-frame -- i )
    [ (stack-frame-size) ]
    [ extra-stack-space ] bi +
    reserved-stack-space +
    3 cells +
    align-stack ;

! Must be a volatile register not used for parameter passing or
! integer return
HOOK: temp-reg cpu ( -- reg )

HOOK: pic-tail-reg cpu ( -- reg )

M: x86 complex-addressing? t ;

M: x86 fused-unboxing? t ;

M: x86 test-instruction? t ;

M: x86 immediate-store? immediate-comparand? ;

M: x86 %load-immediate dup 0 = [ drop dup XOR ] [ MOV ] if ;

M: x86 %load-reference
    [ swap 0 MOV rc-absolute-cell rel-literal ]
    [ \ f type-number MOV ]
    if* ;

HOOK: ds-reg cpu ( -- reg )
HOOK: rs-reg cpu ( -- reg )

: reg-stack ( n reg -- op ) swap cells neg [+] ;

GENERIC: loc>operand ( loc -- operand )

M: ds-loc loc>operand n>> ds-reg reg-stack ;
M: rs-loc loc>operand n>> rs-reg reg-stack ;

M: x86 %peek loc>operand MOV ;

M: x86 %replace loc>operand swap MOV ;

M: x86 %replace-imm
    loc>operand swap
    {
        { [ dup not ] [ drop \ f type-number MOV ] }
        { [ dup fixnum? ] [ tag-fixnum MOV ] }
        [ [ HEX: ffffffff MOV ] dip rc-absolute rel-literal ]
    } cond ;

: (%inc) ( n reg -- ) swap cells dup 0 > [ ADD ] [ neg SUB ] if ; inline
M: x86 %inc-d ( n -- ) ds-reg (%inc) ;
M: x86 %inc-r ( n -- ) rs-reg (%inc) ;

M: x86 %call ( word -- ) 0 CALL rc-relative rel-word-pic ;

: xt-tail-pic-offset ( -- n )
    #! See the comment in vm/cpu-x86.hpp
    4 1 + ; inline

HOOK: %prepare-jump cpu ( -- )

M: x86 %jump ( word -- )
    %prepare-jump
    0 JMP rc-relative rel-word-pic-tail ;

M: x86 %jump-label ( label -- ) 0 JMP rc-relative label-fixup ;

M: x86 %return ( -- ) 0 RET ;

: (%slot) ( obj slot scale tag -- op ) neg <indirect> ; inline
: (%slot-imm) ( obj slot tag -- op ) slot-offset [+] ; inline

M: x86 %slot ( dst obj slot scale tag -- ) (%slot) MOV ;
M: x86 %slot-imm ( dst obj slot tag -- ) (%slot-imm) MOV ;
M: x86 %set-slot ( src obj slot scale tag -- ) (%slot) swap MOV ;
M: x86 %set-slot-imm ( src obj slot tag -- ) (%slot-imm) swap MOV ;

:: two-operand ( dst src1 src2 rep -- dst src )
    dst src2 eq? dst src1 eq? not and [ "Cannot handle this case" throw ] when
    dst src1 rep %copy
    dst src2 ; inline

:: one-operand ( dst src rep -- dst )
    dst src rep %copy
    dst ; inline

M: x86 %add     2over eq? [ nip ADD ] [ [+] LEA ] if ;
M: x86 %add-imm 2over eq? [ nip ADD ] [ [+] LEA ] if ;
M: x86 %sub     int-rep two-operand SUB ;
M: x86 %sub-imm 2over eq? [ nip SUB ] [ neg [+] LEA ] if ;
M: x86 %mul     int-rep two-operand IMUL2 ;
M: x86 %mul-imm IMUL3 ;
M: x86 %and     int-rep two-operand AND ;
M: x86 %and-imm int-rep two-operand AND ;
M: x86 %or      int-rep two-operand OR ;
M: x86 %or-imm  int-rep two-operand OR ;
M: x86 %xor     int-rep two-operand XOR ;
M: x86 %xor-imm int-rep two-operand XOR ;
M: x86 %shl-imm int-rep two-operand SHL ;
M: x86 %shr-imm int-rep two-operand SHR ;
M: x86 %sar-imm int-rep two-operand SAR ;

M: x86 %min     int-rep two-operand [ CMP ] [ CMOVG ] 2bi ;
M: x86 %max     int-rep two-operand [ CMP ] [ CMOVL ] 2bi ;

M: x86 %not     int-rep one-operand NOT ;
M: x86 %neg     int-rep one-operand NEG ;
M: x86 %log2    BSR ;

! A bit of logic to avoid using MOVSS/MOVSD for reg-reg moves
! since this induces partial register stalls
GENERIC: copy-register* ( dst src rep -- )
GENERIC: copy-memory* ( dst src rep -- )

M: int-rep copy-register* drop MOV ;
M: tagged-rep copy-register* drop MOV ;
M: float-rep copy-register* drop MOVAPS ;
M: double-rep copy-register* drop MOVAPS ;
M: float-4-rep copy-register* drop MOVAPS ;
M: double-2-rep copy-register* drop MOVAPS ;
M: vector-rep copy-register* drop MOVDQA ;

M: object copy-memory* copy-register* ;
M: float-rep copy-memory* drop MOVSS ;
M: double-rep copy-memory* drop MOVSD ;

: ?spill-slot ( obj -- obj ) dup spill-slot? [ n>> spill@ ] when ;

M: x86 %copy ( dst src rep -- )
    2over eq? [ 3drop ] [
        [ [ ?spill-slot ] bi@ ] dip
        2over [ register? ] both? [ copy-register* ] [ copy-memory* ] if
    ] if ;

: fixnum-overflow ( label dst src1 src2 cc quot -- )
    swap [ [ int-rep two-operand ] dip call ] dip
    {
        { cc-o [ JO ] }
        { cc/o [ JNO ] }
    } case ; inline

M: x86 %fixnum-add ( label dst src1 src2 cc -- )
    [ ADD ] fixnum-overflow ;

M: x86 %fixnum-sub ( label dst src1 src2 cc -- )
    [ SUB ] fixnum-overflow ;

M: x86 %fixnum-mul ( label dst src1 src2 cc -- )
    [ IMUL2 ] fixnum-overflow ;

M: x86 %unbox-alien ( dst src -- )
    alien-offset [+] MOV ;

M:: x86 %unbox-any-c-ptr ( dst src -- )
    [
        "end" define-label
        dst dst XOR
        ! Is the object f?
        src \ f type-number CMP
        "end" get JE
        ! Compute tag in dst register
        dst src MOV
        dst tag-mask get AND
        ! Is the object an alien?
        dst alien type-number CMP
        ! Add an offset to start of byte array's data
        dst src byte-array-offset [+] LEA
        "end" get JNE
        ! If so, load the offset and add it to the address
        dst src alien-offset [+] MOV
        "end" resolve-label
    ] with-scope ;

: alien@ ( reg n -- op ) cells alien type-number - [+] ;

M:: x86 %box-alien ( dst src temp -- )
    [
        "end" define-label
        dst \ f type-number MOV
        src src TEST
        "end" get JE
        dst 5 cells alien temp %allot
        dst 1 alien@ \ f type-number MOV ! base
        dst 2 alien@ \ f type-number MOV ! expired
        dst 3 alien@ src MOV ! displacement
        dst 4 alien@ src MOV ! address
        "end" resolve-label
    ] with-scope ;

:: %box-displaced-alien/f ( dst displacement -- )
    dst 1 alien@ \ f type-number MOV
    dst 3 alien@ displacement MOV
    dst 4 alien@ displacement MOV ;

:: %box-displaced-alien/alien ( dst displacement base temp -- )
    ! Set new alien's base to base.base
    temp base 1 alien@ MOV
    dst 1 alien@ temp MOV

    ! Compute displacement
    temp base 3 alien@ MOV
    temp displacement ADD
    dst 3 alien@ temp MOV

    ! Compute address
    temp base 4 alien@ MOV
    temp displacement ADD
    dst 4 alien@ temp MOV ;

:: %box-displaced-alien/byte-array ( dst displacement base temp -- )
    dst 1 alien@ base MOV
    dst 3 alien@ displacement MOV
    temp base displacement byte-array-offset [++] LEA
    dst 4 alien@ temp MOV ;

:: %box-displaced-alien/dynamic ( dst displacement base temp -- )
    "not-f" define-label
    "not-alien" define-label

    ! Check base type
    temp base MOV
    temp tag-mask get AND

    ! Is base f?
    temp \ f type-number CMP
    "not-f" get JNE

    ! Yes, it is f. Fill in new object
    dst displacement %box-displaced-alien/f

    "end" get JMP

    "not-f" resolve-label

    ! Is base an alien?
    temp alien type-number CMP
    "not-alien" get JNE

    dst displacement base temp %box-displaced-alien/alien

    ! We are done
    "end" get JMP

    ! Is base a byte array? It has to be, by now...
    "not-alien" resolve-label

    dst displacement base temp %box-displaced-alien/byte-array ;

M:: x86 %box-displaced-alien ( dst displacement base temp base-class -- )
    [
        "end" define-label

        ! If displacement is zero, return the base
        dst base MOV
        displacement displacement TEST
        "end" get JE

        ! Displacement is non-zero, we're going to be allocating a new
        ! object
        dst 5 cells alien temp %allot

        ! Set expired to f
        dst 2 alien@ \ f type-number MOV

        dst displacement base temp
        {
            { [ base-class \ f class<= ] [ 2drop %box-displaced-alien/f ] }
            { [ base-class \ alien class<= ] [ %box-displaced-alien/alien ] }
            { [ base-class \ byte-array class<= ] [ %box-displaced-alien/byte-array ] }
            [ %box-displaced-alien/dynamic ]
        } cond

        "end" resolve-label
    ] with-scope ;

! The 'small-reg' mess is pretty crappy, but its only used on x86-32.
! On x86-64, all registers have 8-bit versions. However, a similar
! problem arises for shifts, where the shift count must be in CL, and
! so one day I will fix this properly by adding precoloring to the
! register allocator.

HOOK: has-small-reg? cpu ( reg size -- ? )

CONSTANT: have-byte-regs { EAX ECX EDX EBX }

M: x86.32 has-small-reg?
    {
        { 8 [ have-byte-regs member-eq? ] }
        { 16 [ drop t ] }
        { 32 [ drop t ] }
    } case ;

M: x86.64 has-small-reg? 2drop t ;

: small-reg-that-isn't ( exclude -- reg' )
    [ have-byte-regs ] dip
    [ native-version-of ] map
    '[ _ member-eq? not ] find nip ;

: with-save/restore ( reg quot -- )
    [ drop PUSH ] [ call ] [ drop POP ] 2tri ; inline

:: with-small-register ( dst exclude size quot: ( new-dst -- ) -- )
    ! If the destination register overlaps a small register with
    ! 'size' bits, we call the quot with that. Otherwise, we find a
    ! small register that is not in exclude, and call quot, saving and
    ! restoring the small register.
    dst size has-small-reg? [ dst quot call ] [
        exclude small-reg-that-isn't
        [ quot call ] with-save/restore
    ] if ; inline

:: %alien-integer-getter ( dst exclude address bits quot -- )
    dst exclude bits [| new-dst |
        new-dst dup bits n-bit-version-of dup address MOV
        quot call
        dst new-dst int-rep %copy
    ] with-small-register ; inline

: %alien-unsigned-getter ( dst exclude address bits -- )
    [ MOVZX ] %alien-integer-getter ; inline

: %alien-signed-getter ( dst exclude address bits -- )
    [ MOVSX ] %alien-integer-getter ; inline

:: %alien-integer-setter ( value exclude address bits -- )
    value exclude bits [| new-value |
        new-value value int-rep %copy
        address new-value bits n-bit-version-of MOV
    ] with-small-register ; inline

: (%memory) ( base displacement scale offset rep c-type -- exclude address rep c-type )
    [ [ [ 2array ] 2keep ] 2dip <indirect> ] 2dip ;

: (%memory-imm) ( base offset rep c-type -- exclude address rep c-type )
    [ [ drop 1array ] [ [+] ] 2bi ] 2dip ;

: (%load-memory) ( dst exclude address rep c-type -- )
    [
        {
            { c:char   [ 8 %alien-signed-getter ] }
            { c:uchar  [ 8 %alien-unsigned-getter ] }
            { c:short  [ 16 %alien-signed-getter ] }
            { c:ushort [ 16 %alien-unsigned-getter ] }
            { c:int    [ 32 %alien-signed-getter ] }
            { c:uint   [ 32 [ 2drop ] %alien-integer-getter ] }
        } case
    ] [ [ drop ] 2dip %copy ] ?if ;

M: x86 %load-memory ( dst base displacement scale offset rep c-type -- )
    (%memory) (%load-memory) ;

M: x86 %load-memory-imm ( dst base offset rep c-type -- )
    (%memory-imm) (%load-memory) ;

: (%store-memory) ( src exclude address rep c-type -- )
    [
        {
            { c:char   [ 8 %alien-integer-setter ] }
            { c:uchar  [ 8 %alien-integer-setter ] }
            { c:short  [ 16 %alien-integer-setter ] }
            { c:ushort [ 16 %alien-integer-setter ] }
            { c:int    [ 32 %alien-integer-setter ] }
            { c:uint   [ 32 %alien-integer-setter ] }
        } case
    ] [ [ nip swap ] dip %copy ] ?if ;

M: x86 %store-memory ( src base displacement scale offset rep c-type -- )
    (%memory) (%store-memory) ;

M: x86 %store-memory-imm ( src base offset rep c-type -- )
    (%memory-imm) (%store-memory) ;

: shift-count? ( reg -- ? ) { ECX RCX } member-eq? ;

:: emit-shift ( dst src quot -- )
    src shift-count? [
        dst CL quot call
    ] [
        dst shift-count? [
            dst src XCHG
            src CL quot call
            dst src XCHG
        ] [
            ECX native-version-of [
                CL src MOV
                drop dst CL quot call
            ] with-save/restore
        ] if
    ] if ; inline

M: x86 %shl int-rep two-operand [ SHL ] emit-shift ;
M: x86 %shr int-rep two-operand [ SHR ] emit-shift ;
M: x86 %sar int-rep two-operand [ SAR ] emit-shift ;

HOOK: %mov-vm-ptr cpu ( reg -- )

HOOK: %vm-field-ptr cpu ( reg offset -- )

: load-zone-offset ( nursery-ptr -- )
    "nursery" vm-field-offset %vm-field-ptr ;

: load-allot-ptr ( nursery-ptr allot-ptr -- )
    [ drop load-zone-offset ] [ swap [] MOV ] 2bi ;

: inc-allot-ptr ( nursery-ptr n -- )
    [ [] ] dip data-alignment get align ADD ;

: store-header ( temp class -- )
    [ [] ] [ type-number tag-header ] bi* MOV ;

: store-tagged ( dst tag -- )
    type-number OR ;

M:: x86 %allot ( dst size class nursery-ptr -- )
    nursery-ptr dst load-allot-ptr
    dst class store-header
    dst class store-tagged
    nursery-ptr size inc-allot-ptr ;

HOOK: %mark-card cpu ( card temp -- )
HOOK: %mark-deck cpu ( card temp -- )

:: (%write-barrier) ( temp1 temp2 -- )
    temp1 card-bits SHR
    temp1 temp2 %mark-card
    temp1 deck-bits card-bits - SHR
    temp1 temp2 %mark-deck ;

M:: x86 %write-barrier ( src slot scale tag temp1 temp2 -- )
    temp1 src slot scale tag (%slot) LEA
    temp1 temp2 (%write-barrier) ;

M:: x86 %write-barrier-imm ( src slot tag temp1 temp2 -- )
    temp1 src slot tag (%slot-imm) LEA
    temp1 temp2 (%write-barrier) ;

M:: x86 %check-nursery-branch ( label size cc temp1 temp2 -- )
    temp1 load-zone-offset
    temp2 temp1 [] MOV
    temp2 size ADD
    temp2 temp1 2 cells [+] CMP
    cc {
        { cc<= [ label JLE ] }
        { cc/<= [ label JG ] }
    } case ;

M: x86 %alien-global ( dst symbol library -- )
    [ 0 MOV ] 2dip rc-absolute-cell rel-dlsym ;    

M: x86 %epilogue ( n -- ) cell - incr-stack-reg ;

:: (%boolean) ( dst temp insn -- )
    dst \ f type-number MOV
    temp 0 MOV \ t rc-absolute-cell rel-literal
    dst temp insn execute ; inline

: %boolean ( dst cc temp -- )
    swap order-cc {
        { cc<  [ \ CMOVL (%boolean) ] }
        { cc<= [ \ CMOVLE (%boolean) ] }
        { cc>  [ \ CMOVG (%boolean) ] }
        { cc>= [ \ CMOVGE (%boolean) ] }
        { cc=  [ \ CMOVE (%boolean) ] }
        { cc/= [ \ CMOVNE (%boolean) ] }
    } case ;

M:: x86 %compare ( dst src1 src2 cc temp -- )
    src1 src2 CMP
    dst cc temp %boolean ;

M:: x86 %test ( dst src1 src2 cc temp -- )
    src1 src2 TEST
    dst cc temp %boolean ;

: (%compare-tagged) ( src1 src2 -- )
    [ HEX: ffffffff CMP ] dip rc-absolute rel-literal ;

M:: x86 %compare-integer-imm ( dst src1 src2 cc temp -- )
    src1 src2 CMP
    dst cc temp %boolean ;

M:: x86 %test-imm ( dst src1 src2 cc temp -- )
    src1 src2 TEST
    dst cc temp %boolean ;

: (%compare-imm) ( src1 src2 -- )
    {
        { [ dup fixnum? ] [ tag-fixnum CMP ] }
        { [ dup not ] [ drop \ f type-number CMP ] }
        [ (%compare-tagged) ]
    } cond ;

M:: x86 %compare-imm ( dst src1 src2 cc temp -- )
    src1 src2 (%compare-imm)
    dst cc temp %boolean ;

: %branch ( label cc -- )
    order-cc {
        { cc<  [ JL ] }
        { cc<= [ JLE ] }
        { cc>  [ JG ] }
        { cc>= [ JGE ] }
        { cc=  [ JE ] }
        { cc/= [ JNE ] }
    } case ;

M:: x86 %compare-branch ( label src1 src2 cc -- )
    src1 src2 CMP
    label cc %branch ;

M:: x86 %compare-integer-imm-branch ( label src1 src2 cc -- )
    src1 src2 CMP
    label cc %branch ;

M:: x86 %test-branch ( label src1 src2 cc -- )
    src1 src2 TEST
    label cc %branch ;

M:: x86 %test-imm-branch ( label src1 src2 cc -- )
    src1 src2 TEST
    label cc %branch ;

M:: x86 %compare-imm-branch ( label src1 src2 cc -- )
    src1 src2 (%compare-imm)
    label cc %branch ;

M: x86 %add-float double-rep two-operand ADDSD ;
M: x86 %sub-float double-rep two-operand SUBSD ;
M: x86 %mul-float double-rep two-operand MULSD ;
M: x86 %div-float double-rep two-operand DIVSD ;
M: x86 %min-float double-rep two-operand MINSD ;
M: x86 %max-float double-rep two-operand MAXSD ;
M: x86 %sqrt SQRTSD ;

: %clear-unless-in-place ( dst src -- )
    over = [ drop ] [ dup XORPS ] if ;

M: x86 %single>double-float [ %clear-unless-in-place ] [ CVTSS2SD ] 2bi ;
M: x86 %double>single-float [ %clear-unless-in-place ] [ CVTSD2SS ] 2bi ;

M: x86 %integer>float [ drop dup XORPS ] [ CVTSI2SD ] 2bi ;
M: x86 %float>integer CVTTSD2SI ;

: %cmov-float= ( dst src -- )
    [
        "no-move" define-label

        "no-move" get [ JNE ] [ JP ] bi
        MOV
        "no-move" resolve-label
    ] with-scope ;

: %cmov-float/= ( dst src -- )
    [
        "no-move" define-label
        "move" define-label

        "move" get JP
        "no-move" get JE
        "move" resolve-label
        MOV
        "no-move" resolve-label
    ] with-scope ;

:: (%compare-float) ( dst src1 src2 cc temp compare -- )
    cc {
        { cc<    [ src2 src1 \ compare execute( a b -- ) dst temp \ CMOVA  (%boolean) ] }
        { cc<=   [ src2 src1 \ compare execute( a b -- ) dst temp \ CMOVAE (%boolean) ] }
        { cc>    [ src1 src2 \ compare execute( a b -- ) dst temp \ CMOVA  (%boolean) ] }
        { cc>=   [ src1 src2 \ compare execute( a b -- ) dst temp \ CMOVAE (%boolean) ] }
        { cc=    [ src1 src2 \ compare execute( a b -- ) dst temp \ %cmov-float= (%boolean) ] }
        { cc<>   [ src1 src2 \ compare execute( a b -- ) dst temp \ CMOVNE (%boolean) ] }
        { cc<>=  [ src1 src2 \ compare execute( a b -- ) dst temp \ CMOVNP (%boolean) ] }
        { cc/<   [ src2 src1 \ compare execute( a b -- ) dst temp \ CMOVBE (%boolean) ] }
        { cc/<=  [ src2 src1 \ compare execute( a b -- ) dst temp \ CMOVB  (%boolean) ] }
        { cc/>   [ src1 src2 \ compare execute( a b -- ) dst temp \ CMOVBE (%boolean) ] }
        { cc/>=  [ src1 src2 \ compare execute( a b -- ) dst temp \ CMOVB  (%boolean) ] }
        { cc/=   [ src1 src2 \ compare execute( a b -- ) dst temp \ %cmov-float/= (%boolean) ] }
        { cc/<>  [ src1 src2 \ compare execute( a b -- ) dst temp \ CMOVE  (%boolean) ] }
        { cc/<>= [ src1 src2 \ compare execute( a b -- ) dst temp \ CMOVP  (%boolean) ] }
    } case ; inline

M: x86 %compare-float-ordered ( dst src1 src2 cc temp -- )
    \ COMISD (%compare-float) ;

M: x86 %compare-float-unordered ( dst src1 src2 cc temp -- )
    \ UCOMISD (%compare-float) ;

: %jump-float= ( label -- )
    [
        "no-jump" define-label
        "no-jump" get JP
        JE
        "no-jump" resolve-label
    ] with-scope ;

: %jump-float/= ( label -- )
    [ JNE ] [ JP ] bi ;

:: (%compare-float-branch) ( label src1 src2 cc compare -- )
    cc {
        { cc<    [ src2 src1 \ compare execute( a b -- ) label JA  ] }
        { cc<=   [ src2 src1 \ compare execute( a b -- ) label JAE ] }
        { cc>    [ src1 src2 \ compare execute( a b -- ) label JA  ] }
        { cc>=   [ src1 src2 \ compare execute( a b -- ) label JAE ] }
        { cc=    [ src1 src2 \ compare execute( a b -- ) label %jump-float= ] }
        { cc<>   [ src1 src2 \ compare execute( a b -- ) label JNE ] }
        { cc<>=  [ src1 src2 \ compare execute( a b -- ) label JNP ] }
        { cc/<   [ src2 src1 \ compare execute( a b -- ) label JBE ] }
        { cc/<=  [ src2 src1 \ compare execute( a b -- ) label JB  ] }
        { cc/>   [ src1 src2 \ compare execute( a b -- ) label JBE ] }
        { cc/>=  [ src1 src2 \ compare execute( a b -- ) label JB  ] }
        { cc/=   [ src1 src2 \ compare execute( a b -- ) label %jump-float/= ] }
        { cc/<>  [ src1 src2 \ compare execute( a b -- ) label JE  ] }
        { cc/<>= [ src1 src2 \ compare execute( a b -- ) label JP  ] }
    } case ;

M: x86 %compare-float-ordered-branch ( label src1 src2 cc -- )
    \ COMISD (%compare-float-branch) ;

M: x86 %compare-float-unordered-branch ( label src1 src2 cc -- )
    \ UCOMISD (%compare-float-branch) ;

MACRO: available-reps ( alist -- )
    ! Each SSE version adds new representations and supports
    ! all old ones
    unzip { } [ append ] accumulate rest swap suffix
    [ [ 1quotation ] map ] bi@ zip
    reverse [ { } ] suffix
    '[ _ cond ] ;

M: x86 %alien-vector-reps
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep char-16-rep uchar-16-rep short-8-rep ushort-8-rep int-4-rep uint-4-rep longlong-2-rep ulonglong-2-rep } }
    } available-reps ;

M: x86 %zero-vector
    {
        { double-2-rep [ dup XORPS ] }
        { float-4-rep [ dup XORPS ] }
        [ drop dup PXOR ]
    } case ;

M: x86 %zero-vector-reps
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep char-16-rep uchar-16-rep short-8-rep ushort-8-rep int-4-rep uint-4-rep longlong-2-rep ulonglong-2-rep } }
    } available-reps ;

M: x86 %fill-vector
    {
        { double-2-rep [ dup [ XORPS ] [ CMPEQPS ] 2bi ] }
        { float-4-rep  [ dup [ XORPS ] [ CMPEQPS ] 2bi ] }
        [ drop dup PCMPEQB ]
    } case ;

M: x86 %fill-vector-reps
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep char-16-rep uchar-16-rep short-8-rep ushort-8-rep int-4-rep uint-4-rep longlong-2-rep ulonglong-2-rep } }
    } available-reps ;

M:: x86 %gather-vector-4 ( dst src1 src2 src3 src4 rep -- )
    rep signed-rep {
        { float-4-rep [
            dst src1 float-4-rep %copy
            dst src2 UNPCKLPS
            src3 src4 UNPCKLPS
            dst src3 MOVLHPS
        ] }
        { int-4-rep [
            dst src1 int-4-rep %copy
            dst src2 PUNPCKLDQ
            src3 src4 PUNPCKLDQ
            dst src3 PUNPCKLQDQ
        ] }
    } case ;

M: x86 %gather-vector-4-reps
    {
        ! Can't do this with sse1 since it will want to unbox
        ! double-precision floats and convert to single precision
        { sse2? { float-4-rep int-4-rep uint-4-rep } }
    } available-reps ;

M:: x86 %gather-vector-2 ( dst src1 src2 rep -- )
    rep signed-rep {
        { double-2-rep [
            dst src1 double-2-rep %copy
            dst src2 MOVLHPS
        ] }
        { longlong-2-rep [
            dst src1 longlong-2-rep %copy
            dst src2 PUNPCKLQDQ
        ] }
    } case ;

M: x86 %gather-vector-2-reps
    {
        { sse2? { double-2-rep longlong-2-rep ulonglong-2-rep } }
    } available-reps ;

: sse1-float-4-shuffle ( dst shuffle -- )
    {
        { { 0 1 2 3 } [ drop ] }
        { { 0 1 0 1 } [ dup MOVLHPS ] }
        { { 2 3 2 3 } [ dup MOVHLPS ] }
        { { 0 0 1 1 } [ dup UNPCKLPS ] }
        { { 2 2 3 3 } [ dup UNPCKHPS ] }
        [ dupd SHUFPS ]
    } case ;

: float-4-shuffle ( dst shuffle -- )
    sse3? [
        {
            { { 0 0 2 2 } [ dup MOVSLDUP ] }
            { { 1 1 3 3 } [ dup MOVSHDUP ] }
            [ sse1-float-4-shuffle ]
        } case
    ] [ sse1-float-4-shuffle ] if ;

: int-4-shuffle ( dst shuffle -- )
    {
        { { 0 1 2 3 } [ drop ] }
        { { 0 0 1 1 } [ dup PUNPCKLDQ ] }
        { { 2 2 3 3 } [ dup PUNPCKHDQ ] }
        { { 0 1 0 1 } [ dup PUNPCKLQDQ ] }
        { { 2 3 2 3 } [ dup PUNPCKHQDQ ] }
        [ dupd PSHUFD ]
    } case ;

: longlong-2-shuffle ( dst shuffle -- )
    first2 [ 2 * dup 1 + ] bi@ 4array int-4-shuffle ;

: >float-4-shuffle ( double-2-shuffle -- float-4-shuffle )
    [ 2 * { 0 1 } n+v ] map concat ;

M:: x86 %shuffle-vector-imm ( dst src shuffle rep -- )
    dst src rep %copy
    dst shuffle rep signed-rep {
        { double-2-rep [ >float-4-shuffle float-4-shuffle ] }
        { float-4-rep [ float-4-shuffle ] }
        { int-4-rep [ int-4-shuffle ] }
        { longlong-2-rep [ longlong-2-shuffle ] }
    } case ;

M: x86 %shuffle-vector-imm-reps
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep int-4-rep uint-4-rep longlong-2-rep ulonglong-2-rep } }
    } available-reps ;

M:: x86 %shuffle-vector-halves-imm ( dst src1 src2 shuffle rep -- )
    dst src1 src2 rep two-operand
    shuffle rep {
        { double-2-rep [ >float-4-shuffle SHUFPS ] }
        { float-4-rep [ SHUFPS ] }
    } case ;

M: x86 %shuffle-vector-halves-imm-reps
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep } }
    } available-reps ;

M: x86 %shuffle-vector ( dst src shuffle rep -- )
    two-operand PSHUFB ;

M: x86 %shuffle-vector-reps
    {
        { ssse3? { float-4-rep double-2-rep longlong-2-rep ulonglong-2-rep int-4-rep uint-4-rep short-8-rep ushort-8-rep char-16-rep uchar-16-rep } }
    } available-reps ;

M: x86 %merge-vector-head
    [ two-operand ] keep
    signed-rep {
        { double-2-rep   [ MOVLHPS ] }
        { float-4-rep    [ UNPCKLPS ] }
        { longlong-2-rep [ PUNPCKLQDQ ] }
        { int-4-rep      [ PUNPCKLDQ ] }
        { short-8-rep    [ PUNPCKLWD ] }
        { char-16-rep    [ PUNPCKLBW ] }
    } case ;

M: x86 %merge-vector-tail
    [ two-operand ] keep
    signed-rep {
        { double-2-rep   [ UNPCKHPD ] }
        { float-4-rep    [ UNPCKHPS ] }
        { longlong-2-rep [ PUNPCKHQDQ ] }
        { int-4-rep      [ PUNPCKHDQ ] }
        { short-8-rep    [ PUNPCKHWD ] }
        { char-16-rep    [ PUNPCKHBW ] }
    } case ;

M: x86 %merge-vector-reps
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep char-16-rep uchar-16-rep short-8-rep ushort-8-rep int-4-rep uint-4-rep longlong-2-rep ulonglong-2-rep } }
    } available-reps ;

M: x86 %signed-pack-vector
    [ two-operand ] keep
    {
        { int-4-rep    [ PACKSSDW ] }
        { short-8-rep  [ PACKSSWB ] }
    } case ;

M: x86 %signed-pack-vector-reps
    {
        { sse2? { short-8-rep int-4-rep } }
    } available-reps ;

M: x86 %unsigned-pack-vector
    [ two-operand ] keep
    signed-rep {
        { int-4-rep   [ PACKUSDW ] }
        { short-8-rep [ PACKUSWB ] }
    } case ;

M: x86 %unsigned-pack-vector-reps
    {
        { sse2? { short-8-rep } }
        { sse4.1? { int-4-rep } }
    } available-reps ;

M: x86 %tail>head-vector ( dst src rep -- )
    dup {
        { float-4-rep [ drop UNPCKHPD ] }
        { double-2-rep [ drop UNPCKHPD ] }
        [ drop [ %copy ] [ drop PUNPCKHQDQ ] 3bi ]
    } case ;

M: x86 %unpack-vector-head ( dst src rep -- )
    {
        { char-16-rep  [ PMOVSXBW ] }
        { uchar-16-rep [ PMOVZXBW ] }
        { short-8-rep  [ PMOVSXWD ] }
        { ushort-8-rep [ PMOVZXWD ] }
        { int-4-rep    [ PMOVSXDQ ] }
        { uint-4-rep   [ PMOVZXDQ ] }
        { float-4-rep  [ CVTPS2PD ] }
    } case ;

M: x86 %unpack-vector-head-reps ( -- reps )
    {
        { sse2? { float-4-rep } }
        { sse4.1? { char-16-rep uchar-16-rep short-8-rep ushort-8-rep int-4-rep uint-4-rep } }
    } available-reps ;

M: x86 %integer>float-vector ( dst src rep -- )
    {
        { int-4-rep [ CVTDQ2PS ] }
    } case ;

M: x86 %integer>float-vector-reps
    {
        { sse2? { int-4-rep } }
    } available-reps ;

M: x86 %float>integer-vector ( dst src rep -- )
    {
        { float-4-rep [ CVTTPS2DQ ] }
    } case ;

M: x86 %float>integer-vector-reps
    {
        { sse2? { float-4-rep } }
    } available-reps ;

: (%compare-float-vector) ( dst src rep double single -- )
    [ double-2-rep eq? ] 2dip if ; inline

: %compare-float-vector ( dst src rep cc -- )
    {
        { cc<    [ [ CMPLTPD    ] [ CMPLTPS    ] (%compare-float-vector) ] }
        { cc<=   [ [ CMPLEPD    ] [ CMPLEPS    ] (%compare-float-vector) ] }
        { cc=    [ [ CMPEQPD    ] [ CMPEQPS    ] (%compare-float-vector) ] }
        { cc<>=  [ [ CMPORDPD   ] [ CMPORDPS   ] (%compare-float-vector) ] }
        { cc/<   [ [ CMPNLTPD   ] [ CMPNLTPS   ] (%compare-float-vector) ] }
        { cc/<=  [ [ CMPNLEPD   ] [ CMPNLEPS   ] (%compare-float-vector) ] }
        { cc/=   [ [ CMPNEQPD   ] [ CMPNEQPS   ] (%compare-float-vector) ] }
        { cc/<>= [ [ CMPUNORDPD ] [ CMPUNORDPS ] (%compare-float-vector) ] }
    } case ;

:: (%compare-int-vector) ( dst src rep int64 int32 int16 int8 -- )
    rep signed-rep :> rep'
    dst src rep' {
        { longlong-2-rep [ int64 call ] }
        { int-4-rep      [ int32 call ] }
        { short-8-rep    [ int16 call ] }
        { char-16-rep    [ int8  call ] }
    } case ; inline

: %compare-int-vector ( dst src rep cc -- )
    {
        { cc= [ [ PCMPEQQ ] [ PCMPEQD ] [ PCMPEQW ] [ PCMPEQB ] (%compare-int-vector) ] }
        { cc> [ [ PCMPGTQ ] [ PCMPGTD ] [ PCMPGTW ] [ PCMPGTB ] (%compare-int-vector) ] }
    } case ;

M: x86 %compare-vector ( dst src1 src2 rep cc -- )
    [ [ two-operand ] keep ] dip
    over float-vector-rep?
    [ %compare-float-vector ]
    [ %compare-int-vector ] if ;

: %compare-vector-eq-reps ( -- reps )
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep char-16-rep uchar-16-rep short-8-rep ushort-8-rep int-4-rep uint-4-rep } }
        { sse4.1? { longlong-2-rep ulonglong-2-rep } }
    } available-reps ;

: %compare-vector-ord-reps ( -- reps )
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep char-16-rep short-8-rep int-4-rep } }
        { sse4.2? { longlong-2-rep } }
    } available-reps ;

M: x86 %compare-vector-reps
    {
        { [ dup { cc= cc/= cc/<>= cc<>= } member-eq? ] [ drop %compare-vector-eq-reps ] }
        [ drop %compare-vector-ord-reps ]
    } cond ;

: %compare-float-vector-ccs ( cc -- ccs not? )
    {
        { cc<    [ { { cc<  f   }              } f ] }
        { cc<=   [ { { cc<= f   }              } f ] }
        { cc>    [ { { cc<  t   }              } f ] }
        { cc>=   [ { { cc<= t   }              } f ] }
        { cc=    [ { { cc=  f   }              } f ] }
        { cc<>   [ { { cc<  f   } { cc<    t } } f ] }
        { cc<>=  [ { { cc<>= f  }              } f ] }
        { cc/<   [ { { cc/<  f  }              } f ] }
        { cc/<=  [ { { cc/<= f  }              } f ] }
        { cc/>   [ { { cc/<  t  }              } f ] }
        { cc/>=  [ { { cc/<= t  }              } f ] }
        { cc/=   [ { { cc/=  f  }              } f ] }
        { cc/<>  [ { { cc/=  f  } { cc/<>= f } } f ] }
        { cc/<>= [ { { cc/<>= f }              } f ] }
    } case ;

: %compare-int-vector-ccs ( cc -- ccs not? )
    order-cc {
        { cc<    [ { { cc> t } } f ] }
        { cc<=   [ { { cc> f } } t ] }
        { cc>    [ { { cc> f } } f ] }
        { cc>=   [ { { cc> t } } t ] }
        { cc=    [ { { cc= f } } f ] }
        { cc/=   [ { { cc= f } } t ] }
        { t      [ {           } t ] }
        { f      [ {           } f ] }
    } case ;

M: x86 %compare-vector-ccs
    swap float-vector-rep?
    [ %compare-float-vector-ccs ]
    [ %compare-int-vector-ccs ] if ;

:: %test-vector-mask ( dst temp mask vcc -- )
    vcc {
        { vcc-any    [ dst dst TEST dst temp \ CMOVNE (%boolean) ] }
        { vcc-none   [ dst dst TEST dst temp \ CMOVE  (%boolean) ] }
        { vcc-all    [ dst mask CMP dst temp \ CMOVE  (%boolean) ] }
        { vcc-notall [ dst mask CMP dst temp \ CMOVNE (%boolean) ] }
    } case ;

: %move-vector-mask ( dst src rep -- mask )
    {
        { double-2-rep [ MOVMSKPS HEX: f ] }
        { float-4-rep  [ MOVMSKPS HEX: f ] }
        [ drop PMOVMSKB HEX: ffff ]
    } case ;

M:: x86 %test-vector ( dst src temp rep vcc -- )
    dst src rep %move-vector-mask :> mask
    dst temp mask vcc %test-vector-mask ;

:: %test-vector-mask-branch ( label temp mask vcc -- )
    vcc {
        { vcc-any    [ temp temp TEST label JNE ] }
        { vcc-none   [ temp temp TEST label JE ] }
        { vcc-all    [ temp mask CMP label JE ] }
        { vcc-notall [ temp mask CMP label JNE ] }
    } case ;

M:: x86 %test-vector-branch ( label src temp rep vcc -- )
    temp src rep %move-vector-mask :> mask
    label temp mask vcc %test-vector-mask-branch ;

M: x86 %test-vector-reps
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep char-16-rep uchar-16-rep short-8-rep ushort-8-rep int-4-rep uint-4-rep longlong-2-rep ulonglong-2-rep } }
    } available-reps ;

M: x86 %add-vector ( dst src1 src2 rep -- )
    [ two-operand ] keep
    {
        { float-4-rep [ ADDPS ] }
        { double-2-rep [ ADDPD ] }
        { char-16-rep [ PADDB ] }
        { uchar-16-rep [ PADDB ] }
        { short-8-rep [ PADDW ] }
        { ushort-8-rep [ PADDW ] }
        { int-4-rep [ PADDD ] }
        { uint-4-rep [ PADDD ] }
        { longlong-2-rep [ PADDQ ] }
        { ulonglong-2-rep [ PADDQ ] }
    } case ;

M: x86 %add-vector-reps
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep char-16-rep uchar-16-rep short-8-rep ushort-8-rep int-4-rep uint-4-rep longlong-2-rep ulonglong-2-rep } }
    } available-reps ;

M: x86 %saturated-add-vector ( dst src1 src2 rep -- )
    [ two-operand ] keep
    {
        { char-16-rep [ PADDSB ] }
        { uchar-16-rep [ PADDUSB ] }
        { short-8-rep [ PADDSW ] }
        { ushort-8-rep [ PADDUSW ] }
    } case ;

M: x86 %saturated-add-vector-reps
    {
        { sse2? { char-16-rep uchar-16-rep short-8-rep ushort-8-rep } }
    } available-reps ;

M: x86 %add-sub-vector ( dst src1 src2 rep -- )
    [ two-operand ] keep
    {
        { float-4-rep [ ADDSUBPS ] }
        { double-2-rep [ ADDSUBPD ] }
    } case ;

M: x86 %add-sub-vector-reps
    {
        { sse3? { float-4-rep double-2-rep } }
    } available-reps ;

M: x86 %sub-vector ( dst src1 src2 rep -- )
    [ two-operand ] keep
    {
        { float-4-rep [ SUBPS ] }
        { double-2-rep [ SUBPD ] }
        { char-16-rep [ PSUBB ] }
        { uchar-16-rep [ PSUBB ] }
        { short-8-rep [ PSUBW ] }
        { ushort-8-rep [ PSUBW ] }
        { int-4-rep [ PSUBD ] }
        { uint-4-rep [ PSUBD ] }
        { longlong-2-rep [ PSUBQ ] }
        { ulonglong-2-rep [ PSUBQ ] }
    } case ;

M: x86 %sub-vector-reps
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep char-16-rep uchar-16-rep short-8-rep ushort-8-rep int-4-rep uint-4-rep longlong-2-rep ulonglong-2-rep } }
    } available-reps ;

M: x86 %saturated-sub-vector ( dst src1 src2 rep -- )
    [ two-operand ] keep
    {
        { char-16-rep [ PSUBSB ] }
        { uchar-16-rep [ PSUBUSB ] }
        { short-8-rep [ PSUBSW ] }
        { ushort-8-rep [ PSUBUSW ] }
    } case ;

M: x86 %saturated-sub-vector-reps
    {
        { sse2? { char-16-rep uchar-16-rep short-8-rep ushort-8-rep } }
    } available-reps ;

M: x86 %mul-vector ( dst src1 src2 rep -- )
    [ two-operand ] keep
    {
        { float-4-rep [ MULPS ] }
        { double-2-rep [ MULPD ] }
        { short-8-rep [ PMULLW ] }
        { ushort-8-rep [ PMULLW ] }
        { int-4-rep [ PMULLD ] }
        { uint-4-rep [ PMULLD ] }
    } case ;

M: x86 %mul-vector-reps
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep short-8-rep ushort-8-rep } }
        { sse4.1? { int-4-rep uint-4-rep } }
    } available-reps ;

M: x86 %mul-high-vector ( dst src1 src2 rep -- )
    [ two-operand ] keep
    {
        { short-8-rep  [ PMULHW ] }
        { ushort-8-rep [ PMULHUW ] }
    } case ;

M: x86 %mul-high-vector-reps
    {
        { sse2? { short-8-rep ushort-8-rep } }
    } available-reps ;

M: x86 %mul-horizontal-add-vector ( dst src1 src2 rep -- )
    [ two-operand ] keep
    {
        { char-16-rep  [ PMADDUBSW ] }
        { uchar-16-rep [ PMADDUBSW ] }
        { short-8-rep  [ PMADDWD ] }
    } case ;

M: x86 %mul-horizontal-add-vector-reps
    {
        { sse2?  { short-8-rep } }
        { ssse3? { char-16-rep uchar-16-rep } }
    } available-reps ;

M: x86 %div-vector ( dst src1 src2 rep -- )
    [ two-operand ] keep
    {
        { float-4-rep [ DIVPS ] }
        { double-2-rep [ DIVPD ] }
    } case ;

M: x86 %div-vector-reps
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep } }
    } available-reps ;

M: x86 %min-vector ( dst src1 src2 rep -- )
    [ two-operand ] keep
    {
        { char-16-rep [ PMINSB ] }
        { uchar-16-rep [ PMINUB ] }
        { short-8-rep [ PMINSW ] }
        { ushort-8-rep [ PMINUW ] }
        { int-4-rep [ PMINSD ] }
        { uint-4-rep [ PMINUD ] }
        { float-4-rep [ MINPS ] }
        { double-2-rep [ MINPD ] }
    } case ;

M: x86 %min-vector-reps
    {
        { sse? { float-4-rep } }
        { sse2? { uchar-16-rep short-8-rep double-2-rep } }
        { sse4.1? { char-16-rep ushort-8-rep int-4-rep uint-4-rep } }
    } available-reps ;

M: x86 %max-vector ( dst src1 src2 rep -- )
    [ two-operand ] keep
    {
        { char-16-rep [ PMAXSB ] }
        { uchar-16-rep [ PMAXUB ] }
        { short-8-rep [ PMAXSW ] }
        { ushort-8-rep [ PMAXUW ] }
        { int-4-rep [ PMAXSD ] }
        { uint-4-rep [ PMAXUD ] }
        { float-4-rep [ MAXPS ] }
        { double-2-rep [ MAXPD ] }
    } case ;

M: x86 %max-vector-reps
    {
        { sse? { float-4-rep } }
        { sse2? { uchar-16-rep short-8-rep double-2-rep } }
        { sse4.1? { char-16-rep ushort-8-rep int-4-rep uint-4-rep } }
    } available-reps ;

M: x86 %avg-vector ( dst src1 src2 rep -- )
    [ two-operand ] keep
    {
        { uchar-16-rep [ PAVGB ] }
        { ushort-8-rep [ PAVGW ] }
    } case ;

M: x86 %avg-vector-reps
    {
        { sse2? { uchar-16-rep ushort-8-rep } }
    } available-reps ;

M: x86 %dot-vector
    [ two-operand ] keep
    {
        { float-4-rep [ HEX: ff DPPS ] }
        { double-2-rep [ HEX: ff DPPD ] }
    } case ;

M: x86 %dot-vector-reps
    {
        { sse4.1? { float-4-rep double-2-rep } }
    } available-reps ;

M: x86 %sad-vector
    [ two-operand ] keep
    {
        { uchar-16-rep [ PSADBW ] }
    } case ;

M: x86 %sad-vector-reps
    {
        { sse2? { uchar-16-rep } }
    } available-reps ;

M: x86 %horizontal-add-vector ( dst src1 src2 rep -- )
    [ two-operand ] keep
    signed-rep {
        { float-4-rep  [ HADDPS ] }
        { double-2-rep [ HADDPD ] }
        { int-4-rep    [ PHADDD ] }
        { short-8-rep  [ PHADDW ] }
    } case ;

M: x86 %horizontal-add-vector-reps
    {
        { sse3? { float-4-rep double-2-rep } }
        { ssse3? { int-4-rep uint-4-rep short-8-rep ushort-8-rep } }
    } available-reps ;

M: x86 %horizontal-shl-vector-imm ( dst src1 src2 rep -- )
    two-operand PSLLDQ ;

M: x86 %horizontal-shl-vector-imm-reps
    {
        { sse2? { char-16-rep uchar-16-rep short-8-rep ushort-8-rep int-4-rep uint-4-rep longlong-2-rep ulonglong-2-rep float-4-rep double-2-rep } }
    } available-reps ;

M: x86 %horizontal-shr-vector-imm ( dst src1 src2 rep -- )
    two-operand PSRLDQ ;

M: x86 %horizontal-shr-vector-imm-reps
    {
        { sse2? { char-16-rep uchar-16-rep short-8-rep ushort-8-rep int-4-rep uint-4-rep longlong-2-rep ulonglong-2-rep float-4-rep double-2-rep } }
    } available-reps ;

M: x86 %abs-vector ( dst src rep -- )
    {
        { char-16-rep [ PABSB ] }
        { short-8-rep [ PABSW ] }
        { int-4-rep [ PABSD ] }
    } case ;

M: x86 %abs-vector-reps
    {
        { ssse3? { char-16-rep short-8-rep int-4-rep } }
    } available-reps ;

M: x86 %sqrt-vector ( dst src rep -- )
    {
        { float-4-rep [ SQRTPS ] }
        { double-2-rep [ SQRTPD ] }
    } case ;

M: x86 %sqrt-vector-reps
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep } }
    } available-reps ;

M: x86 %and-vector ( dst src1 src2 rep -- )
    [ two-operand ] keep
    {
        { float-4-rep [ ANDPS ] }
        { double-2-rep [ ANDPS ] }
        [ drop PAND ]
    } case ;

M: x86 %and-vector-reps
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep char-16-rep uchar-16-rep short-8-rep ushort-8-rep int-4-rep uint-4-rep longlong-2-rep ulonglong-2-rep } }
    } available-reps ;

M: x86 %andn-vector ( dst src1 src2 rep -- )
    [ two-operand ] keep
    {
        { float-4-rep [ ANDNPS ] }
        { double-2-rep [ ANDNPS ] }
        [ drop PANDN ]
    } case ;

M: x86 %andn-vector-reps
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep char-16-rep uchar-16-rep short-8-rep ushort-8-rep int-4-rep uint-4-rep longlong-2-rep ulonglong-2-rep } }
    } available-reps ;

M: x86 %or-vector ( dst src1 src2 rep -- )
    [ two-operand ] keep
    {
        { float-4-rep [ ORPS ] }
        { double-2-rep [ ORPS ] }
        [ drop POR ]
    } case ;

M: x86 %or-vector-reps
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep char-16-rep uchar-16-rep short-8-rep ushort-8-rep int-4-rep uint-4-rep longlong-2-rep ulonglong-2-rep } }
    } available-reps ;

M: x86 %xor-vector ( dst src1 src2 rep -- )
    [ two-operand ] keep
    {
        { float-4-rep [ XORPS ] }
        { double-2-rep [ XORPS ] }
        [ drop PXOR ]
    } case ;

M: x86 %xor-vector-reps
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep char-16-rep uchar-16-rep short-8-rep ushort-8-rep int-4-rep uint-4-rep longlong-2-rep ulonglong-2-rep } }
    } available-reps ;

M: x86 %shl-vector ( dst src1 src2 rep -- )
    [ two-operand ] keep
    {
        { short-8-rep [ PSLLW ] }
        { ushort-8-rep [ PSLLW ] }
        { int-4-rep [ PSLLD ] }
        { uint-4-rep [ PSLLD ] }
        { longlong-2-rep [ PSLLQ ] }
        { ulonglong-2-rep [ PSLLQ ] }
    } case ;

M: x86 %shl-vector-reps
    {
        { sse2? { short-8-rep ushort-8-rep int-4-rep uint-4-rep longlong-2-rep ulonglong-2-rep } }
    } available-reps ;

M: x86 %shr-vector ( dst src1 src2 rep -- )
    [ two-operand ] keep
    {
        { short-8-rep [ PSRAW ] }
        { ushort-8-rep [ PSRLW ] }
        { int-4-rep [ PSRAD ] }
        { uint-4-rep [ PSRLD ] }
        { ulonglong-2-rep [ PSRLQ ] }
    } case ;

M: x86 %shr-vector-reps
    {
        { sse2? { short-8-rep ushort-8-rep int-4-rep uint-4-rep ulonglong-2-rep } }
    } available-reps ;

M: x86 %shl-vector-imm %shl-vector ;
M: x86 %shl-vector-imm-reps %shl-vector-reps ;
M: x86 %shr-vector-imm %shr-vector ;
M: x86 %shr-vector-imm-reps %shr-vector-reps ;

: scalar-sized-reg ( reg rep -- reg' )
    rep-size 8 * n-bit-version-of ;

M: x86 %integer>scalar drop MOVD ;

:: %scalar>integer-32 ( dst src rep -- )
    rep {
        { int-scalar-rep [
            dst 32-bit-version-of src MOVD
            dst dst 32-bit-version-of
            2dup eq? [ 2drop ] [ MOVSX ] if
        ] }
        { uint-scalar-rep [
            dst 32-bit-version-of src MOVD
        ] }
        { short-scalar-rep [
            dst 32-bit-version-of src MOVD
            dst dst 16-bit-version-of MOVSX
        ] }
        { ushort-scalar-rep [
            dst 32-bit-version-of src MOVD
            dst dst 16-bit-version-of MOVZX
        ] }
        { char-scalar-rep [
            dst 32-bit-version-of src MOVD
            dst { } 8 [| tmp-dst |
                tmp-dst dst int-rep %copy
                tmp-dst tmp-dst 8-bit-version-of MOVSX
                dst tmp-dst int-rep %copy
            ] with-small-register
        ] }
        { uchar-scalar-rep [
            dst 32-bit-version-of src MOVD
            dst { } 8 [| tmp-dst |
                tmp-dst dst int-rep %copy
                tmp-dst tmp-dst 8-bit-version-of MOVZX
                dst tmp-dst int-rep %copy
            ] with-small-register
        ] }
    } case ;

M: x86.32 %scalar>integer ( dst src rep -- ) %scalar>integer-32 ;

M: x86.64 %scalar>integer ( dst src rep -- )
    {
        { longlong-scalar-rep  [ MOVD ] }
        { ulonglong-scalar-rep [ MOVD ] }
        [ %scalar>integer-32 ]
    } case ;

M: x86 %vector>scalar %copy ;

M: x86 %scalar>vector %copy ;

M:: x86 %spill ( src rep dst -- )
    dst src rep %copy ;

M:: x86 %reload ( dst rep src -- )
    dst src rep %copy ;

M:: x86 %store-reg-param ( src reg rep -- )
    reg src rep %copy ;

M:: x86 %store-stack-param ( src n rep -- )
    n param@ src rep %copy ;

HOOK: struct-return@ cpu ( n -- operand )

M: x86 %prepare-struct-area ( dst -- )
    f struct-return@ LEA ;

M: x86 %alien-indirect ( src -- )
    ?spill-slot CALL ;

M: x86 %loop-entry 16 alignment [ NOP ] times ;

M:: x86 %restore-context ( temp1 temp2 -- )
    #! Load Factor stack pointers on entry from C to Factor.
    temp1 %context
    ds-reg temp1 "datastack" context-field-offset [+] MOV
    rs-reg temp1 "retainstack" context-field-offset [+] MOV ;

M:: x86 %save-context ( temp1 temp2 -- )
    #! Save Factor stack pointers in case the C code calls a
    #! callback which does a GC, which must reliably trace
    #! all roots.
    temp1 %context
    temp2 stack-reg cell neg [+] LEA
    temp1 "callstack-top" context-field-offset [+] temp2 MOV
    temp1 "datastack" context-field-offset [+] ds-reg MOV
    temp1 "retainstack" context-field-offset [+] rs-reg MOV ;

M: x86 value-struct? drop t ;

M: x86 immediate-arithmetic? ( n -- ? )
    HEX: -80000000 HEX: 7fffffff between? ;

M: x86 immediate-bitwise? ( n -- ? )
    HEX: -80000000 HEX: 7fffffff between? ;

: next-stack@ ( n -- operand )
    #! nth parameter from the next stack frame. Used to box
    #! input values to callbacks; the callback has its own
    #! stack frame set up, and we want to read the frame
    #! set up by the caller.
    frame-reg swap 2 cells + [+] ;

enable-min/max
enable-log2

enable-float-intrinsics
enable-float-functions
enable-float-min/max
enable-fsqrt

: check-sse ( -- )
    [ { (sse-version) } compile ] with-optimizer
    sse-version 20 < [
        "Factor requires SSE2, which your CPU does not support." print
        flush
        1 exit
    ] when ;
