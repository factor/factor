! Copyright (C) 2005, 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
IN: xml-rpc
USING: kernel xml arrays math generic http.client combinators
    hashtables namespaces io base64 sequences strings calendar
    xml.data xml.writer xml.utilities assocs math.parser debugger
    calendar.format ;

! * Sending RPC requests
! TODO: time
! The word for what this does is "serialization"! Wow!

GENERIC: item>xml ( object -- xml )

M: integer item>xml
    dup 31 2^ neg 31 2^ 1 - between?
    [ "Integers must fit in 32 bits" throw ] unless
    number>string "i4" build-tag ;

PREDICATE: boolean < object { t f } member? ;

M: boolean item>xml
    "1" "0" ? "boolean" build-tag ;

M: float item>xml
    number>string "double" build-tag ;

M: string item>xml ! This should change < and &
    "string" build-tag ;

: struct-member ( name value -- tag )
    swap dup string?
    [ "Struct member name must be string" throw ] unless
    "name" build-tag swap
    item>xml "value" build-tag
    2array "member" build-tag* ;

M: hashtable item>xml
    [ struct-member ] { } assoc>map
    "struct" build-tag* ;

M: array item>xml
    [ item>xml "value" build-tag ] map
    "data" build-tag* "array" build-tag ;

TUPLE: base64 string ;

C: <base64> base64

M: base64 item>xml
    base64-string >base64 "base64" build-tag ;

: params ( seq -- xml )
    [ item>xml "value" build-tag "param" build-tag ] map
    "params" build-tag* ;

: method-call ( name seq -- xml )
    params >r "methodName" build-tag r>
    2array "methodCall" build-tag* build-xml ;

: return-params ( seq -- xml )
    params "methodResponse" build-tag build-xml ;

: return-fault ( fault-code fault-string -- xml )
    [ "faultString" set "faultCode" set ] H{ } make-assoc item>xml
    "value" build-tag "fault" build-tag "methodResponse" build-tag
    build-xml ;

TUPLE: rpc-method name params ;

C: <rpc-method> rpc-method

TUPLE: rpc-response params ;

C: <rpc-response> rpc-response

TUPLE: rpc-fault code string ;

C: <rpc-fault> rpc-fault

GENERIC: send-rpc ( rpc -- xml )
M: rpc-method send-rpc
    [ rpc-method-name ] keep rpc-method-params method-call ;
M: rpc-response send-rpc
    rpc-response-params return-params ;
M: rpc-fault send-rpc
    [ rpc-fault-code ] keep rpc-fault-string return-fault ;

! * Recieving RPC requests
! this needs to have much better error checking

TUPLE: server-error tag message ;

: server-error ( tag message -- * )
    \ server-error construct-boa throw ;

M: server-error error.
    "Error in XML supplied to server" print
    "Description: " write dup server-error-message print
    "Tag: " write server-error-tag xml>string print ;

PROCESS: xml>item ( tag -- object )

TAG: string xml>item
    children>string ;

TAG: i4/int/double xml>item
    children>string string>number ;

TAG: boolean xml>item
    dup children>string {
        { [ dup "1" = ] [ 2drop t ] }
        { [ "0" = ] [ drop f ] }
        { [ t ] [ "Bad boolean" server-error ] }
    } cond ;

: unstruct-member ( tag -- )
    children-tags first2
    first-child-tag xml>item
    >r children>string r> swap set ;

TAG: struct xml>item
    [
        children-tags [ unstruct-member ] each
    ] H{ } make-assoc ;

TAG: base64 xml>item
    children>string base64> <base64> ;

TAG: array xml>item
    first-child-tag children-tags
    [ first-child-tag xml>item ] map ;

: params>array ( tag -- array )
    children-tags
    [ first-child-tag first-child-tag xml>item ] map ;

: parse-rpc-response ( xml -- array )
    first-child-tag params>array ;

: parse-method ( xml -- string array )
    children-tags dup first children>string
    swap second params>array ;

: parse-fault ( xml -- fault-code fault-string )
    first-child-tag first-child-tag first-child-tag
    xml>item [ "faultCode" get "faultString" get ] bind ;

: receive-rpc ( xml -- rpc )
    dup name-tag dup "methodCall" =
    [ drop parse-method <rpc-method> ] [
        "methodResponse" = [
            dup first-child-tag name-tag "fault" =
            [ parse-fault <rpc-fault> ]
            [ parse-rpc-response <rpc-response> ] if
        ] [ "Bad main tag name" server-error ] if
    ] if ;

: post-rpc ( rpc url -- rpc )
    ! This needs to do something in the event of an error
    >r "text/xml" swap send-rpc xml>string r> http-post
    2nip string>xml receive-rpc ;

: invoke-method ( params method url -- )
    >r swap <rpc-method> r> post-rpc ;

: put-http-response ( string -- )
    "HTTP/1.1 200 OK\nConnection: close\nContent-Length: " write
    dup length number>string write
    "\nContent-Type: text/xml\nDate: " write
    now timestamp>http-string write "\n\n" write
    write ;
