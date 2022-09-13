! Copyright (C) 2015 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: calendar calendar.format images.loader io.directories vocabs regexp accessors combinators.smart
io.directories.hierarchy io.pathnames kernel memory namespaces sequences ui.theme.switching
ui.images splitting system io.files io.encodings.utf8 math effects math.order
code.import-export parser help help.markup words debugger ;

! Setting Skov version in YYYY-MM format
gmt timestamp>ymd 7 head skov-version set-global

! Setting the Factor directory as working directory
image-path parent-directory set-current-directory

! Loading all bitmaps into the image
{ 
  "vocab:definitions/icons/"
  "vocab:ui/theme/images"
  "vocab:ui/tools/error-list/icons"
} [ 
  dup directory-files
  [ first CHAR: . = ] reject
  [ file-extension [ "png" = ] [ "tiff" = ] bi or ] filter
  [ "@2x" split1-last nip  f = ] filter
  [ dupd append-path <image-name> cached-image drop ] each drop
] each

! Modifying the macOS bundle and removing unused files
os macosx = [
  "factor" delete-file
  "libfactor-ffi-test.dylib" delete-file
  "libfactor.dylib" delete-file
  "Factor.app" "Skov.app" move-file
  "Skov.app/Contents/MacOS/factor" "Skov.app/Contents/MacOS/skov" move-file
  "misc/icons/Skov.icns" "Skov.app/Contents/Resources/Skov.icns" move-file
  "misc/fonts" "Skov.app/Contents/Resources/Fonts" move-file
  "Skov.app/Contents/Resources/Factor.icns" delete-file

  "Skov.app/Contents/Info.plist" utf8 [
    ">factor<" ">skov<" replace
    ">Factor<" ">Skov<" replace 
    "Factor developers<" "Factor and Skov developers<" replace
    "Factor.icns" "Skov.icns</string>
    <key>ATSApplicationFontsPath</key>
    <string>Fonts" replace
  ] change-file-contents 
] when

! Removing unused files on Windows
os windows = [
  "factor.exe" "skov.exe" move-file
  "factor.dll" delete-file
  "libfactor-ffi-test.dll" delete-file
  ".dir-locals.el" delete-file
  "factor.com" delete-file
] when

! Loading the changes made to Factor
"changes" recursive-directory-files
[ file-extension "factor" = ] filter
[ run-file ] each

! Running the help.stylesheet vocabulary to update the fonts
"vocab:help/stylesheet/stylesheet.factor" run-file

! Deleting all Factor code files and other stuff
{ "basis"
  "core"
  "extra"
  "misc"
  "changes"
  "vm"
} [ [ delete-tree ] try ] each
{ "work/README.txt"
  "README.md"
  "git-id"
  "make-skov.factor"
  "boot.unix-x86.64.image"
  "build.cmd"
  "build.sh"
  "factor.image.fresh"
  "GNUmakefile"
  "Nmakefile"
  ".gitignore"
  ".gitattributes"
  ".travis.yml"
  ".dir-locals.el"
} [ ?delete-file ] each

! Choosing dark mode
dark-mode

! Changing stack-effects
\ + { "num" "num" } { "num" } <effect> "declared-effect" set-word-prop
\ - { "num" "num'" } { "num" } <effect> "declared-effect" set-word-prop
\ * { "num" "num" } { "num" } <effect> "declared-effect" set-word-prop
\ / { "num" "num'" } { "num" } <effect> "declared-effect" set-word-prop
\ and { "?" "?" } { "?" } <effect> "declared-effect" set-word-prop
\ or { "?" "?" } { "?" } <effect> "declared-effect" set-word-prop
\ xor { "?" "?'" } { "?" } <effect> "declared-effect" set-word-prop
\ min { "obj" "obj" } { "obj" } <effect> "declared-effect" set-word-prop
\ max { "obj" "obj" } { "obj" } <effect> "declared-effect" set-word-prop
\ compose { "quot" "quot" } { "quot" } <effect> "declared-effect" set-word-prop
\ append { "seq" "seq" } { "seq" } <effect> "declared-effect" set-word-prop

! Renaming every word
all-words [ [
    R/ .{2,}-.{2,}/ [ "-" " " replace ] re-replace-with
    R/ .+>>/ [ ">" "" replace " (accessor)" append ] re-replace-with
    R/ >>.+/ [ ">" "" replace " (mutator)" append ] re-replace-with
    R/ <.+>/ [ ">" "" replace "<" "" replace " (constructor)" append ] re-replace-with
    R/ >.+</ [ ">" "" replace "<" "" replace " (destructor)" append ] re-replace-with
    [ "+" = ] [ drop "add" ] smart-when
    [ "-" = ] [ drop "sub" ] smart-when
    [ "*" = ] [ drop "mul" ] smart-when
    [ "/" = ] [ drop "div" ] smart-when
    [ "." = ] [ drop "disp" ] smart-when
    [ "gadget." = ] [ drop "disp gadget" ] smart-when
    [ "e^" = ] [ drop "exp" ] smart-when
    [ "^" = ] [ drop "pow" ] smart-when
    [ "2^" = ] [ drop "pow2" ] smart-when
    [ "10^" = ] [ drop "pow10" ] smart-when
  ] change-name drop
] each

! Updating the help page of every word
all-words [ [ 
    [ "help" word-prop [ \ $description swap member? ] filter ]
    [ word-help* swap append ]
    [ swap "help" set-word-prop ] tri
  ] try
] each

! Saving and renaming the image
save
"factor.image" "skov.image" move-file
0 exit
