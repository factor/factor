! Copyright (C) 2023 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.syntax assocs calendar combinators
formatting hashtables http http.client http.client.private
http.websockets io io.encodings.string io.encodings.utf8 json
kernel math multiline namespaces prettyprint random sequences
threads tools.hexdump ;
IN: discord

CONSTANT: discord-api-url "https://discord.com/api/v10"
CONSTANT: discord-bot-gateway  "https://gateway.discord.gg/gateway/bot?v=10&encoding=json"

TUPLE: discord-webhook url id token ;

TUPLE: discord-bot-config
    client-id client-secret
    token application-id guild-id channel-id permissions ;

TUPLE: discord-bot
    config in out ui-stdout bot-thread heartbeat-thread
    send-heartbeat? messages sequence-number
    name application guilds user session_id resume_gateway_url ;

: <discord-bot> ( in out config -- discord-bot )
    discord-bot new
        swap >>config
        swap >>out
        swap >>in
        t >>send-heartbeat?
        V{ } clone >>messages ;

: add-discord-auth-header ( request -- request )
    discord-bot-config get token>> "Bot " prepend "Authorization" set-header ;

: add-json-header ( request -- request )
    "application/json" "Content-Type" set-header ;

: json-request ( request -- json ) http-request nip utf8 decode json> ;

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
                '[ _ send-heartbeat t ] [ f ] if
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

: handle-discord-DISPATCH ( json -- )
    dup "t" of {
        { "AUTOMOD_ACTION" [ drop ] }
        { "AUTOMOD_RULE_CREATE" [ drop ] }
        { "AUTOMOD_RULE_UPDATE" [ drop ] }
        { "AUTOMOD_RULE_DELETE" [ drop ] }
        
        { "CHANNEL_CREATE" [ drop ] }
        { "CHANNEL_UPDATE" [ drop ] }
        { "CHANNEL_DELETE" [ drop ] }
        { "CHANNEL_PINS_UPDATE" [ drop ] }

        { "GUILD_CREATE" [ drop ] }
        { "GUILD_UPDATE" [ drop ] }
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

        { "READY" [
            discord-bot get swap
            {
                [ "user" of >>user ]
                [ "session_id" of >>session_id ]
                [ "application" of >>application ]
                [ "guilds" of >>guilds ]
                [ "resume_gateway_url" of >>resume_gateway_url ]
            } cleave drop
        ] }

        { "MESSAGE_CREATE" [ drop ] }
        { "MESSAGE_UPDATE" [ drop ] }
        { "MESSAGE_EDIT" [ drop ] }
        { "MESSAGE_DELETE" [ drop ] }

        { "MESSAGE_REACTION_ADD" [ drop ] }
        { "MESSAGE_REACTION_REMOVE" [ drop ] }

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

        { "TYPING_START" [ drop ] }

        { "USER_UPDATE" [ drop ] }
        { "VOICE_STATE_UPDATE" [ drop ] }
        { "VOICE_SERVER_UPDATE" [ drop ] }
        { "WEBHOOKS_UPDATE" [ drop ] }        
        [ 2drop ]
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
        { 0 [ handle-discord-DISPATCH ] }
        { 6 [ handle-discord-RESUME ] }
        { 7 [ handle-discord-RECONNECT ] }
        { 10 [ handle-discord-HELLO ] }
        { 11 [ handle-discord-HEARTBEAT_ACK ] }
        [ 2drop ]
    } case ;

: handle-discord-websocket ( obj opcode -- loop? )
    {
        { f [ [ "closed with error, code %d" sprintf . flush ] with-global f ] }
        { 1 [
            [ [ hexdump. flush ] with-global ]
            [ utf8 decode json> parse-discord-op ] bi
            t
        ] }
        { 2 [ [ [ hexdump. flush ] with-global ] when* t ] }
        { 8 [ [ drop "close received" print flush ] with-global t ] }
        { 9 [ [ [ "ping received" print flush ] with-global send-heartbeat ] when* t ] }
        [ 2drop t ]
    } case ;

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
: send-discord-message ( hashtable channel-id -- json ) "/channels/%s/messages" sprintf discord-post-json ;

: get-channel-webhooks ( channel-id -- json ) "/channels/%s/webhooks" sprintf discord-get ;
: get-guild-webhooks ( guild-id -- json ) "/guilds/%s/webhooks" sprintf discord-get ;
: get-webhook ( webhook-id -- json ) "/webhooks/%s" sprintf discord-get ;

: get-guilds-me ( -- json ) "/users/@me/guilds" discord-get ;
: get-guild-active-threads ( channel-id -- json ) "/guilds/%s/threads/active" sprintf discord-get ;
: get-application-info ( -- json ) "/oauth2/applications/@me" discord-get ;

: get-discord-gateway ( -- json ) "/gateway" discord-get ;
: get-discord-bot-gateway ( -- json ) "/gateway/bot" discord-get ;

: discord-connect ( config -- discord-bot )
    \ discord-bot-config [
        discord-bot-gateway <get-request>
        add-websocket-upgrade-headers
        add-discord-auth-header
        [ drop ] do-http-request
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
    ] with-variable ;
