# Fresh named class-info constructor

Baseline `1d67bdd034`; tested production/tests `04fa5fdbba`.

The earlier 13-word count-only propagation diagnostic recorded 14,293
class-info constructions and 14,059 repeated class keys. It resets its seen
map at each propagation pass. These counts include anonymous structural keys
and are only an upper bound for a named-class optimization; they are not a
performance measurement. Identical info-object intersections were rare
(298/16,912), so broad memoization/intersection identity checks are not justified
by these counts alone.

## Why not cache

`value-info-state` has five mutable fields. Existing recursive generalization
and cloned-value-info explicitly clone before mutation; the constructor is
also public. Sharing newly interned result tuples would introduce aliasing.
Compilation-local named-class caching still needs invalidation: propagation
runs custom `outputs`, constraint and inlining quotations, and executes
foldable words. No contract prohibits these from redefining a class inside
one propagation invocation. Class redefinition calls `reset-caches`, which
clears the existing algebra tables in place: their identity is not an epoch.
No cache or class-generation mechanism is introduced here.

`(refine-value-info)` also remains unchanged. An entailed class constraint
cannot safely skip `init-value-info` for arbitrary externally supplied,
noncanonical infos. For example, an old fixnum info with full interval needs
the normal intersection path to clamp it to fixnum bounds even when an integer
constraint appears entailed by its class and full interval.

## Constructor proof

The original `<class-info>` calls `f <class/interval-info>`. The new tuple
therefore starts with class supplied, interval/literal/literal?/slots all f.
For named word inputs:

1. `empty-set?` reduces to `null-class?`, since f is not `empty-interval`.
   Keep this class-algebra query on every call, including after redefinition.
2. A null class yields class null and empty interval, with other fields f.
3. Otherwise `wrap-interval` receives full interval and selects `class-interval`.
   Its only finite results are fixnum, array-capacity and integer-array-capacity
   bounds. They are closed, integral and contain more than one point.
4. Integral closure cannot change these values. It is nevertheless retained
   to allocate independent finite interval endpoint arrays, matching the old
   path rather than sharing memoized mutable endpoint arrays. For every other
   named class the full interval is special and closure is a no-op.
5. Literal inference cannot produce a literal from any of these intervals.
   Capacity classes normalize to fixnum/integer exactly as before.
6. A fresh `value-info-state` is built with the resulting class and interval,
   literal/literal?/slots f. No result template is shared.

Anonymous classoids use the untouched original path to preserve structural
class-algebra cache behavior. Predicate and singleton words do not gain new
literal inference. Arbitrary interval and literal constructors are unchanged.

## Validation and limits

The retained check script runs the propagation subtree and class algebra with
SSA, allocation and tree optimizer checks enabled. It passes with zero
failures. New tests compare against the independent original
`f <class/interval-info>` invocation for named classes, metaclasses, predicates,
empty unions and capacity bounds; prime anonymous structural caches and compare
later subtype queries; redefine the same named union from nonempty to empty
and back; and mutate one result's fields and finite interval endpoints without
changing another result.

Two preliminary test loads exposed missing explicit private-vocabulary imports;
the final successful file contains them. No production failure was observed.
The code preserves value semantics and the existing allocation independence;
no measured compiler-speed or bootstrap benefit is claimed yet. Uninstrumented
same-scope compiler measurements and broader integrated validation remain the
parent's acceptance gates.

Relevant lifecycle/call sites: `optimize-tree` owns a namespace scope and invokes
`propagate` once; `propagate` resets copies/value-infos/constraints; recursive
propagation iterates `(propagate)` inside that pass. `word>input-infos`, default
output classes, declaration constraints and known arithmetic output rules call
`<class-info>`. Declaration dependency registration remains in
`#declare propagate-before`, outside this constructor.
