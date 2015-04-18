USING: help.markup help.syntax io.encodings.utf8 strings ;
IN: backticks

HELP: `
{ $syntax "` command [args]`" }
{ $description "Runs the specified command and captures the output as a " { $link utf8 } " encoded " { $link string } "." }
{ $examples
    { $unchecked-example
        "` ls -l`"
        "total 45\ndrwxrwxr-x+ 61 root  admin  2074 Apr  8 22:58 Applic..."
    }
} ;
