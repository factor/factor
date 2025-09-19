#include <memory>
#include <array>

namespace factor {

struct must_start_gc_again {
};

enum gc_op {
  COLLECT_NURSERY_OP,
  COLLECT_AGING_OP,
  COLLECT_TO_TENURED_OP,
  COLLECT_FULL_OP,
  COLLECT_COMPACT_OP,
  COLLECT_GROWING_DATA_HEAP_OP
};

// These are the phases of the gc cycles we record the times of.
enum gc_phase {
  PHASE_CARD_SCAN,
  PHASE_CODE_SCAN,
  PHASE_DATA_SWEEP,
  PHASE_CODE_SWEEP,
  PHASE_DATA_COMPACTION,
  PHASE_MARKING
};

struct gc_event {
  gc_op op;
  data_heap_room data_heap_before;
  allocator_room code_heap_before;
  data_heap_room data_heap_after;
  allocator_room code_heap_after;
  cell cards_scanned;
  cell decks_scanned;
  cell code_blocks_scanned;
  uint64_t start_time;
  cell total_time;
  std::array<cell, 6> times;
  uint64_t temp_time;

  gc_event(gc_op op, factor_vm* parent);
  void reset_timer();
  void ended_phase(gc_phase phase);
  void ended_gc(factor_vm* parent);
};

struct gc_state {
  gc_op op;
  uint64_t start_time;
  std::unique_ptr<gc_event> event;

  gc_state(gc_op op, factor_vm* parent);
  void start_again(gc_op op_, factor_vm* parent);
};

}
