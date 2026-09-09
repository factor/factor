USING: accessors arrays assocs compiler.cfg compiler.cfg.checker
compiler.cfg.instructions compiler.cfg.memory-optimization
compiler.cfg.memory-optimization.private compiler.cfg.registers compiler.cfg.utilities compiler.test
kernel locals namespaces sequences tools.test ;
IN: compiler.cfg.memory-optimization.tests

: check-memory ( cfg -- changed? )
    dup check-ssa [ eliminate-redundant-loads ] [ check-ssa ] bi ;

! A dominating load survives an ordinary edge; an existing local analysis
! cannot reuse it because that analysis resets its facts at every block.
{ t t 1 } [
    V{ T{ ##peek { dst 0 } { loc D: 0 } }
       T{ ##slot-imm { dst 1 } { obj 0 } { slot 1 } { tag 0 } }
       T{ ##branch } } 0 test-bb
    V{ T{ ##slot-imm { dst 2 } { obj 0 } { slot 1 } { tag 0 } }
       T{ ##branch } } 1 test-bb
    0 1 edge
    0 get block>cfg check-memory
    1 get instructions>> first [ ##copy? ] [ src>> ] bi
] unit-test

! The join needs the same SSA value, not merely the same address key.
! Independently loaded sibling values do not dominate the join.
{ f t } [
    V{ T{ ##peek { dst 0 } { loc D: 0 } } T{ ##branch } } 0 test-bb
    V{ T{ ##slot-imm { dst 1 } { obj 0 } { slot 1 } { tag 0 } }
       T{ ##branch } } 1 test-bb
    V{ T{ ##slot-imm { dst 2 } { obj 0 } { slot 1 } { tag 0 } }
       T{ ##branch } } 2 test-bb
    V{ T{ ##slot-imm { dst 3 } { obj 0 } { slot 1 } { tag 0 } }
       T{ ##branch } } 3 test-bb
    0 { 1 2 } edges 1 3 edge 2 3 edge
    0 get block>cfg check-memory
    3 get instructions>> first ##slot-imm?
] unit-test

! An arbitrary write through another incoming object invalidates both paths
! at the join: the two stack arguments may be exactly the same heap object.
{ f t } [
    V{ T{ ##peek { dst 0 } { loc D: 0 } }
       T{ ##peek { dst 1 } { loc D: 1 } }
       T{ ##peek { dst 2 } { loc D: 2 } }
       T{ ##slot-imm { dst 3 } { obj 0 } { slot 1 } { tag 0 } }
       T{ ##branch } } 0 test-bb
    V{ T{ ##set-slot-imm { src 2 } { obj 1 } { slot 1 } { tag 0 } }
       T{ ##branch } } 1 test-bb
    V{ T{ ##branch } } 2 test-bb
    V{ T{ ##slot-imm { dst 4 } { obj 0 } { slot 1 } { tag 0 } }
       T{ ##branch } } 3 test-bb
    0 { 1 2 } edges 1 3 edge 2 3 edge
    0 get block>cfg check-memory
    3 get instructions>> first ##slot-imm?
] unit-test

! Unknown effects, raw writes, GC, allocation and write barriers all clear
! facts. Boxing must override the otherwise transparent foldable-insn class.
{ t } [
    { ##set-slot ##set-slot-imm ##set-vm-field ##store-memory
      ##store-memory-imm ##call ##call-gc ##alien-invoke ##alien-indirect
      ##alien-assembly ##allot ##box ##box-long-long ##box-alien
      ##box-displaced-alien ##unbox ##unbox-long-long
      ##write-barrier ##write-barrier-imm ##spill }
    [| class |
        H{ { { 0 1 0 } 5 } } clone :> facts
        class new facts update-memory-facts
        facts assoc-empty?
    ] all?
] unit-test

! Slot and tag both contribute to the effective address.
{ f } [
    V{ T{ ##peek { dst 0 } { loc D: 0 } }
       T{ ##slot-imm { dst 1 } { obj 0 } { slot 1 } { tag 0 } }
       T{ ##branch } } 0 test-bb
    V{ T{ ##slot-imm { dst 2 } { obj 0 } { slot 1 } { tag 1 } }
       T{ ##slot-imm { dst 3 } { obj 0 } { slot 2 } { tag 0 } }
       T{ ##branch } } 1 test-bb
    0 1 edge 0 get block>cfg check-memory
] unit-test

! Empty entry facts prevent a backedge from proving its own initial load.
{ f } [
    V{ T{ ##peek { dst 0 } { loc D: 0 } }
       T{ ##slot-imm { dst 2 } { obj 0 } { slot 2 } { tag 0 } }
       T{ ##branch } } 0 test-bb
    V{ T{ ##slot-imm { dst 1 } { obj 0 } { slot 1 } { tag 0 } }
       T{ ##branch } } 1 test-bb
    0 1 edge 1 1 edge
    0 get block>cfg check-memory
] unit-test

! Every path preserves one dominating fact, including a loop without writes.
{ t t } [
    V{ T{ ##peek { dst 0 } { loc D: 0 } }
       T{ ##slot-imm { dst 1 } { obj 0 } { slot 1 } { tag 0 } }
       T{ ##branch } } 0 test-bb
    V{ T{ ##branch } } 1 test-bb
    V{ T{ ##branch } } 2 test-bb
    V{ T{ ##slot-imm { dst 2 } { obj 0 } { slot 1 } { tag 0 } }
       T{ ##branch } } 3 test-bb
    0 { 1 2 } edges 1 { 1 3 } edges 2 3 edge
    0 get block>cfg check-memory
    3 get instructions>> first ##copy?
] unit-test

! A store on the loop backedge invalidates an otherwise dominating load.
{ f t } [
    V{ T{ ##peek { dst 0 } { loc D: 0 } }
       T{ ##peek { dst 1 } { loc D: 1 } }
       T{ ##slot-imm { dst 2 } { obj 0 } { slot 1 } { tag 0 } }
       T{ ##branch } } 0 test-bb
    V{ T{ ##slot-imm { dst 3 } { obj 0 } { slot 1 } { tag 0 } }
       T{ ##branch } } 1 test-bb
    V{ T{ ##set-slot-imm { src 1 } { obj 0 } { slot 1 } { tag 0 } }
       T{ ##branch } } 2 test-bb
    0 1 edge 1 2 edge 2 1 edge
    0 get block>cfg check-memory
    1 get instructions>> first ##slot-imm?
] unit-test
