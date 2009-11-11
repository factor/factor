#include "master.hpp"

namespace factor
{

void free_list::clear_free_list()
{
	for(cell i = 0; i < free_list_count; i++)
		small_blocks[i].clear();
	large_blocks.clear();
	free_block_count = 0;
	free_space = 0;
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
		small_blocks[size / block_granularity].push_back(block);
	else
		large_blocks.insert(block);
}

free_heap_block *free_list::find_free_block(cell size)
{
	/* Check small free lists */
	if(size / block_granularity < free_list_count)
	{
		std::vector<free_heap_block *> &blocks = small_blocks[size / block_granularity];
		if(blocks.size() == 0)
		{
			/* Round up to a multiple of 'size' */
			cell large_block_size = ((allocation_page_size + size - 1) / size) * size;

			/* Allocate a block this big */
			free_heap_block *large_block = find_free_block(large_block_size);
			if(!large_block) return NULL;

			large_block = split_free_block(large_block,large_block_size);

			/* Split it up into pieces and add each piece back to the free list */
			for(cell offset = 0; offset < large_block_size; offset += size)
			{
				free_heap_block *small_block = large_block;
				large_block = (free_heap_block *)((cell)large_block + size);
				small_block->make_free(size);
				add_to_free_list(small_block);
			}
		}

		free_heap_block *block = blocks.back();
		blocks.pop_back();

		free_block_count--;
		free_space -= block->size();

		return block;
	}
	else
	{
		/* Check large free list */
		free_heap_block key;
		key.make_free(size);
		large_block_set::iterator iter = large_blocks.lower_bound(&key);
		large_block_set::iterator end = large_blocks.end();

		if(iter != end)
		{
			free_heap_block *block = *iter;
			large_blocks.erase(iter);

			free_block_count--;
			free_space -= block->size();

			return block;
		}

		return NULL;
	}
}

free_heap_block *free_list::split_free_block(free_heap_block *block, cell size)
{
	if(block->size() != size)
	{
		/* split the block in two */
		free_heap_block *split = (free_heap_block *)((cell)block + size);
		split->make_free(block->size() - size);
		block->make_free(size);
		add_to_free_list(split);
	}

	return block;
}

bool free_list::can_allot_p(cell size)
{
	return largest_free_block() >= std::max(size,allocation_page_size);
}

cell free_list::largest_free_block()
{
	if(large_blocks.size())
	{
		large_block_set::reverse_iterator last = large_blocks.rbegin();
		return (*last)->size();
	}
	else
	{
		for(int i = free_list_count - 1; i >= 0; i--)
		{
			if(small_blocks[i].size())
				return small_blocks[i].back()->size();
		}

		return 0;
	}
}

}
