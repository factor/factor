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

import factor.*;
import java.io.*;
import java.util.Map;
import java.util.TreeMap;

/**
 * A table is a persistent namespace.
 *
 * The picked format is as follows:
 *
 * 4 bytes -- number of rows
 * Each row:
 *     4 bytes -- length of name
 *     x bytes -- name
 *     4 bytes -- length of value
 *     x bytes -- unparsed value
 *     1 byte  -- newline
 *
 * All strings are stored as UTF8.
 */
public class Table extends FactorNamespace implements PersistentObject
{
	public static boolean DEBUG = false;
	public static final String ENCODING = "UTF8";

	private Workspace workspace;
	private long id;

	//{{{ Table constructor
	public Table()
	{
	} //}}}

	//{{{ Table constructor
	public Table(Workspace workspace) throws Exception
	{
		this(workspace,workspace == null ? 0L : workspace.nextID());
	} //}}}

	//{{{ Table constructor
	public Table(Workspace workspace, long id) throws Exception
	{
		this.workspace = workspace;
		this.id = id;

		if(workspace != null && id != 0L)
			workspace.put(this);
	} //}}}

	//{{{ Table constructor
	public Table(Object obj) throws Exception
	{
		super(obj);
	} //}}}

	//{{{ Table constructor
	public Table(Object obj, Workspace workspace) throws Exception
	{
		this(obj,workspace,workspace == null ? 0L : workspace.nextID());
	} //}}}

	//{{{ Table constructor
	public Table(Object obj, Workspace workspace, long id) throws Exception
	{
		super(obj);
		this.workspace = workspace;
		this.id = id;

		if(workspace != null && id != 0L)
			workspace.put(this);
	} //}}}

	//{{{ Table constructor
	/**
	 * Cloning constructor.
	 */
	public Table(Map words, Object obj, Workspace workspace)
		throws Exception
	{
		super(words,obj);

		this.workspace = workspace;

		if(workspace != null)
		{
			this.id = workspace.nextID();
			workspace.put(this);
		}
	} //}}}

	//{{{ getWorkspace() method
	/**
	 * Each persistent object is stored in one workspace only.
	 */
	public Workspace getWorkspace()
	{
		return workspace;
	} //}}}

	//{{{ getID() method
	/**
	 * Each persistent object has an associated ID.
	 */
	public long getID()
	{
		return id;
	} //}}}

	//{{{ pickleValue() method
	private synchronized String pickleValue(String name)
		throws Exception
	{
		Object valueObj = words.get(name);

		if(valueObj == null)
		{
			lazyFieldInit(name);
			valueObj = words.get(name);
		}

		String value;

		if(valueObj instanceof Pickled)
		{
			value = ((Pickled)valueObj)
				.getUnparsed();
		}
		else
		{
			value = FactorReader.unparseDBObject(
				getVariable(name));
		}

		return value;
	} //}}}

	//{{{ pickle() method
	/**
	 * Each persistent object can turn itself into a byte array.
	 */
	public synchronized byte[] pickle()
		throws PersistenceException
	{
		try
		{
			ByteArrayOutputStream bytes = new ByteArrayOutputStream();
			DataOutputStream out = new DataOutputStream(bytes);

			Cons values = toVarList();

			if(values == null)
				out.writeInt(0);
			else
				out.writeInt(values.length());

			while(values != null)
			{
				String name = (String)values.car;
				out.writeInt(name.length());
				byte[] nameBytes = name.getBytes(ENCODING);
				out.write(nameBytes);

				String value = pickleValue(name);

				out.writeInt(value.length());
				byte[] valueBytes = value.getBytes(ENCODING);
				out.write(valueBytes);

				out.write('\n');

				values = values.next();
			}

			return bytes.toByteArray();
		}
		catch(Exception e)
		{
			// should not happen with byte array stream
			throw new PersistenceException("Unexpected error",e);
		}
	} //}}}

	//{{{ unpickle() method
	/**
	 * Each persistent object can set its state to that in a byte array.
	 */
	public synchronized void unpickle(byte[] bytes, int offset)
		throws PersistenceException
	{
		try
		{
			ByteArrayInputStream bin = new ByteArrayInputStream(bytes);
			bin.skip(offset);
			DataInputStream in = new DataInputStream(bin);

			int count = in.readInt();

			for(int i = 0; i < count; i++)
			{
				int nameLength = in.readInt();
				byte[] nameBytes = new byte[nameLength];
				in.readFully(nameBytes);

				String name = new String(nameBytes,ENCODING);

				int valueLength = in.readInt();

				byte[] valueBytes = new byte[valueLength];
				in.readFully(valueBytes);

				// skip newline at the end
				in.readByte();

				String value = new String(valueBytes,ENCODING);

				Object obj = words.get(name);
				if(obj == null)
				{
					lazyFieldInit(name);
					obj = words.get(name);
				}

				if(obj instanceof VarBinding)
				{
					try
					{
						setVariable(name,FactorReader.parseObject(
							value,workspace.getInterpreter()));
					}
					catch(Exception e)
					{
						//XXX: what to do here
						System.err.println("Unexpected error when setting " + name + " to " + value);
						e.printStackTrace();
					}
				}
				else
				{
					// super becaue we don't want this to add the
					// table to the save queue
					super.setVariable(name,new Pickled(value));
				}
			}
		}
		catch(Exception e)
		{
			// should not happen with byte array stream
			throw new PersistenceException("Unexpected error",e);
		}
	} //}}}

	//{{{ getVariable() method
	public synchronized Object getVariable(String name) throws Exception
	{
		Object value = super.getVariable(name);
		if(value instanceof Pickled)
		{
			try
			{
				if(DEBUG)
					System.err.println(this + ".getVariable(" + name + "): "
					+ value);

				value = FactorReader.parseObject(((Pickled)value)
					.getUnparsed(),workspace.getInterpreter());
			}
			catch(Exception e)
			{
				throw new FactorRuntimeException("Table " + getID() + " has unreadable values",e);
			}

			// super becaue we don't want this to add the table
			// to the save queue
			super.setVariable(name,value);
		}
		return value;
	} //}}}

	//{{{ setVariable() method
	public synchronized void setVariable(String name, Object value)
		throws Exception
	{
		super.setVariable(name,value);
		if(workspace != null && id != 0L)
			workspace.put(this);
	} //}}}

	//{{{ clone() method
	public FactorNamespace clone(Object rebind)
	{
		if(rebind.getClass() != obj.getClass())
			throw new RuntimeException("Cannot rebind to different type");

		try
		{
			return new Table(words,rebind,workspace);
		}
		catch(Exception e)
		{
			throw new InternalError();
		}
	} //}}}

	//{{{ clone() method
	public Object clone()
	{
		if(obj != null)
			throw new RuntimeException("Cannot clone namespace that's bound to an object");

		try
		{
			return new Table(new TreeMap(words),null,workspace);
		}
		catch(Exception e)
		{
			throw new InternalError();
		}
	} //}}}

	//{{{ Pickled class
	/**
	 * We lazily parse values in tables. An unparsed value is represented
	 * by an instance of this class.
	 */
	static class Pickled
	{
		private String unparsed;

		Pickled(String unparsed)
		{
			this.unparsed = unparsed;
		}

		String getUnparsed()
		{
			return unparsed;
		}

		public String toString()
		{
			return unparsed;
		}
	} //}}}

	//{{{ getReferences() method
	public synchronized Cons getReferences()
	{
		return new Cons(getThis(),toVarList());
	} //}}}
}
