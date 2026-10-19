USING: kernel parser ;
<<
"resource:core/system/system.factor" run-file
"resource:basis/compiler/constants/constants.factor" run-file
"resource:basis/compiler/codegen/relocation/relocation.factor" run-file
"resource:basis/bootstrap/image/image.factor" run-file
>>
USING: bootstrap.image ;
"unix-alpha.64" make-image
