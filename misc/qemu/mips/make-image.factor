! Generate a fresh ordinary CPU seed from current source, including the
! target-native relocation encoding. An older loaded producer image may
! otherwise retain host-endian make-jit/push-uint definitions.
USING: bootstrap.compat bootstrap.image environment kernel parser ;

"resource:core/system/system.factor" run-file
"resource:basis/compiler/constants/constants.factor" run-file
"resource:basis/cpu/architecture/architecture.factor" run-file
"resource:basis/compiler/codegen/relocation/relocation.factor" run-file
"resource:basis/bootstrap/image/image.factor" run-file

"FACTOR_MIPS_BOOT_ARCH" os-env [ ] [ "unix-mips.64" ] if* make-image
