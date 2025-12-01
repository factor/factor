#include "master.hpp"

namespace factor {

bool factor_arg(const vm_char* str, const vm_char* arg, cell* value) {
  int val;
  if (SSCANF(str, arg, &val) > 0) {
    *value = val;
    return true;
  }
  return false;
}

vm_parameters::vm_parameters() {
  embedded_image = false;
  image_path = NULL;
  executable_path = NULL;

  datastack_size = 32 * sizeof(cell);
  retainstack_size = 32 * sizeof(cell);

#if defined(FACTOR_PPC)
  callstack_size = 256 * sizeof(cell);
#else
  callstack_size = 128 * sizeof(cell);
#endif

  code_size = 96;
  young_size = sizeof(cell) / 4;
  aging_size = sizeof(cell) / 2;
  tenured_size = 24 * sizeof(cell);

  max_pic_size = 3;

  fep = false;
  signals = true;

#ifdef WINDOWS
  console = GetConsoleWindow() != NULL;
#else
  console = true;
#endif

  callback_size = 256;
}

vm_parameters::~vm_parameters() {
  free((vm_char *)image_path);
  free((vm_char *)executable_path);
}

void vm_parameters::init_from_args(int argc, vm_char** argv) {
  int i = 0;

  for (i = 1; i < argc; i++) {
    vm_char* arg = argv[i];
    if (STRCMP(arg, STRING_LITERAL("--")) == 0)
      break;
    else if (factor_arg(arg, STRING_LITERAL("-datastack=%d"),
                        &datastack_size))
      ;
    else if (factor_arg(arg, STRING_LITERAL("-retainstack=%d"),
                        &retainstack_size))
      ;
    else if (factor_arg(arg, STRING_LITERAL("-callstack=%d"),
                        &callstack_size))
      ;
    else if (factor_arg(arg, STRING_LITERAL("-young=%d"),
                        &young_size))
      ;
    else if (factor_arg(arg, STRING_LITERAL("-aging=%d"),
                        &aging_size))
      ;
    else if (factor_arg(arg, STRING_LITERAL("-tenured=%d"),
                        &tenured_size))
      ;
    else if (factor_arg(arg, STRING_LITERAL("-codeheap=%d"),
                        &code_size))
      ;
    else if (factor_arg(arg, STRING_LITERAL("-pic=%d"),
                        &max_pic_size))
      ;
    else if (factor_arg(arg, STRING_LITERAL("-callbacks=%d"),
                        &callback_size))
      ;
    else if (STRNCMP(arg, STRING_LITERAL("-i="), 3) == 0) {
      // In case you specify -i more than once.
      if (image_path) {
        free((vm_char *)image_path);
      }
      image_path = safe_strdup(arg + 3);
    }
    else if (STRCMP(arg, STRING_LITERAL("-fep")) == 0)
      fep = true;
    else if (STRCMP(arg, STRING_LITERAL("-no-signals")) == 0)
      signals = false;
  }
}

void factor_vm::load_data_heap(FILE* file, image_header* h, vm_parameters* p) {
  p->tenured_size = std::max((h->data_size * 3) / 2, p->tenured_size);

  data_heap *d = new data_heap(&nursery,
                               p->young_size, p->aging_size, p->tenured_size);
  set_data_heap(d);

  auto uncompress = h->data_size != h->compressed_data_size;
  auto uncompressed_data_size = uncompress ? align_page(h->data_size) : 0;
  auto temp = uncompress && uncompressed_data_size+h->compressed_data_size > data->tenured->size;
  auto buf = temp ? malloc(h->compressed_data_size) : (char*)data->tenured->start+uncompressed_data_size;
  if (!buf) fatal_error("Out of memory in load_data_heap", 0);

  fixnum bytes_read =
      raw_fread(buf, 1, h->compressed_data_size, file);

  if ((cell)bytes_read != h->compressed_data_size) {
    std::cout << "truncated image: " << bytes_read << " bytes read, ";
    std::cout << h->compressed_data_size << " bytes expected\n";
    fatal_error("load_data_heap failed", 0);
  }

  if (uncompress) {
    lib::zstd::zstd_lib zstd;
    zstd.open();
    size_t result = zstd.decompress((void*)data->tenured->start, h->data_size, buf, h->compressed_data_size);
    if (zstd.is_error(result)) {
      std::cout << "data heap decompression: " << zstd.get_error_name(result) << '\n';
      fatal_error("load_data_heap failed", 0);
    }
    zstd.close();
  }

  if (temp) free(buf);

  data->tenured->initial_free_list(h->data_size);
}

void factor_vm::load_code_heap(FILE* file, image_header* h, vm_parameters* p) {
  if (h->code_size > p->code_size)
    fatal_error("Code heap too small to fit image", h->code_size);

  code = new code_heap(p->code_size);

  if (h->code_size != 0) {
    auto uncompress = h->code_size != h->compressed_code_size;
    auto uncompressed_code_size = uncompress ? align_page(h->code_size) : 0;
    auto temp = uncompress && uncompressed_code_size+h->compressed_code_size > code->allocator->size;
    auto buf = temp ? malloc(h->compressed_code_size) : (char*)code->allocator->start+uncompressed_code_size;
    if (!buf) fatal_error("Out of memory in load_code_heap", 0);

    size_t bytes_read =
        raw_fread(buf, 1, h->compressed_code_size, file);
    if (bytes_read != h->compressed_code_size) {
      std::cout << "truncated image: " << bytes_read << " bytes read, ";
      std::cout << h->compressed_code_size << " bytes expected\n";
      fatal_error("load_code_heap failed", 0);
    }

    if (uncompress) {
      lib::zstd::zstd_lib zstd;
      zstd.open();
      size_t result = zstd.decompress((void*)code->allocator->start, h->code_size, buf, h->compressed_code_size);
      if (zstd.is_error(result)) {
        std::cout << "code heap decompression: " << zstd.get_error_name(result) << '\n';
        fatal_error("load_code_heap failed", 0);
      }
      zstd.close();
    }

    if (temp) free(buf);
  }

  code->allocator->initial_free_list(h->code_size);
  code->initialize_all_blocks_set();
}

struct startup_fixup {
  static const bool translated_code_block_map = true;

  cell data_offset;
  cell code_offset;

  startup_fixup(cell data_offset, cell code_offset)
      : data_offset(data_offset), code_offset(code_offset) {}

  object* fixup_data(object* obj) {
    return (object*)((cell)obj + data_offset);
  }

  code_block* fixup_code(code_block* obj) {
    return (code_block*)((cell)obj + code_offset);
  }

  object* translate_data(const object* obj) {
    return fixup_data((object*)obj);
  }

  code_block* translate_code(const code_block* compiled) {
    return fixup_code((code_block*)compiled);
  }

  cell size(const object* obj) {
    return obj->size(*this);
  }

  cell size(code_block* compiled) {
    return compiled->size(*this);
  }
};

void factor_vm::fixup_heaps(cell data_offset, cell code_offset) {
  startup_fixup fixup(data_offset, code_offset);
  slot_visitor<startup_fixup> visitor(this, fixup);
  visitor.visit_all_roots();

  auto start_object_updater = [&](object *obj, cell size) {
    (void)size;
    data->tenured->starts.record_object_start_offset(obj);
    visitor.visit_slots(obj);
    switch (obj->type()) {
      case ALIEN_TYPE: {
        alien* ptr = (alien*)obj;
        if (to_boolean(ptr->base))
          ptr->update_address();
        else
          ptr->expired = special_objects[OBJ_CANONICAL_TRUE];
        break;
      }
      case DLL_TYPE: {
        ffi_dlopen((dll*)obj);
        break;
      }
      default: {
        visitor.visit_object_code_block(obj);
        break;
      }
    }
  };
  data->tenured->iterate(start_object_updater, fixup);

  auto updater = [&](code_block* compiled, cell size) {
    (void)size;
    visitor.visit_code_block_objects(compiled);
    cell rel_base = compiled->entry_point() - fixup.code_offset;
    visitor.visit_instruction_operands(compiled, rel_base);
  };
  code->allocator->iterate(updater, fixup);
}

bool factor_vm::read_embedded_image_footer(FILE* file,
                                           embedded_image_footer* footer) {
  safe_fseek(file, -(off_t)sizeof(embedded_image_footer), SEEK_END);
  safe_fread(footer, (off_t)sizeof(embedded_image_footer), 1, file);
  return footer->magic == image_magic;
}

char *threadsafe_strerror(int errnum) {
  char *buf = (char *) malloc(STRERROR_BUFFER_SIZE);
  if (!buf) {
    fatal_error("Out of memory in threadsafe_strerror, errno", errnum);
  }
  THREADSAFE_STRERROR(errnum, buf, STRERROR_BUFFER_SIZE);
  return buf;
}

// Read an image file from disk, only done once during startup
// This function also initializes the data and code heaps
void factor_vm::load_image(vm_parameters* p) {

  FILE* file = OPEN_READ(p->image_path);
  if (file == NULL) {
    std::cout << "Cannot open image file: " << AS_UTF8(p->image_path) << std::endl;
    char *msg = threadsafe_strerror(errno);
    std::cout << "strerror: " << msg << std::endl;
    free(msg);
    exit(1);
  }
  if (p->embedded_image) {
    embedded_image_footer footer;
    if (!read_embedded_image_footer(file, &footer)) {
      std::cout << "No embedded image" << std::endl;
      exit(1);
    }
    safe_fseek(file, (off_t)footer.image_offset, SEEK_SET);
  }

  image_header h;
  if (raw_fread(&h, sizeof(image_header), 1, file) != 1)
    fatal_error("Cannot read image header", 0);

  if (h.magic != image_magic)
    fatal_error("Bad image: magic number check failed", h.magic);

  if (h.version != image_version)
    fatal_error("Bad image: version number check failed", h.version);

  if (!h.version4_escape) {
    h.data_size = h.escaped_data_size;
  } else {
    h.compressed_data_size = h.data_size;
    h.compressed_code_size = h.code_size;
  }

  load_data_heap(file, &h, p);
  load_code_heap(file, &h, p);

  raw_fclose(file);

  // Certain special objects in the image are known to the runtime
  memcpy(special_objects, h.special_objects, sizeof(special_objects));

  cell data_offset = data->tenured->start - h.data_relocation_base;
  cell code_offset = code->allocator->start - h.code_relocation_base;
  fixup_heaps(data_offset, code_offset);
}

// Save the current image to disk. We don't throw any exceptions here
// because if the 'then-die' argument is t it is not safe to do
// so. Instead we signal failure by returning false.
bool factor_vm::save_image(const vm_char* saving_filename,
                           const vm_char* filename) {
  image_header h = {};

  h.magic = image_magic;
  h.version = image_version;
  h.data_relocation_base = data->tenured->start;
  h.compressed_data_size = h.escaped_data_size = data->tenured->occupied_space();
  h.code_relocation_base = code->allocator->start;
  h.compressed_code_size = h.code_size = code->allocator->occupied_space();

  for (cell i = 0; i < special_object_count; i++)
    h.special_objects[i] =
        (save_special_p(i) ? special_objects[i] : false_object);

  FILE* file = OPEN_WRITE(saving_filename);
  if (file == NULL)
    return false;
  if (safe_fwrite(&h, sizeof(image_header), 1, file) != 1)
    return false;
  if (h.escaped_data_size > 0 &&
      safe_fwrite((void*)data->tenured->start, h.escaped_data_size, 1, file) != 1)
    return false;
  if (h.code_size > 0 &&
      safe_fwrite((void*)code->allocator->start, h.code_size, 1, file) != 1)
    return false;
  if (raw_fclose(file) == -1)
    return false;
  if (!move_file(saving_filename, filename))
    return false;
  return true;
}

// Allocates memory
void factor_vm::primitive_save_image() {
  // We unbox this before doing anything else. This is the only point
  // where we might throw an error, so we have to throw an error here since
  // later steps destroy the current image.
  bool then_die = to_boolean(ctx->pop());
  byte_array* path2 = untag_check<byte_array>(ctx->pop());
  byte_array* path1 = untag_check<byte_array>(ctx->pop());

  // Copy the paths to non-gc memory to avoid them hanging around in
  // the saved image.
  vm_char* path1_saved = safe_strdup(path1->data<vm_char>());
  vm_char* path2_saved = safe_strdup(path2->data<vm_char>());

  if (then_die) {
    // strip out special_objects data which is set on startup anyway
    for (cell i = 0; i < special_object_count; i++)
      if (!save_special_p(i))
        special_objects[i] = false_object;

    // dont trace objects only reachable from context stacks so we don't
    // get volatile data saved in the image.
    active_contexts.clear();
    code->uninitialized_blocks.clear();

    // I think clearing the callback heap should be fine too.
    callbacks->allocator->initial_free_list(0);
  }

  // do a full GC to push everything remaining into tenured space
  primitive_compact_gc();

  // Save the image
  bool ret = save_image(path1_saved, path2_saved);
  if (then_die) {
    exit(ret ? 0 : 1);
  }
  free(path1_saved);
  free(path2_saved);

  if (!ret) {
    general_error(ERROR_IO, tag_fixnum(errno), false_object);
  }
}

bool factor_vm::embedded_image_p() {
  const vm_char* vm_path = vm_executable_path();
  FILE* file = OPEN_READ(vm_path);
  if (!file) {
    free((vm_char *)vm_path);
    return false;
  }
  embedded_image_footer footer;
  bool embedded_p = read_embedded_image_footer(file, &footer);
  fclose(file);
  free((vm_char *)vm_path);
  return embedded_p;
}

}
