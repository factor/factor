! Copyright (C) 2023 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs assocs.extras checksums checksums.sha
combinators formatting hashtables hex-strings http http.client
http.client.post-data io io.files io.pathnames json kernel make
namespaces namespaces.extras sequences sorting urls ;
IN: backblaze

SYMBOL: backblaze-application-key-id
SYMBOL: backblaze-application-key

SYMBOL: b2-authorized-account

: 2bl ( -- ) bl bl ; inline

: <post-request-with-headers> ( post-data headers url -- request )
    >url
    swap
    [ <post-request> ] dip set-headers ;

! Used on the first api call to get the account id and api url
: b2-add-basic-auth-header ( request -- request' )
    backblaze-application-key-id required
    backblaze-application-key required basic-auth "Authorization" set-header ;

: b2-authorize-account ( -- json )
    "https://api.backblazeb2.com/b2api/v3/b2_authorize_account" <get-request>
    b2-add-basic-auth-header
    http-request-json nip ;

: with-b2 ( quot -- )
    [ b2-authorize-account b2-authorized-account ] dip with-variable ; inline

: authorized-account-id ( -- account-id )
    b2-authorized-account required "accountId" of ;
: authorized-account-api-url ( -- api-url )
    b2-authorized-account required "apiInfo" of "storageApi" of "apiUrl" of ;
: authorized-authorization-token ( -- api-url )
    b2-authorized-account required "authorizationToken" of ;

: b2-add-auth-header ( request -- request' )
    authorized-authorization-token "Authorization" set-header ;
: b2-add-account-id ( assoc -- assoc )
    authorized-account-id "accountId" pick set-at ;

: b2-get-request* ( path accountId? -- json )
    [ authorized-account-api-url prepend >url ]
    [ [ authorized-account-id "accountId" set-query-param ] when ] bi*
    <get-request>
    b2-add-auth-header
    http-request-json nip ;

: b2-get-request-with-params ( params path -- json )
    authorized-account-api-url prepend >url
    swap set-query-params
    <get-request>
    b2-add-auth-header
    http-request-json nip ;

: b2-get-request-with-account-id ( path -- json ) t b2-get-request* ;
: b2-get-request ( path -- json ) f b2-get-request* ;

: b2-post-request* ( assoc path accountId? -- json' )
    swap [ [ b2-add-account-id ] when >json ] dip
    authorized-account-api-url prepend <post-request>
    b2-add-auth-header
    http-request-json nip ;

: b2-post-request-with-account-id ( assoc path -- json ) t b2-post-request* ;
: b2-post-request ( assoc path -- json ) f b2-post-request* ;

: b2-storage-api. ( json -- )
    {
        [ "infoType" of "infoType: %s" sprintf 2bl print ]
        [ "apiUrl" of "apiUrl: %s" sprintf 2bl print ]
        [ "bucketId" of "bucketId: %s" sprintf 2bl print ]
        [ "bucketName" of "bucketName: %s" sprintf 2bl print ]
        [ "namePrefix" of "namePrefix: %s" sprintf 2bl print ]
        [ "downloadUrl" of "downloadUrl: %s" sprintf 2bl print ]
        [ "s3ApiUrl" of "s3ApiUrl: %s" sprintf 2bl print ]
        [ "absoluteMinimumPartSize" of "absoluteMinimumPartSize: %d" sprintf 2bl print ]
        [ "recommendedPartSize" of "recommendedPartSize: %d" sprintf 2bl print ]
        [ "capabilities" of "capabilities:" 2bl print sort [ 2bl 2bl print ] each ]
    } cleave ;

: b2-auth. ( json -- )
    {
        [ "accountId" of "accountId: %s" sprintf print ]
        [ "apiInfo" of "appInfo" print "storageApi" of b2-storage-api. ]
        [ "applicationKeyExpirationTimestamp" of "applicationKeyExpirationTimestamp: %s" sprintf print ]
        [ "authorizationToken" of "authorizationToken: %s" sprintf print ]
    } cleave ;

! H{ { "bucketName" "test123" } { "bucketType" "allPrivate" } }
: b2-create-bucket* ( assoc -- json' )
    "/b2api/v2/b2_create_bucket" b2-post-request-with-account-id ;
: b2-create-bucket ( assoc -- json' ) [ b2-create-bucket* ] with-b2 ;

: vaka ( value assoc key -- assoc ) swapd swap set-of ; inline
: kava ( key assoc value -- assoc ) swapd set-of ; inline

: b2-create-bucket-by-name-type ( bucket-name bucket-type -- json' )
    "bucketType" associate
    "bucketName" vaka b2-create-bucket ;

: b2-create-private-bucket-by-name ( bucket-name -- json' )
    "allPrivate" b2-create-bucket-by-name-type ;

: b2-list-buckets* ( -- json )
    "/b2api/v2/b2_list_buckets" b2-get-request-with-account-id ;
: b2-list-buckets ( -- json ) [ b2-list-buckets* ] with-b2 ;

: buckets-by-name ( -- assoc )
    b2-list-buckets "buckets" of [ [ "bucketName" of ] keep ] H{ } map>assoc ;

ERROR: bucket-does-not-exist bucket-name ;
: get-bucket-by-name ( bucket-name -- bucket/* )
    buckets-by-name ?at [ bucket-does-not-exist ] unless ;

: b2-delete-bucket* ( assoc -- json' )
    "/b2api/v2/b2_delete_bucket" b2-post-request-with-account-id ;
: b2-delete-bucket ( assoc -- json' ) [ b2-delete-bucket* ] with-b2 ;

: extract-key-value ( assoc key -- pair )
    [ of ] keep associate ; inline

: b2-delete-bucket-by-name ( bucket-name -- json' )
    [
        get-bucket-by-name "bucketId" extract-key-value b2-delete-bucket*
    ] with-b2 ;

: b2-list-keys* ( -- json ) "/b2api/v2/b2_list_keys" b2-get-request-with-account-id ;
: b2-list-keys ( -- json ) [ b2-list-keys* ] with-b2 ;

: b2-get-upload-url* ( assoc -- json ) "/b2api/v3/b2_get_upload_url" b2-get-request-with-params ;
: b2-get-upload-url ( assoc -- json ) [ b2-get-upload-url* ] with-b2 ;

: b2-list-parts* ( assoc -- json ) "/b2api/v2/b2_list_parts" b2-get-request-with-params ;
: b2-list-parts ( assoc -- json ) [ b2-list-parts* ] with-b2 ;

: b2-upload-file* ( post-data headers bucket-name -- json )
    [
        "/b2api/v2/b2_upload_file" authorized-account-api-url prepend
        <post-request-with-headers>
        b2-add-auth-header
    ] dip
    get-bucket-by-name "bucketId" extract-key-value b2-get-upload-url
    [ "uploadUrl" of >url >>url ]
    [ "authorizationToken" of "Authorization" set-header ] bi
    dup header>> "Connection" delete-of drop
    http-request-json nip ;

! "resource:LICENSE.txt" utf8 prepare-b2-binary-file "bucket-name" b2-upload-file
: b2-upload-file ( post-data headers bucket-name -- json ) [ b2-upload-file* ] with-b2 ;

: prepare-b2-binary-file ( path encoding -- post-data headers )
    [
        "b2/x-auto" "Content-Type" ,,
        {
            [ drop file-name "X-Bz-File-Name" ,, ]
            [ drop sha1 checksum-file bytes>hex-string "X-Bz-Content-Sha1" ,, ]
            [ file-contents >post-data ]
        } 2cleave
    ] H{ } make ;

: b2-upload-path ( path encoding bucket-name -- json )
    [ prepare-b2-binary-file ] dip b2-upload-file ;
