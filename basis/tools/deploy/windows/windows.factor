! Copyright (C) 2007, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io io.encodings.binary io.files io.pathnames io.directories
io.encodings.ascii kernel namespaces
sequences locals system splitting tools.deploy.backend
tools.deploy.config tools.deploy.config.editor assocs hashtables
prettyprint combinators windows.kernel32 windows.shell32 windows.user32
alien.c-types vocabs.metadata vocabs.loader tools.deploy.windows.ico
io.files.windows ;
IN: tools.deploy.windows

CONSTANT: app-icon-resource-id "APPICON"

:: copy-vm ( executable bundle-name extension -- vm )
    vm "." split1-last drop extension append
    bundle-name executable ".exe" append append-path
    [ copy-file ] keep ;

: create-exe-dir ( vocab bundle-name -- vm )
    deploy-console? get ".com" ".exe" ? copy-vm ;

: open-in-explorer ( dir -- )
    [ f "open" ] dip absolute-path normalize-separators
    f f SW_SHOWNORMAL ShellExecute drop ;

: embed-ico ( vm vocab -- )
    dup vocab-windows-icon-path vocab-append-path dup exists?
    [ binary file-contents app-icon-resource-id embed-icon-resource ]
    [ 2drop ] if ;

M: windows deploy*
    "resource:" [
        dup deploy-config [
            deploy-name get
            {
                [ create-exe-dir dup ]
                [ drop embed-ico ]
                [ drop deployed-image-name ]
                [ drop namespace make-deploy-image-executable ]
                [ nip "" [ copy-resources ] [ copy-libraries ] 3bi ]
                [ nip open-in-explorer ]
            } 2cleave 
        ] with-variables
    ] with-directory ;
