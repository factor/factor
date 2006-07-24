! Copyright (C) 2005, 2006 Doug Coleman.
! See http://factor.sf.net/license.txt for BSD license.
USING: hashtables kernel math namespaces parser prettyprint words ;
IN: win32-api-messages

SYMBOL: windows-messages

USE: inspector

: maybe-create-windows-messages
    windows-messages get hashtable? 
    [ H{ } clone global [ windows-messages set ] bind ] unless ;

: add-windows-message ( -- )
    word [ unparse ] keep execute maybe-create-windows-messages
    windows-messages get set-hash ; parsing

: get-windows-message-name ( n -- name )
    windows-messages get hash* [ drop "unknown message" ] unless ;

: WM_NULL HEX: 0000 ; inline add-windows-message
: WM_CREATE HEX: 0001 ; inline add-windows-message
: WM_DESTROY HEX: 0002 ; inline add-windows-message
: WM_MOVE HEX: 0003 ; inline add-windows-message
: WM_SIZE HEX: 0005 ; inline add-windows-message
: WM_ACTIVATE HEX: 0006 ; inline add-windows-message
: WM_SETFOCUS HEX: 0007 ; inline add-windows-message
: WM_KILLFOCUS HEX: 0008 ; inline add-windows-message
: WM_ENABLE HEX: 000A ; inline add-windows-message
: WM_SETREDRAW HEX: 000B ; inline add-windows-message
: WM_SETTEXT HEX: 000C ; inline add-windows-message
: WM_GETTEXT HEX: 000D ; inline add-windows-message
: WM_GETTEXTLENGTH HEX: 000E ; inline add-windows-message
: WM_PAINT HEX: 000F ; inline add-windows-message
: WM_CLOSE HEX: 0010 ; inline add-windows-message
: WM_QUERYENDSESSION HEX: 0011 ; inline add-windows-message
: WM_QUERYOPEN HEX: 0013 ; inline add-windows-message
: WM_ENDSESSION HEX: 0016 ; inline add-windows-message
: WM_QUIT HEX: 0012 ; inline add-windows-message
: WM_ERASEBKGND HEX: 0014 ; inline add-windows-message
: WM_SYSCOLORCHANGE HEX: 0015 ; inline add-windows-message
: WM_SHOWWINDOW HEX: 0018 ; inline add-windows-message
: WM_WININICHANGE HEX: 001A ; inline add-windows-message
: WM_SETTINGCHANGE HEX: 001A ; inline add-windows-message
: WM_DEVMODECHANGE HEX: 001B ; inline add-windows-message
: WM_ACTIVATEAPP HEX: 001C ; inline add-windows-message
: WM_FONTCHANGE HEX: 001D ; inline add-windows-message
: WM_TIMECHANGE HEX: 001E ; inline add-windows-message
: WM_CANCELMODE HEX: 001F ; inline add-windows-message
: WM_SETCURSOR HEX: 0020 ; inline add-windows-message
: WM_MOUSEACTIVATE HEX: 0021 ; inline add-windows-message
: WM_CHILDACTIVATE HEX: 0022 ; inline add-windows-message
: WM_QUEUESYNC HEX: 0023 ; inline add-windows-message
: WM_GETMINMAXINFO HEX: 0024 ; inline add-windows-message
: WM_PAINTICON HEX: 0026 ; inline add-windows-message
: WM_ICONERASEBKGND HEX: 0027 ; inline add-windows-message
: WM_NEXTDLGCTL HEX: 0028 ; inline add-windows-message
: WM_SPOOLERSTATUS HEX: 002A ; inline add-windows-message
: WM_DRAWITEM HEX: 002B ; inline add-windows-message
: WM_MEASUREITEM HEX: 002C ; inline add-windows-message
: WM_DELETEITEM HEX: 002D ; inline add-windows-message
: WM_VKEYTOITEM HEX: 002E ; inline add-windows-message
: WM_CHARTOITEM HEX: 002F ; inline add-windows-message
: WM_SETFONT HEX: 0030 ; inline add-windows-message
: WM_GETFONT HEX: 0031 ; inline add-windows-message
: WM_SETHOTKEY HEX: 0032 ; inline add-windows-message
: WM_GETHOTKEY HEX: 0033 ; inline add-windows-message
: WM_QUERYDRAGICON HEX: 0037 ; inline add-windows-message
: WM_COMPAREITEM HEX: 0039 ; inline add-windows-message
: WM_GETOBJECT HEX: 003D ; inline add-windows-message
: WM_COMPACTING HEX: 0041 ; inline add-windows-message
: WM_COMMNOTIFY HEX: 0044 ; inline add-windows-message
: WM_WINDOWPOSCHANGING HEX: 0046 ; inline add-windows-message
: WM_WINDOWPOSCHANGED HEX: 0047 ; inline add-windows-message
: WM_POWER HEX: 0048 ; inline add-windows-message
: WM_COPYDATA HEX: 004A ; inline add-windows-message
: WM_CANCELJOURNAL HEX: 004B ; inline add-windows-message
: WM_NOTIFY HEX: 004E ; inline add-windows-message
: WM_INPUTLANGCHANGEREQUEST HEX: 0050 ; inline add-windows-message
: WM_INPUTLANGCHANGE HEX: 0051 ; inline add-windows-message
: WM_TCARD HEX: 0052 ; inline add-windows-message
: WM_HELP HEX: 0053 ; inline add-windows-message
: WM_USERCHANGED HEX: 0054 ; inline add-windows-message
: WM_NOTIFYFORMAT HEX: 0055 ; inline add-windows-message
: WM_CONTEXTMENU HEX: 007B ; inline add-windows-message
: WM_STYLECHANGING HEX: 007C ; inline add-windows-message
: WM_STYLECHANGED HEX: 007D ; inline add-windows-message
: WM_DISPLAYCHANGE HEX: 007E ; inline add-windows-message
: WM_GETICON HEX: 007F ; inline add-windows-message
: WM_SETICON HEX: 0080 ; inline add-windows-message
: WM_NCCREATE HEX: 0081 ; inline add-windows-message
: WM_NCDESTROY HEX: 0082 ; inline add-windows-message
: WM_NCCALCSIZE HEX: 0083 ; inline add-windows-message
: WM_NCHITTEST HEX: 0084 ; inline add-windows-message
: WM_NCPAINT HEX: 0085 ; inline add-windows-message
: WM_NCACTIVATE HEX: 0086 ; inline add-windows-message
: WM_GETDLGCODE HEX: 0087 ; inline add-windows-message
: WM_SYNCPAINT HEX: 0088 ; inline add-windows-message
: WM_NCMOUSEMOVE HEX: 00A0 ; inline add-windows-message
: WM_NCLBUTTONDOWN HEX: 00A1 ; inline add-windows-message
: WM_NCLBUTTONUP HEX: 00A2 ; inline add-windows-message
: WM_NCLBUTTONDBLCLK HEX: 00A3 ; inline add-windows-message
: WM_NCRBUTTONDOWN HEX: 00A4 ; inline add-windows-message
: WM_NCRBUTTONUP HEX: 00A5 ; inline add-windows-message
: WM_NCRBUTTONDBLCLK HEX: 00A6 ; inline add-windows-message
: WM_NCMBUTTONDOWN HEX: 00A7 ; inline add-windows-message
: WM_NCMBUTTONUP HEX: 00A8 ; inline add-windows-message
: WM_NCMBUTTONDBLCLK HEX: 00A9 ; inline add-windows-message
: WM_NCXBUTTONDOWN HEX: 00AB ; inline add-windows-message
: WM_NCXBUTTONUP HEX: 00AC ; inline add-windows-message
: WM_NCXBUTTONDBLCLK HEX: 00AD ; inline add-windows-message
: WM_INPUT HEX: 00FF ; inline add-windows-message
: WM_KEYFIRST HEX: 0100 ; inline add-windows-message
: WM_KEYDOWN HEX: 0100 ; inline add-windows-message
: WM_KEYUP HEX: 0101 ; inline add-windows-message
: WM_CHAR HEX: 0102 ; inline add-windows-message
: WM_DEADCHAR HEX: 0103 ; inline add-windows-message
: WM_SYSKEYDOWN HEX: 0104 ; inline add-windows-message
: WM_SYSKEYUP HEX: 0105 ; inline add-windows-message
: WM_SYSCHAR HEX: 0106 ; inline add-windows-message
: WM_SYSDEADCHAR HEX: 0107 ; inline add-windows-message
: WM_UNICHAR HEX: 0109 ; inline add-windows-message
: WM_KEYLAST_NT501 HEX: 0109 ; inline add-windows-message
: UNICODE_NOCHAR HEX: FFFF ; inline add-windows-message
: WM_KEYLAST_PRE501 HEX: 0108 ; inline add-windows-message
: WM_IME_STARTCOMPOSITION HEX: 010D ; inline add-windows-message
: WM_IME_ENDCOMPOSITION HEX: 010E ; inline add-windows-message
: WM_IME_COMPOSITION HEX: 010F ; inline add-windows-message
: WM_IME_KEYLAST HEX: 010F ; inline add-windows-message
: WM_INITDIALOG HEX: 0110 ; inline add-windows-message
: WM_COMMAND HEX: 0111 ; inline add-windows-message
: WM_SYSCOMMAND HEX: 0112 ; inline add-windows-message
: WM_TIMER HEX: 0113 ; inline add-windows-message
: WM_HSCROLL HEX: 0114 ; inline add-windows-message
: WM_VSCROLL HEX: 0115 ; inline add-windows-message
: WM_INITMENU HEX: 0116 ; inline add-windows-message
: WM_INITMENUPOPUP HEX: 0117 ; inline add-windows-message
: WM_MENUSELECT HEX: 011F ; inline add-windows-message
: WM_MENUCHAR HEX: 0120 ; inline add-windows-message
: WM_ENTERIDLE HEX: 0121 ; inline add-windows-message
: WM_MENURBUTTONUP HEX: 0122 ; inline add-windows-message
: WM_MENUDRAG HEX: 0123 ; inline add-windows-message
: WM_MENUGETOBJECT HEX: 0124 ; inline add-windows-message
: WM_UNINITMENUPOPUP HEX: 0125 ; inline add-windows-message
: WM_MENUCOMMAND HEX: 0126 ; inline add-windows-message
: WM_CHANGEUISTATE HEX: 0127 ; inline add-windows-message
: WM_UPDATEUISTATE HEX: 0128 ; inline add-windows-message
: WM_QUERYUISTATE HEX: 0129 ; inline add-windows-message
: WM_CTLCOLORMSGBOX HEX: 0132 ; inline add-windows-message
: WM_CTLCOLOREDIT HEX: 0133 ; inline add-windows-message
: WM_CTLCOLORLISTBOX HEX: 0134 ; inline add-windows-message
: WM_CTLCOLORBTN HEX: 0135 ; inline add-windows-message
: WM_CTLCOLORDLG HEX: 0136 ; inline add-windows-message
: WM_CTLCOLORSCROLLBAR HEX: 0137 ; inline add-windows-message
: WM_CTLCOLORSTATIC HEX: 0138 ; inline add-windows-message
: WM_MOUSEFIRST HEX: 0200 ; inline add-windows-message
: WM_MOUSEMOVE HEX: 0200 ; inline add-windows-message
: WM_LBUTTONDOWN HEX: 0201 ; inline add-windows-message
: WM_LBUTTONUP HEX: 0202 ; inline add-windows-message
: WM_LBUTTONDBLCLK HEX: 0203 ; inline add-windows-message
: WM_RBUTTONDOWN HEX: 0204 ; inline add-windows-message
: WM_RBUTTONUP HEX: 0205 ; inline add-windows-message
: WM_RBUTTONDBLCLK HEX: 0206 ; inline add-windows-message
: WM_MBUTTONDOWN HEX: 0207 ; inline add-windows-message
: WM_MBUTTONUP HEX: 0208 ; inline add-windows-message
: WM_MBUTTONDBLCLK HEX: 0209 ; inline add-windows-message
: WM_MOUSEWHEEL HEX: 020A ; inline add-windows-message
: WM_XBUTTONDOWN HEX: 020B ; inline add-windows-message
: WM_XBUTTONUP HEX: 020C ; inline add-windows-message
: WM_XBUTTONDBLCLK HEX: 020D ; inline add-windows-message
: WM_MOUSELAST_5 HEX: 020D ; inline add-windows-message
: WM_MOUSELAST_4 HEX: 020A ; inline add-windows-message
: WM_MOUSELAST_PRE_4 HEX: 0209 ; inline add-windows-message
: WM_PARENTNOTIFY HEX: 0210 ; inline add-windows-message
: WM_ENTERMENULOOP HEX: 0211 ; inline add-windows-message
: WM_EXITMENULOOP HEX: 0212 ; inline add-windows-message
: WM_NEXTMENU HEX: 0213 ; inline add-windows-message
: WM_SIZING HEX: 0214 ; inline add-windows-message
: WM_CAPTURECHANGED HEX: 0215 ; inline add-windows-message
: WM_MOVING HEX: 0216 ; inline add-windows-message
: WM_POWERBROADCAST HEX: 0218 ; inline add-windows-message
: WM_DEVICECHANGE HEX: 0219 ; inline add-windows-message
: WM_MDICREATE HEX: 0220 ; inline add-windows-message
: WM_MDIDESTROY HEX: 0221 ; inline add-windows-message
: WM_MDIACTIVATE HEX: 0222 ; inline add-windows-message
: WM_MDIRESTORE HEX: 0223 ; inline add-windows-message
: WM_MDINEXT HEX: 0224 ; inline add-windows-message
: WM_MDIMAXIMIZE HEX: 0225 ; inline add-windows-message
: WM_MDITILE HEX: 0226 ; inline add-windows-message
: WM_MDICASCADE HEX: 0227 ; inline add-windows-message
: WM_MDIICONARRANGE HEX: 0228 ; inline add-windows-message
: WM_MDIGETACTIVE HEX: 0229 ; inline add-windows-message
: WM_MDISETMENU HEX: 0230 ; inline add-windows-message
: WM_ENTERSIZEMOVE HEX: 0231 ; inline add-windows-message
: WM_EXITSIZEMOVE HEX: 0232 ; inline add-windows-message
: WM_DROPFILES HEX: 0233 ; inline add-windows-message
: WM_MDIREFRESHMENU HEX: 0234 ; inline add-windows-message
: WM_IME_SETCONTEXT HEX: 0281 ; inline add-windows-message
: WM_IME_NOTIFY HEX: 0282 ; inline add-windows-message
: WM_IME_CONTROL HEX: 0283 ; inline add-windows-message
: WM_IME_COMPOSITIONFULL HEX: 0284 ; inline add-windows-message
: WM_IME_SELECT HEX: 0285 ; inline add-windows-message
: WM_IME_CHAR HEX: 0286 ; inline add-windows-message
: WM_IME_REQUEST HEX: 0288 ; inline add-windows-message
: WM_IME_KEYDOWN HEX: 0290 ; inline add-windows-message
: WM_IME_KEYUP HEX: 0291 ; inline add-windows-message
: WM_MOUSEHOVER HEX: 02A1 ; inline add-windows-message
: WM_MOUSELEAVE HEX: 02A3 ; inline add-windows-message
: WM_NCMOUSEHOVER HEX: 02A0 ; inline add-windows-message
: WM_NCMOUSELEAVE HEX: 02A2 ; inline add-windows-message
: WM_WTSSESSION_CHANGE HEX: 02B1 ; inline add-windows-message
: WM_TABLET_FIRST HEX: 02c0 ; inline add-windows-message
: WM_TABLET_LAST HEX: 02df ; inline add-windows-message
: WM_CUT HEX: 0300 ; inline add-windows-message
: WM_COPY HEX: 0301 ; inline add-windows-message
: WM_PASTE HEX: 0302 ; inline add-windows-message
: WM_CLEAR HEX: 0303 ; inline add-windows-message
: WM_UNDO HEX: 0304 ; inline add-windows-message
: WM_RENDERFORMAT HEX: 0305 ; inline add-windows-message
: WM_RENDERALLFORMATS HEX: 0306 ; inline add-windows-message
: WM_DESTROYCLIPBOARD HEX: 0307 ; inline add-windows-message
: WM_DRAWCLIPBOARD HEX: 0308 ; inline add-windows-message
: WM_PAINTCLIPBOARD HEX: 0309 ; inline add-windows-message
: WM_VSCROLLCLIPBOARD HEX: 030A ; inline add-windows-message
: WM_SIZECLIPBOARD HEX: 030B ; inline add-windows-message
: WM_ASKCBFORMATNAME HEX: 030C ; inline add-windows-message
: WM_CHANGECBCHAIN HEX: 030D ; inline add-windows-message
: WM_HSCROLLCLIPBOARD HEX: 030E ; inline add-windows-message
: WM_QUERYNEWPALETTE HEX: 030F ; inline add-windows-message
: WM_PALETTEISCHANGING HEX: 0310 ; inline add-windows-message
: WM_PALETTECHANGED HEX: 0311 ; inline add-windows-message
: WM_HOTKEY HEX: 0312 ; inline add-windows-message
: WM_PRINT HEX: 0317 ; inline add-windows-message
: WM_PRINTCLIENT HEX: 0318 ; inline add-windows-message
: WM_APPCOMMAND HEX: 0319 ; inline add-windows-message
: WM_THEMECHANGED HEX: 031A ; inline add-windows-message
: WM_HANDHELDFIRST HEX: 0358 ; inline add-windows-message
: WM_HANDHELDLAST HEX: 035F ; inline add-windows-message
: WM_AFXFIRST HEX: 0360 ; inline add-windows-message
: WM_AFXLAST HEX: 037F ; inline add-windows-message
: WM_PENWINFIRST HEX: 0380 ; inline add-windows-message
: WM_PENWINLAST HEX: 038F ; inline add-windows-message
: WM_APP HEX: 8000 ; inline add-windows-message
: WM_USER HEX: 0400 ; inline add-windows-message
: EM_GETSEL HEX: 00B0 ; inline add-windows-message
: EM_SETSEL HEX: 00B1 ; inline add-windows-message
: EM_GETRECT HEX: 00B2 ; inline add-windows-message
: EM_SETRECT HEX: 00B3 ; inline add-windows-message
: EM_SETRECTNP HEX: 00B4 ; inline add-windows-message
: EM_SCROLL HEX: 00B5 ; inline add-windows-message
: EM_LINESCROLL HEX: 00B6 ; inline add-windows-message
: EM_SCROLLCARET HEX: 00B7 ; inline add-windows-message
: EM_GETMODIFY HEX: 00B8 ; inline add-windows-message
: EM_SETMODIFY HEX: 00B9 ; inline add-windows-message
: EM_GETLINECOUNT HEX: 00BA ; inline add-windows-message
: EM_LINEINDEX HEX: 00BB ; inline add-windows-message
: EM_SETHANDLE HEX: 00BC ; inline add-windows-message
: EM_GETHANDLE HEX: 00BD ; inline add-windows-message
: EM_GETTHUMB HEX: 00BE ; inline add-windows-message
: EM_LINELENGTH HEX: 00C1 ; inline add-windows-message
: EM_REPLACESEL HEX: 00C2 ; inline add-windows-message
: EM_GETLINE HEX: 00C4 ; inline add-windows-message
: EM_LIMITTEXT HEX: 00C5 ; inline add-windows-message
: EM_CANUNDO HEX: 00C6 ; inline add-windows-message
: EM_UNDO HEX: 00C7 ; inline add-windows-message
: EM_FMTLINES HEX: 00C8 ; inline add-windows-message
: EM_LINEFROMCHAR HEX: 00C9 ; inline add-windows-message
: EM_SETTABSTOPS HEX: 00CB ; inline add-windows-message
: EM_SETPASSWORDCHAR HEX: 00CC ; inline add-windows-message
: EM_EMPTYUNDOBUFFER HEX: 00CD ; inline add-windows-message
: EM_GETFIRSTVISIBLELINE HEX: 00CE ; inline add-windows-message
: EM_SETREADONLY HEX: 00CF ; inline add-windows-message
: EM_SETWORDBREAKPROC HEX: 00D0 ; inline add-windows-message
: EM_GETWORDBREAKPROC HEX: 00D1 ; inline add-windows-message
: EM_GETPASSWORDCHAR HEX: 00D2 ; inline add-windows-message
: EM_SETMARGINS HEX: 00D3 ; inline add-windows-message
: EM_GETMARGINS HEX: 00D4 ; inline add-windows-message
: EM_SETLIMITTEXT EM_LIMITTEXT ; inline add-windows-message
: EM_GETLIMITTEXT HEX: 00D5 ; inline add-windows-message
: EM_POSFROMCHAR HEX: 00D6 ; inline add-windows-message
: EM_CHARFROMPOS HEX: 00D7 ; inline add-windows-message
: EM_SETIMESTATUS HEX: 00D8 ; inline add-windows-message
: EM_GETIMESTATUS HEX: 00D9 ; inline add-windows-message
: BM_GETCHECK HEX: 00F0 ; inline add-windows-message
: BM_SETCHECK HEX: 00F1 ; inline add-windows-message
: BM_GETSTATE HEX: 00F2 ; inline add-windows-message
: BM_SETSTATE HEX: 00F3 ; inline add-windows-message
: BM_SETSTYLE HEX: 00F4 ; inline add-windows-message
: BM_CLICK HEX: 00F5 ; inline add-windows-message
: BM_GETIMAGE HEX: 00F6 ; inline add-windows-message
: BM_SETIMAGE HEX: 00F7 ; inline add-windows-message
: STM_SETICON HEX: 0170 ; inline add-windows-message
: STM_GETICON HEX: 0171 ; inline add-windows-message
: STM_SETIMAGE HEX: 0172 ; inline add-windows-message
: STM_GETIMAGE HEX: 0173 ; inline add-windows-message
: STM_MSGMAX HEX: 0174 ; inline add-windows-message
: DM_GETDEFID WM_USER ; inline add-windows-message
: DM_SETDEFID  WM_USER 1 + ; inline add-windows-message
: DM_REPOSITION WM_USER 2 + ; inline add-windows-message
: LB_ADDSTRING HEX: 0180 ; inline add-windows-message
: LB_INSERTSTRING HEX: 0181 ; inline add-windows-message
: LB_DELETESTRING HEX: 0182 ; inline add-windows-message
: LB_SELITEMRANGEEX HEX: 0183 ; inline add-windows-message
: LB_RESETCONTENT HEX: 0184 ; inline add-windows-message
: LB_SETSEL HEX: 0185 ; inline add-windows-message
: LB_SETCURSEL HEX: 0186 ; inline add-windows-message
: LB_GETSEL HEX: 0187 ; inline add-windows-message
: LB_GETCURSEL HEX: 0188 ; inline add-windows-message
: LB_GETTEXT HEX: 0189 ; inline add-windows-message
: LB_GETTEXTLEN HEX: 018A ; inline add-windows-message
: LB_GETCOUNT HEX: 018B ; inline add-windows-message
: LB_SELECTSTRING HEX: 018C ; inline add-windows-message
: LB_DIR HEX: 018D ; inline add-windows-message
: LB_GETTOPINDEX HEX: 018E ; inline add-windows-message
: LB_FINDSTRING HEX: 018F ; inline add-windows-message
: LB_GETSELCOUNT HEX: 0190 ; inline add-windows-message
: LB_GETSELITEMS HEX: 0191 ; inline add-windows-message
: LB_SETTABSTOPS HEX: 0192 ; inline add-windows-message
: LB_GETHORIZONTALEXTENT HEX: 0193 ; inline add-windows-message
: LB_SETHORIZONTALEXTENT HEX: 0194 ; inline add-windows-message
: LB_SETCOLUMNWIDTH HEX: 0195 ; inline add-windows-message
: LB_ADDFILE HEX: 0196 ; inline add-windows-message
: LB_SETTOPINDEX HEX: 0197 ; inline add-windows-message
: LB_GETITEMRECT HEX: 0198 ; inline add-windows-message
: LB_GETITEMDATA HEX: 0199 ; inline add-windows-message
: LB_SETITEMDATA HEX: 019A ; inline add-windows-message
: LB_SELITEMRANGE HEX: 019B ; inline add-windows-message
: LB_SETANCHORINDEX HEX: 019C ; inline add-windows-message
: LB_GETANCHORINDEX HEX: 019D ; inline add-windows-message
: LB_SETCARETINDEX HEX: 019E ; inline add-windows-message
: LB_GETCARETINDEX HEX: 019F ; inline add-windows-message
: LB_SETITEMHEIGHT HEX: 01A0 ; inline add-windows-message
: LB_GETITEMHEIGHT HEX: 01A1 ; inline add-windows-message
: LB_FINDSTRINGEXACT HEX: 01A2 ; inline add-windows-message
: LB_SETLOCALE HEX: 01A5 ; inline add-windows-message
: LB_GETLOCALE HEX: 01A6 ; inline add-windows-message
: LB_SETCOUNT HEX: 01A7 ; inline add-windows-message
: LB_INITSTORAGE HEX: 01A8 ; inline add-windows-message
: LB_ITEMFROMPOINT HEX: 01A9 ; inline add-windows-message
: LB_MULTIPLEADDSTRING HEX: 01B1 ; inline add-windows-message
: LB_GETLISTBOXINFO HEX: 01B2 ; inline add-windows-message
: LB_MSGMAX_501 HEX: 01B3 ; inline add-windows-message
: LB_MSGMAX_WCE4 HEX: 01B1 ; inline add-windows-message
: LB_MSGMAX_4 HEX: 01B0 ; inline add-windows-message
: LB_MSGMAX_PRE4 HEX: 01A8 ; inline add-windows-message
: CB_GETEDITSEL HEX: 0140 ; inline add-windows-message
: CB_LIMITTEXT HEX: 0141 ; inline add-windows-message
: CB_SETEDITSEL HEX: 0142 ; inline add-windows-message
: CB_ADDSTRING HEX: 0143 ; inline add-windows-message
: CB_DELETESTRING HEX: 0144 ; inline add-windows-message
: CB_DIR HEX: 0145 ; inline add-windows-message
: CB_GETCOUNT HEX: 0146 ; inline add-windows-message
: CB_GETCURSEL HEX: 0147 ; inline add-windows-message
: CB_GETLBTEXT HEX: 0148 ; inline add-windows-message
: CB_GETLBTEXTLEN HEX: 0149 ; inline add-windows-message
: CB_INSERTSTRING HEX: 014A ; inline add-windows-message
: CB_RESETCONTENT HEX: 014B ; inline add-windows-message
: CB_FINDSTRING HEX: 014C ; inline add-windows-message
: CB_SELECTSTRING HEX: 014D ; inline add-windows-message
: CB_SETCURSEL HEX: 014E ; inline add-windows-message
: CB_SHOWDROPDOWN HEX: 014F ; inline add-windows-message
: CB_GETITEMDATA HEX: 0150 ; inline add-windows-message
: CB_SETITEMDATA HEX: 0151 ; inline add-windows-message
: CB_GETDROPPEDCONTROLRECT HEX: 0152 ; inline add-windows-message
: CB_SETITEMHEIGHT HEX: 0153 ; inline add-windows-message
: CB_GETITEMHEIGHT HEX: 0154 ; inline add-windows-message
: CB_SETEXTENDEDUI HEX: 0155 ; inline add-windows-message
: CB_GETEXTENDEDUI HEX: 0156 ; inline add-windows-message
: CB_GETDROPPEDSTATE HEX: 0157 ; inline add-windows-message
: CB_FINDSTRINGEXACT HEX: 0158 ; inline add-windows-message
: CB_SETLOCALE HEX: 0159 ; inline add-windows-message
: CB_GETLOCALE HEX: 015A ; inline add-windows-message
: CB_GETTOPINDEX HEX: 015B ; inline add-windows-message
: CB_SETTOPINDEX HEX: 015C ; inline add-windows-message
: CB_GETHORIZONTALEXTENT HEX: 015d ; inline add-windows-message
: CB_SETHORIZONTALEXTENT HEX: 015e ; inline add-windows-message
: CB_GETDROPPEDWIDTH HEX: 015f ; inline add-windows-message
: CB_SETDROPPEDWIDTH HEX: 0160 ; inline add-windows-message
: CB_INITSTORAGE HEX: 0161 ; inline add-windows-message
: CB_MULTIPLEADDSTRING HEX: 0163 ; inline add-windows-message
: CB_GETCOMBOBOXINFO HEX: 0164 ; inline add-windows-message
: CB_MSGMAX_501 HEX: 0165 ; inline add-windows-message
: CB_MSGMAX_WCE400 HEX: 0163 ; inline add-windows-message
: CB_MSGMAX_400 HEX: 0162 ; inline add-windows-message
: CB_MSGMAX_PRE400 HEX: 015B ; inline add-windows-message
: SBM_SETPOS HEX: 00E0 ; inline add-windows-message 
: SBM_GETPOS HEX: 00E1 ; inline add-windows-message 
: SBM_SETRANGE HEX: 00E2 ; inline add-windows-message 
: SBM_SETRANGEREDRAW HEX: 00E6 ; inline add-windows-message
: SBM_GETRANGE HEX: 00E3 ; inline add-windows-message
: SBM_ENABLE_ARROWS HEX: 00E4 ; inline add-windows-message
: SBM_SETSCROLLINFO HEX: 00E9 ; inline add-windows-message
: SBM_GETSCROLLINFO HEX: 00EA ; inline add-windows-message
: SBM_GETSCROLLBARINFO HEX: 00EB ; inline add-windows-message
: LVM_FIRST HEX: 1000 ; inline add-windows-message ! ListView messages
: TV_FIRST HEX: 1100 ; inline add-windows-message ! TreeView messages
: HDM_FIRST HEX: 1200 ; inline add-windows-message ! Header messages
: TCM_FIRST HEX: 1300 ; inline add-windows-message ! Tab control messages
: PGM_FIRST HEX: 1400 ; inline add-windows-message ! Pager control messages
: ECM_FIRST HEX: 1500 ; inline add-windows-message ! Edit control messages
: BCM_FIRST HEX: 1600 ; inline add-windows-message ! Button control messages
: CBM_FIRST HEX: 1700 ; inline add-windows-message ! Combobox control messages
: CCM_FIRST HEX: 2000 ; inline add-windows-message ! Common control shared messages
: CCM_LAST CCM_FIRST HEX: 0200 + ; inline add-windows-message
: CCM_SETBKCOLOR CCM_FIRST  1 +  ; inline add-windows-message
: CCM_SETCOLORSCHEME CCM_FIRST  2 +  ; inline add-windows-message
: CCM_GETCOLORSCHEME CCM_FIRST  3 +  ; inline add-windows-message
: CCM_GETDROPTARGET CCM_FIRST  4 +  ; inline add-windows-message
: CCM_SETUNICODEFORMAT CCM_FIRST  5 +  ; inline add-windows-message
: CCM_GETUNICODEFORMAT CCM_FIRST  6 +  ; inline add-windows-message
: CCM_SETVERSION CCM_FIRST  7 +  ; inline add-windows-message
: CCM_GETVERSION CCM_FIRST  8 +  ; inline add-windows-message
: CCM_SETNOTIFYWINDOW CCM_FIRST  9 +  ; inline add-windows-message
: CCM_SETWINDOWTHEME CCM_FIRST  HEX: b +  ; inline add-windows-message
: CCM_DPISCALE CCM_FIRST  HEX: c +  ; inline add-windows-message
: HDM_GETITEMCOUNT HDM_FIRST  0 +  ; inline add-windows-message
: HDM_INSERTITEMA HDM_FIRST  1 +  ; inline add-windows-message
: HDM_INSERTITEMW HDM_FIRST  10 +  ; inline add-windows-message
: HDM_DELETEITEM HDM_FIRST  2 +  ; inline add-windows-message
: HDM_GETITEMA HDM_FIRST  3 +  ; inline add-windows-message
: HDM_GETITEMW HDM_FIRST  11 +  ; inline add-windows-message
: HDM_SETITEMA HDM_FIRST  4 +  ; inline add-windows-message
: HDM_SETITEMW HDM_FIRST  12 +  ; inline add-windows-message
: HDM_LAYOUT HDM_FIRST  5 +  ; inline add-windows-message
: HDM_HITTEST HDM_FIRST  6 +  ; inline add-windows-message
: HDM_GETITEMRECT HDM_FIRST  7 +  ; inline add-windows-message
: HDM_SETIMAGELIST HDM_FIRST  8 +  ; inline add-windows-message
: HDM_GETIMAGELIST HDM_FIRST  9 +  ; inline add-windows-message
: HDM_ORDERTOINDEX HDM_FIRST  15 +  ; inline add-windows-message
: HDM_CREATEDRAGIMAGE HDM_FIRST  16 +  ; inline add-windows-message
: HDM_GETORDERARRAY HDM_FIRST  17 +  ; inline add-windows-message
: HDM_SETORDERARRAY HDM_FIRST  18 +  ; inline add-windows-message
: HDM_SETHOTDIVIDER HDM_FIRST  19 +  ; inline add-windows-message
: HDM_SETBITMAPMARGIN HDM_FIRST  20 +  ; inline add-windows-message
: HDM_GETBITMAPMARGIN HDM_FIRST  21 +  ; inline add-windows-message
: HDM_SETUNICODEFORMAT CCM_SETUNICODEFORMAT ; inline add-windows-message
: HDM_GETUNICODEFORMAT CCM_GETUNICODEFORMAT ; inline add-windows-message
: HDM_SETFILTERCHANGETIMEOUT HDM_FIRST 22 + ; inline add-windows-message
: HDM_EDITFILTER HDM_FIRST 23 + ; inline add-windows-message
: HDM_CLEARFILTER HDM_FIRST 24 + ; inline add-windows-message
: TB_ENABLEBUTTON WM_USER 1 + ; inline add-windows-message
: TB_CHECKBUTTON WM_USER 2 + ; inline add-windows-message
: TB_PRESSBUTTON WM_USER 3 + ; inline add-windows-message
: TB_HIDEBUTTON WM_USER  4 +  ; inline add-windows-message
: TB_INDETERMINATE WM_USER  5 +  ; inline add-windows-message
: TB_MARKBUTTON WM_USER  6 +  ; inline add-windows-message
: TB_ISBUTTONENABLED WM_USER  9 +  ; inline add-windows-message
: TB_ISBUTTONCHECKED WM_USER  10 +  ; inline add-windows-message
: TB_ISBUTTONPRESSED WM_USER  11 +  ; inline add-windows-message
: TB_ISBUTTONHIDDEN WM_USER  12 +  ; inline add-windows-message
: TB_ISBUTTONINDETERMINATE WM_USER  13 +  ; inline add-windows-message
: TB_ISBUTTONHIGHLIGHTED WM_USER  14 +  ; inline add-windows-message
: TB_SETSTATE WM_USER  17 +  ; inline add-windows-message
: TB_GETSTATE WM_USER  18 +  ; inline add-windows-message
: TB_ADDBITMAP WM_USER  19 +  ; inline add-windows-message
: TB_ADDBUTTONSA WM_USER  20 +  ; inline add-windows-message
: TB_INSERTBUTTONA WM_USER  21 +  ; inline add-windows-message
: TB_ADDBUTTONS WM_USER  20 +  ; inline add-windows-message
: TB_INSERTBUTTON WM_USER  21 +  ; inline add-windows-message
: TB_DELETEBUTTON WM_USER  22 +  ; inline add-windows-message
: TB_GETBUTTON WM_USER  23 +  ; inline add-windows-message
: TB_BUTTONCOUNT WM_USER  24 +  ; inline add-windows-message
: TB_COMMANDTOINDEX WM_USER  25 +  ; inline add-windows-message
: TB_SAVERESTOREA WM_USER  26 +  ; inline add-windows-message
: TB_SAVERESTOREW WM_USER  76 +  ; inline add-windows-message
: TB_CUSTOMIZE WM_USER  27 +  ; inline add-windows-message
: TB_ADDSTRINGA WM_USER  28 +  ; inline add-windows-message
: TB_ADDSTRINGW WM_USER  77 +  ; inline add-windows-message
: TB_GETITEMRECT WM_USER  29 +  ; inline add-windows-message
: TB_BUTTONSTRUCTSIZE WM_USER  30 +  ; inline add-windows-message
: TB_SETBUTTONSIZE WM_USER  31 +  ; inline add-windows-message
: TB_SETBITMAPSIZE WM_USER  32 +  ; inline add-windows-message
: TB_AUTOSIZE WM_USER  33 +  ; inline add-windows-message
: TB_GETTOOLTIPS WM_USER  35 +  ; inline add-windows-message
: TB_SETTOOLTIPS WM_USER  36 +  ; inline add-windows-message
: TB_SETPARENT WM_USER  37 +  ; inline add-windows-message
: TB_SETROWS WM_USER  39 +  ; inline add-windows-message
: TB_GETROWS WM_USER  40 +  ; inline add-windows-message
: TB_SETCMDID WM_USER  42 +  ; inline add-windows-message
: TB_CHANGEBITMAP WM_USER  43 +  ; inline add-windows-message
: TB_GETBITMAP WM_USER  44 +  ; inline add-windows-message
: TB_GETBUTTONTEXTA WM_USER  45 +  ; inline add-windows-message
: TB_GETBUTTONTEXTW WM_USER  75 +  ; inline add-windows-message
: TB_REPLACEBITMAP WM_USER  46 +  ; inline add-windows-message
: TB_SETINDENT WM_USER  47 +  ; inline add-windows-message
: TB_SETIMAGELIST WM_USER  48 +  ; inline add-windows-message
: TB_GETIMAGELIST WM_USER  49 +  ; inline add-windows-message
: TB_LOADIMAGES WM_USER  50 +  ; inline add-windows-message
: TB_GETRECT WM_USER  51 +  ; inline add-windows-message
: TB_SETHOTIMAGELIST WM_USER  52 +  ; inline add-windows-message
: TB_GETHOTIMAGELIST WM_USER  53 +  ; inline add-windows-message
: TB_SETDISABLEDIMAGELIST WM_USER  54 +  ; inline add-windows-message
: TB_GETDISABLEDIMAGELIST WM_USER  55 +  ; inline add-windows-message
: TB_SETSTYLE WM_USER  56 +  ; inline add-windows-message
: TB_GETSTYLE WM_USER  57 +  ; inline add-windows-message
: TB_GETBUTTONSIZE WM_USER  58 +  ; inline add-windows-message
: TB_SETBUTTONWIDTH WM_USER  59 +  ; inline add-windows-message
: TB_SETMAXTEXTROWS WM_USER  60 +  ; inline add-windows-message
: TB_GETTEXTROWS WM_USER  61 +  ; inline add-windows-message
: TB_GETOBJECT WM_USER  62 +  ; inline add-windows-message
: TB_GETHOTITEM WM_USER  71 +  ; inline add-windows-message
: TB_SETHOTITEM WM_USER  72 +  ; inline add-windows-message 
: TB_SETANCHORHIGHLIGHT WM_USER  73 +  ; inline add-windows-message 
: TB_GETANCHORHIGHLIGHT WM_USER  74 +  ; inline add-windows-message
: TB_MAPACCELERATORA WM_USER  78 +  ; inline add-windows-message 
: TB_GETINSERTMARK WM_USER  79 +  ; inline add-windows-message 
: TB_SETINSERTMARK WM_USER  80 +  ; inline add-windows-message 
: TB_INSERTMARKHITTEST WM_USER  81 +  ; inline add-windows-message
: TB_MOVEBUTTON WM_USER  82 +  ; inline add-windows-message
: TB_GETMAXSIZE WM_USER  83 +  ; inline add-windows-message
: TB_SETEXTENDEDSTYLE WM_USER  84 +  ; inline add-windows-message
: TB_GETEXTENDEDSTYLE WM_USER  85 +  ; inline add-windows-message
: TB_GETPADDING WM_USER  86 +  ; inline add-windows-message
: TB_SETPADDING WM_USER  87 +  ; inline add-windows-message
: TB_SETINSERTMARKCOLOR WM_USER  88 +  ; inline add-windows-message
: TB_GETINSERTMARKCOLOR WM_USER  89 +  ; inline add-windows-message
: TB_SETCOLORSCHEME CCM_SETCOLORSCHEME ; inline add-windows-message
: TB_GETCOLORSCHEME CCM_GETCOLORSCHEME ; inline add-windows-message
: TB_SETUNICODEFORMAT CCM_SETUNICODEFORMAT ; inline add-windows-message
: TB_GETUNICODEFORMAT CCM_GETUNICODEFORMAT ; inline add-windows-message
: TB_MAPACCELERATORW WM_USER  90 +  ; inline add-windows-message
: TB_GETBITMAPFLAGS WM_USER  41 +  ; inline add-windows-message
: TB_GETBUTTONINFOW WM_USER  63 +  ; inline add-windows-message
: TB_SETBUTTONINFOW WM_USER  64 +  ; inline add-windows-message
: TB_GETBUTTONINFOA WM_USER  65 +  ; inline add-windows-message
: TB_SETBUTTONINFOA WM_USER  66 +  ; inline add-windows-message
: TB_INSERTBUTTONW WM_USER  67 +  ; inline add-windows-message
: TB_ADDBUTTONSW WM_USER  68 +  ; inline add-windows-message
: TB_HITTEST WM_USER  69 +  ; inline add-windows-message
: TB_SETDRAWTEXTFLAGS WM_USER  70 +  ; inline add-windows-message
: TB_GETSTRINGW WM_USER  91 +  ; inline add-windows-message
: TB_GETSTRINGA WM_USER  92 +  ; inline add-windows-message
: TB_GETMETRICS WM_USER  101 +  ; inline add-windows-message
: TB_SETMETRICS WM_USER  102 +  ; inline add-windows-message
: TB_SETWINDOWTHEME CCM_SETWINDOWTHEME ; inline add-windows-message
: RB_INSERTBANDA WM_USER  1 +  ; inline add-windows-message
: RB_DELETEBAND WM_USER  2 +  ; inline add-windows-message
: RB_GETBARINFO WM_USER  3 +  ; inline add-windows-message
: RB_SETBARINFO WM_USER  4 +  ; inline add-windows-message
: RB_GETBANDINFO WM_USER  5 +  ; inline add-windows-message
: RB_SETBANDINFOA WM_USER  6 +  ; inline add-windows-message
: RB_SETPARENT WM_USER  7 +  ; inline add-windows-message
: RB_HITTEST WM_USER  8 +  ; inline add-windows-message
: RB_GETRECT WM_USER  9 +  ; inline add-windows-message
: RB_INSERTBANDW WM_USER  10 +  ; inline add-windows-message
: RB_SETBANDINFOW WM_USER  11 +  ; inline add-windows-message
: RB_GETBANDCOUNT WM_USER  12 +  ; inline add-windows-message
: RB_GETROWCOUNT WM_USER  13 +  ; inline add-windows-message
: RB_GETROWHEIGHT WM_USER  14 +  ; inline add-windows-message
: RB_IDTOINDEX WM_USER  16 +  ; inline add-windows-message 
: RB_GETTOOLTIPS WM_USER  17 +  ; inline add-windows-message
: RB_SETTOOLTIPS WM_USER  18 +  ; inline add-windows-message
: RB_SETBKCOLOR WM_USER  19 +  ; inline add-windows-message
: RB_GETBKCOLOR WM_USER  20 +  ; inline add-windows-message
: RB_SETTEXTCOLOR WM_USER  21 +  ; inline add-windows-message
: RB_GETTEXTCOLOR WM_USER  22 +  ; inline add-windows-message
: RB_SIZETORECT WM_USER  23 +  ; inline add-windows-message
: RB_SETCOLORSCHEME CCM_SETCOLORSCHEME ; inline add-windows-message
: RB_GETCOLORSCHEME CCM_GETCOLORSCHEME ; inline add-windows-message
: RB_BEGINDRAG WM_USER  24 +  ; inline add-windows-message
: RB_ENDDRAG WM_USER  25 +  ; inline add-windows-message
: RB_DRAGMOVE WM_USER  26 +  ; inline add-windows-message
: RB_GETBARHEIGHT WM_USER  27 +  ; inline add-windows-message
: RB_GETBANDINFOW WM_USER  28 +  ; inline add-windows-message
: RB_GETBANDINFOA WM_USER  29 +  ; inline add-windows-message
: RB_MINIMIZEBAND WM_USER  30 +  ; inline add-windows-message
: RB_MAXIMIZEBAND WM_USER  31 +  ; inline add-windows-message
: RB_GETDROPTARGET CCM_GETDROPTARGET ; inline add-windows-message
: RB_GETBANDBORDERS WM_USER  34 +  ; inline add-windows-message 
: RB_SHOWBAND WM_USER  35 +  ; inline add-windows-message 
: RB_SETPALETTE WM_USER  37 +  ; inline add-windows-message
: RB_GETPALETTE WM_USER  38 +  ; inline add-windows-message
: RB_MOVEBAND WM_USER  39 +  ; inline add-windows-message
: RB_SETUNICODEFORMAT CCM_SETUNICODEFORMAT ; inline add-windows-message
: RB_GETUNICODEFORMAT CCM_GETUNICODEFORMAT ; inline add-windows-message
: RB_GETBANDMARGINS WM_USER  40 +  ; inline add-windows-message
: RB_SETWINDOWTHEME CCM_SETWINDOWTHEME ; inline add-windows-message
: RB_PUSHCHEVRON WM_USER  43 +  ; inline add-windows-message
: TTM_ACTIVATE WM_USER  1 +  ; inline add-windows-message
: TTM_SETDELAYTIME WM_USER  3 +  ; inline add-windows-message
: TTM_ADDTOOLA WM_USER  4 +  ; inline add-windows-message
: TTM_ADDTOOLW WM_USER  50 +  ; inline add-windows-message
: TTM_DELTOOLA WM_USER  5 +  ; inline add-windows-message
: TTM_DELTOOLW WM_USER  51 +  ; inline add-windows-message
: TTM_NEWTOOLRECTA WM_USER  6 +  ; inline add-windows-message
: TTM_NEWTOOLRECTW WM_USER  52 +  ; inline add-windows-message
: TTM_RELAYEVENT WM_USER  7 +  ; inline add-windows-message
: TTM_GETTOOLINFOA WM_USER  8 +  ; inline add-windows-message
: TTM_GETTOOLINFOW WM_USER  53 +  ; inline add-windows-message
: TTM_SETTOOLINFOA WM_USER  9 +  ; inline add-windows-message
: TTM_SETTOOLINFOW WM_USER  54 +  ; inline add-windows-message
: TTM_HITTESTA WM_USER 10 + ; inline add-windows-message
: TTM_HITTESTW WM_USER 55 + ; inline add-windows-message
: TTM_GETTEXTA WM_USER 11 + ; inline add-windows-message
: TTM_GETTEXTW WM_USER 56 + ; inline add-windows-message
: TTM_UPDATETIPTEXTA WM_USER 12 + ; inline add-windows-message
: TTM_UPDATETIPTEXTW WM_USER 57 + ; inline add-windows-message
: TTM_GETTOOLCOUNT WM_USER 13 + ; inline add-windows-message
: TTM_ENUMTOOLSA WM_USER 14 + ; inline add-windows-message
: TTM_ENUMTOOLSW WM_USER 58 + ; inline add-windows-message
: TTM_GETCURRENTTOOLA WM_USER  15 +  ; inline add-windows-message
: TTM_GETCURRENTTOOLW WM_USER  59 +  ; inline add-windows-message
: TTM_WINDOWFROMPOINT WM_USER  16 +  ; inline add-windows-message
: TTM_TRACKACTIVATE WM_USER  17 +  ; inline add-windows-message
: TTM_TRACKPOSITION WM_USER  18 +  ; inline add-windows-message
: TTM_SETTIPBKCOLOR WM_USER  19 +  ; inline add-windows-message
: TTM_SETTIPTEXTCOLOR WM_USER  20 +  ; inline add-windows-message
: TTM_GETDELAYTIME WM_USER  21 +  ; inline add-windows-message
: TTM_GETTIPBKCOLOR WM_USER  22 +  ; inline add-windows-message
: TTM_GETTIPTEXTCOLOR WM_USER  23 +  ; inline add-windows-message
: TTM_SETMAXTIPWIDTH WM_USER  24 +  ; inline add-windows-message
: TTM_GETMAXTIPWIDTH WM_USER  25 +  ; inline add-windows-message
: TTM_SETMARGIN WM_USER  26 +  ; inline add-windows-message
: TTM_GETMARGIN WM_USER  27 +  ; inline add-windows-message
: TTM_POP WM_USER  28 +  ; inline add-windows-message
: TTM_UPDATE WM_USER  29 +  ; inline add-windows-message
: TTM_GETBUBBLESIZE WM_USER  30 +  ; inline add-windows-message
: TTM_ADJUSTRECT WM_USER  31 +  ; inline add-windows-message
: TTM_SETTITLEA WM_USER  32 +  ; inline add-windows-message
: TTM_SETTITLEW WM_USER  33 +  ; inline add-windows-message
: TTM_POPUP WM_USER  34 +  ; inline add-windows-message
: TTM_GETTITLE WM_USER  35 +  ; inline add-windows-message
: TTM_SETWINDOWTHEME CCM_SETWINDOWTHEME ; inline add-windows-message
: SB_SETTEXTA WM_USER 1+  ; inline add-windows-message
: SB_SETTEXTW WM_USER 11 +  ; inline add-windows-message
: SB_GETTEXTA WM_USER 2 +  ; inline add-windows-message
: SB_GETTEXTW WM_USER 13 +  ; inline add-windows-message
: SB_GETTEXTLENGTHA WM_USER 3 +  ; inline add-windows-message
: SB_GETTEXTLENGTHW WM_USER 12 +  ; inline add-windows-message
: SB_SETPARTS WM_USER 4 +  ; inline add-windows-message
: SB_GETPARTS WM_USER 6 +  ; inline add-windows-message
: SB_GETBORDERS WM_USER 7 +  ; inline add-windows-message
: SB_SETMINHEIGHT WM_USER 8 +  ; inline add-windows-message
: SB_SIMPLE WM_USER 9 +  ; inline add-windows-message
: SB_GETRECT WM_USER 10 +  ; inline add-windows-message
: SB_ISSIMPLE WM_USER 14 +  ; inline add-windows-message
: SB_SETICON WM_USER 15 +  ; inline add-windows-message
: SB_SETTIPTEXTA WM_USER 16 +  ; inline add-windows-message
: SB_SETTIPTEXTW WM_USER 17 +  ; inline add-windows-message
: SB_GETTIPTEXTA WM_USER 18 +  ; inline add-windows-message
: SB_GETTIPTEXTW WM_USER 19 +  ; inline add-windows-message
: SB_GETICON WM_USER 20 +  ; inline add-windows-message
: SB_SETUNICODEFORMAT CCM_SETUNICODEFORMAT ; inline add-windows-message
: SB_GETUNICODEFORMAT CCM_GETUNICODEFORMAT ; inline add-windows-message
: SB_SETBKCOLOR CCM_SETBKCOLOR ; inline add-windows-message
: SB_SIMPLEID HEX: 00ff ; inline add-windows-message
: TBM_GETPOS WM_USER ; inline add-windows-message
: TBM_GETRANGEMIN WM_USER 1 +  ; inline add-windows-message
: TBM_GETRANGEMAX WM_USER 2 +  ; inline add-windows-message
: TBM_GETTIC WM_USER 3 +  ; inline add-windows-message
: TBM_SETTIC WM_USER 4 +  ; inline add-windows-message
: TBM_SETPOS WM_USER 5 +  ; inline add-windows-message
: TBM_SETRANGE WM_USER 6 +  ; inline add-windows-message
: TBM_SETRANGEMIN WM_USER 7 +  ; inline add-windows-message
: TBM_SETRANGEMAX WM_USER 8 +  ; inline add-windows-message
: TBM_CLEARTICS WM_USER 9 +  ; inline add-windows-message
: TBM_SETSEL WM_USER 10 +  ; inline add-windows-message
: TBM_SETSELSTART WM_USER 11 +  ; inline add-windows-message
: TBM_SETSELEND WM_USER 12 +  ; inline add-windows-message
: TBM_GETPTICS WM_USER 14 +  ; inline add-windows-message
: TBM_GETTICPOS WM_USER 15 +  ; inline add-windows-message
: TBM_GETNUMTICS WM_USER 16 +  ; inline add-windows-message
: TBM_GETSELSTART WM_USER 17 +  ; inline add-windows-message
: TBM_GETSELEND WM_USER 18 +  ; inline add-windows-message
: TBM_CLEARSEL WM_USER 19 +  ; inline add-windows-message
: TBM_SETTICFREQ WM_USER 20 +  ; inline add-windows-message
: TBM_SETPAGESIZE WM_USER 21 +  ; inline add-windows-message
: TBM_GETPAGESIZE WM_USER 22 +  ; inline add-windows-message
: TBM_SETLINESIZE WM_USER 23 +  ; inline add-windows-message
: TBM_GETLINESIZE WM_USER 24 +  ; inline add-windows-message
: TBM_GETTHUMBRECT WM_USER 25 +  ; inline add-windows-message
: TBM_GETCHANNELRECT WM_USER 26 +  ; inline add-windows-message
: TBM_SETTHUMBLENGTH WM_USER 27 +  ; inline add-windows-message
: TBM_GETTHUMBLENGTH WM_USER 28 +  ; inline add-windows-message
: TBM_SETTOOLTIPS WM_USER 29 +  ; inline add-windows-message
: TBM_GETTOOLTIPS WM_USER 30 +  ; inline add-windows-message
: TBM_SETTIPSIDE WM_USER 31 +  ; inline add-windows-message
: TBM_SETBUDDY WM_USER 32 +  ; inline add-windows-message 
: TBM_GETBUDDY WM_USER 33 +  ; inline add-windows-message 
: TBM_SETUNICODEFORMAT CCM_SETUNICODEFORMAT ; inline add-windows-message
: TBM_GETUNICODEFORMAT CCM_GETUNICODEFORMAT ; inline add-windows-message
: DL_BEGINDRAG WM_USER 133 +  ; inline add-windows-message
: DL_DRAGGING WM_USER 134 +  ; inline add-windows-message
: DL_DROPPED WM_USER 135 +  ; inline add-windows-message
: DL_CANCELDRAG WM_USER 136 +  ; inline add-windows-message
: UDM_SETRANGE WM_USER 101 +  ; inline add-windows-message
: UDM_GETRANGE WM_USER 102 +  ; inline add-windows-message
: UDM_SETPOS WM_USER 103 +  ; inline add-windows-message
: UDM_GETPOS WM_USER 104 +  ; inline add-windows-message
: UDM_SETBUDDY WM_USER 105 +  ; inline add-windows-message
: UDM_GETBUDDY WM_USER 106 +  ; inline add-windows-message
: UDM_SETACCEL WM_USER 107 +  ; inline add-windows-message
: UDM_GETACCEL WM_USER 108 +  ; inline add-windows-message
: UDM_SETBASE WM_USER 109 +  ; inline add-windows-message
: UDM_GETBASE WM_USER 110 +  ; inline add-windows-message
: UDM_SETRANGE32 WM_USER 111 +  ; inline add-windows-message
: UDM_GETRANGE32 WM_USER 112 +  ; inline add-windows-message
: UDM_SETUNICODEFORMAT CCM_SETUNICODEFORMAT ; inline add-windows-message
: UDM_GETUNICODEFORMAT CCM_GETUNICODEFORMAT ; inline add-windows-message
: UDM_SETPOS32 WM_USER 113 +  ; inline add-windows-message
: UDM_GETPOS32 WM_USER 114 +  ; inline add-windows-message
: PBM_SETRANGE WM_USER 1 +  ; inline add-windows-message
: PBM_SETPOS WM_USER 2 +  ; inline add-windows-message
: PBM_DELTAPOS WM_USER 3 +  ; inline add-windows-message
: PBM_SETSTEP WM_USER 4 +  ; inline add-windows-message
: PBM_STEPIT WM_USER 5 +  ; inline add-windows-message
: PBM_SETRANGE32 WM_USER 6 +  ; inline add-windows-message
: PBM_GETRANGE WM_USER 7 +  ; inline add-windows-message 
: PBM_GETPOS WM_USER 8 +  ; inline add-windows-message
: PBM_SETBARCOLOR WM_USER 9 +  ; inline add-windows-message
: PBM_SETBKCOLOR CCM_SETBKCOLOR ; inline add-windows-message 
: HKM_SETHOTKEY WM_USER 1 +  ; inline add-windows-message
: HKM_GETHOTKEY WM_USER 2 +  ; inline add-windows-message
: HKM_SETRULES WM_USER 3 +  ; inline add-windows-message
: LVM_SETUNICODEFORMAT CCM_SETUNICODEFORMAT ; inline add-windows-message
: LVM_GETUNICODEFORMAT CCM_GETUNICODEFORMAT ; inline add-windows-message
: LVM_GETBKCOLOR LVM_FIRST  0 +  ; inline add-windows-message
: LVM_SETBKCOLOR LVM_FIRST  1 +  ; inline add-windows-message
: LVM_GETIMAGELIST LVM_FIRST  2 +  ; inline add-windows-message
: LVM_SETIMAGELIST LVM_FIRST  3 +  ; inline add-windows-message
: LVM_GETITEMCOUNT LVM_FIRST  4 +  ; inline add-windows-message
: LVM_GETITEMA LVM_FIRST  5 +  ; inline add-windows-message
: LVM_GETITEMW LVM_FIRST  75 +  ; inline add-windows-message
: LVM_SETITEMA LVM_FIRST  6 +  ; inline add-windows-message
: LVM_SETITEMW LVM_FIRST  76 +  ; inline add-windows-message
: LVM_INSERTITEMA LVM_FIRST  7 +  ; inline add-windows-message
: LVM_INSERTITEMW LVM_FIRST  77 +  ; inline add-windows-message
: LVM_DELETEITEM LVM_FIRST  8 +  ; inline add-windows-message
: LVM_DELETEALLITEMS LVM_FIRST  9 +  ; inline add-windows-message
: LVM_GETCALLBACKMASK LVM_FIRST  10 +  ; inline add-windows-message
: LVM_SETCALLBACKMASK LVM_FIRST  11 +  ; inline add-windows-message
: LVM_FINDITEMA LVM_FIRST  13 +  ; inline add-windows-message
: LVM_FINDITEMW LVM_FIRST  83 +  ; inline add-windows-message
: LVM_GETITEMRECT LVM_FIRST  14 +  ; inline add-windows-message
: LVM_SETITEMPOSITION LVM_FIRST  15 +  ; inline add-windows-message
: LVM_GETITEMPOSITION LVM_FIRST  16 +  ; inline add-windows-message
: LVM_GETSTRINGWIDTHA LVM_FIRST  17 +  ; inline add-windows-message
: LVM_GETSTRINGWIDTHW LVM_FIRST  87 +  ; inline add-windows-message
: LVM_HITTEST LVM_FIRST  18 +  ; inline add-windows-message
: LVM_ENSUREVISIBLE LVM_FIRST  19 +  ; inline add-windows-message
: LVM_SCROLL LVM_FIRST  20 +  ; inline add-windows-message
: LVM_REDRAWITEMS LVM_FIRST  21 +  ; inline add-windows-message
: LVM_ARRANGE LVM_FIRST  22 +  ; inline add-windows-message
: LVM_EDITLABELA LVM_FIRST  23 +  ; inline add-windows-message
: LVM_EDITLABELW LVM_FIRST  118 +  ; inline add-windows-message
: LVM_GETEDITCONTROL LVM_FIRST  24 +  ; inline add-windows-message
: LVM_GETCOLUMNA LVM_FIRST  25 +  ; inline add-windows-message
: LVM_GETCOLUMNW LVM_FIRST  95 +  ; inline add-windows-message
: LVM_SETCOLUMNA LVM_FIRST  26 +  ; inline add-windows-message
: LVM_SETCOLUMNW LVM_FIRST  96 +  ; inline add-windows-message
: LVM_INSERTCOLUMNA LVM_FIRST  27 +  ; inline add-windows-message
: LVM_INSERTCOLUMNW LVM_FIRST  97 +  ; inline add-windows-message
: LVM_DELETECOLUMN LVM_FIRST  28 +  ; inline add-windows-message
: LVM_GETCOLUMNWIDTH LVM_FIRST  29 +  ; inline add-windows-message
: LVM_SETCOLUMNWIDTH LVM_FIRST  30 +  ; inline add-windows-message
: LVM_CREATEDRAGIMAGE LVM_FIRST  33 +  ; inline add-windows-message
: LVM_GETVIEWRECT LVM_FIRST  34 +  ; inline add-windows-message
: LVM_GETTEXTCOLOR LVM_FIRST  35 +  ; inline add-windows-message
: LVM_SETTEXTCOLOR LVM_FIRST  36 +  ; inline add-windows-message
: LVM_GETTEXTBKCOLOR LVM_FIRST  37 +  ; inline add-windows-message
: LVM_SETTEXTBKCOLOR LVM_FIRST  38 +  ; inline add-windows-message
: LVM_GETTOPINDEX LVM_FIRST  39 +  ; inline add-windows-message
: LVM_GETCOUNTPERPAGE LVM_FIRST  40 +  ; inline add-windows-message
: LVM_GETORIGIN LVM_FIRST  41 +  ; inline add-windows-message
: LVM_UPDATE LVM_FIRST  42 +  ; inline add-windows-message
: LVM_SETITEMSTATE LVM_FIRST  43 +  ; inline add-windows-message
: LVM_GETITEMSTATE LVM_FIRST  44 +  ; inline add-windows-message
: LVM_GETITEMTEXTA LVM_FIRST  45 +  ; inline add-windows-message
: LVM_GETITEMTEXTW LVM_FIRST  115 +  ; inline add-windows-message
: LVM_SETITEMTEXTA LVM_FIRST  46 +  ; inline add-windows-message
: LVM_SETITEMTEXTW LVM_FIRST  116 +  ; inline add-windows-message
: LVM_SETITEMCOUNT LVM_FIRST  47 +  ; inline add-windows-message
: LVM_SORTITEMS LVM_FIRST  48 +  ; inline add-windows-message
: LVM_SETITEMPOSITION32 LVM_FIRST  49 +  ; inline add-windows-message
: LVM_GETSELECTEDCOUNT LVM_FIRST  50 +  ; inline add-windows-message
: LVM_GETITEMSPACING LVM_FIRST  51 +  ; inline add-windows-message
: LVM_GETISEARCHSTRINGA LVM_FIRST  52 +  ; inline add-windows-message
: LVM_GETISEARCHSTRINGW LVM_FIRST  117 +  ; inline add-windows-message
: LVM_SETICONSPACING LVM_FIRST  53 +  ; inline add-windows-message
: LVM_SETEXTENDEDLISTVIEWSTYLE LVM_FIRST  54 +  ; inline add-windows-message
: LVM_GETEXTENDEDLISTVIEWSTYLE LVM_FIRST  55 +  ; inline add-windows-message
: LVM_GETSUBITEMRECT LVM_FIRST  56 +  ; inline add-windows-message
: LVM_SUBITEMHITTEST LVM_FIRST  57 +  ; inline add-windows-message
: LVM_SETCOLUMNORDERARRAY LVM_FIRST  58 +  ; inline add-windows-message
: LVM_GETCOLUMNORDERARRAY LVM_FIRST  59 +  ; inline add-windows-message
: LVM_SETHOTITEM LVM_FIRST  60 +  ; inline add-windows-message
: LVM_GETHOTITEM LVM_FIRST  61 +  ; inline add-windows-message
: LVM_SETHOTCURSOR LVM_FIRST  62 +  ; inline add-windows-message
: LVM_GETHOTCURSOR LVM_FIRST  63 +  ; inline add-windows-message
: LVM_APPROXIMATEVIEWRECT LVM_FIRST  64 +  ; inline add-windows-message
: LVM_SETWORKAREAS LVM_FIRST  65 +  ; inline add-windows-message
: LVM_GETWORKAREAS LVM_FIRST  70 +  ; inline add-windows-message
: LVM_GETNUMBEROFWORKAREAS LVM_FIRST  73 +  ; inline add-windows-message
: LVM_GETSELECTIONMARK LVM_FIRST  66 +  ; inline add-windows-message
: LVM_SETSELECTIONMARK LVM_FIRST  67 +  ; inline add-windows-message
: LVM_SETHOVERTIME LVM_FIRST  71 +  ; inline add-windows-message
: LVM_GETHOVERTIME LVM_FIRST  72 +  ; inline add-windows-message
: LVM_SETTOOLTIPS LVM_FIRST  74 +  ; inline add-windows-message
: LVM_GETTOOLTIPS LVM_FIRST  78 +  ; inline add-windows-message
: LVM_SORTITEMSEX LVM_FIRST  81 +  ; inline add-windows-message
: LVM_SETBKIMAGEA LVM_FIRST  68 +  ; inline add-windows-message
: LVM_SETBKIMAGEW LVM_FIRST  138 +  ; inline add-windows-message
: LVM_GETBKIMAGEA LVM_FIRST  69 +  ; inline add-windows-message
: LVM_GETBKIMAGEW LVM_FIRST  139 +  ; inline add-windows-message
: LVM_SETSELECTEDCOLUMN LVM_FIRST  140 +  ; inline add-windows-message
: LVM_SETTILEWIDTH LVM_FIRST  141 +  ; inline add-windows-message
: LVM_SETVIEW LVM_FIRST  142 +  ; inline add-windows-message
: LVM_GETVIEW LVM_FIRST  143 +  ; inline add-windows-message
: LVM_INSERTGROUP LVM_FIRST  145 +  ; inline add-windows-message
: LVM_SETGROUPINFO LVM_FIRST  147 +  ; inline add-windows-message
: LVM_GETGROUPINFO LVM_FIRST  149 +  ; inline add-windows-message
: LVM_REMOVEGROUP LVM_FIRST  150 +  ; inline add-windows-message
: LVM_MOVEGROUP LVM_FIRST  151 +  ; inline add-windows-message
: LVM_MOVEITEMTOGROUP LVM_FIRST  154 +  ; inline add-windows-message
: LVM_SETGROUPMETRICS LVM_FIRST  155 +  ; inline add-windows-message
: LVM_GETGROUPMETRICS LVM_FIRST  156 +  ; inline add-windows-message
: LVM_ENABLEGROUPVIEW LVM_FIRST  157 +  ; inline add-windows-message
: LVM_SORTGROUPS LVM_FIRST  158 +  ; inline add-windows-message
: LVM_INSERTGROUPSORTED LVM_FIRST  159 +  ; inline add-windows-message
: LVM_REMOVEALLGROUPS LVM_FIRST  160 +  ; inline add-windows-message
: LVM_HASGROUP LVM_FIRST  161 +  ; inline add-windows-message
: LVM_SETTILEVIEWINFO LVM_FIRST  162 +  ; inline add-windows-message
: LVM_GETTILEVIEWINFO LVM_FIRST  163 +  ; inline add-windows-message
: LVM_SETTILEINFO LVM_FIRST  164 +  ; inline add-windows-message
: LVM_GETTILEINFO LVM_FIRST  165 +  ; inline add-windows-message
: LVM_SETINSERTMARK LVM_FIRST  166 +  ; inline add-windows-message
: LVM_GETINSERTMARK LVM_FIRST  167 +  ; inline add-windows-message
: LVM_INSERTMARKHITTEST LVM_FIRST  168 +  ; inline add-windows-message
: LVM_GETINSERTMARKRECT LVM_FIRST  169 +  ; inline add-windows-message
: LVM_SETINSERTMARKCOLOR LVM_FIRST  170 +  ; inline add-windows-message
: LVM_GETINSERTMARKCOLOR LVM_FIRST  171 +  ; inline add-windows-message
: LVM_SETINFOTIP LVM_FIRST  173 +  ; inline add-windows-message
: LVM_GETSELECTEDCOLUMN LVM_FIRST  174 +  ; inline add-windows-message
: LVM_ISGROUPVIEWENABLED LVM_FIRST  175 +  ; inline add-windows-message
: LVM_GETOUTLINECOLOR LVM_FIRST  176 +  ; inline add-windows-message
: LVM_SETOUTLINECOLOR LVM_FIRST  177 +  ; inline add-windows-message
: LVM_CANCELEDITLABEL LVM_FIRST  179 +  ; inline add-windows-message
: LVM_MAPINDEXTOID LVM_FIRST  180 +  ; inline add-windows-message
: LVM_MAPIDTOINDEX LVM_FIRST  181 +  ; inline add-windows-message
: TVM_INSERTITEMA TV_FIRST  0 +  ; inline add-windows-message
: TVM_INSERTITEMW TV_FIRST  50 +  ; inline add-windows-message
: TVM_DELETEITEM TV_FIRST  1 +  ; inline add-windows-message
: TVM_EXPAND TV_FIRST  2 +  ; inline add-windows-message
: TVM_GETITEMRECT TV_FIRST  4 +  ; inline add-windows-message
: TVM_GETCOUNT TV_FIRST  5 +  ; inline add-windows-message
: TVM_GETINDENT TV_FIRST  6 +  ; inline add-windows-message
: TVM_SETINDENT TV_FIRST  7 +  ; inline add-windows-message
: TVM_GETIMAGELIST TV_FIRST  8 +  ; inline add-windows-message
: TVM_SETIMAGELIST TV_FIRST  9 +  ; inline add-windows-message
: TVM_GETNEXTITEM TV_FIRST  10 +  ; inline add-windows-message
: TVM_SELECTITEM TV_FIRST  11 +  ; inline add-windows-message
: TVM_GETITEMA TV_FIRST  12 +  ; inline add-windows-message
: TVM_GETITEMW TV_FIRST  62 +  ; inline add-windows-message
: TVM_SETITEMA TV_FIRST  13 +  ; inline add-windows-message
: TVM_SETITEMW TV_FIRST  63 +  ; inline add-windows-message
: TVM_EDITLABELA TV_FIRST  14 +  ; inline add-windows-message
: TVM_EDITLABELW TV_FIRST  65 +  ; inline add-windows-message
: TVM_GETEDITCONTROL TV_FIRST  15 +  ; inline add-windows-message
: TVM_GETVISIBLECOUNT TV_FIRST  16 +  ; inline add-windows-message
: TVM_HITTEST TV_FIRST  17 +  ; inline add-windows-message
: TVM_CREATEDRAGIMAGE TV_FIRST  18 +  ; inline add-windows-message
: TVM_SORTCHILDREN TV_FIRST  19 +  ; inline add-windows-message
: TVM_ENSUREVISIBLE TV_FIRST  20 +  ; inline add-windows-message
: TVM_SORTCHILDRENCB TV_FIRST  21 +  ; inline add-windows-message
: TVM_ENDEDITLABELNOW TV_FIRST  22 +  ; inline add-windows-message
: TVM_GETISEARCHSTRINGA TV_FIRST  23 +  ; inline add-windows-message
: TVM_GETISEARCHSTRINGW TV_FIRST  64 +  ; inline add-windows-message
: TVM_SETTOOLTIPS TV_FIRST  24 +  ; inline add-windows-message
: TVM_GETTOOLTIPS TV_FIRST  25 +  ; inline add-windows-message
: TVM_SETINSERTMARK TV_FIRST  26 +  ; inline add-windows-message
: TVM_SETUNICODEFORMAT CCM_SETUNICODEFORMAT ; inline add-windows-message
: TVM_GETUNICODEFORMAT CCM_GETUNICODEFORMAT ; inline add-windows-message
: TVM_SETITEMHEIGHT TV_FIRST  27 +  ; inline add-windows-message
: TVM_GETITEMHEIGHT TV_FIRST  28 +  ; inline add-windows-message
: TVM_SETBKCOLOR TV_FIRST  29 +  ; inline add-windows-message
: TVM_SETTEXTCOLOR TV_FIRST  30 +  ; inline add-windows-message
: TVM_GETBKCOLOR TV_FIRST  31 +  ; inline add-windows-message
: TVM_GETTEXTCOLOR TV_FIRST  32 +  ; inline add-windows-message
: TVM_SETSCROLLTIME TV_FIRST  33 +  ; inline add-windows-message
: TVM_GETSCROLLTIME TV_FIRST  34 +  ; inline add-windows-message
: TVM_SETINSERTMARKCOLOR TV_FIRST  37 +  ; inline add-windows-message
: TVM_GETINSERTMARKCOLOR TV_FIRST  38 +  ; inline add-windows-message
: TVM_GETITEMSTATE TV_FIRST  39 +  ; inline add-windows-message
: TVM_SETLINECOLOR TV_FIRST  40 +  ; inline add-windows-message
: TVM_GETLINECOLOR TV_FIRST  41 +  ; inline add-windows-message
: TVM_MAPACCIDTOHTREEITEM TV_FIRST  42 +  ; inline add-windows-message
: TVM_MAPHTREEITEMTOACCID TV_FIRST  43 +  ; inline add-windows-message
: CBEM_INSERTITEMA WM_USER  1 +  ; inline add-windows-message
: CBEM_SETIMAGELIST WM_USER  2 +  ; inline add-windows-message
: CBEM_GETIMAGELIST WM_USER  3 +  ; inline add-windows-message
: CBEM_GETITEMA WM_USER  4 +  ; inline add-windows-message
: CBEM_SETITEMA WM_USER  5 +  ; inline add-windows-message
: CBEM_DELETEITEM CB_DELETESTRING ; inline add-windows-message
: CBEM_GETCOMBOCONTROL WM_USER  6 +  ; inline add-windows-message
: CBEM_GETEDITCONTROL WM_USER  7 +  ; inline add-windows-message
: CBEM_SETEXTENDEDSTYLE WM_USER  14 +  ; inline add-windows-message
: CBEM_GETEXTENDEDSTYLE WM_USER  9 +  ; inline add-windows-message
: CBEM_SETUNICODEFORMAT CCM_SETUNICODEFORMAT ; inline add-windows-message
: CBEM_GETUNICODEFORMAT CCM_GETUNICODEFORMAT ; inline add-windows-message
: CBEM_SETEXSTYLE WM_USER  8 +  ; inline add-windows-message
: CBEM_GETEXSTYLE WM_USER  9 +  ; inline add-windows-message
: CBEM_HASEDITCHANGED WM_USER  10 +  ; inline add-windows-message
: CBEM_INSERTITEMW WM_USER  11 +  ; inline add-windows-message
: CBEM_SETITEMW WM_USER  12 +  ; inline add-windows-message
: CBEM_GETITEMW WM_USER  13 +  ; inline add-windows-message
: TCM_GETIMAGELIST TCM_FIRST  2 +  ; inline add-windows-message
: TCM_SETIMAGELIST TCM_FIRST  3 +  ; inline add-windows-message
: TCM_GETITEMCOUNT TCM_FIRST  4 +  ; inline add-windows-message
: TCM_GETITEMA TCM_FIRST  5 +  ; inline add-windows-message
: TCM_GETITEMW TCM_FIRST  60 +  ; inline add-windows-message
: TCM_SETITEMA TCM_FIRST  6 +  ; inline add-windows-message
: TCM_SETITEMW TCM_FIRST  61 +  ; inline add-windows-message
: TCM_INSERTITEMA TCM_FIRST  7 +  ; inline add-windows-message
: TCM_INSERTITEMW TCM_FIRST  62 +  ; inline add-windows-message
: TCM_DELETEITEM TCM_FIRST  8 +  ; inline add-windows-message
: TCM_DELETEALLITEMS TCM_FIRST  9 +  ; inline add-windows-message
: TCM_GETITEMRECT TCM_FIRST  10 +  ; inline add-windows-message
: TCM_GETCURSEL TCM_FIRST  11 +  ; inline add-windows-message
: TCM_SETCURSEL TCM_FIRST  12 +  ; inline add-windows-message
: TCM_HITTEST TCM_FIRST  13 +  ; inline add-windows-message
: TCM_SETITEMEXTRA TCM_FIRST  14 +  ; inline add-windows-message
: TCM_ADJUSTRECT TCM_FIRST  40 +  ; inline add-windows-message
: TCM_SETITEMSIZE TCM_FIRST  41 +  ; inline add-windows-message
: TCM_REMOVEIMAGE TCM_FIRST  42 +  ; inline add-windows-message
: TCM_SETPADDING TCM_FIRST  43 +  ; inline add-windows-message
: TCM_GETROWCOUNT TCM_FIRST  44 +  ; inline add-windows-message
: TCM_GETTOOLTIPS TCM_FIRST  45 +  ; inline add-windows-message
: TCM_SETTOOLTIPS TCM_FIRST  46 +  ; inline add-windows-message
: TCM_GETCURFOCUS TCM_FIRST  47 +  ; inline add-windows-message
: TCM_SETCURFOCUS TCM_FIRST  48 +  ; inline add-windows-message
: TCM_SETMINTABWIDTH TCM_FIRST  49 +  ; inline add-windows-message
: TCM_DESELECTALL TCM_FIRST  50 +  ; inline add-windows-message
: TCM_HIGHLIGHTITEM TCM_FIRST  51 +  ; inline add-windows-message
: TCM_SETEXTENDEDSTYLE TCM_FIRST  52 +  ; inline add-windows-message
: TCM_GETEXTENDEDSTYLE TCM_FIRST  53 +  ; inline add-windows-message
: TCM_SETUNICODEFORMAT CCM_SETUNICODEFORMAT ; inline add-windows-message
: TCM_GETUNICODEFORMAT CCM_GETUNICODEFORMAT ; inline add-windows-message
: ACM_OPENA WM_USER 100 +  ; inline add-windows-message
: ACM_OPENW WM_USER 103 +  ; inline add-windows-message
: ACM_PLAY WM_USER 101 +  ; inline add-windows-message
: ACM_STOP WM_USER 102 +  ; inline add-windows-message
: MCM_FIRST HEX: 1000 ; inline add-windows-message
: MCM_GETCURSEL MCM_FIRST  1 +  ; inline add-windows-message
: MCM_SETCURSEL MCM_FIRST  2 +  ; inline add-windows-message
: MCM_GETMAXSELCOUNT MCM_FIRST  3 +  ; inline add-windows-message
: MCM_SETMAXSELCOUNT MCM_FIRST  4 +  ; inline add-windows-message
: MCM_GETSELRANGE MCM_FIRST  5 +  ; inline add-windows-message
: MCM_SETSELRANGE MCM_FIRST  6 +  ; inline add-windows-message
: MCM_GETMONTHRANGE MCM_FIRST  7 +  ; inline add-windows-message
: MCM_SETDAYSTATE MCM_FIRST  8 +  ; inline add-windows-message
: MCM_GETMINREQRECT MCM_FIRST  9 +  ; inline add-windows-message
: MCM_SETCOLOR MCM_FIRST  10 +  ; inline add-windows-message
: MCM_GETCOLOR MCM_FIRST  11 +  ; inline add-windows-message
: MCM_SETTODAY MCM_FIRST  12 +  ; inline add-windows-message
: MCM_GETTODAY MCM_FIRST  13 +  ; inline add-windows-message
: MCM_HITTEST MCM_FIRST  14 +  ; inline add-windows-message
: MCM_SETFIRSTDAYOFWEEK MCM_FIRST  15 +  ; inline add-windows-message
: MCM_GETFIRSTDAYOFWEEK MCM_FIRST  16 +  ; inline add-windows-message
: MCM_GETRANGE MCM_FIRST  17 +  ; inline add-windows-message
: MCM_SETRANGE MCM_FIRST  18 +  ; inline add-windows-message
: MCM_GETMONTHDELTA MCM_FIRST  19 +  ; inline add-windows-message
: MCM_SETMONTHDELTA MCM_FIRST  20 +  ; inline add-windows-message
: MCM_GETMAXTODAYWIDTH MCM_FIRST  21 +  ; inline add-windows-message
: MCM_SETUNICODEFORMAT CCM_SETUNICODEFORMAT ; inline add-windows-message
: MCM_GETUNICODEFORMAT CCM_GETUNICODEFORMAT ; inline add-windows-message
: DTM_FIRST HEX: 1000 ; inline add-windows-message
: DTM_GETSYSTEMTIME DTM_FIRST  1 +  ; inline add-windows-message
: DTM_SETSYSTEMTIME DTM_FIRST  2 +  ; inline add-windows-message
: DTM_GETRANGE DTM_FIRST  3 +  ; inline add-windows-message
: DTM_SETRANGE DTM_FIRST  4 +  ; inline add-windows-message
: DTM_SETFORMATA DTM_FIRST  5 +  ; inline add-windows-message
: DTM_SETFORMATW DTM_FIRST  50 +  ; inline add-windows-message
: DTM_SETMCCOLOR DTM_FIRST  6 +  ; inline add-windows-message
: DTM_GETMCCOLOR DTM_FIRST  7 +  ; inline add-windows-message
: DTM_GETMONTHCAL DTM_FIRST  8 +  ; inline add-windows-message
: DTM_SETMCFONT DTM_FIRST  9 +  ; inline add-windows-message
: DTM_GETMCFONT DTM_FIRST  10 +  ; inline add-windows-message
: PGM_SETCHILD PGM_FIRST  1 +  ; inline add-windows-message
: PGM_RECALCSIZE PGM_FIRST  2 +  ; inline add-windows-message
: PGM_FORWARDMOUSE PGM_FIRST  3 +  ; inline add-windows-message
: PGM_SETBKCOLOR PGM_FIRST  4 +  ; inline add-windows-message
: PGM_GETBKCOLOR PGM_FIRST  5 +  ; inline add-windows-message
: PGM_SETBORDER PGM_FIRST  6 +  ; inline add-windows-message
: PGM_GETBORDER PGM_FIRST  7 +  ; inline add-windows-message
: PGM_SETPOS PGM_FIRST  8 +  ; inline add-windows-message
: PGM_GETPOS PGM_FIRST  9 +  ; inline add-windows-message
: PGM_SETBUTTONSIZE PGM_FIRST  10 +  ; inline add-windows-message
: PGM_GETBUTTONSIZE PGM_FIRST  11 +  ; inline add-windows-message
: PGM_GETBUTTONSTATE PGM_FIRST  12 +  ; inline add-windows-message
: PGM_GETDROPTARGET CCM_GETDROPTARGET ; inline add-windows-message
: BCM_GETIDEALSIZE BCM_FIRST  1 +  ; inline add-windows-message
: BCM_SETIMAGELIST BCM_FIRST  2 +  ; inline add-windows-message
: BCM_GETIMAGELIST BCM_FIRST  3 +  ; inline add-windows-message
: BCM_SETTEXTMARGIN BCM_FIRST 4 +  ; inline add-windows-message
: BCM_GETTEXTMARGIN BCM_FIRST 5 +  ; inline add-windows-message
: EM_SETCUEBANNER	 ECM_FIRST  1 +  ; inline add-windows-message
: EM_GETCUEBANNER	 ECM_FIRST  2 +  ; inline add-windows-message
: EM_SHOWBALLOONTIP ECM_FIRST  3 +  ; inline add-windows-message
: EM_HIDEBALLOONTIP ECM_FIRST  4 +  ; inline add-windows-message 
: CB_SETMINVISIBLE CBM_FIRST  1 +  ; inline add-windows-message
: CB_GETMINVISIBLE CBM_FIRST  2 +  ; inline add-windows-message
: LM_HITTEST WM_USER  HEX: 0300 +  ; inline add-windows-message 
: LM_GETIDEALHEIGHT WM_USER  HEX: 0301 +  ; inline add-windows-message
: LM_SETITEM WM_USER  HEX: 0302 + ; inline add-windows-message 
: LM_GETITEM WM_USER  HEX: 0303 + ; inline add-windows-message
