! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.data alien.destructors combinators
destructors io io.backend io.files io.files.acls.macos.ffi
kernel libc sequences unix.groups unix.types unix.users ;
QUALIFIED: io
IN: io.files.acls.macos

<PRIVATE

: unix-id>string ( byte-array id-type -- string )
    {
        { ID_TYPE_UID [ user-name "user:" prepend ] }
        { ID_TYPE_GID [ group-name "group:" prepend ] }
        ! [ uuid_string_t new [ mbr_uuid_to_string io-error ] keep ]
    } case ;

: acl-error ( n -- ) -1 = [ throw-errno ] when ; inline

:: file-acl ( path -- acl_t/f )
    path
    normalize-path
    clear-errno
    ACL_TYPE_EXTENDED acl_get_file dup [
        errno ENOENT = [
            [ path file-exists? ] preserve-errno
            [ drop f ] [ throw-errno ] if
        ] [
            throw-errno
        ] if
    ] unless ;

: free-acl ( acl -- ) acl_free acl-error ;

DESTRUCTOR: free-acl

: get-acl-entry ( acl_t n -- acl_entry_t )
    f acl_entry_t <ref> [ acl_get_entry ] 1check -1 = [ drop f ] when ;

: first-acl-entry ( acl_t -- acl_entry_t ) ACL_FIRST_ENTRY get-acl-entry ;
: next-acl-entry ( acl_t -- acl_entry_t ) ACL_NEXT_ENTRY get-acl-entry ;
: last-acl-entry ( acl_t -- acl_entry_t ) ACL_LAST_ENTRY get-acl-entry ;

PRIVATE>

: acl>text ( acl_t -- string ) f acl_to_text ;

:: acl-entry-each ( path quot -- )
    [
        path file-acl &free-acl :> acl
        f :> acl-entry!
        acl [
            acl first-acl-entry void* deref quot call
            [ acl next-acl-entry dup acl-entry! ]
            [ acl-entry void* deref quot call ] while
        ] when
    ] with-destructors ; inline

:: acl-each ( path quot -- )
    [
        path file-acl &free-acl :> acl
        acl [
            acl first-acl-entry drop
            acl quot call
            [ acl next-acl-entry ] [ acl quot call ] while
        ] when
    ] with-destructors ; inline

: acl-entry-map ( path quot -- seq )
    collector [ acl-entry-each ] dip ; inline

: acl-map ( path quot -- seq )
    collector [ acl-each ] dip ; inline

ERROR: acl-init-failed n ;

:: n>new-acl ( n -- acl )
    n acl_init dup [ n acl-init-failed ] unless ;

: new-acl ( -- acl ) 1 n>new-acl ; inline

: acl-valid? ( acl -- ? ) acl_valid [ acl-error ] keep 0 = ;

ERROR: add-permission-failed permission-set permission ;

: add-permission ( acl_permset permission -- )
    acl_add_perm acl-error ;

: acl-entry>permset ( acl_entry_t -- acl_permset )
    f acl_permset_t <ref> [ acl_get_permset acl-error ] keep ;

: filter-strings ( obj strings -- string )
    [ [ 1 = ] dip f ? ] 2map sift "," join ;

: permset>strings ( acl_permset -- strings )
    acl-perms [ acl_get_perm_np dup acl-error ] with map
    acl-perm-names filter-strings ;

: acl-entry>perm-strings ( acl_entry_t -- strings )
    acl-entry>permset permset>strings ;

: with-new-acl ( quot -- )
    [ [ new-acl &free-acl ] dip call ] with-destructors ; inline

: acls. ( path -- )
    [ acl>text io:write ] acl-each ;

: acl-entry>owner-name ( acl-entry -- string )
    [
        acl_get_qualifier dup acl-error &free-acl
        0 uid_t <ref> -1 int <ref> [ mbr_uuid_to_id io-error ] 2keep
        [ uint deref ] bi@ unix-id>string
    ] with-destructors ;

: acl-entry>tag-name ( acl-entry -- string )
    f acl_tag_t <ref> [ acl_get_tag_type acl-error ] keep
    uint deref acl_tag_t>string ;

: flagset>strings ( flagset -- strings )
    acl-flags [ acl_get_flag_np dup acl-error ] with map
    acl-flag-names filter-strings ;

: acl-entry>flagset ( acl-entry -- flagset )
    f acl_flagset_t <ref> [ acl_get_flagset_np acl-error ] keep ;

: acl-entry>flag-names ( acl-entry -- strings )
    acl-entry>flagset flagset>strings ;


! Acl, acl entry, principal, group,
! acl_get_qualifier, acl_get_tag_type, acl_get_flagset_np,
! acl_get_permset

! https://www.google.com/codesearch/p?hl=en#pFm0LxzAWvs/darwinsource/tarballs/apsl/file_cmds-116.10.tar.gz%7CFam4LGNxuqg/file_cmds-116.10/ls/print.c&q=acl_get_permset&d=6
