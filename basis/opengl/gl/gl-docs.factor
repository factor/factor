
USING: help.syntax help.markup ;

IN: opengl.gl

ARTICLE: "opengl-low-level" "OpenGL binding"
{ $subsections
    "opengl-specifying-vertices"
    "opengl-geometric-primitives"
    "opengl-modeling-transformations"
} ;

ARTICLE: "opengl-specifying-vertices" "Specifying vertices"
{ $subsections
    glVertex2d
    glVertex2f
    glVertex2i
    glVertex2s
    glVertex3d
    glVertex3f
    glVertex3i
    glVertex3s
    glVertex4d
    glVertex4f
    glVertex4i
    glVertex4s
    glVertex2dv
    glVertex2fv
    glVertex2iv
    glVertex2sv
    glVertex3dv
    glVertex3fv
    glVertex3iv
    glVertex3sv
    glVertex4dv
    glVertex4fv
    glVertex4iv
    glVertex4sv
} ;


ARTICLE: "opengl-geometric-primitives" "OpenGL geometric primitives"

  { $table
      { { $link GL_POINTS         } "individual points" }
      { { $link GL_LINES          } { "pairs of vertices interpreted as "
                                      "individual line segments" } }
      { { $link GL_LINE_STRIP     } "series of connected line segments" }
      { { $link GL_LINE_LOOP      } { "same as above, with a segment added "
                                      "between last and first vertices" } }
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

HELP: glPolygonMode
  { $values { "face" { "One of the following:"
                       { $list { $link GL_FRONT }
                               { $link GL_BACK }
                               { $link GL_FRONT_AND_BACK } } } }
            { "mode" { "One of the following:"
                       { $list
                         { $link GL_POINT }
                         { $link GL_LINE }
                         { $link GL_FILL } } } } } ;

ARTICLE: "opengl-modeling-transformations" "Modeling transformations"
{ $subsections
    glTranslatef
    glTranslated
    glRotatef
    glRotated
    glScalef
    glScaled
} ;


{ glTranslatef glTranslated glRotatef glRotated glScalef glScaled }
related-words
