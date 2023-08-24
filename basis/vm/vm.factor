! Copyright (C) 2009, 2010 Phil Dawes, Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: classes.struct alien.c-types alien.syntax kernel.private ;
IN: vm

TYPEDEF: uintptr_t cell_t

STRUCT: segment
    { start cell_t }
    { size cell_t }
    { end cell_t } ;

STRUCT: context
    { callstack-top cell_t }
    { callstack-bottom cell_t }
    { datastack cell_t }
    { retainstack cell_t }
    { callstack-save cell_t }
    { datastack-seg segment* }
    { retainstack-seg segment* }
    { callstack-seg segment* }
    { context-objects cell_t[context-object-count] } ;

STRUCT: zone
    { here cell_t }
    { start cell_t }
    { end cell_t }
    { size cell_t } ;

! dispatch-statistics should be kept in sync with:
!   vm/dispatch.hpp
STRUCT: dispatch-statistics
    { megamorphic-cache-hits cell_t }
    { megamorphic-cache-misses cell_t }

    { cold-call-to-ic-transitions cell_t }
    { ic-to-pic-transitions cell_t }
    { pic-to-mega-transitions cell_t }

    { pic-tag-count cell_t }
    { pic-tuple-count cell_t } ;

STRUCT: vm
    { ctx context* }
    { spare-ctx context* }
    { nursery zone }
    { cards-offset cell_t }
    { decks-offset cell_t }
    { signal-handler-addr cell_t }
    { faulting? cell_t }
    { special-objects cell_t[special-object-count] }
    { thread void* }
    { datastack-size cell_t }
    { retainstack-size cell_t }
    { callstack-size cell_t } ;

CONSTANT: COLLECT-NURSERY-OP 0
CONSTANT: COLLECT-AGING-OP 1
CONSTANT: COLLECT-TO-TENURED-OP 2
CONSTANT: COLLECT-FULL-OP 3
CONSTANT: COLLECT-COMPACT-OP 4
CONSTANT: COLLECT-GROWING-DATA-HEAP-OP 5

STRUCT: copying-sizes
{ size cell_t }
{ occupied cell_t }
{ free cell_t } ;

STRUCT: mark-sweep-sizes
{ size cell_t }
{ occupied cell_t }
{ total-free cell_t }
{ contiguous-free cell_t }
{ free-block-count cell_t } ;

STRUCT: data-heap-room
{ nursery copying-sizes }
{ aging copying-sizes }
{ tenured mark-sweep-sizes }
{ cards cell_t }
{ decks cell_t }
{ mark-stack cell_t } ;

CONSTANT: PHASE-CARD-SCAN 0
CONSTANT: PHASE-CODE-SCAN 1
CONSTANT: PHASE-DATA-SWEEP 2
CONSTANT: PHASE-CODE-SWEEP 3
CONSTANT: PHASE-DATA-COMPACTION 4
CONSTANT: PHASE-MARKING 5

! gc-event should be kept in sync with:
!   vm/gc.hpp
STRUCT: gc-event
    { op uint }
    { data-heap-before data-heap-room }
    { code-heap-before mark-sweep-sizes }
    { data-heap-after data-heap-room }
    { code-heap-after mark-sweep-sizes }
    { cards-scanned cell_t }
    { decks-scanned cell_t }
    { code-blocks-scanned cell_t }
    { start-time ulonglong }
    { total-time cell_t }
    { times cell_t[6] }
    { temp-time ulonglong } ;

! gc-info should be kept in sync with:
!   vm/gc_info.hpp
STRUCT: gc-info
    { gc-root-count uint read-only }
    { derived-root-count uint read-only }
    { return-address-count uint read-only } ;

CONSTANT: CODE-BLOCK-UNOPTIMIZED 0
CONSTANT: CODE-BLOCK-OPTIMIZED 1
CONSTANT: CODE-BLOCK-PIC 2
