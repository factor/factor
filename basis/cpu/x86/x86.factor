! Copyright (C) 2005, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs alien alien.c-types arrays strings
cpu.x86.assembler cpu.x86.assembler.private cpu.x86.assembler.operands
cpu.x86.features cpu.x86.features.private cpu.architecture kernel
kernel.private math memory namespaces make sequences words system
layouts combinators math.order math.vectors fry locals compiler.constants
byte-arrays io macros quotations classes.algebra compiler
compiler.units init vm vocabs
compiler.cfg.registers
compiler.cfg.instructions
compiler.cfg.intrinsics
compiler.cfg.comparisons
compiler.cfg.stack-frame
compiler.codegen.gc-maps
compiler.codegen.labels
compiler.codegen.relocation ;
QUALIFIED-WITH: alien.c-types c
FROM: layouts => cell ;
FROM: math => float ;
IN: cpu.x86

! Add some methods to the assembler to be more useful to the backend
M: label JMP 0 JMP rc-relative label-fixup ;
M: label JUMPcc [ 0 ] dip JUMPcc rc-relative label-fixup ;

M: x86 vector-regs float-regs ;

HOOK: stack-reg cpu ( -- reg )

HOOK: reserved-stack-space cpu ( -- n )

: stack@ ( n -- op ) stack-reg swap [+] ;

: special-offset ( m -- n )
    reserved-stack-space + ;

: spill@ ( n -- op ) spill-offset special-offset stack@ ;

: decr-stack-reg ( n -- )
    [ stack-reg swap SUB ] unless-zero ;

: incr-stack-reg ( n -- )
    [ stack-reg swap ADD ] unless-zero ;

: align-stack ( n -- n' ) 16 align ;

M: x86 stack-frame-size ( stack-frame -- i )
    (stack-frame-size)
    reserved-stack-space +
    cell +
    align-stack ;

HOOK: pic-tail-reg cpu ( -- reg )

M: x86 complex-addressing? t ;

M: x86 fused-unboxing? t ;

M: x86 test-instruction? t ;

M: x86 immediate-store? immediate-comparand? ;

M: x86 %load-immediate [ dup XOR ] [ MOV ] if-zero ;

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
        [ [ 0xffffffff MOV ] dip rc-absolute rel-literal ]
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
M: x86 %bit-count POPCNT ;

! A bit of logic to avoid using MOVSS/MOVSD for reg-reg moves
! since this induces partial register stalls
GENERIC: copy-register* ( dst src rep -- )
GENERIC: copy-memory* ( dst src rep -- )

M: int-rep copy-register* drop MOV ;
M: tagged-rep copy-register* drop MOV ;

M: object copy-memory* copy-register* ;

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

:: (%convert-integer) ( dst src bits quot -- )
    dst { src } bits [| new-dst |
        new-dst src int-rep %copy
        new-dst dup bits n-bit-version-of quot call
        dst new-dst int-rep %copy
    ] with-small-register ; inline

: %zero-extend ( dst src bits -- )
    [ MOVZX ] (%convert-integer) ; inline

: %sign-extend ( dst src bits -- )
    [ MOVSX ] (%convert-integer) ; inline

M: x86 %convert-integer ( dst src c-type -- )
    {
        { c:char   [ 8 %sign-extend ] }
        { c:uchar  [ 8 %zero-extend ] }
        { c:short  [ 16 %sign-extend ] }
        { c:ushort [ 16 %zero-extend ] }
        { c:int    [ 32 %sign-extend ] }
        { c:uint   [ 32 [ 2drop ] (%convert-integer) ] }
    } case ;

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

M: x86 gc-root-offset
    n>> spill-offset special-offset cell + cell /i ;

M: x86 %call-gc ( gc-map -- )
    \ minor-gc %call
    gc-map-here ;

M: x86 %alien-global ( dst symbol library -- )
    [ 0 MOV ] 2dip rc-absolute-cell rel-dlsym ;

M: x86 %prologue ( n -- ) cell - decr-stack-reg ;

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
    [ 0xffffffff CMP ] dip rc-absolute rel-literal ;

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

M:: x86 %dispatch ( src temp -- )
    ! Load jump table base.
    temp 0xffffffff MOV
    building get length :> start
    0 rc-absolute-cell rel-here
    ! Add jump table base
    temp src 0x7f [++] JMP
    building get length :> end
    ! Fix up the displacement above
    cell alignment
    [ end start - + building get dup pop* push ]
    [ (align-code) ]
    bi ;

M:: x86 %spill ( src rep dst -- )
    dst src rep %copy ;

M:: x86 %reload ( dst rep src -- )
    dst src rep %copy ;

M:: x86 %local-allot ( dst size align offset -- )
    dst offset local-allot-offset special-offset stack@ LEA ;

: next-stack@ ( n -- operand )
    #! nth parameter from the next stack frame. Used to box
    #! input values to callbacks; the callback has its own
    #! stack frame set up, and we want to read the frame
    #! set up by the caller.
    [ frame-reg ] dip 2 cells + reserved-stack-space + [+] ;

: return-reg ( rep -- reg )
    reg-class-of return-regs at first ;

HOOK: %load-stack-param cpu ( vreg rep n -- )

HOOK: %store-stack-param cpu ( vreg rep n -- )

HOOK: %load-reg-param cpu ( vreg rep reg -- )

HOOK: %store-reg-param cpu ( vreg rep reg -- )

HOOK: %discard-reg-param cpu ( rep reg -- )

: %load-return ( dst rep -- )
    dup return-reg %load-reg-param ;

: %store-return ( dst rep -- )
    dup return-reg %store-reg-param ;

HOOK: %prepare-var-args cpu ( -- )

HOOK: %cleanup cpu ( n -- )

:: emit-alien-insn ( reg-inputs stack-inputs reg-outputs dead-outputs cleanup stack-size quot -- )
    stack-inputs [ first3 %store-stack-param ] each
    reg-inputs [ first3 %store-reg-param ] each
    %prepare-var-args
    quot call
    cleanup %cleanup
    reg-outputs [ first3 %load-reg-param ] each
    dead-outputs [ first2 %discard-reg-param ] each ; inline

M: x86 %alien-invoke ( reg-inputs stack-inputs reg-outputs dead-outputs cleanup stack-size symbols dll gc-map -- )
    '[ _ _ _ %c-invoke ] emit-alien-insn ;

M:: x86 %alien-indirect ( src reg-inputs stack-inputs reg-outputs dead-outputs cleanup stack-size gc-map -- )
    reg-inputs stack-inputs reg-outputs dead-outputs cleanup stack-size [
        src ?spill-slot CALL
        gc-map gc-map-here
    ] emit-alien-insn ;

M: x86 %alien-assembly ( reg-inputs stack-inputs reg-outputs dead-outputs cleanup stack-size quot gc-map -- )
    '[ _ _ gc-map set call( -- ) ] emit-alien-insn ;

HOOK: %begin-callback cpu ( -- )

M: x86 %callback-inputs ( reg-outputs stack-outputs -- )
    [ [ first3 %load-reg-param ] each ]
    [ [ first3 %load-stack-param ] each ] bi*
    %begin-callback ;

HOOK: %end-callback cpu ( -- )

M: x86 %callback-outputs ( reg-inputs -- )
    %end-callback
    [ first3 %store-reg-param ] each ;

M: x86 %loop-entry 16 alignment [ NOP ] times ;

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

M: x86 long-long-odd-register? f ;

M: x86 float-right-align-on-stack? f ;

M: x86 immediate-arithmetic? ( n -- ? )
    -0x80000000 0x7fffffff between? ;

M: x86 immediate-bitwise? ( n -- ? )
    -0x80000000 0x7fffffff between? ;

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
        { cc<    [ src2 src1 compare call( a b -- ) dst temp \ CMOVA (%boolean) ] }
        { cc<=   [ src2 src1 compare call( a b -- ) dst temp \ CMOVAE (%boolean) ] }
        { cc>    [ src1 src2 compare call( a b -- ) dst temp \ CMOVA (%boolean) ] }
        { cc>=   [ src1 src2 compare call( a b -- ) dst temp \ CMOVAE (%boolean) ] }
        { cc=    [ src1 src2 compare call( a b -- ) dst temp \ %cmov-float= (%boolean) ] }
        { cc<>   [ src1 src2 compare call( a b -- ) dst temp \ CMOVNE (%boolean) ] }
        { cc<>=  [ src1 src2 compare call( a b -- ) dst temp \ CMOVNP (%boolean) ] }
        { cc/<   [ src2 src1 compare call( a b -- ) dst temp \ CMOVBE (%boolean) ] }
        { cc/<=  [ src2 src1 compare call( a b -- ) dst temp \ CMOVB (%boolean) ] }
        { cc/>   [ src1 src2 compare call( a b -- ) dst temp \ CMOVBE (%boolean) ] }
        { cc/>=  [ src1 src2 compare call( a b -- ) dst temp \ CMOVB (%boolean) ] }
        { cc/=   [ src1 src2 compare call( a b -- ) dst temp \ %cmov-float/= (%boolean) ] }
        { cc/<>  [ src1 src2 compare call( a b -- ) dst temp \ CMOVE (%boolean) ] }
        { cc/<>= [ src1 src2 compare call( a b -- ) dst temp \ CMOVP (%boolean) ] }
    } case ; inline

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
        { cc<    [ src2 src1 compare call( a b -- ) label JA ] }
        { cc<=   [ src2 src1 compare call( a b -- ) label JAE ] }
        { cc>    [ src1 src2 compare call( a b -- ) label JA ] }
        { cc>=   [ src1 src2 compare call( a b -- ) label JAE ] }
        { cc=    [ src1 src2 compare call( a b -- ) label %jump-float= ] }
        { cc<>   [ src1 src2 compare call( a b -- ) label JNE ] }
        { cc<>=  [ src1 src2 compare call( a b -- ) label JNP ] }
        { cc/<   [ src2 src1 compare call( a b -- ) label JBE ] }
        { cc/<=  [ src2 src1 compare call( a b -- ) label JB ] }
        { cc/>   [ src1 src2 compare call( a b -- ) label JBE ] }
        { cc/>=  [ src1 src2 compare call( a b -- ) label JB ] }
        { cc/=   [ src1 src2 compare call( a b -- ) label %jump-float/= ] }
        { cc/<>  [ src1 src2 compare call( a b -- ) label JE ] }
        { cc/<>= [ src1 src2 compare call( a b -- ) label JP ] }
    } case ;

enable-min/max
enable-log2

: check-sse ( -- )
    "Checking for multimedia extensions... " write flush
    sse-version
    [ sse-string " detected" append print ]
    [ 20 < "cpu.x86.x87" "cpu.x86.sse" ? require ] bi ;

: check-popcnt ( -- )
    enable-popcnt? [
        "Building with POPCNT support" print
        enable-bit-count
    ] when ;

: check-cpu-features ( -- )
    [ { (sse-version) popcnt? } compile ] with-optimizer
    check-sse
    check-popcnt ;
