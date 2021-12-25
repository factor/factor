! Copyright (C) 2019 Jack Lucas
! See http://factorcode.org/license.txt for BSD license.
! These should be complete bindings to the Raygui library 3.0
! Most of the comments are included from the original header
! for your convenience.
USING: alien alien.c-types alien.libraries alien.syntax
classes.struct combinators raylib system ;
IN: raygui

<<
"raygui" {
    { [ os windows? ] [ "raygui.dll" ] }
    { [ os macosx? ] [ "libraygui.dylib" ] }
    { [ os unix? ] [ "libraygui.so" ] }
} cond cdecl add-library

"raygui" deploy-library
>>

LIBRARY: raygui

! Enumerations ----------------------------------------------------------

! Style property
STRUCT: GuiStyleProp
    { controlId ushort }
    { propertyId ushort }
    { propertyValue int } ;

! Gui control state
ENUM: GuiControlState
    GUI_STATE_NORMAL
    GUI_STATE_FOCUSED
    GUI_STATE_PRESSED
    GUI_STATE_DISABLED ;

! Gui control text alignment
ENUM: GuiTextAlignment
    GUI_TEXT_ALIGN_LEFT
    GUI_TEXT_ALIGN_CENTER
    GUI_TEXT_ALIGN_RIGHT ;

! Gui controls
ENUM: GuiControl
    DEFAULT        ! Generic control -> populates to all controls when set
    LABEL          ! Used also for: LABELBUTTON
    BUTTON
    TOGGLE         ! Used also for: TOGGLEGROUP
    SLIDER         ! Used also for: SLIDERBAR
    PROGRESSBAR
    CHECKBOX
    COMBOBOX
    DROPDOWNBOX
    TEXTBOX        ! Used also for: TEXTBOXMULTI
    VALUEBOX
    SPINNER
    LISTVIEW
    COLORPICKER
    SCROLLBAR
    STATUSBAR ;

! Gui base properties for every control
! NOTE: RAYGUI_MAX_PROPS_BASE properties (by default 16 properties)
ENUM: GuiControlProperty
    BORDER_COLOR_NORMAL
    BASE_COLOR_NORMAL
    TEXT_COLOR_NORMAL
    BORDER_COLOR_FOCUSED
    BASE_COLOR_FOCUSED
    TEXT_COLOR_FOCUSED
    BORDER_COLOR_PRESSED
    BASE_COLOR_PRESSED
    TEXT_COLOR_PRESSED
    BORDER_COLOR_DISABLED
    BASE_COLOR_DISABLED
    TEXT_COLOR_DISABLED
    BORDER_WIDTH
    TEXT_PADDING
    TEXT_ALIGNMENT
    RESERVED ;

! Gui extended properties depend on control
! NOTE: RAYGUI_MAX_PROPS_EXTENDED properties (by default 8 properties)

! DEFAULT extended properties
! NOTE: Those properties are actually common to all controls
ENUM: GuiDefaultProperty
    { TEXT_SIZE 16 }
    TEXT_SPACING
    LINE_COLOR
    BACKGROUND_COLOR ;

! Toggle/ToggleGroup
ENUM: GuiToggleProperty
    { GROUP_PADDING 16 } ;

! Slider/SliderBar
ENUM: GuiSliderProperty
    { SLIDER_WIDTH 16 }
    SLIDER_PADDING ;

! ProgressBar
ENUM: GuiProgressBarProperty
    { PROGRESS_PADDING 16 } ;

! CheckBox
ENUM: GuiCheckBoxProperty
    { CHECK_PADDING 16 } ;

! ComboBox
ENUM: GuiComboBoxProperty
    { COMBO_BUTTON_WIDTH 16 }
    COMBO_BUTTON_PADDING ;

! DropdownBox
ENUM: GuiDropdownBoxProperty
    { ARROW_PADDING 16 }
    DROPDOWN_ITEMS_PADDING ;

! TextBox/TextBoxMulti/ValueBox/Spinner
ENUM: GuiTextBoxProperty
    { TEXT_INNER_PADDING 16 }
    TEXT_LINES_PADDING
    COLOR_SELECTED_FG
    COLOR_SELECTED_BG ;

! Spinner
ENUM: GuiSpinnerProperty;
    { SPIN_BUTTON_WIDTH 16 }
    SPIN_BUTTON_PADDING ;

! ScrollBar
ENUM: GuiScrollBarProperty
    { ARROWS_SIZE 16 }
    ARROWS_VISIBLE
    SCROLL_SLIDER_PADDING
    SCROLL_SLIDER_SIZE
    SCROLL_PADDING
    SCROLL_SPEED ;

! ScrollBar side
ENUM: GuiScrollBarSide
    SCROLLBAR_LEFT_SIDE
    SCROLLBAR_RIGHT_SIDE ;

! ListView
ENUM: GuiListViewProperty
    { LIST_ITEMS_HEIGHT 16 }
    LIST_ITEMS_PADDING
    SCROLLBAR_WIDTH
    SCROLLBAR_SIDE ;

! ColorPicker
ENUM: GuiColorPickerProperty
    { COLOR_SELECTOR_SIZE 16 }
    HUEBAR_WIDTH                  ! Right hue bar width
    HUEBAR_PADDING                ! Right hue bar separation from panel
    HUEBAR_SELECTOR_HEIGHT        ! Right hue bar selector height
    HUEBAR_SELECTOR_OVERFLOW ;    ! Right hue bar selector overflow

! ----------------------------------------------------------------------------------
! Module Functions Declaration
! ----------------------------------------------------------------------------------

! Global gui state control functions
FUNCTION-ALIAS: gui-enable void GuiEnable ( )                                           ! Enable gui controls (global state)
FUNCTION-ALIAS: gui-disable void GuiDisable ( )                                         ! Disable gui controls (global state)
FUNCTION-ALIAS: gui-lock void GuiLock ( )                                               ! Lock gui controls (global state)
FUNCTION-ALIAS: gui-unlock void GuiUnlock ( )                                           ! Unlock gui controls (global state)
FUNCTION-ALIAS: gui-is-locked bool GuiIsLocked ( )                                      ! Check if gui is locked (global state)
FUNCTION-ALIAS: gui-fade void GuiFade ( float alpha )                                   ! Set gui controls alpha (global state), alpha goes from 0.0f to 1.0f
FUNCTION-ALIAS: gui-set-state void GuiSetState ( int state )                            ! Set gui state (global state)
FUNCTION-ALIAS: gui-get-state int GuiGetState ( )                                       ! Get gui state (global state)

! Font set/get functions
FUNCTION-ALIAS: gui-set-font void GuiSetFont ( Font font )                              ! Set gui custom font (global state)
FUNCTION-ALIAS: gui-get-font Font GuiGetFont ( )                                        ! Get gui custom font (global state)

! Style set/get functions
FUNCTION-ALIAS: gui-set-style void GuiSetStyle ( int control, int property, int value ) ! Set one style property
FUNCTION-ALIAS: gui-get-style int GuiGetStyle ( int control, int property )             ! Get one style property

! Container/separator controls, useful for controls organization
FUNCTION-ALIAS: gui-window-box bool GuiWindowBox ( Rectangle bounds, c-string title )   ! Window Box control, shows a window that can be closed
FUNCTION-ALIAS: gui-group-box void GuiGroupBox ( Rectangle bounds, c-string text )      ! Group Box control with text name
FUNCTION-ALIAS: gui-line void GuiLine ( Rectangle bounds, c-string text )               ! Line separator control, could contain text
FUNCTION-ALIAS: gui-panel void GuiPanel ( Rectangle bounds )                            ! Panel control, useful to group controls
FUNCTION-ALIAS: gui-scroll-panel Rectangle GuiScrollPanel ( Rectangle bounds, Rectangle content, Vector2* scroll ) ! Scroll Panel control

! Basic controls set
FUNCTION-ALIAS: gui-label void GuiLabel ( Rectangle bounds, c-string text )                                                               ! Label control, shows text
FUNCTION-ALIAS: gui-button bool GuiButton ( Rectangle bounds, c-string text )                                                             ! Button control, returns true when clicked
FUNCTION-ALIAS: gui-label-button bool GuiLabelButton ( Rectangle bounds, c-string text )                                                  ! Label button control, show true when clicked
FUNCTION-ALIAS: gui-toggle bool GuiToggle ( Rectangle bounds, c-string text, bool active )                                                ! Toggle Button control, returns true when active
FUNCTION-ALIAS: gui-toggle-group int GuiToggleGroup ( Rectangle bounds, c-string text, int active )                                       ! Toggle Group control, returns active toggle index
FUNCTION-ALIAS: gui-check-box bool GuiCheckBox ( Rectangle bounds, c-string text, bool checked )                                          ! Check Box control, returns true when active
FUNCTION-ALIAS: gui-combo-box int GuiComboBox ( Rectangle bounds, c-string text, int active )                                             ! Combo Box control, returns selected item index
FUNCTION-ALIAS: gui-dropdown-box bool GuiDropdownBox ( Rectangle bounds, c-string text, int* active, bool editMode )                      ! Dropdown Box control, returns selected item
FUNCTION-ALIAS: gui-spinner bool GuiSpinner ( Rectangle bounds, c-string text, int* value, int minValue, int maxValue, bool editMode )    ! Spinner control, returns selected value
FUNCTION-ALIAS: gui-value-box bool GuiValueBox ( Rectangle bounds, c-string text, int* value, int minValue, int maxValue, bool editMode ) ! Value Box control, updates input text with numbers
FUNCTION-ALIAS: gui-text-box bool GuiTextBox ( Rectangle bounds, char *text, int textSize, bool editMode )                                ! Text Box control, updates input text
FUNCTION-ALIAS: gui-text-box-multi bool GuiTextBoxMulti ( Rectangle bounds, char *text, int textSize, bool editMode )                     ! Text Box control with multiple lines
FUNCTION-ALIAS: gui-slider float GuiSlider ( Rectangle bounds, c-string textLeft, c-string textRight, float value, float minValue, float maxValue ) ! Slider control, returns selected value
FUNCTION-ALIAS: gui-slider-bar float GuiSliderBar ( Rectangle bounds, c-string textLeft, c-string textRight, float value, float minValue, float maxValue ) ! Slider Bar control, returns selected value
FUNCTION-ALIAS: gui-progress-bar float GuiProgressBar ( Rectangle bounds, c-string textLeft, c-string textRight, float value, float minValue, float maxValue ) ! Progress Bar control, shows current progress value
FUNCTION-ALIAS: gui-status-bar void GuiStatusBar ( Rectangle bounds, c-string text )                                                      ! Status Bar control, shows info text
FUNCTION-ALIAS: gui-dummy-rec void GuiDummyRec ( Rectangle bounds, c-string text )                                                        ! Dummy control for placeholders
FUNCTION-ALIAS: gui-scroll-bar int GuiScrollBar ( Rectangle bounds, int value, int minValue, int maxValue )                               ! Scroll Bar control
FUNCTION-ALIAS: gui-grid Vector2 GuiGrid ( Rectangle bounds, float spacing, int subdivs )                                                 ! Grid control


! Advance controls set
FUNCTION-ALIAS: gui-list-view int GuiListView ( Rectangle bounds, c-string text, int* scrollIndex, int active )                           ! List View control, returns selected list item index
FUNCTION-ALIAS: gui-list-view-ex int GuiListViewEx ( Rectangle bounds, c-string* text, int count, int* focus, int* scrollIndex, int active ) ! List View with extended parameters
FUNCTION-ALIAS: gui-message-box int GuiMessageBox ( Rectangle bounds, c-string title, c-string message, c-string buttons )                ! Message Box control, displays a message
FUNCTION-ALIAS: gui-text-input-box int GuiTextInputBox ( Rectangle bounds, c-string title, c-string message, c-string buttons, char *text ) ! Text Input Box control, ask for text
FUNCTION-ALIAS: gui-color-picker Color GuiColorPicker ( Rectangle bounds, Color color )                                                   ! Color Picker control (multiple color controls)
FUNCTION-ALIAS: gui-color-panel Color GuiColorPanel ( Rectangle bounds, Color color )                                                     ! Color Panel control
FUNCTION-ALIAS: gui-color-bar-alpha float GuiColorBarAlpha ( Rectangle bounds, float alpha )                                              ! Color Bar Alpha control
FUNCTION-ALIAS: gui-color-bar-hue float GuiColorBarHue ( Rectangle bounds, float value )                                                  ! Color Bar Hue control

! Styles loading functions
FUNCTION-ALIAS: gui-load-style-(c--string void GuiLoadStyle ( c-string fileName )          ! Load style file over global style variable (.rgs)
FUNCTION-ALIAS: gui-load-style-default void GuiLoadStyleDefault ( )                      ! Load style default over global style

FUNCTION-ALIAS: gui-icon-text c-string GuiIconText ( int iconId, c-string text )         ! Get text with icon id prepended (if supported)

! Gui icons functionality
FUNCTION-ALIAS: gui-draw-icon void GuiDrawIcon ( int iconId, int posX, int posY, int pixelSize, Color color )

FUNCTION-ALIAS: gui-get-icons uint* GuiGetIcons ( )                                      ! Get full icons data pointer
FUNCTION-ALIAS: gui-get-icon-data uint* GuiGetIconData ( int iconId )                    ! Get icon bit data
FUNCTION-ALIAS: gui-set-icon-data void GuiSetIconData ( int iconId, uint* data )         ! Set icon bit data

FUNCTION-ALIAS: gui-set-icon-pixel void GuiSetIconPixel ( int iconId, int x, int y )     ! Set icon pixel value
FUNCTION-ALIAS: gui-clear-icon-pixel void GuiClearIconPixel ( int iconId, int x, int y ) ! Clear icon pixel value
FUNCTION-ALIAS: gui-check-icon-pixel bool GuiCheckIconPixel ( int iconId, int x, int y ) ! Check icon pixel value
