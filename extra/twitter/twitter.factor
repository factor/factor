USING: accessors assocs hashtables http http.client json.reader
kernel namespaces urls.secure urls.encoding ;
IN: twitter

SYMBOLS: twitter-username twitter-password ;

: set-twitter-credentials ( username password -- )
    [ twitter-username set ] [ twitter-password set ] bi* ; 

: set-request-twitter-auth ( request -- request )
    twitter-username twitter-password [ get ] bi@ set-basic-auth ;

: update-post-data ( update -- assoc )
    "status" associate ;

: tweet* ( string -- result )
    update-post-data "https://twitter.com/statuses/update.json" <post-request>
        set-request-twitter-auth 
    http-request nip json> ;

: tweet ( string -- ) tweet* drop ;

