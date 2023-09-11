! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: math.primes kernel math math.functions namespaces
sequences accessors ;
IN: crypto.rsa

! The private key is the only secret.

! p,q are two random primes of numbits/2
! phi = (p-1)(q-1)
! modulus = p*q
! public = 65537
! private = public modinv phi

TUPLE: rsa modulus private-key public-key ;

C: <rsa> rsa

<PRIVATE

CONSTANT: public-key 65537

: rsa-primes ( numbits -- p q )
    2/ 2 swap unique-primes first2 ;

: modulus-phi ( numbits -- n phi )
    ! Loop until phi is not divisible by the public key.
    dup rsa-primes [ * ] 2keep
    [ 1 - ] bi@ *
    dup public-key coprime? [ nipd ] [ 2drop modulus-phi ] if ;

PRIVATE>

: generate-rsa-keypair ( numbits -- <rsa> )
    modulus-phi
    public-key over mod-inv +
    public-key <rsa> ;

: rsa-encrypt ( message rsa -- encrypted )
    [ public-key>> ] [ modulus>> ] bi ^mod ;

: rsa-decrypt ( encrypted rsa -- message )
    [ private-key>> ] [ modulus>> ] bi ^mod ;
