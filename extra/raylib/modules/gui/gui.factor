! Copyright (C) 2019 Jack Lucas
! See http://factorcode.org/license.txt for BSD license.
! These should be complete bindings to the Raygui library 2.0
! Most of the comments are included from the original header
! for your convenience.
USING: alien alien.c-types alien.enums alien.libraries
alien.libraries.finder alien.syntax classes.struct combinators
kernel quotations system vocabs raylib.ffi ;
IN: raylib.modules.gui

! Enumerations ----------------------------------------------------------

! Gui global state enum
ENUM: GuiControlState
    GUI_STATE_NORMAL
    GUI_STATE_FOCUSED
    GUI_STATE_PRESSED
    GUI_STATE_DISABLED ;

! Gui global text alignment
ENUM: GuiTextAlignment
    GUI_TEXT_ALIGN_LEFT
    GUI_TEXT_ALIGN_CENTER
    GUI_TEXT_ALIGN_RIGHT ;

! Gui standard controls
ENUM: GuiControlStandard
    DEFAULT 
    LABEL          ! LABELBUTTON
    BUTTON         ! IMAGEBUTTON
    TOGGLE         ! TOGGLEGROUP
    SLIDER         ! SLIDERBAR
    PROGRESSBAR
    CHECKBOX
    COMBOBOX
    DROPDOWNBOX
    TEXTBOX        ! VALUEBOX SPINNER
    LISTVIEW
    COLORPICKER
    SCROLLBAR ;

! Gui default properties for every control
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
    INNER_PADDING
    TEXT_ALIGNMENT
    RESERVED02 ;

! Gui extended properties depending on control type
! NOTE: We reserve a fixed size of additional properties per control (8)

! Default properties
ENUM: GuiDefaultProperty
    { TEXT_SIZE        16 }
    { TEXT_SPACING     17 }
    { TEXT_COLOR       18 }
    { BACKGROUND_COLOR 19 } ;

! Toggle / ToggleGroup
ENUM: GuiToggleProperty
    { GROUP_PADDING 16 } ;

! Slider / SliderBar
ENUM: GuiSliderProperty
    { SLIDER_WIDTH 16 }
    { TEXT_PADDING 17 } ;

! TextBox / ValueBox / Spinner
ENUM: GuiTextBoxProperty
    { MULTILINE_PADDING           16 }
    { SPINNER_BUTTON_WIDTH        17 }
    { SPINNER_BUTTON_PADDING      18 }
    { SPINNER_BUTTON_BORDER_WIDTH 19 } ;

! CheckBox
ENUM: GuiCheckBoxProperty
    { CHECK_TEXT_PADDING 16 } ;

! ComboBox
ENUM: GuiComboBoxProperty
    { SELECTOR_WIDTH   16 }
    { SELECTOR_PADDING 17 } ;

! DropdownBox
ENUM: GuiDropdownBoxProperty
    { ARROW_RIGHT_PADDING 16 } ;

! ColorPicker
ENUM: GuiColorPickerProperty
    { COLOR_SELECTOR_SIZE  16 }
    { BAR_WIDTH            17 }   ! Lateral bar width
    { BAR_PADDING          18 }   ! Later bar separation from panel
    { BAR_SELECTOR_HEIGHT  19 }   ! Lateral bar selector height
    { BAR_SELECTOR_PADDING 20 } ; ! Later bar selector outer padding

! ListView
ENUM: GuiListViewProperty
    { ELEMENTS_HEIGHT 16 }
    { ELEMENTS_PADDING 17 }
    { SCROLLBAR_WIDTH 18 }
    { SCROLLBAR_SIDE 19 } ; ! This property defines vertical scrollbar side

! ScrollBar
ENUM: GuiScrollBarProperty
    { SCROLLBAR_BORDER               16 }
    { SCROLLBAR_SHOW_SPINNER_BUTTONS 17 }
    { SCROLLBAR_ARROWS_SIZE          18 }
    { SCROLLBAR_PADDING              19 }
    { SCROLLBAR_SLIDER_PADDING       20 }
    { SCROLLBAR_SLIDER_SIZE          21 }
    { SCROLLBAR_SCROLL_SPEED         22 } ;

! ScrollBar side
ENUM: GuiScrollBarSide
    SCROLLBAR_LEFT_SIDE
    SCROLLBAR_RIGHT_SIDE ;

! Functions ---------------------------------------------------------


! Global gui modification functions
FUNCTION-ALIAS:  rl-gui-enable void GuiEnable ( )         ! Enable gui controls  ( global state ) 
FUNCTION-ALIAS:  rl-gui-disable void GuiDisable ( )       ! Disable gui controls  ( global state ) 
FUNCTION-ALIAS:  rl-gui-lock void GuiLock ( )             ! Lock gui controls  ( global state ) 
FUNCTION-ALIAS:  rl-gui-unlock void GuiUnlock ( )         ! Unlock gui controls  ( global state ) 
FUNCTION-ALIAS:  rl-gui-state void GuiState ( int state ) ! Set gui state  ( global state ) 
FUNCTION-ALIAS:  rl-gui-font void GuiFont ( Font font )   ! Set gui custom font  ( global state ) 
FUNCTION-ALIAS:  rl-gui-fade void GuiFade ( float alpha ) ! Set gui controls alpha  ( global state ) , alpha goes from 0.0f to 1.0f

! Style set/get functions
FUNCTION-ALIAS:  rl-gui-set-style void GuiSetStyle ( int control, int property, int value ) ! Set one style property
FUNCTION-ALIAS:  rl-gui-get-style int GuiGetStyle ( int control, int property )             ! Get one style property

! Container/separator controls, useful for controls organization
FUNCTION-ALIAS:  rl-gui-window-box bool GuiWindowBox ( Rectangle bounds, c-string text )                              ! Window Box control, shows a window that can be closed
FUNCTION-ALIAS:  rl-gui-group-box void GuiGroupBox ( Rectangle bounds, c-string text )                                ! Group Box control with title name
FUNCTION-ALIAS:  rl-gui-line void GuiLine ( Rectangle bounds, c-string text )                                         ! Line separator control, could contain text
FUNCTION-ALIAS:  rl-gui-panel void GuiPanel ( Rectangle bounds )                                                      ! Panel control, useful to group controls
FUNCTION-ALIAS:  rl-gui-scrollpanel Rectangle GuiScrollPanel ( Rectangle bounds, Rectangle content, Vector2 *scroll ) ! Scroll Panel control

! Basic controls set
FUNCTION-ALIAS:  rl-gui-label void GuiLabel ( Rectangle bounds, c-string text )                                                                            ! Label control, shows text
FUNCTION-ALIAS:  rl-gui-button bool GuiButton ( Rectangle bounds, c-string text )                                                                          ! Button control, returns true when clicked
FUNCTION-ALIAS:  rl-gui-label-button bool GuiLabelButton ( Rectangle bounds, c-string text )                                                               ! Label button control, show true when clicked
FUNCTION-ALIAS:  rl-gui-image-button bool GuiImageButton ( Rectangle bounds, Texture2D texture )                                                           ! Image button control, returns true when clicked
FUNCTION-ALIAS:  rl-gui-image-button-ex bool GuiImageButtonEx ( Rectangle bounds, Texture2D texture, Rectangle texSource, c-string text )                  ! Image button extended control, returns true when clicked
FUNCTION-ALIAS:  rl-gui-toggle bool GuiToggle ( Rectangle bounds, c-string text, bool active )                                                             ! Toggle Button control, returns true when active
FUNCTION-ALIAS:  rl-gui-toggle-group int GuiToggleGroup ( Rectangle bounds, c-string text, int active )                                                    ! Toggle Group control, returns active toggle index
FUNCTION-ALIAS:  rl-gui-check-box bool GuiCheckBox ( Rectangle bounds, c-string text, bool checked )                                                       ! Check Box control, returns true when active
FUNCTION-ALIAS:  rl-gui-combo-box int GuiComboBox ( Rectangle bounds, c-string text, int active )                                                          ! Combo Box control, returns selected item index
FUNCTION-ALIAS:  rl-gui-dropdown-box bool GuiDropdownBox ( Rectangle bounds, c-string text, int* active, bool editMode )                                   ! Dropdown Box control, returns selected item
FUNCTION-ALIAS:  rl-gui-spinner bool GuiSpinner ( Rectangle bounds, int* value, int minValue, int maxValue, bool editMode )                                ! Spinner control, returns selected value
FUNCTION-ALIAS:  rl-gui-value-box bool GuiValueBox ( Rectangle bounds, int* value, int minValue, int maxValue, bool editMode )                             ! Value Box control, updates input text with numbers
FUNCTION-ALIAS:  rl-gui-text-box bool GuiTextBox ( Rectangle bounds, char *text, int textSize, bool editMode )                                             ! Text Box control, updates input text
FUNCTION-ALIAS:  rl-gui-text-box-multi bool GuiTextBoxMulti ( Rectangle bounds, char *text, int textSize, bool editMode )                                  ! Text Box control with multiple lines
FUNCTION-ALIAS:  rl-gui-slider float GuiSlider ( Rectangle bounds, c-string text, float value, float minValue, float maxValue, bool showValue )            ! Slider control, returns selected value
FUNCTION-ALIAS:  rl-gui-slider-bar float GuiSliderBar ( Rectangle bounds, c-string text, float value, float minValue, float maxValue, bool showValue )     ! Slider Bar control, returns selected value
FUNCTION-ALIAS:  rl-gui-progress-bar float GuiProgressBar ( Rectangle bounds, c-string text, float value, float minValue, float maxValue, bool showValue ) ! Progress Bar control, shows current progress value
FUNCTION-ALIAS:  rl-gui-status-bar void GuiStatusBar ( Rectangle bounds, c-string text )                                                                   ! Status Bar control, shows info text
FUNCTION-ALIAS:  rl-gui-dummy-rec void GuiDummyRec ( Rectangle bounds, c-string text )                                                                     ! Dummy control for placeholders
FUNCTION-ALIAS:  rl-gui-scroll-bar int GuiScrollBar ( Rectangle bounds, int value, int minValue, int maxValue )                                            ! Scroll Bar control

! Advance controls set
FUNCTION-ALIAS:  rl-gui-list-view bool GuiListView ( Rectangle bounds, c-string text, int* active, int* scrollIndex, bool editMode )                                            ! List View control, returns selected list element index
FUNCTION-ALIAS:  rl-gui-list-view-ex bool GuiListViewEx ( Rectangle bounds, c-string *text, int count, int* enabled, int* active, int* focus, int* scrollIndex, bool editMode ) ! List View with extended parameters
FUNCTION-ALIAS:  rl-gui-message-box int GuiMessageBox ( Rectangle bounds, c-string windowTitle, c-string message, c-string buttons )                                            ! Message Box control, displays a message
FUNCTION-ALIAS:  rl-gui-color-picker Color GuiColorPicker ( Rectangle bounds, Color color )                                                                                     ! Color Picker control
FUNCTION-ALIAS:  rl-gui-grid Vector2 GuiGrid ( Rectangle bounds, float spacing, int subdivs )                                                                                   ! Grid

! Styles loading functions
FUNCTION-ALIAS:  rl-gui-load-style void GuiLoadStyle ( c-string fileName )                ! Load style file  ( .rgs ) 
FUNCTION-ALIAS:  rl-gui-load-style-props void GuiLoadStyleProps ( int* props, int count ) ! Load style properties from array
FUNCTION-ALIAS:  rl-gui-load-style-default void GuiLoadStyleDefault ( )                   ! Load style default over global style
FUNCTION-ALIAS:  rl-gui-update-style-complete void GuiUpdateStyleComplete ( )             ! Updates full style properties set with default values


FUNCTION-ALIAS:  rl-gui-icon-text c-string GuiIconText ( int iconId, c-string text )      ! Get text with icon id prepended
