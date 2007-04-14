! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io io.files kernel namespaces sequences
system tools.deploy.backend tools.deploy.config assocs
hashtables prettyprint io.unix.backend cocoa io.encodings.utf8
cocoa.application cocoa.classes cocoa.plists qualified ;
IN: tools.deploy.macosx

: bundle-dir ( -- dir )
    vm parent-directory parent-directory ;

: copy-bundle-dir ( bundle-name dir -- )
    bundle-dir over append-path -rot
    "Contents" prepend-path append-path copy-tree ;

: copy-vm ( executable bundle-name -- vm )
    "Contents/MacOS/" append-path prepend-path vm over copy-file ;

: copy-fonts ( name -- )
    "fonts/" resource-path
    swap "Contents/Resources/" append-path copy-tree-into ;

: app-plist ( executable bundle-name -- string )
    [
        namespace {
            { "CFBundleInfoDictionaryVersion" "6.0" }
            { "CFBundlePackageType" "APPL" }
        } update

        file-name "CFBundleName" set

        dup "CFBundleExecutable" set
        "org.factor." prepend "CFBundleIdentifier" set
    ] H{ } make-assoc plist>string ;

: create-app-plist ( vocab bundle-name -- )
    [ app-plist ] keep
    "Contents/Info.plist" append-path
    utf8 set-file-contents ;

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

: show-in-finder ( path -- )
    NSWorkspace
    -> sharedWorkspace
    over <NSString> rot parent-directory <NSString>
    -> selectFile:inFileViewerRootedAtPath: drop ;

M: macosx-deploy-implementation deploy* ( vocab -- )
    ".app deploy tool" assert.app
    "resource:" [
        dup deploy-config [
            bundle-name dup exists? [ delete-tree ] [ drop ] if
            [ bundle-name create-app-dir ] keep
            [ bundle-name deploy.app-image ] keep
            namespace make-deploy-image
            bundle-name show-in-finder
        ] bind
    ] with-directory ;
