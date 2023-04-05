! File: collection.factor
! Version: 0.1
! DRI: Dave Carlton
! Description: Operations on collections of folders/files
! Copyright (C) 2019 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs checksums checksums.adler-32
checksums.fnv1 checksums.md5 checksums.sha continuations
file.xattr folder io io.backend io.files.info
io.encodings.utf8 io.files io.files.types io.pathnames io.streams.c kernel math math.order
random namespaces sequences serialize sorting strings string threads words
math.parser math.unicode extensions ;

IN: serialize
: save-fstore ( obj path -- )
    utf8 <file-writer> [ serialize ] with-output-stream ;

: load-fstore ( path -- obj )
    dup file-exists? [
        utf8 <file-reader> [ deserialize ] with-input-stream
    ] [
        drop f  ! >r H{ } clone r>
    ] if
    ;

IN: folder.collection

SYMBOLS: COLLECTION-FOLDER  collection ;

: name. ( entry -- entry )
    [ name>> print ] keep ;

: collection-path ( -- path )
    COLLECTION-FOLDER get
    "/collection.save" append  normalize-path ;

: save-collection ( -- )
    collection get collection-path save-fstore ;
 
: (restore-collection) ( path -- )
    load-fstore  collection set ;

: restore-collection ( -- )
   collection-path (restore-collection) ; 

: not-hidden ( entries -- entries )
    [ is-dot? not ] filter ;

: filter-single-entry ( entries -- entries )
    [ entries>> length 1  = ] filter ;

: (collect) ( path -- )
    >folder-tree
    "Collecting files" print
    folder-entries
    collection set
    "Saving collection" print
    save-collection
    ;

: path-collect ( path -- )
    COLLECTION-FOLDER set
    collection get 
    [ "collection already exists" print ] 
    [ COLLECTION-FOLDER get  dup 
      [ (collect) ] 
      [ drop  "COLLECTION-FOLDER IS NOT SET!" print ]
      if
    ]
    if
    ;

: path-collect-force ( path -- )
    f collection set  path-collect ;

: by-folders ( collection -- collection )
    { }  swap values
    [ [ second suffix ] each ] each
    [ pathnameRead ] collect-by 
;

: collection-by-folders ( -- collection )
    collection get
    dup  random first >number string?
    [ ] [ by-folders ] if 
;

IN: folder.fingerprint

TUPLE: fingerprint checksum date ;

: <fingerprint> ( checksum date -- <fingerprint> )
    fingerprint boa ;

IN: folder
DEFER: fingerprintRead

: fingerprintWrite ( fingerprint entry -- )   fingerprint<< ;

: fingerprintGet ( entry -- fingerprint entry )
    [ fingerprintRead ] keep ;

: fingerprint? ( entry -- ? )
    fingerprintRead >boolean ;
         
: fingerprintKey@ ( -- key )
    BUNDLEID "checksum.fnv1-32" append ;

:: fingerprint-xattrStore ( fingerprint entry -- )
    fingerprintKey@  entry fingerprintRead  <xattr>
    entry pathnameRead  
    xattrStore
    entry xattrsRead drop ; 

:: fingerprint-xattrGet ( entry -- fingerprint )
    f :> fp!
    entry xattrsRead  ! list of xattrs
    [ entry xattrsRead
      [ name>> fingerprintKey@ = ] filter :> {xattrs} 
      {xattrs} empty? not
      [ {xattrs} first  value>> fp!
        fp entry fingerprintWrite
      ] when
    ] when
    fp
!    dup HERE.
    ;

:: fingerprint-xattrSet ( entry -- entry )
    entry type>> +regular-file+ = [
        entry pathnameRead fnv1-32 checksum-file :> fp
        fp entry  [ fingerprintWrite ] [ fingerprint-xattrStore ] 2bi
    ] when
    entry
!    fp HERE.
    ;

:: fingerprintRead ( entry -- fingerprint )  ! Read fingerprint
    entry fingerprint>> :> fp!
    fp
    [ entry fingerprint-xattrGet fp!  ! look in xattrs
      fp
      [ entry fingerprint-xattrSet fingerprint>> fp! ]  ! not found, go create
      unless
    ]
    unless
    fp
 !   fp HERE.
    ;

   
M: folder-entry equal?
    [ fingerprintRead ] bi@ = ;

M: folder-entry hashcode*
    nip fingerprintRead ;

IN: folder.fingerprint

: fingerprint-entries ( entries -- entries )
    { } swap
    [ [ second fingerprintGet nip  suffix ] each ] each ;

! : fingerprint-sort ( entries -- entries )
!     [ fingerprintRead [ fingerprintRead ] dip  <=> ] sort-by ;

: spotcheck-entry ( entry -- entry )
    dup
    pathname>> "r" fopen >>fingerprint
    B{ }
    [ over fingerprint>> fgetc
      f over ≠ swap
      over [ rot swap suffix
             [ dup fingerprint>> 100000 1 rot fseek ] 2dip swap
           ]
      [ drop ] if
    ] loop
    adler-32 checksum-bytes
    over fingerprint>> fclose
    >>fingerprint ;

FROM: string => >folder ;
: (fingerprint) ( path -- )
    >folder
    HERE"Fingerprinting files:"
    deep folder-entries
    HERE" Fingerprinting, showing progress every 100 files"
    [
        ENTRY-COUNT inc
        ENTRY-COUNT get
        COUNTBY get mod 0 = [  
            dup name>> HERE.
        ] when
        fingerprintGet
        yield
    ] map>alist
    HERE" Collect by"
    [ first ] collect-by
    collection set
    ;

: (fingerprint-callback) ( thread -- thread )
    [ "Fingerprint files completed" print ] >>exit-handler ;

: path-fingerprint ( path -- )
    COLLECTION-FOLDER set
    collection get 
    [ "collection already exists" print ] 
    [ COLLECTION-FOLDER get  dup 
      [ [ (fingerprint) ] curry "Collect Files" <thread>
        (fingerprint-callback)
        (spawn)
      ]
      [ drop
        "COLLECTION IS NOT SET!" print ]
      if
    ]
    if
    save-collection
    ;

: path-fingerprint! ( path -- )
    f collection set  path-fingerprint ; 

: by-fingerprint ( collection -- collection )
    values fingerprint-entries
    { } swap  values
    [ [ second suffix ] each ] each
    [ fingerprint>> ] collect-by ;

: collection-by-fingerprint ( -- collection )
    collection get
    dup  random first >number number?
    [ ] [ by-fingerprint ] if ; 


        
    
