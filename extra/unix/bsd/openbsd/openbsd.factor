USING: alien.syntax ;
IN: unix

: FD_SETSIZE 1024 ; inline

C-STRUCT: addrinfo
    { "int" "flags" }
    { "int" "family" } 
    { "int" "socktype" }
    { "int" "protocol" }
    { "socklen_t" "addrlen" }
    { "void*" "addr" }
    { "char*" "canonname" }
    { "addrinfo*" "next" } ;
