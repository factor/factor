USING: bit-arrays classes.struct math sequences tools.gc-decode
tools.test vm ;
QUALIFIED: effects
QUALIFIED: llvm.types
IN: tools.gc-decode.tests

! byte-array>bit-array
{
    ?{
        t t t t f t t t
        t f f f f f f f
    }
} [
    B{ 239 1 } byte-array>bit-array
] unit-test

{ ?{ t t t t t t t t } } [ B{ 255 } byte-array>bit-array ] unit-test

! scrub-bits
{ t } [
    \ effects:<effect> word>gc-info scrub-bits
    {
        ?{ t t t f t t t t } ! 64-bit
        ?{ t t t f f f f f t t t t } ! 32-bit
    } member?
] unit-test

{
    { }
} [
    \ decode-gc-maps word>gc-info scrub-bits
] unit-test

! decode-gc-maps
{ f } [
    \ effects:<effect> decode-gc-maps empty?
] unit-test

{ f } [
    \ + decode-gc-maps empty?
] unit-test

! read-gc-maps
{ { } } [
    \ decode-gc-maps decode-gc-maps
] unit-test

! base-pointer-groups
{ t } [
    \ llvm.types:resolve-types word>gc-info base-pointer-groups
    {
        {
            { -1 -1 -1 -1 -1 -1 -1 }
            { -1 -1 -1 -1 -1 -1 -1 }
            { -1 -1 -1 -1 -1 -1 -1 }
            { -1 -1 -1 -1 -1 -1 4 }
            { -1 -1 -1 -1 -1 -1 4 }
            { -1 -1 -1 -1 -1 -1 -1 }
        } ! 64-bit
        {
            { -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 }
            { -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 }
            { -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 }
            { -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 8 }
            { -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 8 }
            { -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 }
        } ! 32-bit
    } member?
] unit-test


! One of the few words that has derived roots.
{ t } [
    \ llvm.types:resolve-types word>gc-info
    {
        S{ gc-info f 0 2 2 1 5 8 6 } ! 64-bit
        S{ gc-info f 0 2 2 1 9 12 6 } ! 32-bit
    } member?
] unit-test
