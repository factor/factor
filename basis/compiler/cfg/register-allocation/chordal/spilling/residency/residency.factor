! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays assocs kernel locals math math.order sequences sets
sorting ;
IN: compiler.cfg.register-allocation.chordal.spilling.residency

! A pressure decision precedes every instruction. Protected operands cannot
! be displaced; dead residents go first, then the farthest reachable use.
! Ties use the SSA number to make witnesses and generated code repeatable.
ERROR: impossible-register-pressure demanded capacity ;

:: eviction-priority ( value distances -- priority )
    value distances at [ 0 swap value 3array ] [ 1 0 value 3array ] if* ;

:: pressure-victims ( residents demanded distances capacity -- victims )
    demanded members :> protected
    protected length capacity >
    [ protected capacity impossible-register-pressure ] when
    residents protected union length capacity - 0 max :> excess
    excess zero? [ { } ] [
        residents protected diff
        [ distances eviction-priority ] sort-by <reversed>
        excess head
    ] if ;

! W records register-resident values; S records values whose home is valid.
! Eviction needs a store only for a still-live value absent from S. This is
! independent of its physical register, which is selected much later.
:: eviction-stores ( victims saved distances -- stores )
    victims [| value | value distances key? value saved in? not and ] filter ;

! At a join, keep values resident on every predecessor first. The remaining
! budget favors nearer uses, including the loop-exit distance penalty. A
! caller passes only values live at entry, and removes unused loop-through
! values when measured loop pressure leaves them no room.
:: entry-priority ( value all-resident distances -- priority )
    value all-resident in? 0 1 ?
    value distances at 1/0. or value 3array ;

:: select-entry-residents ( candidates all-resident distances capacity -- residents )
    candidates members [ all-resident distances entry-priority ] sort-by
    capacity over length min head ;

! Edge coupling uses the actual predecessor W/S state, not a layout guess.
! Stores precede reloads so a reload cannot destroy the only source of a
! value needed in memory by the successor.
:: edge-transfers ( outgoing saved incoming required-memory -- stores reloads )
    required-memory saved diff outgoing intersect
    incoming outgoing diff ;
