USING: editors.vim kernel namespaces ;
IN: editors.macvim

SINGLETON: macvim
macvim \ vim-editor set-global

M: macvim vim-path \ vim-path get-global "mvim" or ;
M: macvim vim-detached? t ;
