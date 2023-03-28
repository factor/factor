! Copyright (C) 2012 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel ;
IN: folder.compare

ARTICLE: "folder.compare" "folder.compare"
{ $vocab-link "folder.compare" }
"
Provides tools to compare two folders and then operate on the results. 
The folders are sepecified as the src (source) folder and the dst (destination) folder. 
The contents of the folders are treated like sets permitting operations such as the union, intersection, and difference. 

Union
The union of two folders will be the files present in either src or dst which do not contain duplicate values.
see https://en.wikipedia.org/wiki/Union_(set_theory)

Intersection
The intersection of two folders will be the files present in both folders and are not duplicated. 
see https://en.wikipedia.org/wiki/Intersection_(set_theory)

Difference
The difference of two folders will be the files present in the src folder but not in the dst folder without any duplicates.
see https://en.wikipedia.org/wiki/Complement_(set_theory)#Relative_complement

"
;

ABOUT: "folder.compare"

HELP: <folder-compare>
{ $values { "src" "path to source folder" } { "dst" "path to destination folder" } { "folder.compare" "value" } }
{ $description "Creates an instance of a folder-compare object." }
;

HELP: folder-compare
{ $var-description "" } ;

  
HELP: set-dir-word
{ $values { "folder.compare" "folder.compare" } { "t|f" boolean } { "folder.compare'" "folder.compare" } }
{ $description "Sets the property for deep or shallow inspection" }
;
