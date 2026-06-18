! Copyright (C) 2009 Bruno Deferrari
! See https://factorcode.org/license.txt for BSD license.
! redis-* command wrappers generated from the Redis 8.8.0 command spec.
! Each wrapper takes a sequence of arguments, sends the command, and
! returns the parsed reply. Use redis-send for arbitrary commands.
USING: accessors arrays calendar io io.encodings.binary
io.encodings.utf8 io.sockets io.streams.duplex io.timeouts kernel
locals redis.response-parser ;
QUALIFIED-WITH: redis.command-writer cw
QUALIFIED: namespaces
IN: redis

! Redis object. encoding is the text encoding used for string arguments
! and bulk replies (UTF-8); the wire connection itself is binary.
TUPLE: redis host port encoding password protocol ;

SYMBOL: redis-host
"127.0.0.1" redis-host namespaces:set-global

SYMBOL: redis-port
6379 redis-port namespaces:set-global

: <redis> ( -- redis )
    redis new
        redis-host namespaces:get >>host
        redis-port namespaces:get >>port
        utf8 >>encoding
        2 >>protocol ;

: redis-do-connect ( redis -- stream )
    [ host>> ] [ port>> ] bi <inet> binary <client> drop
    1 minutes over set-timeout ;

! Send an arbitrary command. args is the full command, e.g.
! { "SET" "key" "value" "EX" 60 } redis-send
: redis-send ( args -- response )
    { } cw:write-command flush read-response ;

! ===== array =====
: redis-arcount ( args -- response ) cw:arcount     flush read-response ;
: redis-ardel ( args -- response ) cw:ardel       flush read-response ;
: redis-ardelrange ( args -- response ) cw:ardelrange  flush read-response ;
: redis-arget ( args -- response ) cw:arget       flush read-response ;
: redis-argetrange ( args -- response ) cw:argetrange  flush read-response ;
: redis-argrep ( args -- response ) cw:argrep      flush read-response ;
: redis-arinfo ( args -- response ) cw:arinfo      flush read-response ;
: redis-arinsert ( args -- response ) cw:arinsert    flush read-response ;
: redis-arlastitems ( args -- response ) cw:arlastitems flush read-response ;
: redis-arlen ( args -- response ) cw:arlen       flush read-response ;
: redis-armget ( args -- response ) cw:armget      flush read-response ;
: redis-armset ( args -- response ) cw:armset      flush read-response ;
: redis-arnext ( args -- response ) cw:arnext      flush read-response ;
: redis-arop ( args -- response ) cw:arop        flush read-response ;
: redis-arring ( args -- response ) cw:arring      flush read-response ;
: redis-arscan ( args -- response ) cw:arscan      flush read-response ;
: redis-arseek ( args -- response ) cw:arseek      flush read-response ;
: redis-arset ( args -- response ) cw:arset       flush read-response ;

! ===== bitmap =====
: redis-bitcount ( args -- response ) cw:bitcount    flush read-response ;
: redis-bitfield ( args -- response ) cw:bitfield    flush read-response ;
: redis-bitfield_ro ( args -- response ) cw:bitfield_ro flush read-response ;
: redis-bitop ( args -- response ) cw:bitop       flush read-response ;
: redis-bitpos ( args -- response ) cw:bitpos      flush read-response ;
: redis-getbit ( args -- response ) cw:getbit      flush read-response ;
: redis-setbit ( args -- response ) cw:setbit      flush read-response ;

! ===== cluster =====
: redis-asking ( args -- response ) cw:asking                        flush read-response ;
: redis-cluster ( args -- response ) cw:cluster                       flush read-response ;
: redis-cluster-addslots ( args -- response ) cw:cluster-addslots              flush read-response ;
: redis-cluster-addslotsrange ( args -- response ) cw:cluster-addslotsrange         flush read-response ;
: redis-cluster-bumpepoch ( args -- response ) cw:cluster-bumpepoch             flush read-response ;
: redis-cluster-count-failure-reports ( args -- response ) cw:cluster-count-failure-reports flush read-response ;
: redis-cluster-countkeysinslot ( args -- response ) cw:cluster-countkeysinslot       flush read-response ;
: redis-cluster-delslots ( args -- response ) cw:cluster-delslots              flush read-response ;
: redis-cluster-delslotsrange ( args -- response ) cw:cluster-delslotsrange         flush read-response ;
: redis-cluster-failover ( args -- response ) cw:cluster-failover              flush read-response ;
: redis-cluster-flushslots ( args -- response ) cw:cluster-flushslots            flush read-response ;
: redis-cluster-forget ( args -- response ) cw:cluster-forget                flush read-response ;
: redis-cluster-getkeysinslot ( args -- response ) cw:cluster-getkeysinslot         flush read-response ;
: redis-cluster-help ( args -- response ) cw:cluster-help                  flush read-response ;
: redis-cluster-info ( args -- response ) cw:cluster-info                  flush read-response ;
: redis-cluster-keyslot ( args -- response ) cw:cluster-keyslot               flush read-response ;
: redis-cluster-links ( args -- response ) cw:cluster-links                 flush read-response ;
: redis-cluster-meet ( args -- response ) cw:cluster-meet                  flush read-response ;
: redis-cluster-migration ( args -- response ) cw:cluster-migration             flush read-response ;
: redis-cluster-myid ( args -- response ) cw:cluster-myid                  flush read-response ;
: redis-cluster-myshardid ( args -- response ) cw:cluster-myshardid             flush read-response ;
: redis-cluster-nodes ( args -- response ) cw:cluster-nodes                 flush read-response ;
: redis-cluster-replicas ( args -- response ) cw:cluster-replicas              flush read-response ;
: redis-cluster-replicate ( args -- response ) cw:cluster-replicate             flush read-response ;
: redis-cluster-reset ( args -- response ) cw:cluster-reset                 flush read-response ;
: redis-cluster-saveconfig ( args -- response ) cw:cluster-saveconfig            flush read-response ;
: redis-cluster-set-config-epoch ( args -- response ) cw:cluster-set-config-epoch      flush read-response ;
: redis-cluster-setslot ( args -- response ) cw:cluster-setslot               flush read-response ;
: redis-cluster-shards ( args -- response ) cw:cluster-shards                flush read-response ;
: redis-cluster-slaves ( args -- response ) cw:cluster-slaves                flush read-response ;
: redis-cluster-slot-stats ( args -- response ) cw:cluster-slot-stats            flush read-response ;
: redis-cluster-slots ( args -- response ) cw:cluster-slots                 flush read-response ;
: redis-cluster-syncslots ( args -- response ) cw:cluster-syncslots             flush read-response ;
: redis-readonly ( args -- response ) cw:readonly                      flush read-response ;
: redis-readwrite ( args -- response ) cw:readwrite                     flush read-response ;

! ===== connection =====
: redis-auth ( args -- response ) cw:auth                flush read-response ;
: redis-client ( args -- response ) cw:client              flush read-response ;
: redis-client-caching ( args -- response ) cw:client-caching      flush read-response ;
: redis-client-getname ( args -- response ) cw:client-getname      flush read-response ;
: redis-client-getredir ( args -- response ) cw:client-getredir     flush read-response ;
: redis-client-help ( args -- response ) cw:client-help         flush read-response ;
: redis-client-id ( args -- response ) cw:client-id           flush read-response ;
: redis-client-info ( args -- response ) cw:client-info         flush read-response ;
: redis-client-kill ( args -- response ) cw:client-kill         flush read-response ;
: redis-client-list ( args -- response ) cw:client-list         flush read-response ;
: redis-client-no-evict ( args -- response ) cw:client-no-evict     flush read-response ;
: redis-client-no-touch ( args -- response ) cw:client-no-touch     flush read-response ;
: redis-client-pause ( args -- response ) cw:client-pause        flush read-response ;
: redis-client-reply ( args -- response ) cw:client-reply        flush read-response ;
: redis-client-setinfo ( args -- response ) cw:client-setinfo      flush read-response ;
: redis-client-setname ( args -- response ) cw:client-setname      flush read-response ;
: redis-client-tracking ( args -- response ) cw:client-tracking     flush read-response ;
: redis-client-trackinginfo ( args -- response ) cw:client-trackinginfo flush read-response ;
: redis-client-unblock ( args -- response ) cw:client-unblock      flush read-response ;
: redis-client-unpause ( args -- response ) cw:client-unpause      flush read-response ;
: redis-echo ( args -- response ) cw:echo                flush read-response ;
: redis-hello ( args -- response ) cw:hello               flush read-response ;
: redis-ping ( args -- response ) cw:ping                flush read-response ;
: redis-quit ( args -- response ) cw:quit                flush read-response ;
: redis-reset ( args -- response ) cw:reset               flush read-response ;
: redis-select ( args -- response ) cw:select              flush read-response ;

! ===== generic =====
: redis-copy ( args -- response ) cw:copy            flush read-response ;
: redis-del ( args -- response ) cw:del             flush read-response ;
: redis-dump ( args -- response ) cw:dump            flush read-response ;
: redis-exists ( args -- response ) cw:exists          flush read-response ;
: redis-expire ( args -- response ) cw:expire          flush read-response ;
: redis-expireat ( args -- response ) cw:expireat        flush read-response ;
: redis-expiretime ( args -- response ) cw:expiretime      flush read-response ;
: redis-keys ( args -- response ) cw:keys            flush read-response ;
: redis-migrate ( args -- response ) cw:migrate         flush read-response ;
: redis-move ( args -- response ) cw:move            flush read-response ;
: redis-object ( args -- response ) cw:object          flush read-response ;
: redis-object-encoding ( args -- response ) cw:object-encoding flush read-response ;
: redis-object-freq ( args -- response ) cw:object-freq     flush read-response ;
: redis-object-help ( args -- response ) cw:object-help     flush read-response ;
: redis-object-idletime ( args -- response ) cw:object-idletime flush read-response ;
: redis-object-refcount ( args -- response ) cw:object-refcount flush read-response ;
: redis-persist ( args -- response ) cw:persist         flush read-response ;
: redis-pexpire ( args -- response ) cw:pexpire         flush read-response ;
: redis-pexpireat ( args -- response ) cw:pexpireat       flush read-response ;
: redis-pexpiretime ( args -- response ) cw:pexpiretime     flush read-response ;
: redis-pttl ( args -- response ) cw:pttl            flush read-response ;
: redis-randomkey ( args -- response ) cw:randomkey       flush read-response ;
: redis-rename ( args -- response ) cw:rename          flush read-response ;
: redis-renamenx ( args -- response ) cw:renamenx        flush read-response ;
: redis-restore ( args -- response ) cw:restore         flush read-response ;
: redis-scan ( args -- response ) cw:scan            flush read-response ;
: redis-sort ( args -- response ) cw:sort            flush read-response ;
: redis-sort_ro ( args -- response ) cw:sort_ro         flush read-response ;
: redis-touch ( args -- response ) cw:touch           flush read-response ;
: redis-ttl ( args -- response ) cw:ttl             flush read-response ;
: redis-type ( args -- response ) cw:type            flush read-response ;
: redis-unlink ( args -- response ) cw:unlink          flush read-response ;
: redis-wait ( args -- response ) cw:wait            flush read-response ;
: redis-waitaof ( args -- response ) cw:waitaof         flush read-response ;

! ===== geo =====
: redis-geoadd ( args -- response ) cw:geoadd               flush read-response ;
: redis-geodist ( args -- response ) cw:geodist              flush read-response ;
: redis-geohash ( args -- response ) cw:geohash              flush read-response ;
: redis-geopos ( args -- response ) cw:geopos               flush read-response ;
: redis-georadius ( args -- response ) cw:georadius            flush read-response ;
: redis-georadius_ro ( args -- response ) cw:georadius_ro         flush read-response ;
: redis-georadiusbymember ( args -- response ) cw:georadiusbymember    flush read-response ;
: redis-georadiusbymember_ro ( args -- response ) cw:georadiusbymember_ro flush read-response ;
: redis-geosearch ( args -- response ) cw:geosearch            flush read-response ;
: redis-geosearchstore ( args -- response ) cw:geosearchstore       flush read-response ;

! ===== hash =====
: redis-hdel ( args -- response ) cw:hdel         flush read-response ;
: redis-hexists ( args -- response ) cw:hexists      flush read-response ;
: redis-hexpire ( args -- response ) cw:hexpire      flush read-response ;
: redis-hexpireat ( args -- response ) cw:hexpireat    flush read-response ;
: redis-hexpiretime ( args -- response ) cw:hexpiretime  flush read-response ;
: redis-hget ( args -- response ) cw:hget         flush read-response ;
: redis-hgetall ( args -- response ) cw:hgetall      flush read-response ;
: redis-hgetdel ( args -- response ) cw:hgetdel      flush read-response ;
: redis-hgetex ( args -- response ) cw:hgetex       flush read-response ;
: redis-hincrby ( args -- response ) cw:hincrby      flush read-response ;
: redis-hincrbyfloat ( args -- response ) cw:hincrbyfloat flush read-response ;
: redis-hkeys ( args -- response ) cw:hkeys        flush read-response ;
: redis-hlen ( args -- response ) cw:hlen         flush read-response ;
: redis-hmget ( args -- response ) cw:hmget        flush read-response ;
: redis-hmset ( args -- response ) cw:hmset        flush read-response ;
: redis-hpersist ( args -- response ) cw:hpersist     flush read-response ;
: redis-hpexpire ( args -- response ) cw:hpexpire     flush read-response ;
: redis-hpexpireat ( args -- response ) cw:hpexpireat   flush read-response ;
: redis-hpexpiretime ( args -- response ) cw:hpexpiretime flush read-response ;
: redis-hpttl ( args -- response ) cw:hpttl        flush read-response ;
: redis-hrandfield ( args -- response ) cw:hrandfield   flush read-response ;
: redis-hscan ( args -- response ) cw:hscan        flush read-response ;
: redis-hset ( args -- response ) cw:hset         flush read-response ;
: redis-hsetex ( args -- response ) cw:hsetex       flush read-response ;
: redis-hsetnx ( args -- response ) cw:hsetnx       flush read-response ;
: redis-hstrlen ( args -- response ) cw:hstrlen      flush read-response ;
: redis-httl ( args -- response ) cw:httl         flush read-response ;
: redis-hvals ( args -- response ) cw:hvals        flush read-response ;

! ===== hyperloglog =====
: redis-pfadd ( args -- response ) cw:pfadd      flush read-response ;
: redis-pfcount ( args -- response ) cw:pfcount    flush read-response ;
: redis-pfdebug ( args -- response ) cw:pfdebug    flush read-response ;
: redis-pfmerge ( args -- response ) cw:pfmerge    flush read-response ;
: redis-pfselftest ( args -- response ) cw:pfselftest flush read-response ;

! ===== list =====
: redis-blmove ( args -- response ) cw:blmove     flush read-response ;
: redis-blmpop ( args -- response ) cw:blmpop     flush read-response ;
: redis-blpop ( args -- response ) cw:blpop      flush read-response ;
: redis-brpop ( args -- response ) cw:brpop      flush read-response ;
: redis-brpoplpush ( args -- response ) cw:brpoplpush flush read-response ;
: redis-lindex ( args -- response ) cw:lindex     flush read-response ;
: redis-linsert ( args -- response ) cw:linsert    flush read-response ;
: redis-llen ( args -- response ) cw:llen       flush read-response ;
: redis-lmove ( args -- response ) cw:lmove      flush read-response ;
: redis-lmpop ( args -- response ) cw:lmpop      flush read-response ;
: redis-lpop ( args -- response ) cw:lpop       flush read-response ;
: redis-lpos ( args -- response ) cw:lpos       flush read-response ;
: redis-lpush ( args -- response ) cw:lpush      flush read-response ;
: redis-lpushx ( args -- response ) cw:lpushx     flush read-response ;
: redis-lrange ( args -- response ) cw:lrange     flush read-response ;
: redis-lrem ( args -- response ) cw:lrem       flush read-response ;
: redis-lset ( args -- response ) cw:lset       flush read-response ;
: redis-ltrim ( args -- response ) cw:ltrim      flush read-response ;
: redis-rpop ( args -- response ) cw:rpop       flush read-response ;
: redis-rpoplpush ( args -- response ) cw:rpoplpush  flush read-response ;
: redis-rpush ( args -- response ) cw:rpush      flush read-response ;
: redis-rpushx ( args -- response ) cw:rpushx     flush read-response ;

! ===== pubsub =====
: redis-psubscribe ( args -- response ) cw:psubscribe           flush read-response ;
: redis-publish ( args -- response ) cw:publish              flush read-response ;
: redis-pubsub ( args -- response ) cw:pubsub               flush read-response ;
: redis-pubsub-channels ( args -- response ) cw:pubsub-channels      flush read-response ;
: redis-pubsub-help ( args -- response ) cw:pubsub-help          flush read-response ;
: redis-pubsub-numpat ( args -- response ) cw:pubsub-numpat        flush read-response ;
: redis-pubsub-numsub ( args -- response ) cw:pubsub-numsub        flush read-response ;
: redis-pubsub-shardchannels ( args -- response ) cw:pubsub-shardchannels flush read-response ;
: redis-pubsub-shardnumsub ( args -- response ) cw:pubsub-shardnumsub   flush read-response ;
: redis-punsubscribe ( args -- response ) cw:punsubscribe         flush read-response ;
: redis-spublish ( args -- response ) cw:spublish             flush read-response ;
: redis-ssubscribe ( args -- response ) cw:ssubscribe           flush read-response ;
: redis-subscribe ( args -- response ) cw:subscribe            flush read-response ;
: redis-sunsubscribe ( args -- response ) cw:sunsubscribe         flush read-response ;
: redis-unsubscribe ( args -- response ) cw:unsubscribe          flush read-response ;

! ===== scripting =====
: redis-eval ( args -- response ) cw:eval             flush read-response ;
: redis-eval_ro ( args -- response ) cw:eval_ro          flush read-response ;
: redis-evalsha ( args -- response ) cw:evalsha          flush read-response ;
: redis-evalsha_ro ( args -- response ) cw:evalsha_ro       flush read-response ;
: redis-fcall ( args -- response ) cw:fcall            flush read-response ;
: redis-fcall_ro ( args -- response ) cw:fcall_ro         flush read-response ;
: redis-function ( args -- response ) cw:function         flush read-response ;
: redis-function-delete ( args -- response ) cw:function-delete  flush read-response ;
: redis-function-dump ( args -- response ) cw:function-dump    flush read-response ;
: redis-function-flush ( args -- response ) cw:function-flush   flush read-response ;
: redis-function-help ( args -- response ) cw:function-help    flush read-response ;
: redis-function-kill ( args -- response ) cw:function-kill    flush read-response ;
: redis-function-list ( args -- response ) cw:function-list    flush read-response ;
: redis-function-load ( args -- response ) cw:function-load    flush read-response ;
: redis-function-restore ( args -- response ) cw:function-restore flush read-response ;
: redis-function-stats ( args -- response ) cw:function-stats   flush read-response ;
: redis-script ( args -- response ) cw:script           flush read-response ;
: redis-script-debug ( args -- response ) cw:script-debug     flush read-response ;
: redis-script-exists ( args -- response ) cw:script-exists    flush read-response ;
: redis-script-flush ( args -- response ) cw:script-flush     flush read-response ;
: redis-script-help ( args -- response ) cw:script-help      flush read-response ;
: redis-script-kill ( args -- response ) cw:script-kill      flush read-response ;
: redis-script-load ( args -- response ) cw:script-load      flush read-response ;

! ===== sentinel =====
: redis-sentinel ( args -- response ) cw:sentinel                         flush read-response ;
: redis-sentinel-ckquorum ( args -- response ) cw:sentinel-ckquorum                flush read-response ;
: redis-sentinel-config ( args -- response ) cw:sentinel-config                  flush read-response ;
: redis-sentinel-debug ( args -- response ) cw:sentinel-debug                   flush read-response ;
: redis-sentinel-failover ( args -- response ) cw:sentinel-failover                flush read-response ;
: redis-sentinel-flushconfig ( args -- response ) cw:sentinel-flushconfig             flush read-response ;
: redis-sentinel-get-master-addr-by-name ( args -- response ) cw:sentinel-get-master-addr-by-name flush read-response ;
: redis-sentinel-help ( args -- response ) cw:sentinel-help                    flush read-response ;
: redis-sentinel-info-cache ( args -- response ) cw:sentinel-info-cache              flush read-response ;
: redis-sentinel-is-master-down-by-addr ( args -- response ) cw:sentinel-is-master-down-by-addr  flush read-response ;
: redis-sentinel-master ( args -- response ) cw:sentinel-master                  flush read-response ;
: redis-sentinel-masters ( args -- response ) cw:sentinel-masters                 flush read-response ;
: redis-sentinel-monitor ( args -- response ) cw:sentinel-monitor                 flush read-response ;
: redis-sentinel-myid ( args -- response ) cw:sentinel-myid                    flush read-response ;
: redis-sentinel-pending-scripts ( args -- response ) cw:sentinel-pending-scripts         flush read-response ;
: redis-sentinel-remove ( args -- response ) cw:sentinel-remove                  flush read-response ;
: redis-sentinel-replicas ( args -- response ) cw:sentinel-replicas                flush read-response ;
: redis-sentinel-reset ( args -- response ) cw:sentinel-reset                   flush read-response ;
: redis-sentinel-sentinels ( args -- response ) cw:sentinel-sentinels               flush read-response ;
: redis-sentinel-set ( args -- response ) cw:sentinel-set                     flush read-response ;
: redis-sentinel-simulate-failure ( args -- response ) cw:sentinel-simulate-failure        flush read-response ;
: redis-sentinel-slaves ( args -- response ) cw:sentinel-slaves                  flush read-response ;

! ===== server =====
: redis-acl ( args -- response ) cw:acl                     flush read-response ;
: redis-acl-cat ( args -- response ) cw:acl-cat                 flush read-response ;
: redis-acl-deluser ( args -- response ) cw:acl-deluser             flush read-response ;
: redis-acl-dryrun ( args -- response ) cw:acl-dryrun              flush read-response ;
: redis-acl-genpass ( args -- response ) cw:acl-genpass             flush read-response ;
: redis-acl-getuser ( args -- response ) cw:acl-getuser             flush read-response ;
: redis-acl-help ( args -- response ) cw:acl-help                flush read-response ;
: redis-acl-list ( args -- response ) cw:acl-list                flush read-response ;
: redis-acl-load ( args -- response ) cw:acl-load                flush read-response ;
: redis-acl-log ( args -- response ) cw:acl-log                 flush read-response ;
: redis-acl-save ( args -- response ) cw:acl-save                flush read-response ;
: redis-acl-setuser ( args -- response ) cw:acl-setuser             flush read-response ;
: redis-acl-users ( args -- response ) cw:acl-users               flush read-response ;
: redis-acl-whoami ( args -- response ) cw:acl-whoami              flush read-response ;
: redis-bgrewriteaof ( args -- response ) cw:bgrewriteaof            flush read-response ;
: redis-bgsave ( args -- response ) cw:bgsave                  flush read-response ;
: redis-command ( args -- response ) cw:command                 flush read-response ;
: redis-command-count ( args -- response ) cw:command-count           flush read-response ;
: redis-command-docs ( args -- response ) cw:command-docs            flush read-response ;
: redis-command-getkeys ( args -- response ) cw:command-getkeys         flush read-response ;
: redis-command-getkeysandflags ( args -- response ) cw:command-getkeysandflags flush read-response ;
: redis-command-help ( args -- response ) cw:command-help            flush read-response ;
: redis-command-info ( args -- response ) cw:command-info            flush read-response ;
: redis-command-list ( args -- response ) cw:command-list            flush read-response ;
: redis-config ( args -- response ) cw:config                  flush read-response ;
: redis-config-get ( args -- response ) cw:config-get              flush read-response ;
: redis-config-help ( args -- response ) cw:config-help             flush read-response ;
: redis-config-resetstat ( args -- response ) cw:config-resetstat        flush read-response ;
: redis-config-rewrite ( args -- response ) cw:config-rewrite          flush read-response ;
: redis-config-set ( args -- response ) cw:config-set              flush read-response ;
: redis-dbsize ( args -- response ) cw:dbsize                  flush read-response ;
: redis-debug ( args -- response ) cw:debug                   flush read-response ;
: redis-failover ( args -- response ) cw:failover                flush read-response ;
: redis-flushall ( args -- response ) cw:flushall                flush read-response ;
: redis-flushdb ( args -- response ) cw:flushdb                 flush read-response ;
: redis-hotkeys ( args -- response ) cw:hotkeys                 flush read-response ;
: redis-hotkeys-get ( args -- response ) cw:hotkeys-get             flush read-response ;
: redis-hotkeys-help ( args -- response ) cw:hotkeys-help            flush read-response ;
: redis-hotkeys-reset ( args -- response ) cw:hotkeys-reset           flush read-response ;
: redis-hotkeys-start ( args -- response ) cw:hotkeys-start           flush read-response ;
: redis-hotkeys-stop ( args -- response ) cw:hotkeys-stop            flush read-response ;
: redis-info ( args -- response ) cw:info                    flush read-response ;
: redis-lastsave ( args -- response ) cw:lastsave                flush read-response ;
: redis-latency ( args -- response ) cw:latency                 flush read-response ;
: redis-latency-doctor ( args -- response ) cw:latency-doctor          flush read-response ;
: redis-latency-graph ( args -- response ) cw:latency-graph           flush read-response ;
: redis-latency-help ( args -- response ) cw:latency-help            flush read-response ;
: redis-latency-histogram ( args -- response ) cw:latency-histogram       flush read-response ;
: redis-latency-history ( args -- response ) cw:latency-history         flush read-response ;
: redis-latency-latest ( args -- response ) cw:latency-latest          flush read-response ;
: redis-latency-reset ( args -- response ) cw:latency-reset           flush read-response ;
: redis-lolwut ( args -- response ) cw:lolwut                  flush read-response ;
: redis-memory ( args -- response ) cw:memory                  flush read-response ;
: redis-memory-doctor ( args -- response ) cw:memory-doctor           flush read-response ;
: redis-memory-help ( args -- response ) cw:memory-help             flush read-response ;
: redis-memory-malloc-stats ( args -- response ) cw:memory-malloc-stats     flush read-response ;
: redis-memory-purge ( args -- response ) cw:memory-purge            flush read-response ;
: redis-memory-stats ( args -- response ) cw:memory-stats            flush read-response ;
: redis-memory-usage ( args -- response ) cw:memory-usage            flush read-response ;
: redis-module ( args -- response ) cw:module                  flush read-response ;
: redis-module-help ( args -- response ) cw:module-help             flush read-response ;
: redis-module-list ( args -- response ) cw:module-list             flush read-response ;
: redis-module-load ( args -- response ) cw:module-load             flush read-response ;
: redis-module-loadex ( args -- response ) cw:module-loadex           flush read-response ;
: redis-module-unload ( args -- response ) cw:module-unload           flush read-response ;
: redis-monitor ( args -- response ) cw:monitor                 flush read-response ;
: redis-psync ( args -- response ) cw:psync                   flush read-response ;
: redis-replconf ( args -- response ) cw:replconf                flush read-response ;
: redis-replicaof ( args -- response ) cw:replicaof               flush read-response ;
: redis-restore-asking ( args -- response ) cw:restore-asking          flush read-response ;
: redis-role ( args -- response ) cw:role                    flush read-response ;
: redis-save ( args -- response ) cw:save                    flush read-response ;
: redis-sflush ( args -- response ) cw:sflush                  flush read-response ;
: redis-shutdown ( args -- response ) cw:shutdown                flush read-response ;
: redis-slaveof ( args -- response ) cw:slaveof                 flush read-response ;
: redis-slowlog ( args -- response ) cw:slowlog                 flush read-response ;
: redis-slowlog-get ( args -- response ) cw:slowlog-get             flush read-response ;
: redis-slowlog-help ( args -- response ) cw:slowlog-help            flush read-response ;
: redis-slowlog-len ( args -- response ) cw:slowlog-len             flush read-response ;
: redis-slowlog-reset ( args -- response ) cw:slowlog-reset           flush read-response ;
: redis-swapdb ( args -- response ) cw:swapdb                  flush read-response ;
: redis-sync ( args -- response ) cw:sync                    flush read-response ;
: redis-time ( args -- response ) cw:time                    flush read-response ;
: redis-trimslots ( args -- response ) cw:trimslots               flush read-response ;

! ===== set =====
: redis-sadd ( args -- response ) cw:sadd        flush read-response ;
: redis-scard ( args -- response ) cw:scard       flush read-response ;
: redis-sdiff ( args -- response ) cw:sdiff       flush read-response ;
: redis-sdiffstore ( args -- response ) cw:sdiffstore  flush read-response ;
: redis-sinter ( args -- response ) cw:sinter      flush read-response ;
: redis-sintercard ( args -- response ) cw:sintercard  flush read-response ;
: redis-sinterstore ( args -- response ) cw:sinterstore flush read-response ;
: redis-sismember ( args -- response ) cw:sismember   flush read-response ;
: redis-smembers ( args -- response ) cw:smembers    flush read-response ;
: redis-smismember ( args -- response ) cw:smismember  flush read-response ;
: redis-smove ( args -- response ) cw:smove       flush read-response ;
: redis-spop ( args -- response ) cw:spop        flush read-response ;
: redis-srandmember ( args -- response ) cw:srandmember flush read-response ;
: redis-srem ( args -- response ) cw:srem        flush read-response ;
: redis-sscan ( args -- response ) cw:sscan       flush read-response ;
: redis-sunion ( args -- response ) cw:sunion      flush read-response ;
: redis-sunionstore ( args -- response ) cw:sunionstore flush read-response ;

! ===== sorted_set =====
: redis-bzmpop ( args -- response ) cw:bzmpop           flush read-response ;
: redis-bzpopmax ( args -- response ) cw:bzpopmax         flush read-response ;
: redis-bzpopmin ( args -- response ) cw:bzpopmin         flush read-response ;
: redis-zadd ( args -- response ) cw:zadd             flush read-response ;
: redis-zcard ( args -- response ) cw:zcard            flush read-response ;
: redis-zcount ( args -- response ) cw:zcount           flush read-response ;
: redis-zdiff ( args -- response ) cw:zdiff            flush read-response ;
: redis-zdiffstore ( args -- response ) cw:zdiffstore       flush read-response ;
: redis-zincrby ( args -- response ) cw:zincrby          flush read-response ;
: redis-zinter ( args -- response ) cw:zinter           flush read-response ;
: redis-zintercard ( args -- response ) cw:zintercard       flush read-response ;
: redis-zinterstore ( args -- response ) cw:zinterstore      flush read-response ;
: redis-zlexcount ( args -- response ) cw:zlexcount        flush read-response ;
: redis-zmpop ( args -- response ) cw:zmpop            flush read-response ;
: redis-zmscore ( args -- response ) cw:zmscore          flush read-response ;
: redis-zpopmax ( args -- response ) cw:zpopmax          flush read-response ;
: redis-zpopmin ( args -- response ) cw:zpopmin          flush read-response ;
: redis-zrandmember ( args -- response ) cw:zrandmember      flush read-response ;
: redis-zrange ( args -- response ) cw:zrange           flush read-response ;
: redis-zrangebylex ( args -- response ) cw:zrangebylex      flush read-response ;
: redis-zrangebyscore ( args -- response ) cw:zrangebyscore    flush read-response ;
: redis-zrangestore ( args -- response ) cw:zrangestore      flush read-response ;
: redis-zrank ( args -- response ) cw:zrank            flush read-response ;
: redis-zrem ( args -- response ) cw:zrem             flush read-response ;
: redis-zremrangebylex ( args -- response ) cw:zremrangebylex   flush read-response ;
: redis-zremrangebyrank ( args -- response ) cw:zremrangebyrank  flush read-response ;
: redis-zremrangebyscore ( args -- response ) cw:zremrangebyscore flush read-response ;
: redis-zrevrange ( args -- response ) cw:zrevrange        flush read-response ;
: redis-zrevrangebylex ( args -- response ) cw:zrevrangebylex   flush read-response ;
: redis-zrevrangebyscore ( args -- response ) cw:zrevrangebyscore flush read-response ;
: redis-zrevrank ( args -- response ) cw:zrevrank         flush read-response ;
: redis-zscan ( args -- response ) cw:zscan            flush read-response ;
: redis-zscore ( args -- response ) cw:zscore           flush read-response ;
: redis-zunion ( args -- response ) cw:zunion           flush read-response ;
: redis-zunionstore ( args -- response ) cw:zunionstore      flush read-response ;

! ===== stream =====
: redis-xack ( args -- response ) cw:xack                  flush read-response ;
: redis-xackdel ( args -- response ) cw:xackdel               flush read-response ;
: redis-xadd ( args -- response ) cw:xadd                  flush read-response ;
: redis-xautoclaim ( args -- response ) cw:xautoclaim            flush read-response ;
: redis-xcfgset ( args -- response ) cw:xcfgset               flush read-response ;
: redis-xclaim ( args -- response ) cw:xclaim                flush read-response ;
: redis-xdel ( args -- response ) cw:xdel                  flush read-response ;
: redis-xdelex ( args -- response ) cw:xdelex                flush read-response ;
: redis-xgroup ( args -- response ) cw:xgroup                flush read-response ;
: redis-xgroup-create ( args -- response ) cw:xgroup-create         flush read-response ;
: redis-xgroup-createconsumer ( args -- response ) cw:xgroup-createconsumer flush read-response ;
: redis-xgroup-delconsumer ( args -- response ) cw:xgroup-delconsumer    flush read-response ;
: redis-xgroup-destroy ( args -- response ) cw:xgroup-destroy        flush read-response ;
: redis-xgroup-help ( args -- response ) cw:xgroup-help           flush read-response ;
: redis-xgroup-setid ( args -- response ) cw:xgroup-setid          flush read-response ;
: redis-xidmprecord ( args -- response ) cw:xidmprecord           flush read-response ;
: redis-xinfo ( args -- response ) cw:xinfo                 flush read-response ;
: redis-xinfo-consumers ( args -- response ) cw:xinfo-consumers       flush read-response ;
: redis-xinfo-groups ( args -- response ) cw:xinfo-groups          flush read-response ;
: redis-xinfo-help ( args -- response ) cw:xinfo-help            flush read-response ;
: redis-xinfo-stream ( args -- response ) cw:xinfo-stream          flush read-response ;
: redis-xlen ( args -- response ) cw:xlen                  flush read-response ;
: redis-xnack ( args -- response ) cw:xnack                 flush read-response ;
: redis-xpending ( args -- response ) cw:xpending              flush read-response ;
: redis-xrange ( args -- response ) cw:xrange                flush read-response ;
: redis-xread ( args -- response ) cw:xread                 flush read-response ;
: redis-xreadgroup ( args -- response ) cw:xreadgroup            flush read-response ;
: redis-xrevrange ( args -- response ) cw:xrevrange             flush read-response ;
: redis-xsetid ( args -- response ) cw:xsetid                flush read-response ;
: redis-xtrim ( args -- response ) cw:xtrim                 flush read-response ;

! ===== string =====
: redis-append ( args -- response ) cw:append      flush read-response ;
: redis-decr ( args -- response ) cw:decr        flush read-response ;
: redis-decrby ( args -- response ) cw:decrby      flush read-response ;
: redis-delex ( args -- response ) cw:delex       flush read-response ;
: redis-digest ( args -- response ) cw:digest      flush read-response ;
: redis-get ( args -- response ) cw:get         flush read-response ;
: redis-getdel ( args -- response ) cw:getdel      flush read-response ;
: redis-getex ( args -- response ) cw:getex       flush read-response ;
: redis-getrange ( args -- response ) cw:getrange    flush read-response ;
: redis-getset ( args -- response ) cw:getset      flush read-response ;
: redis-incr ( args -- response ) cw:incr        flush read-response ;
: redis-incrby ( args -- response ) cw:incrby      flush read-response ;
: redis-incrbyfloat ( args -- response ) cw:incrbyfloat flush read-response ;
: redis-increx ( args -- response ) cw:increx      flush read-response ;
: redis-lcs ( args -- response ) cw:lcs         flush read-response ;
: redis-mget ( args -- response ) cw:mget        flush read-response ;
: redis-mset ( args -- response ) cw:mset        flush read-response ;
: redis-msetex ( args -- response ) cw:msetex      flush read-response ;
: redis-msetnx ( args -- response ) cw:msetnx      flush read-response ;
: redis-psetex ( args -- response ) cw:psetex      flush read-response ;
: redis-set ( args -- response ) cw:set         flush read-response ;
: redis-setex ( args -- response ) cw:setex       flush read-response ;
: redis-setnx ( args -- response ) cw:setnx       flush read-response ;
: redis-setrange ( args -- response ) cw:setrange    flush read-response ;
: redis-strlen ( args -- response ) cw:strlen      flush read-response ;
: redis-substr ( args -- response ) cw:substr      flush read-response ;

! ===== transactions =====
: redis-discard ( args -- response ) cw:discard flush read-response ;
: redis-exec ( args -- response ) cw:exec    flush read-response ;
: redis-multi ( args -- response ) cw:multi   flush read-response ;
: redis-unwatch ( args -- response ) cw:unwatch flush read-response ;
: redis-watch ( args -- response ) cw:watch   flush read-response ;

<PRIVATE

: redis-authenticate ( redis -- )
    password>> [ 1array redis-auth drop ] when* ;

: redis-negotiate-protocol ( redis -- )
    protocol>> 3 = [ { 3 } redis-hello drop ] when ;

PRIVATE>

:: with-redis ( redis quot -- )
    redis redis-do-connect [
        redis redis-authenticate
        redis redis-negotiate-protocol
        quot call
    ] with-stream ; inline
