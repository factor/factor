! Copyright (C) 2007 Chris Double. All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
!
! Wrap a sniffer in a channel
USING: kernel channels channels.sniffer concurrency io
io.sniffer io.sniffer.bsd io.unix.backend ;

M: unix-io sniff-channel ( -- channel ) 
  "/dev/bpf0" "en1" <sniffer-spec> <sniffer> <channel> [
   (sniff-channel) 
  ] spawn drop nip ;

