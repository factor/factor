namespace factor {

VM_C_API void init_globals();
factor_vm* new_factor_vm();
VM_C_API void start_standalone_factor(int argc, vm_char** argv);

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
