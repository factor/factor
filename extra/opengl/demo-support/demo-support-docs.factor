USING: help.markup help.syntax opengl.gl opengl.demo-support quotations ;
IN: opengl.demo-support+docs

HELP: do-state
{ $values
  { "mode" GLenum }
  { "quot" quotation }
} { $description "Runs the quotation wrapped in a " { $link glBegin } "/" { $link glEnd } " block." } ;
