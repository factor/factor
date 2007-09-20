USING: kernel strings assocs sequences math ;

IN: x.keysym-table

: keysym-table ( -- table )
H{ { HEX: FF08 "BACKSPACE"     }
   { HEX: FF09 "TAB"           }
   { HEX: FF0D "RETURN"        }
   { HEX: FF8D "ENTER"         }
   { HEX: FF1B "ESCAPE"        }
   { HEX: FFFF "DELETE"        }
   { HEX: FF50 "HOME"          }
   { HEX: FF51 "LEFT"          }
   { HEX: FF52 "UP"            }
   { HEX: FF53 "RIGHT"         }
   { HEX: FF54 "DOWN"          }
   { HEX: FF55 "PAGE-UP"       }
   { HEX: FF56 "PAGE-DOWN"     }
   { HEX: FF57 "END"           }
   { HEX: FF58 "BEGIN"         }
   { HEX: FFBE "F1"            }
   { HEX: FFBF "F2"            }
   { HEX: FFC0 "F3"            }
   { HEX: FFC1 "F4"            }
   { HEX: FFC2 "F5"            }
   { HEX: FFC3 "F6"            }
   { HEX: FFC4 "F7"            }
   { HEX: FFC5 "F8"            }
   { HEX: FFC6 "F9"            }
   { HEX: FFC7 "F10"           }
   { HEX: FFC8 "F11"           }
   { HEX: FFC9 "F12"           }
   { HEX: FFE1 "LEFT-SHIFT"    }
   { HEX: FFE2 "RIGHT-SHIFT"   }
   { HEX: FFE3 "LEFT-CONTROL"  }
   { HEX: FFE4 "RIGHT-CONTROL" }
   { HEX: FFE5 "CAPSLOCK"      }
   { HEX: FFE9 "LEFT-ALT"      }
   { HEX: FFEA "RIGHT-ALT"     }
} ;

: keysym>name ( keysym -- name )
dup keysym-table at dup [ nip ] [ drop 1string ] if ;

: name>keysym ( name -- keysym ) keysym-table value-at ;
