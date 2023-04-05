! Copyright (C) 2011 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel ;
IN: file.security

HELP: <filesec_property_t>
{ $values
    { "number" null }
    { "enum" null }
}
{ $description "" } ;

HELP: FILESEC_ACL
{ $var-description "" } ;

HELP: FILESEC_ACL_ALLOCSIZE
{ $var-description "" } ;

HELP: FILESEC_ACL_RAW
{ $var-description "" } ;

HELP: FILESEC_GROUP
{ $var-description "" } ;

HELP: FILESEC_GRPUUID
{ $var-description "" } ;

HELP: FILESEC_MODE
{ $var-description "" } ;

HELP: FILESEC_OWNER
{ $var-description "" } ;

HELP: FILESEC_UUID
{ $var-description "" } ;

HELP: __darwin_uuid_t
{ $var-description "" } ;

HELP: _filesec
{ $var-description "" } ;

HELP: filesec_init
{ $values
    { ")" null }
    { "filesec_t" null }
}
{ $description "" } ;

HELP: filesec_property_t
{ $var-description "" } ;

HELP: filesec_t
{ $var-description "" } ;

HELP: mbr_uid_to_uuid
{ $values
    { "id" null } { "uu" null }
    { "int" null }
}
{ $description "" } ;

HELP: set-file-example
{ $values
    { "ACL" null }    
}
{ $description "" } ;

HELP: uuid_t
{ $var-description "" } ;

ARTICLE: "file.security" "file.security"
{ $vocab-link "file.security" }
;

ABOUT: "file.security"
