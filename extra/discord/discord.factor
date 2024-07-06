! Copyright (C) 2023 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.syntax arrays assocs byte-arrays calendar
combinators combinators.short-circuit concurrency.mailboxes
continuations destructors formatting hashtables help http
http.client http.websockets io io.encodings.string
io.encodings.utf8 io.streams.string json kernel math multiline
namespaces prettyprint prettyprint.sections random sequences
sets splitting strings threads tools.hexdump unicode vocabs
words ;
IN: discord

CONSTANT: discord-api-url "https://discord.com/api/v10"
CONSTANT: discord-bot-gateway  "wss://gateway.discord.gg/gateway/bot?v=10&encoding=json"

TUPLE: discord-webhook url id token ;

TUPLE: discord-bot-config
    client-id client-secret
    token application-id guild-id channel-id
    permissions intents
    user-callback obey-names
    metadata
    discord-bot mailbox connect-thread ;

TUPLE: discord-bot < disposable
    config in out bot-thread heartbeat-thread
    send-heartbeat? reconnect? stop?
    sequence-number
    messages last-message
    application user session_id resume_gateway_url
    guilds channels ;

: <discord-bot> ( in out config -- discord-bot )
    discord-bot new-disposable
        swap >>config
        swap >>out
        swap >>in
        t >>send-heartbeat?
        t >>reconnect?
        f >>stop?
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
: discord-patch-request ( payload route -- request )
    >discord-url <patch-request> add-discord-auth-header ;
: discord-delete-request ( route -- request )
    >discord-url <delete-request> add-discord-auth-header ;
: discord-post ( payload route -- json )
    discord-post-request json-request ;
: discord-post-json ( payload route -- json )
    [ >json ] dip discord-post-request add-json-header json-request ;
: discord-post-json-no-resp ( payload route -- )
    [ >json ] dip discord-post-request add-json-header http-request 2drop ;
: discord-patch-json ( payload route -- json )
    [ >json ] dip discord-patch-request add-json-header json-request ;
: discord-delete-json ( route -- json )
    discord-delete-request add-json-header json-request ;

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

: set-discord-application-commands ( json application-id -- json )
    "/applications/%s/commands" sprintf discord-post-json ;
: set-discord-application-guild-commands ( json application-id guild-id -- json )
    "/applications/%s/guilds/%s/commands" sprintf discord-post-json ;

: delete-discord-application-command ( application-id -- json )
    "/applications/%s/commands" sprintf discord-delete-json ;
: delete-discord-application-guild-command ( application-id -- json )
    "/applications/%s/commands" sprintf discord-delete-json ;

: create-interaction-response ( json interaction-id interaction-token -- )
    "/interactions/%s/%s/callback" sprintf discord-post-json-no-resp ;
: get-original-interaction-response ( application-id interaction-token -- json )
    "/webhooks/%s/%s/messages/@original" sprintf discord-get ;
: edit-interaction-response ( json application-id interaction-token -- json )
    "/webhooks/%s/%s/messages/@original" sprintf discord-patch-json ;


: send-message* ( string channel-id -- json )
    [ "content" associate ] dip "/channels/%s/messages" sprintf discord-post-json ;
: send-message ( string channel-id -- ) send-message* drop ;
: reply-message ( string -- ) discord-bot get last-message>> "channel_id" of send-message ;
: ghosting-payload ( -- string )
    { 124 124 8203 }
    197 [ { 124 124 124 124 8203 } ] replicate concat
    1 [ 124 ] replicate "" 3append-as ;

: ghost-ping ( message who channel-id -- )
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
    \ discord-bot get
    [ config>> ] ?call
    [ [ token>> ] ?call "0" or  ]
    [ [ intents>> ] ?call 3276541 or ] bi
    [[ {
        "op": 2,
        "d": {
            "token": "%s",
            "properties": {
                "os": "darwin",
                "browser": "discord.factor",
                "device": "discord.factor"
            },
            "large_threshold": 250,
            "intents": %d
        }
    }]] sprintf json> >json ;

: jitter-millis ( heartbeat-millis -- millis ) random-unit * >integer ;

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
                        output-stream get disposed>>
                        [ f ] [ send-heartbeat t ] if
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

SINGLETONS:
    AUTOMOD_ACTION AUTOMOD_RULE_CREATE AUTOMOD_RULE_DELETE AUTOMOD_RULE_UPDATE
    CHANNEL_CREATE CHANNEL_DELETE CHANNEL_PINS_UPDATE CHANNEL_UPDATE
    GUILD_AVAILABLE GUILD_BAN_ADD GUILD_BAN_REMOVE
    GUILD_CHANNEL_CREATE GUILD_CHANNEL_DELETE GUILD_CHANNEL_PINS_UPDATE GUILD_CHANNEL_UPDATE
    GUILD_CREATE GUILD_EMOJIS_UPDATE GUILD_INTEGRATION_UPDATE GUILD_JOIN
    GUILD_MEMBER_ADD GUILD_MEMBER_REMOVE GUILD_MEMBER_UPDATE GUILD_REMOVE
    GUILD_ROLE_CREATE GUILD_ROLE_DELETE GUILD_ROLE_UPDATE
    GUILD_STICKERS_UPDATE GUILD_UNAVAILABLE GUILD_UPDATE
    INTERACTION_CREATE
    INVITE_CREATE INVITE_DELETE
    MEMBER_BAN MEMBER_JOIN MEMBER_REMOVE MEMBER_UNBAN MEMBER_UPDATE
    MESSAGE_CREATE MESSAGE_DELETE MESSAGE_EDIT
    MESSAGE_REACTION_ADD MESSAGE_REACTION_REMOVE MESSAGE_UPDATE
    PRESENCE_UPDATE
    RAW_MESSAGE_DELETE RAW_MESSAGE_EDIT
    REACTION_ADD REACTION_CLEAR REACTION_REMOVE
    SCHEDULED_EVENT_CREATE SCHEDULED_EVENT_REMOVE SCHEDULED_EVENT_UPDATE
    SCHEDULED_EVENT_USER_ADD SCHEDULED_EVENT_USER_REMOVE
    SHARD_CONNECT SHARD_DISCONNECT
    SHARD_READY SHARD_RESUMED THREAD_CREATE
    THREAD_DELETE THREAD_JOIN
    THREAD_MEMBER_JOIN THREAD_MEMBER_REMOVE THREAD_UPDATE
    VOICE_SERVER_UPDATE VOICE_STATE_UPDATE
    READY TYPING_START USER_UPDATE WEBHOOKS_UPDATE ;

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
: obey-message? ( json -- ? )
    "author" of "username" of
    discord-bot get config>> obey-names>> [ in? ] [ drop f ] if* ;

: handle-incoming-message ( guild_id channel_id message_id author content -- )
    5drop ;

GENERIC: dispatch-message ( json singleton -- )
M: object dispatch-message "unhandled: " gwrite name>> gwrite g... ;
M: string dispatch-message "unhandled string: " gwrite gwrite g... ;

M: READY dispatch-message drop
    [ discord-bot get ] dip
    {
        [ "user" of >>user ]
        [ "session_id" of >>session_id ]
        [ "application" of >>application ]
        [ "resume_gateway_url" of >>resume_gateway_url ]
    } cleave drop ;

M: AUTOMOD_ACTION dispatch-message 2drop ;
M: AUTOMOD_RULE_CREATE dispatch-message 2drop ;
M: AUTOMOD_RULE_UPDATE dispatch-message 2drop ;
M: AUTOMOD_RULE_DELETE dispatch-message 2drop ;
M: CHANNEL_CREATE dispatch-message drop handle-channel-message ;
M: CHANNEL_UPDATE dispatch-message drop handle-channel-message ;
M: CHANNEL_DELETE dispatch-message drop handle-channel-message ;
M: CHANNEL_PINS_UPDATE dispatch-message 2drop ;
M: GUILD_CREATE dispatch-message drop handle-guild-message ;
M: GUILD_UPDATE dispatch-message drop handle-guild-message ;
M: GUILD_EMOJIS_UPDATE dispatch-message 2drop ;
M: GUILD_STICKERS_UPDATE dispatch-message 2drop ;
M: GUILD_INTEGRATION_UPDATE dispatch-message 2drop ;
M: GUILD_CHANNEL_CREATE dispatch-message 2drop ;
M: GUILD_CHANNEL_UPDATE dispatch-message 2drop ;
M: GUILD_CHANNEL_DELETE dispatch-message 2drop ;
M: GUILD_CHANNEL_PINS_UPDATE dispatch-message 2drop ;
M: GUILD_JOIN dispatch-message 2drop ;
M: GUILD_REMOVE dispatch-message 2drop ;
M: GUILD_AVAILABLE dispatch-message 2drop ;
M: GUILD_UNAVAILABLE dispatch-message 2drop ;
M: GUILD_MEMBER_ADD dispatch-message 2drop ;
M: GUILD_MEMBER_REMOVE dispatch-message 2drop ;
M: GUILD_MEMBER_UPDATE dispatch-message 2drop ;
M: GUILD_BAN_ADD dispatch-message 2drop ;
M: GUILD_BAN_REMOVE dispatch-message 2drop ;
M: GUILD_ROLE_CREATE dispatch-message 2drop ;
M: GUILD_ROLE_UPDATE dispatch-message 2drop ;
M: GUILD_ROLE_DELETE dispatch-message 2drop ;
M: INTERACTION_CREATE dispatch-message 2drop ;
M: INVITE_CREATE dispatch-message 2drop ;
M: INVITE_DELETE dispatch-message 2drop ;
M: MEMBER_BAN dispatch-message 2drop ;
M: MEMBER_UNBAN dispatch-message 2drop ;
M: MEMBER_JOIN dispatch-message 2drop ;
M: MEMBER_REMOVE dispatch-message 2drop ;
M: MEMBER_UPDATE dispatch-message 2drop ;
M: PRESENCE_UPDATE dispatch-message 2drop ;
M: RAW_MESSAGE_EDIT dispatch-message 2drop ;
M: RAW_MESSAGE_DELETE dispatch-message 2drop ;
M: REACTION_ADD dispatch-message 2drop ;
M: REACTION_REMOVE dispatch-message 2drop ;
M: REACTION_CLEAR dispatch-message 2drop ;
M: SCHEDULED_EVENT_CREATE dispatch-message 2drop ;
M: SCHEDULED_EVENT_REMOVE dispatch-message 2drop ;
M: SCHEDULED_EVENT_UPDATE dispatch-message 2drop ;
M: SCHEDULED_EVENT_USER_ADD dispatch-message 2drop ;
M: SCHEDULED_EVENT_USER_REMOVE dispatch-message 2drop ;
M: SHARD_CONNECT dispatch-message 2drop ;
M: SHARD_DISCONNECT dispatch-message 2drop ;
M: SHARD_READY dispatch-message 2drop ;
M: SHARD_RESUMED dispatch-message 2drop ;
M: THREAD_CREATE dispatch-message 2drop ;
M: THREAD_JOIN dispatch-message 2drop ;
M: THREAD_UPDATE dispatch-message 2drop ;
M: THREAD_DELETE dispatch-message 2drop ;
M: THREAD_MEMBER_JOIN dispatch-message 2drop ;
M: THREAD_MEMBER_REMOVE dispatch-message 2drop ;
M: USER_UPDATE dispatch-message 2drop ;
M: VOICE_STATE_UPDATE dispatch-message 2drop ;
M: VOICE_SERVER_UPDATE dispatch-message 2drop ;
M: WEBHOOKS_UPDATE dispatch-message 2drop ;

M: MESSAGE_CREATE dispatch-message drop
    [
        "MESSAGE_CREATE" write bl [
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
    ] with-global ;
M: MESSAGE_UPDATE dispatch-message drop
    [
        "MESSAGE_UPDATE" write bl {
            [ [ "guild_id" of ] [ "channel_id" of ] bi guild-channel-name write bl ]
            [ "id" of "id:" prepend write bl ]
            [ "author" of "username" of ":" append write bl ]
            [ "content" of "`" dup surround print flush ]
        } cleave
    ] with-global ;
M: MESSAGE_EDIT dispatch-message 2drop ;
M: MESSAGE_DELETE dispatch-message drop
    [
        "MESSAGE_DELETE" write bl {
            [ [ "guild_id" of ] [ "channel_id" of ] bi guild-channel-name write bl ]
            [ "id" of "id:" prepend print flush ]
        } cleave
    ] with-global ;
M: MESSAGE_REACTION_ADD dispatch-message 2drop ;
M: MESSAGE_REACTION_REMOVE dispatch-message 2drop ;
M: TYPING_START dispatch-message drop
    [
        "TYPING_START:" write bl
        [ [ "guild_id" of ] [ "channel_id" of ] bi guild-channel-name write bl ]
        [
            "member" of [ "nick" of json-null>f ] [ "user" of "username" of ] bi or
            " started typing" append print flush
        ] bi
    ] with-global ;

: handle-discord-RESUME ( json -- ) drop ;

: handle-discord-RECONNECT ( json -- ) drop ;

: handle-discord-HELLO ( json -- )
    "d" of "heartbeat_interval" of start-heartbeat-thread
    gateway-identify-json send-masked-message ;

: handle-discord-HEARTBEAT_ACK ( json -- ) drop ;

: parse-discord-op ( json -- )
    [
        clone now "timestamp" pick set-at discord-bot get
        [ messages>> push ] [ [ "d" of ] dip last-message<< ] 2bi
    ] keep
    [ ] [ "s" of discord-bot get sequence-number<< ] [ "op" of ] tri {
        { 0 [
            [ "d" of ] [ "t" of [ "discord" lookup-word ] transmute ] bi
            [ dispatch-message ]
            [
                discord-bot get config>> user-callback>>
                [ call( json message-type -- ) ] [ 2drop ] if*
            ] 2bi
        ] }
        { 6 [ handle-discord-RESUME ] }
        { 7 [ handle-discord-RECONNECT ] }
        { 10 [ handle-discord-HELLO ] }
        { 11 [ handle-discord-HEARTBEAT_ACK ] }
        [ "unknown opcode:" gwrite g. g... gflush ]
    } case ;

: stopping-discord-bot ( -- )
    discord-bot get t >>stop? drop ;

DEFER: discord-reconnect
: handle-discord-websocket ( obj opcode -- )
    "opcode: " gwrite dup g. over dup byte-array? [ utf8 decode json> ] when g... gflush
    {
        { f [
            [
                "closed with error, code %d" sprintf gprint-flush
                stopping-discord-bot
            ] [ "closed with f" gprint-flush ] if*
        ] }
        { 1 [
            [ drop ]
            [ utf8 decode json> parse-discord-op ] bi
        ] }
        { 2 [
            [ [ hexdump. flush ] with-global ] when*
        ] }
        { 8 [
            drop "close received" gprint-flush
        ] }
        { 9 [
            [ "ping received" gprint-flush send-heartbeat ] when*
        ] }
        [ 2drop ]
    } case ;

: discord-reconnect ( -- )
    "reconnect" g.
    discord-bot-gateway <get-request>
    add-discord-auth-header
    [ drop ] do-http-request
    dup response? [
        throw
    ] [
        [ in>> stream>> ] [ out>> stream>> ] bi \ discord-bot-config get
        <discord-bot>
        [ discord-bot-config get discord-bot<< ] keep
        dup '[
            _ \ discord-bot [
                discord-bot get [ in>> ] [ out>> ] bi
                [
                    [ handle-discord-websocket discord-bot-config get discord-bot>> stop?>> not ] read-websocket-loop
                ] with-streams
            ] with-variable
            discord-bot-config get mailbox>> "disconnected" swap mailbox-put
        ] "Discord Bot" spawn >>bot-thread discord-bot-config get discord-bot<<
    ] if ;

M: discord-bot dispose*
    f >>reconnect?
    t >>stop?
    f >>send-heartbeat?
    [
        [ in>> &dispose drop ]
        [ out>> &dispose drop ]
        [ f >>in f >>out drop ] tri
    ] with-destructors ;

M: discord-bot-config dispose
    discord-bot>> dispose ;

: discord-connect ( config -- )
    <mailbox> >>mailbox
    \ discord-bot-config [
        [
            [
                "connecting" g.
                discord-reconnect
                discord-bot-config get
                ! wait here for signal to maybe reconnect
                [ mailbox>> mailbox-get ] [ discord-bot>> ] bi
                [ reconnect?>> ] [ stop?>> not ] bi and
            ] loop
        ] "Discord bot connect loop" spawn discord-bot-config get connect-thread<<
    ] with-variable ;

: reply-command ( json -- ? )
    "content" of [ blank? ] trim
    " " split1 [ [ blank? ] trim ] bi@
    swap {
        { "help" [
            ":" split1 swap lookup-word dup [
                [ [ print-topic ] with-string-writer ]
                [ 2drop f ] recover
            ] when "vocab:word not found (maybe it's not loaded)" or
            reply-message t
        ] }
        { "effects" [
            all-words swap '[ name>> _ = ] filter
            [
                [ vocabulary-name ]
                [ name>> ":" glue ]
                [ props>> "declared-effect" of unparse " " glue ] tri
            ] map
            [ "no words found" reply-message f ]
            [ "\n" join reply-message t ] if-empty
        ] }
        [ 2drop f ]
    } case ;

: reply-echo ( json -- ? )
    dup message-mentions-me-and-not-from-me?
    [ "content" of "echobot sez: " prepend reply-message t ]
    [ drop f ] if ;

GENERIC: discord-help-bot ( json opcode -- )

M: object discord-help-bot 2drop ;

M: MESSAGE_CREATE discord-help-bot drop
    '[ _ { [ reply-command ] [ reply-echo ] } 1|| drop ]
    [ g... gflush ] recover ;
