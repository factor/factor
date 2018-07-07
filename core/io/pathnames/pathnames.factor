! Copyright (C) 2004, 2009 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators io.backend kernel math math.order
namespaces sequences splitting strings system ;
IN: io.pathnames

SYMBOL: current-directory

: path-separator? ( ch -- ? ) os windows? "/\\" "/" ? member? ;

: path-separator ( -- string ) os windows? "\\" "/" ? ;

: trim-tail-separators ( string -- string' )
    [ path-separator? ] trim-tail ;

: trim-head-separators ( string -- string' )
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

PRIVATE>

: absolute-path? ( path -- ? )
    {
        { [ dup empty? ] [ f ] }
        { [ dup special-path? nip ] [ t ] }
        { [ os windows? ] [ windows-absolute-path? ] }
        { [ dup first path-separator? ] [ t ] }
        [ f ]
    } cond nip ;

: append-relative-path ( path1 path2 -- path )
    [ trim-tail-separators ]
    [ trim-head-separators ] bi* "/" glue ;

: append-path ( path1 path2 -- path )
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
        [ append-relative-path ]
    } cond ;

: prepend-path ( path1 path2 -- path )
    swap append-path ; inline

: 3append-path ( path chunk1 chunk2 -- path' )
    [ append-path ] dip append-path ; inline

: file-name ( path -- string )
    dup root-directory? [
        trim-tail-separators
        dup last-path-separator [ 1 + tail ] [
            drop special-path? [ file-name ] when
        ] if
    ] unless ;

: file-stem ( path -- stem )
    file-name "." split1-last drop ;

: file-extension ( path -- extension )
    file-name "." split1-last nip ;

: path-components ( path -- seq )
    normalize-path path-separator split harvest ;

HOOK: resolve-symlinks os ( path -- path' )

M: object resolve-symlinks normalize-path ;

: resource-path ( path -- newpath )
    "resource-path" get prepend-path ;

HOOK: home io-backend ( -- dir )

M: object home "" resource-path ;

GENERIC: vocab-path ( path -- newpath )

GENERIC: absolute-path ( path -- path' )

M: string absolute-path
    "resource:" ?head [
        trim-head-separators resource-path
        absolute-path
    ] [
        "vocab:" ?head [
            trim-head-separators vocab-path
            absolute-path
        ] [
            "~" ?head [
                trim-head-separators home prepend-path
                absolute-path
        ] [
            current-directory get prepend-path
        ] if ] if
    ] if ;

M: object normalize-path ( path -- path' )
    absolute-path ;

: root-path* ( path -- path' )
    dup absolute-path? [
        dup [ path-separator? ] find
        drop 1 + head
    ] when ;

HOOK: root-path os ( path -- path' )

M: object root-path root-path* ;

: relative-path* ( path -- relative-path )
    dup absolute-path? [
        dup [ path-separator? ] find
        drop 1 + tail
    ] when ;

HOOK: relative-path os ( path -- path' )

M: object relative-path relative-path* ;

: canonicalize-path* ( path -- path' )
    [
        relative-path
        [ path-separator? ] split-when
        [ { "." "" } member? ] reject
        V{ } clone [
            dup ".." = [
                over empty?
                [ over push ]
                [ over ?last ".." = [ over push ] [ drop dup pop* ] if ] if
            ] [
                over push
            ] if
        ] reduce
    ] keep dup absolute-path? [
        [
            [ ".." = ] trim-head
            path-separator join
        ] dip root-path prepend-path
    ] [
        drop path-separator join [ "." ] when-empty
    ] if ;

HOOK: canonicalize-path io-backend ( path -- path' )

M: object canonicalize-path canonicalize-path* ;

TUPLE: pathname string ;

C: <pathname> pathname

M: pathname absolute-path string>> absolute-path ;

M: pathname <=> [ string>> ] compare ;