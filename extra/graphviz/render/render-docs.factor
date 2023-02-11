! Copyright (C) 2012 Alex Vondrak.
! See https://factorcode.org/license.txt for BSD license.
USING: graphviz help.markup help.syntax images.viewer
io.encodings.latin1 io.encodings.utf8 io.launcher kernel
strings ;
IN: graphviz.render

{ cannot-find-graphviz-installation default-graphviz-program ?default-graphviz-program } related-words
{ unsupported-encoding graph-encoding } related-words
{ unsupported-preview-format preview-format } related-words
{ graphviz graphviz* } related-words
{ preview preview-window } related-words
{ circo dot fdp neato osage sfdp twopi } related-words
{ bmp canon dot-file xdot cmap eps fig gd gd2 gif ico imap cmapx imap_np cmapx_np ismap jpg jpeg jpe pdf plain plain-ext png ps ps2 svg svgz tif tiff vml vmlz vrml wbmp webp } related-words

HELP: cannot-find-graphviz-installation
{ $error-description "Thrown by " { $link ?default-graphviz-program } " if a Graphviz installation cannot be found." } ;

HELP: unsupported-encoding
{ $values
    { "graph-encoding" "a character encoding" }
}
{ $error-description "Thrown by " { $links graphviz graphviz* preview preview-window } ", and related words if " { $link graph-encoding } " has a value other than " { $link utf8 } " or " { $link latin1 } "." } ;

HELP: unsupported-preview-format
{ $values
    { "preview-format" string }
}
{ $error-description "Thrown by " { $link preview } " or " { $link preview-window } " if " { $link preview-format } " has a value that's not supported by " { $vocab-link "images.loader" } "." } ;

HELP: ?default-graphviz-program
{ $values
        { "path" "a pathname string" }
}
{ $description "Searches your computer for the path to a Graphviz executable." }
{ $errors "Throws an error if a Graphviz installation cannot be found." } ;

HELP: default-graphviz-program
{ $values
        { "path/f" { $maybe "a pathname string" } }
}
{ $description "Searches your computer for the path to a Graphviz executable. If one cannot be found, returns " { $link f } "."
$nl
"On a Unix machine, this involves looking for " { $snippet "circo" } ", " { $snippet "dot" } ", " { $snippet "fdp" } ", " { $snippet "neato" } ", " { $snippet "osage" } ", " { $snippet "sfdp" } ", or " { $snippet "twopi" } " somewhere in your " { $snippet "PATH" } "."
$nl
"On Windows, if you have Graphviz installed into a folder whose name begins with " { $snippet "Graphviz" } " in either " { $snippet "Program Files" } " or " { $snippet "Program Files(x86)" } ", that folder will be searched for an executable named " { $snippet "circo.exe" } ", " { $snippet "dot.exe" } ", " { $snippet "fdp.exe" } ", " { $snippet "neato.exe" } ", " { $snippet "osage.exe" } ", " { $snippet "sfdp.exe" } ", or " { $snippet "twopi.exe" } "."
} ;

HELP: default-layout
{ $var-description "A " { $link string } " representing the layout engine implicitly used by " { $links graphviz* preview preview-window } ", and related words." }
{ $notes "Must be an image format supported by " { $vocab-link "images.loader" } "." } ;

HELP: graph-encoding
{ $var-description "The character encoding used when writing " { $instance graph } " to a DOT file." }
{ $notes "To match Graphviz's valid values for a graph's " { $snippet "charset" } " attribute (see " { $url "https://graphviz.org/content/attrs#dcharset" } "), this global variable must either be " { $link utf8 } " or " { $link latin1 } ". If it does not match your graph's " { $snippet "charset" } ", your output may be incorrect." } ;

HELP: preview-format
{ $var-description "A " { $link string } " representing the output format implicitly used by " { $link preview } " and " { $link preview-window } "." } ;

HELP: graphviz
{ $values
    { "graph" graph } { "path" "a pathname string" } { "format" string } { "layout" string }
}
{ $description "Translates " { $snippet "graph" } " into DOT code and invokes Graphviz on the result."
$nl
{ $snippet "path" } " is the location where you want to save your output, " { $emphasis "without" } " a file extension (Graphviz will automatically add one based on " { $snippet "format" } ")."
$nl
{ $snippet "format" } " is the format of your output (e.g., " { $snippet "\"png\"" } ")."
$nl
{ $snippet "layout" } " is the layout engine to use (e.g., " { $snippet "\"dot\"" } ")."
$nl
"Essentially, you can think of it as equivalent to running the Graphviz command \"" { $strong "dot" } " " { $snippet "path" } " " { $strong "-O" } " " { $strong "-T" } { $snippet "format" } " " { $strong "-K" } { $snippet "layout" } "\". See " { $url "https://graphviz.org/content/command-line-invocation" } "."
}
{ $errors
"If the Graphviz process encounters an error, its output will be captured and thrown as " { $instance output-process-error } " by Factor."
$nl
"Throws " { $instance unsupported-encoding } " error if " { $link graph-encoding } " isn't one of " { $link utf8 } " or " { $link latin1 } "."
}
{ $examples "To render a " { $link graph } " " { $snippet "G" } " using circo and save the output to a PNG file, you could write" { $code "G \"foo\" \"png\" \"circo\" graphviz" } "(assuming circo and PNG are supported by your Graphviz installation). This will save the output to the file " { $snippet "foo.png" } "." } ;

HELP: graphviz*
{ $values
    { "graph" graph } { "path" "a pathname string" } { "format" string }
}
{ $description "Invokes the " { $link graphviz } " word using the value of " { $link default-layout } " as the layout engine. That is, the following two lines are equivalent:"
{ $code "graph path format default-layout get-global graphviz" "graph path format graphviz*" }
}
{ $examples "To render a " { $link graph } " " { $snippet "G" } " when you don't particularly care about the layout engine but want to save the output to a PNG file, you could write" { $code "G \"foo\" \"png\" graphviz*" } "(assuming that " { $link default-layout } " and PNG are supported by your Graphviz installation). This will save the output to the file " { $snippet "foo.png" } "." } ;

HELP: preview
{ $values
    { "graph" graph }
}
{ $description "Renders " { $snippet "graph" } " to a temporary file using " { $link preview-format } " and " { $link default-layout } ". Then, using " { $link image. } ", displays the image in the UI listener before deleting the temporary file." }
{ $errors
"Throws " { $instance unsupported-preview-format } " error if " { $link preview-format } " is not supported by " { $vocab-link "images.loader" } "."
$nl
"If the Graphviz process encounters an error, its output will be captured and thrown as " { $instance output-process-error } " by Factor."
$nl
"Throws " { $instance unsupported-encoding } " error if " { $link graph-encoding } " isn't one of " { $link utf8 } " or " { $link latin1 } "."
} ;

HELP: preview-window
{ $values
    { "graph" graph }
}
{ $description "Renders " { $snippet "graph" } " to a temporary file using " { $link preview-format } " and " { $link default-layout } ". Then, using " { $link image-window } ", opens a new window displaying the image before deleting the temporary file." }
{ $errors
"Throws " { $instance unsupported-preview-format } " error if " { $link preview-format } " is not supported by " { $vocab-link "images.loader" } "."
$nl
"If the Graphviz process encounters an error, its output will be captured and thrown as " { $instance output-process-error } " by Factor."
$nl
"Throws " { $instance unsupported-encoding } " error if " { $link graph-encoding } " isn't one of " { $link utf8 } " or " { $link latin1 } "."
} ;

!

HELP: circo
{ $values
    { "graph" graph } { "path" "a pathname string" } { "format" string }
}
{ $description "Invokes " { $link graphviz } " with " { $snippet "\"circo\"" } " supplied as the layout engine. That is, the following two lines are equivalent:" { $code "graph path format \"circo\" graphviz" "graph path format circo" } } ;

HELP: dot
{ $values
    { "graph" graph } { "path" "a pathname string" } { "format" string }
}
{ $description "Invokes " { $link graphviz } " with " { $snippet "\"dot\"" } " supplied as the layout engine. That is, the following two lines are equivalent:" { $code "graph path format \"dot\" graphviz" "graph path format dot" } } ;

HELP: fdp
{ $values
    { "graph" graph } { "path" "a pathname string" } { "format" string }
}
{ $description "Invokes " { $link graphviz } " with " { $snippet "\"fdp\"" } " supplied as the layout engine. That is, the following two lines are equivalent:" { $code "graph path format \"fdp\" graphviz" "graph path format fdp" } } ;

HELP: neato
{ $values
    { "graph" graph } { "path" "a pathname string" } { "format" string }
}
{ $description "Invokes " { $link graphviz } " with " { $snippet "\"neato\"" } " supplied as the layout engine. That is, the following two lines are equivalent:" { $code "graph path format \"neato\" graphviz" "graph path format neato" } } ;

HELP: osage
{ $values
    { "graph" graph } { "path" "a pathname string" } { "format" string }
}
{ $description "Invokes " { $link graphviz } " with " { $snippet "\"osage\"" } " supplied as the layout engine. That is, the following two lines are equivalent:" { $code "graph path format \"osage\" graphviz" "graph path format osage" } } ;

HELP: sfdp
{ $values
    { "graph" graph } { "path" "a pathname string" } { "format" string }
}
{ $description "Invokes " { $link graphviz } " with " { $snippet "\"sfdp\"" } " supplied as the layout engine. That is, the following two lines are equivalent:" { $code "graph path format \"sfdp\" graphviz" "graph path format sfdp" } } ;

HELP: twopi
{ $values
    { "graph" graph } { "path" "a pathname string" } { "format" string }
}
{ $description "Invokes " { $link graphviz } " with " { $snippet "\"twopi\"" } " supplied as the layout engine. That is, the following two lines are equivalent:" { $code "graph path format \"twopi\" graphviz" "graph path format twopi" } } ;

!

HELP: bmp
{ $values
    { "graph" graph } { "path" "a pathname string" }
}
{ $description "Invokes " { $link graphviz* } " with " { $snippet "\"bmp\"" } " supplied as the output format. That is, the following two lines are equivalent:" { $code "graph path \"bmp\" graphviz*" "graph path bmp" } } ;

HELP: canon
{ $values
    { "graph" graph } { "path" "a pathname string" }
}
{ $description "Invokes " { $link graphviz* } " with " { $snippet "\"canon\"" } " supplied as the output format. That is, the following two lines are equivalent:" { $code "graph path \"canon\" graphviz*" "graph path canon" } } ;

HELP: cmap
{ $values
    { "graph" graph } { "path" "a pathname string" }
}
{ $description "Invokes " { $link graphviz* } " with " { $snippet "\"cmap\"" } " supplied as the output format. That is, the following two lines are equivalent:" { $code "graph path \"cmap\" graphviz*" "graph path cmap" } } ;

HELP: cmapx
{ $values
    { "graph" graph } { "path" "a pathname string" }
}
{ $description "Invokes " { $link graphviz* } " with " { $snippet "\"cmapx\"" } " supplied as the output format. That is, the following two lines are equivalent:" { $code "graph path \"cmapx\" graphviz*" "graph path cmapx" } } ;

HELP: cmapx_np
{ $values
    { "graph" graph } { "path" "a pathname string" }
}
{ $description "Invokes " { $link graphviz* } " with " { $snippet "\"cmapx_np\"" } " supplied as the output format. That is, the following two lines are equivalent:" { $code "graph path \"cmapx_np\" graphviz*" "graph path cmapx_np" } } ;

HELP: dot-file
{ $values
    { "graph" graph } { "path" "a pathname string" }
}
{ $description "Invokes " { $link graphviz* } " with " { $snippet "\"dot\"" } " supplied as the output format. That is, the following two lines are equivalent:" { $code "graph path \"dot\" graphviz*" "graph path dot-file" } } ;

HELP: eps
{ $values
    { "graph" graph } { "path" "a pathname string" }
}
{ $description "Invokes " { $link graphviz* } " with " { $snippet "\"eps\"" } " supplied as the output format. That is, the following two lines are equivalent:" { $code "graph path \"eps\" graphviz*" "graph path eps" } } ;

HELP: fig
{ $values
    { "graph" graph } { "path" "a pathname string" }
}
{ $description "Invokes " { $link graphviz* } " with " { $snippet "\"fig\"" } " supplied as the output format. That is, the following two lines are equivalent:" { $code "graph path \"fig\" graphviz*" "graph path fig" } } ;

HELP: gd
{ $values
    { "graph" graph } { "path" "a pathname string" }
}
{ $description "Invokes " { $link graphviz* } " with " { $snippet "\"gd\"" } " supplied as the output format. That is, the following two lines are equivalent:" { $code "graph path \"gd\" graphviz*" "graph path gd" } } ;

HELP: gd2
{ $values
    { "graph" graph } { "path" "a pathname string" }
}
{ $description "Invokes " { $link graphviz* } " with " { $snippet "\"gd2\"" } " supplied as the output format. That is, the following two lines are equivalent:" { $code "graph path \"gd2\" graphviz*" "graph path gd2" } } ;

HELP: gif
{ $values
    { "graph" graph } { "path" "a pathname string" }
}
{ $description "Invokes " { $link graphviz* } " with " { $snippet "\"gif\"" } " supplied as the output format. That is, the following two lines are equivalent:" { $code "graph path \"gif\" graphviz*" "graph path gif" } } ;

HELP: ico
{ $values
    { "graph" graph } { "path" "a pathname string" }
}
{ $description "Invokes " { $link graphviz* } " with " { $snippet "\"ico\"" } " supplied as the output format. That is, the following two lines are equivalent:" { $code "graph path \"ico\" graphviz*" "graph path ico" } } ;

HELP: imap
{ $values
    { "graph" graph } { "path" "a pathname string" }
}
{ $description "Invokes " { $link graphviz* } " with " { $snippet "\"imap\"" } " supplied as the output format. That is, the following two lines are equivalent:" { $code "graph path \"imap\" graphviz*" "graph path imap" } } ;

HELP: imap_np
{ $values
    { "graph" graph } { "path" "a pathname string" }
}
{ $description "Invokes " { $link graphviz* } " with " { $snippet "\"imap_np\"" } " supplied as the output format. That is, the following two lines are equivalent:" { $code "graph path \"imap_np\" graphviz*" "graph path imap_np" } } ;

HELP: ismap
{ $values
    { "graph" graph } { "path" "a pathname string" }
}
{ $description "Invokes " { $link graphviz* } " with " { $snippet "\"ismap\"" } " supplied as the output format. That is, the following two lines are equivalent:" { $code "graph path \"ismap\" graphviz*" "graph path ismap" } } ;

HELP: jpe
{ $values
    { "graph" graph } { "path" "a pathname string" }
}
{ $description "Invokes " { $link graphviz* } " with " { $snippet "\"jpe\"" } " supplied as the output format. That is, the following two lines are equivalent:" { $code "graph path \"jpe\" graphviz*" "graph path jpe" } } ;

HELP: jpeg
{ $values
    { "graph" graph } { "path" "a pathname string" }
}
{ $description "Invokes " { $link graphviz* } " with " { $snippet "\"jpeg\"" } " supplied as the output format. That is, the following two lines are equivalent:" { $code "graph path \"jpeg\" graphviz*" "graph path jpeg" } } ;

HELP: jpg
{ $values
    { "graph" graph } { "path" "a pathname string" }
}
{ $description "Invokes " { $link graphviz* } " with " { $snippet "\"jpg\"" } " supplied as the output format. That is, the following two lines are equivalent:" { $code "graph path \"jpg\" graphviz*" "graph path jpg" } } ;

HELP: pdf
{ $values
    { "graph" graph } { "path" "a pathname string" }
}
{ $description "Invokes " { $link graphviz* } " with " { $snippet "\"pdf\"" } " supplied as the output format. That is, the following two lines are equivalent:" { $code "graph path \"pdf\" graphviz*" "graph path pdf" } } ;

HELP: plain
{ $values
    { "graph" graph } { "path" "a pathname string" }
}
{ $description "Invokes " { $link graphviz* } " with " { $snippet "\"plain\"" } " supplied as the output format. That is, the following two lines are equivalent:" { $code "graph path \"plain\" graphviz*" "graph path plain" } } ;

HELP: plain-ext
{ $values
    { "graph" graph } { "path" "a pathname string" }
}
{ $description "Invokes " { $link graphviz* } " with " { $snippet "\"plain-ext\"" } " supplied as the output format. That is, the following two lines are equivalent:" { $code "graph path \"plain-ext\" graphviz*" "graph path plain-ext" } } ;

HELP: png
{ $values
    { "graph" graph } { "path" "a pathname string" }
}
{ $description "Invokes " { $link graphviz* } " with " { $snippet "\"png\"" } " supplied as the output format. That is, the following two lines are equivalent:" { $code "graph path \"png\" graphviz*" "graph path png" } } ;

HELP: ps
{ $values
    { "graph" graph } { "path" "a pathname string" }
}
{ $description "Invokes " { $link graphviz* } " with " { $snippet "\"ps\"" } " supplied as the output format. That is, the following two lines are equivalent:" { $code "graph path \"ps\" graphviz*" "graph path ps" } } ;

HELP: ps2
{ $values
    { "graph" graph } { "path" "a pathname string" }
}
{ $description "Invokes " { $link graphviz* } " with " { $snippet "\"ps2\"" } " supplied as the output format. That is, the following two lines are equivalent:" { $code "graph path \"ps2\" graphviz*" "graph path ps2" } } ;

HELP: svg
{ $values
    { "graph" graph } { "path" "a pathname string" }
}
{ $description "Invokes " { $link graphviz* } " with " { $snippet "\"svg\"" } " supplied as the output format. That is, the following two lines are equivalent:" { $code "graph path \"svg\" graphviz*" "graph path svg" } } ;

HELP: svgz
{ $values
    { "graph" graph } { "path" "a pathname string" }
}
{ $description "Invokes " { $link graphviz* } " with " { $snippet "\"svgz\"" } " supplied as the output format. That is, the following two lines are equivalent:" { $code "graph path \"svgz\" graphviz*" "graph path svgz" } } ;

HELP: tif
{ $values
    { "graph" graph } { "path" "a pathname string" }
}
{ $description "Invokes " { $link graphviz* } " with " { $snippet "\"tif\"" } " supplied as the output format. That is, the following two lines are equivalent:" { $code "graph path \"tif\" graphviz*" "graph path tif" } } ;

HELP: tiff
{ $values
    { "graph" graph } { "path" "a pathname string" }
}
{ $description "Invokes " { $link graphviz* } " with " { $snippet "\"tiff\"" } " supplied as the output format. That is, the following two lines are equivalent:" { $code "graph path \"tiff\" graphviz*" "graph path tiff" } } ;

HELP: vml
{ $values
    { "graph" graph } { "path" "a pathname string" }
}
{ $description "Invokes " { $link graphviz* } " with " { $snippet "\"vml\"" } " supplied as the output format. That is, the following two lines are equivalent:" { $code "graph path \"vml\" graphviz*" "graph path vml" } } ;

HELP: vmlz
{ $values
    { "graph" graph } { "path" "a pathname string" }
}
{ $description "Invokes " { $link graphviz* } " with " { $snippet "\"vmlz\"" } " supplied as the output format. That is, the following two lines are equivalent:" { $code "graph path \"vmlz\" graphviz*" "graph path vmlz" } } ;

HELP: vrml
{ $values
    { "graph" graph } { "path" "a pathname string" }
}
{ $description "Invokes " { $link graphviz* } " with " { $snippet "\"vrml\"" } " supplied as the output format. That is, the following two lines are equivalent:" { $code "graph path \"vrml\" graphviz*" "graph path vrml" } } ;

HELP: wbmp
{ $values
    { "graph" graph } { "path" "a pathname string" }
}
{ $description "Invokes " { $link graphviz* } " with " { $snippet "\"wbmp\"" } " supplied as the output format. That is, the following two lines are equivalent:" { $code "graph path \"wbmp\" graphviz*" "graph path wbmp" } } ;

HELP: webp
{ $values
    { "graph" graph } { "path" "a pathname string" }
}
{ $description "Invokes " { $link graphviz* } " with " { $snippet "\"webp\"" } " supplied as the output format. That is, the following two lines are equivalent:" { $code "graph path \"webp\" graphviz*" "graph path webp" } } ;

HELP: xdot
{ $values
    { "graph" graph } { "path" "a pathname string" }
}
{ $description "Invokes " { $link graphviz* } " with " { $snippet "\"xdot\"" } " supplied as the output format. That is, the following two lines are equivalent:" { $code "graph path \"xdot\" graphviz*" "graph path xdot" } } ;

ARTICLE: { "graphviz.render" "layouts" } "Rendering graphs by layout engine"
"For each \"standard\" layout command listed in " { $url "https://graphviz.org/Documentation.php" } ", the " { $vocab-link "graphviz.render" } " vocabulary defines a corresponding word that calls " { $link graphviz } " with that layout engine already supplied as an argument. For instance, instead of writing" { $code "graph path format \"dot\" graphviz" } "you can simply write" { $code "graph path format dot" }
$nl
"The following words are defined:"
{ $subsections circo dot fdp neato osage sfdp twopi } ;

ARTICLE: { "graphviz.render" "formats" } "Rendering graphs by output format"
"For each output format listed in " { $url "https://graphviz.org/content/output-formats" } ", the " { $vocab-link "graphviz.render" } " vocabulary defines a corresponding word that calls " { $link graphviz* } " with that format already supplied as an argument. For instance, instead of writing" { $code "graph path \"png\" graphviz*" } "you can simply write" { $code "graph path png" }
$nl
"In the case of the " { $snippet "dot" } " output format (which already has the " { $link dot } " shortcut defined for the layout engine), the shortcut function is named " { $link dot-file } "."
$nl
"The following words are defined:"
{ $subsections bmp canon dot-file xdot cmap eps fig gd gd2 gif ico imap cmapx imap_np cmapx_np ismap jpg jpeg jpe pdf plain plain-ext png ps ps2 svg svgz tif tiff vml vmlz vrml wbmp webp } ;

ARTICLE: "graphviz.render" "Rendering Graphviz output"
"The " { $vocab-link "graphviz.render" } " vocabulary provides words for converting " { $link graph } " objects into equivalent Graphviz output. This is done by using the " { $vocab-link "graphviz.dot" } " vocabulary to convert the Factor objects into equivalent DOT code, then invoking Graphviz upon the result."
$nl
"The most general words in this vocabulary will have you manually specify the desired layout engine and/or output format, along with a file to which Graphviz should save its output:"
{ $subsections
    graphviz
    graphviz*
}

"If the graph is small enough, it may be convenient to see an image of it using Factor's UI listener:"
{ $subsections
    preview
    preview-window
}

"A few global variables are used to control the above words:"
{ $subsections
    default-layout
    graph-encoding
    preview-format
}

"Shortcut words are also defined to save on extra typing:"
{ $subsections
    { "graphviz.render" "layouts" }
    { "graphviz.render" "formats" }
}
;

ABOUT: "graphviz.render"
