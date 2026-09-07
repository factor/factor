USING: help.markup help.syntax kernel strings ;
IN: io.standard-paths

HELP: find-in-path
{ $values { "string" string } { "path/f" { $maybe string } } }
{ $description "Returns the path of the first executable file found in PATH, or false if none is found. Directories are skipped. Unix searches require execute permission. Windows searches recognize PATHEXT and append its extensions to commands without an extension, preserving directory order before extension order." } ;

HELP: find-in-standard-login-path
{ $values { "string" string } { "path/f" { $maybe string } } }
{ $description "Searches the login shell's standard path on Unix, using the same executable-file checks as " { $link find-in-path } ". On other platforms, searches PATH." } ;

HELP: ?find-in-path
{ $values { "string" string } { "path/string" string } }
{ $description "Calls " { $link find-in-path } " and returns the original string if no executable is found." } ;
