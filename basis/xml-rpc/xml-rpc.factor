! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs base64 calendar calendar.format
combinators debugger generic hashtables http http.client
http.client.private io io.encodings.string io.encodings.utf8
kernel make math math.order math.parser namespaces sequences
strings xml xml.data xml.syntax xml.traversal xml.writer ;
IN: xml-rpc

! * Sending RPC requests
! TODO: time
! The word for what this does is "serialization"! Wow!

GENERIC: item>xml ( object -- xml )

M: integer item>xml
    dup 31 2^ neg 31 2^ 1 - between?
    [ "Integers must fit in 32 bits" throw ] unless
    [XML <i4><-></i4> XML] ;

M: boolean item>xml
    "1" "0" ? [XML <boolean><-></boolean> XML] ;

M: float item>xml
    number>string [XML <double><-></double> XML] ;

M: string item>xml
    [XML <string><-></string> XML] ;

: struct-member ( name value -- tag )
    over string? [ "Struct member name must be string" throw ] unless
    item>xml
    [XML
        <member>
            <name><-></name>
            <value><-></value>
        </member>
    XML] ;

M: hashtable item>xml
    [ struct-member ] { } assoc>map
    [XML <struct><-></struct> XML] ;

M: array item>xml
    [ item>xml [XML <value><-></value> XML] ] map
    [XML <array><data><-></data></array> XML] ;

TUPLE: base64 string ;

C: <base64> base64

M: base64 item>xml
    string>> >base64
    [XML <base64><-></base64> XML] ;

: params ( seq -- xml )
    [ item>xml [XML <param><value><-></value></param> XML] ] map
    [XML <params><-></params> XML] ;

: method-call ( name seq -- xml )
    params
    <XML
        <methodCall>
            <methodName><-></methodName>
            <->
        </methodCall>
    XML> ;

: return-params ( seq -- xml )
    params <XML <methodResponse><-></methodResponse> XML> ;

: return-fault ( fault-code fault-string -- xml )
    [ "faultString" ,, "faultCode" ,, ] H{ } make item>xml
    <XML
        <methodResponse>
            <fault>
                <value><-></value>
            </fault>
        </methodResponse>
    XML> ;

TUPLE: rpc-method name params ;

C: <rpc-method> rpc-method

TUPLE: rpc-response params ;

C: <rpc-response> rpc-response

TUPLE: rpc-fault code string ;

C: <rpc-fault> rpc-fault

GENERIC: send-rpc ( rpc -- xml )
M: rpc-method send-rpc
    [ name>> ] [ params>> ] bi method-call ;
M: rpc-response send-rpc
    params>> return-params ;
M: rpc-fault send-rpc
    [ code>> ] [ string>> ] bi return-fault ;

! * Recieving RPC requests
! this needs to have much better error checking

ERROR: server-error tag message ;

M: server-error error.
    "Error in XML supplied to server" print
    "Description: " write dup message>> print
    "Tag: " write tag>> xml>string print ;

TAGS: xml>item ( tag -- object )

TAG: string xml>item
    children>string ;

: children>number ( tag -- n )
    children>string string>number ;

TAG: i4 xml>item children>number ;
TAG: int xml>item children>number ;
TAG: double xml>item children>number ;

TAG: boolean xml>item
    children>string {
        { "1" [ t ] }
        { "0" [ f ] }
        [ "Bad boolean" server-error ]
    } case ;

: unstruct-member ( tag -- )
    children-tags first2
    first-child-tag xml>item
    [ children>string ] dip swap ,, ;

TAG: struct xml>item
    [
        children-tags [ unstruct-member ] each
    ] H{ } make ;

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
    children-tags first2
    [ children>string ] [ params>array ] bi* ;

: parse-fault ( xml -- fault-code fault-string )
    first-child-tag first-child-tag first-child-tag
    xml>item [ "faultCode" get "faultString" get ] with-variables ;

: receive-rpc ( xml -- rpc )
    dup main>> dup "methodCall" =
    [ drop parse-method <rpc-method> ] [
        "methodResponse" = [
            dup first-child-tag main>> "fault" =
            [ parse-fault <rpc-fault> ]
            [ parse-rpc-response <rpc-response> ] if
        ] [ "Bad main tag name" server-error ] if
    ] if ;

<PRIVATE

: xml-post-data ( xml -- post-data )
    xml>string utf8 encode "text/xml" <post-data> swap >>data ;

: rpc-post-request ( xml url -- request )
    [ send-rpc xml-post-data ] [ "POST" <client-request> ] bi*
    swap >>post-data ;

PRIVATE>

: post-rpc ( rpc url -- rpc' )
    ! This needs to do something in the event of an error
    rpc-post-request http-request nip string>xml receive-rpc ;

: invoke-method ( params method url -- response )
    [ swap <rpc-method> ] dip post-rpc ;
