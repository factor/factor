! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.syntax ascii assocs
byte-arrays io io.encodings.string io.encodings.utf8 io.files
io.streams.byte-array libc kernel sequences splitting strings
system system-info unix unix.linux.proc math unix.users ;
IN: system-info.linux

FUNCTION-ALIAS: (uname)
    int uname ( c-string buf )

: uname ( -- seq )
    65536 <byte-array> [ (uname) io-error ] keep >string
    "\0" split harvest dup length 6 assert= ;

: sysname ( -- string ) 0 uname nth ;
: nodename ( -- string ) 1 uname nth ;
: release ( -- string ) 2 uname nth ;
: version ( -- string ) 3 uname nth ;
: machine ( -- string ) 4 uname nth ;
: domainname ( -- string ) 5 uname nth ;

<PRIVATE

: parse-os-release ( -- assoc )
    "/etc/os-release" utf8 file-lines
    [ [ blank? ] trim ] map harvest
    [ "#" head? ] reject
    [ "=" split1 [ "\"" "" replace ] bi@ ] H{ } map>assoc ;

CONSTANT: ubuntu-code-names H{
    { "26.10" "Stonking Stinkray" }
    { "26.04" "Resolute Raccoon" }
    { "25.10" "Questing Quokka" }
    { "25.04" "Plucky Puffin" }
    { "24.10" "Oracular Oriole" }
    { "24.04" "Noble Numbat" }
    { "23.10" "Mantic Minotaur" }
    { "23.04" "Lunar Lobster" }
    { "22.10" "Kinetic Kudu" }
    { "22.04" "Jammy Jellyfish" }
    { "21.10" "Impish Indri" }
    { "21.04" "Hirsute Hippo" }
    { "20.10" "Groovy Gorilla" }
    { "20.04" "Focal Fossa" }
    { "19.10" "Eoan Ermine" }
    { "19.04" "Disco Dingo" }
    { "18.10" "Cosmic Cuttlefish" }
    { "18.04" "Bionic Beaver" }
    { "17.10" "Artful Aardvark" }
    { "17.04" "Zesty Zapus" }
    { "16.10" "Yakkety Yak" }
    { "16.04" "Xenial Xerus" }
    { "15.10" "Wily Werewolf" }
    { "15.04" "Vivid Vervet" }
    { "14.10" "Utopic Unicorn" }
    { "14.04" "Trusty Tahr" }
    { "13.10" "Saucy Salamander" }
    { "13.04" "Raring Ringtail" }
    { "12.10" "Quantal Quetzal" }
    { "12.04" "Precise Pangolin" }
    { "11.10" "Oneiric Ocelot" }
    { "11.04" "Natty Narwhal" }
    { "10.10" "Maverick Meerkat" }
    { "10.04" "Lucid Lynx" }
    { "9.10" "Karmic Koala" }
    { "9.04" "Jaunty Jackalope" }
    { "8.10" "Intrepid Ibex" }
    { "8.04" "Hardy Heron" }
    { "7.10" "Gutsy Gibbon" }
    { "7.04" "Feisty Fawn" }
    { "6.10" "Edgy Eft" }
    { "6.06" "Dapper Drake" }
    { "5.10" "Breezy Badger" }
    { "5.04" "Hoary Hedgehog" }
    { "4.10" "Warty Warthog" }
}

: system-code-name ( -- str/f )
    "/etc/os-release" file-exists? [
        parse-os-release
        dup "ID" of "ubuntu" = [
            "VERSION_ID" of ubuntu-code-names at
        ] [ drop f ] if
    ] [ f ] if ;

PRIVATE>

M: linux os-version release ;
M: linux cpus parse-proc-cpuinfo sort-cpus cpu-counts 2drop ;
: cores ( -- n ) parse-proc-cpuinfo sort-cpus cpu-counts drop nip ;
: hyperthreads ( -- n ) parse-proc-cpuinfo sort-cpus cpu-counts 2nip ;
M: linux cpu-mhz parse-proc-cpuinfo first cpu-mhz>> 1,000,000 * ;
M: linux physical-mem parse-proc-meminfo mem-total>> ;
M: linux computer-name nodename ;
M: linux username real-user-name ;
