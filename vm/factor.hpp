namespace factor {

factor_vm* new_factor_vm();
VM_C_API void start_standalone_factor(int argc, vm_char** argv);

// image
bool factor_arg(const vm_char* str, const vm_char* arg, cell* value);

// objects
cell object_size(cell tagged);

// os-*
void open_console();
void close_console();
void lock_console();
void unlock_console();
bool move_file(const vm_char* path1, const vm_char* path2);

void ignore_ctrl_c();
void handle_ctrl_c();

bool set_memory_locked(cell base, cell size, bool locked);

}
