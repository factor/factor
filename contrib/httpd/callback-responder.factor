! Copyright (C) 2004 Chris Double.
! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: callback-responder
USING: hashtables html http httpd io kernel math namespaces
sequences ;

: expiry-timeout ( -- ms ) 900 1000 * ;

: get-random-id ( -- id ) 
    #! Generate a random id to use for continuation URL's
    [ "ID" % 32 [ 9 random-int CHAR: 0 + , ] times ] "" make ;

: callback-table ( -- <hashtable> ) 
    #! Return the global table of continuations
    \ callback-table get-global ;

: reset-callback-table ( -- ) 
    #! Create the initial global table
    H{ } clone \ callback-table set-global ;

reset-callback-table

#! Tuple for holding data related to a callback.
TUPLE: item quot expire? id time-added ;

C: item ( quot expire? id -- item )
    millis over set-item-time-added
    [ set-item-id ] keep
    [ set-item-expire? ] keep
    [ set-item-quot ] keep ;

: expired? ( item -- ? )
    #! Return true if the callback item is expirable
    #! and has expired (ie. was added to the table more than
    #! timeout milliseconds ago).
    [ item-time-added expiry-timeout + millis < ] keep
    item-expire? and ;

: expire-callbacks ( -- )
    #! Expire all continuations in the continuation table
    #! if they are 'timeout-seconds' old (ie. were added
    #! more than 'timeout-seconds' ago.
    callback-table clone [
        expired? [ callback-table remove-hash ] [ drop ] if
    ] hash-each ;

: id>url ( id -- string )
    #! Convert the continuation id to an URL suitable for
    #! embedding in an HREF or other HTML.
    "/responder/callback/?id=" swap url-encode append ;

: register-callback ( quot expire? -- url ) 
    #! Store a continuation in the table and associate it with
    #! a random id. That continuation will be expired after
    #! a certain period of time if 'expire?' is true.  
    get-random-id [ <item> ] keep
    [ callback-table set-hash ] keep
    id>url ;

: register-html-callback ( quot expire? -- url )
    >r [ serving-html ] swap append r> register-callback ;

: callback-responder ( -- )
    expire-callbacks
    "id" query-param callback-table hash [
        item-quot call
    ] [
        "404 Callback not available" httpd-error
    ] if* ;
