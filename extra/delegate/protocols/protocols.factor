! Copyright (C) 2007 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: delegate sequences.private sequences assocs prettyprint.sections 
io definitions kernel continuations ;
IN: delegate.protocols

PROTOCOL: sequence-protocol
    clone clone-like like new new-resizable nth nth-unsafe
    set-nth set-nth-unsafe length set-length lengthen ;

PROTOCOL: assoc-protocol
    at* assoc-size >alist set-at assoc-clone-like { assoc-find 1 }
    delete-at clear-assoc new-assoc assoc-like ;

PROTOCOL: stream-protocol
    stream-read1 stream-read stream-read-until dispose
    stream-flush stream-write1 stream-write stream-format
    stream-nl make-span-stream make-block-stream stream-readln
    make-cell-stream stream-write-table ;

PROTOCOL: definition-protocol
    where set-where forget uses redefined*
    synopsis* definer definition ;

PROTOCOL: prettyprint-section-protocol
    section-fits? indent-section? unindent-first-line?
    newline-after?  short-section? short-section long-section
    <section> delegate>block add-section ;
