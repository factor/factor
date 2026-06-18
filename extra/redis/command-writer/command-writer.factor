! Copyright (C) 2009 Bruno Deferrari
! See https://factorcode.org/license.txt for BSD license.
! Command words generated from the Redis 8.8.0 command spec
! (redis/src/commands/*.json). Each word takes a sequence of arguments
! and writes the command to the current (binary) output stream as a RESP
! array of bulk strings. See write-command.
USING: byte-arrays combinators formatting io io.encodings.string
io.encodings.utf8 kernel math math.parser sequences ;
IN: redis.command-writer

<PRIVATE

CONSTANT: crlf B{ 13 10 }

: arg>bytes ( obj -- byte-array )
    {
        { [ dup byte-array? ] [ ] }
        { [ dup number? ] [ number>string utf8 encode ] }
        [ utf8 encode ]
    } cond ;

: write-bulk ( bytes -- )
    [ length "$%d\r\n" sprintf utf8 encode write ] [ write ] bi
    crlf write ;

: write-count ( n -- )
    "*%d\r\n" sprintf utf8 encode write ;

PRIVATE>

! Write command tokens followed by args as one RESP array of bulk
! strings, each length-prefixed by its UTF-8 byte count. Numbers are
! sent as their decimal string form; byte-arrays are sent verbatim.
: write-command ( args command -- )
    swap
    2dup [ length ] bi@ + write-count
    [ [ arg>bytes write-bulk ] each ] bi@ ;

! ===== array =====
: arcount     ( args -- ) { "ARCOUNT" } write-command ;
: ardel       ( args -- ) { "ARDEL" } write-command ;
: ardelrange  ( args -- ) { "ARDELRANGE" } write-command ;
: arget       ( args -- ) { "ARGET" } write-command ;
: argetrange  ( args -- ) { "ARGETRANGE" } write-command ;
: argrep      ( args -- ) { "ARGREP" } write-command ;
: arinfo      ( args -- ) { "ARINFO" } write-command ;
: arinsert    ( args -- ) { "ARINSERT" } write-command ;
: arlastitems ( args -- ) { "ARLASTITEMS" } write-command ;
: arlen       ( args -- ) { "ARLEN" } write-command ;
: armget      ( args -- ) { "ARMGET" } write-command ;
: armset      ( args -- ) { "ARMSET" } write-command ;
: arnext      ( args -- ) { "ARNEXT" } write-command ;
: arop        ( args -- ) { "AROP" } write-command ;
: arring      ( args -- ) { "ARRING" } write-command ;
: arscan      ( args -- ) { "ARSCAN" } write-command ;
: arseek      ( args -- ) { "ARSEEK" } write-command ;
: arset       ( args -- ) { "ARSET" } write-command ;

! ===== bitmap =====
: bitcount    ( args -- ) { "BITCOUNT" } write-command ;
: bitfield    ( args -- ) { "BITFIELD" } write-command ;
: bitfield_ro ( args -- ) { "BITFIELD_RO" } write-command ;
: bitop       ( args -- ) { "BITOP" } write-command ;
: bitpos      ( args -- ) { "BITPOS" } write-command ;
: getbit      ( args -- ) { "GETBIT" } write-command ;
: setbit      ( args -- ) { "SETBIT" } write-command ;

! ===== cluster =====
: asking                        ( args -- ) { "ASKING" } write-command ;
: cluster                       ( args -- ) { "CLUSTER" } write-command ;
: cluster-addslots              ( args -- ) { "CLUSTER" "ADDSLOTS" } write-command ;
: cluster-addslotsrange         ( args -- ) { "CLUSTER" "ADDSLOTSRANGE" } write-command ;
: cluster-bumpepoch             ( args -- ) { "CLUSTER" "BUMPEPOCH" } write-command ;
: cluster-count-failure-reports ( args -- ) { "CLUSTER" "COUNT-FAILURE-REPORTS" } write-command ;
: cluster-countkeysinslot       ( args -- ) { "CLUSTER" "COUNTKEYSINSLOT" } write-command ;
: cluster-delslots              ( args -- ) { "CLUSTER" "DELSLOTS" } write-command ;
: cluster-delslotsrange         ( args -- ) { "CLUSTER" "DELSLOTSRANGE" } write-command ;
: cluster-failover              ( args -- ) { "CLUSTER" "FAILOVER" } write-command ;
: cluster-flushslots            ( args -- ) { "CLUSTER" "FLUSHSLOTS" } write-command ;
: cluster-forget                ( args -- ) { "CLUSTER" "FORGET" } write-command ;
: cluster-getkeysinslot         ( args -- ) { "CLUSTER" "GETKEYSINSLOT" } write-command ;
: cluster-help                  ( args -- ) { "CLUSTER" "HELP" } write-command ;
: cluster-info                  ( args -- ) { "CLUSTER" "INFO" } write-command ;
: cluster-keyslot               ( args -- ) { "CLUSTER" "KEYSLOT" } write-command ;
: cluster-links                 ( args -- ) { "CLUSTER" "LINKS" } write-command ;
: cluster-meet                  ( args -- ) { "CLUSTER" "MEET" } write-command ;
: cluster-migration             ( args -- ) { "CLUSTER" "MIGRATION" } write-command ;
: cluster-myid                  ( args -- ) { "CLUSTER" "MYID" } write-command ;
: cluster-myshardid             ( args -- ) { "CLUSTER" "MYSHARDID" } write-command ;
: cluster-nodes                 ( args -- ) { "CLUSTER" "NODES" } write-command ;
: cluster-replicas              ( args -- ) { "CLUSTER" "REPLICAS" } write-command ;
: cluster-replicate             ( args -- ) { "CLUSTER" "REPLICATE" } write-command ;
: cluster-reset                 ( args -- ) { "CLUSTER" "RESET" } write-command ;
: cluster-saveconfig            ( args -- ) { "CLUSTER" "SAVECONFIG" } write-command ;
: cluster-set-config-epoch      ( args -- ) { "CLUSTER" "SET-CONFIG-EPOCH" } write-command ;
: cluster-setslot               ( args -- ) { "CLUSTER" "SETSLOT" } write-command ;
: cluster-shards                ( args -- ) { "CLUSTER" "SHARDS" } write-command ;
: cluster-slaves                ( args -- ) { "CLUSTER" "SLAVES" } write-command ;
: cluster-slot-stats            ( args -- ) { "CLUSTER" "SLOT-STATS" } write-command ;
: cluster-slots                 ( args -- ) { "CLUSTER" "SLOTS" } write-command ;
: cluster-syncslots             ( args -- ) { "CLUSTER" "SYNCSLOTS" } write-command ;
: readonly                      ( args -- ) { "READONLY" } write-command ;
: readwrite                     ( args -- ) { "READWRITE" } write-command ;

! ===== connection =====
: auth                ( args -- ) { "AUTH" } write-command ;
: client              ( args -- ) { "CLIENT" } write-command ;
: client-caching      ( args -- ) { "CLIENT" "CACHING" } write-command ;
: client-getname      ( args -- ) { "CLIENT" "GETNAME" } write-command ;
: client-getredir     ( args -- ) { "CLIENT" "GETREDIR" } write-command ;
: client-help         ( args -- ) { "CLIENT" "HELP" } write-command ;
: client-id           ( args -- ) { "CLIENT" "ID" } write-command ;
: client-info         ( args -- ) { "CLIENT" "INFO" } write-command ;
: client-kill         ( args -- ) { "CLIENT" "KILL" } write-command ;
: client-list         ( args -- ) { "CLIENT" "LIST" } write-command ;
: client-no-evict     ( args -- ) { "CLIENT" "NO-EVICT" } write-command ;
: client-no-touch     ( args -- ) { "CLIENT" "NO-TOUCH" } write-command ;
: client-pause        ( args -- ) { "CLIENT" "PAUSE" } write-command ;
: client-reply        ( args -- ) { "CLIENT" "REPLY" } write-command ;
: client-setinfo      ( args -- ) { "CLIENT" "SETINFO" } write-command ;
: client-setname      ( args -- ) { "CLIENT" "SETNAME" } write-command ;
: client-tracking     ( args -- ) { "CLIENT" "TRACKING" } write-command ;
: client-trackinginfo ( args -- ) { "CLIENT" "TRACKINGINFO" } write-command ;
: client-unblock      ( args -- ) { "CLIENT" "UNBLOCK" } write-command ;
: client-unpause      ( args -- ) { "CLIENT" "UNPAUSE" } write-command ;
: echo                ( args -- ) { "ECHO" } write-command ;
: hello               ( args -- ) { "HELLO" } write-command ;
: ping                ( args -- ) { "PING" } write-command ;
: quit                ( args -- ) { "QUIT" } write-command ;
: reset               ( args -- ) { "RESET" } write-command ;
: select              ( args -- ) { "SELECT" } write-command ;

! ===== generic =====
: copy            ( args -- ) { "COPY" } write-command ;
: del             ( args -- ) { "DEL" } write-command ;
: dump            ( args -- ) { "DUMP" } write-command ;
: exists          ( args -- ) { "EXISTS" } write-command ;
: expire          ( args -- ) { "EXPIRE" } write-command ;
: expireat        ( args -- ) { "EXPIREAT" } write-command ;
: expiretime      ( args -- ) { "EXPIRETIME" } write-command ;
: keys            ( args -- ) { "KEYS" } write-command ;
: migrate         ( args -- ) { "MIGRATE" } write-command ;
: move            ( args -- ) { "MOVE" } write-command ;
: object          ( args -- ) { "OBJECT" } write-command ;
: object-encoding ( args -- ) { "OBJECT" "ENCODING" } write-command ;
: object-freq     ( args -- ) { "OBJECT" "FREQ" } write-command ;
: object-help     ( args -- ) { "OBJECT" "HELP" } write-command ;
: object-idletime ( args -- ) { "OBJECT" "IDLETIME" } write-command ;
: object-refcount ( args -- ) { "OBJECT" "REFCOUNT" } write-command ;
: persist         ( args -- ) { "PERSIST" } write-command ;
: pexpire         ( args -- ) { "PEXPIRE" } write-command ;
: pexpireat       ( args -- ) { "PEXPIREAT" } write-command ;
: pexpiretime     ( args -- ) { "PEXPIRETIME" } write-command ;
: pttl            ( args -- ) { "PTTL" } write-command ;
: randomkey       ( args -- ) { "RANDOMKEY" } write-command ;
: rename          ( args -- ) { "RENAME" } write-command ;
: renamenx        ( args -- ) { "RENAMENX" } write-command ;
: restore         ( args -- ) { "RESTORE" } write-command ;
: scan            ( args -- ) { "SCAN" } write-command ;
: sort            ( args -- ) { "SORT" } write-command ;
: sort_ro         ( args -- ) { "SORT_RO" } write-command ;
: touch           ( args -- ) { "TOUCH" } write-command ;
: ttl             ( args -- ) { "TTL" } write-command ;
: type            ( args -- ) { "TYPE" } write-command ;
: unlink          ( args -- ) { "UNLINK" } write-command ;
: wait            ( args -- ) { "WAIT" } write-command ;
: waitaof         ( args -- ) { "WAITAOF" } write-command ;

! ===== geo =====
: geoadd               ( args -- ) { "GEOADD" } write-command ;
: geodist              ( args -- ) { "GEODIST" } write-command ;
: geohash              ( args -- ) { "GEOHASH" } write-command ;
: geopos               ( args -- ) { "GEOPOS" } write-command ;
: georadius            ( args -- ) { "GEORADIUS" } write-command ;
: georadius_ro         ( args -- ) { "GEORADIUS_RO" } write-command ;
: georadiusbymember    ( args -- ) { "GEORADIUSBYMEMBER" } write-command ;
: georadiusbymember_ro ( args -- ) { "GEORADIUSBYMEMBER_RO" } write-command ;
: geosearch            ( args -- ) { "GEOSEARCH" } write-command ;
: geosearchstore       ( args -- ) { "GEOSEARCHSTORE" } write-command ;

! ===== hash =====
: hdel         ( args -- ) { "HDEL" } write-command ;
: hexists      ( args -- ) { "HEXISTS" } write-command ;
: hexpire      ( args -- ) { "HEXPIRE" } write-command ;
: hexpireat    ( args -- ) { "HEXPIREAT" } write-command ;
: hexpiretime  ( args -- ) { "HEXPIRETIME" } write-command ;
: hget         ( args -- ) { "HGET" } write-command ;
: hgetall      ( args -- ) { "HGETALL" } write-command ;
: hgetdel      ( args -- ) { "HGETDEL" } write-command ;
: hgetex       ( args -- ) { "HGETEX" } write-command ;
: hincrby      ( args -- ) { "HINCRBY" } write-command ;
: hincrbyfloat ( args -- ) { "HINCRBYFLOAT" } write-command ;
: hkeys        ( args -- ) { "HKEYS" } write-command ;
: hlen         ( args -- ) { "HLEN" } write-command ;
: hmget        ( args -- ) { "HMGET" } write-command ;
: hmset        ( args -- ) { "HMSET" } write-command ;
: hpersist     ( args -- ) { "HPERSIST" } write-command ;
: hpexpire     ( args -- ) { "HPEXPIRE" } write-command ;
: hpexpireat   ( args -- ) { "HPEXPIREAT" } write-command ;
: hpexpiretime ( args -- ) { "HPEXPIRETIME" } write-command ;
: hpttl        ( args -- ) { "HPTTL" } write-command ;
: hrandfield   ( args -- ) { "HRANDFIELD" } write-command ;
: hscan        ( args -- ) { "HSCAN" } write-command ;
: hset         ( args -- ) { "HSET" } write-command ;
: hsetex       ( args -- ) { "HSETEX" } write-command ;
: hsetnx       ( args -- ) { "HSETNX" } write-command ;
: hstrlen      ( args -- ) { "HSTRLEN" } write-command ;
: httl         ( args -- ) { "HTTL" } write-command ;
: hvals        ( args -- ) { "HVALS" } write-command ;

! ===== hyperloglog =====
: pfadd      ( args -- ) { "PFADD" } write-command ;
: pfcount    ( args -- ) { "PFCOUNT" } write-command ;
: pfdebug    ( args -- ) { "PFDEBUG" } write-command ;
: pfmerge    ( args -- ) { "PFMERGE" } write-command ;
: pfselftest ( args -- ) { "PFSELFTEST" } write-command ;

! ===== list =====
: blmove     ( args -- ) { "BLMOVE" } write-command ;
: blmpop     ( args -- ) { "BLMPOP" } write-command ;
: blpop      ( args -- ) { "BLPOP" } write-command ;
: brpop      ( args -- ) { "BRPOP" } write-command ;
: brpoplpush ( args -- ) { "BRPOPLPUSH" } write-command ;
: lindex     ( args -- ) { "LINDEX" } write-command ;
: linsert    ( args -- ) { "LINSERT" } write-command ;
: llen       ( args -- ) { "LLEN" } write-command ;
: lmove      ( args -- ) { "LMOVE" } write-command ;
: lmpop      ( args -- ) { "LMPOP" } write-command ;
: lpop       ( args -- ) { "LPOP" } write-command ;
: lpos       ( args -- ) { "LPOS" } write-command ;
: lpush      ( args -- ) { "LPUSH" } write-command ;
: lpushx     ( args -- ) { "LPUSHX" } write-command ;
: lrange     ( args -- ) { "LRANGE" } write-command ;
: lrem       ( args -- ) { "LREM" } write-command ;
: lset       ( args -- ) { "LSET" } write-command ;
: ltrim      ( args -- ) { "LTRIM" } write-command ;
: rpop       ( args -- ) { "RPOP" } write-command ;
: rpoplpush  ( args -- ) { "RPOPLPUSH" } write-command ;
: rpush      ( args -- ) { "RPUSH" } write-command ;
: rpushx     ( args -- ) { "RPUSHX" } write-command ;

! ===== pubsub =====
: psubscribe           ( args -- ) { "PSUBSCRIBE" } write-command ;
: publish              ( args -- ) { "PUBLISH" } write-command ;
: pubsub               ( args -- ) { "PUBSUB" } write-command ;
: pubsub-channels      ( args -- ) { "PUBSUB" "CHANNELS" } write-command ;
: pubsub-help          ( args -- ) { "PUBSUB" "HELP" } write-command ;
: pubsub-numpat        ( args -- ) { "PUBSUB" "NUMPAT" } write-command ;
: pubsub-numsub        ( args -- ) { "PUBSUB" "NUMSUB" } write-command ;
: pubsub-shardchannels ( args -- ) { "PUBSUB" "SHARDCHANNELS" } write-command ;
: pubsub-shardnumsub   ( args -- ) { "PUBSUB" "SHARDNUMSUB" } write-command ;
: punsubscribe         ( args -- ) { "PUNSUBSCRIBE" } write-command ;
: spublish             ( args -- ) { "SPUBLISH" } write-command ;
: ssubscribe           ( args -- ) { "SSUBSCRIBE" } write-command ;
: subscribe            ( args -- ) { "SUBSCRIBE" } write-command ;
: sunsubscribe         ( args -- ) { "SUNSUBSCRIBE" } write-command ;
: unsubscribe          ( args -- ) { "UNSUBSCRIBE" } write-command ;

! ===== scripting =====
: eval             ( args -- ) { "EVAL" } write-command ;
: eval_ro          ( args -- ) { "EVAL_RO" } write-command ;
: evalsha          ( args -- ) { "EVALSHA" } write-command ;
: evalsha_ro       ( args -- ) { "EVALSHA_RO" } write-command ;
: fcall            ( args -- ) { "FCALL" } write-command ;
: fcall_ro         ( args -- ) { "FCALL_RO" } write-command ;
: function         ( args -- ) { "FUNCTION" } write-command ;
: function-delete  ( args -- ) { "FUNCTION" "DELETE" } write-command ;
: function-dump    ( args -- ) { "FUNCTION" "DUMP" } write-command ;
: function-flush   ( args -- ) { "FUNCTION" "FLUSH" } write-command ;
: function-help    ( args -- ) { "FUNCTION" "HELP" } write-command ;
: function-kill    ( args -- ) { "FUNCTION" "KILL" } write-command ;
: function-list    ( args -- ) { "FUNCTION" "LIST" } write-command ;
: function-load    ( args -- ) { "FUNCTION" "LOAD" } write-command ;
: function-restore ( args -- ) { "FUNCTION" "RESTORE" } write-command ;
: function-stats   ( args -- ) { "FUNCTION" "STATS" } write-command ;
: script           ( args -- ) { "SCRIPT" } write-command ;
: script-debug     ( args -- ) { "SCRIPT" "DEBUG" } write-command ;
: script-exists    ( args -- ) { "SCRIPT" "EXISTS" } write-command ;
: script-flush     ( args -- ) { "SCRIPT" "FLUSH" } write-command ;
: script-help      ( args -- ) { "SCRIPT" "HELP" } write-command ;
: script-kill      ( args -- ) { "SCRIPT" "KILL" } write-command ;
: script-load      ( args -- ) { "SCRIPT" "LOAD" } write-command ;

! ===== sentinel =====
: sentinel                         ( args -- ) { "SENTINEL" } write-command ;
: sentinel-ckquorum                ( args -- ) { "SENTINEL" "CKQUORUM" } write-command ;
: sentinel-config                  ( args -- ) { "SENTINEL" "CONFIG" } write-command ;
: sentinel-debug                   ( args -- ) { "SENTINEL" "DEBUG" } write-command ;
: sentinel-failover                ( args -- ) { "SENTINEL" "FAILOVER" } write-command ;
: sentinel-flushconfig             ( args -- ) { "SENTINEL" "FLUSHCONFIG" } write-command ;
: sentinel-get-master-addr-by-name ( args -- ) { "SENTINEL" "GET-MASTER-ADDR-BY-NAME" } write-command ;
: sentinel-help                    ( args -- ) { "SENTINEL" "HELP" } write-command ;
: sentinel-info-cache              ( args -- ) { "SENTINEL" "INFO-CACHE" } write-command ;
: sentinel-is-master-down-by-addr  ( args -- ) { "SENTINEL" "IS-MASTER-DOWN-BY-ADDR" } write-command ;
: sentinel-master                  ( args -- ) { "SENTINEL" "MASTER" } write-command ;
: sentinel-masters                 ( args -- ) { "SENTINEL" "MASTERS" } write-command ;
: sentinel-monitor                 ( args -- ) { "SENTINEL" "MONITOR" } write-command ;
: sentinel-myid                    ( args -- ) { "SENTINEL" "MYID" } write-command ;
: sentinel-pending-scripts         ( args -- ) { "SENTINEL" "PENDING-SCRIPTS" } write-command ;
: sentinel-remove                  ( args -- ) { "SENTINEL" "REMOVE" } write-command ;
: sentinel-replicas                ( args -- ) { "SENTINEL" "REPLICAS" } write-command ;
: sentinel-reset                   ( args -- ) { "SENTINEL" "RESET" } write-command ;
: sentinel-sentinels               ( args -- ) { "SENTINEL" "SENTINELS" } write-command ;
: sentinel-set                     ( args -- ) { "SENTINEL" "SET" } write-command ;
: sentinel-simulate-failure        ( args -- ) { "SENTINEL" "SIMULATE-FAILURE" } write-command ;
: sentinel-slaves                  ( args -- ) { "SENTINEL" "SLAVES" } write-command ;

! ===== server =====
: acl                     ( args -- ) { "ACL" } write-command ;
: acl-cat                 ( args -- ) { "ACL" "CAT" } write-command ;
: acl-deluser             ( args -- ) { "ACL" "DELUSER" } write-command ;
: acl-dryrun              ( args -- ) { "ACL" "DRYRUN" } write-command ;
: acl-genpass             ( args -- ) { "ACL" "GENPASS" } write-command ;
: acl-getuser             ( args -- ) { "ACL" "GETUSER" } write-command ;
: acl-help                ( args -- ) { "ACL" "HELP" } write-command ;
: acl-list                ( args -- ) { "ACL" "LIST" } write-command ;
: acl-load                ( args -- ) { "ACL" "LOAD" } write-command ;
: acl-log                 ( args -- ) { "ACL" "LOG" } write-command ;
: acl-save                ( args -- ) { "ACL" "SAVE" } write-command ;
: acl-setuser             ( args -- ) { "ACL" "SETUSER" } write-command ;
: acl-users               ( args -- ) { "ACL" "USERS" } write-command ;
: acl-whoami              ( args -- ) { "ACL" "WHOAMI" } write-command ;
: bgrewriteaof            ( args -- ) { "BGREWRITEAOF" } write-command ;
: bgsave                  ( args -- ) { "BGSAVE" } write-command ;
: command                 ( args -- ) { "COMMAND" } write-command ;
: command-count           ( args -- ) { "COMMAND" "COUNT" } write-command ;
: command-docs            ( args -- ) { "COMMAND" "DOCS" } write-command ;
: command-getkeys         ( args -- ) { "COMMAND" "GETKEYS" } write-command ;
: command-getkeysandflags ( args -- ) { "COMMAND" "GETKEYSANDFLAGS" } write-command ;
: command-help            ( args -- ) { "COMMAND" "HELP" } write-command ;
: command-info            ( args -- ) { "COMMAND" "INFO" } write-command ;
: command-list            ( args -- ) { "COMMAND" "LIST" } write-command ;
: config                  ( args -- ) { "CONFIG" } write-command ;
: config-get              ( args -- ) { "CONFIG" "GET" } write-command ;
: config-help             ( args -- ) { "CONFIG" "HELP" } write-command ;
: config-resetstat        ( args -- ) { "CONFIG" "RESETSTAT" } write-command ;
: config-rewrite          ( args -- ) { "CONFIG" "REWRITE" } write-command ;
: config-set              ( args -- ) { "CONFIG" "SET" } write-command ;
: dbsize                  ( args -- ) { "DBSIZE" } write-command ;
: debug                   ( args -- ) { "DEBUG" } write-command ;
: failover                ( args -- ) { "FAILOVER" } write-command ;
: flushall                ( args -- ) { "FLUSHALL" } write-command ;
: flushdb                 ( args -- ) { "FLUSHDB" } write-command ;
: hotkeys                 ( args -- ) { "HOTKEYS" } write-command ;
: hotkeys-get             ( args -- ) { "HOTKEYS" "GET" } write-command ;
: hotkeys-help            ( args -- ) { "HOTKEYS" "HELP" } write-command ;
: hotkeys-reset           ( args -- ) { "HOTKEYS" "RESET" } write-command ;
: hotkeys-start           ( args -- ) { "HOTKEYS" "START" } write-command ;
: hotkeys-stop            ( args -- ) { "HOTKEYS" "STOP" } write-command ;
: info                    ( args -- ) { "INFO" } write-command ;
: lastsave                ( args -- ) { "LASTSAVE" } write-command ;
: latency                 ( args -- ) { "LATENCY" } write-command ;
: latency-doctor          ( args -- ) { "LATENCY" "DOCTOR" } write-command ;
: latency-graph           ( args -- ) { "LATENCY" "GRAPH" } write-command ;
: latency-help            ( args -- ) { "LATENCY" "HELP" } write-command ;
: latency-histogram       ( args -- ) { "LATENCY" "HISTOGRAM" } write-command ;
: latency-history         ( args -- ) { "LATENCY" "HISTORY" } write-command ;
: latency-latest          ( args -- ) { "LATENCY" "LATEST" } write-command ;
: latency-reset           ( args -- ) { "LATENCY" "RESET" } write-command ;
: lolwut                  ( args -- ) { "LOLWUT" } write-command ;
: memory                  ( args -- ) { "MEMORY" } write-command ;
: memory-doctor           ( args -- ) { "MEMORY" "DOCTOR" } write-command ;
: memory-help             ( args -- ) { "MEMORY" "HELP" } write-command ;
: memory-malloc-stats     ( args -- ) { "MEMORY" "MALLOC-STATS" } write-command ;
: memory-purge            ( args -- ) { "MEMORY" "PURGE" } write-command ;
: memory-stats            ( args -- ) { "MEMORY" "STATS" } write-command ;
: memory-usage            ( args -- ) { "MEMORY" "USAGE" } write-command ;
: module                  ( args -- ) { "MODULE" } write-command ;
: module-help             ( args -- ) { "MODULE" "HELP" } write-command ;
: module-list             ( args -- ) { "MODULE" "LIST" } write-command ;
: module-load             ( args -- ) { "MODULE" "LOAD" } write-command ;
: module-loadex           ( args -- ) { "MODULE" "LOADEX" } write-command ;
: module-unload           ( args -- ) { "MODULE" "UNLOAD" } write-command ;
: monitor                 ( args -- ) { "MONITOR" } write-command ;
: psync                   ( args -- ) { "PSYNC" } write-command ;
: replconf                ( args -- ) { "REPLCONF" } write-command ;
: replicaof               ( args -- ) { "REPLICAOF" } write-command ;
: restore-asking          ( args -- ) { "RESTORE-ASKING" } write-command ;
: role                    ( args -- ) { "ROLE" } write-command ;
: save                    ( args -- ) { "SAVE" } write-command ;
: sflush                  ( args -- ) { "SFLUSH" } write-command ;
: shutdown                ( args -- ) { "SHUTDOWN" } write-command ;
: slaveof                 ( args -- ) { "SLAVEOF" } write-command ;
: slowlog                 ( args -- ) { "SLOWLOG" } write-command ;
: slowlog-get             ( args -- ) { "SLOWLOG" "GET" } write-command ;
: slowlog-help            ( args -- ) { "SLOWLOG" "HELP" } write-command ;
: slowlog-len             ( args -- ) { "SLOWLOG" "LEN" } write-command ;
: slowlog-reset           ( args -- ) { "SLOWLOG" "RESET" } write-command ;
: swapdb                  ( args -- ) { "SWAPDB" } write-command ;
: sync                    ( args -- ) { "SYNC" } write-command ;
: time                    ( args -- ) { "TIME" } write-command ;
: trimslots               ( args -- ) { "TRIMSLOTS" } write-command ;

! ===== set =====
: sadd        ( args -- ) { "SADD" } write-command ;
: scard       ( args -- ) { "SCARD" } write-command ;
: sdiff       ( args -- ) { "SDIFF" } write-command ;
: sdiffstore  ( args -- ) { "SDIFFSTORE" } write-command ;
: sinter      ( args -- ) { "SINTER" } write-command ;
: sintercard  ( args -- ) { "SINTERCARD" } write-command ;
: sinterstore ( args -- ) { "SINTERSTORE" } write-command ;
: sismember   ( args -- ) { "SISMEMBER" } write-command ;
: smembers    ( args -- ) { "SMEMBERS" } write-command ;
: smismember  ( args -- ) { "SMISMEMBER" } write-command ;
: smove       ( args -- ) { "SMOVE" } write-command ;
: spop        ( args -- ) { "SPOP" } write-command ;
: srandmember ( args -- ) { "SRANDMEMBER" } write-command ;
: srem        ( args -- ) { "SREM" } write-command ;
: sscan       ( args -- ) { "SSCAN" } write-command ;
: sunion      ( args -- ) { "SUNION" } write-command ;
: sunionstore ( args -- ) { "SUNIONSTORE" } write-command ;

! ===== sorted_set =====
: bzmpop           ( args -- ) { "BZMPOP" } write-command ;
: bzpopmax         ( args -- ) { "BZPOPMAX" } write-command ;
: bzpopmin         ( args -- ) { "BZPOPMIN" } write-command ;
: zadd             ( args -- ) { "ZADD" } write-command ;
: zcard            ( args -- ) { "ZCARD" } write-command ;
: zcount           ( args -- ) { "ZCOUNT" } write-command ;
: zdiff            ( args -- ) { "ZDIFF" } write-command ;
: zdiffstore       ( args -- ) { "ZDIFFSTORE" } write-command ;
: zincrby          ( args -- ) { "ZINCRBY" } write-command ;
: zinter           ( args -- ) { "ZINTER" } write-command ;
: zintercard       ( args -- ) { "ZINTERCARD" } write-command ;
: zinterstore      ( args -- ) { "ZINTERSTORE" } write-command ;
: zlexcount        ( args -- ) { "ZLEXCOUNT" } write-command ;
: zmpop            ( args -- ) { "ZMPOP" } write-command ;
: zmscore          ( args -- ) { "ZMSCORE" } write-command ;
: zpopmax          ( args -- ) { "ZPOPMAX" } write-command ;
: zpopmin          ( args -- ) { "ZPOPMIN" } write-command ;
: zrandmember      ( args -- ) { "ZRANDMEMBER" } write-command ;
: zrange           ( args -- ) { "ZRANGE" } write-command ;
: zrangebylex      ( args -- ) { "ZRANGEBYLEX" } write-command ;
: zrangebyscore    ( args -- ) { "ZRANGEBYSCORE" } write-command ;
: zrangestore      ( args -- ) { "ZRANGESTORE" } write-command ;
: zrank            ( args -- ) { "ZRANK" } write-command ;
: zrem             ( args -- ) { "ZREM" } write-command ;
: zremrangebylex   ( args -- ) { "ZREMRANGEBYLEX" } write-command ;
: zremrangebyrank  ( args -- ) { "ZREMRANGEBYRANK" } write-command ;
: zremrangebyscore ( args -- ) { "ZREMRANGEBYSCORE" } write-command ;
: zrevrange        ( args -- ) { "ZREVRANGE" } write-command ;
: zrevrangebylex   ( args -- ) { "ZREVRANGEBYLEX" } write-command ;
: zrevrangebyscore ( args -- ) { "ZREVRANGEBYSCORE" } write-command ;
: zrevrank         ( args -- ) { "ZREVRANK" } write-command ;
: zscan            ( args -- ) { "ZSCAN" } write-command ;
: zscore           ( args -- ) { "ZSCORE" } write-command ;
: zunion           ( args -- ) { "ZUNION" } write-command ;
: zunionstore      ( args -- ) { "ZUNIONSTORE" } write-command ;

! ===== stream =====
: xack                  ( args -- ) { "XACK" } write-command ;
: xackdel               ( args -- ) { "XACKDEL" } write-command ;
: xadd                  ( args -- ) { "XADD" } write-command ;
: xautoclaim            ( args -- ) { "XAUTOCLAIM" } write-command ;
: xcfgset               ( args -- ) { "XCFGSET" } write-command ;
: xclaim                ( args -- ) { "XCLAIM" } write-command ;
: xdel                  ( args -- ) { "XDEL" } write-command ;
: xdelex                ( args -- ) { "XDELEX" } write-command ;
: xgroup                ( args -- ) { "XGROUP" } write-command ;
: xgroup-create         ( args -- ) { "XGROUP" "CREATE" } write-command ;
: xgroup-createconsumer ( args -- ) { "XGROUP" "CREATECONSUMER" } write-command ;
: xgroup-delconsumer    ( args -- ) { "XGROUP" "DELCONSUMER" } write-command ;
: xgroup-destroy        ( args -- ) { "XGROUP" "DESTROY" } write-command ;
: xgroup-help           ( args -- ) { "XGROUP" "HELP" } write-command ;
: xgroup-setid          ( args -- ) { "XGROUP" "SETID" } write-command ;
: xidmprecord           ( args -- ) { "XIDMPRECORD" } write-command ;
: xinfo                 ( args -- ) { "XINFO" } write-command ;
: xinfo-consumers       ( args -- ) { "XINFO" "CONSUMERS" } write-command ;
: xinfo-groups          ( args -- ) { "XINFO" "GROUPS" } write-command ;
: xinfo-help            ( args -- ) { "XINFO" "HELP" } write-command ;
: xinfo-stream          ( args -- ) { "XINFO" "STREAM" } write-command ;
: xlen                  ( args -- ) { "XLEN" } write-command ;
: xnack                 ( args -- ) { "XNACK" } write-command ;
: xpending              ( args -- ) { "XPENDING" } write-command ;
: xrange                ( args -- ) { "XRANGE" } write-command ;
: xread                 ( args -- ) { "XREAD" } write-command ;
: xreadgroup            ( args -- ) { "XREADGROUP" } write-command ;
: xrevrange             ( args -- ) { "XREVRANGE" } write-command ;
: xsetid                ( args -- ) { "XSETID" } write-command ;
: xtrim                 ( args -- ) { "XTRIM" } write-command ;

! ===== string =====
: append      ( args -- ) { "APPEND" } write-command ;
: decr        ( args -- ) { "DECR" } write-command ;
: decrby      ( args -- ) { "DECRBY" } write-command ;
: delex       ( args -- ) { "DELEX" } write-command ;
: digest      ( args -- ) { "DIGEST" } write-command ;
: get         ( args -- ) { "GET" } write-command ;
: getdel      ( args -- ) { "GETDEL" } write-command ;
: getex       ( args -- ) { "GETEX" } write-command ;
: getrange    ( args -- ) { "GETRANGE" } write-command ;
: getset      ( args -- ) { "GETSET" } write-command ;
: incr        ( args -- ) { "INCR" } write-command ;
: incrby      ( args -- ) { "INCRBY" } write-command ;
: incrbyfloat ( args -- ) { "INCRBYFLOAT" } write-command ;
: increx      ( args -- ) { "INCREX" } write-command ;
: lcs         ( args -- ) { "LCS" } write-command ;
: mget        ( args -- ) { "MGET" } write-command ;
: mset        ( args -- ) { "MSET" } write-command ;
: msetex      ( args -- ) { "MSETEX" } write-command ;
: msetnx      ( args -- ) { "MSETNX" } write-command ;
: psetex      ( args -- ) { "PSETEX" } write-command ;
: set         ( args -- ) { "SET" } write-command ;
: setex       ( args -- ) { "SETEX" } write-command ;
: setnx       ( args -- ) { "SETNX" } write-command ;
: setrange    ( args -- ) { "SETRANGE" } write-command ;
: strlen      ( args -- ) { "STRLEN" } write-command ;
: substr      ( args -- ) { "SUBSTR" } write-command ;

! ===== transactions =====
: discard ( args -- ) { "DISCARD" } write-command ;
: exec    ( args -- ) { "EXEC" } write-command ;
: multi   ( args -- ) { "MULTI" } write-command ;
: unwatch ( args -- ) { "UNWATCH" } write-command ;
: watch   ( args -- ) { "WATCH" } write-command ;
