! Copyright (C) 2007, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: cocoa.application cocoa.plists combinators io.backend
io.directories io.files io.files.info.unix io.launcher
io.pathnames kernel make namespaces sequences system
tools.deploy.backend tools.deploy.config
tools.deploy.config.editor vocabs.loader ;
QUALIFIED-WITH: tools.deploy.unix unix
IN: tools.deploy.macos

: bundle-dir ( -- dir )
    running.app?
    [ vm-path parent-directory parent-directory parent-directory ]
    [ "resource:Factor.app" ]
    if ;

: copy-bundle-dir ( bundle-name dir -- )
    [ bundle-dir prepend-path swap ] keep
    append-path copy-tree ;

: app-plist ( icon? executable bundle-name -- assoc )
    [
        "6.0" "CFBundleInfoDictionaryVersion" ,,
        "APPL" "CFBundlePackageType" ,,

        file-name "CFBundleName" ,,

        [ "CFBundleExecutable" ,, ]
        [ "org.factor." prepend "CFBundleIdentifier" ,, ] bi

        [ "Icon.icns" "CFBundleIconFile" ,, ] when

        t "NSHighResolutionCapable" ,,
    ] H{ } make ;

: create-app-plist ( icon? executable bundle-name -- )
    [ app-plist ] keep
    "Contents/Info.plist" append-path
    write-plist ;

: copy-nib ( bundle-name -- )
    deploy-ui? get [
        "Contents/Resources/English.lproj/MiniFactor.nib" copy-bundle-dir
    ] [ drop ] if ;

: vocab-mac-icon-path ( vocab -- string )
    vocab-dir "icon.icns" append-path ;

: copy-icns ( vocab bundle-name -- icon? )
    swap dup vocab-mac-icon-path vocab-append-path dup file-exists?
    [ swap "Contents/Resources/Icon.icns" append-path copy-file t ]
    [ 2drop f ] if ;

: add-frameworks-rpath ( vm -- )
    {
        "install_name_tool"
        "-add_rpath"
        "@executable_path/../Frameworks"
    } swap suffix try-output-process ;

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
    dup 0o755 set-file-permissions
    dup add-frameworks-rpath ;

: bundle-name ( -- string )
    deploy-name get ".app" append ;

: deploy.app-image-name ( vocab bundle-name -- str )
    [ % "/Contents/Resources/" % % ".image" % ] "" make ;

: deploy-app-bundle ( vocab -- )
    bundle-name ?delete-tree
    [ bundle-name create-app-dir ] keep
    [ bundle-name deploy.app-image-name ] keep
    namespace make-deploy-image
    bundle-name
    [ "Contents/Resources" copy-resources ]
    [ "Contents/Frameworks" copy-libraries ] 2bi
    bundle-name maybe-open-deploy-directory ;

: deploy-app-bundle? ( vocab -- ? )
    deploy-config [ deploy-console? get not deploy-ui? get or ] with-variables ;

M: macos deploy*
    ! pass off to M: unix deploy* if we're building a console app
    dup deploy-app-bundle? [
        deploy-app-bundle
    ] [
        call-next-method
    ] if ;

M: macos deploy-path
    dup deploy-app-bundle? [
        deploy-directory get [
            dup deploy-config [
                bundle-name "Contents/MacOS/" append-path
                swap append-path normalize-path
            ] with-variables
        ] with-directory
    ] [
        call-next-method
    ] if ;
