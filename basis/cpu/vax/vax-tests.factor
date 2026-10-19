USING: accessors alien.c-types alien.data arrays compiler.test byte-arrays combinators compiler.cfg compiler.cfg.rpo compiler.cfg.build-stack-frame compiler.cfg.register-allocation compiler.cfg.comparisons compiler.cfg.instructions compiler.cfg.liveness compiler.cfg.linearization compiler.cfg.utilities compiler.cfg.ssa.destruction.leaders compiler.cfg.linear-scan.live-intervals compiler.cfg.save-contexts compiler.cfg.registers compiler.codegen.gc-maps compiler.codegen.labels compiler.codegen.relocation cpu.architecture cpu.vax cpu.vax.assembler.registers kernel layouts make math namespaces sequences system vectors words tools.test sorting ;
FROM: alien.c-types => float ;
IN: cpu.vax.tests

{ B{ 0xd0 0x53 0x52 } } [ [ 2 3 MV ] B{ } make ] unit-test
{ B{ } } [ [ 2 2 MV ] B{ } make ] unit-test
{ B{ 0xd0 0x2a 0x52 } } [ [ 2 42 LI ] B{ } make ] unit-test
{ B{ 0xd0 0x8f 0xff 0xff 0xff 0xff 0x52 } }
[ [ 2 -1 LI ] B{ } make ] unit-test
{ B{ 0xd0 0xa6 0xfc 0x52 0xd0 0x52 0xa7 0x04 } }
[ [ 2 DS -4 LW 2 RS 4 SW ] B{ } make ] unit-test
{ B{ 0x7d 0xa6 0x08 0x5a 0x7d 0x5a 0xa7 0x10 } }
[ [ 10 DS 8 FLD 10 RS 16 FSD ] B{ } make ] unit-test
{ B{ 0xc1 0x8f 0xf4 0xff 0xff 0xff 0x5e 0x5e
     0xc1 0x0c 0x5e 0x5e 0x05 } }
[ [ 16 M\ vax.32 %prologue execute( size -- )
    16 M\ vax.32 %epilogue execute( size -- )
    M\ vax.32 %return execute( -- ) ] B{ } make ] unit-test

! Three-operand arithmetic preserves inputs when the destination aliases either.
{ B{ 0xc3 0x52 0x53 0x52 } }
[ [ 2 3 2 M\ vax.32 %sub execute( dst a b -- ) ] B{ } make ] unit-test
{ B{ 0xd2 0x53 0x54 0xcb 0x54 0x52 0x53 } }
[ [ 3 2 3 M\ vax.32 %and execute( dst a b -- ) ] B{ } make ] unit-test
{ B{ 0xcb 0x8f 0xff 0xff 0xff 0x7f 0x52 0x53 } }
[ [ 3 2 0x80000000 M\ vax.32 %and-imm execute( dst src n -- ) ] B{ } make ] unit-test
{ B{ 0xd0 0x8f 0 0 0 0 0x55 0x17 0x9f 0 0 0 0 } }
[ [ init-relocation V{ } clone label-table set
    [ \ dup M\ vax.32 %jump execute( word -- ) ] B{ } make ] with-scope ] unit-test

{ 0x19 0x18 0x1d 0x1c }
[ cc< condition-code cc>= condition-code cc-o condition-code cc/o condition-code ] unit-test
{ B{ 0x7d 0x5a 0x50 } }
[ [ 0 10 double-rep M\ vax.32 %copy execute( dst src rep -- ) ] B{ } make ] unit-test
{ B{ 0xd1 0x52 0x53 0x18 0x06 0x17 0x9f 0 0 0 0 } }
[ [ init-relocation V{ } clone label-table set
    [ <label> 2 3 cc< M\ vax.32 %compare-branch execute( label a b cc -- ) ] B{ } make
  ] with-scope ] unit-test

! Variable shifts guard against ASHL's signed-byte count wrap.
{ B{ 0xd1 0x53 0x20 0x1f 0x06 0x17 0x9f 0 0 0 0
     0xc3 0x53 0x20 0x54 0xef 0x53 0x54 0x52 0x53
     0x17 0x9f 0 0 0 0 0xd0 0x00 0x53 } }
[ [ init-relocation V{ } clone label-table set
    [ 3 2 3 M\ vax.32 %shr execute( dst src count -- ) ] B{ } make
  ] with-scope ] unit-test
! ASHL's count operand is byte-sized, including values outside literal 0..63.
{ B{ 0x78 0x8f 0x40 0x52 0x53 0x78 0x8f 0x7f 0x52 0x53
     0x78 0x8f 0xe1 0x52 0x53 } }
[ [ 3 2 64 M\ vax.32 %shl-imm execute( dst src count -- )
    3 2 127 M\ vax.32 %shl-imm execute( dst src count -- )
    3 2 31 M\ vax.32 %sar-imm execute( dst src count -- ) ] B{ } make ] unit-test
{ B{ 0x78 0x8f 0xfd 0x52 0x53 } }
[ [ 3 2 3 M\ vax.32 %sar-imm execute( dst src count -- ) ] B{ } make ] unit-test

{ B{ 0xd0 0x00 0x54 0xd0 0x54 0x66 } }
[ [ vax.32 \ cpu set
    [ 0 0 <ds-loc> M\ vax.32 %replace-imm execute( value loc -- ) ] B{ } make
  ] with-scope ] unit-test

{ B{ 0 0 0 0x80 } } [ -0.0 single-literal ] unit-test
{ B{ 1 0 0 0 0 0 0 0 } } [ 1 bits>double double-literal ] unit-test
{ B{ 0x23 0x01 0 0 0 0 0xf0 0x7f } }
[ 0x7ff0000000000123 bits>double double-literal ] unit-test

! The pushed anchor label and emitted GC map resolve to the same return PC.
{ 6 t } [
    [ init-relocation V{ } clone label-table set
      V{ } clone gc-maps set V{ } clone return-addresses set 4 \ cell set
      [ "native_sum" f <gc-map> { 1 } >>gc-roots 0 native-call ] B{ } make drop
      label-table get first [ offset>> ] [ label>> offset>> ] bi
      return-addresses get first =
    ] with-scope
] unit-test

{ B{ 0x98 0x53 0x52 0x9a 0x53 0x52 0x32 0x53 0x52 0x3c 0x53 0x52 } }
[ [ 2 3 char M\ vax.32 %convert-integer execute( dst src c-type -- )
    2 3 uchar M\ vax.32 %convert-integer execute( dst src c-type -- )
    2 3 short M\ vax.32 %convert-integer execute( dst src c-type -- )
    2 3 ushort M\ vax.32 %convert-integer execute( dst src c-type -- )
  ] B{ } make ] unit-test

{ "vax_to_ieee_float" "vax_from_ieee_double" "to_signed_4" }
[ "to_float" ieee-boxing-helper "from_double" ieee-boxing-helper
  "to_signed_4" ieee-boxing-helper ] unit-test

{ B{ 0x7d 0x50 0x5a } } [
    [ init-relocation V{ } clone label-table set
      vax.32 \ cpu set
      [ 10 3 "to_double" double-rep
        M\ vax.32 %unbox execute( dst src helper rep -- ) ] B{ } make
      3 tail*
    ] with-scope
] unit-test
{ B{ 0xd0 0x50 0x52 } } [
    [ init-relocation V{ } clone label-table set
      vax.32 \ cpu set
      [ 2 10 "from_double" double-rep f
        M\ vax.32 %box execute( dst src helper rep gc-map -- ) ] B{ } make
      3 tail*
    ] with-scope
] unit-test


! Ordinary CPU memory IR remains untouched unless it crosses native F/D.
{ t t t t } [
    T{ ##single>double-float { dst 2 } { src 1 } }
    [ lower-vax-native-insn ] V{ } make first
    { [ gc-map-insn? ] [ clobber-insn? ]
      [ needs-save-context-insn? ] [ gc-map>> gc-map? ] } cleave
] unit-test

{ t t } [
    [ H{ } clone representations set 10 vreg-counter set
      T{ ##store-memory-imm { src 3 } { base 2 } { offset 0 }
          { rep double-rep } { c-type double } }
      [ lower-vax-native-insn ] V{ } make
      [ first ##native-helper? ]
      [ second c-type>> not ] bi
    ] with-scope
] unit-test

{ t } [
    T{ ##load-memory-imm { dst 3 } { base 2 } { offset 0 }
        { rep double-rep } { c-type f } }
    dup [ lower-vax-native-insn ] V{ } make first eq?
] unit-test

! A raw address used by the store after a helper keeps its moving base root.
{ { 1 } V{ { 2 1 } } } [
    [ f leader-map set
      H{ { 1 tagged-rep } { 2 int-rep } { 3 double-rep } { 4 double-rep } }
      representations set
      {
          T{ ##peek { dst 1 } { loc D: 0 } }
          T{ ##tagged>integer { dst 2 } { src 1 } }
          T{ ##native-helper { dst 4 } { src 3 }
              { helper "vax_ieee_double_to_native" }
              { rep double-rep } { src-rep double-rep } { vm? t }
              { gc-map T{ gc-map } } }
          T{ ##store-memory-imm { src 4 } { base 2 } { offset 0 }
              { rep double-rep } { c-type f } }
      } [ insns>cfg compute-live-sets ] keep
      2 swap nth gc-map>> [ gc-roots>> ] [ derived-roots>> ] bi
    ] with-scope
] unit-test

! The helper's map is emitted at the bridge's Factor continuation, immediately
! before result copying. Outgoing argument cleanup belongs to pinned text.
{ t t } [
    [ init-relocation V{ } clone label-table set
      V{ } clone gc-maps set V{ } clone return-addresses set
      4 \ cell set vax.32 \ cpu set
      [ 10 10 "vax_ieee_double_to_single" float-rep double-rep f
        <gc-map> { 1 } >>gc-roots
        M\ vax.32 %native-helper execute( dst src helper rep src-rep vm? gc-map -- )
      ] B{ } make
      return-addresses get first
      dup label-table get first label>> offset>> =
      -rot swap nth 0xd0 =
    ] with-scope
] unit-test


! Full allocation spills the moving base, converts maps to stack locations,
! inserts context publication, and reserves the native outgoing argument area.
{ t t t t } [
    [ vax.32 \ cpu set 4 \ cell set 10 vreg-counter set
      H{ { 1 tagged-rep } { 2 int-rep } { 3 double-rep } { 4 double-rep } }
      representations set
      {
          T{ ##peek { dst 1 } { loc D: 0 } }
          T{ ##tagged>integer { dst 2 } { src 1 } }
          T{ ##load-double { dst 3 } { val 1.0 } }
          T{ ##native-helper { dst 4 } { src 3 }
              { helper "vax_ieee_double_to_native" }
              { rep double-rep } { src-rep double-rep } { vm? t }
              { gc-map T{ gc-map } } }
          T{ ##store-memory-imm { src 4 } { base 2 } { offset 0 }
              { rep double-rep } { c-type f } }
      } insns>cfg dup cfg set
      dup insert-save-contexts
      dup allocate-registers
      dup build-stack-frame
      { [ stack-frame>> params>> 16 >= ]
      [ cfg>insns [ ##save-context? ] any? ]
      [ cfg>insns [ ##spill? ] any? ]
      [ cfg>insns [ ##native-helper? ] find nip gc-map>>
        gc-roots>> dup length 1 = swap [ spill-slot? ] all? and ] } cleave
    ] with-scope
] unit-test


! On a host CPU the lowering hook remains a no-op through normal optimization.
{ 2.25 } [ [ 2.25 float <ref> float deref ] compile-call ] unit-test
{ 1.5 } [ [ 3 >float 0.5 * ] compile-call ] unit-test

{ B{ 0xd4 0x9f 0 0 0 0 } } [
    [ init-relocation [ M\ vax.32 %safepoint execute( -- ) ] B{ } make ] with-scope
] unit-test
{ B{ 0x78 0x8f 0x02 0x53 0x55 0xc1 0x52 0x55 0x55
     0xc1 0x8f 0xf9 0xff 0xff 0xff 0x55 0x55 0xd0 0x65 0x52 } } [
    [ vax.32 \ cpu set [ 2 2 3 2 7 M\ vax.32 %slot execute( dst base disp scale tag -- ) ] B{ } make ]
    with-scope
] unit-test
{ B{ 0xc1 0x04 0x53 0x55 0xef 0x08 0x18 0x55 0x55
     0xd0 0xa8 0x18 0x54 0xc1 0x54 0x55 0x54 0x90 0x8f 0xc0 0x64
     0xef 0x0a 0x16 0x55 0x55
     0xd0 0xa8 0x1c 0x54 0xc1 0x54 0x55 0x54 0x90 0x8f 0xc0 0x64 } } [
    [ 4 \ cell set vax.32 \ cpu set
      [ 3 2 4 5 4 M\ vax.32 %write-barrier-imm execute( src slot tag card temp -- ) ] B{ } make
    ] with-scope
] unit-test

{ t t t t } [
    [ H{ } clone representations set 10 vreg-counter set
      T{ ##alien-invoke
          { reg-inputs { } }
          { stack-inputs { { 1 float-rep 0 4 } { 2 double-rep 4 8 } } }
          { reg-outputs { { 3 double-rep 0 } } }
          { gc-map T{ gc-map } } }
      [ lower-vax-native-insn ] V{ } make
      { [ length 4 = ]
        [ first helper>> "vax_ieee_float_to_native" = ]
        [ third ##alien-invoke? ]
        [ last helper>> "vax_native_double_to_ieee" = ] } cleave
    ] with-scope
] unit-test

{ t t t } [
    [ H{ } clone representations set 10 vreg-counter set
      T{ ##callback-inputs
          { reg-outputs { { 1 int-rep 1 } } }
          { stack-outputs { { 2 double-rep 0 8 } } } }
      [ lower-vax-native-insn ] V{ } make first
      { [ ##mapped-callback-inputs? ] [ gc-map-insn? ]
        [ hairy-clobber-insn? ] } cleave
    ] with-scope
] unit-test

{ B{ 0xd0 0xac 0x04 0x54 0xd0 0x54 0x52
     0x7d 0xac 0x08 0x5a } } [
    [ vax.32 \ cpu set
      [ 2 int-rep 0 4 load-callback-param
        10 double-rep 4 8 load-callback-param ] B{ } make
    ] with-scope
] unit-test
{ B{ 0xd0 0xa9 0x10 0x54 0xd0 0xa4 0x08 0x54 0xd0 0x54 0x52 } } [
    [ vax.32 \ cpu set 4 \ cell set
      [ 2 int-rep 1 load-callback-reg-param ] B{ } make
    ] with-scope
] unit-test

! The indirect target in R5 survives argument copying through R4. Its mapped
! Factor continuation follows JSB into the pinned native bridge.
{ t t } [
    [ init-relocation V{ } clone label-table set
      V{ } clone gc-maps set V{ } clone return-addresses set
      vax.32 \ cpu set 4 \ cell set
      [ 3 f { } { { 2 int-rep 0 4 } } { { 2 int-rep 0 } }
        { } 0 4 <gc-map> { 1 } >>gc-roots
        M\ vax.32 %alien-indirect execute( src varargs? reg-inputs stack-inputs reg-outputs dead-outputs cleanup stack-size gc-map -- )
      ] B{ } make
      return-addresses get first
      dup label-table get first label>> offset>> =
      -rot dup 6 - swap rot <slice> >array { 0x16 0x9f 0 0 0 0 } =
    ] with-scope
] unit-test

! Allocating callback entry participates in ordinary root spilling/assignment.
{ t } [
    [ vax.32 \ cpu set 4 \ cell set 10 vreg-counter set
      H{ { 1 tagged-rep } { 2 int-rep } } representations set
      {
          T{ ##peek { dst 1 } { loc D: 0 } }
          T{ ##mapped-callback-inputs
              { reg-outputs { } } { stack-outputs { { 2 int-rep 0 4 } } }
              { gc-map T{ gc-map } } }
          T{ ##store-memory-imm { src 2 } { base 2 } { offset 0 }
              { rep int-rep } { c-type f } }
          T{ ##replace { src 1 } { loc D: 0 } }
      } insns>cfg dup cfg set dup insert-save-contexts
      dup allocate-registers dup build-stack-frame
      cfg>insns [ ##mapped-callback-inputs? ] find nip
      gc-map>> gc-roots>> dup length 1 = swap [ spill-slot? ] all? and
    ] with-scope
] unit-test

! Cross emission uses 32-bit context offsets even in a 64-bit host VM.
{ B{ 0xc1 0x8f 0xfc 0xff 0xff 0xff 0x5e 0x52
     0xd0 0x52 0x69 0xd0 0x56 0xa9 0x08 0xd0 0x57 0xa9 0x0c } } [
    [ 4 \ cell set vax.32 \ cpu set
      [ 2 3 M\ vax.32 %save-context execute( t1 t2 -- ) ] B{ } make
    ] with-scope
] unit-test

! An aliasing pointer destination snapshots its address before heap allocation.
{ B{ 0xd5 0x52 0x12 0x06 0x17 0x9f 0 0 0 0 0xdd 0x52 } } [
    [ init-relocation V{ } clone label-table set
      4 \ cell set vax.32 \ cpu set
      [ 2 2 3 M\ vax.32 %box-alien execute( dst src temp -- ) ] B{ } make
      12 head
    ] with-scope
] unit-test

{ "vax_ieee_sqrt" t t f } [
    T{ ##sqrt { dst 2 } { src 1 } }
    [ lower-vax-native-insn ] V{ } make first
    { [ helper>> ] [ gc-map-insn? ] [ clobber-insn? ] [ vm?>> ] } cleave
] unit-test

{ { { int-regs { 0 1 2 3 } } { float-regs { 10 } } } }
[ M\ vax.32 machine-registers execute( -- regs ) ] unit-test

QUALIFIED: compiler.cfg.linear-scan.allocation

! Native hashtable? compilation reaches this four-way overlap in ##compare.
: compare-pressure-intervals ( -- intervals )
    H{ { 33 int-rep } { 34 int-rep } { 35 tagged-rep } { 13 int-rep } }
    representations set
    H{ { 33 33 } { 34 34 } { 35 35 } { 13 13 } } leader-map set
    {
        T{ live-interval-state { vreg 33 } { ranges V{ { 14 18 } } }
           { uses V{ T{ vreg-use { n 14 } { def-rep int-rep } }
                     T{ vreg-use { n 18 } { use-rep int-rep } } } } }
        T{ live-interval-state { vreg 34 } { ranges V{ { 16 18 } } }
           { uses V{ T{ vreg-use { n 16 } { def-rep int-rep } }
                     T{ vreg-use { n 18 } { use-rep int-rep } } } } }
        T{ live-interval-state { vreg 13 } { ranges V{ { 18 18 } } }
           { uses V{ T{ vreg-use { n 18 } { def-rep int-rep } } } } }
        T{ live-interval-state { vreg 35 } { ranges V{ { 18 20 } } }
           { uses V{ T{ vreg-use { n 18 } { def-rep tagged-rep } }
                     T{ vreg-use { n 20 } { use-rep tagged-rep } } } } }
    } [ clone ] map ;

[ [ compare-pressure-intervals
    { { int-regs { 2 3 } } { float-regs { 10 } } }
    compiler.cfg.linear-scan.allocation:allocate-registers drop
  ] with-scope ] [ bounds-error? ] must-fail-with

{ { 0 1 2 3 } } [
    [ compare-pressure-intervals
      M\ vax.32 machine-registers execute( -- registers )
      compiler.cfg.linear-scan.allocation:allocate-registers
      [ reg>> ] map natural-sort
    ] with-scope
] unit-test
