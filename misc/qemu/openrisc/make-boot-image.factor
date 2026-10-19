! Build an OpenRISC bootstrap image from a current host runtime.
USE: parser
<<
    "resource:core/system/system.factor" run-file
    "resource:basis/cpu/architecture/architecture.factor" run-file
    "resource:basis/bootstrap/compat/compat.factor" run-file
    "resource:basis/compiler/constants/constants.factor" run-file
    "resource:basis/compiler/codegen/relocation/relocation.factor" run-file
    "resource:basis/cpu/openrisc/32/assembler/registers/registers.factor" run-file
    "resource:basis/cpu/openrisc/32/assembler/assembler.factor" run-file
    "resource:basis/cpu/openrisc/32/abi/abi.factor" run-file
    "resource:basis/cpu/openrisc/32/32.factor" run-file
    "resource:basis/bootstrap/image/image.factor" run-file
>>
USING: bootstrap.image cpu.openrisc.32 ;
"unix-openrisc.32" make-image
