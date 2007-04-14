USING: alien alien.c-types assocs bit-arrays hashtables io io.files
io.sockets kernel mirrors openssl.libcrypto openssl.libssl
namespaces math math.parser openssl prettyprint sequences tools.test ;

! =========================================================
! Some crypto functions (still to be turned into words)
! =========================================================

[
    B{ 201 238 222 100 92 200 182 188 138 255 129 163 115 88 240 136 }
]
[ "Hello world from the openssl binding" >md5 ] unit-test

[
    B{ 63 113 237 255 181 5 152 241 136 181 43 95 160 105 44 87 49
    82 115 0 }
]
[ "Hello world from the openssl binding" >sha1 ] unit-test

! =========================================================
! Initialize context
! =========================================================

[ ] [ init load-error-strings ] unit-test

[ ] [ ssl-v23 new-ctx ] unit-test

[ ] [ get-ctx "extra/openssl/test/server.pem" resource-path use-cert-chain ] unit-test

! TODO: debug 'Memory protection fault at address 6c'
! get-ctx 1024 "char" malloc-array 1024 0 f password-cb set-default-passwd

[ ] [ get-ctx "password" string>char-alien set-default-passwd-userdata ] unit-test

! Enter PEM pass phrase: password
[ ] [ get-ctx "extra/openssl/test/server.pem" resource-path
SSL_FILETYPE_PEM use-private-key ] unit-test

[ ] [ get-ctx "extra/openssl/test/root.pem" resource-path f
verify-load-locations ] unit-test

[ ] [ get-ctx 1 set-verify-depth ] unit-test

! =========================================================
! Load Diffie-Hellman parameters
! =========================================================

[ ] [ "extra/openssl/test/dh1024.pem" resource-path "r" bio-new-file ] unit-test

[ ] [ get-bio f f f read-pem-dh-params ] unit-test

[ ] [ get-bio bio-free ] unit-test

! TODO: debug SSL_CTX_set_tmp_dh 'No such symbol'
[ ] [ get-ctx get-dh set-tmp-dh-callback ] unit-test

! Workaround (this function should never be called directly)
! [ ] [ get-ctx SSL_CTRL_SET_TMP_DH 0 get-dh set-ctx-ctrl ] unit-test

! =========================================================
! Generate ephemeral RSA key
! =========================================================

[ ] [ 512 RSA_F4 f f generate-rsa-key ] unit-test

! TODO: debug SSL_CTX_set_tmp_rsa 'No such symbol'
! get-ctx get-rsa set-tmp-rsa-callback

! Workaround (this function should never be called directly)
[ ] [ get-ctx SSL_CTRL_SET_TMP_RSA 0 get-rsa set-ctx-ctrl ] unit-test

[ ] [ get-rsa free-rsa ] unit-test

! =========================================================
! Listen and accept on socket
! =========================================================

! SYMBOL: sock
! SYMBOL: fdset
! SYMBOL: acset
! SYMBOL: sbio
! SYMBOL: ssl
! 
! : is-set ( seq -- newseq )
!     <enum> >alist [ nip ] assoc-subset >hashtable keys ;
! 
! ! 1234 server-socket sock set
! "127.0.0.1" 1234 <inet4> SOCK_STREAM server-fd sock set
! 
! FD_SETSIZE 8 * <bit-array> fdset set
! 
! FD_SETSIZE 8 * <bit-array> t 8 rot [ set-nth ] keep fdset set
! 
! fdset get is-set .

! : loop ( -- )
!     sock get f f accept
!     dup -1 = [ drop ] [
!         dup number>string print flush
!         ! BIO_NOCLOSE bio-new-socket sbio set
!         [ get-ctx new-ssl ssl set ] keep
!         ssl get swap set-ssl-fd
!         ! ssl get sbio get dup set-ssl-bio
!         ! ssl get ssl-accept
!         ! dup 0 <= [ 
!         !     ssl get swap ssl-get-error 
!         ! ] [ drop ] if
!     ] if
!     loop ;

! { } acset set
! 
! : loop ( -- )
!     ! FD_SETSIZE fdset get f f f select . flush
!     FD_SETSIZE fdset get f f 10000 make-timeval select 
!     0 <= [ acset get [ close ] each "timeout" print ] [
!         fdset get is-set sock get swap member? [ 
!              sock get f f accept dup . flush 
!              acset get swap add acset set
!     ] [ ] if
!         loop
!     ] if ;
! 
! loop
! 
! sock get close

! =========================================================
! Dump errors to file
! =========================================================

[ ] [ "extra/openssl/test/errors.txt" resource-path "w" bio-new-file ] unit-test

[ 6 ] [ get-bio "Hello\n" bio-print ] unit-test

[ ] [ get-bio bio-free ] unit-test

! =========================================================
! Clean-up
! =========================================================

! sock get close

get-ctx destroy-ctx
