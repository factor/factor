/* :folding=explicit:collapseFolds=1: */

/*
 * $Id$
 *
 * Copyright (C) 2004 Slava Pestov.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 * FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package factor.db;

import java.io.*;

/**
 * A store that puts all records inside a single file on disk, indexed
 * by a B-tree.
 *
 * B-Tree index header:
 *
 * INDEX_MAGIC
 * 8 bytes - offset of root
 * 1 byte - order
 * 1 byte - dirty - set when loading, cleared when closing
 * 4 bytes - height
 * 8 bytes - maximum key
 *
 * Each record in data file:
 *
 * 8 bytes - key
 * 4 bytes - length
 * ... data follows
 *
 * Records in index file - see BTreeNode
 */
public class BTreeStore implements Store
{
	public static boolean DEBUG = false;
	private static final int INDEX_MAGIC = 0xcabba4e4;
	private static final int DATA_MAGIC = 0xdeadbeef;

	private static final int DEFAULT_ORDER = 64;

	private File indexFile;
	private RandomAccessFile index;
	private File dataFile;
	private RandomAccessFile data;

	// header has INDEX_MAGIC + these 3 values packed
	private long rootPointer;
	private byte order;
	private byte dirty; // non-zero if dirty
	private int height; // height of the tree
	private long maximumKey = -1;

	// root is always in memory
	private BTreeNode root;

	private BTreeNode[] lookup;

	// next offset in the index file
	private long nextOffset;

	//{{{ BTreeStore() method
	/**
	 * Constructor used by FactorInterpreter when parsing -db parameter.
	 */
	public BTreeStore(String spec)
		throws IOException, PersistenceException
	{
		int index = spec.lastIndexOf(':');
		byte order;
		if(index == -1)
			order = DEFAULT_ORDER;
		else
		{
			order = Byte.parseByte(spec.substring(index + 1));
			spec = spec.substring(0,index);
		}

		init(new File(spec),order,spec.startsWith("ro:"));
	} //}}}

	//{{{ BTreeStore() method
	public BTreeStore(File dataFile, byte order, boolean readOnly)
		throws IOException, PersistenceException
	{
		init(dataFile,order,readOnly);
	} //}}}

	//{{{ init() method
	private void init(File dataFile, byte order, boolean readOnly)
		throws IOException, PersistenceException
	{
		if(order <= 3)
			throw new BTreeException("order must be > 3, < 127");

		this.indexFile = new File(dataFile.getParent(),
			dataFile.getName() + ".index");
		this.dataFile = dataFile;

		boolean indexFileExists = indexFile.exists();
		boolean dataFileExists = dataFile.exists();

		index = new RandomAccessFile(indexFile,
			readOnly ? "r" : "rw");
		data = new RandomAccessFile(dataFile,
			readOnly ? "r" : "rw");

		try
		{
			if(!indexFileExists || !dataFileExists)
			{
				this.order = order;
				writeHeader();
				nextOffset = index.length();
				if(dataFileExists)
					createIndex();
			}
			else
			{
				readHeader();
				if(rootPointer != 0)
					root = readNode(rootPointer);
			}
		}
		catch(IOException e)
		{
			index.close();
			data.close();
			throw e;
		}
		catch(PersistenceException e)
		{
			index.close();
			data.close();
			throw e;
		}
	} //}}}

	//{{{ writeHeader() method
	private void writeHeader() throws IOException
	{
		index.seek(0);
		index.writeInt(INDEX_MAGIC);
		index.writeByte(dirty);
		index.writeLong(rootPointer);
		index.writeByte(order);
		index.writeInt(height);
	} //}}}

	//{{{ readHeader() method
	private void readHeader() throws IOException, PersistenceException
	{
		index.seek(0);
		if(index.readInt() != INDEX_MAGIC)
			throw new BTreeException("Bad magic number in index file");
		dirty = index.readByte();
		rootPointer = index.readLong();
		order = index.readByte();
		if(order < 3)
			throw new BTreeException("Bad order");
		height = index.readInt();

		nextOffset = index.length();
	} //}}}

	//{{{ createIndex() method
	private void createIndex() throws IOException, PersistenceException
	{
		System.err.println("Re-creating index...");

		data.seek(0);

		for(;;)
		{
			long offset = data.getFilePointer();

			if(offset == data.length())
			{
				// we're done
				break;
			}

			int magic = data.readInt();
			if(magic != DATA_MAGIC)
				throw new BTreeException(magic + " != " + DATA_MAGIC);

			long key = data.readLong();
			int length = data.readInt();

			saveToIndex(key,offset);

			data.skipBytes(length);
		}

		System.err.println("... done");
	} //}}}

	//{{{ readNode() method
	private BTreeNode readNode(long offset) throws IOException
	{
		BTreeNode node = new BTreeNode(order,offset);
		node.read(index);
		return node;
	} //}}}

	//{{{ writeNode() method
	private void writeNode(BTreeNode node)
		throws IOException, BTreeException
	{
		if(DEBUG)
		{
			System.err.println("node.offset=" + node.offset
				+ ",index.length()=" + index.length());
			if(node.offset < index.length())
			{
				BTreeNode existing = readNode(node.offset);
				if(existing.leaf != node.leaf
					// if children is zero, empty space!
					&& existing.children != 0)
				{
					throw new BTreeException("Overwriting "
						+ existing + " with "
						+ node);
				}
			}
		}

		node.dirty = false;
		node.write(index);
	} //}}}

	//{{{ dump() method
	private void dump(BTreeNode node, int indent)
		throws IOException
	{
		node.dump(indent);
		if(node.leaf)
			return;

		indent++;

		for(int i = 0; i < node.children; i++)
			dump(readNode(node.pointers[i]),indent);
	} //}}}

	//{{{ dump() method
	private void dump()
		throws IOException
	{
		System.err.println("<<<< dump");
		if(root != null)
			dump(root,0);
		System.err.println(">>>>");
	} //}}}

	//{{{ checkOffset() method
	private void checkOffset(long offset)
		throws IOException, BTreeException
	{
		if(offset > nextOffset)
			throw new BTreeException("Invalid pointer: " + offset + " > " + nextOffset);
	} //}}}

	//{{{ lookup() method
	/**
	 * Look up the given key, traversing down the tree. Returns an array
	 * of all nodes, from the root down, that were traversed.
	 *
	 * Note that when adding nodes to the B-tree, I 'cheat' by splitting on
	 * the way down any nodes with order == children. While this ends up
	 * splitting a few more nodes than strictly necessary, it avoids a
	 * second traversal up the tree, and simplifies the code.

	 * @param add in add mode, nodes along the way are split if they would
	 * overflow.
	 * @param newMaximum if add is true *and* this is true, a new maximal
	 * node is being added, so the rightmost key in each node along the way
	 * needs to be updated.
	 */
	private void lookup(long key, boolean add, boolean newMaximum)
		throws IOException, BTreeException
	{
		if(DEBUG)
			System.err.println("HEIGHT = " + height);

		if(lookup == null || lookup.length != height)
		{
			saveLookup();
			lookup = new BTreeNode[height];
		}

		if(height != 0)
		{

			/*
			if this is true, a new level has been added (ie, the
			root was split). we return this value instead of
			incrementing the levels variable directly, since the old
			value of 'levels' is needed until the end of the method.
			*/
			boolean newLevel = false;

			lookup[0] = root;

			if(add)
			{
				if(possiblySplitAndUpdateMax(0,newMaximum,key))
					newLevel = true;
			}

			for(int i = 1; i < height; i++)
			{
				if(DEBUG)
					System.err.println("Level " + i);
				BTreeNode node = lookup[i - 1];
				if(node.leaf)
					throw new BTreeException("A leaf: " + node);
				int next = node.lookupInternal(key);
				if(next == node.children)
					next--;

				// read this node, and split it if we need to.
				long offset = node.pointers[next];
				checkOffset(offset);

				// is the node already loaded?
				if(lookup[i] == null)
					lookup[i] = readNode(offset);
				else if(lookup[i].offset != offset)
				{
					if(lookup[i].dirty)
						writeNode(lookup[i]);
					lookup[i] = readNode(offset);
				}

				if(add)
				{
					if(possiblySplitAndUpdateMax(i,newMaximum,key))
						newLevel = true;
				}
			}

			// now that the above loop (indexed by 'levels') is
			// done, we can increment the variable, and update the
			// index header on disk.
			if(newLevel)
			{
				height++;
				writeHeader();
			}
		}

		BTreeNode last = lookup[lookup.length - 1];

		if(!last.leaf)
			throw new BTreeException("Not a leaf: " + last);

		if(DEBUG)
			System.err.println("NOW height=" + height);
	} //}}}

	//{{{ nextOffset() method
	private long nextOffset()
	{
		long ret = nextOffset;
		nextOffset += BTreeNode.getSize(order);
		return ret;
	} //}}}

	//{{{ possiblySplitAndUpdateMax() method
	/**
	 * The most important method of the B-tree class.
	 * If the number of keys in the node is equal to the order, split the
	 * node, and update the maximum key if necessary.
	 */
	private boolean possiblySplitAndUpdateMax(
		int level,
		boolean newMaximum,
		long key)
		throws IOException, BTreeException
	{
		BTreeNode node = lookup[level];
		long offset = node.offset;

		// see comment in findLeaf() to see why this is needed.
		boolean newLevel = false;

		// will we split?
		boolean split = (node.children == order);

		if(split)
		{
			BTreeNode left = new BTreeNode(order,0);
			BTreeNode right = new BTreeNode(order,0);

			// split the node along the median into left and right
			// side of median. store the left side in a new index
			// record.
			int median = node.split(left,right,key,
				level == height - 1);

			if(DEBUG)
			{
				System.err.println("Splitting " + node);
				System.err.println("==> left = " + left);
				System.err.println("==> right = " + right);
			}

			long medianKey = node.keys[median];
			long highestInLeft = medianKey;

			long leftOffset = nextOffset();
			if(DEBUG)
				System.err.println("leftOffset=" + leftOffset);

			// the key we're adding might be in the left or right
			// side of the split, so act accordingly.
			if(key < medianKey)
			{
				if(DEBUG)
					System.err.println("node=left");
				node = left;
				right.offset = offset;
				writeNode(right);
				offset = leftOffset;
			}
			else
			{
				if(DEBUG)
					System.err.println("node=right");
				left.offset = leftOffset;
				writeNode(left);
				node = right;
			}

			if(level == 0)
			{
				if(DEBUG)
					System.err.println("ROOT SPLIT");
				// we just split the root. create a new root
				BTreeNode newRoot = new BTreeNode(order,
					nextOffset());
				checkOffset(leftOffset);
				newRoot.add(highestInLeft,leftOffset);
				checkOffset(rootPointer);
				newRoot.add(maximumKey,rootPointer);
				writeNode(newRoot);
				rootPointer = newRoot.offset;
				root = newRoot;
				newLevel = true;
			}
			else
			{
				if(DEBUG)
					System.err.println("NODE SPLIT");
				// we just split a non-root node, update its
				// parent.
				BTreeNode parent = lookup[level - 1];
				// note that this will never fail, since if the
				// parent previously had order == numKeys, it
				// will already have been split
				checkOffset(leftOffset);
				parent.add(highestInLeft,leftOffset);
				parent.dirty = true;
			}

			node.dirty = true;
		}

		// is this key we're adding a new maximum?
		if(newMaximum && level != height - 1)
		{
			node.dirty = true;
			node.updateHighest(key);
		}

		// store node back in the 'nodes' array, after any changes have
		// been made.
		lookup[level] = node;
		node.offset = offset;

		return newLevel;
	} //}}}

	//{{{ exists() method
	public boolean exists(long key) throws IOException, BTreeException
	{
		// empty tree?
		if(height == 0)
			return false;

		lookup(key,false,false);
		return lookup[height - 1].lookupExternal(key) != -1;
	} //}}}

	//{{{ loadFromData() method
	/**
	 * Load a record from the data file.
	 */
	private byte[] loadFromData(long offset, long key)
		throws IOException, BTreeException
	{
		data.seek(offset);

		int magic = data.readInt();
		if(magic != DATA_MAGIC)
			throw new BTreeException(magic + " != " + DATA_MAGIC);

		if(data.readLong() != key)
			throw new BTreeException("Record " + key + " not stored at " + offset);
		int length = data.readInt();
		byte[] value = new byte[length];
		data.readFully(value);
		return value;
	} //}}}

	//{{{ loadFromStore() method
	/**
	 * Load a record from the database with the given ID.
	 */
	public byte[] loadFromStore(long key)
		throws IOException, PersistenceException
	{
		lookup(key,false,false);
		BTreeNode last = lookup[height - 1];
		int index = last.lookupExternal(key);
		if(index == -1)
			throw new NoSuchRecordException(key);
		long offset = last.pointers[index];
		return loadFromData(offset,key);
	} //}}}

	//{{{ saveToData() method
	/**
	 * Append a record to the data file.
	 */
	private long saveToData(long key, byte[] value) throws IOException
	{
		long offset = data.length();
		data.seek(offset);
		data.writeInt(DATA_MAGIC);
		data.writeLong(key);
		data.writeInt(value.length);
		data.write(value);
		return offset;
	} //}}}

	//{{{ saveToIndex() method
	private void saveToIndex(long key, long offset)
		throws IOException, PersistenceException
	{
		if(DEBUG)
			dump();

		// Do we need to update the maximum keys as we go along?
		boolean newMaximum = (key > maximumKey);
		if(newMaximum)
			maximumKey = key;

		BTreeNode leaf;

		if(rootPointer == 0)
		{
			rootPointer = nextOffset();
			root = new BTreeNode(order,rootPointer);
			root.leaf = true;
			leaf = root;
			height = 1;
		}
		else
		{
			int last = height - 1;
			lookup(key,true,newMaximum);
			leaf = lookup[last];
		}

		// add the node to the leaf, write the leaf back to disk.
		int existing = leaf.lookupExternal(key);
		if(existing == -1)
		{
			// new record
			leaf.add(key,offset);
		}
		else
		{
			// updating existing record
			leaf.pointers[existing] = offset;
		}

		leaf.dirty = true;
		writeNode(leaf);
	} //}}}

	//{{{ saveToStore() method
	/**
	 * Save a record to the database with the given ID.
	 */
	public void saveToStore(long key, byte[] value)
		throws IOException, PersistenceException
	{
		long offset = saveToData(key,value);

		saveToIndex(key,offset);
	} //}}}

	//{{{ saveLookup() method
	/**
	 * Save all nodes in the lookup array.
	 */
	private void saveLookup() throws IOException, BTreeException
	{
		if(lookup == null)
			return;

		for(int i = 0; i < lookup.length; i++)
		{
			if(lookup[i].dirty)
				writeNode(lookup[i]);
		}
	} //}}}

	//{{{ close() method
	/**
	 * Close the store.
	 */
	public void close() throws IOException, BTreeException
	{
		saveLookup();
		index.close();
		data.close();
	} //}}}
}
