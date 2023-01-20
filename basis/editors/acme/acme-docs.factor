! Copyright (C) 2020 Fred Alger.
! See https://factorcode.org/license.txt for BSD license.
USING: editors.acme help.markup help.syntax ;
IN: editors.acme

ABOUT: "editors.acme"

ARTICLE: "editors.acme" "Plan9 acme editor support"
"This editor invokes the Plan9 `plumb` command. "
"With the default Plan 9 plumbing, this will open acme."
$nl
"The path to the Plan9 installation is determined by "
{ $link plan9-path }
{ $see-also "editor" } ;

HELP: plan9-path
{ $values { "path" "a pathname string" } }
{ $description
"Find the local installation of Plan9 from user space."
"The " { $link plan9-path } " word will try to locate your Plan9"
" installation. In order of preference this word checks:"
$nl
{ $list
  { "The " { $link plan9-path } " global" }
  "The PLAN9 environment variable"
}
$nl
"Finally, if neither is available, falls back to "
"/usr/local/plan9, the default installation path." } ;
