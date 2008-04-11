! Copyright (C) 2007 Elie CHAFTARI
! See http://factorcode.org/license.txt for BSD license.
!
! Tested with OpenLDAP 2.2.7.0.21 on Mac OS X 10.4.9 PowerPC

USING: alien alien.c-types assocs continuations hashtables io kernel
ldap.libldap math namespaces sequences ;

IN: ldap

SYMBOL: message
SYMBOL: ldp

! =========================================================
! Error interpretation routines
! =========================================================

: result-to-error ( ld res freeit -- num )
    ldap_result2error ;

: err-to-string ( err -- str )
    ldap_err2string ;

: check-result ( result -- )
    dup zero? [ drop ] [
        err-to-string throw
    ] if ;

: result-type ( result -- )
    result-types >hashtable at print ;

! =========================================================
! Initialization routines
! =========================================================

! deprecated in favor of ldap_initialize
: open ( host port -- ld )
    ldap_open ;

! deprecated in favor of ldap_initialize
: init ( host port -- ld )
    ldap_init ;

: initialize ( ld url -- )
    dupd ldap_initialize swap *void* ldp set check-result ;

: get-option ( ld option outvalue -- )
    ldap_get_option check-result ;

: set-option ( ld option invalue -- )
    ldap_set_option check-result ;

! =========================================================
! Bind operations
! =========================================================

: simple-bind ( ld who passwd -- id )
    ldap_simple_bind ;

: simple-bind-s ( ld who passwd -- )
    ldap_simple_bind_s check-result ;

: unbind-s ( ld -- )
    ldap_unbind_s check-result ;

: with-bind ( ld who passwd quot -- )
    -roll [ simple-bind-s [ ldp get unbind-s ] [ ] cleanup ] with-scope ; inline

! =========================================================
! Search operations
! =========================================================

: search ( ld base scope filter attrs attrsonly -- id )
    ldap_search ;

: search-s ( ld base scope filter attrs attrsonly res -- )
    ldap_search_s check-result ;

! =========================================================
! Return results of asynchronous operation routines
! =========================================================

: result ( ld msgid all timeout result -- )
    [ ldap_result ] keep *void* message set result-type ;

: parse-result ( ld result errcodep matcheddnp errmsgp referralsp serverctrlsp freeit -- )
    ldap_parse_result check-result ;

: count-messages ( ld result -- count )
    ldap_count_messages ;

: first-message ( ld result -- message )
    ldap_first_message ;

: next-message ( ld message -- message )
    ldap_next_message ;

: msgtype ( msg -- num )
    ldap_msgtype ;

: msgid ( msg -- num )
    ldap_msgid ;

: count-entries ( ld result -- count )
    ldap_count_entries ;

: first-entry ( ld result -- entry )
    ldap_first_entry ;

: next-entry ( ld entry -- entry )
    ldap_next_entry ;

: first-attribute ( ld entry berptr -- str )
    ldap_first_attribute ;

: next-attribute ( ld entry ber -- str )
    ldap_next_attribute ;

: get-values ( ld entry attr -- values )
    ldap_get_values ;

: get-dn ( ld entry -- str )
    ldap_get_dn ;

! =========================================================
! Public routines
! =========================================================

: get-message ( -- message )
    message get ;

: get-ldp ( -- ldp )
    ldp get ;
