USING: arrays help.markup help.syntax math sequences ;
IN: compiler.cfg.linear-scan.ranges

HELP: add-range
{ $values { "from" integer } { "to" integer } { "ranges" sequence } }
{ $description "Adds the given range to the 'ranges' sequence, or extends the last range of it if it is possible." } ;

HELP: intersect-range
{ $values
  { "r1" pair }
  { "r2" pair }
  { "n/f" { $link number } " or " { $link f } }
}
{ $description "First index for the ranges intersection, or f if they don't intersect." } ;

ARTICLE: "compiler.cfg.linear-scan.ranges" "Live ranges utilities"
"Utilities for dealing with the live range part of live intervals. A sequence of integer 2-tuples encodes the closed intervals in the cfg where a virtual register is live."
$nl
"Range splitting:"
{ $subsections
  split-range split-ranges
} ;

ABOUT: "compiler.cfg.linear-scan.ranges"
