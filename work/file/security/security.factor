! Copyright (C) 2011 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries alien.syntax prettyprint
unix.types ;

<< "libc" "/usr/lib/libc.dylib" cdecl add-library >>

IN: file.security

LIBRARY: libc

ENUM: filesec_property_t
    { FILESEC_OWNER 1 }
    { FILESEC_GROUP 2 }
    { FILESEC_UUID 3 }
    { FILESEC_MODE 4 }
    { FILESEC_ACL 5 }
    { FILESEC_GRPUUID 6 }
    { FILESEC_ACL_RAW 100 }
    { FILESEC_ACL_ALLOCSIZE 101 }
;

C-TYPE: _filesec

TYPEDEF: _filesec* filesec_t
TYPEDEF: uchar[16] __darwin_uuid_t
TYPEDEF: __darwin_uuid_t uuid_t

FUNCTION: filesec_t filesec_init ( ) 
FUNCTION: int mbr_uid_to_uuid ( uid_t id, uuid_t uu ) 

: set-file-example ( -- )
    filesec_init .
    ;


