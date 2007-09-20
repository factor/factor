! Copyright (C) 2004 Chris Double.
! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: html http http.server.responders io kernel math namespaces
continuations random system sequences assocs ;

IN: http.server.responders.callback

#! Name of the variable holding the continuation used to exit
#! back to the httpd responder.
SYMBOL: exit-continuation 

#! Tuple to hold global request data. This gets passed to
#! the continuation when resumed so it can restore things
#! like 'stdio' so it writes to the correct socket. 
TUPLE: request stream exitcc method url raw-query query header response ;

: <request> ( -- request )
  stdio get
  exit-continuation get
  "method" get
  "request" get
  "raw-query" get
  "query" get
  "header" get
  "response" get
  request construct-boa ;

: restore-request ( -- )
  request get 
  dup request-stream stdio set 
  dup request-method "method" set 
  dup request-raw-query "raw-query" set 
  dup request-query "query" set 
  dup request-header "header" set 
  dup request-response "response" set 
  request-exitcc exit-continuation set ;

: update-request ( request new-request -- )
  [ request-stream over set-request-stream ] keep 
  [ request-method over set-request-method ] keep 
  [ request-url over set-request-url ] keep 
  [ request-raw-query over set-request-raw-query ] keep 
  [ request-query over set-request-query ] keep 
  [ request-header over set-request-header ] keep 
  [ request-response over set-request-response ] keep 
  request-exitcc swap set-request-exitcc ;
  
: with-exit-continuation ( quot -- ) 
    #! Call the quotation with the variable exit-continuation bound 
    #! such that when the exit continuation is called, computation 
    #! will resume from the end of this 'with-exit-continuation' call. 
    [ 
        exit-continuation set call exit-continuation get continue
    ] callcc0 drop ;

: expiry-timeout ( -- ms ) 900 1000 * ;

: get-random-id ( -- id ) 
    #! Generate a random id to use for continuation URL's
    "ID" 32 [ drop 9 random CHAR: 0 + ] map append ;

: callback-table ( -- <hashtable> ) 
    #! Return the global table of continuations
    \ callback-table get-global ;

: reset-callback-table ( -- ) 
    #! Create the initial global table
    H{ } clone \ callback-table set-global ;

reset-callback-table

#! Tuple for holding data related to a callback.
TUPLE: item quot expire? request id  time-added ;

: <item> ( quot expire? request id -- item )
    millis item construct-boa ;

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
        expired? [ callback-table delete-at ] [ drop ] if
    ] assoc-each ;

: id>url ( id -- string )
    #! Convert the continuation id to an URL suitable for
    #! embedding in an HREF or other HTML.
    "/responder/callback/?id=" swap url-encode append ;

: register-callback ( quot expire? -- url ) 
    #! Store a continuation in the table and associate it with
    #! a random id. That continuation will be expired after
    #! a certain period of time if 'expire?' is true.  
    request get get-random-id [ <item> ] keep
    [ callback-table set-at ] keep
    id>url ;

: register-html-callback ( quot expire? -- url )
    >r [ serving-html ] swap append r> register-callback ;

: callback-responder ( -- )   
    expire-callbacks
    "id" query-param callback-table at [
        [
  	  dup item-request [
            <request> update-request
          ] when*
          item-quot call 
          exit-continuation get continue 
        ] with-exit-continuation drop
    ] [
        "404 Callback not available" httpd-error
    ] if* ;

global [
    "callback" [ callback-responder ] add-simple-responder
] bind
