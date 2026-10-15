USING: kernel parser ;
<<
"resource:core/system/system.factor" run-file
"resource:basis/compiler/constants/constants.factor" run-file
"resource:basis/compiler/codegen/relocation/relocation.factor" run-file
"resource:basis/cpu/alpha/64/assembler/assembler.factor" run-file
>>
USING: accessors assocs bootstrap.image.private kernel.private compiler.constants
io.encodings.binary io.files make cpu.alpha.64.assembler cpu.alpha.64.assembler.registers math.private namespaces sequences strings words ;
H{ } clone special-objects set H{ } clone sub-primitives set
"resource:basis/bootstrap/layouts.factor" run-file
"resource:basis/bootstrap/assembler/alpha.64.factor" run-file
{ dup swap fixnum+fast fixnum*fast fixnum-bitnot fixnum-bitand eq? fixnum< fixnum> fixnum>= }
[ dup name>> "alpha-" prepend ".bin" append swap sub-primitives get at
  third second swap binary set-file-contents ] each

[ obj DS 0 LDQ PIC-TAG special-objects get at second % temp1 DS 0 STQ ] B{ } make
"alpha-pic-tag.bin" binary set-file-contents
