! Copyright (C) 2016 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: combinators io.backend io.files.temp io.pathnames kernel
literals make mason.common mason.config namespaces sequences
system ;
IN: mason.release.sign

<<
! Two cases to allow signing in mason or in the UI
: make-factor-path ( path -- path )
    build-dir [
        ! In a build, make dir: "build-dir/factor/factor.com"
        [ "factor/" prepend-path ] dip prepend-path
    ] [
        ! Not in build, make dir: "resource:factor.com"
        "resource:" prepend-path
    ] if* normalize-path ;

HOOK: cert-path os ( -- path/f )

M: object cert-path f ;

M: macos cert-path home "config/mac_app.cer" append-path ;
>>

HOOK: sign-factor-app os ( -- )

M: object sign-factor-app ;

M: macos sign-factor-app
    {
        "Factor.app/"
        "libfactor.dylib"
        "libfactor-ffi-test.dylib"
    } [
        [
            "codesign" ,
            "--entitlements" ,
            "factor.entitlements" make-factor-path ,
            "--option" , "runtime" , ! Hardened Runtime
            "--force" , "--sign" ,
            "Developer ID Application" ,
            cert-path ,
            make-factor-path ,
        ] { } make short-running-process
    ] each ;

M:: windows sign-factor-app ( -- )
    {
        "factor.com"
        "factor.exe"
        "factor.dll"
        "libfactor-ffi-test.dll"
    } [
        ${
            "signtool" "sign"
            "/v"
            "/tr" "http://timestamp.digicert.com"
            "/td" "SHA256"
            "/fd" "SHA256"
            "/a"
        } swap make-factor-path suffix short-running-process
    ] each ;

HOOK: sign-archive os ( path -- )

M: object sign-archive drop ;

M: macos sign-archive
    ! sign the .dmg on macOS as well to avoid Gatekeeper marking
    ! the xattrs as quarantined.
    ! https://github.com/factor/factor/issues/1896
    ${
        "codesign" "--force" "--sign"
        "Developer ID Application"
        cert-path
    } over suffix short-running-process

    ! notarize the binaries
    [
        "xcrun" ,
        "notarytool" ,
        "submit" ,
        dup ,
        notary-args get %
        "--wait" ,
    ] { } make short-running-process

    ! staple the notarized ticket
    [
        "xcrun" ,
        "stapler" ,
        "staple" ,
        ,
    ] { } make short-running-process ;
