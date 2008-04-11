! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io.unix.bsd
USING: namespaces system kernel accessors assocs continuations
unix
io.backend io.unix.backend io.unix.select io.unix.kqueue io.monitors ;

M: bsd init-io ( -- )
    <select-mx> mx set-global
    <kqueue-mx> kqueue-mx set-global
    kqueue-mx get-global <mx-port> <mx-task>
    dup io-task-fd
    [ mx get-global reads>> set-at ]
    [ mx get-global writes>> set-at ] 2bi ;

M: bsd init-monitors ;

M: bsd dispose-monitors ;

M: bsd (monitor) ( path recursive? mailbox -- )
    nip <vnode-monitor> ;
