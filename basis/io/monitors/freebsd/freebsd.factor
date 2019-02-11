USING: kernel io.backend io.monitors io.monitors.recursive
io.files io.pathnames io.buffers io.ports io.timeouts
io.backend.unix io.encodings.utf8 assocs namespaces make
sequences locals system destructors accessors ;
IN: io.monitors.freebsd

TUPLE: freebsd-monitor < monitor handle ;

M:: freebsd (monitor) ( path recursive? mailbox -- monitor )
    path normalize-path :> path
    path mailbox freebsd-monitor new-monitor ;

M: freebsd-monitor dispose*
    [ handle>> dispose ] [ call-next-method ] bi ;

freebsd set-io-backend
