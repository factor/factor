! Copyright (C) 2007 Elie CHAFTARI
! See http://factorcode.org/license.txt for BSD license.
!
! Tested with libharu2 2.0.8 on Mac OS X 10.4.9 PowerPC
!
! export LD_LIBRARY_PATH=/opt/local/lib

USING: alien alien.syntax combinators system ;

IN: pdf.libhpdf

<< "libhpdf" {
    { [ win32? ] [ "libhpdf.dll" stdcall ] }
    { [ macosx? ] [ "libhpdf.dylib" cdecl ] }
    { [ unix? ] [ "$LD_LIBRARY_PATH/libhpdf.so" cdecl ] }
} cond add-library >>

! compression mode
: HPDF_COMP_NONE      0x00 ; inline ! No contents are compressed
: HPDF_COMP_TEXT      0x01 ; inline ! Compress contents stream of page
: HPDF_COMP_IMAGE     0x02 ; inline ! Compress streams of image objects
: HPDF_COMP_METADATA  0x04 ; inline ! Compress other data (fonts, cmaps...)
: HPDF_COMP_ALL       0x0F ; inline ! All stream data are compressed
: HPDF_COMP_MASK      0xFF ; inline

! page mode
CONSTANT: HPDF_PAGE_MODE_USE_NONE 0
CONSTANT: HPDF_PAGE_MODE_USE_OUTLINE 1
CONSTANT: HPDF_PAGE_MODE_USE_THUMBS 2
CONSTANT: HPDF_PAGE_MODE_FULL_SCREEN 3
CONSTANT: HPDF_PAGE_MODE_EOF 4

: error-code ( -- seq ) {
     { 0x1001  "HPDF_ARRAY_COUNT_ERR\nInternal error. The consistency of the data was lost." }
     { 0x1002  "HPDF_ARRAY_ITEM_NOT_FOUND\nInternal error. The consistency of the data was lost." }
     { 0x1003  "HPDF_ARRAY_ITEM_UNEXPECTED_TYPE\nInternal error. The consistency of the data was lost." }
     { 0x1004  "HPDF_BINARY_LENGTH_ERR\nThe length of the data exceeds HPDF_LIMIT_MAX_STRING_LEN." }
     { 0x1005  "HPDF_CANNOT_GET_PALLET\nCannot get a pallet data from PNG image." }
     { 0x1007  "HPDF_DICT_COUNT_ERR\nThe count of elements of a dictionary exceeds HPDF_LIMIT_MAX_DICT_ELEMENT" }
     { 0x1008  "HPDF_DICT_ITEM_NOT_FOUND\nInternal error. The consistency of the data was lost." }
     { 0x1009  "HPDF_DICT_ITEM_UNEXPECTED_TYPE\nInternal error. The consistency of the data was lost." }  
     { 0x100A  "HPDF_DICT_STREAM_LENGTH_NOT_FOUND\nInternal error. The consistency of the data was lost." }  
     { 0x100B  "HPDF_DOC_ENCRYPTDICT_NOT_FOUND\nHPDF_SetPermission() OR HPDF_SetEncryptMode() was called before a password is set." }
     { 0x100C  "HPDF_DOC_INVALID_OBJECT\nInternal error. The consistency of the data was lost." }
     { 0x100E  "HPDF_DUPLICATE_REGISTRATION\nTried to register a font that has been registered." }
     { 0x100F  "HPDF_EXCEED_JWW_CODE_NUM_LIMIT\nCannot register a character to the japanese word wrap characters list." }
     { 0x1011  "HPDF_ENCRYPT_INVALID_PASSWORD\nTried to set the owner password to NULL. owner password and user password is the same." }
     { 0x1013  "HPDF_ERR_UNKNOWN_CLASS\nInternal error. The consistency of the data was lost." }
     { 0x1014  "HPDF_EXCEED_GSTATE_LIMIT\nThe depth of the stack exceeded HPDF_LIMIT_MAX_GSTATE." }
     { 0x1015  "HPDF_FAILED_TO_ALLOC_MEM\nMemory allocation failed." }
     { 0x1016  "HPDF_FILE_IO_ERROR\nFile processing failed. (A detailed code is set.)" }
     { 0x1017  "HPDF_FILE_OPEN_ERROR\nCannot open a file. (A detailed code is set.)" }
     { 0x1019  "HPDF_FONT_EXISTS\nTried to load a font that has already been registered." }
     { 0x101A  "HPDF_FONT_INVALID_WIDTHS_TABLE\nThe format of a font-file is invalid . Internal error. The consistency of the data was lost." }
     { 0x101B  "HPDF_INVALID_AFM_HEADER\nCannot recognize a header of an afm file." }
     { 0x101C  "HPDF_INVALID_ANNOTATION\nThe specified annotation handle is invalid." }
     { 0x101E  "HPDF_INVALID_BIT_PER_COMPONENT\nBit-per-component of a image which was set as mask-image is invalid." }
     { 0x101F  "HPDF_INVALID_CHAR_MATRICS_DATA\nCannot recognize char-matrics-data  of an afm file." }
     { 0x1020  "HPDF_INVALID_COLOR_SPACE\n1. The color_space parameter of HPDF_LoadRawImage is invalid.\n2. Color-space of a image which was set as mask-image is invalid.\n3. The function which is invalid in the present color-space was invoked." }
     { 0x1021  "HPDF_INVALID_COMPRESSION_MODE\nInvalid value was set when invoking HPDF_SetCommpressionMode()." }
     { 0x1022  "HPDF_INVALID_DATE_TIME\nAn invalid date-time value was set." }
     { 0x1023  "HPDF_INVALID_DESTINATION\nAn invalid destination handle was set." }
     { 0x1025  "HPDF_INVALID_DOCUMENT\nAn invalid document handle is set." }
     { 0x1026  "HPDF_INVALID_DOCUMENT_STATE\nThe function which is invalid in the present state was invoked." }
     { 0x1027  "HPDF_INVALID_ENCODER\nAn invalid encoder handle was set." }
     { 0x1028  "HPDF_INVALID_ENCODER_TYPE\nA combination between font and encoder is wrong." }
     { 0x102B  "HPDF_INVALID_ENCODING_NAME\nAn Invalid encoding name is specified." }
     { 0x102C  "HPDF_INVALID_ENCRYPT_KEY_LEN\nThe lengh of the key of encryption is invalid." }
     { 0x102D  "HPDF_INVALID_FONTDEF_DATA\n1. An invalid font handle was set.\n2. Unsupported font format." }
     { 0x102E  "HPDF_INVALID_FONTDEF_TYPE\nInternal error. The consistency of the data was lost." }
     { 0x102F  "HPDF_INVALID_FONT_NAME\nA font which has the specified name is not found." }
     { 0x1030  "HPDF_INVALID_IMAGE\nUnsupported image format." }
     { 0x1031  "HPDF_INVALID_JPEG_DATA\nUnsupported image format." }
     { 0x1032  "HPDF_INVALID_N_DATA\nCannot read a postscript-name from an afm file." }
     { 0x1033  "HPDF_INVALID_OBJECT\n1. An invalid object is set.\n2. Internal error. The consistency of the data was lost." }
     { 0x1034  "HPDF_INVALID_OBJ_ID\nInternal error. The consistency of the data was lost." }
     { 0x1035  "HPDF_INVALID_OPERATION\nInvoked HPDF_Image_SetColorMask() against the image-object which was set a mask-image." }
     { 0x1036  "HPDF_INVALID_OUTLINE\nAn invalid outline-handle was specified." }
     { 0x1037  "HPDF_INVALID_PAGE\nAn invalid page-handle was specified." }
     { 0x1038  "HPDF_INVALID_PAGES\nAn invalid pages-handle was specified. (internal error)" }
     { 0x1039  "HPDF_INVALID_PARAMETER\nAn invalid value is set." }
     { 0x103B  "HPDF_INVALID_PNG_IMAGE\nInvalid PNG image format." }
     { 0x103C  "HPDF_INVALID_STREAM\nInternal error. The consistency of the data was lost." }
     { 0x103D  "HPDF_MISSING_FILE_NAME_ENTRY\nInternal error. The \"_FILE_NAME\" entry for delayed loading is missing." }
     { 0x103F  "HPDF_INVALID_TTC_FILE\nInvalid .TTC file format." }
     { 0x1040  "HPDF_INVALID_TTC_INDEX\nThe index parameter was exceed the number of included fonts" }
     { 0x1041  "HPDF_INVALID_WX_DATA\nCannot read a width-data from an afm file." }
     { 0x1042  "HPDF_ITEM_NOT_FOUND\nInternal error. The consistency of the data was lost." }
     { 0x1043  "HPDF_LIBPNG_ERROR\nAn error has returned from PNGLIB while loading an image." }
     { 0x1044  "HPDF_NAME_INVALID_VALUE\nInternal error. The consistency of the data was lost." }
     { 0x1045  "HPDF_NAME_OUT_OF_RANGE\nInternal error. The consistency of the data was lost." }
     { 0x1049  "HPDF_PAGES_MISSING_KIDS_ENTRY\nInternal error. The consistency of the data was lost." }
     { 0x104A  "HPDF_PAGE_CANNOT_FIND_OBJECT\nInternal error. The consistency of the data was lost." }
     { 0x104B  "HPDF_PAGE_CANNOT_GET_ROOT_PAGES\nInternal error. The consistency of the data was lost." }
     { 0x104C  "HPDF_PAGE_CANNOT_RESTORE_GSTATE\nThere are no graphics-states to be restored." }
     { 0x104D  "HPDF_PAGE_CANNOT_SET_PARENT\nInternal error. The consistency of the data was lost." }
     { 0x104E  "HPDF_PAGE_FONT_NOT_FOUND\nThe current font is not set." }
     { 0x104F  "HPDF_PAGE_INVALID_FONT\nAn invalid font-handle was specified." }
     { 0x1050  "HPDF_PAGE_INVALID_FONT_SIZE\nAn invalid font-size was set." }
     { 0x1051  "HPDF_PAGE_INVALID_GMODE\nSee Graphics mode." }
     { 0x1052  "HPDF_PAGE_INVALID_INDEX\nInternal error. The consistency of the data was lost." }
     { 0x1053  "HPDF_PAGE_INVALID_ROTATE_VALUE\nThe specified value is not a multiple of 90." }
     { 0x1054  "HPDF_PAGE_INVALID_SIZE\nAn invalid page-size was set." }
     { 0x1055  "HPDF_PAGE_INVALID_XOBJECT\nAn invalid image-handle was set." }
     { 0x1056  "HPDF_PAGE_OUT_OF_RANGE\nThe specified value is out of range." }
     { 0x1057  "HPDF_REAL_OUT_OF_RANGE\nThe specified value is out of range." }
     { 0x1058  "HPDF_STREAM_EOF\nUnexpected EOF marker was detected." }
     { 0x1059  "HPDF_STREAM_READLN_CONTINUE\nInternal error. The consistency of the data was lost." }
     { 0x105B  "HPDF_STRING_OUT_OF_RANGE\nThe length of the specified text is too long." }
     { 0x105C  "HPDF_THIS_FUNC_WAS_SKIPPED\nThe execution of a function was skipped because of other errors." }
     { 0x105D  "HPDF_TTF_CANNOT_EMBEDDING_FONT\nThis font cannot be embedded. (restricted by license.)" }
     { 0x105E  "HPDF_TTF_INVALID_CMAP\nUnsupported ttf format. (cannot find unicode cmap.)" }
     { 0x105F  "HPDF_TTF_INVALID_FOMAT\nUnsupported ttf format." }
     { 0x1060  "HPDF_TTF_MISSING_TABLE\nUnsupported ttf format. (cannot find a necessary table.)" }
     { 0x1061  "HPDF_UNSUPPORTED_FONT_TYPE\nInternal error. The consistency of the data was lost." }
     { 0x1062  "HPDF_UNSUPPORTED_FUNC\n1. The library is not configured to use PNGLIB.\n2. Internal error. The consistency of the data was lost." }
     { 0x1063  "HPDF_UNSUPPORTED_JPEG_FORMAT\nUnsupported Jpeg format." }
     { 0x1064  "HPDF_UNSUPPORTED_TYPE1_FONT\nFailed to parse .PFB file." }
     { 0x1065  "HPDF_XREF_COUNT_ERR\nInternal error. The consistency of the data was lost." }
     { 0x1066  "HPDF_ZLIB_ERROR\nAn error has occurred while executing a function of Zlib." }
     { 0x1067  "HPDF_INVALID_PAGE_INDEX\nAn error returned from Zlib." }
     { 0x1068  "HPDF_INVALID_URI\nAn invalid URI was set." }
     { 0x1069  "HPDF_PAGELAYOUT_OUT_OF_RANGE\nAn invalid page-layout was set." }
     { 0x1070  "HPDF_PAGEMODE_OUT_OF_RANGE\nAn invalid page-mode was set." }
     { 0x1071  "HPDF_PAGENUM_STYLE_OUT_OF_RANGE\nAn invalid page-num-style was set." }
     { 0x1072  "HPDF_ANNOT_INVALID_ICON\nAn invalid icon was set." }
     { 0x1073  "HPDF_ANNOT_INVALID_BORDER_STYLE\nAn invalid border-style was set." }
     { 0x1074  "HPDF_PAGE_INVALID_DIRECTION\nAn invalid page-direction was set." }
     { 0x1075  "HPDF_INVALID_FONT\nAn invalid font-handle was specified." }
} ;

LIBRARY: libhpdf

! ===============================================
! hpdf.h
! ===============================================

FUNCTION: void* HPDF_New ( void* user_error_fn, void* user_data ) ;

FUNCTION: void* HPDF_Free ( void* pdf ) ;

FUNCTION: ulong HPDF_SetCompressionMode ( void* pdf, uint mode ) ;

FUNCTION: ulong HPDF_SetPageMode ( void* pdf, uint mode ) ;

FUNCTION: void* HPDF_AddPage ( void* pdf ) ;

FUNCTION: ulong HPDF_SaveToFile ( void* pdf, char* file_name ) ;

FUNCTION: float HPDF_Page_GetHeight ( void* page ) ;

FUNCTION: float HPDF_Page_GetWidth ( void* page ) ;

FUNCTION: ulong HPDF_Page_SetLineWidth ( void* page, float line_width ) ;

FUNCTION: ulong HPDF_Page_Rectangle ( void* page, float x, float y,
                                      float width, float height ) ;

FUNCTION: ulong HPDF_Page_Stroke ( void* page ) ;

FUNCTION: void* HPDF_GetFont ( void* pdf, char* font_name,
                               char* encoding_name ) ;

FUNCTION: ulong HPDF_Page_SetFontAndSize ( void* page, void* font,
                                           float size ) ;

FUNCTION: float HPDF_Page_TextWidth ( void* page, char* text ) ;

FUNCTION: ulong HPDF_Page_BeginText ( void* page ) ;

FUNCTION: ulong HPDF_Page_TextOut ( void* page, float xpos, float ypos,
                                    char* text ) ;

FUNCTION: ulong HPDF_Page_EndText ( void*  page ) ;

FUNCTION: ulong HPDF_Page_MoveTextPos ( void* page, float x, float y ) ;

FUNCTION: ulong HPDF_Page_ShowText ( void* page, char* text ) ;
