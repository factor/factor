USING: alien.syntax ;
IN: unix

: FD_SETSIZE 1024 ; inline

C-STRUCT: addrinfo
    { "int" "flags" }
    { "int" "family" } 
    { "int" "socktype" }
    { "int" "protocol" }
    { "socklen_t" "addrlen" }
    { "char*" "canonname" }
    { "void*" "addr" }
    { "addrinfo*" "next" } ;

C-STRUCT: passwd
    { "char*"  "pw_name" }
    { "char*"  "pw_passwd" }
    { "uid_t"  "pw_uid" }
    { "gid_t"  "pw_gid" }
    { "time_t" "pw_change" }
    { "char*"  "pw_class" }
    { "char*"  "pw_gecos" }
    { "char*"  "pw_dir" }
    { "char*"  "pw_shell" }
    { "time_t" "pw_expire" }
    { "int"    "pw_fields" } ;
