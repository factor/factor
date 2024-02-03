! Copyright (C) 2018 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.

USING: io.launcher io.standard-paths json kernel literals
namespaces sequences strings system ;

IN: docker

SYMBOL: docker-username
SYMBOL: docker-password

: docker-path ( -- path )
    "docker" find-in-standard-login-path ;

: docker-machine-path ( -- path )
    "docker-machine" find-in-standard-login-path ;

: vboxmanage-path ( -- path )
    "VBoxManage" find-in-standard-login-path ;

: sudo-linux ( seq -- seq' )
    os linux? [ "sudo" prefix ] when ;

: docker-lines ( seq -- lines )
    docker-path prefix sudo-linux process-lines ;

: docker-machine-lines ( seq -- lines )
    docker-machine-path prefix process-lines ;


: docker-command ( seq -- )
    docker-path prefix sudo-linux try-output-process ;

: docker-machine-command ( seq -- )
    docker-machine-path prefix try-output-process ;


: docker-version ( -- string )
    { "version" } docker-lines ;

: docker-machine-version ( -- string )
    { "version" } docker-machine-lines ?first ;



: docker-machine-inspect ( string -- json )
    { "inspect" } swap suffix docker-machine-lines "" join json> ;


: docker-machines ( -- seq )
    { "ls" "-q" } docker-machine-lines ;

: docker-machine-status ( string -- status )
    { "status" } swap suffix docker-machine-lines ;


: docker-image-names ( -- seq )
    { "image" "ls" "-q" } docker-lines ;

: docker-image-ls ( -- seq )
    { "image" "ls" } docker-lines ;

: docker-login ( -- )
    ${
        "sudo"
        docker-path "login"
        "-p" docker-password get-global
        "-u" docker-username get-global
    } try-process ;

GENERIC: docker-pull ( obj -- )

M: string docker-pull ( string -- )
    { "pull" } swap suffix docker-command ;

M: sequence docker-pull ( seq -- )
    [ docker-pull ] each ;

: docker-hello-world ( -- )
    { "run" "hello-world" } docker-command ;
