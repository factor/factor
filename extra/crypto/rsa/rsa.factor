USING: math.miller-rabin kernel math math.functions namespaces
sequences ;
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

: public-key 65537 ; inline

: rsa-primes ( numbits -- p q )
    2/ 2 unique-primes first2 ;

: modulus-phi ( numbits -- n phi ) 
    #! Loop until phi is not divisible by the public key.
    dup rsa-primes [ * ] 2keep
    [ 1- ] 2apply *
    dup public-key gcd nip 1 = [
        rot drop
    ] [
        2drop modulus-phi
    ] if ;

PRIVATE>

: generate-rsa-keypair ( numbits -- <rsa> )
    modulus-phi
    public-key over mod-inv +
    public-key <rsa> ;

: rsa-encrypt ( message rsa -- encrypted )
    [ rsa-public-key ] keep rsa-modulus ^mod ;

: rsa-decrypt ( encrypted rsa -- message )
    [ rsa-private-key ] keep rsa-modulus ^mod ;