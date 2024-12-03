! Copyright (C) 2023 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays ascii assocs calendar calendar.format
calendar.parser checksums checksums.hmac checksums.sha
combinators combinators.short-circuit formatting hex-strings
http ini-file io.directories io.encodings.utf8 io.files
io.files.info io.pathnames io.streams.string json kernel math
math.order sequences sets sorting splitting urls urls.encoding ;
IN: aws

: aws-timestamp-valid? ( str -- duration-valid valid? )
    rfc3339>timestamp now-gmt time- dup duration>seconds 0 > ;

: unexpired? ( json -- ? )
    {
        [ "expiresAt" of ]
        [ "expiresAt" of rfc3339>timestamp now >utc after? ]
    } 1&& ;

: client-json? ( json -- ? )
    { [ "clientId" of ] [ "clientSecret" of ] [ "expiresAt" of ] } 1&& ;

: access-token-json? ( json -- ? )
    { [ "region" of ] [ "accessToken" of ] [ "startUrl" of ] [ "expiresAt" of ] } 1&& ;

: parse-by-filename ( string path -- object )
    file-name {
        { [ dup "config" = ] [ drop string>ini ] }
        { [ dup "credentials" = ] [ drop string>ini ] }
        { [ dup file-extension "json" = ] [ drop json> ] }
        [ drop ]
    } cond ;

: aws-hidden-files ( -- assoc )
    home ".aws" append-path recursive-directory-files
    [ directory? ] reject
    [ [ utf8 file-contents ] keep parse-by-filename ] zip-with
    [ dup ".aws" swap subseq-start tail ] map-keys ;

: aws-unexpired ( -- seq )
    aws-hidden-files [ unexpired? ] filter-values ;

: aws-client-json ( -- json )
    aws-unexpired [ client-json? ] filter-values values ?first ;

: aws-access-token ( -- json )
    aws-unexpired [ access-token-json? ] filter-values values ?first ;

! Get this from awsapps.com
! [[ export AWS_ACCESS_KEY_ID="..."
! export AWS_SECRET_ACCESS_KEY="..."
! export AWS_SESSION_TOKEN="..."]] string>aws-creds
TUPLE: aws-creds access-key-id secret-access-key session-token ;

: <aws-creds> ( access-key-id secret-access-key session-token -- aws-creds )
    aws-creds new
        swap >>session-token
        swap >>secret-access-key
        swap >>access-key-id ; inline

: parse-shell-credentials ( string -- assoc )
    string-lines
    [ blank? ] trim sift
    [ "export " ?head drop ] map
    [ "=" split1 [ CHAR: " = ] trim 2array ] map ;

: string>aws-creds ( string -- aws-creds )
    parse-shell-credentials
    [ "AWS_ACCESS_KEY_ID" of ]
    [ "AWS_SECRET_ACCESS_KEY" of ]
    [ "AWS_SESSION_TOKEN" of ] tri <aws-creds> ;

: aws-date ( -- string )
    [ now >utc { YYYY MM DD } formatted ] with-string-writer ;

: aws-timestamp ( -- string )
    [ now >utc { YYYY MM DD "T" hh mm ss "Z" } formatted ] with-string-writer ;

: make-canonical-headers ( assoc -- string )
    clone [ >lower ] map-keys
    sort-keys [ ":" glue "\n" append ] { } assoc>map concat ;

: canonical-header-keys ( assoc -- string )
    keys [ >lower ] map members sort ";" join ;

: aws4-signing-key ( service region creds -- string )
    secret-access-key>> "AWS4" prepend
        aws-date swap sha-256 hmac-bytes
    sha-256 hmac-bytes
    sha-256 hmac-bytes
    "aws4_request" swap sha-256 hmac-bytes ;

:: sign-aws-request ( request service region creds -- request )
    request
        "Connection" delete-header
        request url>> host>> "Host" set-header
        aws-timestamp "X-Amz-Date" set-header
        "application/json" "accept" set-header
        creds session-token>> "x-amz-security-token" set-header
        url>> "DescribeKeyPairs" "Action" set-query-param
    drop

    request data>> sha-256 checksum-bytes bytes>hex-string :> body-hex-hash

    request
        dup data>> [
            body-hex-hash "x-amz-content-sha256" set-header
            ! content-type "Content-Type" set-header
        ] when
    header>>
    [ make-canonical-headers ]
    [ canonical-header-keys ] bi :> ( canonical-headers-string signed-headers-string )

    aws-date region service
        "%s/%s/%s/aws4_request" sprintf :> credential-scope-string

    request
        [ method>> ] [ url>> path>> ] [ url>> query>> assoc>query ] tri
        canonical-headers-string
        signed-headers-string
        body-hex-hash
        "%s\n%s\n%s\n%s\n%s\n%s" sprintf
        sha-256 checksum-bytes bytes>hex-string :> canonical-request-hash

    "AWS4-HMAC-SHA256"
        aws-timestamp
        credential-scope-string
        canonical-request-hash
        "%s\n%s\n%s\n%s" sprintf :> string-to-sign

    "AWS4-HMAC-SHA256"
        creds access-key-id>>
        credential-scope-string
        signed-headers-string
        string-to-sign service region creds
            aws4-signing-key sha-256 hmac-bytes bytes>hex-string
        "%s Credential=%s/%s, SignedHeaders=%s, Signature=%s" sprintf :> authorization-header-string

    request
        authorization-header-string "Authorization" set-header
        "close" "Connection" set-header ;
