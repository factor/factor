! Copyright (C) 2007 Elie CHAFTARI
! See http://factorcode.org/license.txt for BSD license.
!
! Adapted from oci.h and ociap.h
! Tested with Oracle version - 10.1.0.3 Instant Client

USING: alien alien.c-types alien.strings combinators kernel math
namespaces oracle.liboci prettyprint sequences
io.encodings.ascii accessors ;

IN: oracle

SYMBOL: env
SYMBOL: err
SYMBOL: srv
SYMBOL: svc
SYMBOL: ses
SYMBOL: stm
SYMBOL: buf
SYMBOL: res

SYMBOL: con

TUPLE: connection username password db ;

C: <connection> connection

! =========================================================
! Error-handling routines
! =========================================================

: get-oci-error ( object -- * )
    1 f "uint*" <c-object> dup >r 512 "uchar" <c-array> dup >r
    512 OCI_HTYPE_ERROR OCIErrorGet r> r> *uint drop
    ascii alien>string throw ;

: check-result ( result -- )
    {
        { OCI_SUCCESS [ ] }
        { OCI_ERROR [ err get get-oci-error ] }
        { OCI_INVALID_HANDLE [ "invalid handle" throw ] }
        [ "operation failed" throw ]
    } case ;

: check-status ( status -- bool )
    {
        { OCI_SUCCESS [ t ] }
        { OCI_ERROR [ err get get-oci-error ] }
        { OCI_INVALID_HANDLE [ "invalid handle" throw ] }
        { OCI_NO_DATA [ f ] }
        [ "operation failed" throw ]
    } case ;

! =========================================================
! Initialization and handle-allocation routines
! =========================================================

! Legacy initialization routine
: oci-initialize ( -- )
    OCI_DEFAULT f f f f OCIInitialize check-result ;

! Legacy initialization routine
: oci-env-init ( -- )
    "void*" <c-object> dup OCI_DEFAULT 0 f OCIEnvInit
    check-result *void* env set ;

: create-environment ( -- )
    "void*" <c-object> dup OCI_DEFAULT f f f f 0 f OCIEnvCreate 
    check-result *void* env set ;

: allocate-error-handle ( -- )
    env get
    "void*" <c-object> tuck OCI_HTYPE_ERROR 0 f OCIHandleAlloc 
    check-result *void* err set ;

: allocate-service-handle ( -- )
    env get
    "void*" <c-object> tuck OCI_HTYPE_SVCCTX 0 f OCIHandleAlloc 
    check-result *void* svc set ;

: allocate-session-handle ( -- )
    env get
    "void*" <c-object> tuck OCI_HTYPE_SESSION 0 f OCIHandleAlloc 
    check-result *void* ses set ;

: allocate-server-handle ( -- )
    env get
    "void*" <c-object> tuck OCI_HTYPE_SERVER 0 f OCIHandleAlloc 
    check-result *void* srv set ;

: init ( -- )
    oci-initialize
    oci-env-init
    allocate-error-handle
    allocate-service-handle
    allocate-session-handle
    allocate-server-handle ;

! =========================================================
! Single user session logon routine
! =========================================================

: oci-log-on ( -- )
    env get err get svc get 
    con get username>> dup length swap ascii malloc-string swap 
    con get password>> dup length swap ascii malloc-string swap
    con get db>> dup length swap ascii malloc-string swap
    OCILogon check-result ;

! =========================================================
! Attach to server and attribute-setting routines
! =========================================================

: attach-to-server ( -- )
    srv get err get con get db>> dup length OCI_DEFAULT
    OCIServerAttach check-result ;

: set-service-attribute ( -- )
    svc get OCI_HTYPE_SVCCTX srv get 0 OCI_ATTR_SERVER err get OCIAttrSet check-result ;

: set-username-attribute ( -- )
    ses get OCI_HTYPE_SESSION con get username>> dup length swap ascii malloc-string swap 
    OCI_ATTR_USERNAME err get OCIAttrSet check-result ;

: set-password-attribute ( -- )
    ses get OCI_HTYPE_SESSION con get password>> dup length swap ascii malloc-string swap 
    OCI_ATTR_PASSWORD err get OCIAttrSet check-result ;

: set-attributes ( -- )
    set-service-attribute
    set-username-attribute
    set-password-attribute ;

! =========================================================
! Session startup routines
! =========================================================

: begin-session ( -- )
    svc get err get ses get OCI_CRED_RDBMS OCI_DEFAULT OCISessionBegin check-result ;

: set-authentication-handle ( -- )
    svc get OCI_HTYPE_SVCCTX ses get 0 OCI_ATTR_SESSION err get OCIAttrSet check-result ;

! =========================================================
! Statement preparation and execution routines
! =========================================================

: allocate-statement-handle ( -- )
    env get
    "void*" <c-object> tuck OCI_HTYPE_STMT 0 f OCIHandleAlloc 
    check-result *void* stm set ;

: prepare-statement ( statement -- )
    >r stm get err get r> dup length swap ascii malloc-string swap
    OCI_NTV_SYNTAX OCI_DEFAULT OCIStmtPrepare check-result ;

: calculate-size ( type -- size )
    {
        { SQLT_INT [ "int" heap-size ] }
        { SQLT_FLT [ "float" heap-size ] }
        { SQLT_CHR [ "char" heap-size ] }
        { SQLT_NUM [ "int" heap-size 10 * ] }
        { SQLT_STR [ 64 ] }
        { SQLT_ODT [ 256 ] }
    } case ;

: define-by-position ( position type -- )
    >r >r stm get f <void*> err get
    r> r> dup calculate-size >r [ "char" malloc-array dup buf set ] keep 1+
    r> f f f OCI_DEFAULT OCIDefineByPos check-result ;

: execute-statement ( -- bool )
    svc get stm get err get 1 0 f f OCI_DEFAULT OCIStmtExecute check-status ;

: fetch-statement ( -- bool )
    stm get err get 1 OCI_FETCH_NEXT OCI_DEFAULT OCIStmtFetch check-status ;

: free-statement-handle ( -- )
    stm get OCI_HTYPE_STMT OCIHandleFree check-result ;

! =========================================================
! Log off and detach from server routines
! =========================================================

: end-session ( -- )
    svc get err get ses get OCI_DEFAULT OCISessionEnd check-result ;

: detach-from-server ( -- )
    srv get err get OCI_DEFAULT OCIServerDetach check-result ;

: log-off ( -- )
    end-session
    detach-from-server ;

! =========================================================
! Clean-up and termination routines
! =========================================================

: free-service-handle ( -- )
    svc get OCI_HTYPE_SVCCTX OCIHandleFree check-result ;

: free-server-handle ( -- )
    srv get OCI_HTYPE_SERVER OCIHandleFree check-result ;

: free-error-handle ( -- )
    err get OCI_HTYPE_ERROR OCIHandleFree check-result ;

: free-environment-handle ( -- )
    env get OCI_HTYPE_ENV OCIHandleFree check-result ;

: clean-up ( -- )
    free-service-handle
    free-server-handle
    free-error-handle
    free-environment-handle ;

: terminate ( -- )
    OCI_DEFAULT OCITerminate check-result ;

! =========================================================
! Utility routines
! =========================================================

: server-version ( -- )
    srv get err get 512 "uchar" malloc-array dup >r 512 OCI_HTYPE_SERVER
    OCIServerVersion check-result r> ascii alien>string . ;

! =========================================================
! Public routines
! =========================================================

: log-on ( username password db -- )
    <connection> con set 
    init attach-to-server set-attributes
    begin-session set-authentication-handle 
    V{ } clone res set ;

: fetch-each ( object -- object )
    fetch-statement [
        buf get ascii alien>string res get swap suffix res set
        fetch-each
    ] [ ] if ;

: run-query ( object -- object )
    execute-statement [
        buf get ascii alien>string res get swap suffix res set
        fetch-each
    ] [ ] if ;

: gather-results ( -- seq )
    res get ;

: show-result ( -- )
    res get [ . ] each ;

: clear-result ( -- )
    V{ } clone res set ;
