! Copyright (C) 2009, 2010 Phil Dawes, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
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

CONSTANT: collect-nursery-op 0
CONSTANT: collect-aging-op 1
CONSTANT: collect-to-tenured-op 2
CONSTANT: collect-full-op 3
CONSTANT: collect-compact-op 4
CONSTANT: collect-growing-heap-op 5

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
{ card-scan-time cell_t }
{ code-scan-time cell_t }
{ data-sweep-time cell_t }
{ code-sweep-time cell_t }
{ compaction-time cell_t }
{ temp-time ulonglong } ;

! gc-info should be kept in sync with:
!   vm/gc_info.hpp
STRUCT: gc-info
    { scrub-d-count uint read-only }
    { scrub-r-count uint read-only }
    { gc-root-count uint read-only }
    { derived-root-count uint read-only }
    { return-address-count uint read-only } ;
