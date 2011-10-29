USING: editors.vim environment fry io.files io.pathnames kernel
namespaces sequences splitting ;
IN: editors.macvim

SINGLETON: macvim
macvim \ vim-editor set-global

: find-binary-path ( string -- path/f )
    [ "PATH" os-env ":" split ] dip '[ _ append-path exists? ] find nip ;

M: macvim find-vim-path "mvim" find-binary-path { "open" "-a" "MacVim" } or ;
M: macvim vim-detached? t ;
M: macvim vim-open-line? f ;
