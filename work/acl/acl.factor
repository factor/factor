! Copyright (C) 2011 PolyMicro Systems.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data alien.libraries
alien.syntax combinators destructors file.security kernel
c-types-ext literals locals math tools.continuations unix.ffi unix.types ;

<< "libc" "/usr/lib/libc.dylib" cdecl add-library >>

IN: acl

LIBRARY: libc

CONSTANT: __DARWIN_ACL_READ_DATA $[ 1 1 shift ]
ALIAS: __DARWIN_ACL_LIST_DIRECTORY __DARWIN_ACL_READ_DATA
CONSTANT: __DARWIN_ACL_WRITE_DATA $[ 1 2 shift ]
ALIAS: __DARWIN_ACL_ADD_FILE __DARWIN_ACL_WRITE_DATA
CONSTANT: __DARWIN_ACL_EXECUTE $[ 1 3 shift ]
ALIAS: __DARWIN_ACL_SEARCH __DARWIN_ACL_EXECUTE
CONSTANT: __DARWIN_ACL_DELETE $[ 1 4 shift ]
CONSTANT: __DARWIN_ACL_APPEND_DATA $[ 1 5 shift ]
ALIAS: __DARWIN_ACL_ADD_SUBDIRECTORY __DARWIN_ACL_APPEND_DATA
CONSTANT: __DARWIN_ACL_DELETE_CHILD $[ 1 6 shift ]
CONSTANT: __DARWIN_ACL_READ_ATTRIBUTES $[ 1 7 shift ]
CONSTANT: __DARWIN_ACL_WRITE_ATTRIBUTES $[ 1 8 shift ]
CONSTANT: __DARWIN_ACL_READ_EXTATTRIBUTES $[ 1 9 shift ]
CONSTANT: __DARWIN_ACL_WRITE_EXTATTRIBUTES $[ 1 10 shift ]
CONSTANT: __DARWIN_ACL_READ_SECURITY $[ 1 11 shift ]
CONSTANT: __DARWIN_ACL_WRITE_SECURITY $[ 1 12 shift ]
CONSTANT: __DARWIN_ACL_CHANGE_OWNER $[ 1 13 shift ]
CONSTANT: __DARWIN_ACL_EXTENDED_ALLOW 1
CONSTANT: __DARWIN_ACL_EXTENDED_DENY 2
CONSTANT: __DARWIN_ACL_ENTRY_INHERITED $[ 1 4 shift ]
CONSTANT: __DARWIN_ACL_ENTRY_FILE_INHERIT $[ 1 5 shift ]
CONSTANT: __DARWIN_ACL_ENTRY_DIRECTORY_INHERIT $[ 1 6 shift ]
CONSTANT: __DARWIN_ACL_ENTRY_LIMIT_INHERIT $[ 1 7 shift ]
CONSTANT: __DARWIN_ACL_ENTRY_ONLY_INHERIT $[ 1 8 shift ]
CONSTANT: __DARWIN_ACL_FLAG_NO_INHERIT $[ 1 17 shift ]

CONSTANT: ACL_MAX_ENTRIES  128

ENUM: acl_perm_t
    { ACL_READ_DATA $ __DARWIN_ACL_READ_DATA }
    { ACL_LIST_DIRECTORY $ __DARWIN_ACL_LIST_DIRECTORY }
    { ACL_WRITE_DATA $ __DARWIN_ACL_WRITE_DATA }
    { ACL_ADD_FILE $ __DARWIN_ACL_ADD_FILE }
    { ACL_EXECUTE $ __DARWIN_ACL_EXECUTE }
    { ACL_SEARCH $ __DARWIN_ACL_SEARCH }
    { ACL_DELETE $ __DARWIN_ACL_DELETE }
    { ACL_APPEND_DATA $ __DARWIN_ACL_APPEND_DATA }
    { ACL_ADD_SUBDIRECTORY $ __DARWIN_ACL_ADD_SUBDIRECTORY }
    { ACL_DELETE_CHILD $ __DARWIN_ACL_DELETE_CHILD }
    { ACL_READ_ATTRIBUTES $ __DARWIN_ACL_READ_ATTRIBUTES }
    { ACL_WRITE_ATTRIBUTES $ __DARWIN_ACL_WRITE_ATTRIBUTES }
    { ACL_READ_EXTATTRIBUTES $ __DARWIN_ACL_READ_EXTATTRIBUTES }
    { ACL_WRITE_EXTATTRIBUTES $ __DARWIN_ACL_WRITE_EXTATTRIBUTES }
    { ACL_READ_SECURITY $ __DARWIN_ACL_READ_SECURITY }
    { ACL_WRITE_SECURITY $ __DARWIN_ACL_WRITE_SECURITY }
    { ACL_CHANGE_OWNER $ __DARWIN_ACL_CHANGE_OWNER }
;
  
ENUM: acl_tag_t
    { ACL_UNDEFINED_TAG 0x0 }
    { ACL_EXTENDED_ALLOW $ __DARWIN_ACL_EXTENDED_ALLOW }
    { ACL_EXTENDED_DENY $ __DARWIN_ACL_EXTENDED_DENY }
    ;
  
ENUM: acl_type_t
    { ACL_TYPE_EXTENDED 0x00000100 }
    { ACL_TYPE_ACCESS 0x00000000 }
    { ACL_TYPE_DEFAULT 0x00000001 }
    { ACL_TYPE_AFS 0x00000002 }
    { ACL_TYPE_CODA 0x00000003 }
    { ACL_TYPE_NTFS 0x00000004 }
    { ACL_TYPE_NWFS 0x00000005 }
;
  
CONSTANT: ACL_UNDEFINED_ID 0 

ENUM: acl_entry_id_t
    { ACL_FIRST_ENTRY 0 }
    { ACL_NEXT_ENTRY -1 }
    { ACL_LAST_ENTRY -2 }
    ;

ENUM: acl_flag_t
    { ACL_FLAG_DEFER_INHERIT 1 }
    { ACL_FLAG_NO_INHERIT $ __DARWIN_ACL_FLAG_NO_INHERIT }
    { ACL_ENTRY_INHERITED $ __DARWIN_ACL_ENTRY_INHERITED }
    { ACL_ENTRY_FILE_INHERIT $ __DARWIN_ACL_ENTRY_FILE_INHERIT }
    { ACL_ENTRY_DIRECTORY_INHERIT $ __DARWIN_ACL_ENTRY_DIRECTORY_INHERIT }
    { ACL_ENTRY_LIMIT_INHERIT $ __DARWIN_ACL_ENTRY_LIMIT_INHERIT }
    { ACL_ENTRY_ONLY_INHERIT $ __DARWIN_ACL_ENTRY_ONLY_INHERIT }
;
  
C-TYPE: _acl
C-TYPE: _acl_entry
C-TYPE: _acl_permset
C-TYPE: _acl_flagset

TYPEDEF: _acl* acl_t
TYPEDEF: _acl_entry* acl_entry_t
TYPEDEF: _acl_permset* acl_permset_t
TYPEDEF: _acl_flagset* acl_flagset_t
TYPEDEF: u_int64_t  acl_permset_mask_t

FUNCTION: acl_t acl_dup ( acl_t acl )
FUNCTION: int acl_free ( void* obj_p )
FUNCTION: acl_t acl_init ( int count )
FUNCTION: int acl_copy_entry ( acl_entry_t dest_d, acl_entry_t src_d )
FUNCTION: int acl_create_entry ( acl_t* acl_p, acl_entry_t* entry_p )
FUNCTION: int acl_create_entry_np ( acl_t* acl_p, acl_entry_t* entry_p, int entry_index )
FUNCTION: int acl_delete_entry ( acl_t acl, acl_entry_t entry_d )
FUNCTION: int acl_get_entry ( acl_t acl, int entry_id, acl_entry_t* entry_p )
FUNCTION: int acl_valid ( acl_t acl )
FUNCTION: int acl_valid_fd_np ( int fd, acl_type_t type, acl_t acl )
FUNCTION: int acl_valid_file_np ( c-string path, acl_type_t type, acl_t acl )
FUNCTION: int acl_valid_link_np ( c-string path, acl_type_t type, acl_t acl )

FUNCTION: int acl_add_perm ( acl_permset_t permset_d, acl_perm_t perm )
FUNCTION: int acl_calc_mask ( acl_t* acl_p ) 
FUNCTION: int acl_clear_perms ( acl_permset_t permset_d )
FUNCTION: int acl_delete_perm ( acl_permset_t permset_d, acl_perm_t perm )
FUNCTION: int acl_get_perm_np ( acl_permset_t permset_d, acl_perm_t perm )
FUNCTION: int acl_get_permset ( acl_entry_t entry_d, acl_permset_t* permset_p )
FUNCTION: int acl_set_permset ( acl_entry_t entry_d, acl_permset_t permset_d )

FUNCTION: int acl_maximal_permset_mask_np ( acl_permset_mask_t*  mask_p )
FUNCTION: int acl_get_permset_mask_np ( acl_entry_t entry_d, acl_permset_mask_t*  mask_p )
FUNCTION: int acl_set_permset_mask_np ( acl_entry_t entry_d, acl_permset_mask_t mask )

FUNCTION: int acl_add_flag_np ( acl_flagset_t flagset_d, acl_flag_t flag )
FUNCTION: int acl_clear_flags_np ( acl_flagset_t flagset_d )
FUNCTION: int acl_delete_flag_np ( acl_flagset_t flagset_d, acl_flag_t flag )
FUNCTION: int acl_get_flag_np ( acl_flagset_t flagset_d, acl_flag_t flag )
FUNCTION: int acl_get_flagset_np ( void* obj_p, acl_flagset_t* flagset_p )
FUNCTION: int acl_set_flagset_np ( void* obj_p, acl_flagset_t flagset_d )

FUNCTION: void* acl_get_qualifier ( acl_entry_t entry_d )
FUNCTION: int acl_get_tag_type ( acl_entry_t entry_d, acl_tag_t* tag_type_p )
FUNCTION: int acl_set_qualifier ( acl_entry_t entry_d, void* tag_qualifier_p )
FUNCTION: int acl_set_tag_type ( acl_entry_t entry_d, acl_tag_t tag_type )

FUNCTION: int acl_delete_def_file ( c-string path_p ) 
FUNCTION: acl_t  acl_get_fd ( int fd )
FUNCTION: acl_t acl_get_fd_np ( int fd, acl_type_t type )
FUNCTION: acl_t acl_get_file ( c-string path_p, acl_type_t type )
FUNCTION: acl_t acl_get_link_np ( c-string path_p, acl_type_t type )
FUNCTION: int acl_set_fd ( int fd, acl_t acl )
FUNCTION: int acl_set_fd_np ( int fd, acl_t acl, acl_type_t acl_type )
FUNCTION: int acl_set_file ( c-string path_p, acl_type_t type, acl_t acl )
FUNCTION: int acl_set_link_np ( c-string path_p, acl_type_t type, acl_t acl )

FUNCTION: ssize_t acl_copy_ext ( void* buf_p, acl_t acl, ssize_t size )
FUNCTION: ssize_t acl_copy_ext_native ( void* buf_p, acl_t acl, ssize_t size )
FUNCTION: acl_t acl_copy_int ( void* buf_p )
FUNCTION: acl_t acl_copy_int_native ( void* buf_p )
FUNCTION: acl_t acl_from_text ( c-string buf_p )
FUNCTION: ssize_t acl_size ( acl_t acl )
FUNCTION: char* acl_to_text ( acl_t acl, ssize_t* len_p )

! <<
! CONSTANT: ROPERMS $[ ACL_READ_DATA
!                      ACL_READ_SECURITY or
!                      ACL_READ_ATTRIBUTES or
!                      ACL_READ_EXTATTRIBUTES or ]
! >>

TUPLE: ACL < disposable acl ace perms tag qualifer error ;

! if (0 != acl_create_entry(&acl, &ace))
: create-acl ( ACL -- )
    ACL_MAX_ENTRIES acl_init
     acl_t <ref> >>acl
     drop
    ;

: create-ace ( ACL -- )
    f acl_entry_t <ref> >>ace
     drop
    ;

: <ACL> ( -- ACL )
    ACL new-disposable dup
    {
        [ create-acl ]
        [ create-ace ]
        [ acl>> ] 
        [ ace>> acl_create_entry ]
        [ ace>> acl_entry_t deref ]
        [ ace<< ]
        [ acl>> acl_t deref ]
        [ acl<< ]
        [ error<< ]
    } cleave
;

! int acl_set_tag_type(acl_entry_t entry_d, acl_tag_t tag_type);
! if (0 != acl_set_tag_type(ace, ACL_EXTENDED_ALLOW ))
: set-tag-type ( ACL tag -- ? )
    ! acl_tag_t <ref> >>tag
    >>tag
    [ ace>> ] keep
    tag>> acl_set_tag_type ;

! if (0 != acl_set_qualifier(ace, uuid))
: set-qualifer ( ACL qualifer -- ? )
    >>qualifer
    [ ace>> ] keep
    qualifer>> 
    acl_set_qualifier ;

! if (0 != acl_get_permset(ace, &perms))
:: get-permset ( ACL -- ? )
    ACL ace>>
    ACL perms>> acl_permset_t <ref> 
    [ acl_get_permset ] keep
    acl_permset_t deref
    ACL perms<<
    ;
! if (0 != acl_clear_perms(perms))
: clear-permset ( ACL -- ? )
    perms>>
    acl_clear_perms ;

! if (0 != acl_add_perm(perms, ROPERMS))
: add-permset ( ACL permset -- ? )
    [ perms>> ] dip
    acl_add_perm ;

! if (0 != acl_set_permset(ace, perms))
: set-permset ( ACL -- ? )
    [ ace>> ] keep 
    perms>>
    acl_set_permset ;

! int
! main(void)
! {
!     int result;
!     long retval;
!     uuid_t *uuid=NULL;

!     /* check to see if ACLs are supported in the current directory*/
!     if (-1 == (retval = pathconf(".", _PC_EXTENDED_SECURITY_NP))) {
!         err(1, "pathconf()");
!     } else {
!         if(0 == retval) {
!             fprintf(stderr,
!                 "ACLs not supported here (retval=%ld)\n",
!                 retval);
!             exit(1);
!         }
!     }


!     if (NULL == (uuid = (uuid_t *)calloc(1,sizeof(uuid_t))))
!         err(1, "unable to allocate a uuid");

!     if (0 != mbr_uid_to_uuid(getuid(), *uuid)) {
!         perror("mbr_uid_to_uuid()");
!         free(uuid);
!         exit(1);
!     }

!     result = acl_readonly_example(uuid);
!     free(uuid);

!     printf("result=%d\n", result);
!     return(result);
! }

: acl-get-uuid ( -- uuid x x x )
    getuid
    uuid_t make-c-array
    [ mbr_uid_to_uuid ] keep swap
    [ ]
    [ throw ] 
    ; 

: acl_readonly_example ( -- ACL x x x )
    <ACL>
    [ ACL_EXTENDED_ALLOW set-tag-type ] keep nip
    [ acl-get-uuid set-qualifer ] keep nip
    [ get-permset ] keep nip
    [ clear-permset ] keep nip
    [ break 0x820a add-permset ] keep nip
!    [ perms>> 1 dm ] keep 
    [ set-permset ] keep nip
    ;

! if (0 != mbr_uid_to_uuid(getuid(), *uuid)) {


