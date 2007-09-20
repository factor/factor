USING: definitions editors.vim help help.markup help.syntax io io.files
editors words ;

ARTICLE: { "vim" "vim" } "Vim support"
"This module makes the " { $link edit } " word work with Vim by setting the " { $link edit-hook } " global variable to call " { $link vim-location } ". The " { $link vim-path } " variable contains the name of the vim executable.  The default " { $link vim-path } " is " { $snippet "\"gvim\"" } "."
$nl
"If you intend to use this module regularly, it helps to have it load during stage 2 bootstrap. On Windows, place the following example " { $snippet ".factor-boot-rc" } " in the directory returned by " { $link home } ":"
{ $code
"USING: modules namespaces ;"
"REQUIRES: libs/vim ;"
"USE: vim"
"\"c:\\\\program files\\\\vim\\\\vim70\\\\gvim\" vim-path set-global"
}
"On Unix, you may omit the last line if " { $snippet "\"vim\"" } " is in your " { $snippet "$PATH" } "."
$nl
"If you are running the terminal version of Vim, you want it to block Factor until exiting, but for GVim the opposite is desired, so that one can work in Factor and GVim concurrently. The " { $link vim-detach } " global variable can be set to " { $link t } " to detach the Vim process. The default is " { $link f } "." ;

