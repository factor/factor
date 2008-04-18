! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io io.files kernel namespaces sequences
system tools.deploy.backend tools.deploy.config assocs
hashtables prettyprint io.unix.backend cocoa io.encodings.utf8
io.backend cocoa.application cocoa.classes cocoa.plists
qualified ;
IN: tools.deploy.macosx

: bundle-dir ( -- dir )
    vm parent-directory parent-directory ;

: copy-bundle-dir ( bundle-name dir -- )
    bundle-dir over append-path -rot
    "Contents" prepend-path append-path copy-tree ;

: app-plist ( executable bundle-name -- assoc )
    [
        "6.0" "CFBundleInfoDictionaryVersion" set
        "APPL" "CFBundlePackageType" set

        file-name "CFBundleName" set

        [ "CFBundleExecutable" set ]
        [ "org.factor." prepend "CFBundleIdentifier" set ] bi
    ] H{ } make-assoc ;

: create-app-plist ( executable bundle-name -- )
    [ app-plist ] keep
    "Contents/Info.plist" append-path
    write-plist ;

: create-app-dir ( vocab bundle-name -- vm )
    dup "Frameworks" copy-bundle-dir
    dup "Resources/English.lproj/MiniFactor.nib" copy-bundle-dir
    dup "Contents/Resources/" copy-fonts
    2dup create-app-plist "Contents/MacOS/" append-path "" copy-vm ;

: deploy.app-image ( vocab bundle-name -- str )
    [ % "/Contents/Resources/" % % ".image" % ] "" make ;

: bundle-name ( -- string )
    deploy-name get ".app" append ;

: show-in-finder ( path -- )
    NSWorkspace
    -> sharedWorkspace
    over <NSString> rot parent-directory <NSString>
    -> selectFile:inFileViewerRootedAtPath: drop ;

M: macosx deploy* ( vocab -- )
    ".app deploy tool" assert.app
    "resource:" [
        dup deploy-config [
            bundle-name dup exists? [ delete-tree ] [ drop ] if
            [ bundle-name create-app-dir ] keep
            [ bundle-name deploy.app-image ] keep
            namespace make-deploy-image
            bundle-name normalize-path show-in-finder
        ] bind
    ] with-directory ;
