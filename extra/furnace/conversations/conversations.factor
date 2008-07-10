! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces assocs kernel sequences accessors hashtables
urls db.types db.tuples math.parser fry logging combinators
html.templates.chloe.syntax
http http.server http.server.filters http.server.redirection
furnace
furnace.cache
furnace.scopes
furnace.sessions
furnace.redirection ;
IN: furnace.conversations

TUPLE: conversation < scope
session
method url post-data ;

: <conversation> ( id -- aside )
    conversation new-server-state ;

conversation "CONVERSATIONS" {
    { "session" "SESSION" BIG-INTEGER +not-null+ }
    { "method" "METHOD" { VARCHAR 10 } }
    { "url" "URL" URL }
    { "post-data" "POST_DATA" FACTOR-BLOB }
} define-persistent

: conversation-id-key "__f" ;

TUPLE: conversations < server-state-manager ;

: <conversations> ( responder -- responder' )
    conversations new-server-state-manager ;

SYMBOL: conversation

SYMBOL: conversation-id

: cget ( key -- value )
    conversation get scope-get ;

: cset ( value key -- )
    conversation get scope-set ;

: cchange ( key quot -- )
    conversation get scope-change ; inline

: get-conversation ( id -- conversation )
    dup [ conversation get-state ] when
    dup [ dup session>> session get id>> = [ drop f ] unless ] when ;

: request-conversation-id ( request -- id )
    conversation-id-key swap request-params at string>number ;

: request-conversation ( request -- conversation )
    request-conversation-id get-conversation ;

: init-conversations ( -- )
    request get request-conversation-id
    [ conversation-id set ]
    [ get-conversation conversation set ]
    bi ;

M: conversations call-responder*
    init-conversations
    [ conversations set ] [ call-next-method ] bi ;

: empty-conversastion ( -- conversation )
    conversation empty-scope
        session get id>> >>session ;

: add-conversation ( conversation -- id )
    [ conversations get touch-state ] [ insert-tuple ] [ id>> ] tri ;

: begin-conversation* ( -- id )
    empty-conversastion add-conversation ;

: begin-conversation ( -- )
    conversation-id [ [ begin-conversation* ] unless* ] change ;

: <conversation-redirect> ( url seq -- response )
    begin-conversation
    [ [ get ] keep cset ] each
    <redirect> ;

: restore-conversation ( seq -- )
    conversation get dup [
        namespace>>
        [ '[ , key? ] filter ]
        [ '[ [ , at ] keep set ] each ]
        bi
    ] [ 2drop ] if ;

: begin-aside* ( -- id )
    empty-conversastion
        request get
        [ method>> >>method ]
        [ url>> >>url ]
        [ post-data>> >>post-data ]
        tri
    add-conversation ;

: begin-aside ( -- )
    begin-aside* conversation-id set ;

: end-aside-post ( aside -- response )
    request [
        clone
            over post-data>> >>post-data
            over url>> >>url
    ] change
    url>> path>> split-path
    conversations get responder>> call-responder ;

\ end-aside-post DEBUG add-input-logging

ERROR: end-aside-in-get-error ;

: end-aside* ( url id -- response )
    post-request? [ end-aside-in-get-error ] unless
    get-conversation [
        dup method>> {
            { "GET" [ url>> <redirect> ] }
            { "HEAD" [ url>> <redirect> ] }
            { "POST" [ end-aside-post ] }
        } case
    ] [ <redirect> ] ?if ;

: end-aside ( default -- response )
    conversation-id [ f ] change end-aside* ;

M: conversations link-attr ( tag -- )
    drop
    "aside" optional-attr {
        { "none" [ conversation-id off ] }
        { "begin" [ begin-aside ] }
        { "current" [ ] }
        { f [ ] }
    } case ;

M: conversations modify-query ( query conversations -- query' )
    drop
    conversation-id get [
        conversation-id-key associate assoc-union
    ] when* ;

M: conversations modify-form ( conversations -- )
    drop
    conversation-id get
    conversation-id-key
    hidden-form-field ;
