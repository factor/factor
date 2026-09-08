USING: accessors alien.c-types alien.libraries alien.syntax arrays
assocs compiler.cfg.linear-scan.ranges
compiler.cfg.register-allocation.occupancy io json kernel locals math
namespaces sequences tools.time vectors ;
IN: interference-query-comparison
<< "allocator-counters" "/Users/erg/factor.worktrees/allocator-benchmarks/reference/allocator-benchmarks-20260908/counters.dylib" cdecl add-library >>
LIBRARY: allocator-counters
FUNCTION: ulonglong compiler_instructions ( )
FUNCTION: double compiler_cpu_seconds ( )
FUNCTION: int compiler_background ( )
SYMBOLS: assigned indexes probes ;
:: setup ( -- )
    8 [ <register-occupancy> ] replicate indexes set
    512 <iota> [| owner |
        owner 8 /i 16 * :> start
        start start 2 + 2array start 6 + start 8 + 2array 2array :> ranges
        owner 8 mod :> reg
        owner ranges reg indexes get nth occupy-ranges
        reg ranges owner 3array
    ] map assigned set
    assigned get probes set ;
:: reference-query ( probe -- owners )
    assigned get [| entry |
        entry first probe first = [
            entry second probe second intersect-ranges
        ] [ f ] if
    ] filter [ third ] map ;
: indexed-query ( probe -- owners )
    [ second ] [ first indexes get nth ] bi occupancy-conflicts ;
:: sample ( label quot: ( probe -- owners ) -- )
    compiler_background :> background-before
    compiler_instructions :> instructions
    compiler_cpu_seconds :> cpu
    [ 100 [ probes get [ quot call drop ] each ] times ] benchmark :> ns
    compiler_cpu_seconds cpu - :> elapsed
    compiler_instructions instructions - :> retired
    compiler_background :> background-after
    H{ { "label" label } { "cpu_seconds" elapsed }
       { "instructions" retired } { "ns" ns }
       { "background_before" background-before }
       { "background_after" background-after } } >json print flush ; inline
setup
probes get [ [ reference-query ] [ indexed-query ] bi = ] all? t assert=
3 [
    "reference" [ reference-query ] sample
    "indexed" [ indexed-query ] sample
] times
