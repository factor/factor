USING: kernel listener lists.lazy math.trig namespaces sequences
ui.tools.environment splitting ui ui.gadgets.borders ;
IN: ui.tools.listener

: show-listener ( -- ) [ border? ] find-window [ raise-window ] [ environment-window ] if* ;
: listener-window ( -- ) environment-window ;

USE: lists.lazy
USE: math.trig

interactive-vocabs [ { 
  "io.encodings.utf8"
  "io.encodings.binary"
  "io.encodings.ascii"
  "io.binary"
  "io.directories"
  "io.directories.hierarchy"
  "lists.lazy"
  "splitting"
  "math.functions"
  "math.trig"
  "math.vectors"
  "math.intervals"
  "math.statistics"
  "math.parser"
  "sequences.deep"
  "sequences.extras"
  "sequences.generalizations"
  "binary-search"
  "vectors"
  "quotations"
  "byte-arrays"
  "deques"
  "regexp"
  "calendar"
  "classes"
  "unicode.case"
  "unicode.categories"
  "io.files.info"
  "colors"
  "colors.hex"
  "timers"
  "sets"
  "globs"
  "scratchpad"
} append ] change-global
