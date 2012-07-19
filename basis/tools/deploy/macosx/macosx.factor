! Copyright (C) 2007, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io io.files io.files.info.unix io.pathnames
io.directories io.directories.hierarchy kernel namespaces make
sequences system tools.deploy.backend tools.deploy.config
tools.deploy.config.editor assocs hashtables prettyprint
io.backend.unix cocoa io.encodings.utf8 io.backend
cocoa.application cocoa.classes cocoa.plists
combinators vocabs.metadata vocabs.loader ;
QUALIFIED-WITH: tools.deploy.unix unix
IN: tools.deploy.macosx

: bundle-dir ( -- dir )
    running.app?
    [ vm parent-directory parent-directory parent-directory ]
    [ "resource:Factor.app" ]
    if ;

: copy-bundle-dir ( bundle-name dir -- )
    [ bundle-dir prepend-path swap ] keep
    append-path copy-tree ;

: app-plist ( icon? executable bundle-name -- assoc )
    [
        "6.0" "CFBundleInfoDictionaryVersion" set
        "APPL" "CFBundlePackageType" set

        file-name "CFBundleName" set

        [ "CFBundleExecutable" set ]
        [ "org.factor." prepend "CFBundleIdentifier" set ] bi

        [ "Icon.icns" "CFBundleIconFile" set ] when
    ] H{ } make-assoc ;

: create-app-plist ( icon? executable bundle-name -- )
    [ app-plist ] keep
    "Contents/Info.plist" append-path
    write-plist ;

: copy-nib ( bundle-name -- )
    deploy-ui? get [
        "Contents/Resources/English.lproj/MiniFactor.nib" copy-bundle-dir
    ] [ drop ] if ;

: copy-icns ( vocab bundle-name -- icon? )
    swap dup vocab-mac-icon-path vocab-append-path dup exists?
    [ swap "Contents/Resources/Icon.icns" append-path copy-file t ]
    [ 2drop f ] if ;

: create-app-dir ( vocab bundle-name -- vm )
    {
        [
            nip
            [ copy-nib ]
            [ "Contents/Resources" append-path make-directories ]
            [ "Contents/Frameworks" append-path make-directories ] tri
        ]
        [ copy-icns ]
        [ create-app-plist ]
        [ "Contents/MacOS/" append-path copy-vm ]
    } 2cleave
    dup 0o755 set-file-permissions ;

: bundle-name ( -- string )
    deploy-name get ".app" append ;

: show-in-finder ( path -- )
    [ NSWorkspace -> sharedWorkspace ]
    [ normalize-path [ <NSString> ] [ parent-directory <NSString> ] bi ] bi*
    -> selectFile:inFileViewerRootedAtPath: drop ;

: deploy.app-image-name ( vocab bundle-name -- str )
    [ % "/Contents/Resources/" % % ".image" % ] "" make ;

: deploy-app-bundle ( vocab -- )
    "resource:" [
        dup deploy-config [
            bundle-name dup exists? [ delete-tree ] [ drop ] if
            [ bundle-name create-app-dir ] keep
            [ bundle-name deploy.app-image-name ] keep
            namespace make-deploy-image
            bundle-name
            [ "Contents/Resources" copy-resources ]
            [ "Contents/Frameworks" copy-libraries ] 2bi
            bundle-name show-in-finder
        ] with-variables
    ] with-directory ;

: deploy-app-bundle? ( vocab -- ? )
    deploy-config [ deploy-console? get not deploy-ui? get or ] with-variables ;

M: macosx deploy* ( vocab -- )
    ! pass off to M: unix deploy* if we're building a console app
    dup deploy-app-bundle?
    [ deploy-app-bundle ]
    [ call-next-method ] if ;
