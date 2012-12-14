! Copyright (C) 2007 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: delegate sequences.private sequences assocs io ;
IN: delegate.protocols

PROTOCOL: sequence-protocol
like new-sequence new-resizable nth nth-unsafe
set-nth set-nth-unsafe length set-length
lengthen ;

PROTOCOL: assoc-protocol
at* assoc-size >alist set-at assoc-clone-like
delete-at clear-assoc new-assoc assoc-like ;

PROTOCOL: input-stream-protocol
stream-read1 stream-read-unsafe stream-read-partial-unsafe
stream-readln stream-read-until stream-contents* ;

PROTOCOL: output-stream-protocol
stream-flush stream-write1 stream-write stream-nl ;
