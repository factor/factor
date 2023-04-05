! File: folder.tools.dxf-convert
! Version: 0.1
! DRI: Dave Carlton
! Description: Convert dxf files
! Copyright (C) 2023 Dave Carlton.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors command-line file.xattr folder folder.collection io
 io.launcher io.pathnames kernel math.order math.parser math.unicode
 multiline namespaces prettyprint proquint sequences sorting
 string strings syntax.terse tools.continuations unix.ffi uuid 
 uuid.private  ;
IN: folder.tools.dxf-convert

INITIALIZED-SYMBOL: ART-FOLDER [ "/Users/davec/Dropbox/Design/Art" ]

SYMBOLS: dxf svg png webp ;
SYMBOL: art-collection
INITIALIZED-SYMBOL: RENAMED-ID [ BUNDLEID "proquint" append ]
INITIALIZED-SYMBOL: SVG-FOLDER [ ART-FOLDER get "SVG/" "/" glue ] 
INITIALIZED-SYMBOL: PNG-FOLDER [ ART-FOLDER get "PNG/" "/" glue ] 
INITIALIZED-SYMBOL: PDF-FOLDER [ ART-FOLDER get "PDF/" "/" glue ] 

: collect-files ( -- ) 
    { dxf svg png webp  } 
    [ ART-FOLDER get
      over name>> "/" glue
      path-collect-force collection get
      not-hidden
      [ (xattrs@) ] map
      [ name>> ] sort-by
      over set  
    ] map  art-collection set ;

: dxf-file? ( entry -- ? )
    name>> file-extension "dxf" = ;

: renamed? ( entry -- ? )
    xattrsRead [ name>> RENAMED-ID get  = ] filter  length 0 =  not ;

: quint-name ( -- newname )
    uuid1 string>uuid  32 >quint ; 

! FROM: folder => pathname>> ;
:: set-xattr ( oldname entry -- )
    RENAMED-ID get oldname <xattr> :> newxattr
    newxattr entry pathname>> xattrStore
    newxattr entry xattrs<< ;

:: quint-file ( entry! -- entry )
    entry string? [ entry >entry entry! ] when
    quint-name  entry name>> file-extension  "." glue :> newname
    entry name>> :> oldname
    entry pathname>>
    entry path>> as-directory  newname append 
    rename 0 =
    [ newname entry name<<
      oldname entry set-xattr
    ] when
    entry ;
    
: not-renamed ( collection -- collection )
    [ renamed? not ] filter ;
    
: rename-collection ( collection -- collection )
    not-renamed [ quint-file ] map ;

: collect-and-rename ( -- )
    collect-files  dxf get
    rename-collection
    drop ;

CONSTANT: DXF>SVG "python /Applications/Inkscape.app/Contents/Resources/share/inkscape/extensions/dxf_input.py --scalemethod auto --output "

: make-svg ( entry -- )
    [ SVG-FOLDER get ] [ name>> file-stem  ".svg" append ] bi  "/" glue
    DXF>SVG prepend " " append
    swap pathname>> append 
    run-process wait-for-process . ;

: in-collection? ( name collection -- ? )
    [ file-stem ] dip
    [ name>> file-stem over = ] find drop  >boolean nip ;

: in-svg? ( name -- ? )
    svg get in-collection? ; 
    
: convert-dxf ( entry -- )
    [ name>> file-extension "dxf" = ] retain 
    [ [ name>> in-svg? ] retain
      [ drop  ] [ make-svg ] if
    ]
    [ drop ]
    if ;
                
: run ( -- )
    "dxfconvert" print
    command-line get dup . first
    dup "Renamed: " prepend  swap 
    quint-file
    name>> " to " prepend  append print
    ; 
    
MAIN: collect-and-rename
