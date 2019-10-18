! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces system kernel accessors assocs continuations
unix io.backend io.backend.unix io.backend.unix.multiplexers
io.backend.unix.multiplexers.kqueue io.files.unix ;
IN: io.backend.unix.bsd

M: bsd init-io ( -- )
    <kqueue-mx> mx set-global ;

! M: bsd (monitor) ( path recursive? mailbox -- )
!     swap [ "Recursive kqueue monitors not supported" throw ] when
!     <vnode-monitor> ;
