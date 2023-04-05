! Copyright (C) 2013 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING: io kernel libc regexp locals math.parser splitting sequences unix.hosts unix.ps ;

IN: unix.ssh

CONSTANT: ssh-cmd  "ssh "
CONSTANT: ssh-config "~/.ssh/config"

SYMBOL: ssh-host
SYMBOL: ssh-relay 
SYMBOL: ssh-src-port
SYMBOL: ssh-dst-port

: ssh-tunnel-commands ( commands -- ssh-tunnel-commands )
    [ R/ .*ssh .*-L .*:.*:.*/ matches? ] filter ;

: ssh-command-ips ( ssh-tunnel-commands -- ips )
    [ ":" split  second ] map ; 

: ssh-processes ( -- seq )
    "ax" ps-status
    5 head
    { "PID" "COMMAND" } B ps-status-data 
    ssh-tunnel-commands  ;

: ssh-relay+ ( string -- string )  ssh-relay append ;
: ssh-tunnel-prefix ( -- string )  ssh-cmd "-f -N -L " append ;
: ssh-tunnel-proxy ( -- string )  ssh-cmd "-f -N -D " append ;
: ssh-tunnel-reverse ( -- string )  ssh-cmd "-f -N -R " append ; 
: ssh-tunnel-src-port+ ( string ip -- string )  append  ":" append ;
: ssh-tunnel-dst-port+ ( string port -- string )  number>string append ;
: ssh-tunnel-ip+ ( string ip -- string )  append  ":" append ;

:: ssh-tunnel-exists? ( ip port -- ? )
    ssh-processes :> processes
    processes ssh-command-ips ip [ = ] curry find  >boolean :> result
    ;

:: ssh-tunnel ( ip port -- string )
    ssh-tunnel-prefix ip ssh-tunnel-src-port+
    ip ssh-tunnel-ip+  port ssh-tunnel-dst-port+
    ssh-relay+  dup print ;

:: ssh-proxy ( ip -- string )
    ssh-tunnel-proxy 
    ip ssh-tunnel-ip+  ip ssh-dst-port append
    ssh-relay+  print ;

: ssh-tunnel-name ( name port -- )
    over find-ip 
    [ over ssh-tunnel-exists? ] keep
    [ 3drop "Tunnel already established" print ]
    [ swap ssh-tunnel system  -1 over =  swap 127 =  or
      [ "Failed to create tunnel" print ] when  drop
    ] if ;

: ssh-proxy-name ( x name -- )
    find-ip dup
    ssh-tunnel-exists?
    [ drop "Tunnel already established" print ]
    [ ssh-proxy system  -1 over =  swap 127 =  or
      [ "Failed to create tunnel" print ] when  
    ] if ;

: ssh-name ( name -- )
    dup 22 ssh-tunnel
    ssh-cmd over ".wwiiol" append  append
    swap  find-ip ssh-dst-port " -p" prepend
    append  dup  "echo " prepend  "|pbcopy" append system drop
    print 2drop ;

: ssh-number ( number -- )
    find-number ssh-name ;

