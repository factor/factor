! Copyright (C) 2009, 2010 Phil Dawes, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: classes.struct alien.c-types alien.syntax kernel.private ;
IN: vm

TYPEDEF: uintptr_t cell

STRUCT: context
{ callstack-top void* }
{ callstack-bottom void* }
{ datastack cell }
{ retainstack cell }
{ callstack-save cell }
{ datastack-region void* }
{ retainstack-region void* }
{ callstack-region void* }
{ context-objects cell[context-object-count] } ;

: context-field-offset ( field -- offset ) context offset-of ; inline

STRUCT: zone
{ here cell }
{ start cell }
{ end cell }
{ size cell } ;

STRUCT: vm
{ ctx context* }
{ spare-ctx context* }
{ nursery zone }
{ cards-offset cell }
{ decks-offset cell }
{ signal-handler-addr cell }
{ faulting? cell }
{ special-objects cell[special-object-count] } ;

: vm-field-offset ( field -- offset ) vm offset-of ; inline

CONSTANT: collect-nursery-op 0
CONSTANT: collect-aging-op 1
CONSTANT: collect-to-tenured-op 2
CONSTANT: collect-full-op 3
CONSTANT: collect-compact-op 4
CONSTANT: collect-growing-heap-op 5

STRUCT: copying-sizes
{ size cell }
{ occupied cell }
{ free cell } ;

STRUCT: mark-sweep-sizes
{ size cell }
{ occupied cell }
{ total-free cell }
{ contiguous-free cell }
{ free-block-count cell } ;

STRUCT: data-heap-room
{ nursery copying-sizes }
{ aging copying-sizes }
{ tenured mark-sweep-sizes }
{ cards cell }
{ decks cell }
{ mark-stack cell } ;

STRUCT: gc-event
{ op uint }
{ data-heap-before data-heap-room }
{ code-heap-before mark-sweep-sizes }
{ data-heap-after data-heap-room }
{ code-heap-after mark-sweep-sizes }
{ cards-scanned cell }
{ decks-scanned cell }
{ code-blocks-scanned cell }
{ start-time ulonglong }
{ total-time cell }
{ card-scan-time cell }
{ code-scan-time cell }
{ data-sweep-time cell }
{ code-sweep-time cell }
{ compaction-time cell }
{ temp-time ulonglong } ;

STRUCT: dispatch-statistics
{ megamorphic-cache-hits cell }
{ megamorphic-cache-misses cell }

{ cold-call-to-ic-transitions cell }
{ ic-to-pic-transitions cell }
{ pic-to-mega-transitions cell }

{ pic-tag-count cell }
{ pic-tuple-count cell } ;

! gc-info should be kept in sync with:
!   vm/gc_info.hpp
STRUCT: gc-info
    { scrub-d-count uint read-only }
    { scrub-r-count uint read-only }
    { check-d-count uint read-only }
    { check-r-count uint read-only }
    { gc-root-count uint read-only }
    { derived-root-count uint read-only }
    { return-address-count uint read-only } ;
