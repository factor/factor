USING: unix.ffi alien.data alien.c-types classes.struct accessors
kernel locals math io parser ;
IN: namespace.network.proof
:: connect-probe ( host port -- )
    addrinfo new AF_INET >>family SOCK_STREAM >>socktype :> hints
    f void* <ref> :> result
    host port hints result getaddrinfo 0 = [ "DNS failed" throw ] unless
    result void* deref addrinfo memory>struct :> info
    info family>> info socktype>> info protocol>> socket :> fd
    fd info addr>> info addrlen>> connect 0 = [ "connect failed" throw ] unless
    fd close drop
    result void* deref freeaddrinfo
    "Actual Factor/libc outbound TCP PASS" print flush ;
"www.google.se" "80" connect-probe
