USING: definitions editors help help.markup help.syntax
io io.files io.pathnames words ;
IN: editors.vim

ABOUT: { "vim" "vim" }

ARTICLE: { "vim" "vim" } "Vim support"
"This module makes the " { $link edit } " word work with Vim by setting the " { $link edit-hook } " global variable to call " { $link vim } "."
$nl
"The " { $link vim-path } " variable contains the name of the vim executable. The default " { $link vim-path } " is " { $snippet "\"vim\"" } ". Which is not very useful, as it starts vim in the same terminal where you started factor."
{ $list
    { "If you want to use gvim instead or are on a Windows platform use " { $vocab-link "editors.gvim" } "." }
    { "If you want to start vim in an extra terminal, use something like this:" { $code "{ \"urxvt\" \"-e\" \"vim\" } vim-path set-global" } "Replace " { $snippet "urxvt" } " by your terminal of choice." }
}
$nl
"You may also wish to install Vim support files to enable syntax hilighting and other features. These are in the " { $link resource-path } " in " { $snippet "misc/vim" } "."
{ $see-also "editor" }
;
