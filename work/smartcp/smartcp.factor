USING: accessors combinators command-line io io.directories kernel
namespaces sequences ui ui.gadgets.labels vectors ;

IN: smartcp

SYMBOL: src
SYMBOL: dst
SYMBOL: mode

: show-results ( seq -- )
    [ print ] each
    ;

: get-args ( args -- )
    >vector
    [ pop ] keep
    [ pop ] keep
    pop mode set
    src set
    dst set
    ;

: usage ( -- )
    "smartcp [ [-move [-prune] ] | [-mode=diff|intersect|union] ] ] [-R] [-filter regexp] src=path dest=path" print
    "  A utility to compare folders by content and optionally move files. You may use this utility" print
    "  when the timestamps of the files are not correct or cannot be used because the system has" print
    "  updated the timestamps. With no options the default is to report the difference bewteen two " print
    "  directories, items in the source that are not present in the desination." print
    "" print
    "    -deep    If source_file designates a directory, cp copies the directory and the entire subtree connected at that" print
    "           point.  If the source_file ends in a /, the contents of the directory are copied rather than the directory" print
    "           itself.  This option also causes symbolic links to be copied, rather than indirected through, and for cp" print
    "           to create special files rather than copying them as normal files.  Created directories have the same mode" print
    "           as the corresponding source directory, unmodified by the process' umask." print
    "" print
    "           In -R mode, cp will continue copying even if errors are detected." print
    "" print
    "           Note that cp copies hard-linked files as separate files.  If you need to preserve hard links, consider" print
    "  -src=path The source path must be present." print
    "  -dst=path The destination path must be present." print
    "  -mode=  Sets the mode of operation" print
    "    diff Difference, show items in source-path not in dest-path." print
    "    intersect Intersection, show items present in both source and destination." print
    "    union Union, show items in either source or destination with no duplicates." print
    "    md-compare MD Compare, source folder is comapred to destination folder, " print
    "      items with duplicate content are reported" print
    "  -move Move, items in the source are moved to destination if same name" print
    "     AND content is different. Items absent in destination are moved from source. " print
    "     Items absent from the source are optionally pruned (-prune0 from destination." print
    "  -prune items not in the source will be deleted in the destination if present." print
    "     Only permitted with the -move option" print
    "     if different" print
    ;

FROM: io.directories => directory-diff directory-intersect directory-union directory-md5diff directory-move ;

: smartcp-mode ( folder.compare -- seq )
    "mode" get-global {
        { "diff" [ directory-diff ] }
        { "intersect" [ directory-intersect ] }
        { "union" [ directory-union ] }
        { "mddiff" [ directory-md5diff ] }
        [ drop usage ]
    } case
    ;

FROM: string => to-folder ;
: smartcp ( -- )
    [ "diff" "mode" set-global
      f "deep" set-global
      regexp-nothing "filter" set-global
      command-line get
      parse-command-line
      "src" get-global  
      "dst" get-global 
      "filter" get-global
      "deep" get-global
      new-folder-compare
      "move" get-global
      [ directory-move ]
      [ smartcp-mode ]
      if
      show-results
    ] with-global
    ;

: smartcp-test ( args -- )
    command-line set
    smartcp
    ;

CONSTANT: f1 "/Sources/OpenPrograph/XMacVPL/Source Marten/CE IDE Project.app/Contents/Frameworks/MartenEngine.framework"
CONSTANT: f2 "/Sources/OpenPrograph/XMacVPL/Frameworks/MartenEngine.framework"
CONSTANT: f3 "/Volumes/Space\ 2008/Marten/Marten\ 2006/Andescotia/Marten\ 1.2.x/54.00/XMacVPL\ 54.16\ Framework\ Addresses/"
CONSTANT: f4 "/Volumes/Space\ 2008/Marten/XMacVPL\ Archive/"
CONSTANT: f5 "/Applications/Marten/Marten.app"
CONSTANT: f6 "/Applications/Marten/Marten\ Server\ 007.app/"
CONSTANT: f7 "/Users/davec/Dropbox/Private/Library/Application\ Support/1Password"
CONSTANT: f8 "/Users/davec/Dropbox/Application\ Support/1Password"

: smartcp-md ( -- )
    { }
    "-mode=diff" suffix
    "-progress" suffix
    "-filter=[.].*" suffix
    "-deep" suffix 
    "-src=" f7 append suffix
    "-dst=" f8 append suffix
    smartcp-test
    ;

MAIN: smartcp

MAIN-WINDOW: smarty
{ { title "SmartCP" } }
"Smart Copy" <label> { 30 30 } <border> { 4 4 } >>fill { 3 3 } <border> "Test" <labeled-gadget>
>>gadgets ;

