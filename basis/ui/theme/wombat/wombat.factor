USING: colors ui.theme ;
IN: ui.theme.wombat
SINGLETON: wombat-theme

! This is a port of the `wombat` theme from emacs, adapted with permission from
! Kristoffer Grönlund, who, in turn, adapted it from the Vim color scheme by
! Lars H. Nielsen.

M: wombat-theme toolbar-background COLOR: #454545 ;
M: wombat-theme toolbar-button-pressed-background COLOR: #242424 ;

M: wombat-theme menu-background COLOR: #384048 ;
M: wombat-theme menu-border-color COLOR: #a0a8b0 ;

M: wombat-theme status-bar-background COLOR: #384048 ;
M: wombat-theme status-bar-foreground COLOR: white ;

M: wombat-theme button-text-color COLOR: #303030 ;
M: wombat-theme button-clicked-text-color COLOR: white ;

M: wombat-theme line-color COLOR: #656565 ;

M: wombat-theme column-title-background COLOR: #384048 ;

M: wombat-theme roll-button-rollover-border COLOR: #a0a8b0 ;
M: wombat-theme roll-button-selected-background COLOR: #a0a8b0 ;

M: wombat-theme source-files-color COLOR: #95e454 ;
M: wombat-theme errors-color COLOR: #e5786d ;
M: wombat-theme details-color COLOR: #8ac6f2 ;

M: wombat-theme debugger-color COLOR: #e5786d ;
M: wombat-theme completion-color COLOR: #3f9f9e ;

M: wombat-theme data-stack-color COLOR: #8ac6f2 ;
M: wombat-theme retain-stack-color COLOR: #95e454 ;
M: wombat-theme call-stack-color COLOR: #3f9f9e ;

M: wombat-theme title-bar-gradient { COLOR: #242424 COLOR: #454545 } ;

M: wombat-theme popup-color COLOR: #ddaa6f ;

M: wombat-theme object-color COLOR: #8ac6f2 ;
M: wombat-theme contents-color COLOR: #95e454 ;

M: wombat-theme help-header-background COLOR: #384048 ;

M: wombat-theme thread-status-stopped-background COLOR: #333333 ;
M: wombat-theme thread-status-suspended-background COLOR: #242424 ;
M: wombat-theme thread-status-running-background COLOR: #444444 ;

M: wombat-theme thread-status-stopped-foreground COLOR: #8ac6f2 ;
M: wombat-theme thread-status-suspended-foreground COLOR: #ddaa6f ;
M: wombat-theme thread-status-running-foreground COLOR: #95e454 ;

M: wombat-theme error-summary-background COLOR: #b85149 ;

M: wombat-theme content-background COLOR: #242424 ;
M: wombat-theme text-color COLOR: #f6f3e9 ;

M: wombat-theme link-color COLOR: #8ac6f2 ;
M: wombat-theme title-color COLOR: #a0a8b0 ;
M: wombat-theme heading-color COLOR: #a0a8b0 ;
M: wombat-theme snippet-color COLOR: #e5786d ;
M: wombat-theme output-color COLOR: #e5786d ;
M: wombat-theme deprecated-background-color COLOR: #454545 ;
M: wombat-theme deprecated-border-color COLOR: #92a65e ;
M: wombat-theme warning-background-color COLOR: #454545 ;
M: wombat-theme warning-border-color COLOR: #8ac6f2 ;
M: wombat-theme code-background-color COLOR: #303030 ;
M: wombat-theme code-border-color COLOR: white ;
M: wombat-theme help-path-border-color COLOR: #384048 ;

M: wombat-theme tip-background-color COLOR: #303030 ;

M: wombat-theme prompt-background-color COLOR: #92a65e ;

M: wombat-theme dim-color COLOR: #8ac6f2 ;
M: wombat-theme highlighted-word-color COLOR: #95e454 ;
M: wombat-theme string-color COLOR: #95e454 ;
M: wombat-theme stack-effect-color COLOR: #e5786d ;

M: wombat-theme vocab-background-color COLOR: #303030 ;
M: wombat-theme vocab-border-color COLOR: #a0a8b0 ;

M: wombat-theme field-border-color COLOR: #a0a8b0 ;

M: wombat-theme editor-caret-color COLOR: #92a65e ;
M: wombat-theme selection-color COLOR: #444444 ;
M: wombat-theme panel-background-color COLOR: #444444 ;
M: wombat-theme focus-border-color COLOR: #a0a8b0 ;

M: wombat-theme labeled-border-color COLOR: #303030 ;

M: wombat-theme table-border-color COLOR: #a0a8b0 ;
