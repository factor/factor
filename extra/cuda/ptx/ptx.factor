! (c)2010 Joe Groff bsd license
USING: accessors arrays combinators io io.streams.string kernel
math math.parser roles sequences strings variants words ;
FROM: roles => TUPLE: ;
IN: cuda.ptx

UNION: dim integer sequence ;

VARIANT: ptx-type
    .s8 .s16 .s32 .s64
    .u8 .u16 .u32 .u64
        .f16 .f32 .f64
    .b8 .b16 .b32 .b64
    .pred
    .texref .samplerref .surfref
    .v2: { { of ptx-type } }
    .v4: { { of ptx-type } }
    .struct: { { name string } } ;

VARIANT: ptx-arch
    sm_10 sm_11 sm_12 sm_13 sm_20 ;

VARIANT: ptx-texmode
    .texmode_unified .texmode_independent ;

VARIANT: ptx-storage-space
    .reg
    .sreg
    .const: { { bank maybe{ integer } } }
    .global
    .local
    .param
    .shared
    .tex ;

TUPLE: ptx-target
    { arch maybe{ ptx-arch } }
    { map_f64_to_f32? boolean }
    { texmode maybe{ ptx-texmode } } ;

TUPLE: ptx
    { version string }
    { target ptx-target }
    body ;

TUPLE: ptx-struct-definition
    { name string }
    members ;

TUPLE: ptx-variable
    { extern? boolean }
    { visible? boolean }
    { align maybe{ integer } }
    { storage-space ptx-storage-space }
    { type ptx-type }
    { name string }
    { parameter maybe{ integer } }
    { dim dim }
    { initializer maybe{ string } } ;

TUPLE: ptx-negation
    { var string } ; 

TUPLE: ptx-vector
    elements ;

TUPLE: ptx-element
    { var string }
    { index integer } ;

UNION: ptx-var
    string ptx-element ;

TUPLE: ptx-indirect
    { base ptx-var }
    { offset integer } ;

UNION: ptx-operand
    integer float ptx-var ptx-negation ptx-vector ptx-indirect ;

TUPLE: ptx-instruction
    { label maybe{ string } }
    { predicate maybe{ ptx-operand } } ;

TUPLE: ptx-entry
    { name string }
    params
    directives
    body ;

TUPLE: ptx-func < ptx-entry
    { return maybe{ ptx-variable } } ;

TUPLE: ptx-directive ;

TUPLE: .file         < ptx-directive
    { info string } ;
TUPLE: .loc          < ptx-directive
    { info string } ;
TUPLE: .maxnctapersm < ptx-directive
    { ncta integer } ;
TUPLE: .minnctapersm < ptx-directive
    { ncta integer } ;
TUPLE: .maxnreg      < ptx-directive
    { n integer } ;
TUPLE: .maxntid      < ptx-directive
    { dim dim } ;
TUPLE: .pragma       < ptx-directive
    { pragma string } ;

VARIANT: ptx-float-rounding-mode
    .rn .rz .rm .rp .approx .full ;
VARIANT: ptx-int-rounding-mode
    .rni .rzi .rmi .rpi ;

UNION: ptx-rounding-mode
    ptx-float-rounding-mode ptx-int-rounding-mode ;

TUPLE: ptx-typed-instruction < ptx-instruction
    { type ptx-type }
    { dest ptx-operand } ;

TUPLE: ptx-2op-instruction < ptx-typed-instruction
    { a ptx-operand } ;

TUPLE: ptx-3op-instruction < ptx-typed-instruction
    { a ptx-operand }
    { b ptx-operand } ;

TUPLE: ptx-4op-instruction < ptx-typed-instruction
    { a ptx-operand }
    { b ptx-operand }
    { c ptx-operand } ;

TUPLE: ptx-5op-instruction < ptx-typed-instruction
    { a ptx-operand }
    { b ptx-operand }
    { c ptx-operand }
    { d ptx-operand } ;

TUPLE: ptx-addsub-instruction < ptx-3op-instruction
    { sat? boolean }
    { cc? boolean } ;

VARIANT: ptx-mul-mode
    .wide ;

TUPLE: ptx-mul-instruction < ptx-3op-instruction
    { mode maybe{ ptx-mul-mode } } ;

TUPLE: ptx-mad-instruction < ptx-4op-instruction
    { mode maybe{ ptx-mul-mode } }
    { sat? boolean } ;

VARIANT: ptx-prmt-mode
    .f4e .b4e .rc8 .ecl .ecr .rc16 ;

ROLE: ptx-float-ftz
    { ftz? boolean } ;
ROLE: ptx-float-env < ptx-float-ftz
    { round maybe{ ptx-float-rounding-mode } } ;

VARIANT: ptx-testp-op
    .finite .infinite .number .notanumber .normal .subnormal ;

VARIANT: ptx-cmp-op
    .eq .ne
    .lt .le .gt .ge
    .ls .hs
    .equ .neu
    .ltu .leu .gtu .geu
    .num .nan ;

VARIANT: ptx-op
    .and .or .xor .cas .exch .add .inc .dec .min .max
    .popc ;

SINGLETONS: .lo .hi ;
INSTANCE: .lo ptx-mul-mode
INSTANCE: .lo ptx-cmp-op
INSTANCE: .hi ptx-mul-mode
INSTANCE: .hi ptx-cmp-op

TUPLE: ptx-set-instruction < ptx-3op-instruction
    { cmp-op ptx-cmp-op }
    { bool-op maybe{ ptx-op } }
    { c maybe{ ptx-operand } }
    { ftz? boolean } ;

VARIANT: ptx-cache-op
    .ca .cg .cs .lu .cv
    .wb .wt ;

TUPLE: ptx-ldst-instruction < ptx-2op-instruction
    { volatile? boolean }
    { storage-space maybe{ ptx-storage-space } }
    { cache-op maybe{ ptx-cache-op } } ;

VARIANT: ptx-cache-level
    .L1 .L2 ;

TUPLE: ptx-branch-instruction < ptx-instruction
    { target string }
    { uni? boolean } ;

VARIANT: ptx-membar-level
    .cta .gl .sys ;

VARIANT: ptx-vote-mode
    .all .any .uni .ballot ;

TUPLE: ptx-instruction-not-supported-yet < ptx-instruction ;

TUPLE: abs       <{ ptx-2op-instruction ptx-float-ftz } ;
TUPLE: add       <{ ptx-addsub-instruction ptx-float-env } ;
TUPLE: addc      < ptx-addsub-instruction ;
TUPLE: and       < ptx-3op-instruction ;
TUPLE: atom      < ptx-3op-instruction
    { storage-space maybe{ ptx-storage-space } }
    { op ptx-op }
    { c maybe{ ptx-operand } } ;
TUPLE: bar.arrive < ptx-instruction
    { a ptx-operand }
    { b ptx-operand } ;
TUPLE: bar.red   < ptx-2op-instruction
    { op ptx-op }
    { b maybe{ ptx-operand } }
    { c ptx-operand } ;
TUPLE: bar.sync  < ptx-instruction
    { a ptx-operand }
    { b maybe{ ptx-operand } } ;
TUPLE: bfe       < ptx-4op-instruction ;
TUPLE: bfi       < ptx-5op-instruction ;
TUPLE: bfind     < ptx-2op-instruction
    { shiftamt? boolean } ;
TUPLE: bra       < ptx-branch-instruction ;
TUPLE: brev      < ptx-2op-instruction ;
TUPLE: brkpt     < ptx-instruction ;
TUPLE: call      < ptx-branch-instruction
    { return maybe{ ptx-operand } }
    params ;
TUPLE: clz       < ptx-2op-instruction ;
TUPLE: cnot      < ptx-2op-instruction ;
TUPLE: copysign  < ptx-3op-instruction ;
TUPLE: cos       <{ ptx-2op-instruction ptx-float-env } ;
TUPLE: cvt       < ptx-2op-instruction
    { round maybe{ ptx-rounding-mode } }
    { ftz? boolean }
    { sat? boolean }
    { dest-type ptx-type } ;
TUPLE: cvta      < ptx-2op-instruction
    { to? boolean }
    { storage-space maybe{ ptx-storage-space } } ;
TUPLE: div       <{ ptx-3op-instruction ptx-float-env } ;
TUPLE: ex2       <{ ptx-2op-instruction ptx-float-env } ;
TUPLE: exit      < ptx-instruction ;
TUPLE: fma       <{ ptx-mad-instruction ptx-float-env } ;
TUPLE: isspacep  < ptx-instruction
    { storage-space ptx-storage-space }
    { dest ptx-operand }
    { a ptx-operand } ;
TUPLE: ld        < ptx-ldst-instruction ;
TUPLE: ldu       < ptx-ldst-instruction ;
TUPLE: lg2       <{ ptx-2op-instruction ptx-float-env } ;
TUPLE: mad       <{ ptx-mad-instruction ptx-float-env } ;
TUPLE: mad24     < ptx-mad-instruction ;
TUPLE: max       <{ ptx-3op-instruction ptx-float-ftz } ;
TUPLE: membar    < ptx-instruction
    { level ptx-membar-level } ;
TUPLE: min       <{ ptx-3op-instruction ptx-float-ftz } ;
TUPLE: mov       < ptx-2op-instruction ;
TUPLE: mul       <{ ptx-mul-instruction ptx-float-env } ;
TUPLE: mul24     < ptx-mul-instruction ;
TUPLE: neg       <{ ptx-2op-instruction ptx-float-ftz } ;
TUPLE: not       < ptx-2op-instruction ;
TUPLE: or        < ptx-3op-instruction ;
TUPLE: pmevent   < ptx-instruction
    { a ptx-operand } ;
TUPLE: popc      < ptx-2op-instruction ;
TUPLE: prefetch  < ptx-instruction
    { a ptx-operand }
    { storage-space maybe{ ptx-storage-space } }
    { level ptx-cache-level } ;
TUPLE: prefetchu < ptx-instruction
    { a ptx-operand }
    { level ptx-cache-level } ;
TUPLE: prmt      < ptx-4op-instruction
    { mode maybe{ ptx-prmt-mode } } ;
TUPLE: rcp       <{ ptx-2op-instruction ptx-float-env } ;
TUPLE: red       < ptx-2op-instruction
    { storage-space maybe{ ptx-storage-space } }
    { op ptx-op } ;
TUPLE: rem       < ptx-3op-instruction ;
TUPLE: ret       < ptx-instruction ;
TUPLE: rsqrt     <{ ptx-2op-instruction ptx-float-env } ;
TUPLE: sad       < ptx-4op-instruction ;
TUPLE: selp      < ptx-4op-instruction ;
TUPLE: set       < ptx-set-instruction
    { dest-type ptx-type } ;
TUPLE: setp      < ptx-set-instruction
    { |dest maybe{ ptx-operand } } ;
TUPLE: shl       < ptx-3op-instruction ;
TUPLE: shr       < ptx-3op-instruction ;
TUPLE: sin       <{ ptx-2op-instruction ptx-float-env } ;
TUPLE: slct      < ptx-4op-instruction
    { dest-type ptx-type }
    { ftz? boolean } ;
TUPLE: sqrt      <{ ptx-2op-instruction ptx-float-env } ;
TUPLE: st        < ptx-ldst-instruction ;
TUPLE: sub       <{ ptx-addsub-instruction ptx-float-env } ;
TUPLE: subc      < ptx-addsub-instruction  ;
TUPLE: suld      < ptx-instruction-not-supported-yet ;
TUPLE: sured     < ptx-instruction-not-supported-yet ;
TUPLE: sust      < ptx-instruction-not-supported-yet ;
TUPLE: suq       < ptx-instruction-not-supported-yet ;
TUPLE: testp     < ptx-2op-instruction
    { op ptx-testp-op } ;
TUPLE: tex       < ptx-instruction-not-supported-yet ;
TUPLE: txq       < ptx-instruction-not-supported-yet ;
TUPLE: trap      < ptx-instruction ;
TUPLE: vabsdiff  < ptx-instruction-not-supported-yet ;
TUPLE: vadd      < ptx-instruction-not-supported-yet ;
TUPLE: vmad      < ptx-instruction-not-supported-yet ;
TUPLE: vmax      < ptx-instruction-not-supported-yet ;
TUPLE: vmin      < ptx-instruction-not-supported-yet ;
TUPLE: vset      < ptx-instruction-not-supported-yet ;
TUPLE: vshl      < ptx-instruction-not-supported-yet ;
TUPLE: vshr      < ptx-instruction-not-supported-yet ;
TUPLE: vsub      < ptx-instruction-not-supported-yet ;
TUPLE: vote      < ptx-2op-instruction
    { mode ptx-vote-mode } ;
TUPLE: xor       < ptx-3op-instruction ;

GENERIC: ptx-element-label ( elt -- label )
M: object ptx-element-label  drop f ;

GENERIC: ptx-semicolon? ( elt -- ? )
M: object ptx-semicolon? drop t ;
M: ptx-target ptx-semicolon? drop f ;
M: ptx-entry ptx-semicolon? drop f ;
M: ptx-func ptx-semicolon? drop f ;
M: .file ptx-semicolon? drop f ;
M: .loc ptx-semicolon? drop f ;

GENERIC: write-ptx-operand ( operand -- )

M: string write-ptx-operand write ;
M: integer write-ptx-operand number>string write ;
M: float write-ptx-operand "0d" write double>bits >hex 16 CHAR: 0 pad-head write ;
M: ptx-negation write-ptx-operand "!" write var>> write ;
M: ptx-vector write-ptx-operand
    "{" write
    elements>> [ ", " write ] [ write-ptx-operand ] interleave
    "}" write ;
M: ptx-element write-ptx-operand dup var>> write "[" write index>> number>string write "]" write ;
M: ptx-indirect write-ptx-operand
    "[" write
    dup base>> write-ptx-operand
    offset>> {
        { [ dup zero? ] [ drop ] }
        { [ dup 0 < ] [ number>string write ] }
        [ "+" write number>string write ]
    } cond
    "]" write ;

GENERIC: (write-ptx-element) ( elt -- )

: write-ptx-element ( elt -- )
    dup ptx-element-label [ write ":" write ] when*
    "\t" write dup (write-ptx-element) 
    ptx-semicolon? [ ";" print ] [ nl ] if ;

: write-ptx ( ptx -- )
    "\t.version " write dup version>> print
    dup target>> write-ptx-element
    body>> [ write-ptx-element ] each ;

: write-ptx-symbol ( symbol/f -- )
    [ name>> write ] when* ;

M: f (write-ptx-element)
    drop ;

M: word (write-ptx-element)
    name>> write ;

M: .const (write-ptx-element)
    ".const" write
    bank>> [ "[" write number>string write "]" write ] when* ;
M: .v2 (write-ptx-element)
    ".v2" write of>> (write-ptx-element) ;
M: .v4 (write-ptx-element)
    ".v4" write of>> (write-ptx-element) ;
M: .struct (write-ptx-element)
    ".struct " write name>> write ;

M: ptx-target (write-ptx-element)
    ".target " write
    [ arch>> [ name>> ] [ f ] if* ]
    [ map_f64_to_f32?>> [ "map_f64_to_f32" ] [ f ] if ]
    [ texmode>> [ name>> ] [ f ] if* ] tri
    3array sift [ ", " write ] [ write ] interleave ;

: write-ptx-dim ( dim -- )
    {
        { [ dup zero? ] [ drop "[]" write ] }
        { [ dup sequence? ] [ [ "[" write number>string write "]" write ] each ] }
        [ "[" write number>string write "]" write ]
    } cond ;

M: ptx-variable (write-ptx-element)
    dup extern?>> [ ".extern " write ] when
    dup visible?>> [ ".visible " write ] when
    dup align>> [ ".align " write number>string write bl ] when*
    dup storage-space>> (write-ptx-element) bl
    dup type>> (write-ptx-element) bl
    dup name>> write
    dup parameter>> [ "<" write number>string write ">" write ] when*
    dup dim>> [ write-ptx-dim ] when*
    dup initializer>> [ " = " write write ] when*
    drop ;

: write-params ( params -- )
    "(" write unclip (write-ptx-element)
    [ ", " write (write-ptx-element) ] each
    ")" write ;

: write-body ( params -- )
    "\t{" print
    [ write-ptx-element ] each
    "\t}" write ;

: write-entry ( entry -- )
    dup name>> write
    dup params>> [  bl write-params ] when* nl
    dup directives>> [ (write-ptx-element) nl ] each
    dup body>> write-body
    drop ;

M: ptx-entry (write-ptx-element)
    ".entry " write
    write-entry ;

M: ptx-func (write-ptx-element)
    ".func " write
    dup return>> [ "(" write (write-ptx-element) ") " write ] when*
    write-entry ;

M: .file (write-ptx-element)
    ".file " write info>> write ;
M: .loc (write-ptx-element)
    ".loc " write info>> write ;
M: .maxnctapersm (write-ptx-element)
    ".maxnctapersm " write ncta>> number>string write ;
M: .minnctapersm (write-ptx-element)
    ".minnctapersm " write ncta>> number>string write ;
M: .maxnreg (write-ptx-element)
    ".maxnreg " write n>> number>string write ;
M: .maxntid (write-ptx-element)
    ".maxntid " write
    dup sequence? [ [ ", " write ] [ number>string write ] interleave ] [ number>string write ] if ;
M: .pragma (write-ptx-element)
    ".pragma \"" write pragma>> write "\"" write ;

M: ptx-instruction ptx-element-label
    label>> ;

: write-insn ( insn name -- insn )
    over predicate>>
    [ "@" write write-ptx-operand bl ] when*
    write ;

: write-2op ( insn -- )
    dup type>> (write-ptx-element) bl
    dup dest>> write-ptx-operand ", " write
    dup a>> write-ptx-operand
    drop ;

: write-3op ( insn -- )
    dup write-2op ", " write
    dup b>> write-ptx-operand
    drop ;

: write-4op ( insn -- )
    dup write-3op ", " write
    dup c>> write-ptx-operand
    drop ;

: write-5op ( insn -- )
    dup write-4op ", " write
    dup d>> write-ptx-operand
    drop ;

: write-ftz ( insn -- )
    ftz?>> [ ".ftz" write ] when ;

: write-sat ( insn -- )
    sat?>> [ ".sat" write ] when ;

: write-float-env ( insn -- )
    dup round>> (write-ptx-element)
    write-ftz ;

: write-int-addsub ( insn -- )
    dup write-sat
    dup cc?>>  [ ".cc"  write ] when
    write-3op ;

: write-addsub ( insn -- )
    dup write-float-env
    write-int-addsub ;

: write-ldst ( insn -- )
    dup volatile?>> [ ".volatile" write ] when
    dup storage-space>> (write-ptx-element)
    dup cache-op>> (write-ptx-element)
    write-2op ;

: (write-mul) ( insn -- )
    dup mode>> (write-ptx-element)
    drop ;

: write-mul ( insn -- )
    dup write-float-env
    dup (write-mul)
    write-3op ;

: write-mad ( insn -- )
    dup write-float-env
    dup (write-mul)
    dup write-sat
    write-4op ;

: write-uni ( insn -- )
    uni?>> [ ".uni" write ] when ;

: write-set ( insn -- )
    dup cmp-op>> (write-ptx-element)
    dup bool-op>> (write-ptx-element)
    write-ftz ;

M: abs (write-ptx-element)
    "abs" write-insn
    dup write-ftz
    write-2op ;
M: add (write-ptx-element)
    "add" write-insn
    write-addsub ;
M: addc (write-ptx-element)
    "addc" write-insn
    write-int-addsub ;
M: and (write-ptx-element)
    "and" write-insn
    write-3op ;
M: atom (write-ptx-element)
    "atom" write-insn
    dup storage-space>> (write-ptx-element)
    dup op>> (write-ptx-element)
    dup write-3op
    c>> [ ", " write write-ptx-operand ] when* ;
M: bar.arrive (write-ptx-element)
    "bar.arrive " write-insn
    dup a>> write-ptx-operand ", " write
    dup b>> write-ptx-operand
    drop ;
M: bar.red (write-ptx-element)
    "bar.red" write-insn
    dup op>> (write-ptx-element)
    dup write-2op
    dup b>> [ ", " write write-ptx-operand ] when*
    ", " write c>> write-ptx-operand ;
M: bar.sync (write-ptx-element)
    "bar.sync " write-insn
    dup a>> write-ptx-operand
    dup b>> [ ", " write write-ptx-operand ] when*
    drop ;
M: bfe (write-ptx-element)
    "bfe" write-insn
    write-4op ;
M: bfi (write-ptx-element)
    "bfi" write-insn
    write-5op ;
M: bfind (write-ptx-element)
    "bfind" write-insn
    dup shiftamt?>> [ ".shiftamt" write ] when
    write-2op ;
M: bra (write-ptx-element)
    "bra" write-insn
    dup write-uni bl
    target>> write ;
M: brev (write-ptx-element)
    "brev" write-insn
    write-2op ;
M: brkpt (write-ptx-element)
    "brkpt" write-insn drop ;
M: call (write-ptx-element)
    "call" write-insn
    dup write-uni bl
    dup return>> [ "(" write write-ptx-operand "), " write ] when*
    dup target>> write
    dup params>> [ ", (" write [ ", " write ] [ write-ptx-operand ] interleave ")" write ] unless-empty
    drop ;
M: clz (write-ptx-element)
    "clz" write-insn
    write-2op ;
M: cnot (write-ptx-element)
    "cnot" write-insn
    write-2op ;
M: copysign (write-ptx-element)
    "copysign" write-insn
    write-3op ;
M: cos (write-ptx-element)
    "cos" write-insn
    dup write-float-env
    write-2op ;
M: cvt (write-ptx-element)
    "cvt" write-insn
    dup round>> (write-ptx-element)
    dup write-ftz
    dup write-sat
    dup dest-type>> (write-ptx-element)
    write-2op ;
M: cvta (write-ptx-element)
    "cvta" write-insn
    dup to?>> [ ".to" write ] when
    dup storage-space>> (write-ptx-element)
    write-2op ;
M: div (write-ptx-element)
    "div" write-insn
    dup write-float-env
    write-3op ;
M: ex2 (write-ptx-element)
    "ex2" write-insn
    dup write-float-env
    write-2op ;
M: exit (write-ptx-element)
    "exit" write-insn drop ;
M: fma (write-ptx-element)
    "fma" write-insn
    write-mad ;
M: isspacep (write-ptx-element)
    "isspacep" write-insn
    dup storage-space>> (write-ptx-element)
    bl
    dup dest>> write-ptx-operand ", " write a>> write-ptx-operand ;
M: ld (write-ptx-element)
    "ld" write-insn
    write-ldst ;
M: ldu (write-ptx-element)
    "ldu" write-insn
    write-ldst ;
M: lg2 (write-ptx-element)
    "lg2" write-insn
    dup write-float-env
    write-2op ;
M: mad (write-ptx-element)
    "mad" write-insn
    write-mad ;
M: mad24 (write-ptx-element)
    "mad24" write-insn
    dup (write-mul)
    dup write-sat
    write-4op ;
M: max (write-ptx-element)
    "max" write-insn
    dup write-ftz
    write-3op ;
M: membar (write-ptx-element)
    "membar" write-insn
    dup level>> (write-ptx-element)
    drop ;
M: min (write-ptx-element)
    "min" write-insn
    dup write-ftz
    write-3op ;
M: mov (write-ptx-element)
    "mov" write-insn
    write-2op ;
M: mul (write-ptx-element)
    "mul" write-insn
    write-mul ;
M: mul24 (write-ptx-element)
    "mul24" write-insn
    dup (write-mul)
    write-3op ;
M: neg (write-ptx-element)
    "neg" write-insn
    dup write-ftz
    write-2op ;
M: not (write-ptx-element)
    "not" write-insn
    write-2op ;
M: or (write-ptx-element)
    "or" write-insn
    write-3op ;
M: pmevent (write-ptx-element)
    "pmevent" write-insn bl a>> write ;
M: popc (write-ptx-element)
    "popc" write-insn
    write-2op ;
M: prefetch (write-ptx-element)
    "prefetch" write-insn
    dup storage-space>> (write-ptx-element)
    dup level>> (write-ptx-element)
    bl a>> write-ptx-operand ;
M: prefetchu (write-ptx-element)
    "prefetchu" write-insn
    dup level>> (write-ptx-element)
    bl a>> write-ptx-operand ;
M: prmt (write-ptx-element)
    "prmt" write-insn
    dup type>> (write-ptx-element)
    dup mode>> (write-ptx-element) bl
    dup dest>> write-ptx-operand ", " write
    dup a>> write-ptx-operand ", " write
    dup b>> write-ptx-operand ", " write
    dup c>> write-ptx-operand
    drop ;
M: rcp (write-ptx-element)
    "rcp" write-insn
    dup write-float-env
    write-2op ;
M: red (write-ptx-element)
    "red" write-insn
    dup storage-space>> (write-ptx-element)
    dup op>> (write-ptx-element)
    write-2op ;
M: rem (write-ptx-element)
    "rem" write-insn
    write-3op ;
M: ret (write-ptx-element)
    "ret" write-insn drop ;
M: rsqrt (write-ptx-element)
    "rsqrt" write-insn
    dup write-float-env
    write-2op ;
M: sad (write-ptx-element)
    "sad" write-insn
    write-4op ;
M: selp (write-ptx-element)
    "selp" write-insn
    write-4op ;
M: set (write-ptx-element)
    "set" write-insn
    dup write-set
    dup dest-type>> (write-ptx-element)
    dup write-3op
    c>> [ ", " write write-ptx-operand ] when* ;
M: setp (write-ptx-element)
    "setp" write-insn
    dup write-set
    dup type>> (write-ptx-element) bl
    dup dest>> write-ptx-operand
    dup |dest>> [ "|" write write-ptx-operand ] when* ", " write
    dup a>> write-ptx-operand ", " write
    dup b>> write-ptx-operand
    c>> [ ", " write write-ptx-operand ] when* ;
M: shl (write-ptx-element)
    "shl" write-insn
    write-3op ;
M: shr (write-ptx-element)
    "shr" write-insn
    write-3op ;
M: sin (write-ptx-element)
    "sin" write-insn
    dup write-float-env
    write-2op ;
M: slct (write-ptx-element)
    "slct" write-insn
    dup write-ftz
    dup dest-type>> (write-ptx-element)
    write-4op ;
M: sqrt (write-ptx-element)
    "sqrt" write-insn
    dup write-float-env
    write-2op ;
M: st (write-ptx-element)
    "st" write-insn
    write-ldst ;
M: sub (write-ptx-element)
    "sub" write-insn
    write-addsub ;
M: subc (write-ptx-element)
    "subc" write-insn
    write-int-addsub ;
M: testp (write-ptx-element)
    "testp" write-insn
    dup op>> (write-ptx-element)
    write-2op ;
M: trap (write-ptx-element)
    "trap" write-insn drop ;
M: vote (write-ptx-element)
    "vote" write-insn
    dup mode>> (write-ptx-element)
    write-2op ;
M: xor (write-ptx-element)
    "xor" write-insn
    write-3op ;

: ptx>string ( ptx -- string )
    [ write-ptx ] with-string-writer ;
