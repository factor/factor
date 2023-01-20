! Copyright (C) 2007 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: assocs delegate deques io sequences sequences.private
sets ;
IN: delegate.protocols

PROTOCOL: sequence-protocol
like new-sequence new-resizable nth nth-unsafe
set-nth set-nth-unsafe length set-length
lengthen ;

PROTOCOL: assoc-protocol
at* assoc-size >alist set-at assoc-clone-like
delete-at clear-assoc new-assoc assoc-like ;

PROTOCOL: deque-protocol
push-front* push-back* peek-front* peek-back* pop-front*
pop-back* delete-node deque-member?  clear-deque deque-empty? ;

PROTOCOL: set-protocol
adjoin ?adjoin in? delete ?delete set-like fast-set members
union intersect intersects? diff subset? set= duplicates
all-unique? null? cardinality clear-set ;

PROTOCOL: input-stream-protocol
stream-read1 stream-read-unsafe stream-read-partial-unsafe
stream-readln stream-read-until stream-contents* ;

PROTOCOL: output-stream-protocol
stream-flush stream-write1 stream-write stream-nl ;
