! Dump actual HPPA bootstrap templates for native GNU fixture execution.
USING: parser ;
"resource:basis/compiler/constants/constants.factor" run-file
"resource:basis/compiler/codegen/relocation/relocation.factor" run-file
"resource:basis/bootstrap/image/image.factor" run-file
"resource:basis/cpu/hppa/assembler/registers/registers.factor" run-file
"resource:basis/cpu/hppa/assembler/assembler.factor" run-file
USING: accessors assocs bootstrap.image.private command-line
compiler.constants io.encodings.binary io.files io.pathnames kernel
kernel.private math.private namespaces sequences slots.private splitting strings strings.private words ;
H{ } clone special-objects set H{ } clone sub-primitives set
"resource:basis/bootstrap/layouts.factor" run-file
"resource:basis/bootstrap/assembler/hppa.32.unix.factor" run-file
IN: hppa-bootstrap-emit
: write-template ( code name -- )
    command-line get first prepend binary set-file-contents ;
{
    dup over swap rot -rot 2dup dupd 3dup 4dup nip 2nip
    fixnum+fast fixnum-fast fixnum*fast fixnum* fixnum-bitand fixnum-bitor
    fixnum-bitxor fixnum-bitnot fixnum/i-fast fixnum-mod
    fixnum/mod-fast fixnum-shift-fast slot string-nth-fast
    fpu-state set-fpu-state leaf-signal-handler signal-handler
} [
    [ sub-primitives get at third
      [ second B{ 0xe8 0x40 0xc0 0x00 0x08 0x00 0x02 0x40 } append ]
      [ first ] bi ]
    [ name>> "/" split "-" join ] bi
    [ ".rel" append write-template ]
    [ ".bin" append write-template ] bi
] each
CALLBACK-STUB special-objects get at first
"callback.rel" write-template
CALLBACK-STUB special-objects get at second
"callback.bin" write-template
