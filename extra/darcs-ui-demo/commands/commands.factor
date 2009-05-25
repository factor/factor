USING: arrays closures continuations darcs-ui io.encodings.utf8
io.launcher kernel regexp sequences fries xml xml.data xml.traversal
ui.gadgets.alerts ;
IN: darcs-ui-demo.commands

: extract ( tag name -- string ) tag-named children>string ;
: prepare-patches ( changelog -- table-columns )
   string>xml "patch" tags-named
      [  [ "name" extract ]
         [ [ "author" attr ] [ "local_date" attr ] bi ]
         bi 3array
      ] map ;
: patches ( method search -- table-columns )
   [ drop "" ] [ i" --_ \"_\"" ] if-empty
   i" darcs changes --xml-output _" run-desc prepare-patches ;

: whatsnew ( -- matches ) "darcs whatsnew" run-desc R/ ^[^+-].*/m all-matching-subseqs ;

: pull ( repo -- ) i" darcs pull -a _" [ try-process ] [ 2drop "Can't connect" alert* ] recover ; inline
: repo-push ( repo -- ) i{ "darcs" "push" "-a" _ } [ try-process ] [ 2drop "Push refused" alert* ] recover ; inline
: send ( repo -- ) i{ "darcs" "send" "-a" _ } [ try-process ] [ 2drop "Sending failed" alert* ] recover ; inline
: app ( file -- ) i{ "darcs" "apply" "-a" _ } [ try-process ] [ 2drop "Applying failed" alert* ] recover ; inline
: record ( quot name author -- ) i{ "darcs" "record" "--skip-long-comment" "-m" _ "--author" _ }
   utf8 rot with-process-writer ; inline

: cnts ( file patch -- result ) i" exact \"_\"" swap i{ "darcs" "show" "contents" "--match" _ _ }
   [ run-desc ] [ 2drop "File doesn't exist for selected patch" ] recover ;
: files ( -- str ) "darcs show files" [ run-desc ] [ drop "Error showing files" alert* ] recover ;

: init-repo ( -- ) "darcs init" try-process ;
: add-repo-file ( files -- ) { "darcs" "add" "-r" } prepend
   [ try-process ] [ 2drop "File already exists in repository" alert* ] recover ;
: remove-repo-file ( files -- ) { "darcs" "remove" } prepend
   [ try-process ] [ 2drop "File doesn't exist in repository" alert* ] recover ;