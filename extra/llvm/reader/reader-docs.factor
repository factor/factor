! Copyright (C) 2017 Björn Lindqvist.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax llvm.wrappers strings ;

IN: llvm.reader

HELP: load-module
{ $values { "path" string } { "module" module } }
{ $description "Parses a file containing llvm bitcode into an llvm module." }
{ $examples
  { $unchecked-example
    "USING: io.pathnames llvm.reader ;"
    "\"resource:extra/llvm/wrappers/add.bc\" absolute-path load-module"
    "T{ module { value ALIEN: 1be7120 } }"
  }
} ;
