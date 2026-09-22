USING: help.markup help.syntax math sequences ;
IN: arrays.shaped

HELP: ndim
{ $values { "array" { $or shaped-array sequence } } { "n" integer } }
{ $description "Returns the number of dimensions of a shaped array or a rectangular nested sequence. An empty ordinary sequence has one dimension." } ;
