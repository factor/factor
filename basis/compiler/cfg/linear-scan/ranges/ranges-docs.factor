USING: compiler.cfg help.syntax help.markup math ;
IN: compiler.cfg.linear-scan.ranges

HELP: intersect-range
{ $values
  { "range1" live-range }
  { "range2" live-range }
  { "n/f" { $link number } " or " { $link f } }
}
{ $description "First index for the ranges intersection, or f if they don't intersect." } ;

HELP: live-range
{ $class-description "Represents a range in the " { $link cfg } " in which a vreg is live." } ;

ARTICLE: "compiler.cfg.linear-scan.ranges" "Live ranges utilities"
"Utilities for dealing with the live range part of live intervals. A sequence of " { $link live-range } " tuples encodes where in the cfg a virtual register is live."
$nl
"Constructors:" { $subsections <live-range> live-range } ;

ABOUT: "compiler.cfg.linear-scan.ranges"
