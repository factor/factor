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
 * A store that puts all records as files inside a directory.
 */
public class FileStore implements Store
{
	private File directory;

	//{{{ FileStore() method
	public FileStore(String directory)
	{
		this(new File(directory));
	} //}}}

	//{{{ FileStore() method
	public FileStore(File directory)
	{
		this.directory = directory;
		directory.mkdirs();
	} //}}}

	//{{{ exists() method
	public boolean exists(long id)
	{
		return new File(directory,String.valueOf(id)).exists();
	} //}}}

	//{{{ loadFromStore() method
	/**
	 * Load a record from the database with the given ID.
	 */
	public byte[] loadFromStore(long key)
		throws IOException, PersistenceException
	{
		if(!exists(key))
			throw new NoSuchRecordException(key);
		return readFile(new File(directory,String.valueOf(key)));
	} //}}}

	//{{{ readFile() method
	private byte[] readFile(File file) throws IOException
	{
		DataInputStream in = new DataInputStream(
			new FileInputStream(file));
		byte[] buf = new byte[(int)file.length()];
		try
		{
			in.readFully(buf);
		}
		finally
		{
			in.close();
		}
		return buf;
	} //}}}

	//{{{ saveToStore() method
	/**
	 * Save a record to the database with the given ID.
	 */
	public void saveToStore(long key, byte[] value) throws IOException
	{
		writeFile(new File(directory,String.valueOf(key)),value);
	} //}}}

	//{{{ writeFile() method
	private void writeFile(File file, byte[] content) throws IOException
	{
		FileOutputStream out = new FileOutputStream(file);
		try
		{
			out.write(content,0,content.length);
		}
		finally
		{
			out.close();
		}
	} //}}}

	//{{{ close() method
	/**
	 * Close the store.
	 */
	public void close() throws IOException, PersistenceException
	{
	} //}}}
}
