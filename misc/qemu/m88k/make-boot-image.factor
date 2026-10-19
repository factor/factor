! Reload the producer definitions from the selected resource tree.
! A host image may contain older target constants and relocation serialization.
USE: parser
<<
   "resource:core/system/system.factor" run-file
   "resource:basis/cpu/architecture/architecture.factor" run-file
   "resource:basis/bootstrap/compat/compat.factor" run-file
   "resource:basis/compiler/constants/constants.factor" run-file
   "resource:basis/compiler/codegen/relocation/relocation.factor" run-file
   "resource:basis/cpu/m88k/assembler/assembler.factor" run-file
   "resource:basis/cpu/m88k/m88k.factor" run-file
   "resource:basis/bootstrap/image/image.factor" run-file
>>
USING: bootstrap.image cpu.m88k ;
"unix-m88k.32" make-image
