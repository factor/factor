! Copyright (C) 2019 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test resolv-conf ;
IN: resolv-conf.tests
{
    T{ resolv.conf
        { nameserver V{ "127.0.0.53" } }
        { domain V{ } }
        { lookup V{ } }
        { search V{ "localdomain" } }
        { sortlist V{ } }
        { options T{ options { edns0? t } } }
    }
} [
    "nameserver 127.0.0.53
    options edns0
    search localdomain" string>resolv.conf
] unit-test

