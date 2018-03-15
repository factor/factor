! Copyright (C) 2016 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: io.backend io.pathnames kernel literals locals
mason.common namespaces sequences system ;
IN: mason.release.sign

<<
! Two cases to allow signing in mason or in the UI
: make-factor-path ( path -- path )
    build-dir [
        ! In a build, make dir: "build-dir/factor/factor.com"
        [ "factor/" prepend-path ] dip prepend-path
    ] [
        ! Not in build, make dir: "resource:factor.com"
        "resource:" prepend-path normalize-path
    ] if* ;

HOOK: cert-path os ( -- path/f )

M: object cert-path f ;

M: macosx cert-path
    home "config/mac_app.cer" append-path ;

M: windows cert-path
    home "config/FactorSPC.pfx" append-path ;
>>

HOOK: sign-factor-app os ( -- )

M: object sign-factor-app ;

M:: macosx sign-factor-app ( -- )
    ${
        "codesign" "--force" "--sign"
        "Developer ID Application"
        cert-path
    }
    "Factor.app/" make-factor-path suffix
    short-running-process ;

M:: windows sign-factor-app ( -- )
    { "factor.com" "factor.exe" } [
        [
            ${
                "signtool" "sign"
                "/v"
                "/f" cert-path
            }
        ] dip make-factor-path suffix short-running-process
    ] each ;

HOOK: sign-archive os ( path -- )

M: object sign-archive drop ;

! Sign the .dmg on macOS as well to avoid Gatekeeper marking
! the xattrs as quarantined.
! https://github.com/factor/factor/issues/1896
M: macosx sign-archive ( path -- )
    ${
        "codesign" "--force" "--sign"
        "Developer ID Application"
        cert-path
    } swap suffix
    short-running-process ;
