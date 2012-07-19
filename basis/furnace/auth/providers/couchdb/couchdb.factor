USING: accessors assocs couchdb furnace.auth.providers
json.writer kernel mirrors sequences urls urls.encoding
arrays furnace.auth byte-arrays combinators.short-circuit
strings continuations combinators base64 make
locals namespaces ;
FROM: assocs => change-at ;
IN: furnace.auth.providers.couchdb

! !!! Implement the authentication protocol for CouchDB.
! !!!
! !!! 'user' tuples are copied verbatim into the DB as objects.
! !!! Special 'reservation' records are inserted into the DB to
! !!! reserve usernames and email addresses. These reservation records
! !!! all have ids with the prefix given to couchdb-auth-provider.
! !!! A reservation in the email domain for the email address "foo@bar.com"
! !!! would have id "PREFIXemail!foo%40bar.com". Both the domain name
! !!! and the value are url-encoded, to ensure that the use of '!' as
! !!! a separator guarantees a unique ID for any given (domain,value)
! !!! pairing.
! !!!
! !!! It would be nice to use CouchDB attachments to avoid junking the
! !!! global namespace like this. However, attachments in CouchDB
! !!! inherit their revision ids from their parent document, which would
! !!! make various operations on users unnecessairly non-independent
! !!! of each other.
! !!!
! !!! On the basic technique used here, see:
! !!!
! !!! http://kfalck.net/2009/06/29/enforcing-unique-usernames-on-couchdb
! !!!

! Many of the words below assume that this symbol is bound to an
! appropriate instance.
TUPLE: couchdb-auth-provider
    base-url
    { username-view string }
    { prefix string initial: "user_reservation_" }
    { field-map assoc initial: { } } ;

<PRIVATE

! >json does weird things for mirrors, so we copy the mirror into
! a real hashtable before serializing it.
: hash-mirror ( obj -- hash )
    make-mirror H{ } assoc-like ;

: is-couchdb-conflict-error? ( error -- ? )
    { [ couchdb-error? ] [ data>> "error" swap at "conflict" = ] } 1&& ;
: is-couchdb-not-found-error? ( error -- ? )
    { [ couchdb-error? ] [ data>> "error" swap at "not_found" = ] } 1&& ;

: get-url ( url -- url' )
    couchdb-auth-provider get
    base-url>> >url swap >url derive-url ;

: reservation-id ( value name -- id )
    couchdb-auth-provider get
    prefix>> [ % url-encode-full % "!" % url-encode-full % ] "" make ;

: (reserve) ( value name -- id/f )
    reservation-id
    get-url
    [
        H{ } clone >json swap couch-put
    ] [
        nip dup is-couchdb-conflict-error? [ drop f ] [ rethrow ] if
    ] recover ;

! Don't reserve false values (e.g. if the email field is f, don't reserve f,
! or the first user who registers without an email address will block all
! others who wish to do so).
: reserve ( value name -- id/f )
    over [ (reserve) ] [ 2drop t ] if ;

: unreserve ( couch-rval -- )
    [ "id" swap at get-url ]
    [ "rev" swap at "rev" set-query-param ]
    bi
    couch-delete drop ;

: unreserve-from-id ( id -- )
    [
        get-url dup couch-get
        "_rev" swap at "rev" set-query-param
        couch-delete drop
    ] [
        dup is-couchdb-not-found-error? [ 2drop ] [ rethrow ] if
    ] recover ;

:: (reserve-multiple) ( hash keys made -- ? )
    keys empty? [ t ] [
        keys first hash at keys first reserve [
            made push
            hash keys rest-slice made (reserve-multiple)
        ] [
            ! Delete reservations that were already successfully made.
            made [ unreserve ] each
            f
        ] if*
    ] if ;

! Try to reserve all of the given name/value pairs; if not all reservations
! can be made, delete those that were made.
: reserve-multiple ( hash -- ? )
    dup keys V{ } clone (reserve-multiple) ;

: change-at* ( key assoc quot -- assoc )
    over [ change-at ] dip ; inline

! Should be given a view URL.
: ((get-user)) ( couchdb-url -- user/f )
    couch-get
    "rows" swap at dup empty? [ drop f ] [ first "value" swap at ] if ;

: (get-user) ( username -- user/f )
    couchdb-auth-provider get
    username-view>> get-url
    swap >json "key" set-query-param
    ((get-user)) ;

: strip-hash ( hash1 -- hash2 )
    [ drop first CHAR: _ = not ] assoc-filter ;

: at-or-k ( key hash -- newkey )
    dupd at [ nip ] when* ;
: value-at-or-k ( key hash -- newkey )
    dupd value-at [ nip ] when* ;

: map-fields-forward ( assoc field-map -- assoc )
    [ swapd at-or-k swap ] curry assoc-map ;

: map-fields-backward ( assoc field-map -- assoc )
    [ swapd value-at-or-k swap ] curry assoc-map ;

: user-hash>user ( hash -- user )
    couchdb-auth-provider get field-map>> map-fields-backward
    [ "password" swap [ base64> >byte-array ] change-at ]
    [
        strip-hash
        user new dup [ make-mirror swap assoc-union! drop ] dip
        f >>changed?
    ]
    bi ;

: user>user-hash ( user -- hash )
     hash-mirror
     [ [ "password" ] dip [ >base64 >string ] change-at ] keep
     couchdb-auth-provider get field-map>> map-fields-forward ;

! Used when the user is guaranteed to exist if the logic of the Factor
! code is correct (e.g. when update-user is called).
! In the unlikely event that the user does not exist, an error is thrown.
: (get-user)/throw-on-no-user ( username -- user/f )
    (get-user) [ ] [ "User not found" throw ] if* ;

: (new-user) ( user -- user/f )
    dup
    [
        [ username>> "username" ,, ]
        [ email>> "email" ,, ]
        bi
    ] H{ } make
    reserve-multiple
    [
        user>user-hash >json
        "" get-url
        couch-post
    ] [
        drop f
    ] if ;

: unify-users ( old new -- new )
    swap
    [ "_rev" swap at "_rev" rot set-at ]
    [ "_id" swap at "_id" rot set-at ]
    [ swap assoc-union ]
    2tri ;

! If the user has changed username or email address,
! we should let other registrants use the old ones,
! and make sure that the new ones are reserved.
! (This word is called by the 'update-user' method.)
: check-update ( old new -- ? )
    [
        2dup [ "email" swap at ] bi@ = not [
            [ "email" swap at ] bi@
            [ drop "email" reservation-id unreserve-from-id ]
            [ nip "email" reserve ]
            2bi
        ] [ 2drop t ] if
    ] [
        2dup [ "username" swap at ] bi@ = not [
            [ "username" swap at ] bi@
            [ drop "username" reservation-id unreserve-from-id ]
            [ nip "username" reserve ]
            2bi
        ] [ 2drop t ] if
    ] 2bi and ;

PRIVATE>

: <couchdb-auth-provider> ( base-url username-view -- couchdb-auth-provider )
    couchdb-auth-provider new swap >>username-view swap >>base-url ;

M: couchdb-auth-provider get-user ( username provider -- user/f )
    couchdb-auth-provider [
        (get-user) [ user-hash>user ] [ f ] if*
    ] with-variable ;

M: couchdb-auth-provider new-user ( user provider -- user/f )
    couchdb-auth-provider [
        dup (new-user) [
            username>> couchdb-auth-provider get get-user
        ] [ drop f ] if
    ] with-variable ;

M: couchdb-auth-provider update-user ( user provider -- )
    couchdb-auth-provider [
        [ username>> (get-user)/throw-on-no-user dup ]
        [ drop "_id" swap at get-url ]
        [ user>user-hash swapd
          2dup check-update drop
          unify-users >json swap couch-put drop
        ]
        tri
    ] with-variable ;
