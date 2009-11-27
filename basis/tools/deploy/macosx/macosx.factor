! Copyright (C) 2007, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io io.files io.files.info.unix io.pathnames
io.directories io.directories.hierarchy kernel namespaces make
sequences system tools.deploy.backend tools.deploy.config
tools.deploy.config.editor assocs hashtables prettyprint
io.backend.unix cocoa io.encodings.utf8 io.backend
cocoa.application cocoa.classes cocoa.plists
combinators ;
IN: tools.deploy.macosx

: bundle-dir ( -- dir )
    vm parent-directory parent-directory ;

: copy-bundle-dir ( bundle-name dir -- )
    [ bundle-dir prepend-path swap ] keep
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

: copy-dll ( bundle-name -- )
    "Frameworks/libfactor.dylib" copy-bundle-dir ;

: copy-nib ( bundle-name -- )
    deploy-ui? get [
        "Resources/English.lproj/MiniFactor.nib" copy-bundle-dir
    ] [ drop ] if ;

: create-app-dir ( vocab bundle-name -- vm )
    [
        nip {
            [ copy-dll ]
            [ copy-nib ]
            [ "Contents/Resources" append-path make-directories ]
            [ "Contents/Resources" copy-theme ]
        } cleave
    ]
    [ create-app-plist ]
    [ "Contents/MacOS/" append-path copy-vm ] 2tri
    dup OCT: 755 set-file-permissions ;

: deploy.app-image ( vocab bundle-name -- str )
    [ % "/Contents/Resources/" % % ".image" % ] "" make ;

: bundle-name ( -- string )
    deploy-name get ".app" append ;

: show-in-finder ( path -- )
    [ NSWorkspace -> sharedWorkspace ]
    [ normalize-path [ <NSString> ] [ parent-directory <NSString> ] bi ] bi*
    -> selectFile:inFileViewerRootedAtPath: drop ;

M: macosx deploy* ( vocab -- )
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
