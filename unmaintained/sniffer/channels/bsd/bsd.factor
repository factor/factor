! Copyright (C) 2007 Chris Double. All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
!
! Wrap a sniffer in a channel
USING: kernel channels channels.sniffer.backend
threads io io.sniffer.backend io.sniffer.bsd
io.unix.backend ;
IN: channels.sniffer.bsd

M: unix-io sniff-channel ( -- channel ) 
  "/dev/bpf0" "en1" <sniffer-spec> <sniffer> <channel> [
    [
      (sniff-channel) 
    ] 3curry spawn drop
  ] keep ;

