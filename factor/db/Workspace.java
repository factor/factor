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
import java.lang.ref.WeakReference;
import java.util.*;

/**
 * A workspace is an orthogonal persistence store.
 *
 * Record format is:
 * - 1 byte: name length
 * - n bytes: class name
 * - remainder: bytes passed to new instance unpickle()
 */
public class Workspace
{
	/**
	 * A map of WeakReferences. All instances of this class are stored
	 * here.
	 */
	private static Map instances = new WeakHashMap();

	private static WorkspaceSaveDaemon flushThread = new WorkspaceSaveDaemon();
	public static boolean LOAD_DEBUG = false;
	public static boolean SAVE_DEBUG = false;

	/**
	 * The ID of the header record. A value never returned by
	 * nextID().
	 */
	public static final long HEADER = -1;

	public static final String DB_VERSION = "1.0";
	public static int flushInterval = 5000;

	/**
	 * In a read-only workspace, changes are silently discarded on
	 * shutdown.
	 */
	private boolean readOnly;

	private Store store;
	private FactorInterpreter interp;
	private HashSet saveQueue;

	/**
	 * Floating objects are currently in-memory.
	 * This map maps IDs to WeakReferences.
	 */
	private Map floating;

	/**
	 * Table containing important values. Always in memory.
	 */
	private Table header;

	/**
	 * For resolving circular references, currently loading objects.
	 */
	private Map loading;

	private boolean closed;

	/**
	 * Track all IDs handed out with nextID(), and make sure they
	 * eventually reach the store.
	 */
	private Set pendingIDs = new TreeSet();

	//{{{ Workspace constructor
	public Workspace(Store store, boolean readOnly,
		FactorInterpreter interp)
		throws Exception
	{
		this.store = store;
		this.readOnly = readOnly;
		this.interp = interp;
		floating = new HashMap();
		saveQueue = new HashSet();
		loading = new HashMap();

		if(store.exists(HEADER))
			header = (Table)get(HEADER);
		else
		{
			header = new Table(this,HEADER);
			initHeader();
		}

		instances.put(this,Boolean.TRUE);
	} //}}}

	//{{{ isFirstTime() method
	public boolean isFirstTime()
	{
		try
		{
			return header.getVariable("first-time") != null;
		}
		catch(Exception e)
		{
			throw new RuntimeException(e);
		}
	} //}}}

	//{{{ setFirstTime() method
	public void setFirstTime(boolean firstTime)
	{
		try
		{
			header.setVariable("first-time",firstTime
				? Boolean.TRUE : null);
		}
		catch(Exception e)
		{
			throw new RuntimeException(e);
		}
	} //}}}

	//{{{ isReadOnly() method
	/**
	 * In a 'read only' workspace, changes are silently discarded when
	 * the workspace is closed.
	 */
	public boolean isReadOnly()
	{
		return readOnly;
	} //}}}

	//{{{ initHeader() method
	public void initHeader() throws Exception
	{
		header.setVariable("nextID",new Long(0));
		header.setVariable("root",new Table(this));
		header.setVariable("version",DB_VERSION);
		header.setVariable("first-time",Boolean.TRUE);
	} //}}}

	//{{{ getRoot() method
	/**
	 * Returns the workspace root.
	 */
	public Table getRoot()
	{
		try
		{
			return (Table)header.getVariable("root");
		}
		catch(Exception e)
		{
			throw new RuntimeException(e);
		}
	} //}}}

	//{{{ getInterpreter() method
	public FactorInterpreter getInterpreter()
	{
		return interp;
	} //}}}

	//{{{ nextID() method
	public synchronized long nextID()// throws PersistenceException
	{
		try
		{
			long nextID =  FactorJava.toLong(
				header.getVariable("nextID"));
			if(nextID == Long.MAX_VALUE)
				throw new RuntimeException("FIXME!");

			nextID++;

			Long nextIDboxed = new Long(nextID);
			header.setVariable("nextID",nextIDboxed);
			pendingIDs.add(nextIDboxed);
			return nextID;
		}
		catch(Exception e)
		{
			throw new RuntimeException(e);
		}
	} //}}}

	//{{{ load() method
	/**
	 * Load an object.
	 */
	private PersistentObject load(long id)
		throws IOException, PersistenceException
	{
		PersistentObject circularRef = (PersistentObject)
			loading.get(new Long(id));

		if(circularRef != null)
			return circularRef;

		if(LOAD_DEBUG)
			System.err.println("Loading from store: " + id);
		byte[] data = store.loadFromStore(id);
		byte len = data[0];
		String className = new String(data,1,len,"ASCII");

		// hack :-)
		try
		{
			PersistentObject obj = (PersistentObject)
				Class.forName(className)
				.getConstructor(new Class[] {
					Workspace.class, long.class
				}).newInstance(new Object[] {
					this, new Long(id)
				});

			loading.put(new Long(id),obj);

			obj.unpickle(data,len + 1);
			return obj;
		}
		catch(PersistenceException p)
		{
			throw p;
		}
		catch(Exception e)
		{
			throw new PersistenceException("Unexpected error",e);
		}
		finally
		{
			loading.remove(new Long(id));
		}
	} //}}}

	//{{{ loadToCache() method
	/**
	 * Load an object with given ID and store it in the floating map.
	 */
	private PersistentObject loadToCache(long id)
		throws IOException, PersistenceException
	{
		PersistentObject obj = load(id);
		WeakReference ref = new WeakReference(obj);
		floating.put(new Long(id),ref);
		return obj;
	} //}}}

	//{{{ get() method
	/**
	 * If an object is already loaded, return that instance, otherwise
	 * load it.
	 */
	public synchronized PersistentObject get(long id)
		throws IOException, PersistenceException
	{
		if(closed)
			throw new PersistenceException();

		WeakReference ref = (WeakReference)floating.get(new Long(id));
		if(ref == null)
			return loadToCache(id);
		else
		{
			PersistentObject obj = (PersistentObject)ref.get();
			if(obj == null)
				return loadToCache(id);
			else
			{
				if(LOAD_DEBUG)
					System.err.println("Found cached: " + id);
				return obj;
			}
		}
	} //}}}

	//{{{ addToCache() method
	private void addToCache(PersistentObject obj)
		throws PersistenceException
	{
		if(obj.getWorkspace() != this)
			throw new PersistenceException("Object from another workspace");

		Long id = new Long(obj.getID());

		WeakReference ref = (WeakReference)floating.get(id);
		if(ref == null)
			floating.put(id,new WeakReference(obj));
		else
		{
			Object referenced = ref.get();
			if(referenced != obj)
				throw new PersistenceException(referenced + " != " + obj);
		}
	} //}}}

	//{{{ save() method
	/**
	 * Store an object.
	 */
	private void save(PersistentObject obj)
		throws IOException, PersistenceException
	{
		save(obj,store);
	} //}}}

	//{{{ save() method
	/**
	 * Store an object.
	 */
	private void save(PersistentObject obj, Store store)
		throws IOException, PersistenceException
	{
		if(SAVE_DEBUG)
			System.err.println("Saving object " + obj.getID());

		if(readOnly)
			throw new RuntimeException();

		pendingIDs.remove(new Long(obj.getID()));

		ByteArrayOutputStream bout = new ByteArrayOutputStream();
		String className = obj.getClass().getName();
		bout.write((byte)className.length());
		bout.write(className.getBytes("ASCII"));
		bout.write(obj.pickle());
		store.saveToStore(obj.getID(),bout.toByteArray());
	} //}}}

	//{{{ put() method
	/**
	 * Add an object to the save queue.
	 */
	public synchronized void put(PersistentObject obj)
		throws PersistenceException
	{
		if(closed)
			throw new PersistenceException();

		addToCache(obj);
		saveQueue.add(obj);
	} //}}}

	//{{{ flush() method
	/**
	 * Write all pending unsaved objects to the store.
	 */
	public synchronized void flush()
		throws IOException, PersistenceException
	{
		if(closed || readOnly)
			return;

		Iterator iter = saveQueue.iterator();
		while(iter.hasNext())
		{
			PersistentObject obj = (PersistentObject)iter.next();
			save(obj);
			iter.remove();
		}
	} //}}}

	//{{{ compact() method
	/**
	 * Write all referencable objects to the given store.
	 */
	private void compact(Store store)
		throws IOException, PersistenceException
	{
		Set open = new HashSet();
		Set closed = new HashSet();

		for(;;)
		{
			if(open.isEmpty())
				break;

			Iterator iter = open.iterator();
			Object obj = iter.next();
			iter.remove();

			closed.add(obj);

			Cons references;
			if(obj instanceof PersistentObject)
			{
				PersistentObject pobj = (PersistentObject)obj;
				save(pobj,store);
				references = pobj.getReferences();
			}
			else
				references = (Cons)obj;

			while(references != null)
			{
				Object ref = references.car;
				if((references.car instanceof PersistentObject
					|| references.car instanceof Cons)
					&& !closed.contains(references.car))
				{
					open.add(references.car);
				}
				if(references.cdr instanceof Cons)
					references = references.next();
				else
				{
					if(references.cdr != null
						&&
						!closed.contains(references.car))
					{
						open.add(references.cdr);
					}
					break;
				}
			}
		}
	} //}}}

	//{{{ close() method
	/**
	 * Close the workspace.
	 */
	public synchronized void close()
		throws IOException, PersistenceException
	{
		flush();

		closed = true;

		if(pendingIDs.size() != 0)
		{
			System.err.println("The following IDs did not get saved:");
			System.err.println(pendingIDs);
		}

		store.close();
	} //}}}

	//{{{ finalize() method
	protected void finalize() throws Throwable
	{
		super.finalize();
		close();
	} //}}}

	//{{{ WorkspaceSaveDaemon class
	static class WorkspaceSaveDaemon extends Thread
	{
		WorkspaceSaveDaemon()
		{
			setDaemon(true);
			start();
		}

		public void run()
		{
			for(;;)
			{
				Iterator workspaces = instances.keySet().iterator();
				while(workspaces.hasNext())
				{
					Workspace workspace = (Workspace)
						workspaces.next();
					try
					{
						workspace.flush();
					}
					catch(Exception e)
					{
						System.err.println("ERROR WHILE SAVING WORKSPACE.");
						System.err.println("Workspace will be closed.");
						synchronized(workspace)
						{
							workspace.closed = true;
						}
						e.printStackTrace();
					}
				}

				try
				{
					Thread.sleep(flushInterval);
				}
				catch(InterruptedException e)
				{
				}
			}
		}
	} //}}}
}
