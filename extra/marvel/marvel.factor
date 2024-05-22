! Copyright (C) 2014 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs checksums checksums.md5 hex-strings http.client
json kernel math.parser namespaces sequences strings system urls ;
IN: marvel

! https://developer.marvel.com/docs
! Register for an api key.
SYMBOLS: marvel-base-url marvel-public-key marvel-private-key ;

marvel-base-url [ "https://gateway.marvel.com/v1/public/" ] initialize

: calculate-hash ( ts -- hash )
    number>string
    marvel-private-key get
    marvel-public-key get
    3append md5 checksum-bytes bytes>hex-string ;

:: make-marvel-params-url ( endpoint params -- url )
    nano-count
    [ "ts" params set-at ]
    [ calculate-hash "hash" params set-at ] bi
    marvel-public-key get "apikey" params set-at
    marvel-base-url get endpoint [ >url ] bi@ derive-url
    params [ swap set-query-param ] assoc-each ;

: make-marvel-url ( endpoint -- string )
    H{ } clone make-marvel-params-url ;

: get-marvel-params-url ( endpoint params -- data )
    make-marvel-params-url http-get nip >string json> ;

: get-marvel-url ( endpoint -- data )
    H{ } clone get-marvel-params-url ;

: get-characters ( -- json ) "characters" get-marvel-url ;
: get-comics ( -- json ) "comics" get-marvel-url ;
: get-creators ( -- json ) "creators" get-marvel-url ;
: get-events ( -- json ) "events" get-marvel-url ;
: get-series ( -- json ) "series" get-marvel-url ;
: get-stories ( -- json ) "stories" get-marvel-url ;
