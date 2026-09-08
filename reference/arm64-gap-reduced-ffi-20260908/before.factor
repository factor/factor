USING: accessors alien alien.libraries alien.syntax io.files io.pathnames
kernel parser prettyprint system vocabs vocabs.loader ;
! Load the baseline storage type captured verbatim from snapshot3c430ff2fc.
<<
"resource:reference/arm64-gap-reduced-ffi-20260908/before-c-types.factor" run-file
"math.floats.small.c-types" lookup-vocab +done+ >>source-loaded? drop
>>
USE: math.floats.small.c-types
IN: reduced-before
<< "small-floats-before" "resource:libfactor-ffi-test.dylib" absolute-path cdecl add-library >>
LIBRARY: small-floats-before
FUNCTION: half half_identity ( half x )
FUNCTION: bfloat bfloat_identity ( bfloat x )
1.5 half_identity .
1.5 bfloat_identity .
