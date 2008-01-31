! Copyright (C) 2007 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: delegate sequences.private sequences assocs prettyprint.sections 
io definitions kernel ;
IN: delegate.protocols

PROTOCOL: sequence-protocol
    clone clone-like like new new-resizable nth nth-unsafe
    set-nth set-nth-unsafe length set-length lengthen ;

PROTOCOL: assoc-protocol
    at* assoc-size >alist set-at assoc-clone-like
    delete-at clear-assoc new-assoc assoc-like ;
    ! assoc-find excluded because GENERIC# 1
    ! everything should work, just slower (with >alist)

PROTOCOL: stream-protocol
    stream-read1 stream-read stream-read-until
    stream-flush stream-write1 stream-write stream-format
    stream-nl make-span-stream make-block-stream stream-readln
    make-cell-stream stream-write-table set-timeout ;

PROTOCOL: definition-protocol
    where set-where forget uses redefined*
    synopsis* definer definition ;

PROTOCOL: prettyprint-section-protocol
    section-fits? indent-section? unindent-first-line?
    newline-after?  short-section? short-section long-section
    <section> delegate>block add-section ;


