namespace factor {

// Cannot allocate
inline static bool to_boolean(cell value) { return value != false_object; }

}
