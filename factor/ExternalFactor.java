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

package factor;

import java.io.*;
import java.net.Socket;
import java.util.*;
import org.gjt.sp.util.Log;

/**
 * Encapsulates a connection to an external Factor instance.
 */
public class ExternalFactor extends DefaultVocabularyLookup
{
	//{{{ ExternalFactor constructor
	public ExternalFactor(int port)
	{
		/* Start stream server */;
		streamServer = port;

		for(int i = 1; i < 6; i++)
		{
			Log.log(Log.DEBUG,this,"Factor connection, try #" + i);
			try
			{
				Thread.sleep(1000);
				openWire();
				Log.log(Log.DEBUG,this,"Connection established");
				return;
			}
			catch(Exception e)
			{
				Log.log(Log.ERROR,this,e);
			}
			
		}

		Log.log(Log.ERROR,this,"Cannot connect to Factor on port " + port);
		if(in != null && out != null)
			close();
	} //}}}

	//{{{ openWireSocket() method
	/**
	 * Return a listener stream.
	 */
	public Socket openWireSocket() throws IOException
	{
		if(closed)
			throw new IOException("Socket closed");
		return new Socket("localhost",streamServer);
	} //}}}

	//{{{ openWire() method
	private void openWire() throws Exception
	{
		Socket client = openWireSocket();
		in = new DataInputStream(new BufferedInputStream(
			client.getInputStream()));
		out = new DataOutputStream(new BufferedOutputStream(
			client.getOutputStream()));
		out.write("USE: jedit wire-server\n".getBytes("ASCII"));
		out.flush();
		waitForAck();
	}

	//{{{ waitForAck() method
	private void waitForAck() throws IOException
	{
		sendEval("\"ACK\" write flush\n");

		/* Read everything until wire header */
		String discardStr = "";

		while(!discardStr.endsWith("ACK"))
		{
			byte[] discard = new byte[2048];
			int len = in.read(discard,0,discard.length);
			discardStr = new String(discard,0,len);
		}
	} //}}}
	
	//{{{ sendEval() method
	private void sendEval(String cmd) throws IOException
	{
		byte[] bytes = cmd.getBytes("ASCII");
		out.writeInt(bytes.length);
		out.write(bytes,0,bytes.length);
		out.flush();
	} //}}}

	//{{{ eval() method
	/**
	 * Send a command to the inferior Factor, and return the string output.
	 */
	public synchronized String eval(String cmd) throws IOException
	{
		try
		{
			waitForAck();
	
			sendEval(cmd);
	
			int responseLength = in.readInt();
			byte[] response = new byte[responseLength];
			in.readFully(response);
			
			String responseStr = new String(response,"ASCII");
			return responseStr;
		}
		catch(IOException e)
		{
			close();
			throw e;
		}
	} //}}}

	//{{{ openStream() method
	/**
	 * Return a listener stream.
	 */
	public FactorStream openStream()
	{
		try
		{
			return new FactorStream(openWireSocket());
		}
		catch(Exception e)
		{
			Log.log(Log.ERROR,this,"Cannot open stream connection to "
				+ "external Factor:");
			Log.log(Log.ERROR,this,e);
			return null;
		}
	} //}}}

	//{{{ getVocabularies() method
	public synchronized Cons getVocabularies()
	{
		Cons vocabs = super.getVocabularies();

		try
		{
			if(!closed)
			{
				Cons moreVocabs = (Cons)parseObject(eval("vocabs.")).car;
				while(moreVocabs != null)
				{
					String vocab = (String)moreVocabs.car;
					if(!Cons.contains(vocabs,vocab))
						vocabs = new Cons(vocab,vocabs);
					moreVocabs = moreVocabs.next();
				}
			}
		}
		catch(Exception e)
		{
			Log.log(Log.ERROR,this,e);
		}

		return vocabs;
	} //}}}

	//{{{ makeWord() method
	/**
	 * Make a word from an info list returned by Factor.
	 */
	public synchronized FactorWord makeWord(Cons info)
	{
		String vocabulary = (String)info.car;
		String name = (String)info.next().car;
		FactorWord w = super.searchVocabulary(new Cons(vocabulary,null),name);
		if(w == null)
			w = new FactorWord(vocabulary,name);
		w.stackEffect = (String)info.next().next().car;
		return w;
	} //}}}

	//{{{ searchVocabulary() method
	/**
	 * Search through the given vocabulary list for the given word.
	 */
	public synchronized FactorWord searchVocabulary(Cons vocabulary, String name)
	{
		FactorWord w = super.searchVocabulary(vocabulary,name);

		if(w != null)
			return w;

		if(closed)
			return define("#<unknown>",name);

		try
		{
			Cons result = parseObject(eval(FactorReader.unparseObject(name)
				+ " "
				+ FactorReader.unparseObject(vocabulary)
				+ " search jedit-lookup ."));
			if(result.car == null)
				return null;

			return makeWord((Cons)result.car);
		}
		catch(Exception e)
		{
			Log.log(Log.ERROR,this,e);
			return null;
		}
	} //}}}

	//{{{ getCompletions() method
	public synchronized void getCompletions(Cons use, String word,
		boolean anywhere, Set completions) throws Exception
	{
		super.getCompletions(use,word,anywhere,completions);

		if(closed)
			return;

		/* We can't send words across the socket at this point in
		human history, because of USE: issues. so we send name/vocab
		pairs. */
		Cons moreCompletions = (Cons)parseObject(eval(
			FactorReader.unparseObject(word)
			+ " "
			+ FactorReader.unparseObject(Boolean.valueOf(anywhere))
			+ " "
			+ FactorReader.unparseObject(use)
			+ " completions .")).car;

		while(moreCompletions != null)
		{
			Cons completion = (Cons)moreCompletions.car;
			FactorWord w = makeWord(completion);
			if(w != null)
				completions.add(w);
			moreCompletions = moreCompletions.next();
		}
	} //}}}

	//{{{ close() method
	/**
	 * Close communication session. Factor will then exit.
	 */
	public synchronized void close()
	{
		if(closed)
			return;

		closed = true;

		try
		{
			/* don't care about response */
			sendEval("0 exit*");
		}
		catch(Exception e)
		{
			// We don't care...
			Log.log(Log.DEBUG,this,e);
		}
		
		try
		{
			in.close();
			out.close();
		}
		catch(Exception e)
		{
			// We don't care...
			Log.log(Log.DEBUG,this,e);
		}

		in = null;
		out = null;
	} //}}}

	//{{{ isClosed() method
	public boolean isClosed()
	{
		return closed;
	} //}}}

	//{{{ Private members
	private boolean closed;

	private DataInputStream in;
	private DataOutputStream out;
	
	private int streamServer;
	//}}}
}
