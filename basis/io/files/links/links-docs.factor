USING: help.markup help.syntax io.files.info math ;
IN: io.files.links

HELP: make-link
{ $values { "target" "a path to the symbolic link's target" } { "symlink" "a path to new symbolic link" } }
{ $description "Creates a symbolic link." } ;

HELP: make-hard-link
{ $values { "target" "a path to the hard link's target" } { "link" "a path to new symbolic link" } }
{ $description "Creates a hard link." } ;

HELP: read-link
{ $values { "symlink" "a path to an existing symbolic link" } { "path" "the path pointed to by the symbolic link" } }
{ $description "Reads the symbolic link and returns its target path." } ;

HELP: copy-link
{ $values { "target" "a path to an existing symlink" } { "symlink" "a path to a new symbolic link" } }
{ $description "Copies a symbolic link without following the link." } ;

HELP: follow-link
{ $values
    { "path" "a pathname string" }
    { "path'" "a pathname string" }
}
{ $description "Returns an absolute path from " { $link read-link } "." } ;

HELP: follow-links
{ $values
    { "path" "a pathname string" }
    { "path'" "a pathname string" }
}
{ $description "Follows a chain of symlinks up to " { $link symlink-depth } "." } ;

{ read-link follow-link follow-links } related-words

HELP: symlink-depth
{ $values
    { "value" integer }
}
{ $description "The number of redirections " { $link follow-links } " will follow." } ;

HELP: too-many-symlinks
{ $values
    { "path" "a pathname string" } { "n" integer }
}
{ $description "An error thrown when the number of redirections in a chain of symlinks surpasses the value in the " { $link symlink-depth } " variable." } ;

ARTICLE: "io.files.links" "Symbolic links"
"Reading links:"
{ $subsections
    read-link
    follow-link
    follow-links
}
"Creating links:"
{ $subsections make-link }
"Copying links:"
{ $subsections copy-link }
"Not all operating systems support symbolic links."
{ $see-also link-info } ;

ABOUT: "io.files.links"
