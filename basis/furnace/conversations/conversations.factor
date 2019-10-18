! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces assocs kernel sequences accessors hashtables
urls db.types db.tuples math.parser fry logging combinators
html.templates.chloe.syntax
http http.server http.server.filters http.server.redirection
furnace.cache
furnace.scopes
furnace.sessions
furnace.utilities
furnace.redirection ;
IN: furnace.conversations

TUPLE: conversation < scope session ;

: <conversation> ( id -- conversation )
    conversation new-server-state ;

conversation "CONVERSATIONS" {
    { "session" "SESSION" BIG-INTEGER +not-null+ }
} define-persistent

CONSTANT: conversation-id-key "__c"

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
    dup [ conversation get-state ] when check-session ;

: request-conversation-id ( request -- id )
    conversation-id-key swap request-params at string>number ;

: request-conversation ( request -- conversation )
    request-conversation-id get-conversation ;

: save-conversation-after ( conversation -- )
    conversations get save-scope-after ;

: set-conversation ( conversation -- )
    [
        [ conversation set ]
        [ id>> conversation-id set ]
        [ save-conversation-after ]
        tri
    ] when* ;

: init-conversations ( conversations -- )
    conversations set
    request get request-conversation
    set-conversation ;

M: conversations call-responder*
    [ init-conversations ]
    [ conversations set ]
    [ call-next-method ]
    tri ;

: empty-conversastion ( -- conversation )
    conversation empty-scope
        session get id>> >>session ;

: touch-conversation ( conversation -- )
    conversations get touch-state ;

: add-conversation ( conversation -- )
    [ touch-conversation ] [ insert-tuple ] bi ;

: begin-conversation ( -- )
    conversation get [
        empty-conversastion
        [ add-conversation ]
        [ set-conversation ] bi
    ] unless ;

: end-conversation ( -- )
    conversation off
    conversation-id off ;

: <continue-conversation> ( url -- response )
    conversation-id get
    conversation-id-key
    set-query-param
    <redirect> ;

: restore-conversation ( seq -- )
    conversation get [
        namespace>>
        [ '[ _ key? ] filter ]
        [ '[ [ _ at ] keep set ] each ]
        bi
    ] [ drop ] if* ;

M: conversations modify-form ( conversations -- xml/f )
    drop
    conversation-id get
    conversation-id-key
    hidden-form-field ;
