! Diagnostic only: run against the chosen source/image before or after the fix.
! Captures immutable interval records and each interval-expiry store, with
! the actual final machine IR. No allocation decisions are changed here.
USING: accessors arrays assocs combinators compiler.cfg
compiler.cfg.instructions compiler.cfg.linear-scan.allocation.state
compiler.cfg.linear-scan.assignment compiler.cfg.linear-scan.checker
compiler.cfg.linear-scan.live-intervals compiler.cfg.linear-scan.numbering
compiler.cfg.linear-scan.resolve compiler.cfg.linearization
compiler.cfg.register-allocation compiler.cfg.register-allocation.greedy
compiler.cfg.register-allocation.rematerialization
compiler.cfg.register-allocation.verifier compiler.cfg.registers
compiler.cfg.ssa.destruction compiler.cfg.utilities compiler.units
io json kernel kernel.private locals math math.private namespaces prettyprint
sequences tools.test vectors words ;
IN: allocator-greedy-provenance

SYMBOLS: provenance-records current-provenance ;

:: use-record ( use -- record )
    H{ } clone :> record
    use n>> "n" record set-at
    use def-rep>> unparse "def-rep" record set-at
    use use-rep>> unparse "use-rep" record set-at
    use spill-slot?>> >boolean "spill-slot?" record set-at
    record ;

:: interval-record ( interval -- record )
    H{ } clone :> record
    interval vreg>> "vreg" record set-at
    interval reg>> unparse "reg" record set-at
    interval ranges>> [ clone ] map "ranges" record set-at
    interval uses>> [ use-record ] map "uses" record set-at
    interval reload-from>> unparse "reload-from" record set-at
    interval spill-to>> unparse "spill-to" record set-at
    interval reload-rep>> unparse "reload-rep" record set-at
    interval spill-rep>> unparse "spill-rep" record set-at
    record ;

:: record-expiry-store ( interval -- )
    current-provenance get [| record |
        interval interval-record :> store
        basic-block get number>> "block" store set-at
        store "emitted-stores" record at push
    ] when* ;

! This is the production insert-spill body with a diagnostic notification.
IN: compiler.cfg.linear-scan.assignment
USE: allocator-greedy-provenance
: insert-spill ( live-interval -- )
    dup record-expiry-store
    [ reg>> ] [ spill-rep>> ] [ spill-to>> ] tri emit-save ;

IN: allocator-greedy-provenance
SINGLETON: provenance-allocator

:: capture-greedy ( graph -- )
    H{ } clone :> record
    graph word>> unparse "word" record set-at
    V{ } clone "emitted-stores" record set-at
    record current-provenance set
    graph destruct-ssa graph number-instructions graph prepare-greedy-regions
    graph compute-live-intervals :> original
    original required-register-uses :> required
    original [ live-interval-state? ] filter [ interval-record ] map
    "original" record set-at
    graph linearization-order [| block |
        block number>> block instructions>> [ unparse ] map 2array
    ] map "before" record set-at
    original graph admissible-registers greedy-allocate-intervals :> intervals
    intervals graph admissible-registers check-allocated-intervals
    intervals required check-register-uses
    intervals [ interval-record ] map "allocated" record set-at
    graph intervals assign-registers graph resolve-data-flow graph check-numbering
    graph linearization-order [| block |
        block number>> block instructions>> [ unparse ] map 2array
    ] map "after" record set-at
    greedy-allocator allocator-statistics "allocation" record set-at
    record provenance-records get push
    f current-provenance set ;

M: provenance-allocator allocate-cfg drop capture-greedy ;
M: provenance-allocator allocator-statistics drop greedy-allocator allocator-statistics ;

:: integer-pressure ( x -- value )
    x { fixnum } declare :> y
    y 1 fixnum+fast :> a1
    y 2 fixnum+fast :> a2
    y 3 fixnum+fast :> a3
    y 4 fixnum+fast :> a4
    y 5 fixnum+fast :> a5
    y 6 fixnum+fast :> a6
    y 7 fixnum+fast :> a7
    y 8 fixnum+fast :> a8
    y 9 fixnum+fast :> a9
    y 10 fixnum+fast :> a10
    y 11 fixnum+fast :> a11
    y 12 fixnum+fast :> a12
    y 13 fixnum+fast :> a13
    y 14 fixnum+fast :> a14
    y 15 fixnum+fast :> a15
    y 16 fixnum+fast :> a16
    y 17 fixnum+fast :> a17
    y 18 fixnum+fast :> a18
    y 19 fixnum+fast :> a19
    y 20 fixnum+fast :> a20
    y 21 fixnum+fast :> a21
    y 22 fixnum+fast :> a22
    y 23 fixnum+fast :> a23
    y 24 fixnum+fast :> a24
    y 25 fixnum+fast :> a25
    y 26 fixnum+fast :> a26
    y 27 fixnum+fast :> a27
    y 28 fixnum+fast :> a28
    y 29 fixnum+fast :> a29
    y 30 fixnum+fast :> a30
    y 31 fixnum+fast :> a31
    y 32 fixnum+fast :> a32
    y 33 fixnum+fast :> a33
    y 34 fixnum+fast :> a34
    y 35 fixnum+fast :> a35
    y 36 fixnum+fast :> a36
    y 37 fixnum+fast :> a37
    y 38 fixnum+fast :> a38
    y 39 fixnum+fast :> a39
    y 40 fixnum+fast :> a40
    a1
    a2 fixnum+fast
    a3 fixnum+fast
    a4 fixnum+fast
    a5 fixnum+fast
    a6 fixnum+fast
    a7 fixnum+fast
    a8 fixnum+fast
    a9 fixnum+fast
    a10 fixnum+fast
    a11 fixnum+fast
    a12 fixnum+fast
    a13 fixnum+fast
    a14 fixnum+fast
    a15 fixnum+fast
    a16 fixnum+fast
    a17 fixnum+fast
    a18 fixnum+fast
    a19 fixnum+fast
    a20 fixnum+fast
    a21 fixnum+fast
    a22 fixnum+fast
    a23 fixnum+fast
    a24 fixnum+fast
    a25 fixnum+fast
    a26 fixnum+fast
    a27 fixnum+fast
    a28 fixnum+fast
    a29 fixnum+fast
    a30 fixnum+fast
    a31 fixnum+fast
    a32 fixnum+fast
    a33 fixnum+fast
    a34 fixnum+fast
    a35 fixnum+fast
    a36 fixnum+fast
    a37 fixnum+fast
    a38 fixnum+fast
    a39 fixnum+fast
    a40 fixnum+fast
    ;

