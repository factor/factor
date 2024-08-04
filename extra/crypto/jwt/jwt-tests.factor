! Copyright (C) 2021 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: checksums.sha crypto.jwt tools.test ;
IN: crypto.jwt.tests

{ "eyJhIjoiYmNkIn0" }
[ "{\"a\":\"bcd\"}" >urlsafe-base64-jwt >string ] unit-test

{ "{\"a\":\"bcd\"}" }
[ "{\"a\":\"bcd\"}" >urlsafe-base64-jwt urlsafe-base64> >string ] unit-test

{ t } [
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.he0ErCNloe4J7Id0Ry2SEDg09lKkZkfsRiGsdX_vgEg"
    "" check-signature
] unit-test

{ t } [
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.QjxgSJl1C760VSNK4e5EZaYo6qemRqYL_Ol8ZgeQreg"
    "covid" check-signature
] unit-test

{ "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.he0ErCNloe4J7Id0Ry2SEDg09lKkZkfsRiGsdX_vgEg" } [
    H{ { "alg" "HS256" } { "typ" "JWT" } }
    H{
        { "sub" "1234567890" }
        { "name" "John Doe" }
        { "iat" 1516239022 }
    }
    "" sha-256 sign-jwt
] unit-test
