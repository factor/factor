USING: help.markup help.syntax opengl.gl quotations ;
IN: opengl.demo-support

HELP: do-state
{ $values
  { "mode" GLenum }
  { "quot" quotation }
} { $description "Runs the quotation wrapped in a " { $link glBegin } "/" { $link glEnd } " block." } ;
