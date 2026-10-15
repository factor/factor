! Called after loading current system, architecture and codegen vocabularies.
! Emit the production ##safepoint instruction and its registered map offset.
USING: accessors byte-arrays command-line compiler.cfg.instructions
compiler.constants compiler.codegen compiler.codegen.gc-maps compiler.codegen.relocation
cpu.architecture cpu.ppc cpu.sparc io.encodings.ascii io.encodings.binary io.files
kernel layouts make math.parser namespaces sequences strings system tools.test ;
IN: sparc-safepoint-map
{ 0 } [ f \ cpu set safepoint-gc-map-offset ] unit-test
{ 0 } [ hppa.32 \ cpu set safepoint-gc-map-offset ] unit-test
{ 0 } [ m88k.32 \ cpu set safepoint-gc-map-offset ] unit-test
{ 8 } [ ppc.32 \ cpu set safepoint-gc-map-offset ] unit-test
{ 20 } [ ppc.64 \ cpu set safepoint-gc-map-offset ] unit-test
{ 8 } [ sparc.32 \ cpu set safepoint-gc-map-offset ] unit-test
{ 32 } [ sparc.64 \ cpu set safepoint-gc-map-offset ] unit-test
: emit-poll ( target bytes path -- )
    [ cell set \ cpu set
      [ init-relocation V{ } clone return-addresses set V{ } clone gc-maps set
        T{ ##safepoint { gc-map T{ gc-map { gc-roots { 1 } } } } } generate-insn
        return-addresses get first
      ] B{ } make
    ] dip
    [ ".bin" append binary set-file-contents ] keep
    [ number>string ] dip ".offset" append ascii set-file-contents ;
sparc.32 4 command-line get first "/poll32" append emit-poll
sparc.64 8 command-line get first "/poll64" append emit-poll
