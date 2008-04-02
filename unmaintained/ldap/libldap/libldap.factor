! Copyright (C) 2007 Elie CHAFTARI
! See http://factorcode.org/license.txt for BSD license.
!
! Tested with OpenLDAP 2.2.7.0.21 on Mac OS X 10.4.9 PowerPC
!
! export LD_LIBRARY_PATH=/opt/local/lib

USING: alien alien.syntax combinators kernel system ;

IN: ldap.libldap

<< "libldap" {
    { [ win32? ]  [ "libldap.dll" "stdcall" ] }
    { [ macosx? ] [ "libldap.dylib" "cdecl" ] }
    { [ unix? ]   [ "libldap.so" "cdecl" ] }
} cond add-library >>
 
: LDAP_VERSION1     1 ; inline
: LDAP_VERSION2     2 ; inline 
: LDAP_VERSION3     3 ; inline

: LDAP_VERSION_MIN  LDAP_VERSION2 ; inline  
: LDAP_VERSION      LDAP_VERSION2 ; inline
: LDAP_VERSION_MAX  LDAP_VERSION3 ; inline

: LDAP_PORT         389 ; inline ! ldap:///   default LDAP port
: LDAPS_PORT        636 ; inline ! ldaps:///  default LDAP over TLS port

: LDAP_SCOPE_BASE         HEX: 0000              ; inline
: LDAP_SCOPE_BASEOBJECT   LDAP_SCOPE_BASE        ; inline
: LDAP_SCOPE_ONELEVEL     HEX: 0001              ; inline
: LDAP_SCOPE_ONE          LDAP_SCOPE_ONELEVEL    ; inline
: LDAP_SCOPE_SUBTREE      HEX: 0002              ; inline
: LDAP_SCOPE_SUB          LDAP_SCOPE_SUBTREE     ; inline
: LDAP_SCOPE_SUBORDINATE  HEX: 0003              ; inline ! OpenLDAP extension
: LDAP_SCOPE_CHILDREN     LDAP_SCOPE_SUBORDINATE ; inline
: LDAP_SCOPE_DEFAULT      -1                     ; inline ! OpenLDAP extension

: LDAP_RES_ANY            -1 ; inline
: LDAP_RES_UNSOLICITED     0 ; inline

! how many messages to retrieve results for
: LDAP_MSG_ONE             HEX: 00 ; inline
: LDAP_MSG_ALL             HEX: 01 ; inline
: LDAP_MSG_RECEIVED        HEX: 02 ; inline

! the possible result types returned
: LDAP_RES_BIND             HEX: 61 ; inline
: LDAP_RES_SEARCH_ENTRY     HEX: 64 ; inline
: LDAP_RES_SEARCH_REFERENCE HEX: 73 ; inline
: LDAP_RES_SEARCH_RESULT    HEX: 65 ; inline
: LDAP_RES_MODIFY           HEX: 67 ; inline
: LDAP_RES_ADD              HEX: 69 ; inline
: LDAP_RES_DELETE           HEX: 6b ; inline
: LDAP_RES_MODDN            HEX: 6d ; inline
: LDAP_RES_COMPARE          HEX: 6f ; inline
: LDAP_RES_EXTENDED         HEX: 78 ; inline
: LDAP_RES_EXTENDED_PARTIAL HEX: 79 ; inline

: result-types ( -- seq ) {
    { HEX: 61  "LDAP_RES_BIND" }
    { HEX: 64  "LDAP_RES_SEARCH_ENTRY" }
    { HEX: 73  "LDAP_RES_SEARCH_REFERENCE" }
    { HEX: 65  "LDAP_RES_SEARCH_RESULT" }
    { HEX: 67  "LDAP_RES_MODIFY" }
    { HEX: 69  "LDAP_RES_ADD" }
    { HEX: 6b  "LDAP_RES_DELETE" }
    { HEX: 6d  "LDAP_RES_MODDN" }
    { HEX: 6f  "LDAP_RES_COMPARE" }
    { HEX: 78  "LDAP_RES_EXTENDED" }
    { HEX: 79  "LDAP_RES_EXTENDED_PARTIAL" }
} ;

: LDAP_OPT_PROTOCOL_VERSION HEX: 0011 ; inline

C-STRUCT: ldap 
    { "char" "ld_lberoptions" }
    { "int" "ld_deref" }
    { "int" "ld_timelimit" }
    { "int" "ld_sizelimit" }
    { "int" "ld_errno" }
    { "char*" "ld_error" }
    { "char*" "ld_matched" }
    { "int" "ld_refhoplimit" }
    { "ulong" "ld_options" } ;

LIBRARY: libldap

! ===============================================
! ldap.h
! ===============================================

! Will be depreciated in a later release (ldap_init() is preferred)
FUNCTION: void* ldap_open ( char* host, int port ) ;

FUNCTION: void* ldap_init ( char* host, int port ) ;

FUNCTION: int ldap_initialize ( ldap* ld, char* url ) ;

FUNCTION: int ldap_get_option ( void* ld, int option, void* outvalue ) ;

FUNCTION: int ldap_set_option ( void* ld, int option, void* invalue ) ;

FUNCTION: int ldap_simple_bind ( void* ld, char* who, char* passwd ) ;

FUNCTION: int ldap_simple_bind_s ( void* ld, char* who, char* passwd ) ;

FUNCTION: int ldap_unbind_s ( void* ld ) ;

FUNCTION: int ldap_result2error ( void* ld, void* res, int freeit ) ;

FUNCTION: char* ldap_err2string ( int err ) ;

FUNCTION: int ldap_search ( void* ld, char* base, int scope, char* filter, 
                           char* attrs, int attrsonly ) ;

FUNCTION: int ldap_search_s ( void* ld, char* base, int scope, char* filter,
                             char* attrs, int attrsonly, void* res ) ;

FUNCTION: int ldap_result ( void* ld, int msgid, int all, void* timeout,
                            void* result ) ;

FUNCTION: int ldap_parse_result ( void* ld, void* result, int* errcodep,
                                 char* matcheddnp, char* errmsgp, 
                                 char* referralsp, void* serverctrlsp, 
                                 int freeit ) ;

FUNCTION: int ldap_count_messages ( void* ld, void* result ) ;

FUNCTION: void* ldap_first_message ( void* ld, void* result ) ;

FUNCTION: void* ldap_next_message ( void* ld, void* message ) ;

FUNCTION: int ldap_msgtype ( void* msg ) ;

FUNCTION: int ldap_msgid ( void* msg ) ;

FUNCTION: int ldap_count_entries ( void* ld, void* result ) ;

FUNCTION: void* ldap_first_entry ( void* ld, void* result ) ;

FUNCTION: void* ldap_next_entry ( void* ld, void* entry ) ;

FUNCTION: char* ldap_first_attribute ( void* ld, void* entry, void* berptr ) ;

FUNCTION: char* ldap_next_attribute ( void* ld, void* entry, void* ber ) ;

FUNCTION: char** ldap_get_values ( void* ld, void* entry, char* attr ) ;

FUNCTION: char* ldap_get_dn ( void* ld, void* entry ) ;
