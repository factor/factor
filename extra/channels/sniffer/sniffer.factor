! Copyright (C) 2007 Chris Double. All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
!
! Wrap a sniffer in a channel
USING: kernel channels concurrency io io.backend
io.sniffer system vocabs.loader ;

: (sniff-channel) ( stream channel -- ) 
  4096 pick stream-read-partial over to (sniff-channel) ;

HOOK: sniff-channel io-backend ( -- channel ) 

bsd? [ "channels.sniffer.bsd" require ] when
