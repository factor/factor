! Copyright (C) 2009 Maxim Savchenko
! See https://factorcode.org/license.txt for BSD license.

USING: kernel accessors sequences sequences.private destructors math namespaces
    openssl openssl.libcrypto byte-arrays bit-arrays.private
    alien.c-types alien.destructors alien.data ;

IN: ecdsa

<PRIVATE

TUPLE: ec-key handle disposed ;

M: ec-key dispose*
    [ EC_KEY_free f ] change-handle drop ;

: <ec-key> ( curve -- key )
    OBJ_sn2nid dup zero? [ "Unknown curve name" throw ] when
    EC_KEY_new_by_curve_name dup ssl-error f ec-key boa ;

: ec-key-handle ( -- handle )
    ec-key get [ handle>> ] [ already-disposed ] ?unless ;

DESTRUCTOR: BN_clear_free

DESTRUCTOR: EC_POINT_clear_free

PRIVATE>

: with-ec ( curve quot -- )
    swap <ec-key> [ ec-key rot with-variable ] with-disposal ; inline

: generate-key ( -- )
    ec-key get handle>> EC_KEY_generate_key ssl-error ;

: set-private-key ( bin -- )
    ec-key-handle swap
    dup length f BN_bin2bn dup ssl-error
    [ &BN_clear_free EC_KEY_set_private_key ssl-error ] with-destructors ;

:: set-public-key ( BIN -- )
    ec-key-handle :> KEY
    KEY EC_KEY_get0_group :> GROUP
    GROUP EC_POINT_new dup ssl-error
    [
        &EC_POINT_clear_free :> POINT
        GROUP POINT BIN dup length f EC_POINT_oct2point ssl-error
        KEY POINT EC_KEY_set_public_key ssl-error
    ] with-destructors ;

: get-private-key ( -- bin/f )
    ec-key-handle EC_KEY_get0_private_key
    dup [ dup BN_num_bits bits>bytes <byte-array> [ BN_bn2bin drop ] keep ] when ;

:: get-public-key ( -- bin/f )
    ec-key-handle :> KEY
    KEY EC_KEY_get0_public_key dup
    [| PUB |
        KEY EC_KEY_get0_group :> GROUP
        GROUP EC_GROUP_get_degree bits>bytes 1 + :> LEN
        LEN <byte-array> :> BIN
        GROUP PUB POINT_CONVERSION_COMPRESSED BIN LEN f
        EC_POINT_point2oct ssl-error
        BIN
    ] when ;

:: ecdsa-sign ( DGST -- sig )
    ec-key-handle :> KEY
    KEY ECDSA_size dup ssl-error <byte-array> :> SIG
    0 uint <ref> :> LEN
    0 DGST dup length SIG LEN KEY ECDSA_sign ssl-error
    LEN uint deref SIG resize ;

: ecdsa-verify ( dgst sig -- ? )
    ec-key-handle [ 0 -rot [ dup length ] bi@ ] dip ECDSA_verify 0 > ;
