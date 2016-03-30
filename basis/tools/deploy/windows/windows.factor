! Copyright (C) 2007, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators io.backend io.directories
io.encodings.binary io.files io.files.windows io.pathnames
kernel locals namespaces splitting sequences system
tools.deploy.backend tools.deploy.config
tools.deploy.config.editor tools.deploy.windows.ico
vocabs.loader vocabs.metadata windows.shell32 windows.user32 ;
IN: tools.deploy.windows

CONSTANT: app-icon-resource-id "APPICON"

:: copy-vm ( executable bundle-name extension -- vm-path )
    vm-path "." split1-last drop extension append
    bundle-name executable ".exe" append append-path
    [ copy-file ] keep normalize-path ;

: create-exe-dir ( vocab bundle-name -- vm-path )
    deploy-console? get ".com" ".exe" ? copy-vm ;

: open-in-explorer ( dir -- )
    [ f "open" ] dip absolute-path normalize-separators
    f f SW_SHOWNORMAL ShellExecute drop ;

: ?open-in-explorer ( dir -- )
    open-directory-after-deploy? get [ open-in-explorer ] [ drop ] if ;

: vocab-windows-icon-path ( vocab -- string )
    vocab-dir "icon.ico" append-path ;

: embed-ico ( vm-path vocab -- )
    dup vocab-windows-icon-path vocab-append-path dup exists?
    [ binary file-contents app-icon-resource-id embed-icon-resource ]
    [ 2drop ] if ;

M: windows deploy*
    deploy-directory get [
        dup deploy-config [
            deploy-name get
            {
                [ create-exe-dir dup ]
                [ drop embed-ico ]
                [ drop deployed-image-name ]
                [ drop namespace make-deploy-image-executable ]
                [ nip "resource:" [ copy-resources ] [ copy-libraries ] 3bi ]
                [ nip ?open-in-explorer ]
            } 2cleave
        ] with-variables
    ] with-directory ;

M: windows deploy-path
    deploy-directory get [
        dup deploy-config [
            deploy-name get
            swap ".exe" append append-path
            normalize-path
        ] with-variables
    ] with-directory ;
