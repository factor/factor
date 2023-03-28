! Copyright (C) 2011 PolyMicro Systems.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax ;

IN: dropbox

ABOUT: dropbox

ARTICLE: "dropbox" "Dropbox utility words for MacOSX"
"This is a set of words to create links from your ~/Library/folder to your ~/Dropbox folder on client computers. The idea is to create a folder structure in your Dropbox folder which mirrors the folders in your ~/Library. Then on other computers using your Dropbox account, you run words from this vocabulary to create the symlinks. I worte these words as my first attempt in learning Factor and as such they are not the most robust or efficeint code possible. I did strive to insure no data is lost and to be safe when moving things around."
;

HELP: db-library-folder 
{ $values { "path" "Path to ~/Dropbox/Private/Library folder" } }
{ $description "You should change this if your folder is in a different location" }
;
    
HELP: db-is-linked-to-db? 
{ $values
  { "symlink" "Symbolic link to a folder" }
  { "?" "True if symlink is not linked to Dropbox folder" }
}
{ $description "Determines if a symlink points to an entry in the Dropbox folder. If it does, return false, else reanme the entry and return t" }
{ $see-also db-check-symbolic? db-moved-path? }
;

HELP: db-check-symbolic? 
{ $values
  { "path" "Path to a folder in ~/Library" }
  { "?" "True if path is not a symlink" }
}
  { $description "Determines if a path is a symbolic link. If is, it calls " { $link db-is-linked-to-db? } " to see if the path is linked to a Dropbox folder. Existing symlinks to Dropbox folders are not touched as it is assumed they are already setup. If the path is not symbolic, rename the folder and return t." }
  { $see-also db-is-linked-to-db? db-moved-path? }
;

HELP: db-moved-path? 
{ $values
  { "path" "Path to a folder in ~/Library" }
  { "?" "True if path was not renamed" }
}
{ $description "Determines if a path currently exists and calls words to rename it if it does as long as the existing path is not a symlink to the Dropbox folder." }
  { $see-also db-check-symbolic? }
;

HELP: do-appsupport 
{ $values { "folder" "Folder in the Dropbox" } }
{ $description "Processes the \"~/Library/Application Support\" folder by taking the content of the \"~/Dropbox/Private/Library/Application Support\" and creating a sequence containing all of the folders in it which are not already symlinked to the users Library. For each Dropbox folder, the equivilent user Library folder is examined. If a link to the Dropbox folder alreasy exists it is skipped. If a folder is already existing in the user Library, it is renamed so as not to delete anything and can be compared later if any content needs to be merged into the Dropbox." }
  ;

HELP: db-process-folder
  { $values { "folder" "" } }
  { $description "Determine if the Dropbox folder is the \"Application Support\" mirror" }
;

HELP: db-process-item 
  { $values { "folder" "Folder in the Dropbox" } }
  { $description "Process a Dropbox folder" }
;

HELP: db-library-item 
  { $values { "folder-entry" "Folder in the Dropbox" } }
  { $description "If the folder-enrty is a folder it is processed. Regular files are skipped" }
;

HELP: db-main
  { $description "This is the main utility word which will examine the content of the Dropbox Libraryfolder. Each folder in the tree represent a mirror to the users Library. Symbolic links are created in the users Library which point to the Dropbox folder. Any existing folders in the users Library are moved aside for later merging into the Dropbox Library. Progress is reported to the standard output stream and should be examined for any errors or warnings" }
;