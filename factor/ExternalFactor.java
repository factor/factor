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
	/**
	 * We are given two streams that point to a bare REPL.
	 */
	public ExternalFactor(InputStream in, OutputStream out)
		throws IOException
	{
		this.in = new DataInputStream(in);
		this.out = new DataOutputStream(out);

		out.write("USE: jedit wire-server\n".getBytes("ASCII"));
		out.flush();

		waitForAck();

		/* Start stream server */
		streamServer = 9999;
		eval("USE: telnetd [ 9999 telnetd ] in-thread");
	} //}}}

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
		/* Log.log(Log.DEBUG,ExternalFactor.class,"SEND: " + cmd); */

		waitForAck();

		sendEval(cmd);

		int responseLength = in.readInt();
		byte[] response = new byte[responseLength];
		in.readFully(response);
		
		String responseStr = new String(response,"ASCII");
		/* Log.log(Log.DEBUG,ExternalFactor.class,"RECV: " + responseStr); */
		return responseStr;
	} //}}}

	//{{{ openStream() method
	/**
	 * Return a listener stream.
	 */
	public FactorStream openStream() throws IOException
	{
		Socket client = new Socket("localhost",streamServer);
		return new FactorStream(client);
	} //}}}

	//{{{ searchVocabulary() method
	/**
	 * Search through the given vocabulary list for the given word.
	 */
	public FactorWord searchVocabulary(Cons vocabulary, String name)
	{
		FactorWord w = super.searchVocabulary(vocabulary,name);
		if(w != null)
			return w;

		try
		{
			Cons result = parseObject(eval(FactorReader.unparseObject(name)
				+ " "
				+ FactorReader.unparseObject(vocabulary)
				+ " jedit-lookup ."));
			if(result.car == null)
				return null;

			result = (Cons)result.car;
			w = new FactorWord(
				(String)result.car,
				(String)result.next().car);
			w.stackEffect = (String)result.next().next().car;
			return w;
		}
		catch(Exception e)
		{
			Log.log(Log.ERROR,this,e);
			return null;
		}
	} //}}}

	//{{{ close() method
	/**
	 * Close communication session. Factor will then exit.
	 */
	public synchronized void close()
	{
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
	} //}}}

	//{{{ Private members
	private DataInputStream in;
	private DataOutputStream out;
	
	private int streamServer;
	//}}}
}
