USING: alien byte-arrays gdk2.ffi gtk2.ffi help.markup help.syntax
kernel strings ui.backend.x11.keys ;
IN: ui.backend.gtk2

HELP: configure-im
{ $values { "win" GtkWindow } { "im" GtkIMContext } }
{ $description "Configures the input methods of the window. Must only be run after the window has been realized." }
{ $see-also gtk_widget_realize } ;

HELP: icon-data
{ $var-description "Contains a " { $link byte-array } " or " { $link f } " which is the data for the icon to be used for gtk windows. The variable is updated to contain a vocab-specific icon when deploying. See " { $link "vocabs.icons" } " and 'tools.deploy.shaker.strip-gtk-icon'." } ;

HELP: key-sym
{ $values
  { "keyval" GdkEventKey }
  { "string/f" { $maybe string } }
  { "action?" boolean }
} { $description "Gets the key symbol and action indicator from a " { $link GdkEventKey } " struct. If 'action?' is " { $link t } ", then the key is one of the special keys in " { $link codes } "." } ;

HELP: on-configure
{ $values
  { "window" alien }
  { "event" alien }
  { "user-data" alien }
  { "?" boolean }
}
{ $description "Handles a configure event (" { $link GdkEventConfigure } ") sent from the windowing system. If the world has been sent the on-map event from gtk then it is updated, otherwise nothing happens. Resizing the window causes the world to be relayouted, but moving the window does not." } ;

ARTICLE: "ui.backend.gtk2" "Gtk-based UI backend"
"GDK Event handlers:"
{ $list
  { "Focus events:"
    { $subsections
      on-focus-in
      on-focus-out
      on-leave
    }
  }
  { "IM events:"
    { $subsections
      im-on-destroy
      im-on-focus-in
      im-on-focus-out
      im-on-key-event
      on-commit
      on-delete-surrounding
      on-retrieve-surrounding
    }
  }
  { "Keyboard events:"
    { $subsections
      on-key-press/release
    }
  }
  { "Mouse events:"
    { $subsections
      on-button-press
      on-button-release
      on-motion
      on-scroll
    }
  }
  { "Window sizing and visibility events:"
    { $subsections
      on-configure
      on-delete
      on-expose
      on-map
    }
  }
} ;

ABOUT: "ui.backend.gtk2"
