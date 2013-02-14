! Copyright (C) 2013 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators combinators.smart
io.encodings.utf8 io.files kernel math math.order math.parser
memoize sequences sorting.slots splitting splitting.monotonic
strings ;
IN: unix.linux.proc

! /proc/*

! /proc/buddyinfo
! /proc/cgroups
! /proc/cmdline

TUPLE: proc-cmdline string ;
C: <proc-cmdline> proc-cmdline
: parse-proc-cmdline ( -- obj )
    "/proc/cmdline" utf8 file-lines first <proc-cmdline> ;


! /proc/consoles

! /proc/cpuinfo
TUPLE: processor-info
    { processor integer }
    { vendor-id string }
    { cpu-family integer }
    { model integer }
    { model-name string }
    { stepping integer }
    { microcode integer }
    { cpu-mhz number }
    { cache-size integer }
    { physical-id integer }
    { siblings integer }
    { core-id integer }
    { cpu-cores integer }
    { apicid integer }
    { initial-apicid integer }
    { fpu string }
    { fpu-expception string }
    { cpuid-level integer }
    { wp string }
    { flags array }
    { bogomips number }
    { clflush-size integer }
    { cache-alignent integer }
    { address-sizes array }
    { power-management string } ;

: lines>processor-info ( strings -- processor-info )
    [ ":" split second [ CHAR: \s = ] trim ] map
    [
        {
            [ string>number ]
            [ ]
            [ string>number ]
            [ string>number ]
            [ ]
            [ string>number ]
            [ string>number ]
            [ string>number ]
            [ " " split first [ CHAR: \s = ] trim string>number 1024 * ]
            [ string>number ]
            [ string>number ]
            [ string>number ]
            [ string>number ]
            [ string>number ]
            [ string>number ]
            [ ]
            [ ]
            [ string>number ]
            [ ]
            [ " " split harvest ]
            [ string>number ]
            [ string>number ]
            [ string>number ]
            [ "," split [ [ CHAR: \s = ] trim " " split first string>number ] map ]
            [ ]
        } spread
    ] input<sequence processor-info boa ;

MEMO: parse-proc-cpuinfo ( -- seq )
    "/proc/cpuinfo" utf8 file-lines { "" } split harvest [ lines>processor-info ] map ;

: sort-cpus ( seq -- seq )
    { { physical-id>> <=> } { core-id>> <=> } } sort-by
    [ [ physical-id>> ] bi@ = ] monotonic-split
    [ [ [ core-id>> ] bi@ = ] monotonic-split ] map ;

: cpu-counts ( seq -- #cpus #cores #hyperthread )
    [ length ]
    [ [ length ] map-sum ]
    [ [ [ length ] map-sum ] map-sum ] tri ;


! /proc/loadavg
TUPLE: proc-loadavg
    load-average-1
    load-average-5
    load-average-15
    #processes-executing
    #processes-total
    last-pid ;

: parse-proc-loadavg ( -- obj )
    "/proc/loadavg" utf8 file-lines first
    " " split [
        {
            [ string>number ]
            [ string>number ]
            [ string>number ]
            [ "/" split1 [ string>number ] bi@ ]
            [ string>number ]
        } spread
    ] input<sequence proc-loadavg boa ;


! /proc/meminfo
! In the file as kb, convert to bytes
TUPLE: meminfo
    mem-total
    mem-free
    buffers
    cached
    swap-cached
    active
    inactive
    active-anon
    inactive-anon
    active-file
    inactive-file
    unevictable
    mlocked
    swap-total
    swap-free
    dirty
    writeback
    anon-pages
    mapped
    shmem
    slab
    s-reclaimable
    s-unreclaimable
    kernel-stack
    page-tables
    nfs-unstable
    bounce
    writeback-tmp
    commit-limit
    committed-as
    vmalloc-total
    vmalloc-used
    vmalloc-chunk
    hardware-corrupted
    anon-huge-pages
    huge-pages-total
    huge-pages-free
    huge-pages-rsvd
    huge-pages-surp
    huge-page-size
    direct-map-4k
    direct-map-2m ;

: parse-proc-meminfo ( -- meminfo )
    "/proc/meminfo" utf8 file-lines [
        " " split harvest second string>number 1024 *
    ] map [ meminfo boa ] input<sequence ;

! /proc/stat
! All cpu-stat fields are measured in jiffies.

TUPLE: proc-stat
    cpu
    cpus
    intr
    ctxt
    btime
    processes
    procs-running
    procs-blocked
    softirq ;

TUPLE: cpu-stat name user nice system idle iowait irq softirq steal guest guest-nice ;

: line>cpu ( string -- cpu )
    " " split
    unclip-slice
    [ [ [ CHAR: \s = ] trim string>number ] map ] dip prefix
    [ cpu-stat boa ] input<sequence ;

: parse-proc-stat ( -- obj )
    "/proc/stat" utf8 file-lines
    [ first ] [ 7 head* rest ] [ 7 tail* ] tri 3array {
        [ first line>cpu ]
        [ second [ line>cpu ] map ]
        [
            third
            [ " " split1 nip " " split [ string>number ] map ] map
            [
                {
                    [ ]
                    [ first ]
                    [ first ]
                    [ first ]
                    [ first ]
                    [ first ]
                    [ ]
                } spread
            ] input<sequence
        ]
    } cleave proc-stat boa ;

: active-cpus ( -- n )
    parse-proc-stat procs-running>> ;

! /proc/partitions

! /proc/swaps

! /proc/pid/*

: proc-pid-path ( pid string -- path )
    [ "/proc/" ] 2dip
    [ number>string "/" append ] dip
    3append ;

: proc-pid-first-line ( pid string -- string )
    proc-pid-path utf8 file-lines first ;

: proc-pid-cmdline ( pid -- string )
    "cmdline" proc-pid-first-line ;

TUPLE: pid-stat pid filename state parent-pid group-id session-id terminal#
    terminal-group-id task-flags
    #minor-page-faults #minor-page-faults-child
    #major-page-faults #major-page-faults-child
    cpu-user cpu-kernel
    cpu-user-children cpu-kernel-children
    priority
    niceness
    #threads
    zero0
    nanos-since-boot
    virtual-memory
    resident-set-size resident-set-limit
    start-address end-address stack-start-address
    current-stack-pointer current-instruction-pointer
    pending-signals blocked-signals ignored-signals
    handled-signals
    wait-address
    zero1
    zero2
    exit-signal
    task-cpu
    realtime-policy
    policy
    blkio-ticks
    guest-time children-guest-time
    start-data end-data
    start-brk
    arg-start arg-end
    env-start env-end
    exit-code ;

: proc-pid-stat ( pid -- stat )
    "stat" proc-pid-first-line " " split harvest
    [ dup string>number [ nip ] when* ] map
    [ pid-stat boa ] input<sequence ;
