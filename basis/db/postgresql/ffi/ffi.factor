! Copyright (C) 2007, 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
! tested on debian linux with postgresql 8.1
USING: alien alien.syntax combinators system alien.libraries ;
IN: db.postgresql.ffi

<< "postgresql" {
    { [ os winnt? ]  [ "libpq.dll" ] }
    { [ os macosx? ] [ "libpq.dylib" ] }
    { [ os unix?  ]  [ "libpq.so" ] }
} cond "cdecl" add-library >>

! ConnSatusType
CONSTANT: CONNECTION_OK                     HEX: 0
CONSTANT: CONNECTION_BAD                    HEX: 1
CONSTANT: CONNECTION_STARTED                HEX: 2
CONSTANT: CONNECTION_MADE                   HEX: 3
CONSTANT: CONNECTION_AWAITING_RESPONSE      HEX: 4
CONSTANT: CONNECTION_AUTH_OK                HEX: 5
CONSTANT: CONNECTION_SETENV                 HEX: 6
CONSTANT: CONNECTION_SSL_STARTUP            HEX: 7
CONSTANT: CONNECTION_NEEDED                 HEX: 8

! PostgresPollingStatusType
CONSTANT: PGRES_POLLING_FAILED              HEX: 0
CONSTANT: PGRES_POLLING_READING             HEX: 1
CONSTANT: PGRES_POLLING_WRITING             HEX: 2
CONSTANT: PGRES_POLLING_OK                  HEX: 3
CONSTANT: PGRES_POLLING_ACTIVE              HEX: 4

! ExecStatusType;
CONSTANT: PGRES_EMPTY_QUERY                 HEX: 0
CONSTANT: PGRES_COMMAND_OK                  HEX: 1
CONSTANT: PGRES_TUPLES_OK                   HEX: 2
CONSTANT: PGRES_COPY_OUT                    HEX: 3
CONSTANT: PGRES_COPY_IN                     HEX: 4
CONSTANT: PGRES_BAD_RESPONSE                HEX: 5
CONSTANT: PGRES_NONFATAL_ERROR              HEX: 6
CONSTANT: PGRES_FATAL_ERROR                 HEX: 7

! PGTransactionStatusType;
CONSTANT: PQTRANS_IDLE                      HEX: 0
CONSTANT: PQTRANS_ACTIVE                    HEX: 1
CONSTANT: PQTRANS_INTRANS                   HEX: 2
CONSTANT: PQTRANS_INERROR                   HEX: 3
CONSTANT: PQTRANS_UNKNOWN                   HEX: 4

! PGVerbosity;
CONSTANT: PQERRORS_TERSE                    HEX: 0
CONSTANT: PQERRORS_DEFAULT                  HEX: 1
CONSTANT: PQERRORS_VERBOSE                  HEX: 2

CONSTANT: InvalidOid 0

TYPEDEF: int ConnStatusType
TYPEDEF: int ExecStatusType 
TYPEDEF: int PostgresPollingStatusType
TYPEDEF: int PGTransactionStatusType 
TYPEDEF: int PGVerbosity 

TYPEDEF: void* PGconn*
TYPEDEF: void* PGresult*
TYPEDEF: void* PGcancel*
TYPEDEF: uint Oid
TYPEDEF: uint* Oid*
TYPEDEF: char pqbool
TYPEDEF: void* PQconninfoOption*
TYPEDEF: void* PGnotify*
TYPEDEF: void* PQArgBlock*
TYPEDEF: void* PQprintOpt*
TYPEDEF: void* FILE*
TYPEDEF: void* SSL*

LIBRARY: postgresql

! Exported functions of libpq

! make a new client connection to the backend
! Asynchronous (non-blocking)
FUNCTION: PGconn* PQconnectStart ( char* conninfo ) ;
FUNCTION: PostgresPollingStatusType PQconnectPoll ( PGconn* conn ) ;

! Synchronous (blocking)
FUNCTION: PGconn* PQconnectdb ( char* conninfo ) ;
FUNCTION: PGconn* PQsetdbLogin ( char* pghost, char* pgport,
             char* pgoptions, char* pgtty,
             char* dbName,
             char* login, char* pwd ) ;

: PQsetdb ( M_PGHOST M_PGPORT M_PGOPT M_PGTTY M_DBNAME -- PGconn* )
    f f PQsetdbLogin ;

! close the current connection and free the PGconn data structure
FUNCTION: void PQfinish ( PGconn* conn ) ;

! get info about connection options known to PQconnectdb
FUNCTION: PQconninfoOption* PQconndefaults ( ) ;

! free the data structure returned by PQconndefaults()
FUNCTION: void PQconninfoFree ( PQconninfoOption* connOptions ) ;

! Asynchronous (non-blocking)
FUNCTION: int    PQresetStart ( PGconn* conn ) ;
FUNCTION: PostgresPollingStatusType PQresetPoll ( PGconn* conn ) ;

! Synchronous (blocking)
FUNCTION: void PQreset ( PGconn* conn ) ;

! request a cancel structure
FUNCTION: PGcancel* PQgetCancel ( PGconn* conn ) ;

! free a cancel structure
FUNCTION: void PQfreeCancel ( PGcancel* cancel ) ;

! issue a cancel request
FUNCTION: int    PQrequestCancel ( PGconn* conn ) ;

! Accessor functions for PGconn objects
FUNCTION: char* PQdb ( PGconn* conn ) ;
FUNCTION: char* PQuser ( PGconn* conn ) ;
FUNCTION: char* PQpass ( PGconn* conn ) ;
FUNCTION: char* PQhost ( PGconn* conn ) ;
FUNCTION: char* PQport ( PGconn* conn ) ;
FUNCTION: char* PQtty ( PGconn* conn ) ;
FUNCTION: char* PQoptions ( PGconn* conn ) ;
FUNCTION: ConnStatusType PQstatus ( PGconn* conn ) ;
FUNCTION: PGTransactionStatusType PQtransactionStatus ( PGconn* conn ) ;
FUNCTION: char* PQparameterStatus ( PGconn* conn,
                  char* paramName ) ;
FUNCTION: int PQprotocolVersion ( PGconn* conn ) ;
! FUNCTION: int PQServerVersion ( PGconn* conn ) ;
FUNCTION: char* PQerrorMessage ( PGconn* conn ) ;
FUNCTION: int PQsocket ( PGconn* conn ) ;
FUNCTION: int PQbackendPID ( PGconn* conn ) ;
FUNCTION: int PQclientEncoding ( PGconn* conn ) ;
FUNCTION: int PQsetClientEncoding ( PGconn* conn, char* encoding ) ;

! May not be compiled into libpq
! Get the SSL structure associated with a connection
FUNCTION: SSL* PQgetssl ( PGconn* conn ) ;

! Tell libpq whether it needs to initialize OpenSSL
FUNCTION: void PQinitSSL ( int do_init ) ;

! Set verbosity for PQerrorMessage and PQresultErrorMessage
FUNCTION: PGVerbosity PQsetErrorVerbosity ( PGconn* conn,
    PGVerbosity verbosity ) ;

! Enable/disable tracing
FUNCTION: void PQtrace ( PGconn* conn, FILE* debug_port ) ;
FUNCTION: void PQuntrace ( PGconn* conn ) ;

! BROKEN
! Function types for notice-handling callbacks
! typedef void (*PQnoticeReceiver) (void *arg, PGresult *res);
! typedef void (*PQnoticeProcessor) (void *arg, char* message);
! ALIAS: void* PQnoticeReceiver
! ALIAS: void* PQnoticeProcessor

! Override default notice handling routines
! FUNCTION: PQnoticeReceiver PQsetNoticeReceiver ( PGconn* conn,
                    ! PQnoticeReceiver proc,
                    ! void* arg ) ;
! FUNCTION: PQnoticeProcessor PQsetNoticeProcessor ( PGconn* conn,
                    ! PQnoticeProcessor proc,
                    ! void* arg ) ;
! END BROKEN

! === in fe-exec.c ===

! Simple synchronous query
FUNCTION: PGresult* PQexec ( PGconn* conn, char* query ) ;
FUNCTION: PGresult* PQexecParams ( PGconn* conn,
             char* command,
             int nParams,
             Oid* paramTypes,
             char** paramValues,
             int* paramLengths,
             int* paramFormats,
             int resultFormat ) ;
FUNCTION: PGresult* PQprepare ( PGconn* conn, char* stmtName,
        char* query, int nParams,
        Oid* paramTypes ) ;
FUNCTION: PGresult* PQexecPrepared ( PGconn* conn,
             char* stmtName,
             int nParams,
             char** paramValues,
             int* paramLengths,
             int* paramFormats,
             int resultFormat ) ;

! Interface for multiple-result or asynchronous queries
FUNCTION: int PQsendQuery ( PGconn* conn, char* query ) ;
FUNCTION: int PQsendQueryParams ( PGconn* conn,
                  char* command,
                  int nParams,
                  Oid* paramTypes,
                  char** paramValues,
                  int* paramLengths,
                  int* paramFormats,
                  int resultFormat ) ;
FUNCTION: PGresult* PQsendPrepare ( PGconn* conn, char* stmtName,
            char* query, int nParams,
            Oid* paramTypes ) ;
FUNCTION: int PQsendQueryPrepared ( PGconn* conn,
                  char* stmtName,
                  int nParams,
                  char** paramValues,
                  int *paramLengths,
                  int *paramFormats,
                  int resultFormat ) ;
FUNCTION: PGresult* PQgetResult ( PGconn* conn ) ;

! Routines for managing an asynchronous query
FUNCTION: int    PQisBusy ( PGconn* conn ) ;
FUNCTION: int    PQconsumeInput ( PGconn* conn ) ;

! LISTEN/NOTIFY support
FUNCTION: PGnotify* PQnotifies ( PGconn* conn ) ;

! Routines for copy in/out
FUNCTION: int    PQputCopyData ( PGconn* conn, char* buffer, int nbytes ) ;
FUNCTION: int    PQputCopyEnd ( PGconn* conn, char* errormsg ) ;
FUNCTION: int    PQgetCopyData ( PGconn* conn, char** buffer, int async ) ;

! Deprecated routines for copy in/out
FUNCTION: int    PQgetline ( PGconn* conn, char* string, int length ) ;
FUNCTION: int    PQputline ( PGconn* conn, char* string ) ;
FUNCTION: int    PQgetlineAsync ( PGconn* conn, char* buffer, int bufsize ) ;
FUNCTION: int    PQputnbytes ( PGconn* conn, char* buffer, int nbytes ) ;
FUNCTION: int    PQendcopy ( PGconn* conn ) ;

! Set blocking/nonblocking connection to the backend
FUNCTION: int    PQsetnonblocking ( PGconn* conn, int arg ) ;
FUNCTION: int    PQisnonblocking ( PGconn* conn ) ;

! Force the write buffer to be written (or at least try)
FUNCTION: int    PQflush ( PGconn* conn ) ;

! 
! * "Fast path" interface --- not really recommended for application
! * use
!
FUNCTION: PGresult* PQfn ( PGconn* conn,
     int fnid,
     int* result_buf,
     int* result_len,
     int result_is_int,
     PQArgBlock* args,
     int nargs ) ;

! Accessor functions for PGresult objects
FUNCTION: ExecStatusType PQresultStatus ( PGresult* res ) ;
FUNCTION: char* PQresStatus ( ExecStatusType status ) ;
FUNCTION: char* PQresultErrorMessage ( PGresult* res ) ;
FUNCTION: char* PQresultErrorField ( PGresult* res, int fieldcode ) ;
FUNCTION: int   PQntuples ( PGresult* res ) ;
FUNCTION: int   PQnfields ( PGresult* res ) ;
FUNCTION: int   PQbinaryTuples ( PGresult* res ) ;
FUNCTION: char* PQfname ( PGresult* res, int field_num ) ;
FUNCTION: int   PQfnumber ( PGresult* res, char* field_name ) ;
FUNCTION: Oid   PQftable ( PGresult* res, int field_num ) ;
FUNCTION: int   PQftablecol ( PGresult* res, int field_num ) ;
FUNCTION: int   PQfformat ( PGresult* res, int field_num ) ;
FUNCTION: Oid   PQftype ( PGresult* res, int field_num ) ;
FUNCTION: int   PQfsize ( PGresult* res, int field_num ) ;
FUNCTION: int   PQfmod ( PGresult* res, int field_num ) ;
FUNCTION: char* PQcmdStatus ( PGresult* res ) ;
FUNCTION: char* PQoidStatus ( PGresult* res ) ;
FUNCTION: Oid   PQoidValue ( PGresult* res ) ;
FUNCTION: char* PQcmdTuples ( PGresult* res ) ;
! FUNCTION: char* PQgetvalue ( PGresult* res, int tup_num, int field_num ) ;
FUNCTION: void* PQgetvalue ( PGresult* res, int tup_num, int field_num ) ;
FUNCTION: int   PQgetlength ( PGresult* res, int tup_num, int field_num ) ;
FUNCTION: int   PQgetisnull ( PGresult* res, int tup_num, int field_num ) ;

! Delete a PGresult
FUNCTION: void PQclear ( PGresult* res ) ;

! For freeing other alloc'd results, such as PGnotify structs
FUNCTION: void PQfreemem ( void* ptr ) ;

! Exists for backward compatibility.
: PQfreeNotify ( ptr -- ) PQfreemem ;

!
! Make an empty PGresult with given status (some apps find this
! useful). If conn is not NULL and status indicates an error, the
! conn's errorMessage is copied.
!
FUNCTION: PGresult* PQmakeEmptyPGresult ( PGconn* conn, ExecStatusType status ) ;

! Quoting strings before inclusion in queries.
FUNCTION: size_t PQescapeStringConn ( PGconn* conn,
                                    char* to, char* from, size_t length,
                                    int* error ) ;
FUNCTION: uchar* PQescapeByteaConn ( PGconn* conn,
                                    char* from, size_t length,
                                    size_t* to_length ) ;
FUNCTION: void* PQunescapeBytea ( uchar* strtext, size_t* retbuflen ) ;
! FUNCTION: uchar* PQunescapeBytea ( uchar* strtext, size_t* retbuflen ) ;
! These forms are deprecated!
FUNCTION: size_t PQescapeString ( void* to, char* from, size_t length ) ;
FUNCTION: uchar* PQescapeBytea ( uchar* bintext, size_t binlen,
              size_t* bytealen ) ;

! === in fe-print.c ===

FUNCTION: void PQprint ( FILE* fout, PGresult* res, PQprintOpt* ps ) ;

! really old printing routines
FUNCTION: void PQdisplayTuples ( PGresult* res,
                                FILE* fp,               
                                int fillAlign,
                                char* fieldSep,
                                int printHeader,
                                int quiet ) ;

FUNCTION: void PQprintTuples ( PGresult* res,
                          FILE* fout,           
                          int printAttName,
                          int terseOutput,      
                          int width ) ; 
! === in fe-lobj.c ===

! Large-object access routines
FUNCTION: int    lo_open ( PGconn* conn, Oid lobjId, int mode ) ;
FUNCTION: int    lo_close ( PGconn* conn, int fd ) ;
FUNCTION: int    lo_read ( PGconn* conn, int fd, char* buf, size_t len ) ;
FUNCTION: int    lo_write ( PGconn* conn, int fd, char* buf, size_t len ) ;
FUNCTION: int    lo_lseek ( PGconn* conn, int fd, int offset, int whence ) ;
FUNCTION: Oid    lo_creat ( PGconn* conn, int mode ) ;
! FUNCTION: Oid    lo_creat ( PGconn* conn, Oid lobjId ) ;
FUNCTION: int    lo_tell ( PGconn* conn, int fd ) ;
FUNCTION: int    lo_unlink ( PGconn* conn, Oid lobjId ) ;
FUNCTION: Oid    lo_import ( PGconn* conn, char* filename ) ;
FUNCTION: int    lo_export ( PGconn* conn, Oid lobjId, char* filename ) ;

! === in fe-misc.c ===

! Determine length of multibyte encoded char at *s
FUNCTION: int    PQmblen ( uchar* s, int encoding ) ;

! Determine display length of multibyte encoded char at *s
FUNCTION: int    PQdsplen ( uchar* s, int encoding ) ;

! Get encoding id from environment variable PGCLIENTENCODING
FUNCTION: int    PQenv2encoding ( ) ;

! From git, include/catalog/pg_type.h
CONSTANT: BOOL-OID 16
CONSTANT: BYTEA-OID 17
CONSTANT: CHAR-OID 18
CONSTANT: NAME-OID 19
CONSTANT: INT8-OID 20
CONSTANT: INT2-OID 21
CONSTANT: INT4-OID 23
CONSTANT: TEXT-OID 23
CONSTANT: OID-OID 26
CONSTANT: FLOAT4-OID 700
CONSTANT: FLOAT8-OID 701
CONSTANT: VARCHAR-OID 1043
CONSTANT: DATE-OID 1082
CONSTANT: TIME-OID 1083
CONSTANT: TIMESTAMP-OID 1114
CONSTANT: TIMESTAMPTZ-OID 1184
CONSTANT: INTERVAL-OID 1186
CONSTANT: NUMERIC-OID 1700
