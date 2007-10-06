! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io io.files io.launcher kernel namespaces sequences
system cocoa.plists cocoa.application tools.deploy
tools.deploy.config assocs hashtables prettyprint ;
IN: tools.deploy.app

: mkdir ( path -- )
    "mkdir -p \"" swap "\"" 3append run-process ;

: touch ( path -- )
    "touch \"" swap "\"" 3append run-process ;

: rm ( path -- )
    "rm -rf \"" swap "\"" 3append run-process ;

: cp ( from to -- )
    "Copying " write over write " to " write dup print
    dup parent-dir mkdir
    [ "cp -R \"" % swap % "\" \"" % % "\"" % ] "" make
    run-process ;

: copy-bundle-dir ( name dir -- )
    vm parent-dir parent-dir over path+ -rot
    >r "Contents" path+ r> path+ cp ;

: copy-vm ( executable bundle-name -- vm )
    "Contents/MacOS/" path+ swap path+ vm swap [ cp ] keep ;

: copy-fonts ( name -- )
    "fonts/" resource-path
    swap "Contents/Resources/fonts/" path+ cp ;

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

: deploy.app-config ( vocab -- assoc )
    [ ".app" append "bundle-name" associate ] keep
    deploy-config union ;

: deploy.app ( vocab -- )
    ".app deploy tool" assert.app
    "." resource-path cd
    dup deploy.app-config [
        "bundle-name" get rm
        [ "bundle-name" get create-app-dir ] keep
        [ "bundle-name" get deploy.app-image ] keep
        namespace
    ] bind deploy* ;
