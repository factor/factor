! Copyright (C) 2010 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors calendar combinators.short-circuit formatting
io io.backend io.directories io.encodings.utf8 io.files
io.files.info io.files.info.unix io.files.trash io.pathnames
kernel math math.parser sequences system unix.stat unix.users
xdg ;

IN: io.files.trash.unix

! Implements the FreeDesktop.org Trash Specification 0.7

<PRIVATE

: top-directory? ( path -- ? )
    dup ".." append-path [ link-status ] bi@
    [ [ st_dev>> ] same? not ] [ [ st_ino>> ] same? ] 2bi or ;

: top-directory ( path -- path' )
    [ dup top-directory? not ] [ ".." append-path ] while ;

: make-user-directory ( path -- )
    [ make-directories ] [ 0o700 set-file-permissions ] bi ;

: check-trash-path ( path -- )
    {
        [ file-info directory? ]
        [ sticky? ]
        [ link-info symbolic-link? not ]
    } 1&& [ "invalid trash path" throw ] unless ;

: trash-home ( -- path )
    xdg-data-home "Trash" append-path dup check-trash-path ;

: trash-1 ( root -- path )
    ".Trash" append-path dup check-trash-path
    real-user-id number>string append-path ;

: trash-2 ( root -- path )
    real-user-id ".Trash-%d" sprintf append-path ;

: trash-path ( path -- path' )
    top-directory dup trash-home top-directory = [
        drop trash-home
    ] [
        dup ".Trash" append-path file-exists?
        [ trash-1 ] [ trash-2 ] if
        [ make-user-directory ] keep
    ] if ;

: (safe-file-name) ( path counter -- path' )
    [
        [ parent-directory ]
        [ file-stem ]
        [ file-extension dup [ "." prepend ] when ] tri
    ] dip swap "%s%s %s%s" sprintf ;

: safe-file-name ( path -- path' )
    dup 0 [ over file-exists? ] [
        [ parent-directory to-directory ] [ 1 + ] bi*
        [ (safe-file-name) ] keep
    ] while drop nip ;

PRIVATE>

M: unix send-to-trash ( path -- )
    normalize-path dup trash-path [
        "files" append-path [ make-user-directory ] keep
        to-directory safe-file-name
    ] [
        "info" append-path [ make-user-directory ] keep
        to-directory ".trashinfo" append overd utf8 [
            "[Trash Info]" write nl
            "Path=" write write nl
            "DeletionDate=" write
            now "%Y-%m-%dT%H:%M:%S" strftime write nl
        ] with-file-writer
    ] bi move-file ;
