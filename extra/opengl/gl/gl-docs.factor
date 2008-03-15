
USING: help.syntax help.markup ;

IN: opengl.gl

ARTICLE: "opengl-specifying-vertices" "Specifying Vertices"

  { $subsection glVertex2d }
  { $subsection glVertex2f }
  { $subsection glVertex2i }
  { $subsection glVertex2s }
  { $subsection glVertex3d }
  { $subsection glVertex3f }
  { $subsection glVertex3i }
  { $subsection glVertex3s }
  { $subsection glVertex4d }
  { $subsection glVertex4f }
  { $subsection glVertex4i }
  { $subsection glVertex4s }
  { $subsection glVertex2dv }
  { $subsection glVertex2fv }
  { $subsection glVertex2iv }
  { $subsection glVertex2sv }
  { $subsection glVertex3dv }
  { $subsection glVertex3fv }
  { $subsection glVertex3iv }
  { $subsection glVertex3sv }
  { $subsection glVertex4dv }
  { $subsection glVertex4fv }
  { $subsection glVertex4iv }
  { $subsection glVertex4sv } ;

ARTICLE: "opengl-geometric-primitives" "OpenGL Geometric Primitives"

  { $table
      { { $link GL_POINTS         } "individual points" }
      { { $link GL_LINES          } "pairs of vertices interpreted as "
                                    "indivisual line segments" }
      { { $link GL_LINE_STRIP     } "series of connected line segments" }
      { { $link GL_LINE_LOOP      } "same as above, with a segment added "
                                    "between last and first vertices" }
      { { $link GL_TRIANGLES      }
        "triples of vertices interpreted as triangles" }
      { { $link GL_TRIANGLE_STRIP } "linked strip of triangles" }
      { { $link GL_TRIANGLE_FAN   } "linked fan of triangles" }
      { { $link GL_QUADS          }
        "quadruples of vertices interpreted as four-sided polygons" }
      { { $link GL_QUAD_STRIP     } "linked strip of quadrilaterals" }
      { { $link GL_POLYGON        } "boundary of a simple, convex polygon" } }

;

HELP: glBegin
  { $values { "mode"
              { "One of the " { $link "opengl-geometric-primitives" } } } } ;