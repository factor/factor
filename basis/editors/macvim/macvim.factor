USING: core-foundation.launch-services editors.vim io.pathnames
io.standard-paths kernel namespaces ;
IN: editors.macvim

SINGLETON: macvim
macvim \ vim-editor set-global

: find-macvim-bundle-path ( -- path/f )
    "org.vim.MacVim" find-native-bundle [
        "Contents/MacOS/Vim" append-path
    ] [
        f
    ] if* ;
    
M: macvim find-vim-path
    find-macvim-bundle-path "mvim" or ;

M: macvim vim-detached? t ;
M: macvim vim-ui? t ;
