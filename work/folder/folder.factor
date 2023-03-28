! File: folder.factor
! Version: 0.2
! DRI: Dave Carlton <davec@polymicro.net>
! Description: Folder Summary
! This vocabulary implements folder entries in a manner similar to directory entries.
! The primary difference is a folder entry contains the complete path to the entry
! making it easier to work with and manipulate items.
!
! Copyright (C) 2011 PolyMicro Systems.
! See http://polymicrosystems.com/license for license details.
USING: accessors assocs checksums checksums.adler-32 checksums.fnv1 classes.tuple
 combinators combinators.short-circuit continuations debugger extensions file.xattr
 io io.backend io.directories io.files io.files.info io.files.links
 io.streams.c kernel layouts libc locals make
 math math.order math.parser math.unicode namespaces prettyprint
 prettyprint.config prettyprint.custom regexp sequences sorting splitting
 strings syntax.terse threads unix.ffi unix.users variables
 words  ;
IN: folder

:: trunc-path ( seq -- 'seq )
    length-limit get :> ll
    seq dup length ll >
    [ ll 2 /i [ 1 - head ] [ tail* ] 2bi "…" glue ]
    when ;
   
: print-path ( seq -- )
    trunc-path ... ;

IN: strings
: space? ( ch -- ? ) 32 = ;

: tab? ( ch -- ? ) 9 = ;

: trim-whitespace ( str -- str' )
    [ [ space? ] [ tab? ] bi or ] trim-head
    [ [ space? ] [ tab? ] bi or ] trim-tail
    ;

: quote-soft ( string -- string' )
    "\"" dup surround ;

: quote-hard ( string -- string' )
    "'" dup surround ;

IN: io.pathnames
: soft-quote ( string -- string' )
    "\"" dup surround ;

: hard-quote ( string -- string' )
    "'" dup surround ;

: escape-string-by ( str table -- escaped )
    ! Convert $ ( ) ' and " to shell escapes
    [ '[ [ _ at ] [ % ] [ , ] ?if ] each ] "" make ; inline

CONSTANT: PATH_ESCAPE_CHARS H{
       { CHAR: \s "\\ "  }
       { CHAR: \n "?"    }
       { CHAR: (  "\\("  }
       { CHAR: )  "\\)"  }
       { CHAR: &  "\\&"  }
       { CHAR: $  "\\$"  }
       { CHAR: ;  "\\;"  }
       { CHAR: "  "\""   }      ! for editor's sake "
       { CHAR: '  "\\'"  } 
       { CHAR: `  "\\`"  }
       }
       
: escape-string ( str -- str' )
    PATH_ESCAPE_CHARS escape-string-by ;
    ! [ dup
    !   [ PATH_ESCAPE_CHARS at ] [ nip ] [ drop 1string ] ?if
    ! ] { } map-as
    ! "" join ; 

: components-to-path ( seq -- path )
    "/" join
    ;

: as-directory ( path -- path' )
    [ last CHAR: / = ] keep
    swap
    [ ]
    [ "/" append ] if
    ;

: as-file ( path -- path' )
    [ CHAR: / = ] trim-tail
    ;

: special-path? ( path -- rest ? )
    {
        { [ "resource:" ?head ] [ t ] }
        { [ "vocab:" ?head ] [ t ] }
        { [ "~" ?head ] [ t ] }
        [ f ]
    } cond ;

: (empty-to-root) ( path -- path' )
    [ "" = ] keep "/" swap ?
    ;

: (homepath) ( path -- newpath )
    (empty-to-root)
    [ "/" head? ] keep
    path-components swap
    [ home prefix ]                        
    [                                      
      [ first user-passwd ] keep
      over 
      [ 0 swap remove-nth swap dir>> prefix ]
      [ nip ] if
    ] if
    components-to-path
    ;

M: string absolute-path
    trim-whitespace
    "resource:" ?head [
        trim-head-separators resource-path
        absolute-path
    ] [
        "vocab:" ?head [
            trim-head-separators vocab-path
            absolute-path
        ] [ "~" ?head
            [ (homepath) ]
            [ current-directory get prepend-path
            ] if
        ] if
    ] if
    ;

: remove-extension ( path -- path )
    [ [ CHAR: . = ] find-last drop ] keep swap head ;

: bump-name ( path -- path )
    dup file-extension string>number [
        [ remove-extension "." ] dip 1 +
        number>string 3append
    ] [ ".1" append ] if*
    dup file-exists?
    [ bump-name ] [ ] if
    ;

: (move-aside-error) ( error -- )
    "move-aside: Error: " over errno>>
      number>string append
      " " append over args>> first append
      " " append swap args>> second append print-path
;

: remove-acl ( path -- )
    "chmod -N " prepend
    system drop
    ;

FROM: io.directories => move-file ;
: move-aside ( path -- )
    dup bump-name
    [ over remove-acl move-file ]
    [ (move-aside-error) 2drop ]
    recover
    ;

: hasTilde ( path -- ? )
    "~" head?
;

IN: io.pathnames
: last-path-component ( path -- path stem )
    path-components
    [  "/" "" ]
    [
    [ last ] keep
    [ length ] keep
    [ 1 - ] dip
    remove-nth
    components-to-path
    "/" swap append
    ]
    if-empty
;

IN: io.files.types

SYMBOL: +nonexistent-file+

USE: io.directories
IN: folder

CONSTANT: BUNDLEID "net.polymicro."

CONSTANT: TEST "~/Sources"
CONSTANT: DOMAIN-ID "net.polymicro."
    
TUPLE: folder-entry < directory-entry path info xattrs entries fingerprint depth ;

: (folder-entry) ( name info path -- name type path info xattrs entries fingerprint depth )
    swap normalize-path
    over ! check for existence
    [ [ dup type>> swap ] dip  swap ] ! adjust stack: name type path info
    [ [ drop +nonexistent-file+ ] dip f
    ] if
    f f f f ! xattrs, entries, fingerprint and depth are f until needed
    ;

 : <folder-entry> ( name info path -- folder )
     (folder-entry) folder-entry boa
     ;
    
 : <folder-entry-deep> ( name info path -- folder )
     (folder-entry) folder-entry boa  t >>depth
     ;

    ! Accessors
: nameRead ( entry -- name )   name>> ;
: pathRead ( entry -- path )   path>> ;
: pathnameRead ( entry -- path )
    [ pathRead ] keep  [ "/" append ] dip  nameRead append ; 
: typeRead ( entry -- type )   type>> ; 
: infoRead ( entry -- info )   info>> ;

DEFER: does-exist?
DEFER: pathnameGet
    
: (xattrs@) ( entry -- entry )
    dup does-exist? [ ! entry ? 
        dup xattrs>> empty? ! entry ?
        [ dup ! entry entry 
          pathnameRead path>xattrs ! entry xattrs
          >>xattrs  ! entry
        ] when
    ] when ; ! entry 

: xattrsRead ( entry -- xattrs )   (xattrs@) xattrs>> ;
: entriesRead ( entry -- entries )   entries>> ;

: nameWrite ( name entry -- )   name<< ;
: typeWrite ( type entry -- )   type<< ; 
: infoWrite ( info entry -- )   info<< ; 
: xattrsWrite ( xattrs entry -- )   xattrs<< ;

: nameGet ( entry -- name entry )
    [ name>> ] keep ;
: extensionGet ( entry -- extension entry )
    [ name>> file-extension ] keep ;
: typeGet ( entry -- type entry )
    [ type>> ] keep ;
: pathGet ( entry -- path entry )
    [ path>> ] keep ;
: pathnameGet ( entry -- pathname entry )
    [ pathnameRead ] keep ;
: infoGet ( entry -- file-info entry )
    [ info>> ] keep ;

: xattrsGet ( entry -- xattrs entry )
    [ xattrsRead ] keep ;
: entriesGet ( entry -- entries entry )
    [ entries>> ] keep ;

: does-exist? ( entry -- ? )
    type>> +nonexistent-file+ = not ;

: is-directory? ( entry -- ? )
    type>> +directory+ = ;

: is-file? ( entry -- ? )
    type>> +regular-file+ = ;

: is-symbolic? ( entry -- ? )
    type>> +symbolic-link+ = ;

: is-hidden? ( entry -- ? )
    name>> first CHAR: . = ;

: name=? ( str entry -- ? )
    swap name>> =  ;

: name=~? ( regexp entry -- ? )
    name>> swap re-contains? ; 

: name-in-seq? ( string-seq entry -- ? )
    [ name=? ] with find drop ;

: has-entries? ( entry -- ? )
    entries>> length f = not ;

: wwcd ( -- path )
    "." normalize-path ;

: print-names ( entries -- )
    [ name>> print ] each ;

: dot-in-name ( entries -- entries )
    dup
    [ name>> "." split  first "" = ] filter
    "Multiple . in name" print
    print-names
    ;

: more-than-2 ( entries -- entries )
    dup
    "Multiple parts" print
    [ name>> "." split length 2 = not ] filter
    print-names
    ;

: underscore-in-name ( entries -- entries )
    dup 
    "Multiple underscores" print
    [ name>> "_" split length 3 = ] filter
    print-names
    ;

: find-in-name ( entry regexp -- t|f )
    [ name>> ] dip re-contains? ; 

: filter-_1 ( seq -- seq )
    [ R/ .*_1\..*/ swap first find-in-name ] filter ;

: filter-dot-names ( seq -- seq )
    [ R/ ^\..*/ swap name=~? not ] filter ;

! Default is shallow, will not look into subdirectories

: deep ( entry -- entry )   t >>depth ;
: notdeep ( entry -- entry )  f >>depth ;

: is-dot? ( entry -- ? )
    name>> first  CHAR: . = ;

: starts-with-dot? ( entry -- ? )
    R/ ^\..*/ swap name=~? ;
    
: is-dot-dir? ( entry -- ? )
    [ is-directory? ] keep  is-dot?  and ;

DEFER: folder-entries
SYMBOL: FOLDERFILTER
    
IN: string
GENERIC: >folder ( path -- folder )
GENERIC: >folder-tree ( path -- folder )
GENERIC: >entry ( path -- entry )
FROM: folder => folder-entries ;

: (>entry) ( path class -- entry )
    over 
    [ link-info ]
    [ nip drop f ]
    recover
    [ last-path-component ] 2dip swap
    call( name info path -- folder ) ;
    
: (>folder) ( path class -- folder )
    (>entry)
    [ folder-entries ] keep  swap >>entries
    f FOLDERFILTER set ;
    
M: string >folder ( path -- folder )
    [ <folder-entry> ] (>folder) ;

M: string >folder-tree ( path -- folder )
    [ <folder-entry-deep> ] (>folder) ;

M: string >entry ( path -- entry )
    [ <folder-entry> ] (>entry) ;

! IN: folder
! : >folder ( path -- folder )
!     >folder ; ! Uses string >folder from above

! : >folder-tree ( path -- folder )
!     >folder-tree ; ! Uses string >folder-deep from above

IN: io.directories
GENERIC: entry>folder ( path directory-entry -- folder )
GENERIC: entry>folder-tree ( path directory-entry -- folder )

: (entry-folder) ( path directory-entry -- folder )
    tuple-slots
    swap normalize-path
    [ suffix ] keep
    over first append  
    link-info suffix 
    folder-entry prefix
    >tuple
    ;
    
M: directory-entry entry>folder 
    (entry-folder) ;

M: directory-entry entry>folder-tree
    (entry-folder) deep ; 


IN: folder

: pathname>> ( entry -- path )  pathnameRead ; 

: error>string ( error -- string )
    "ERROR: "
    over args>> first append
    " error: " append  over errno>> number>string append
    " msg: " append  over message>> append
    " word: " append  swap  word>> name>> append
;
      
FROM: io.pathnames => absolute-path ;
M: folder-entry absolute-path pathname>> absolute-path ;

FROM: io.directories => (directory-entries) entry>folder ;

SYMBOL: †level
INITIALIZED-SYMBOL: COUNTBY [ 1000 ] 
SYMBOL: ENTRY-COUNT
    
: count-by ( n -- )   COUNTBY set  0 ENTRY-COUNT set ;
: +count ( -- )   ENTRY-COUNT get  1 +  ENTRY-COUNT set ;
: .countby ( -- )
    ENTRY-COUNT get  COUNTBY get  mod 0=
    [ ENTRY-COUNT get  . +count ] when ;
    
: (folder-filter) ( entry -- ? )
    is-dot-dir? not ;

: not-dot-file? ( entry -- ? )
    is-dot? not ;
    
: folder-filter ( entry -- ? )
    FOLDERFILTER get dup
    [ dup word?
      [ execute( entry -- ? ) ]
      [ call( entry -- ? ) ]
      if
    ]
    [ drop  (folder-filter) ]
    if
    ;
    
: (folder-entries) ( folder -- entries )
    typeGet [ +nonexistent-file+ = ] dip  swap
    [ drop { } ]
    [
        yield
        [ pathname>> ] keep
        [ 
            [ (directory-entries) ]
            [ message>>  ": " prepend  append  print-path  { } ]
            recover
        ] dip
        [ [ folder-filter ] filter ] dip
        swap
        [ over pathname>> "/" append swap entry>folder ] map
        >>entries entries>>
    ] if
    ;

SYMBOL: †test-level

FROM: string => >folder-tree ;

! Recurse into folder and get every file stored into entries
: (folder-entries-deep) ( folder -- entries )
   (folder-entries)
    [ dup is-directory?
      [ dup is-dot-dir? not 
          [ †level get †test-level get <=
            [ †level get 1 + †level set
              [ pathname>> >folder-tree (folder-entries-deep) ] keep 
              swap >>entries
            ] when 
          ] when
      ] when
    ] map
    ;

: (deep-entries) ( entries -- all-entries )
    { } swap
    [
        dup is-directory? [
            [ dup is-dot-dir? not ] keep swap
            [ entries>> (deep-entries)
              nip append
            ] 
            [ dup is-dot? 
              [ 2drop ]
              [ drop suffix ]
              if
            ] if
        ]
        [ suffix ] if
    ] each
    ;
        
: folder-entries ( folder -- entries )
    dup depth>> dup
    {
      { t [ drop most-positive-fixnum ] }
      { f [ drop 0 ] }
      [ drop ]
    } case
    dup †test-level set
    0 †level set
    dup [ >>depth ] dip  0 >
    ! If depth is t, then replace with big number, pass thru otherwise
    [ (folder-entries-deep)
      (deep-entries)
    ]
    [ (folder-entries) ]
    if
;

: entry-files ( entry -- seq )
    [ entries>> ] keep swap
    [ name>>  over pathname>> as-directory  prepend ] map  nip
    ;
    
: folder-filenames ( folder -- seq )
    folder-entries [ name>> ] map! ;

: with-folder-directory ( folder quot -- )
     [ pathname>> ] dip  with-directory ; inline

: with-folder ( folder quot -- )
     [ folder-entries ] dip each ; inline

: with-folder-filenames ( folder quot -- )
     [ folder-filenames ] dip each ; inline

: open-entry ( entry -- )
    dup type>>
    {
        { +regular-file+ [ path>> escape-string  "open " prepend  system ] }
        { +directory+ [ pathname>> escape-string  "open " prepend  system ] }
        { +symbolic-link+ [ path>> escape-string  "open " prepend  system ] }
        { +nonexistent-file+ [ "Not a file" print-path ] }
        [ drop  "Can't determine file type" . ]
    } case
    drop
    ;

SYMBOL: ERRORS

: folder-exists? ( folder -- ? )
    [ pathname>> file-exists? ] [ does-exist? ] bi  and ; 
    
: entry-copy  ( from to -- )
    [ [ pathname>> ] dip  pathname>>  copy-file-into ]
    [ error>string .
      { } 2sequence 
      ERRORS [ suffix ] change
    ]
    recover    
    ;
    
: entries-copy ( from to -- )
    { } ERRORS set
    2dup [ type>> +nonexistent-file+ = not ] bi@ or
    [ over entries>> [ [ swap entry-copy ] keep swap  ] each 2drop ]
    [ 2drop ]
    if ;

: folder-copy-tree ( folder-from folder-to -- )
    2dup [ folder-exists? ] bi@ and
    [ [ pathname>> ] bi@
      [ copy-tree-into ]
      [ print-error-and-restarts 2drop ] recover
    ] 
    [ 2drop ]
    if
    ;
    
: entry-move  ( from to -- )
    [ [ pathname>> ] dip  pathname>>  move-file-into ]
    [ error>string
      .
      { } 2sequence 
      ERRORS get  swap suffix
      ERRORS set
    ]
      recover    
    ;
    
: entries-move ( from to -- )
    { } ERRORS set
    2dup [ type>> +nonexistent-file+ = not ] bi@ or
    [ over entries>> [ [ swap entry-move ] keep swap  ] each 2drop ]
    [ 2drop ]
    if
    ;


: entry-rename ( from to -- )
    2drop "Unimplemented" .
    ;

: delete-entry ( entry -- )
    [ dup
      [ type>> ] keep swap
      {
          { +regular-file+ [ pathname>> delete-file ] }
          { +directory+ [ pathname>> delete-directory ] }
          { +symbolic-link+ [ pathname>> delete-file ] }
          [ 2drop ]
      } case
      +nonexistent-file+ swap type<<
    ]
    [ error>string .  drop ]
    recover
;

: entry-delete-tree ( entry -- )
    pathname>>
    [ file-exists? ] keep swap 
    [ delete-tree ]
    [ drop ]
    if
    ;
    
SYMBOL: (link-entries)
    
: entry>symlink ( entry1 entry2 -- )
    over file-exists?
    [ dup entry-delete
      [ pathname>> ] bi@
      [ symlink ] 2keep
      pick 0 = not
      [ [ " to " append ] dip
        append "ERR: " prepend print
        drop
      ]
      [ drop 2drop ]
      if
    ]
    [ drop  pathname>> " does not exist: " append  print ]
    if
    ;

: entry>hardlink ( entry1 entry2 -- )
    over type>> +symbolic-link+ = not [ 
        dup file-exists?
        [ dup delete-entry 
          [ pathname>> ] bi@
          [ make-hard-link ]
          [    "Error: " over errno>> number>string append
               " " append over args>> first append " " append
               swap args>> second append print-path 
               2drop ]
          recover
        ]
        [ nip  "dst does not exist: " swap pathname>> append  print-path ]
        if
    ] [ drop  "src is symlink!: " swap pathname>> append  print-path ] if
    ;

M: folder-entry pprint* pprint-object ;

IN: io.directories

: links. ( path1 path2 -- )
    swap "link: " prepend print-path
    "  to: " prepend print-path
;

: link-to-current-directory ( path -- )
    normalize-path
    dup file-name
    current-directory get as-directory prepend
    2dup links.
    dup file-exists?
    [ dup move-aside ] [ ] if
    [ make-link ]
    [ (move-aside-error) 2drop ]
    recover
;

