! Copyright (C) 2007 Chris Double. All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
!
! Wrap a sniffer in a channel
USING: kernel channels io io.backend io.sniffer
io.sniffer.backend system vocabs.loader ;

: (sniff-channel) ( stream channel -- ) 
  4096 pick stream-read-partial over to (sniff-channel) ;

bsd? [ "channels.sniffer.bsd" require ] when
