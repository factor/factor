USING: alien.fortran help.markup help.syntax math.blas.config multiline ;
IN: math.blas.config

ARTICLE: "math.blas.config" "Configuring the BLAS interface"
"The " { $link "math.blas-summary" } " chooses the underlying BLAS interface to use based on the values of the following global variables:"
{ $subsection blas-library }
{ $subsection blas-fortran-abi }
"The interface attempts to set default values based on the ones encountered on the Factor project's build machines. If these settings don't work with your system's BLAS, or you wish to use a commercial BLAS, you may change the global values of those variables in your " { $link "factor-rc" } ". For example, to use AMD's ACML library on Windows with " { $snippet "math.blas" } ", your " { $snippet "factor-rc" } " would look like this:"
{ $code <"
USING: math.blas.config namespaces ;
"X:\\path\\to\\acml.dll" blas-library set-global
intel-windows-abi blas-fortran-abi set-global
"> }
"To take effect, the " { $snippet "blas-library" } " and " { $snippet "blas-fortran-abi" } " variables must be set before any other " { $snippet "math.blas" } " vocabularies are loaded."
;

HELP: blas-library
{ $description "The name of the shared library containing the BLAS interface to load. The value of this variable must be a valid shared library name that can be passed to " { $link add-fortran-library } ". To take effect, this variable must be set before any other " { $snippet "math.blas" } " vocabularies are loaded. See " { $link "math.blas.config" } " for details and examples." } ;

HELP: blas-fortran-abi
{ $description "The Fortran ABI used by the BLAS interface specified in the " { $link blas-library } " variable. The value of " { $snippet "blas-fortran-abi" } " must be one of the " { $link "alien.fortran-abis" } " that can be passed to " { $link add-fortran-library } ". To take effect, this variable must be set before any other " { $snippet "math.blas" } " vocabularies are loaded. See " { $link "math.blas.config" } " for details and examples." } ;

ABOUT: "math.blas.config"
