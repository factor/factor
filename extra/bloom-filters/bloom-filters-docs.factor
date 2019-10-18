USING: help.markup help.syntax kernel math ;
IN: bloom-filters

HELP: <bloom-filter>
{ $values { "error-rate" "The desired false positive rate. A " { $link float } " between 0 and 1." }
          { "capacity" "The expected number of object in the set. A positive " { $link integer } "." }
          { "bloom-filter" bloom-filter } }
{ $description "Creates an empty Bloom filter." }
{ $errors "Throws a " { $link invalid-size } " when unable to produce a filter meeting the given constraints. Throws a " { $link invalid-error-rate } " or a " { $link invalid-capacity } " when input is invalid." } ;


HELP: bloom-filter-insert
{ $values { "object" object }
          { "bloom-filter" bloom-filter } }
{ $description "Records the item as a member of the filter." }
{ $side-effects "bloom-filter" } ;

HELP: bloom-filter-member?
{ $values { "object" object }
          { "bloom-filter" bloom-filter }
          { "?" boolean } }
{ $description "Returns " { $link t } " if the object may be a member of Bloom filter, " { $link f } " otherwise. The false positive rate is configurable; there are no false negatives." } ;

HELP: bloom-filter
{ $class-description "This is the class for Bloom filters. These provide constant-time insertion and probabilistic membership-testing operations, but do not actually store any elements." } ;

ARTICLE: "bloom-filters" "Bloom filters"
"This is a library for Bloom filters, sets that provide a constant-time insertion operation and probabilistic membership tests, but do not actually store any elements."
$nl
"The accuracy of the membership test is configurable; a Bloom filter will never incorrectly report an item is not a member of the set, but may incorrectly report than an item is a member of the set."
$nl
"Bloom filters cannot be resized and do not support removal."
$nl
{ $subsections
    <bloom-filter>
    bloom-filter-insert
    bloom-filter-member?
} ;

ABOUT: "bloom-filters"
