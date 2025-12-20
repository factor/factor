! Copyright (C) 2013 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators combinators.smart
io.encodings.utf8 io.files kernel math math.order math.parser
memoize sequences sorting.specification splitting
splitting.monotonic strings io.pathnames calendar words ;
IN: unix.linux.proc

! /proc/*

! /proc/buddyinfo
! /proc/cgroups

TUPLE: proc-cmdline string ;
C: <proc-cmdline> proc-cmdline
: parse-proc-cmdline ( -- obj )
    "/proc/cmdline" utf8 file-lines first <proc-cmdline> ;


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
    { fdiv-bug? boolean }
    { hlt-bug? boolean }
    { f00f-bug? boolean }
    { coma-bug? boolean }
    { physical-id integer }
    { siblings integer }
    { core-id integer }
    { cpu-cores integer }
    { apicid integer }
    { initial-apicid integer }
    { fpu? boolean }
    { fpu-exception? boolean }
    { cpuid-level integer }
    { wp? boolean }
    { flags array }
    { bogomips number }
    { clflush-size integer }
    { cache-alignment integer }
    { address-sizes array }
    { power-management string }
    { tlb-size string }
    { bugs string }
    { vmx-flags string } ;


ERROR: unknown-cpuinfo-line string ;

: line>processor-info ( processor-info string -- processor-info )
    ":" split first2 swap
    [ CHAR: \t = ] trim-tail [ [ CHAR: \s = ] trim ] bi@
    {
        { "address sizes" [
            "," split [ [ CHAR: \s = ] trim split-words first string>number ] map
            >>address-sizes
        ] }
        { "apicid" [ string>number >>apicid ] }
        { "bogomips" [ string>number >>bogomips ] }
        { "BogoMIPS" [ string>number >>bogomips ] }
        { "bugs" [ >>bugs ] }
        { "cache size" [
            split-words first [ CHAR: \s = ] trim
            string>number 1024 * >>cache-size
        ] }
        { "cache_alignment" [ string>number >>cache-alignment ] }
        { "clflush size" [ string>number >>clflush-size ] }
        { "coma_bug" [ "yes" = >>coma-bug? ] }
        { "core id" [ string>number >>core-id ] }
        { "cpu MHz" [ string>number >>cpu-mhz ] }
        { "CPU architecture" [ drop ] }
        { "cpu cores" [ string>number >>cpu-cores ] }
        { "cpu family" [ string>number >>cpu-family ] }
        { "CPU implementer" [ drop ] }
        { "CPU revision" [ drop ] }
        { "CPU part" [ drop ] }
        { "CPU variant" [ drop ] }
        { "cpuid level" [ string>number >>cpuid-level ] }
        { "f00f_bug" [ "yes" = >>f00f-bug? ] }
        { "fdiv_bug" [ "yes" = >>fdiv-bug? ] }
        { "Features" [ split-words harvest >>flags ] }
        { "flags" [ split-words harvest >>flags ] }
        { "fpu" [ "yes" = >>fpu? ] }
        { "fpu_exception" [ "yes" = >>fpu-exception? ] }
        { "hlt_bug" [ "yes" = >>hlt-bug? ] }
        { "initial apicid" [ string>number >>initial-apicid ] }
        { "microcode" [ string>number >>microcode ] }
        { "model" [ string>number >>model ] }
        { "model name" [ >>model-name ] }
        { "physical id" [ string>number >>physical-id ] }
        { "power management" [ >>power-management ] }
        { "processor" [ string>number >>processor ] }
        { "siblings" [ string>number >>siblings ] }
        { "stepping" [ string>number >>stepping ] }
        { "TLB size" [ >>tlb-size ] }
        { "vendor_id" [ >>vendor-id ] }
        { "vmx flags" [ >>vmx-flags ] }
        { "wp" [ "yes" = >>wp? ] }
        [ unknown-cpuinfo-line ]
    } case ;


! Linux 2.6 has fewer values than new kernels
: lines>processor-info ( strings -- processor-info )
    [ processor-info new ] dip
    [ line>processor-info ] each ;

: parse-proc-cpuinfo ( -- seq )
    "/proc/cpuinfo" utf8 file-lines
    { "" } split harvest [ lines>processor-info ] map ;

: sort-cpus ( seq -- seq )
    { { physical-id>> <=> } { core-id>> <=> } } sort-with-spec
    [ [ physical-id>> ] bi@ = ] monotonic-split
    [ [ [ core-id>> ] bi@ = ] monotonic-split ] map ;

: cpu-counts ( seq -- #cpus #cores #hyperthread )
    [ length ]
    [ [ length ] map-sum ]
    [ [ [ length ] map-sum ] map-sum ] tri ;


TUPLE: proc-loadavg
    load-average-1
    load-average-5
    load-average-15
    #processes-executing
    #processes-total
    last-pid ;

: parse-proc-loadavg ( -- obj )
    "/proc/loadavg" utf8 file-lines first
    split-words [
        {
            [ string>number ]
            [ string>number ]
            [ string>number ]
            [ "/" split1 [ string>number ] bi@ ]
            [ string>number ]
        } spread
    ] input<sequence proc-loadavg boa ;


! In the file as kb, convert to bytes
TUPLE: proc-meminfo
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

! Different kernels have fewer fields. Make sure we have enough.
: parse-proc-meminfo ( -- meminfo )
    "/proc/meminfo" utf8 file-lines
    [ split-words harvest second string>number 1024 * ] map
    proc-meminfo "slots" word-prop length f pad-tail
    [ proc-meminfo boa ] input<sequence ;

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

TUPLE: proc-cpu-stat name user nice system idle iowait irq softirq steal guest guest-nice ;

: line>cpu ( string -- cpu )
    split-words
    unclip-slice
    [ [ [ CHAR: \s = ] trim string>number ] map ] dip prefix
    [ proc-cpu-stat boa ] input<sequence ;

: parse-proc-stat ( -- obj )
    "/proc/stat" utf8 file-lines
    [ first ] [ 7 head* rest ] [ 7 tail* ] tri 3array {
        [ first line>cpu ]
        [ second [ line>cpu ] map ]
        [
            third
            [ " " split1 nip split-words [ string>number ] map ] map
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

TUPLE: proc-partition major minor #blocks name ;

: parse-proc-partitions ( -- partitions )
    "/proc/partitions" utf8 file-lines 2 tail
    [
        " \t" split harvest
        [
            {
                [ string>number ]
                [ string>number ]
                [ string>number ]
                [ ]
            } spread
        ] input<sequence proc-partition boa
    ] map ;

TUPLE: proc-swap filename type size used priority ;

: parse-proc-swaps ( -- sequence )
    "/proc/swaps" utf8 file-lines rest
    [
        " \t" split harvest
        [
            {
                [ ]
                [ ]
                [ string>number ]
                [ string>number ]
                [ string>number ]
            } spread
        ] input<sequence proc-swap boa
    ] map ;

TUPLE: proc-uptime up idle ;

: parse-proc-uptime ( -- uptime )
    "/proc/uptime" utf8 file-lines first
    split-words first2 [ string>number seconds ] bi@
    proc-uptime boa ;

! /proc/pid/*

GENERIC#: proc-pid-path 1 ( object string -- path )

M: integer proc-pid-path
    [ "/proc/" ] 2dip
    [ number>string "/" append ] dip
    3append ;

M: string proc-pid-path
    [ "/proc/" ] 2dip [ append-path ] dip append-path ;

: proc-file-lines ( path -- strings ) utf8 file-lines ;
: proc-first-line ( path -- string/f ) proc-file-lines ?first ;

: proc-pid-first-line ( pid string -- string )
    proc-pid-path proc-first-line ;

: parse-proc-pid-cmdline ( pid -- string/f )
    "cmdline" proc-pid-path proc-first-line ;

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

: parse-proc-pid-stat ( pid -- stat )
    "stat" proc-pid-path
    proc-first-line
    split-words harvest
    pid-stat "slots" word-prop length "0" pad-tail
    [ [ string>number ] transmute ] map
    [ pid-stat boa ] input<sequence ;
