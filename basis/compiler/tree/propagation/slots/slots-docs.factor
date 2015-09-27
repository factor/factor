USING: compiler.tree.propagation.info help.markup help.syntax kernel math ;
IN: compiler.tree.propagation.slots

HELP: literal-info-slot
{ $values
  { "slot" integer }
  { "object" object }
  { "info/f" { $link value-info } " or " { $link f } }
}
{ $description "literal-info-slot makes an unsafe call to 'slot'. Check that the layout is up to date to avoid accessing the wrong slot during a compilation unit where reshaping took place. This could happen otherwise because the 'slots' word property would reflect the new layout, but instances in the heap would use the old layout since instances are updated immediately after compilation." } ;

ARTICLE: "compiler.tree.propagation"
"Propagation for read-only tuple slots and array lengths"
"Propagation of immutable slots and array lengths." ;

ABOUT: "compiler.tree.propagation"
