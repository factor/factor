USING: cryptlib.libcl cryptlib prettyprint kernel alien sequences libc math 
tools.test io io.files continuations alien.c-types splitting generic.math ;

"=========================================================" print
"Envelope/de-envelop test..." print
"=========================================================" print

[
    ! envelope
    CRYPT_FORMAT_CRYPTLIB [
        "Hello world" set-pop-buffer
        envelope-handle CRYPT_ENVINFO_DATASIZE
        get-pop-buffer alien>char-string length set-attribute
        envelope-handle get-pop-buffer dup alien>char-string length push-data
        get-bytes-copied .
        envelope-handle flush-data
        envelope-handle 1024 pop-data
        get-bytes-copied .
        pop-buffer-string .
    ] with-envelope

    ! de-envelope
    CRYPT_FORMAT_AUTO [
        envelope-handle get-pop-buffer get-bytes-copied push-data
        get-bytes-copied .
        envelope-handle flush-data
        envelope-handle get-bytes-copied pop-data
        get-bytes-copied .
        [ "Hello world" ] [ pop-buffer-string ] unit-test
    ] with-envelope

] with-cryptlib

"=========================================================" print
"Password encryption test..." print
"=========================================================" print

[
    ! envelope
    CRYPT_FORMAT_CRYPTLIB [
        envelope-handle CRYPT_ENVINFO_PASSWORD "password" set-attribute-string
        "Hello world" set-pop-buffer
        envelope-handle CRYPT_ENVINFO_DATASIZE
        get-pop-buffer alien>char-string length set-attribute
        envelope-handle get-pop-buffer dup alien>char-string length push-data
        get-bytes-copied .
        envelope-handle flush-data
        envelope-handle 1024 pop-data
        get-bytes-copied .
        pop-buffer-string .
    ] with-envelope

        ! de-envelope
    CRYPT_FORMAT_AUTO [
        [ envelope-handle get-pop-buffer get-bytes-copied push-data ] [
            dup CRYPT_ENVELOPE_RESOURCE = [ 
                envelope-handle CRYPT_ENVINFO_PASSWORD
                "password" set-attribute-string 
            ] [ 
                rethrow
            ] if 
        ] recover drop
        get-bytes-copied .
        envelope-handle flush-data
        envelope-handle get-bytes-copied pop-data
        get-bytes-copied .
        [ "Hello world" ] [ pop-buffer-string ] unit-test
    ] with-envelope
] with-cryptlib

"=========================================================" print
"Compression test..." print
"=========================================================" print

[
    ! envelope
    CRYPT_FORMAT_CRYPTLIB [
        envelope-handle CRYPT_ENVINFO_COMPRESSION CRYPT_UNUSED set-attribute
        "Hello world" set-pop-buffer
        envelope-handle CRYPT_ENVINFO_DATASIZE
        get-pop-buffer alien>char-string length set-attribute
        envelope-handle get-pop-buffer dup alien>char-string length push-data
        get-bytes-copied .
        envelope-handle flush-data
        envelope-handle 1024 pop-data
        get-bytes-copied .
        pop-buffer-string .
    ] with-envelope

    ! de-envelope
    CRYPT_FORMAT_AUTO [
        envelope-handle get-pop-buffer get-bytes-copied push-data
        get-bytes-copied .
        envelope-handle flush-data
        envelope-handle get-bytes-copied pop-data
        get-bytes-copied .
        [ "Hello world" ] [ pop-buffer-string ] unit-test
    ] with-envelope
] with-cryptlib

"=========================================================" print
"Conventional encryption test..." print
"=========================================================" print

[
    ! envelope
    CRYPT_FORMAT_CRYPTLIB [
        CRYPT_ALGO_IDEA [
            context-handle CRYPT_CTXINFO_KEY "0123456789ABCDEF" set-attribute-string
            envelope-handle CRYPT_ENVINFO_SESSIONKEY context-handle *int set-attribute
        ] with-context

        "Hello world" set-pop-buffer
        envelope-handle CRYPT_ENVINFO_DATASIZE
        get-pop-buffer alien>char-string length set-attribute
        envelope-handle get-pop-buffer dup alien>char-string length push-data
        get-bytes-copied .
        envelope-handle flush-data
        envelope-handle 1024 pop-data
        get-bytes-copied .
        pop-buffer-string .
    ] with-envelope

    ! de-envelope
    CRYPT_FORMAT_AUTO [
        [ envelope-handle get-pop-buffer get-bytes-copied push-data ] [
            dup CRYPT_ENVELOPE_RESOURCE = [ 
                CRYPT_ALGO_IDEA create-context
                context-handle CRYPT_CTXINFO_KEY "0123456789ABCDEF"
                set-attribute-string
                envelope-handle CRYPT_ENVINFO_SESSIONKEY context-handle *int 
                set-attribute
            ] [ 
                rethrow 
            ] if 
        ] recover drop
        
        get-bytes-copied .
        destroy-context
        envelope-handle flush-data
        envelope-handle get-bytes-copied pop-data
        get-bytes-copied .
        [ "Hello world" ] [ pop-buffer-string ] unit-test
    ] with-envelope
] with-cryptlib

"=========================================================" print
"Large data size envelope/de-envelop test..." print
"=========================================================" print

[
    ! envelope
    CRYPT_FORMAT_CRYPTLIB [
        "extra/cryptlib/test/large_data.txt" resource-path <file-reader>
        contents set-pop-buffer
        envelope-handle CRYPT_ATTRIBUTE_BUFFERSIZE
        get-pop-buffer alien>char-string length 10000 + set-attribute
        envelope-handle CRYPT_ENVINFO_DATASIZE
        get-pop-buffer alien>char-string length set-attribute
        envelope-handle get-pop-buffer dup alien>char-string length push-data
        get-bytes-copied .
        envelope-handle flush-data
        envelope-handle get-pop-buffer alien>char-string length 10000 + pop-data
        get-bytes-copied .
        ! pop-buffer-string .
    ] with-envelope

    ! de-envelope
    CRYPT_FORMAT_AUTO [
        envelope-handle CRYPT_ATTRIBUTE_BUFFERSIZE
        get-pop-buffer alien>char-string length 10000 + set-attribute
        envelope-handle get-pop-buffer get-bytes-copied push-data
        get-bytes-copied .
        envelope-handle flush-data
        envelope-handle get-bytes-copied pop-data
        get-bytes-copied .
        ! pop-buffer-string .
        [ "/opt/local/lib/libcl.dylib(dylib1.o):" ] 
        [ pop-buffer-string "\n" split first ] unit-test
        [ "00000000 t __mh_dylib_header" ] 
        [ pop-buffer-string "\n" split last/first first ] unit-test
    ] with-envelope
] with-cryptlib

"=========================================================" print
"Large data size password encryption test..." print
"=========================================================" print

[

    ! envelope
    CRYPT_FORMAT_CRYPTLIB [
        envelope-handle CRYPT_ENVINFO_PASSWORD "password" set-attribute-string
        "extra/cryptlib/test/large_data.txt" resource-path
        <file-reader> contents set-pop-buffer
        envelope-handle CRYPT_ATTRIBUTE_BUFFERSIZE
        get-pop-buffer alien>char-string length 10000 + set-attribute
        envelope-handle CRYPT_ENVINFO_DATASIZE
        get-pop-buffer alien>char-string length set-attribute
        envelope-handle get-pop-buffer dup alien>char-string length push-data
        get-bytes-copied .
        envelope-handle flush-data
        envelope-handle get-pop-buffer alien>char-string length 10000 + pop-data
        get-bytes-copied .
        pop-buffer-string .
    ] with-envelope
    
    ! de-envelope
    CRYPT_FORMAT_AUTO [
        envelope-handle CRYPT_ATTRIBUTE_BUFFERSIZE 130000 set-attribute
        [ envelope-handle get-pop-buffer get-bytes-copied push-data ] [
            dup CRYPT_ENVELOPE_RESOURCE = [ 
                envelope-handle CRYPT_ENVINFO_PASSWORD
                "password" set-attribute-string
            ] [ 
                rethrow 
            ] if 
        ] recover drop

        get-bytes-copied .
        envelope-handle flush-data
        envelope-handle get-bytes-copied pop-data
        get-bytes-copied .
        ! pop-buffer-string .

        [ "/opt/local/lib/libcl.dylib(dylib1.o):" ]
        [ pop-buffer-string "\n" split first ] unit-test

        [ "00000000 t __mh_dylib_header" ] 
        [ pop-buffer-string "\n" split last/first first ] unit-test
    ] with-envelope
] with-cryptlib

"=========================================================" print
"Generating a key pair test..." print
"=========================================================" print

[
    CRYPT_ALGO_RSA [
        context-handle CRYPT_CTXINFO_LABEL "private key" set-attribute-string

        ! a particular key length can be set (e.g. 1536-bit/192-byte key)
        context-handle CRYPT_CTXINFO_KEYSIZE 1536 8 / set-attribute

        context-handle generate-key

        CRYPT_KEYSET_FILE "extra/cryptlib/test/keys.p15" resource-path
        CRYPT_KEYOPT_CREATE [
            "password" add-private-key
        ] with-keyset
    ] with-context
] with-cryptlib

"Passed" print

"=========================================================" print
"Simple certificate creation test..." print
"=========================================================" print

[
    CRYPT_ALGO_RSA [
        context-handle CRYPT_CTXINFO_LABEL "private key" set-attribute-string
        context-handle generate-key
        CRYPT_KEYSET_FILE "extra/cryptlib/test/keys.p15" resource-path
        CRYPT_KEYOPT_CREATE [
            "password" add-private-key
            CRYPT_CERTTYPE_CERTIFICATE [
                certificate-handle CRYPT_CERTINFO_XYZZY 1 set-attribute
                certificate-handle CRYPT_CERTINFO_SUBJECTPUBLICKEYINFO
                context-handle *int set-attribute
                certificate-handle CRYPT_CERTINFO_COMMONNAME "Dave Smith"
                set-attribute-string
                sign-certificate
                check-certificate
                add-public-key
                f 0 CRYPT_CERTFORMAT_TEXT_CERTIFICATE export-certificate
                get-cert-length *int dup malloc swap 
                CRYPT_CERTFORMAT_TEXT_CERTIFICATE export-certificate
                get-cert-buffer alien>char-string print
            ] with-certificate
        ] with-keyset
    ] with-context
] with-cryptlib

: ssh-session ( -- )
    "=========================================================" print
    "SSH session test..." print
    "=========================================================" print

    ! start client connection with:
    ! ssh -v localhost -p3000
    "waiting for: ssh -v localhost -p3000" print flush

    ! Are you sure you want to continue connecting (yes/no)? yes
    ! ...
    ! <at> localhost's password: (any password will be accepted)

    ! If you want to run the test again you should clean the [localhost]:3000 
    ! ssh-rsa entry in the known_hosts file, in your home directory under the .ssh 
    ! folder, since the test generates a new RSA certificate on every run.

    [
        CRYPT_KEYSET_FILE "extra/cryptlib/test/keys.p15" resource-path
        CRYPT_KEYOPT_READONLY [
            CRYPT_KEYID_NAME "private key" "password" get-private-key
        
            CRYPT_SESSION_SSH_SERVER [

                session-handle CRYPT_SESSINFO_SERVER_NAME "localhost"
                set-attribute-string

                session-handle CRYPT_SESSINFO_SERVER_PORT 3000 set-attribute

                session-handle CRYPT_SESSINFO_PRIVATEKEY
            
                context-handle *int set-attribute

                [ session-handle CRYPT_SESSINFO_ACTIVE 1 set-attribute ] [
                    dup CRYPT_ENVELOPE_RESOURCE = [
                        session-handle CRYPT_SESSINFO_AUTHRESPONSE 1
                        set-attribute

                        session-handle CRYPT_SESSINFO_ACTIVE 1 set-attribute

                        "Welcome to cryptlib, now go away.\r\n" set-pop-buffer

                        session-handle  get-pop-buffer dup alien>char-string
                        length push-data

                        session-handle flush-data
                    ] [ 
                        rethrow 
                    ] if 
                ] recover drop
            ] with-session
        ] with-keyset
    ] with-cryptlib

    "Passed" print
;

: ssl-session ( -- )
    "=========================================================" print
    "SSL session test..." print
    "=========================================================" print

    ! start client connection with:
    ! curl -k https://localhost:3000
    "waiting for: curl -k https://localhost:3000" print flush

    [
        CRYPT_KEYSET_FILE "extra/cryptlib/test/keys.p15" resource-path
        CRYPT_KEYOPT_READONLY [
            CRYPT_KEYID_NAME "private key" "password" get-private-key

            CRYPT_SESSION_SSL_SERVER [
                session-handle CRYPT_SESSINFO_SERVER_NAME "localhost"
                set-attribute-string
                session-handle CRYPT_SESSINFO_SERVER_PORT 3000 set-attribute
                session-handle CRYPT_OPTION_NET_WRITETIMEOUT 10 set-attribute
                session-handle CRYPT_OPTION_NET_READTIMEOUT 10 set-attribute
                session-handle CRYPT_OPTION_NET_CONNECTTIMEOUT 10 set-attribute
                session-handle CRYPT_SESSINFO_PRIVATEKEY
                context-handle *int set-attribute

                session-handle CRYPT_SESSINFO_ACTIVE 1 set-attribute
                "Welcome to cryptlib, now go away.\r\n" set-pop-buffer
                session-handle  get-pop-buffer dup alien>char-string
                length push-data
                session-handle flush-data
            ] with-session
        ] with-keyset
    ] with-cryptlib

    "Passed" print
;
