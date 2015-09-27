! Copyright (C) 2014 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays combinators.short-circuit combinators.smart
io.directories io.pathnames kernel math math.parser sequences
sorting sorting.human splitting sets ;
IN: forestdb.paths

CONSTANT: fdb-filename-base "fq"

: fdb-filename? ( path -- ? )
    "." split {
        [ length 3 = ]
        [ second fdb-filename-base = ]
        [ first string>number ]
        [ third string>number ]
    } 1&& ;

ERROR: not-an-fdb-filename string ;

: ensure-fdb-filename ( string -- string )
    dup fdb-filename? [ not-an-fdb-filename ] unless ;

ERROR: not-a-string-number string ;

: ?string>number ( string -- n )
    dup string>number dup [ nip ] [ not-a-string-number ] if ;

: change-string-number ( string quot -- string' )
    [ [ string>number ] dip call number>string ] 2keep drop
    length CHAR: 0 pad-head ; inline

: next-vnode-name ( string -- string' )
    [
        "." split
        first [ 1 + ] change-string-number
        "." fdb-filename-base ".0"
    ] "" append-outputs-as ;

: trim-head-zeros ( string -- string' )
    [ CHAR: 0 = ] trim-head 1 CHAR: 0 pad-head ;

: canonical-fdb-name ( string -- string' )
    ensure-fdb-filename
    "." split first3
    [ trim-head-zeros ]
    [ ]
    [ trim-head-zeros ] tri* 3array "." join ;

: next-vnode-version-name ( string -- string' )
    "." split
    [ but-last "." join ]
    [ last [ 1 + ] change-string-number ] bi "." glue ;

: path>next-vnode-path ( path -- path' )
    dup directory-files
    [ fdb-filename? ] filter
    [ human<=> ] sort [
        fdb-filename-base "0." ".0" surround append-path
    ] [
        last "." split first [ 1 + ] change-string-number
        ".fq.0" append append-path
    ] if-empty ;

: path-has-fdb? ( path -- ? )
    directory-files [ fdb-filename? ] filter length 0 > ;

: path-only-fdb? ( path -- ? )
    directory-files
    [ length ]
    [ [ fdb-filename? ] filter length ] bi = ;

: path-fdb-duplicates ( path -- seq )
    directory-files [ canonical-fdb-name ] map members ;

: ensure-fdb-directory ( filename -- filename )
    [ make-directories ] keep ;

: ensure-fdb-filename-directory ( filename -- filename )
    [ parent-directory make-directories ] keep ;

! : path>next-vnode-version-name ( path -- path' )
    ! [ file-name ]
