
USING: help.syntax help.markup ;

USING: bubble-chamber.particle.muon
       bubble-chamber.particle.quark
       bubble-chamber.particle.hadron
       bubble-chamber.particle.axion ;

IN: bubble-chamber

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

HELP: muon

  { $class-description
    "The muon is a colorful particle with an entangled friend."
    "It draws both itself and its horizontally symmetric partner."
    "A high range of speed and almost no speed decay allow the"
    "muon to reach the extents of the window, often forming rings"
    "where theta has decayed but speed remains stable. The result"
    "is color almost everywhere in the general direction of collision,"
    "stabilized into fuzzy rings." } ;

HELP: quark

  { $class-description
    "The quark draws as a translucent black. Their large numbers"
    "create fields of blackness overwritten only by the glowing shadows of "
    "Hadrons. "
    "quarks are allowed to accelerate away with speed decay values above 1.0. "
    "Each quark has an entangled friend. Both particles are drawn identically,"
    "mirrored along the y-axis." } ;

HELP: hadron

  { $class-description
    "Hadrons collide from totally random directions. "
    "Those hadrons that do not exit the drawing area, "
    "tend to stabilize into perfect circular orbits. "
    "Each hadron draws with a slight glowing emboss. "
    "The hadron itself is not drawn." } ;

HELP: axion

  { $class-description
    "The axion particle draws a bold black path. Axions exist "
    "in a slightly higher dimension and as such are drawn with "
    "elevated embossed shadows. Axions are quick to stabilize "
    "and fall into single pixel orbits axions automatically "
    "recollide themselves after stabilizing." } ;

{ muon quark hadron axion } related-words

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

ARTICLE: "bubble-chamber" "Bubble Chamber"

  { $subsection "bubble-chamber-introduction" }
  { $subsection "bubble-chamber-particles" }
  { $subsection "bubble-chamber-author" }
  { $subsection "bubble-chamber-running" } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

ARTICLE: "bubble-chamber-introduction" "Introduction"

"The Bubble Chamber is a generative painting system of imaginary "
"colliding particles. A single super-massive collision produces a "
"discrete universe of four particle types. Particles draw their "
"positions over time as pixel exposures. " ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

ARTICLE: "bubble-chamber-particles" "Particles"

"Four types of particles exist. The behavior and graphic appearance of "
"each particle type is unique."

  { $subsection muon }
  { $subsection quark }
  { $subsection hadron }
  { $subsection axion } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

ARTICLE: "bubble-chamber-author" "Author"

  "Bubble Chamber was created by Jared Tarbell. "
  "It was originally implemented in Processing. "
  "It was ported to Factor by Eduardo Cavazos. "
  "The original work is on display here: "
  { $url
  "http://www.complexification.net/gallery/machines/bubblechamber/" } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

ARTICLE: "bubble-chamber-running" "How to use"

  "After you run the vocabulary, a window will appear. Click the "
  "mouse in a random area to fire 11 particles of each type. "
  "Another way to fire particles is to press the "
  "spacebar. This fires all the particles." ;