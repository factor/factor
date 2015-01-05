namespace factor {

typedef void (*c_to_factor_func_type)(cell quot);
typedef void (*unwind_native_frames_func_type)(cell quot, cell to);
typedef cell (*get_fpu_state_func_type)();
typedef void (*set_fpu_state_func_type)(cell state);

}
