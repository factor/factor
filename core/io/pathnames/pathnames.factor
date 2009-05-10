! Copyright (C) 2004, 2009 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators io.backend kernel math math.order
namespaces sequences splitting strings system ;
IN: io.pathnames

SYMBOL: current-directory

: path-separator? ( ch -- ? ) os windows? "/\\" "/" ? member? ;

: path-separator ( -- string ) os windows? "\\" "/" ? ;

: trim-tail-separators ( str -- newstr )
    [ path-separator? ] trim-tail ;

: trim-head-separators ( str -- newstr )
    [ path-separator? ] trim-head ;

: last-path-separator ( path -- n ? )
    [ length 1 - ] keep [ path-separator? ] find-last-from ;

HOOK: root-directory? io-backend ( path -- ? )

M: object root-directory? ( path -- ? )
    [ f ] [ [ path-separator? ] all? ] if-empty ;

ERROR: no-parent-directory path ;

: parent-directory ( path -- parent )
    dup root-directory? [
        trim-tail-separators
        dup last-path-separator [
            1 + cut
        ] [
            drop "." swap
        ] if
        { "" "." ".." } member? [
            no-parent-directory
        ] when
    ] unless ;

<PRIVATE

: head-path-separator? ( path1 ? -- ?' )
    [
        [ t ] [ first path-separator? ] if-empty
    ] [
        drop f
    ] if ;

: head.? ( path -- ? ) "." ?head head-path-separator? ;

: head..? ( path -- ? ) ".." ?head head-path-separator? ;

: append-path-empty ( path1 path2 -- path' )
    {
        { [ dup head.? ] [
            rest trim-head-separators append-path-empty
        ] }
        { [ dup head..? ] [ drop no-parent-directory ] }
        [ nip ]
    } cond ;

PRIVATE>

: windows-absolute-path? ( path -- path ? )
    {
        { [ dup "\\\\?\\" head? ] [ t ] }
        { [ dup length 2 < ] [ f ] }
        { [ dup second CHAR: : = ] [ t ] }
        [ f ]
    } cond ;

: special-path? ( path -- rest ? )
    {
        { [ "resource:" ?head ] [ t ] }
        { [ "vocab:" ?head ] [ t ] }
        [ f ]
    } cond ;

: absolute-path? ( path -- ? )
    {
        { [ dup empty? ] [ f ] }
        { [ dup special-path? nip ] [ t ] }
        { [ os windows? ] [ windows-absolute-path? ] }
        { [ dup first path-separator? ] [ t ] }
        [ f ]
    } cond nip ;

: append-path ( str1 str2 -- str )
    {
        { [ over empty? ] [ append-path-empty ] }
        { [ dup empty? ] [ drop ] }
        { [ over trim-tail-separators "." = ] [ nip ] }
        { [ dup absolute-path? ] [ nip ] }
        { [ dup head.? ] [ rest trim-head-separators append-path ] }
        { [ dup head..? ] [
            2 tail trim-head-separators
            [ parent-directory ] dip append-path
        ] }
        { [ over absolute-path? over first path-separator? and ] [
            [ 2 head ] dip append
        ] }
        [
            [ trim-tail-separators "/" ] dip
            trim-head-separators 3append
        ]
    } cond ;

: prepend-path ( str1 str2 -- str )
    swap append-path ; inline

: file-name ( path -- string )
    dup root-directory? [
        trim-tail-separators
        dup last-path-separator [ 1 + tail ] [
            drop special-path? [ file-name ] when
        ] if
    ] unless ;

: file-extension ( filename -- extension )
    file-name "." split1-last nip ;

: path-components ( path -- seq )
    normalize-path path-separator split harvest ;

HOOK: canonicalize-path os ( path -- path' )

M: object canonicalize-path normalize-path ;

: resource-path ( path -- newpath )
    "resource-path" get prepend-path ;

GENERIC: vocab-path ( path -- newpath )

GENERIC: (normalize-path) ( path -- path' )

M: string (normalize-path)
    "resource:" ?head [
        trim-head-separators resource-path
        (normalize-path)
    ] [
        "vocab:" ?head [
            trim-head-separators vocab-path
            (normalize-path)
        ] [
            current-directory get prepend-path
        ] if
    ] if ;

M: object normalize-path ( path -- path' )
    (normalize-path) ;

TUPLE: pathname string ;

C: <pathname> pathname

M: pathname (normalize-path) string>> (normalize-path) ;

M: pathname <=> [ string>> ] compare ;

HOOK: home io-backend ( -- dir )

M: object home "" resource-path ;
