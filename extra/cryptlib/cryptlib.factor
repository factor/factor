! Copyright (C) 2007 Elie CHAFTARI
! See http://factorcode.org/license.txt for BSD license.

! libs/cryptib/cryptlib.factor

! Adapted from cryptlib.h
! Tested with cryptlib 3.3.1.0
USING: cryptlib.libcl kernel hashtables alien math 
namespaces sequences assocs libc alien.c-types continuations ;

IN: cryptlib

SYMBOL: keyset
SYMBOL: certificate
SYMBOL: cert-buffer
SYMBOL: cert-length
SYMBOL: context
SYMBOL: envelope
SYMBOL: bytes-copied
SYMBOL: pop-buffer
SYMBOL: session

! =========================================================
! Error-handling routines
! =========================================================

: check-result ( result -- )
    dup CRYPT_OK = [ 
        drop
    ] [
        dup CRYPT_ENVELOPE_RESOURCE = [
            throw
        ] [
            dup error-messages >hashtable at throw
        ] if     
    ] if ;

! =========================================================
! Secure pointer-freeing routines
! =========================================================

: secure-free ( ptr n -- )
    [ dupd 0 -rot set-alien-unsigned-1 ] each free ;

: secure-free-array ( ptr n type -- )
    heap-size * [ dupd 0 -rot set-alien-unsigned-1 ] each free ;

: secure-free-object ( ptr type -- )
    1 swap secure-free-array ;

! =========================================================
! Initialise and shut down cryptlib
! =========================================================

: init ( -- )
    cryptInit check-result ;

: end ( -- )
    cryptEnd check-result ;

: with-cryptlib ( quot -- )
	[ init [ end ] [ ] cleanup ] with-scope ; inline

! =========================================================
! Create and destroy an encryption context
! =========================================================

: create-context ( algo -- )
    >r "int" <c-object> dup swap CRYPT_UNUSED r> cryptCreateContext
    check-result context set ;

: destroy-context ( -- )
    context get [ *int cryptDestroyContext check-result ] when*
	context off ;

: with-context ( algo quot -- )
	swap create-context [ destroy-context ] [ ] cleanup ; inline

! =========================================================
! Keyset routines
! =========================================================

: open-keyset ( type name options -- )
    >r >r >r "int" <c-object> dup swap CRYPT_UNUSED r> r> string>char-alien
    r> cryptKeysetOpen check-result keyset set ;

: close-keyset ( -- )
    keyset get *int cryptKeysetClose check-result
	destroy-context ;

: with-keyset ( type name options quot -- )
	>r open-keyset r> [ close-keyset ] [ ] cleanup ; inline

: get-public-key ( idtype id -- )
    >r >r keyset get *int "int*" <c-object> tuck r> r> string>char-alien
    cryptGetPublicKey check-result context set ;

: get-private-key ( idtype id password -- )
    >r >r >r keyset get *int "int*" <c-object> tuck r>
    r> string>char-alien r> string>char-alien cryptGetPrivateKey
    check-result context set ;

: get-key ( idtype id password -- )
    >r >r >r keyset get *int "int*" <c-object> tuck r>
    r> string>char-alien r> string>char-alien cryptGetKey
    check-result context set ;

: add-public-key ( -- )
    keyset get *int certificate get *int cryptAddPublicKey check-result ;

: add-private-key ( password -- )
    >r keyset get *int context get *int r> string>char-alien
    cryptAddPrivateKey check-result ;

: delete-key ( type id -- )
    >r >r keyset get *int r> r> string>char-alien cryptDeleteKey
    check-result ;

! =========================================================
! Certificate routines
! =========================================================

: create-certificate ( type -- )
    >r "int" <c-object> dup swap CRYPT_UNUSED r>
    cryptCreateCert check-result certificate set ;

: destroy-certificate ( -- )
    certificate get *int cryptDestroyCert check-result ;

: with-certificate ( type quot -- )
	swap create-certificate [ destroy-certificate ] [ ] cleanup ; inline

: sign-certificate ( -- )
    certificate get *int context get *int cryptSignCert check-result ;

: check-certificate ( -- )
    certificate get *int context get *int cryptCheckCert check-result ;

: import-certificate ( certbuffer length -- )
    >r r> CRYPT_UNUSED "int*" malloc-object dup >r
    cryptImportCert check-result r> certificate set ;

: export-certificate ( certbuffer maxlength format -- )
    >r >r dup swap r> "int*" malloc-object dup r> swap >r
    certificate get *int cryptExportCert check-result
    cert-buffer set r> cert-length set ;

! =========================================================
! Generate a key into a context
! =========================================================

: generate-key ( handle -- )
    *int cryptGenerateKey check-result ;

! =========================================================
! Get/set/delete attribute functions
! =========================================================

: set-attribute ( handle attribute value -- )
    >r >r *int r> r> cryptSetAttribute check-result ;

: set-attribute-string ( handle attribute value -- )
    >r >r *int r> r> dup length swap string>char-alien swap
    cryptSetAttributeString check-result ;

! =========================================================
! Envelope and Session routines
! =========================================================

: create-envelope ( format -- )
    >r "int" <c-object> dup swap CRYPT_UNUSED r> cryptCreateEnvelope
    check-result envelope set ;

: destroy-envelope ( -- )
    envelope get *int cryptDestroyEnvelope check-result ;

: with-envelope ( format quot -- )
	swap create-envelope [ destroy-envelope ] [ ] cleanup ;

: create-session ( format -- )
    >r "int" <c-object> dup swap CRYPT_UNUSED r> cryptCreateSession
    check-result session set ;

: destroy-session ( -- )
    session get *int cryptDestroySession check-result ;

: with-session ( format quot -- )
	swap create-session [ destroy-session ] [ ] cleanup ;

: push-data ( handle buffer length -- )
    >r >r *int r> r> "int" <c-object> [ cryptPushData ]
    keep swap check-result bytes-copied set ;

: flush-data ( handle -- )
    *int cryptFlushData check-result ;

: pop-data ( handle length -- )
    dup >r >r *int r> "uchar*" malloc-array 
    dup r> swap >r "int" <c-object> [ cryptPopData ] keep
    swap check-result bytes-copied set r> pop-buffer set ;

! =========================================================
! Public routines
! =========================================================

: envelope-handle ( -- envelope )
    envelope get ;

: context-handle ( -- context )
    context get ;

: certificate-handle ( -- certificate )
    certificate get ;

: session-handle ( -- session )
    session get ;

: set-pop-buffer ( data -- )
    string>char-alien pop-buffer set ;

: get-pop-buffer ( -- buffer )
    pop-buffer get ;

: pop-buffer-string ( -- s )
    pop-buffer get alien>char-string ;

: get-bytes-copied ( -- value )
    bytes-copied get *int ;

: get-cert-buffer ( -- certreq )
    cert-buffer get ;

: get-cert-length ( -- certlength )
    cert-length get ;
