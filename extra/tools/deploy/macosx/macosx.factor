! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io io.files io.launcher kernel namespaces sequences
system cocoa.plists cocoa.application tools.deploy
tools.deploy.config assocs hashtables prettyprint ;
IN: tools.deploy.macosx

: touch ( path -- )
    "touch \"" swap "\"" 3append run-process ;

: rm ( path -- )
    "rm -rf \"" swap "\"" 3append run-process ;

: bundle-dir ( -- dir )
    vm parent-directory parent-directory ;

: copy-bundle-dir ( name dir -- )
    bundle-dir over path+ -rot
    >r "Contents" path+ r> path+ copy-directory ;

: copy-vm ( executable bundle-name -- vm )
    "Contents/MacOS/" path+ swap path+ vm swap [ copy-file ] keep ;

: copy-fonts ( name -- )
    "fonts/" resource-path
    swap "Contents/Resources/fonts/" path+ copy-directory ;

: print-app-plist ( executable bundle-name -- )
    [
        namespace {
            { "CFBundleInfoDictionaryVersion" "6.0" }
            { "CFBundlePackageType" "APPL" }
        } update

        file-name "CFBundleName" set

        dup "CFBundleExecutable" set
        "org.factor." swap append "CFBundleIdentifier" set
    ] H{ } make-assoc print-plist ;

: create-app-plist ( vocab bundle-name -- )
    dup "Contents/Info.plist" path+ <file-writer>
    [ print-app-plist ] with-stream ;

: create-app-dir ( vocab bundle-name -- vm )
    dup "Frameworks" copy-bundle-dir
    dup "Resources/English.lproj/MiniFactor.nib" copy-bundle-dir
    dup copy-fonts
    2dup create-app-plist copy-vm ;

: deploy.app-image ( vocab bundle-name -- str )
    [ % "/Contents/Resources/" % % ".image" % ] "" make ;

: bundle-name ( -- string )
    deploy-name get ".app" append ;

TUPLE: macosx-deploy-implementation ;

T{ macosx-deploy-implementation } deploy-implementation set-global

M: macosx-deploy-implementation deploy ( vocab -- )
    ".app deploy tool" assert.app
    "." resource-path cd
    dup deploy-config [
        bundle-name rm
        [ bundle-name create-app-dir ] keep
        [ bundle-name deploy.app-image ] keep
        namespace
    ] bind deploy* ;
