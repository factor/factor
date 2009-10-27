#include "master.hpp"

namespace factor
{

void free_list::clear_free_list()
{
	memset(this,0,sizeof(free_list));
}

void free_list::initial_free_list(cell start, cell end, cell occupied)
{
	clear_free_list();
	if(occupied != end - start)
	{
		free_heap_block *last_block = (free_heap_block *)(start + occupied);
		last_block->make_free(end - (cell)last_block);
		add_to_free_list(last_block);
	}
}

void free_list::add_to_free_list(free_heap_block *block)
{
	cell size = block->size();

	free_block_count++;
	free_space += size;

	if(size < free_list_count * block_granularity)
	{
		int index = size / block_granularity;
		block->next_free = small_blocks[index];
		small_blocks[index] = block;
	}
	else
	{
		block->next_free = large_blocks;
		large_blocks = block;
	}
}

free_heap_block *free_list::find_free_block(cell size)
{
	cell attempt = size;

	while(attempt < free_list_count * block_granularity)
	{
		int index = attempt / block_granularity;
		free_heap_block *block = small_blocks[index];
		if(block)
		{
			small_blocks[index] = block->next_free;

			free_block_count--;
			free_space -= block->size();

			return block;
		}

		attempt++;
	}

	free_heap_block *prev = NULL;
	free_heap_block *block = large_blocks;

	while(block)
	{
		if(block->size() >= size)
		{
			if(prev)
				prev->next_free = block->next_free;
			else
				large_blocks = block->next_free;

			free_block_count--;
			free_space -= block->size();

			return block;
		}

		prev = block;
		block = block->next_free;
	}

	return NULL;
}

free_heap_block *free_list::split_free_block(free_heap_block *block, cell size)
{
	if(block->size() != size)
	{
		/* split the block in two */
		free_heap_block *split = (free_heap_block *)((cell)block + size);
		split->make_free(block->size() - size);
		split->next_free = block->next_free;
		block->make_free(size);
		add_to_free_list(split);
	}

	return block;
}

bool free_list::can_allot_p(cell size)
{
	cell attempt = size;

	while(attempt < free_list_count * block_granularity)
	{
		int index = attempt / block_granularity;
		if(small_blocks[index]) return true;
		attempt++;
	}

	free_heap_block *block = large_blocks;
	while(block)
	{
		if(block->size() >= size) return true;
		block = block->next_free;
	}

	return false;
}

cell free_list::largest_free_block()
{
	cell largest = 0;
	free_heap_block *scan = large_blocks;

	while(scan)
	{
		largest = std::max(largest,scan->size());
		scan = scan->next_free;
	}

	return largest;
}

}
