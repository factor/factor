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

package factor.jedit;

import factor.Cons;
import factor.FactorReader;
import javax.swing.text.AttributeSet;
import java.io.*;
import java.net.Socket;
import java.util.*;

/**
 * Encapsulates a Factor listener connection.
 */
public class FactorStream
{
	//{{{ FactorStream constructor
	/**
	 * We are given a socket that points to a bare REPL.
	 */
	public FactorStream(Socket socket) throws IOException
	{
		this.socket = socket;
		this.in = new DataInputStream(new BufferedInputStream(
			socket.getInputStream()));
		this.out = new DataOutputStream(new BufferedOutputStream(
			socket.getOutputStream()));

		out.write("\"\\0\" write flush USE: jedit stream-server\n"
			.getBytes("ASCII"));
		out.flush();

		/* Read everything until prompt */
		int b = -2;
		while(b != '\0' && b != -1)
			b = in.read();
	} //}}}

	//{{{ nextPacket() method
	/**
	 * @return null on EOF.
	 */
	public Packet nextPacket() throws Exception
	{
		int ch = in.read();
		switch(ch)
		{
		case 'r':
			return new ReadLinePacket();
		case 'f':
			return new FlushPacket();
		case 'w':
			int len = in.readInt();
			byte[] request = new byte[len];
			in.readFully(request);
			return new WritePacket(new String(request,0,len));
		case -1:
			return null;
		default:
			throw new IOException("Bad stream packet type: " + ch);
		}
	} //}}}
	
	//{{{ readResponse() method
	/**
	 * This must only be called if the last packet received was a read request.
	 */
	public void readResponse(String input) throws IOException
	{
		int len = input.length();
		out.writeInt(len);
		out.write(input.getBytes("ASCII"),0,len);
		out.flush();
	} //}}}

	//{{{ close() method
	/**
	 * Close communication session. Factor will then exit.
	 */
	public void close() throws IOException
	{
		socket.close();
		in.close();
		out.close();
	} //}}}

	//{{{ Private members
	private Socket socket;
	private DataInputStream in;
	private DataOutputStream out;
	//}}}
	
	//{{{ Packet class
	public static abstract class Packet {}
	//}}}
	
	//{{{ ReadLinePacket class
	public static class ReadLinePacket extends Packet {}
	//}}}
	
	//{{{ FlushPacket class
	public static class FlushPacket extends Packet {}
	//}}}
	
	//{{{ WritePacket class
	public static class WritePacket extends Packet
	{
		public WritePacket(String input)
			throws Exception
		{
			FactorReader parser = new FactorReader(
				"parseObject()",
				new BufferedReader(new StringReader(input)),
				true,FactorPlugin.getExternalInstance());
			Cons pair = parser.parse();

			this.write = (String)pair.car;
			this.attrs = new ListenerAttributeSet((Cons)pair.next().car);
		}
		
		public String getText()
		{
			return write;
		}

		public AttributeSet getAttributes()
		{
			return attrs;
		}

		private String write;
		private AttributeSet attrs;
	} //}}}
}
