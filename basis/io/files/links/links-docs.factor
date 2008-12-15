IN: io.files.links

HELP: make-link
{ $values { "target" "a path to the symbolic link's target" } { "symlink" "a path to new symbolic link" } }
{ $description "Creates a symbolic link." } ;

HELP: read-link
{ $values { "symlink" "a path to an existing symbolic link" } { "path" "the path pointed to by the symbolic link" } }
{ $description "Reads the symbolic link and returns its target path." } ;

HELP: copy-link
{ $values { "target" "a path to an existing symlink" } { "symlink" "a path to a new symbolic link" } }
{ $description "Copies a symbolic link without following the link." } ;

{ make-link read-link copy-link } related-words

ARTICLE: "io.files.links" "Symbolic links"
"Reading and creating links:"
{ $subsection read-link }
{ $subsection make-link }
"Copying links:"
{ $subsection copy-link }
"Not all operating systems support symbolic links."
{ $see-also link-info } ;

ABOUT: "io.files.links"
