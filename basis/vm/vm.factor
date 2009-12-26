! Copyright (C) 2009 Phil Dawes.
! See http://factorcode.org/license.txt for BSD license.
USING: classes.struct alien.c-types alien.syntax ;
IN: vm

TYPEDEF: uintptr_t cell

STRUCT: context
{ callstack-top void* }
{ callstack-bottom void* }
{ datastack cell }
{ callstack cell }
{ magic-frame void* }
{ datastack-region void* }
{ retainstack-region void* }
{ catchstack-save cell }
{ current-callback-save cell }
{ next context* } ;

: context-field-offset ( field -- offset ) context offset-of ; inline

STRUCT: zone
{ start cell }
{ here cell }
{ size cell }
{ end cell } ;

STRUCT: vm
{ ctx context* }
{ nursery zone }
{ cards-offset cell }
{ decks-offset cell }
{ userenv cell[70] } ;

: vm-field-offset ( field -- offset ) vm offset-of ; inline

C-ENUM:
collect-nursery-op
collect-aging-op
collect-to-tenured-op
collect-full-op
collect-compact-op
collect-growing-heap-op ;

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
