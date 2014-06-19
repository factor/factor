#include "master.hpp"

namespace factor {

std::ostream& operator<<(std::ostream& out, const string* str) {
  for (cell i = 0; i < string_capacity(str); i++)
    out << (char)str->data()[i];
  return out;
}

void factor_vm::print_word(word* word, cell nesting) {
  if (tagged<object>(word->vocabulary).type_p(STRING_TYPE))
    std::cout << untag<string>(word->vocabulary) << ":";

  if (tagged<object>(word->name).type_p(STRING_TYPE))
    std::cout << untag<string>(word->name);
  else {
    std::cout << "#<not a string: ";
    print_nested_obj(word->name, nesting);
    std::cout << ">";
  }
}

void factor_vm::print_factor_string(string* str) {
  std::cout << '"' << str << '"';
}

void factor_vm::print_array(array* array, cell nesting) {
  cell length = array_capacity(array);
  cell i;
  bool trimmed;

  if (length > 10 && !full_output) {
    trimmed = true;
    length = 10;
  } else
    trimmed = false;

  for (i = 0; i < length; i++) {
    std::cout << " ";
    print_nested_obj(array_nth(array, i), nesting);
  }

  if (trimmed)
    std::cout << "...";
}

void factor_vm::print_alien(alien* alien, cell nesting) {
  if (to_boolean(alien->expired))
    std::cout << "#<expired alien>";
  else if (to_boolean(alien->base)) {
    std::cout << "#<displaced alien " << alien->displacement << "+";
    print_nested_obj(alien->base, nesting);
    std::cout << ">";
  } else {
    std::cout << "#<alien " << (void*)alien->address << ">";
  }
}

void factor_vm::print_byte_array(byte_array* array, cell nesting) {
  cell length = array->capacity;
  cell i;
  bool trimmed;
  unsigned char* data = array->data<unsigned char>();

  if (length > 16 && !full_output) {
    trimmed = true;
    length = 16;
  } else
    trimmed = false;

  for (i = 0; i < length; i++) {
    std::cout << " " << (unsigned) data[i];
  }

  if (trimmed)
    std::cout << "...";
}

void factor_vm::print_tuple(tuple* tuple, cell nesting) {
  tuple_layout* layout = untag<tuple_layout>(tuple->layout);
  cell length = to_fixnum(layout->size);

  std::cout << " ";
  print_nested_obj(layout->klass, nesting);

  bool trimmed;
  if (length > 10 && !full_output) {
    trimmed = true;
    length = 10;
  } else
    trimmed = false;

  for (cell i = 0; i < length; i++) {
    std::cout << " ";
    print_nested_obj(tuple->data()[i], nesting);
  }

  if (trimmed)
    std::cout << "...";
}

void factor_vm::print_nested_obj(cell obj, fixnum nesting) {
  if (nesting <= 0 && !full_output) {
    std::cout << " ... ";
    return;
  }

  quotation* quot;

  switch (tagged<object>(obj).type()) {
    case FIXNUM_TYPE:
      std::cout << untag_fixnum(obj);
      break;
    case FLOAT_TYPE:
      std::cout << untag_float(obj);
      break;
    case WORD_TYPE:
      print_word(untag<word>(obj), nesting - 1);
      break;
    case STRING_TYPE:
      print_factor_string(untag<string>(obj));
      break;
    case F_TYPE:
      std::cout << "f";
      break;
    case TUPLE_TYPE:
      std::cout << "T{";
      print_tuple(untag<tuple>(obj), nesting - 1);
      std::cout << " }";
      break;
    case WRAPPER_TYPE:
      std::cout << "W{ ";
      print_nested_obj(untag<wrapper>(obj)->object, nesting - 1);
      std::cout << " }";
      break;
    case BYTE_ARRAY_TYPE:
      std::cout << "B{";
      print_byte_array(untag<byte_array>(obj), nesting - 1);
      std::cout << " }";
      break;
    case ARRAY_TYPE:
      std::cout << "{";
      print_array(untag<array>(obj), nesting - 1);
      std::cout << " }";
      break;
    case QUOTATION_TYPE:
      std::cout << "[";
      quot = untag<quotation>(obj);
      print_array(untag<array>(quot->array), nesting - 1);
      std::cout << " ]";
      break;
    case ALIEN_TYPE:
      print_alien(untag<alien>(obj), nesting - 1);
      break;
    default:
      std::cout << "#<" << type_name(tagged<object>(obj).type()) << " @ ";
      std::cout << (void*)obj << ">";
      break;
  }
  std::cout << std::flush;
}

void factor_vm::print_obj(cell obj) { print_nested_obj(obj, 10); }

void factor_vm::print_objects(cell* start, cell* end) {
  for (; start <= end; start++) {
    print_obj(*start);
    std::cout << std::endl;
  }
}

void factor_vm::print_datastack() {
  std::cout << "==== DATA STACK:" << std::endl;
  if (ctx)
    print_objects((cell*)ctx->datastack_seg->start, (cell*)ctx->datastack);
  else
    std::cout << "*** Context not initialized" << std::endl;
}

void factor_vm::print_retainstack() {
  std::cout << "==== RETAIN STACK:" << std::endl;
  if (ctx)
    print_objects((cell*)ctx->retainstack_seg->start, (cell*)ctx->retainstack);
  else
    std::cout << "*** Context not initialized" << std::endl;
}

struct stack_frame_printer {
  factor_vm* parent;

  explicit stack_frame_printer(factor_vm* parent) : parent(parent) {}
  void operator()(void* frame_top, cell frame_size, code_block* owner,
                  void* addr) {
    std::cout << std::endl;
    std::cout << "frame: " << frame_top << " size " << frame_size << std::endl;
    std::cout << "executing: ";
    parent->print_obj(owner->owner);
    std::cout << std::endl;
    std::cout << "scan: ";
    parent->print_obj(owner->scan(parent, addr));
    std::cout << std::endl;
    std::cout << "word/quot addr: ";
    std::cout << std::hex << (cell)owner->owner << std::dec;
    std::cout << std::endl;
    std::cout << "word/quot xt: ";
    std::cout << std::hex << (cell)owner->entry_point() << std::dec;
    std::cout << std::endl;
    std::cout << "return address: ";
    std::cout << std::hex << (cell)addr << std::dec;
    std::cout << std::endl;
  }
};

void factor_vm::print_callstack() {
  std::cout << "==== CALL STACK:" << std::endl;
  if (ctx) {
    stack_frame_printer printer(this);
    iterate_callstack(ctx, printer);
  } else
    std::cout << "*** Context not initialized" << std::endl;
}

void factor_vm::print_callstack_object(callstack* obj) {
  stack_frame_printer printer(this);
  iterate_callstack_object(obj, printer);
}

struct padded_address {
  cell value;

  explicit padded_address(cell value) : value(value) {}
};

std::ostream& operator<<(std::ostream& out, const padded_address& value) {
  char prev = out.fill('0');
  out.width(sizeof(cell) * 2);
  out << std::hex << value.value << std::dec;
  out.fill(prev);
  return out;
}

void factor_vm::dump_cell(cell x) {
  std::cout << padded_address(x) << ": ";
  x = *(cell*)x;
  std::cout << padded_address(x) << " tag " << TAG(x) << std::endl;
}

void factor_vm::dump_memory(cell from, cell to) {
  from = UNTAG(from);

  for (; from <= to; from += sizeof(cell))
    dump_cell(from);
}

template <typename Generation>
void factor_vm::dump_generation(const char* name, Generation* gen) {
  std::cout << name << ": ";
  std::cout << "Start=" << gen->start;
  std::cout << ", size=" << gen->size;
  std::cout << ", end=" << gen->end;
  std::cout << std::endl;
}

void factor_vm::dump_generations() {
  std::cout << std::hex;

  dump_generation("Nursery", &nursery);
  dump_generation("Aging", data->aging);
  dump_generation("Tenured", data->tenured);

  std::cout << "Cards:";
  std::cout << "base=" << (cell)data->cards << ", ";
  std::cout << "size=" << (cell)(data->cards_end - data->cards) << std::endl;

  std::cout << std::dec;
}

struct object_dumper {
  factor_vm* parent;
  cell type;

  object_dumper(factor_vm* parent, cell type)
      : parent(parent), type(type) {}

  void operator()(object* obj) {
    if (type == TYPE_COUNT || obj->type() == type) {
      std::cout << padded_address((cell)obj) << " ";
      parent->print_nested_obj(tag_dynamic(obj), 2);
      std::cout << std::endl;
    }
  }
};

void factor_vm::dump_objects(cell type) {
  primitive_full_gc();
  object_dumper dumper(this, type);
  each_object(dumper);
}

struct find_data_reference_slot_visitor {
  cell look_for;
  object* obj;
  factor_vm* parent;

  find_data_reference_slot_visitor(cell look_for, object* obj,
                                   factor_vm* parent)
      : look_for(look_for), obj(obj), parent(parent) {}

  void operator()(cell* scan) {
    if (look_for == *scan) {
      std::cout << padded_address((cell)obj) << " ";
      parent->print_nested_obj(tag_dynamic(obj), 2);
      std::cout << std::endl;
    }
  }
};

struct dump_edges_slot_visitor {
  object* obj;
  factor_vm* parent;

  dump_edges_slot_visitor(cell, object* obj, factor_vm* parent)
      : obj(obj), parent(parent) {}

  void operator()(cell* scan) {
    if (TAG(*scan) > F_TYPE)
      std::cout << (void*)tag_dynamic(obj) << " ==> " << (void*)*scan
                << std::endl;
  }
};

template <typename SlotVisitor> struct data_reference_object_visitor {
  cell look_for;
  factor_vm* parent;

  data_reference_object_visitor(cell look_for, factor_vm* parent)
      : look_for(look_for), parent(parent) {}

  void operator()(object* obj) {
    SlotVisitor visitor(look_for, obj, parent);
    obj->each_slot(visitor);
  }
};

void factor_vm::find_data_references(cell look_for) {
  data_reference_object_visitor<find_data_reference_slot_visitor> visitor(
      look_for, this);
  each_object(visitor);
}

void factor_vm::dump_edges() {
  data_reference_object_visitor<dump_edges_slot_visitor> visitor(0, this);
  each_object(visitor);
}

struct code_block_printer {
  factor_vm* parent;
  cell reloc_size, parameter_size;

  explicit code_block_printer(factor_vm* parent)
      : parent(parent), reloc_size(0), parameter_size(0) {}

  void operator()(code_block* scan, cell size) {
    const char* status;
    if (scan->free_p())
      status = "free";
    else {
      reloc_size += parent->object_size(scan->relocation);
      parameter_size += parent->object_size(scan->parameters);

      if (parent->code->marked_p(scan))
        status = "marked";
      else
        status = "allocated";

      std::cout << std::hex << (cell)scan << std::dec << " ";
      std::cout << std::hex << size << std::dec << " ";
      std::cout << status << " ";
      std::cout << "stack frame " << scan->stack_frame_size();
      std::cout << std::endl;
    }
  }
};

/* Dump all code blocks for debugging */
void factor_vm::dump_code_heap() {
  code_block_printer printer(this);
  code->allocator->iterate(printer);
  std::cout << printer.reloc_size << " bytes used by relocation tables"
            << std::endl;
  std::cout << printer.parameter_size << " bytes used by parameter tables"
            << std::endl;
}

void factor_vm::factorbug_usage(bool advanced_p) {
  std::cout << "Basic commands:" << std::endl;
#ifdef WINDOWS
  std::cout << "  q ^Z             -- quit Factor" << std::endl;
#else
  std::cout << "  q ^D             -- quit Factor" << std::endl;
#endif
  std::cout << "  c                -- continue executing Factor - NOT SAFE"
            << std::endl;
  std::cout << "  t                -- throw exception in Factor - NOT SAFE"
            << std::endl;
  std::cout << "  .s .r .c         -- print data, retain, call stacks"
            << std::endl;
  if (advanced_p) {
    std::cout << "  help             -- reprint this message" << std::endl;
    std::cout << "Advanced commands:" << std::endl;
    std::cout << "  e                -- dump environment" << std::endl;
    std::cout << "  d <addr> <count> -- dump memory" << std::endl;
    std::cout << "  u <addr>         -- dump object at tagged <addr>"
              << std::endl;
    std::cout << "  . <addr>         -- print object at tagged <addr>"
              << std::endl;
    std::cout << "  g                -- dump generations" << std::endl;
    std::cout << "  ds dr            -- dump data, retain stacks" << std::endl;
    std::cout << "  trim             -- toggle output trimming" << std::endl;
    std::cout << "  data             -- data heap dump" << std::endl;
    std::cout << "  words            -- words dump" << std::endl;
    std::cout << "  tuples           -- tuples dump" << std::endl;
    std::cout << "  edges            -- print all object-to-object references"
              << std::endl;
    std::cout << "  refs <addr>      -- find data heap references to object"
              << std::endl;
    std::cout << "  push <addr>      -- push object on data stack - NOT SAFE"
              << std::endl;
    std::cout << "  gc               -- trigger full GC - NOT SAFE"
              << std::endl;
    std::cout << "  compact-gc       -- trigger compacting GC - NOT SAFE"
              << std::endl;
    std::cout << "  code             -- code heap dump" << std::endl;
    std::cout << "  abort            -- call abort()" << std::endl;
    std::cout << "  breakpoint       -- trigger system breakpoint" << std::endl;
  } else {
    std::cout << "  help             -- full help, including advanced commands"
              << std::endl;
  }

  std::cout << std::endl;

}

static void exit_fep(factor_vm* vm) {
  vm->unlock_console();
  vm->handle_ctrl_c();
  vm->fep_p = false;
}

void factor_vm::factorbug() {
  if (fep_disabled) {
    std::cout << "Low level debugger disabled" << std::endl;
    exit(1);
  }

  if (sampling_profiler_p)
    end_sampling_profiler();

  fep_p = true;

  std::cout << "Starting low level debugger..." << std::endl;

  // Even though we've stopped the VM, the stdin_loop thread (see os-*.cpp)
  // that pumps the console is still running concurrently. We lock a mutex so
  // the thread will take a break and give us exclusive access to stdin.
  lock_console();
  ignore_ctrl_c();

  if (!fep_help_was_shown) {
    factorbug_usage(false);
    fep_help_was_shown = true;
  }
  bool seen_command = false;

  for (;;) {
    std::string cmd;

    std::cout << "> " << std::flush;

    std::cin >> std::setw(1024) >> cmd >> std::setw(0);
    if (!std::cin.good()) {
      if (!seen_command) {
        /* If we exit with an EOF immediately, then
           dump stacks. This is useful for builder and
           other cases where Factor is run with stdin
           redirected to /dev/null */
        fep_disabled = true;

        print_datastack();
        print_retainstack();
        print_callstack();
      }

      exit(1);
    }

    seen_command = true;

    if (cmd == "q")
      exit(1);
    if (cmd == "d") {
      cell addr = read_cell_hex();
      if (std::cin.peek() == ' ')
        std::cin.ignore();

      if (!std::cin.good())
        break;
      cell count = read_cell_hex();
      dump_memory(addr, addr + count);
    } else if (cmd == "u") {
      cell addr = read_cell_hex();
      cell count = object_size(addr);
      dump_memory(addr, addr + count);
    } else if (cmd == ".") {
      cell addr = read_cell_hex();
      print_obj(addr);
      std::cout << std::endl;
    } else if (cmd == "trim")
      full_output = !full_output;
    else if (cmd == "ds")
      dump_memory(ctx->datastack_seg->start, ctx->datastack);
    else if (cmd == "dr")
      dump_memory(ctx->retainstack_seg->start, ctx->retainstack);
    else if (cmd == ".s")
      print_datastack();
    else if (cmd == ".r")
      print_retainstack();
    else if (cmd == ".c")
      print_callstack();
    else if (cmd == "e") {
      for (cell i = 0; i < special_object_count; i++)
        dump_cell((cell)&special_objects[i]);
    } else if (cmd == "g")
      dump_generations();
    else if (cmd == "c") {
      exit_fep(this);
      return;
    } else if (cmd == "t") {
      exit_fep(this);
      general_error(ERROR_INTERRUPT, false_object, false_object);
      FACTOR_ASSERT(false);
    } else if (cmd == "data")
      dump_objects(TYPE_COUNT);
    else if (cmd == "edges")
      dump_edges();
    else if (cmd == "refs") {
      cell addr = read_cell_hex();
      std::cout << "Data heap references:" << std::endl;
      find_data_references(addr);
      std::cout << std::endl;
    } else if (cmd == "words")
      dump_objects(WORD_TYPE);
    else if (cmd == "tuples")
      dump_objects(TUPLE_TYPE);
    else if (cmd == "push") {
      cell addr = read_cell_hex();
      ctx->push(addr);
    } else if (cmd == "code")
      dump_code_heap();
    else if (cmd == "compact-gc")
      primitive_compact_gc();
    else if (cmd == "gc")
      primitive_full_gc();
    else if (cmd == "compact-gc")
      primitive_compact_gc();
    else if (cmd == "help")
      factorbug_usage(true);
    else if (cmd == "abort")
      abort();
    else if (cmd == "breakpoint")
      breakpoint();
    else
      std::cout << "unknown command" << std::endl;
  }
}

void factor_vm::primitive_die() {
  std::cout << "The die word was called by the library. Unless you called it "
               "yourself," << std::endl;
  std::cout << "you have triggered a bug in Factor. Please report."
            << std::endl;
  factorbug();
}

}
