! Copyright (C) 2021 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.

USING: assocs base64 checksums.hmac checksums.sha json kernel
sequences splitting strings ;

IN: crypto.jwt

: jwt> ( jwt -- header payload signature )
    "." split first3
    [ urlsafe-base64> >string json> ]
    [ urlsafe-base64> >string json> ]
    [ ] tri* ;

: hmac-signature ( encoded secret/f method/f -- signature )
    [ "" or ] [ sha-256 or ] bi*
    hmac-bytes >urlsafe-base64-jwt >string ;

: jwt-encode-header-payload ( header payload -- encoded )
    [ >json >urlsafe-base64-jwt ] bi@ "." glue ;

: sign-jwt ( header payload secret/f method/f -- jwt )
    [ jwt-encode-header-payload dup ] 2dip
    hmac-signature "." "" glue-as ;

ERROR: unsupported-jwt header ;

: ensure-sha256 ( header -- header )
    dup "typ" of "JWT" = [ unsupported-jwt ] unless
    dup "alg" of "HS256" = [ unsupported-jwt ] unless ;

: check-signature ( jwt secret/f -- ? )
    [
        "." split first3 [
            dup
            urlsafe-base64> >string json> ensure-sha256 drop
        ] [ "." glue ]
        [ ] tri*
    ] dip
    '[ _ f hmac-signature ] dip = ;
