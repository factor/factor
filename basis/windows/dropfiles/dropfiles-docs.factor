! Copyright (C) 2017-2018 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays help.markup help.syntax kernel math
ui.backend.windows ui.gestures windows.types ;
IN: windows.dropfiles

ABOUT: "windows-dropfiles"

ARTICLE: "windows-dropfiles" "File drop gesture for Windows"
"A window has to declare whether it wants to accept dropped files. By default files are rejected:"
{ $subsections
    accept-files
    reject-files
    world-accept-files
    world-reject-files
}
"When user drops files onto a window, the target gadget may handle the corresponding gesture:"
{ $subsections file-drop }
"Implementation details:"
{ $subsections
    "about-dragdrop"
    init-message-filter
} ;

ARTICLE: "about-dragdrop" "File drag-and-drop in Windows"
"There are two mechanisms in Windows that can be used to drag-and-drop files across applications:"
{ $list
    { { $snippet "WM_DROPFILES" } " - was introduced back in the early days, it is a message that's posted to a window's message queue after the user has dropped some files on it. While handling the message, the application can fetch the list of the dropped files and the mouse position of the drop." }
    { { $snippet "IDropTarget" } " - an OLE reinvention of the same. It provides more fine-grained capabilities of dynamically accepting or rejecting the drop based on the mouse location and the contents of the drop, while the user still drags the files over the window." }
}
"Windows Vista has introduced some security features that made it impossible for the OLE to work between two applications with different security tokens. E.g. if one of the applications is ran with administrative privileges, and the other is without, the OLE drag-and-drop will not work between them."
$nl
"By default, WM_DROPFILES doesn't work either, because the necessary window messages are filtered out from the queue, but it is possible to configure the filters and make it work, see " { $link init-message-filter } "." ;

HELP: init-message-filter
{ $description "Call " { $snippet "ChangeWindowMessageFilter" } " to allow the window messages necessary for file dropping pass through the filters. This will have a process-wide effect, and will only be called once."
$nl
"The API function is only available since Windows Vista, and is not needed in earlier versions. On Windows XP the missing function will cause an exception on the first call, which will be suppressed, and no more calls will be made." }
{ $notes "It is generally preferrable to use " { $snippet "ChangeWindowMessageFilterEx" } ", because it has a per-window-handle effect, thus gives a more fine-grained security control. Unfortunately, the " { $snippet "Ex" } "-version is only available since Windows 7, and in any case the " { $link add-wm-handler } " has global effect for all Factor native windows, so it's not like we are exposing any additional code to potential exploitation." } ;

HELP: filecount-from-hdrop
{ $values
    { "hdrop" HDROP }
    { "n" number }
}
{ $description "Return the number of files in the drop." } ;

HELP: filenames-from-hdrop
{ $values
    { "hdrop" HDROP }
    { "filenames" array }
}
{ $description "Return an array of file names in the drop. Each file name is a string with a full path to a file or a folder." } ;
