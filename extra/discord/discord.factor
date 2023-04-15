! Copyright (C) 2023 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.syntax arrays assocs byte-arrays calendar
combinators combinators.short-circuit continuations destructors
formatting hashtables help http http.client http.websockets io
io.encodings.string io.encodings.utf8 io.streams.string json
kernel math multiline namespaces prettyprint
prettyprint.sections random sequences splitting threads
tools.hexdump unicode vocabs words ;
IN: discord

CONSTANT: discord-api-url "https://discord.com/api/v10"
CONSTANT: discord-bot-gateway  "wss://gateway.discord.gg/gateway/bot?v=10&encoding=json"

TUPLE: discord-webhook url id token ;

TUPLE: discord-bot-config
    client-id client-secret
    token application-id guild-id channel-id permissions
    user-callback ;

TUPLE: discord-bot
    config in out bot-thread heartbeat-thread
    send-heartbeat? reconnect?
    messages sequence-number
    application user session_id resume_gateway_url
    guilds channels ;

: <discord-bot> ( in out config -- discord-bot )
    discord-bot new
        swap >>config
        swap >>out
        swap >>in
        t >>send-heartbeat?
        t >>reconnect?
        V{ } clone >>messages
        H{ } clone >>guilds
        H{ } clone >>channels ;

: add-discord-auth-header ( request -- request )
    discord-bot-config get token>> "Bot " prepend "Authorization" set-header ;

: add-json-header ( request -- request )
    "application/json" "Content-Type" set-header ;

: json-request ( request -- json ) http-request nip utf8 decode json> ;
: gwrite ( string -- ) [ write ] with-global ;
: gprint ( string -- ) [ print ] with-global ;
: gprint-flush ( string -- ) [ print flush ] with-global ;
: gflush ( -- ) [ flush ] with-global ;
: gbl ( -- ) [ bl ] with-global ;
: gnl ( -- ) [ nl ] with-global ;
: g. ( object -- ) [ . ] with-global ;
: g... ( object -- ) [ ... ] with-global ;

: >discord-url ( route -- url ) discord-api-url prepend ;
: discord-get-request ( route -- request )
    >discord-url <get-request> add-discord-auth-header ;
: discord-get ( route -- json )
    discord-get-request json-request ;
: discord-post-request ( payload route -- request )
    >discord-url <post-request> add-discord-auth-header ;
: discord-post ( payload route -- json )
    discord-post-request json-request ;
: discord-post-json ( payload route -- json )
    [ >json ] dip discord-post-request add-json-header json-request ;

: bot-guild-join-uri ( discord-bot-config -- uri )
    [ permissions>> ] [ client-id>> ] [ guild-id>> ] tri
    "https://discord.com/oauth2/authorize?scope=bot&permissions=%d&client_id=%s&guild_id=%s" sprintf ;

: get-discord-user ( user -- json ) "/users/%s" sprintf discord-get ;
: get-discord-users-me ( -- json ) "/users/@me" discord-get ;
: get-discord-users-guilds ( -- json ) "/users/@me/guilds" discord-get ;
: get-discord-users-guild-member ( guild-id -- json ) "/users/@me/guilds/%s/member" sprintf discord-get ;
: get-discord-user-connections ( -- json ) "/users/@me/connections" discord-get ;
: get-discord-user-application-role-connection ( application-id -- json )
    "/users/@me/applications/%s/role-connection" sprintf discord-get ;
: get-discord-channel ( channel-id -- json ) "/channels/%s" sprintf discord-get ;
: get-discord-channel-pins ( channel-id -- json ) "/channels/%s/pins" sprintf discord-get ;
: get-discord-channel-messages ( channel-id -- json ) "/channels/%s/messages" sprintf discord-get ;
: get-discord-channel-message ( channel-id message-id -- json ) "/channels/%s/messages/%s" sprintf discord-get ;
: send-message ( string channel-id -- json )
    [ "content" associate ] dip "/channels/%s/messages" sprintf discord-post-json ;
: ghosting-payload ( -- string )
    { 124 124 8203 }
    197 [ { 124 124 124 124 8203 } ] replicate concat
    1 [ 124 ] replicate "" 3append-as ;

: ghost-ping ( message who channel-id -- json )
    [ ghosting-payload glue ] dip send-message ;

: get-channel-webhooks ( channel-id -- json ) "/channels/%s/webhooks" sprintf discord-get ;
: get-guild-webhooks ( guild-id -- json ) "/guilds/%s/webhooks" sprintf discord-get ;
: get-webhook ( webhook-id -- json ) "/webhooks/%s" sprintf discord-get ;

: get-guilds-me ( -- json ) "/users/@me/guilds" discord-get ;
: get-guild-active-threads ( channel-id -- json ) "/guilds/%s/threads/active" sprintf discord-get ;
: get-application-info ( -- json ) "/oauth2/applications/@me" discord-get ;

: get-discord-gateway ( -- json ) "/gateway" discord-get ;
: get-discord-bot-gateway ( -- json ) "/gateway/bot" discord-get ;

: gateway-identify-json ( -- json )
    \ discord-bot get config>> token>> [[ {
        "op": 2,
        "d": {
            "token": "%s",
            "properties": {
                "os": "darwin",
                "browser": "discord.factor",
                "device": "discord.factor"
            },
            "large_threshold": 250,
            "intents": 3276541
        }
    }]] sprintf json> >json ;

: jitter-millis ( heartbeat-millis -- millis ) 0 1 uniform-random-float * >integer ;

: send-heartbeat ( seq/f -- )
    json-null or "d" associate H{ { "op" 1 } } assoc-union!
    >json send-masked-message ;

: start-heartbeat-thread ( millis -- )
    '[
        _
        [ jitter-millis sleep f send-heartbeat ]
        [
            milliseconds
            '[
                _ sleep discord-bot get
                [ send-heartbeat?>> ] [ sequence-number>> ] bi
                '[
                    _ [
                        output-stream get disposed>> [
                            "heartbeat thread: output-stream is disposed, stopping" gprint-flush f
                        ] [
                            send-heartbeat t
                            "sent heartbeat" gprint-flush
                        ] if
                    ] [ 2drop f ] recover
                ] [ f ] if
            ] loop
        ] bi
    ] "discord-bot-heartbeat" spawn discord-bot get heartbeat-thread<< ;

ENUM: discord-opcode
    { DISPATCH           0 }
    { HEARTBEAT          1 }
    { IDENTIFY           2 }
    { PRESENCE           3 }
    { VOICE_STATE        4 }
    { VOICE_PING         5 }
    { RESUME             6 }
    { RECONNECT          7 }
    { REQUEST_MEMBERS    8 }
    { INVALIDATE_SESSION 9 }
    { HELLO              10 }
    { HEARTBEAT_ACK      11 }
    { GUILD_SYNC         12 } ;

: guild-name ( guild-id -- name ) discord-bot get guilds>> at "name" of ;
: channel-name ( guild-id channel-id -- name ) 2array discord-bot get channels>> at "name" of ;
: guild-channel-name ( guild-id channel-id -- name )
    [ ":" glue print ]
    [ drop guild-name "`" dup surround ]
    [ channel-name "`" dup surround ] 2tri ":" glue ;

: handle-channel-message ( json -- )
    {
        [ "guild_id" of "guild_id:" prepend write bl ]
        [ "id" of "channel_id:" prepend write bl ]
        [ [ "guild_id" of ] [ "id" of ] bi guild-channel-name write bl ]
        [ "name" of "name:`" "`" surround write bl ]
        [ "rate_limit_per_user" of "rate_limit_per_user:%d" sprintf write bl ]
        [ "default_auto_archive_duration" of -1 or "default_auto_archive_duration:%d minutes" sprintf write bl ]
        [ "nsfw" of unparse "nsfw:%s" sprintf write bl ]
        [ "position" of unparse "position:%s" sprintf write bl ]
        [ "topic" of json-null>f "topic:`" "`" surround print flush ]
    } cleave ;

: handle-guild-message ( json -- )
    {
        [ dup "id" of discord-bot get guilds>> set-at ]
        [
            [ "id" of ] [ "channels" of ] bi
            discord-bot get channels>> '[ tuck "id" of 2array _ set-at ] with each
        ]
    } cleave ;

: my-user-id ( -- id ) discord-bot get user>> "id" of ;
: message-from-me? ( json -- ? ) "author" of "id" of my-user-id = ;
: message-mentions ( json -- ids ) "mentions" of ;
: message-mentions-ids ( json -- ids ) message-mentions [ "id" of ] map ;
: message-mentions-me? ( json -- ? ) message-mentions my-user-id '[ "id" of _ = ] any? ;
: message-mentions-me-and-not-from-me? ( json -- ? )
    { [ message-mentions-me? ] [ message-from-me? not ] } 1&& ;
: message-channel-id ( json -- ids ) "channel_id" of ;

: handle-incoming-message ( guild_id channel_id message_id author content -- )
    5drop ;

: handle-discord-DISPATCH ( json -- )
    dup "t" of {
        { "READY" [
            "READY" gprint-flush
            discord-bot get swap
            "d" of
            {
                [ "user" of >>user ]
                [ "session_id" of >>session_id ]
                [ "application" of >>application ]
                [ "resume_gateway_url" of >>resume_gateway_url ]
            } cleave drop
        ] }

        { "AUTOMOD_ACTION" [ drop ] }
        { "AUTOMOD_RULE_CREATE" [ drop ] }
        { "AUTOMOD_RULE_UPDATE" [ drop ] }
        { "AUTOMOD_RULE_DELETE" [ drop ] }

        { "CHANNEL_CREATE" [
            [
                "CHANNEL_CREATE:" write bl
                "d" of handle-channel-message
            ] with-global
        ] }
        { "CHANNEL_UPDATE" [
            [
                "CHANNEL_UPDATE:" write bl
                "d" of handle-channel-message
            ] with-global
        ] }
        { "CHANNEL_DELETE" [
            [
                "CHANNEL_DELETE:" write bl
                "d" of handle-channel-message
            ] with-global
        ] }
        { "CHANNEL_PINS_UPDATE" [
            [
                "CHANNEL_PINS_UPDATE:" write bl
                "d" of {
                    [ [ "guild_id" of ] [ "channel_id" of ] bi guild-channel-name write bl ]
                    [ "last_pin_timestamp" of "last_pin_timestamp:`" "`" surround print flush ]
                } cleave
            ] with-global
        ] }

        { "GUILD_CREATE" [
            [
                "GUILD_CREATE:" print flush
                "d" of handle-guild-message
            ] with-global
        ] }
        { "GUILD_UPDATE" [
            [
                "GUILD_UPDATE:" print flush
                "d" of handle-guild-message
            ] with-global
        ] }
        { "GUILD_EMOJIS_UPDATE" [ drop ] }
        { "GUILD_STICKERS_UPDATE" [ drop ] }
        { "GUILD_INTEGRATION_UPDATE" [ drop ] }
        { "GUILD_CHANNEL_CREATE" [ drop ] }
        { "GUILD_CHANNEL_UPDATE" [ drop ] }
        { "GUILD_CHANNEL_DELETE" [ drop ] }
        { "GUILD_CHANNEL_PINS_UPDATE" [ drop ] }
        { "GUILD_JOIN" [ drop ] }
        { "GUILD_REMOVE" [ drop ] }
        { "GUILD_AVAILABLE" [ drop ] }
        { "GUILD_UNAVAILABLE" [ drop ] }
        { "GUILD_MEMBER_ADD" [ drop ] }
        { "GUILD_MEMBER_REMOVE" [ drop ] }
        { "GUILD_MEMBER_UPDATE" [ drop ] }
        { "GUILD_BAN_ADD" [ drop ] }
        { "GUILD_BAN_REMOVE" [ drop ] }
        { "GUILD_ROLE_CREATE" [ drop ] }
        { "GUILD_ROLE_UPDATE" [ drop ] }
        { "GUILD_ROLE_DELETE" [ drop ] }

        { "INVITE_CREATE" [ drop ] }
        { "INVITE_DELETE" [ drop ] }

        { "MESSAGE_CREATE" [
            [
                "MESSAGE_CREATE" write bl
                "d" of [
                    {
                        [ [ "guild_id" of ] [ "channel_id" of ] bi guild-channel-name write bl ]
                        [ "id" of "id:" prepend write bl ]
                        [ "author" of "username" of ":" append write bl ]
                        [ "content" of "`" dup surround print flush ]
                    } cleave
                ] [
                    {
                        [ [ "guild_id" of ] [ "channel_id" of ] bi ]
                        [ "id" of ]
                        [ "author" of "username" of ]
                        [ "content" of ]
                    } cleave handle-incoming-message
                ] bi
            ] with-global
        ] }
        { "MESSAGE_UPDATE" [
            [
                "MESSAGE_UPDATE" write bl
                "d" of
                {
                    [ [ "guild_id" of ] [ "channel_id" of ] bi guild-channel-name write bl ]
                    [ "id" of "id:" prepend write bl ]
                    [ "author" of "username" of ":" append write bl ]
                    [ "content" of "`" dup surround print flush ]
                } cleave
            ] with-global
        ] }
        { "MESSAGE_EDIT" [ drop ] }
        { "MESSAGE_DELETE" [
            [
                "MESSAGE_DELETE" write bl
                "d" of {
                    [ [ "guild_id" of ] [ "channel_id" of ] bi guild-channel-name write bl ]
                    [ "id" of "id:" prepend print flush ]
                } cleave
            ] with-global
        ] }

        { "MESSAGE_REACTION_ADD" [
            [
                "MESSAGE_REACTION_ADD" write ...
            ] with-global
         ] }
        { "MESSAGE_REACTION_REMOVE" [
            [
                "MESSAGE_REACTION_REMOVE" write ...
            ] with-global
        ] }

        { "MEMBER_BAN" [ drop ] }
        { "MEMBER_UNBAN" [ drop ] }
        { "MEMBER_JOIN" [ drop ] }
        { "MEMBER_REMOVE" [ drop ] }
        { "MEMBER_UPDATE" [ drop ] }

        { "PRESENCE_UPDATE" [ drop ] }

        { "RAW_MESSAGE_EDIT" [ drop ] }
        { "RAW_MESSAGE_DELETE" [ drop ] }

        { "REACTION_ADD" [ drop ] }
        { "REACTION_REMOVE" [ drop ] }
        { "REACTION_CLEAR" [ drop ] }

        { "SCHEDULED_EVENT_CREATE" [ drop ] }
        { "SCHEDULED_EVENT_REMOVE" [ drop ] }
        { "SCHEDULED_EVENT_UPDATE" [ drop ] }
        { "SCHEDULED_EVENT_USER_ADD" [ drop ] }
        { "SCHEDULED_EVENT_USER_REMOVE" [ drop ] }

        { "SHARD_CONNECT" [ drop ] }
        { "SHARD_DISCONNECT" [ drop ] }
        { "SHARD_READY" [ drop ] }
        { "SHARD_RESUMED" [ drop ] }

        { "THREAD_CREATE" [ drop ] }
        { "THREAD_JOIN" [ drop ] }
        { "THREAD_UPDATE" [ drop ] }
        { "THREAD_DELETE" [ drop ] }

        { "THREAD_MEMBER_JOIN" [ drop ] }
        { "THREAD_MEMBER_REMOVE" [ drop ] }

        { "TYPING_START" [
            [
                "TYPING_START:" write bl
                "d" of
                [ [ "guild_id" of ] [ "channel_id" of ] bi guild-channel-name write bl ]
                [
                    "member" of [ "nick" of json-null>f ] [ "user" of "username" of ] bi or
                    " started typing" append print flush
                ] bi
            ] with-global
        ] }

        { "USER_UPDATE" [ drop ] }
        { "VOICE_STATE_UPDATE" [ drop ] }
        { "VOICE_SERVER_UPDATE" [ drop ] }
        { "WEBHOOKS_UPDATE" [ drop ] }
        [
            [
                write " UHNANDLED" write ... flush
            ] with-global
        ]
    } case ;

: handle-discord-RESUME ( json -- ) drop ;

: handle-discord-RECONNECT ( json -- ) drop ;

: handle-discord-HELLO ( json -- )
    "d" of "heartbeat_interval" of start-heartbeat-thread
    gateway-identify-json send-masked-message ;

: handle-discord-HEARTBEAT_ACK ( json -- ) drop ;

: parse-discord-op ( json -- )
    [ clone now "timestamp" pick set-at discord-bot get messages>> push ] keep
    [ ] [ "s" of discord-bot get sequence-number<< ] [ "op" of ] tri {
        { 0 [
            [ handle-discord-DISPATCH ]
            [
                [ discord-bot get ] dip over config>> user-callback>>
                [ [ dup "t" of ] dip call( discord-bot json message-type -- ) ] [ 2drop ] if*
            ] bi
        ] }
        { 6 [ handle-discord-RESUME ] }
        { 7 [ handle-discord-RECONNECT ] }
        { 10 [ handle-discord-HELLO ] }
        { 11 [ handle-discord-HEARTBEAT_ACK ] }
        [
            [
                "unknown opcode:" write .
                ... flush
            ] with-global
        ]
    } case ;

DEFER: discord-reconnect
: handle-discord-websocket ( obj opcode -- loop? )
    [ "opcode: " write dup . over dup byte-array? [ utf8 decode json> ] when ... flush ] with-global
    {
        { f [
            [
                [ "closed with error, code %d" sprintf print ]
                [ "closed with f" print ] if* flush
            ] with-global
            discord-bot get reconnect?>> [
                discord-reconnect drop
            ] when f ! don't loop this one, reconnect makes a new thread
        ] }
        { 1 [
            [ drop ]
            [ utf8 decode json> parse-discord-op ] bi
            t
        ] }
        { 2 [
            [ [ hexdump. flush ] with-global ] when* t
        ] }
        { 8 [
            [ drop "close received" print flush ] with-global
            discord-bot get reconnect?>> [ discord-reconnect drop ] when f
        ] }
        { 9 [
            [ "ping received" gprint-flush send-heartbeat ] when* t
        ] }
        [ 2drop t ]
    } case ;

: discord-reconnect ( -- discord-bot )
    discord-bot-gateway <get-request>
    add-discord-auth-header
    [ drop ] do-http-request
    dup response? [
        throw
    ] [
        [ in>> stream>> ] [ out>> stream>> ] bi
        \ discord-bot-config get <discord-bot>
        dup '[
            _ \ discord-bot [
                discord-bot get [ in>> ] [ out>> ] bi
                [
                    [ handle-discord-websocket ] read-websocket-loop
                ] with-streams
            ] with-variable
        ] "Discord Bot" spawn
        >>bot-thread
    ] if ;

M: discord-bot dispose
    f >>reconnect?
    f >>send-heartbeat?
    [
        [ in>> &dispose drop ]
        [ out>> &dispose drop ]
        [ f >>in f >>out drop ] tri
    ] with-destructors ;

: discord-connect ( config -- discord-bot )
    \ discord-bot-config [ discord-reconnect ] with-variable ;

: reply-command ( json -- ? )
    dup "content" of [ blank? ] trim
    " " split1 [ [ blank? ] trim ] bi@
    swap {
        { "help" [
            ":" split1 swap lookup-word dup [
                [ [ print-topic ] with-string-writer ]
                [ 2drop f ] recover
            ] when "vocab:word not found (maybe it's not loaded)" or
            swap message-channel-id send-message drop t
        ] }
        { "effects" [
            all-words swap '[ name>> _ = ] filter
            [
                [ vocabulary-name ]
                [ name>> ":" glue ]
                [ props>> "declared-effect" of unparse " " glue ] tri
            ] map [
                "no words found" swap message-channel-id send-message drop f
            ] [
                "\n" join swap message-channel-id send-message drop t
            ] if-empty
        ] }
        [ 3drop f ]
    } case ;

: reply-echo ( json -- ? )
    dup message-mentions-me-and-not-from-me? [
        [ "content" of "echobot sez: " prepend ]
        [ message-channel-id ] bi send-message drop t
    ] [
        drop f
    ] if ;

: discord-help-bot-handler ( discord-bot json opcode -- )
    [ "d" of ] dip {
        { "MESSAGE_CREATE" [
            nip { [ reply-command ] [ reply-echo ] } 1|| drop
        ] }
        [ 3drop ]
    } case ;