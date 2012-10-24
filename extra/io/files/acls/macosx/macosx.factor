! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.data alien.destructors alien.syntax
classes.struct combinators destructors io.backend io.files
kernel libc literals locals math.order prettyprint sequences
unix unix.ffi unix.groups unix.types unix.users ;
QUALIFIED: io
IN: io.files.acls.macosx

<PRIVATE

TYPEDEF: uint acl_type_t
TYPEDEF: uint acl_perm_t
TYPEDEF: void* acl_t
TYPEDEF: void* acl_entry_t
TYPEDEF: void* acl_permset_t
TYPEDEF: void* acl_flagset_t

CONSTANT: KAUTH_GUID_SIZE 16

CONSTANT: ACL_MAX_ENTRIES 128

! acl_entry_id_t
CONSTANT: ACL_FIRST_ENTRY 0
CONSTANT: ACL_NEXT_ENTRY -1
CONSTANT: ACL_LAST_ENTRY -2

! acl_type_t Supported:
CONSTANT: ACL_TYPE_EXTENDED 0x00000100
! acl_type_t Unsupported:
CONSTANT: ACL_TYPE_ACCESS 0x00000000
CONSTANT: ACL_TYPE_DEFAULT 0x00000001
CONSTANT: ACL_TYPE_AFS 0x00000002
CONSTANT: ACL_TYPE_CODA 0x00000003
CONSTANT: ACL_TYPE_NTFS 0x00000004
CONSTANT: ACL_TYPE_NWFS 0x00000005

! acl_perm_t
CONSTANT: ACL_READ_DATA        2
CONSTANT: ACL_LIST_DIRECTORY   2
CONSTANT: ACL_WRITE_DATA       4
CONSTANT: ACL_ADD_FILE         4
CONSTANT: ACL_EXECUTE          8
CONSTANT: ACL_SEARCH           8
CONSTANT: ACL_DELETE           16
CONSTANT: ACL_APPEND_DATA      32
CONSTANT: ACL_ADD_SUBDIRECTORY 32
CONSTANT: ACL_DELETE_CHILD     64
CONSTANT: ACL_READ_ATTRIBUTES  128
CONSTANT: ACL_WRITE_ATTRIBUTES 256
CONSTANT: ACL_READ_EXTATTRIBUTES 512
CONSTANT: ACL_WRITE_EXTATTRIBUTES 1024
CONSTANT: ACL_READ_SECURITY    2048
CONSTANT: ACL_WRITE_SECURITY   4096
CONSTANT: ACL_CHANGE_OWNER     8192

CONSTANT: acl-perms ${
    ACL_READ_DATA ACL_LIST_DIRECTORY ACL_WRITE_DATA ACL_ADD_FILE
    ACL_EXECUTE ACL_SEARCH ACL_DELETE ACL_APPEND_DATA ACL_ADD_SUBDIRECTORY
    ACL_DELETE_CHILD ACL_READ_ATTRIBUTES ACL_WRITE_ATTRIBUTES
    ACL_READ_EXTATTRIBUTES ACL_WRITE_EXTATTRIBUTES
    ACL_READ_SECURITY ACL_WRITE_SECURITY ACL_CHANGE_OWNER
}

CONSTANT: acl-perm-names
{
    "read" "list" "write" "add_file" "execute" "search"
    "delete" "append" "add_subdirectory" "delete_child"
    "readattr" "writeattr" "readextattr" "writeextattr"
    "readsecurity" "writesecurity" "chown"
}

CONSTANT: acl-file-perm { t f t f t f t t f f t t t t t t t }
CONSTANT: acl-dir-perm  { f t f t f t t f t t t t t t t t t }

! acl_tag_t
TYPEDEF: uint acl_tag_t
CONSTANT: ACL_UNDEFINED_TAG  0
CONSTANT: ACL_EXTENDED_ALLOW 1
CONSTANT: ACL_EXTENDED_DENY  2

ERROR: bad-acl-tag-t n ;

: acl_tag_t>string ( n -- string )
    dup 0 2 between? [ bad-acl-tag-t ] unless
    { "undefined" "allow" "deny" } nth ;

! acl_flag_t
TYPEDEF: int acl_flag_t
CONSTANT: ACL_FLAG_DEFER_INHERIT 1
CONSTANT: ACL_ENTRY_INHERITED 16
CONSTANT: ACL_ENTRY_FILE_INHERIT 32
CONSTANT: ACL_ENTRY_DIRECTORY_INHERIT 64
CONSTANT: ACL_ENTRY_LIMIT_INHERIT 128
CONSTANT: ACL_ENTRY_ONLY_INHERIT 256

CONSTANT: acl-flags ${
    ACL_ENTRY_FILE_INHERIT
    ACL_ENTRY_DIRECTORY_INHERIT
    ACL_ENTRY_LIMIT_INHERIT
    ACL_ENTRY_ONLY_INHERIT
}

CONSTANT: acl-flag-names {
    "file_inherit"
    "directory_inherit"
    "limit_inherit"
    "only_inherit"
}

STRUCT: guid_t
   { g_guid { uchar KAUTH_GUID_SIZE } } ;

TYPEDEF: uint kauth_ace_rights_t
STRUCT: kauth_ace
   { ace_applicable guid_t }
   { ace_flags uint }
   { ace_rights kauth_ace_rights_t } ;
TYPEDEF: kauth_ace* kauth_ace_t

STRUCT: kauth_acl
   { acl_entrycount uint }
   { acl_flags uint }
   { acl_ace { kauth_ace 1 } } ;
TYPEDEF: kauth_acl* kauth_acl_t

STRUCT: kauth_filesec
   { fsec_magic uint }
   { fsec_owner guid_t }
   { fsec_group guid_t } ;
TYPEDEF: kauth_filesec* kauth_filesec_t

FUNCTION: int acl_dup ( acl_t acl ) ;
FUNCTION: int acl_free ( void* obj_p ) ;
FUNCTION: acl_t acl_init ( int count ) ;

FUNCTION: acl_t acl_get_fd ( int fd ) ;
FUNCTION: acl_t acl_get_fd_np ( int fd, acl_type_t type ) ;
FUNCTION: acl_t acl_get_file ( char* path_p, acl_type_t type ) ;
FUNCTION: acl_t acl_get_link_np ( char* path_p, acl_type_t type ) ;

FUNCTION: int acl_set_file ( char* path_p, acl_type_t type, acl_t acl ) ;

FUNCTION: int acl_get_entry ( acl_t acl, int entry_id, acl_entry_t* entry_p ) ;

FUNCTION: int acl_get_permset ( acl_entry_t entry_d, acl_permset_t* permset_p ) ;
FUNCTION: int acl_get_perm_np ( acl_permset_t permset_d, acl_perm_t perm ) ;

FUNCTION: ssize_t acl_copy_ext ( void* buf_p, acl_t acl, ssize_t size ) ;
FUNCTION: ssize_t acl_copy_ext_native ( void* buf_p, acl_t acl, ssize_t size ) ;
FUNCTION: acl_t acl_copy_int ( void* buf_p ) ;
FUNCTION: acl_t acl_copy_int_native ( void* buf_p ) ;
FUNCTION: acl_t acl_from_text ( char* buf_p ) ;
FUNCTION: ssize_t acl_size ( acl_t acl ) ;
FUNCTION: char* acl_to_text ( acl_t acl, ssize_t* len_p ) ;
FUNCTION: int acl_valid ( acl_t acl ) ;
FUNCTION: int acl_add_perm ( acl_permset_t permset_d, acl_perm_t perm ) ;
FUNCTION: int acl_delete_perm ( acl_permset_t permset_d, acl_perm_t perm ) ;
FUNCTION: void* acl_get_qualifier ( acl_entry_t entry_d ) ;
FUNCTION: int acl_get_flagset_np ( void *obj, acl_flagset_t* flagset_p ) ;
FUNCTION: int acl_get_flag_np ( acl_flagset_t flagset_d, acl_flag_t flag ) ;
FUNCTION: int acl_get_tag_type ( acl_entry_t entry_d, acl_tag_t *tag_type_p ) ;

TYPEDEF: uchar[16] uuid_t
TYPEDEF: uint32_t uid_t

CONSTANT: ID_TYPE_UID 0
CONSTANT: ID_TYPE_GID 1
CONSTANT: ID_TYPE_SID 3
CONSTANT: ID_TYPE_USERNAME 4
CONSTANT: ID_TYPE_GROUPNAME 5
CONSTANT: ID_TYPE_GSS_EXPORT_NAME 10
CONSTANT: ID_TYPE_X509_DN 11
CONSTANT: ID_TYPE_KERBEROS 12

CONSTANT: NTSID_MAX_AUTHORITIES 16

! Supposed to be packed
STRUCT: nt_sid_t
    { sid_kind u_int8_t }
    { sid_authcount u_int8_t }
    { sid_authority u_int8_t[6] }
    { sid_authorities u_int32_t[NTSID_MAX_AUTHORITIES] } ;

FUNCTION: int mbr_uid_to_uuid ( uid_t id, uuid_t uu ) ;
FUNCTION: int mbr_gid_to_uuid ( gid_t id, uuid_t uu ) ;
FUNCTION: int mbr_uuid_to_id ( uuid_t uu, uid_t *id, int *id_type ) ;
FUNCTION: int mbr_sid_to_uuid ( nt_sid_t *sid, uuid_t uu ) ;
FUNCTION: int mbr_uuid_to_sid ( uuid_t uu, nt_sid_t *sid ) ;

TYPEDEF: char[37] uuid_string_t

FUNCTION: int mbr_uuid_to_string (  uuid_t uu, char* string ) ;

: unix-id>string ( byte-array id-type -- string )
    {
        { ID_TYPE_UID [ user-name "user:" prepend ] }
        { ID_TYPE_GID [ group-name "group:" prepend ] }
        ! [ uuid_string_t <struct> [ mbr_uuid_to_string io-error ] keep ]
    } case ;

: acl-error ( n -- ) -1 = [ (io-error) ] when ; inline

:: file-acl ( path -- acl_t/f )
    path
    normalize-path
    clear-errno
    ACL_TYPE_EXTENDED acl_get_file dup [
        errno ENOENT = [
            [ path exists? ] preserve-errno [ drop f ] [ (io-error) ] if
        ] [
            (io-error)
        ] if
    ] unless ;

: free-acl ( acl -- ) acl_free acl-error ;

DESTRUCTOR: free-acl

: get-acl-entry ( acl_t n -- acl_entry_t )
    acl_entry_t <struct> [ acl_get_entry ] keep swap -1 = [ drop f ] when ;

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
    acl_permset_t <struct> [ acl_get_permset acl-error ] keep ;

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
        uid_t <struct> -1 int <ref> [ mbr_uuid_to_id io-error ] 2keep
        [ uint deref ] bi@ unix-id>string
    ] with-destructors ;

: acl-entry>tag-name ( acl-entry -- string )
    acl_tag_t <struct> [ acl_get_tag_type acl-error ] keep
    uint deref acl_tag_t>string ;

: flagset>strings ( flagset -- strings )
    acl-flags [ acl_get_flag_np dup acl-error ] with map
    acl-flag-names filter-strings ;

: acl-entry>flagset ( acl-entry -- flagset )
    acl_flagset_t <struct> [ acl_get_flagset_np acl-error ] keep ;

: acl-entry>flag-names ( acl-entry -- strings )
    acl-entry>flagset flagset>strings ;


! Acl, acl entry, principal, group, 
! acl_get_qualifier, acl_get_tag_type, acl_get_flagset_np,
! acl_get_permset

! http://www.google.com/codesearch/p?hl=en#pFm0LxzAWvs/darwinsource/tarballs/apsl/file_cmds-116.10.tar.gz%7CFam4LGNxuqg/file_cmds-116.10/ls/print.c&q=acl_get_permset&d=6
