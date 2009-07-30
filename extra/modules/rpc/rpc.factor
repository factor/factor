! Copyright (C) 2009 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs concurrency.distributed
concurrency.messaging fry generalizations io.sockets kernel
locals namespaces parser sequences vocabs vocabs.parser words ;
IN: modules.rpc

TUPLE: rpc-request args vocabspec wordname ;

: send-with-check ( message thread -- reply/* ) send-synchronous dup no-vocab? [ throw ] when ;

:: define-remote ( str effect addrspec vocabspec -- )
    str create-in effect [ in>> length ] [ out>> length ] bi
    '[ _ narray vocabspec str rpc-request boa "does-thread" addrspec 9012 <inet> <remote-process> send-with-check _ firstn ]
    effect define-declared ;

:: remote-vocab ( addrspec vocabspec -- vocab )
   vocabspec "-remote" append dup vocab [ dup set-current-vocab
     vocabspec "gets-thread" addrspec 9012 <inet> <remote-process> send-with-check
     [ first2 addrspec vocabspec define-remote ] each
   ] unless ;

: remote-load ( addr vocabspec -- voabspec ) [ swap
    "loads-thread" swap 9012 <inet> <remote-process> send-synchronous ] keep [ dictionary get-global set-at ] keep ;