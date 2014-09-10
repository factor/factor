namespace factor {

enum gc_op {
  collect_nursery_op,
  collect_aging_op,
  collect_to_tenured_op,
  collect_full_op,
  collect_compact_op,
  collect_growing_heap_op
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
  cell card_scan_time;
  cell code_scan_time;
  cell data_sweep_time;
  cell code_sweep_time;
  cell compaction_time;
  uint64_t temp_time;

  gc_event(gc_op op, factor_vm* parent);
  void started_card_scan();
  void ended_card_scan(cell cards_scanned_, cell decks_scanned_);
  void started_code_scan();
  void ended_code_scan(cell code_blocks_scanned_);
  void started_data_sweep();
  void ended_data_sweep();
  void started_code_sweep();
  void ended_code_sweep();
  void started_compaction();
  void ended_compaction();
  void ended_gc(factor_vm* parent);
};

struct gc_state {
  gc_op op;
  uint64_t start_time;
  gc_event* event;

  gc_state(gc_op op, factor_vm* parent);
  ~gc_state();
  void start_again(gc_op op_, factor_vm* parent);
};

}
