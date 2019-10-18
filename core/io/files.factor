! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io
USING: io-internals hashtables kernel math memory namespaces
sequences strings styles arrays definitions ;

! Words for accessing filesystem meta-data.

: path+ ( str1 str2 -- str )
    >r dup "/" tail? [ 1 head* ] when r>
    dup "/" head? [ 1 tail ] when
    >r "/" r> 3append ;

: stat ( path -- directory? permissions length modified )
    (stat) ;

: exists? ( path -- ? ) stat >r 3drop r> >boolean ;

: directory? ( path -- ? ) stat 3drop ;

: directory ( path -- seq )
    directory-fixup (directory)
    [ { "." ".." } member? not ] subset ;

: file-length ( path -- n ) stat 4array third ;

: file-modified ( path -- n ) stat >r 3drop r> ;

: parent-dir ( path -- parent )
    dup [ "/\\" member? ] find-last
    drop dup [ head ] [ 2drop "." ] if ;

: resource-path ( path -- newpath )
    \ resource-path get [ image parent-dir ] unless*
    swap path+ ;

: ?resource-path ( path -- newpath )
    "resource:" ?head [ resource-path ] when ;

TUPLE: pathname string ;

M: pathname where pathname-string 1 2array ;

M: pathname <=> [ pathname-string ] 2apply <=> ;

: home ( -- dir )
    {
        { [ winnt? ] [ "USERPROFILE" os-env ] }
        { [ wince? ] [ image parent-dir ] }
        { [ unix? ] [ "HOME" os-env ] }
    } cond ;
