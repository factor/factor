! Copyright (C) 2010 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax classes.struct kernel
literals math.order sequences unix.types ;
IN: io.files.acls.macosx.ffi

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

FUNCTION: int acl_dup ( acl_t acl )
FUNCTION: int acl_free ( void* obj_p )
FUNCTION: acl_t acl_init ( int count )

FUNCTION: acl_t acl_get_fd ( int fd )
FUNCTION: acl_t acl_get_fd_np ( int fd, acl_type_t type )
FUNCTION: acl_t acl_get_file ( c-string path_p, acl_type_t type )
FUNCTION: acl_t acl_get_link_np ( c-string path_p, acl_type_t type )

FUNCTION: int acl_set_file ( c-string path_p, acl_type_t type, acl_t acl )

FUNCTION: int acl_get_entry ( acl_t acl, int entry_id, acl_entry_t* entry_p )

FUNCTION: int acl_get_permset ( acl_entry_t entry_d, acl_permset_t* permset_p )
FUNCTION: int acl_get_perm_np ( acl_permset_t permset_d, acl_perm_t perm )

FUNCTION: ssize_t acl_copy_ext ( void* buf_p, acl_t acl, ssize_t size )
FUNCTION: ssize_t acl_copy_ext_native ( void* buf_p, acl_t acl, ssize_t size )
FUNCTION: acl_t acl_copy_int ( void* buf_p )
FUNCTION: acl_t acl_copy_int_native ( void* buf_p )
FUNCTION: acl_t acl_from_text ( c-string buf_p )
FUNCTION: ssize_t acl_size ( acl_t acl )
FUNCTION: c-string acl_to_text ( acl_t acl, ssize_t* len_p )
FUNCTION: int acl_valid ( acl_t acl )
FUNCTION: int acl_add_perm ( acl_permset_t permset_d, acl_perm_t perm )
FUNCTION: int acl_delete_perm ( acl_permset_t permset_d, acl_perm_t perm )
FUNCTION: void* acl_get_qualifier ( acl_entry_t entry_d )
FUNCTION: int acl_get_flagset_np ( void *obj, acl_flagset_t* flagset_p )
FUNCTION: int acl_get_flag_np ( acl_flagset_t flagset_d, acl_flag_t flag )
FUNCTION: int acl_get_tag_type ( acl_entry_t entry_d, acl_tag_t *tag_type_p )

TYPEDEF: uchar[16] uuid_t

CONSTANT: ID_TYPE_UID 0
CONSTANT: ID_TYPE_GID 1
CONSTANT: ID_TYPE_SID 3
CONSTANT: ID_TYPE_USERNAME 4
CONSTANT: ID_TYPE_GROUPNAME 5
CONSTANT: ID_TYPE_GSS_EXPORT_NAME 10
CONSTANT: ID_TYPE_X509_DN 11
CONSTANT: ID_TYPE_KERBEROS 12

CONSTANT: NTSID_MAX_AUTHORITIES 16

! FIXME: Supposed to be packed
STRUCT: nt_sid_t
    { sid_kind u_int8_t }
    { sid_authcount u_int8_t }
    { sid_authority u_int8_t[6] }
    { sid_authorities u_int32_t[NTSID_MAX_AUTHORITIES] } ;

FUNCTION: int mbr_uid_to_uuid ( uid_t id, uuid_t uu )
FUNCTION: int mbr_gid_to_uuid ( gid_t id, uuid_t uu )
FUNCTION: int mbr_uuid_to_id ( uuid_t uu, uid_t *id, int *id_type )
FUNCTION: int mbr_sid_to_uuid ( nt_sid_t *sid, uuid_t uu )
FUNCTION: int mbr_uuid_to_sid ( uuid_t uu, nt_sid_t *sid )

TYPEDEF: char[37] uuid_string_t

FUNCTION: int mbr_uuid_to_string ( uuid_t uu, c-string string )
