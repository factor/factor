! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax namespaces sequences ;
IN: namespaces.contexts

HELP: namespace-context
{ $class-description "The internal dynamic namespace state stored in the VM context. Scope topology is held separately from a hashtable of binding stacks. Owned frames retain binding cells in journals; caller-supplied or exported assocs are searched live." }
{ $notes "Internal captures share frames, binding values and indexes, but copy scope topology. Index hashtables copy on the first topology mutation; changed binding vectors are copied separately. A shared revision clock invalidates indexes when a captured frame gains a key or exposes its assoc. New keys in uncaptured scopes and changes to existing cell values need no invalidation." } ;

HELP: namespace-frame
{ $class-description "An owned scope's binding journal, or a borrowed scope's live assoc. A frame retains its depth within captured scope topology." }
{ $notes "These flags describe aliasing and mutation, not memory lifetime. borrowed? means the assoc is caller-supplied or publicly exported and must be read live. shared? means a continuation or thread has captured the frame, so new bindings must invalidate other indexes. Factor's garbage collector manages all frames, assocs and binding cells." } ;

HELP: namespace-binding
{ $class-description "A mutable value cell with its variable key and owning scope. A variable's index vector holds these cells in scope order." } ;

HELP: namespace-clock
{ $class-description "A revision clock shared by contexts descended from the same internal capture. It guards indexes against additions to shared frames and assoc exports." } ;

HELP: context-snapshot
{ $values { "context" namespace-context } { "snapshot" namespace-context } }
{ $description "Copies scope topology without materializing frame assocs. Indexes are shared until a scope mutation needs a private hashtable; shared frame changes invalidate indexes for lazy rebuilding. Frames and mutable binding cells remain shared." } ;

HELP: context>namestack
{ $values { "context" namespace-context } { "vector" "a vector of assocs" } }
{ $description "Exports scope assocs in search order, with the global assoc first when present. Owned frames are materialized once and become borrowed, preserving subsequent direct mutation and assoc identity." } ;

ARTICLE: "namespaces.contexts" "Indexed namespace contexts"
"This vocabulary implements the dynamic variable state used by " { $vocab-link "namespaces" } "."
$nl
"Use " { $link with-scope } " and " { $link with-variable } " for private scopes with indexed bindings. " { $link with-variables } " retains a supplied assoc by identity and reads it live. " { $link namespace } " and " { $link get-namestack } " export mutable assocs, so their frames switch to the live path. Thread inheritance and continuations use " { $link capture-namestack } " instead, retaining indexed frames."
{ $subsections namespace-context context-snapshot context>namestack } ;

ABOUT: "namespaces.contexts"
