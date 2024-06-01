! Copyright (c) 2008, 2010 Slava Pestov
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs checksums checksums.sha combinators
destructors endian furnace.actions furnace.auth.providers
furnace.auth.providers.db furnace.boilerplate
furnace.redirection furnace.utilities html.forms http.server
http.server.dispatchers http.server.filters io.encodings.string
io.encodings.utf8 io.sockets.secure kernel logging namespaces
random sequences sets urls ;
IN: furnace.auth

SYMBOL: logged-in-user

: logged-in? ( -- ? )
    logged-in-user get >boolean ;

: username ( -- string/f )
    logged-in-user get dup [ username>> ] when ;

GENERIC: init-user-profile ( responder -- )

M: object init-user-profile drop ;

M: dispatcher init-user-profile
    default>> init-user-profile ;

M: filter-responder init-user-profile
    responder>> init-user-profile ;

: current-profile ( -- assoc ) logged-in-user get profile>> ;

: user-changed ( -- )
    logged-in-user get t >>changed? drop ;

: uget ( key -- value )
    current-profile at ;

: uset ( value key -- )
    current-profile set-at
    user-changed ;

: uchange ( quot key -- )
    current-profile swap change-at
    user-changed ; inline

SYMBOL: capabilities

V{ } clone capabilities set-global

: define-capability ( word -- ) capabilities get adjoin ;

TUPLE: realm < dispatcher name users checksum secure ;

GENERIC: login-required* ( description capabilities realm -- response )

GENERIC: user-registered ( user realm -- response )

M: object user-registered 2drop URL" $realm" <redirect> ;

GENERIC: init-realm ( realm -- )

GENERIC: logged-in-username ( realm -- username )

: login-required ( description capabilities -- * )
    realm get login-required* exit-with ;

: new-realm ( responder name class -- realm )
    new-dispatcher
        swap >>name
        swap >>default
        users-in-db >>users
        sha-256 >>checksum
        ssl-supported? >>secure ; inline

: users ( -- provider )
    realm get users>> ;

TUPLE: user-saver user disposed ;

: <user-saver> ( user -- user-saver )
    f user-saver boa ;

M: user-saver dispose*
    user>> dup changed?>> [ users update-user ] [ drop ] if ;

: save-user-after ( user -- )
    <user-saver> &dispose drop ;

: init-user ( user -- )
    [ [ logged-in-user namespaces:set ] [ save-user-after ] bi ] when* ;

\ init-user DEBUG add-input-logging

M: realm call-responder*
    dup realm namespaces:set
    logged-in? [
        dup init-realm
        dup logged-in-username
        dup [ users get-user ] when
        init-user
    ] unless
    call-next-method ;

: encode-password ( string salt -- bytes )
    [ utf8 encode ] [ 4 >be ] bi* append
    realm get checksum>> checksum-bytes ;

: >>encoded-password ( user string -- user )
    32 random-bits [ encode-password ] keep
    [ >>password ] [ >>salt ] bi* ; inline

: valid-login? ( password user -- ? )
    [ salt>> encode-password ] [ password>> ] bi = ;

: check-login ( password username -- user/f )
    users get-user dup [ [ valid-login? ] keep and ] [ 2drop f ] if ;

: if-secure-realm ( quot -- )
    realm get secure>> [ if-secure ] [ call ] if ; inline

TUPLE: secure-realm-only < filter-responder ;

C: <secure-realm-only> secure-realm-only

M: secure-realm-only call-responder*
    '[ _ _ call-next-method ] if-secure-realm ;

TUPLE: protected < filter-responder description capabilities ;

: <protected> ( responder -- protected )
    protected new
        swap >>responder ;

: have-capabilities? ( capabilities -- ? )
    realm get secure>> secure-connection? not and [ drop f ] [
        logged-in-user get {
            { [ dup not ] [ 2drop f ] }
            { [ dup deleted>> 1 = ] [ 2drop f ] }
            [ capabilities>> subset? ]
        } cond
    ] if ;

M: protected call-responder*
    dup protected namespaces:set
    dup capabilities>> have-capabilities?
    [ call-next-method ] [
        [ drop ] [ [ description>> ] [ capabilities>> ] bi ] bi*
        realm get login-required*
    ] if ;

: <auth-boilerplate> ( responder -- responder' )
    <boilerplate> { realm "boilerplate" } >>template ;

: password-mismatch ( -- * )
    "passwords do not match" validation-error
    validation-failed ;

: same-password-twice ( -- )
    "new-password" value "verify-password" value =
    [ password-mismatch ] unless ;

: user-exists ( -- * )
    "username taken" validation-error
    validation-failed ;
