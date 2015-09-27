! Copyright (C) 2009 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs fry generalizations io.encodings.binary
io.sockets kernel locals namespaces parser sequences serialize
vocabs vocabs.parser words io ;
IN: modules.rpc

TUPLE: rpc-request args vocabspec wordname ;

: send-with-check ( message -- reply/* )
    serialize flush deserialize dup no-vocab? [ throw ] when ;

:: define-remote ( str effect addrspec vocabspec -- )
    str create-word-in effect [ in>> length ] [ out>> length ] bi
    '[ _ narray vocabspec str rpc-request boa addrspec 9012 <inet> binary
    [ "doer" serialize send-with-check ] with-client _ firstn ]
    effect define-declared ;

:: remote-vocab ( addrspec vocabspec -- vocab )
   vocabspec "-remote" append dup vocab [ dup set-current-vocab
     vocabspec addrspec 9012 <inet> binary [ "getter" serialize send-with-check ] with-client
     [ first2 addrspec vocabspec define-remote ] each
   ] unless ;

: remote-load ( addr vocabspec -- voabspec ) [ swap
    9012 <inet> binary [ "loader" serialize serialize flush deserialize ] with-client ] keep
    [ dictionary get-global set-at ] keep ;