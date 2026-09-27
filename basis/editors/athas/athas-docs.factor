USING: editors help.markup help.syntax ;
IN: editors.athas

HELP: athas-path
{ $values { "path" "a pathname string" } }
{ $description "Finds the Athas command in PATH. Set this word's variable to override the executable path." } ;

ARTICLE: "editors.athas" "Athas support"
"Install the " { $snippet "athas" } " command from Settings > General > Terminal Command in Athas, and ensure its bin directory is in PATH. See the " { $url "https://athas.dev/docs/cli" "Athas CLI documentation" } "."
$nl
"To use Athas for editing Factor source, add the following to your " { $snippet ".factor-rc" } " file:"
{ $code "USING: editors ;"
    "EDITOR: athas" }
"If the command is not in PATH, configure its full path:"
{ $code "USING: editors.athas namespaces ;"
    "\"/path/to/athas\" \\ athas-path set-global" }
"Source locations open at the requested line. Files opened without a line number start at line 1." ;

ABOUT: "editors.athas"
