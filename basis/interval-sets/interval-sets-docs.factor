! Copyright (C) 2009 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: help.syntax help.markup math ;
IN: interval-sets

ABOUT: "interval-sets"

ARTICLE: "interval-sets" "Interval sets"
"The " { $vocab-link "interval-sets" } " vocabulary implements an efficient data structure for sets of positive, machine word-sized integers, specified by ranges. The space taken by the data structure is proportional to the number of intervals contained. Membership testing is O(log n), and creation is O(n log n), where n is the number of ranges. Boolean operations are O(n). Interval sets are immutable."
{ $subsection interval-set }
{ $subsection <interval-set> }
{ $subsection in? }
{ $subsection <interval-not> }
{ $subsection <interval-and> }
{ $subsection <interval-or> } ;

HELP: interval-set
{ $class-description "The class of interval sets." }
{ $see-also "interval-sets" } ;

HELP: <interval-set>
{ $values { "specification" "a sequence of numbers and pairs of numbers" } { "interval-set" interval-set } }
{ $description "Creates an interval set based on the specification. Pairs of numers are interpreted as intervals which include their endpoints, and individual numbers are interpreted to be in the set, in a singleton range." } ;

HELP: in?
{ $values { "key" integer } { "set" interval-set } { "?" { { $link t } " or " { $link f } } } }
{ $description "Tests whether an integer is in an interval set. This takes O(log n) time for an interval map composed of n intervals." } ;

HELP: <interval-and>
{ $values { "set1" interval-set } { "set2" interval-set } { "set" interval-set } }
{ $description "Calculates the intersection of two interval sets. This takes O(n+m) time, where the input interval maps have n and m intervals in them." } ;

HELP: <interval-or>
{ $values { "set1" interval-set } { "set2" interval-set } { "set" interval-set } }
{ $description "Calculates the union of two interval sets. This takes O(n+m) time, where the input interval maps have n and m intervals in them." } ;

HELP: <interval-not>
{ $values { "set" interval-set } { "maximum" integer } { "set'" interval-set } }
{ $description "Calculates the complement of an interval set. Because interval sets are finite, this takes an argument for the maximum integer in the domain considered. This takes time proportional to the size of the input." } ;
