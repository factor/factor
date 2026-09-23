USING: alien.c-types kernel layouts tools.test windows.advapi32 ;
IN: windows.advapi32.tests

{ t t } [
    HCRYPTKEY heap-size cell =
    HCRYPTHASH heap-size cell =
] unit-test

! Reject a null key without touching the registry, using the native four arguments.
{ 6 } [ f "FactorBindingTest" 0 0 RegDeleteKeyExW ] unit-test
