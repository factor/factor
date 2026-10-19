! Run with a host Factor whose resource directory is this checkout.
USING: parser ;
"resource:basis/compiler/codegen/relocation/relocation.factor" run-file
"resource:basis/bootstrap/image/image.factor" run-file
"resource:basis/cpu/m68k/assembler/assembler.factor" run-file
USING: compiler.constants accessors assocs bootstrap.image.private io.encodings.binary io.files
io.pathnames kernel kernel.private math.private namespaces sequences slots.private strings.private splitting words ;
H{ } clone special-objects set H{ } clone sub-primitives set
"resource:basis/bootstrap/layouts.factor" run-file
"resource:basis/bootstrap/assembler/m68k.32.factor" run-file
{
    dup over swap rot -rot 2dup dupd 3dup 4dup nip 2nip
    fixnum+fast fixnum-fast fixnum*fast fixnum* fixnum-bitand fixnum-bitor
    fixnum-bitxor fixnum-bitnot fixnum/i-fast fixnum-mod
    fixnum/mod-fast fixnum-shift-fast slot string-nth-fast
    fpu-state set-fpu-state unwind-native-frames set-callstack
} [
    [ sub-primitives get at third last
      JIT-PROLOG special-objects get at last prepend
      JIT-EPILOG special-objects get at last append
      B{ 0x4e 0x75 } append ]
    [ name>> "/" split "-" join ".bin" append "m68k-bootstrap-probe-dir" get prepend ] bi
    binary set-file-contents
] each

CALLBACK-STUB special-objects get at second
"m68k-bootstrap-probe-dir" get "callback.bin" append binary set-file-contents
CALLBACK-STUB special-objects get at first
"m68k-bootstrap-probe-dir" get "callback-relocations.bin" append binary set-file-contents

\ unwind-native-frames sub-primitives get at third first
"m68k-bootstrap-probe-dir" get "unwind-relocations.bin" append binary set-file-contents

MEGA-LOOKUP special-objects get at second B{ 0x4e 0x75 } append
"m68k-bootstrap-probe-dir" get "mega.bin" append binary set-file-contents
MEGA-LOOKUP special-objects get at first
"m68k-bootstrap-probe-dir" get "mega-relocations.bin" append binary set-file-contents
