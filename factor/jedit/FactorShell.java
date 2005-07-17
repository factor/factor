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

import console.*;
import factor.*;
import javax.swing.text.AttributeSet;
import java.io.*;
import java.net.Socket;
import java.util.Iterator;
import java.util.HashMap;
import org.gjt.sp.jedit.jEdit;
import org.gjt.sp.jedit.ServiceManager;
import org.gjt.sp.util.Log;

public class FactorShell extends Shell
{
	//{{{ FactorShell constructor
	public FactorShell()
	{
		super("Factor");
		consoles = new HashMap();
	} //}}}

	//{{{ closeConsole() method
	/**
	 * Called when a Console dockable is closed.
	 * @since Console 4.0.2
	 */
	public void closeConsole(Console console)
	{
		ConsoleState state = (ConsoleState)consoles.get(console);
		if(state != null)
			state.closeStream();
	} //}}}

	//{{{ printInfoMessage() method
	/**
	 * Prints a 'info' message to the specified console.
	 * @param output The output
	 */
	public void printInfoMessage(Output output)
	{
	} //}}}

	//{{{ printPrompt() method
	/**
	 * Prints a prompt to the specified console.
	 * @param console The console instance
	 * @param output The output
	 * @since Console 3.6
	 */
	public void printPrompt(Console console, Output output)
	{
		ConsoleState state = null;

		try
		{
			state = getConsoleState(console);
			state.openStream();
		}
		catch(Exception e)
		{
			output.print(console.getErrorColor(),e.toString());
			if(state != null)
				state.closeStream();
			Log.log(Log.ERROR,this,e);
		}
	} //}}}

	//{{{ execute() method
	/**
	 * Executes a command.
	 * @param console The console
	 * @param input Standard input
	 * @param output Standard output
	 * @param error Standard error
	 * @param command The command
	 * @since Console 3.5
	 */
	public void execute(Console console, String input,
		Output output, Output error, String command)
	{
		ConsoleState state = null;
		try
		{
			state = getConsoleState(console);
			state.userInput(command);
		}
		catch(Exception e)
		{
			output.print(console.getErrorColor(),e.toString());
			if(state != null)
				state.closeStream();
			Log.log(Log.ERROR,this,e);
		}
		finally
		{
			output.commandDone();
			error.commandDone();
		}
	} //}}}
	
	//{{{ stop() method
	/**
	 * Stops the currently executing command, if any.
	 */
	public void stop(Console console)
	{
	} //}}}

	//{{{ openStreams() method
	/**
	 * Open all listener connections. Should be called after Factor is restarted.
	 */
	public void openStreams()
	{
		Iterator iter = consoles.values().iterator();
		while(iter.hasNext())
		{
			ConsoleState state = (ConsoleState)iter.next();
			state.openStream();
		}
	} //}}}

	//{{{ closeStreams() method
	/**
	 * Close all listener connections. Should be called before Factor is restarted.
	 */
	public void closeStreams()
	{
		Iterator iter = consoles.values().iterator();
		while(iter.hasNext())
		{
			ConsoleState state = (ConsoleState)iter.next();
			state.closeStream();
		}
	} //}}}

	//{{{ Private members
	private HashMap consoles;
	
	//{{{ getConsoleState() method
	private ConsoleState getConsoleState(Console console)
		throws IOException
	{
		ConsoleState state = (ConsoleState)consoles.get(console);
		if(state == null)
		{
			state = new ConsoleState(console);
			consoles.put(console,state);
		}
		return state;
	} //}}}

	//}}}

	//{{{ StreamThread class
	static class StreamThread extends Thread
	{
		private Reader in;
		private Output output;

		StreamThread(Reader in, Output output)
		{
			this.in = in;
			this.output = output;
		}
		
		public void run()
		{
			try
			{
				char[] buf = new char[4096];
				
				for(;;)
				{
					int count = in.read(buf);
					if(count <= 0)
						break;
					output.writeAttrs(null, new String(buf,0,count));
				}
			}
			catch(IOException io)
			{
				Log.log(Log.ERROR,this,io);
			}
			finally
			{
				try
				{
					in.close();
				}
				catch(IOException io2)
				{
					Log.log(Log.ERROR,this,io2);
				}
			}
		}
	} //}}}

	//{{{ ConsoleState class
	class ConsoleState
	{
		private Console console;
		private Output output;
		private Reader in;
		private Writer out;
		private StreamThread thread;
		
		ConsoleState(Console console)
		{
			this.console = console;
			this.output = console.getShellState(FactorShell.this);
		}

		void openStream()
		{
			if(thread != null)
				return;

			output.print(console.getInfoColor(),
				jEdit.getProperty("factor.shell.opening"));

			Socket socket = null;
			
			ExternalFactor external = FactorPlugin.getExternalInstance();
			if(external != null)
				socket = external.openStream();

			if(socket == null)
			{
				output.print(console.getInfoColor(),
					jEdit.getProperty("factor.shell.no-connection"));
			}
			else
			{
				try
				{
					in = new InputStreamReader(socket.getInputStream());
					out = new OutputStreamWriter(socket.getOutputStream());
					thread = new StreamThread(in,output);
					thread.start();
				}
				catch(IOException io)
				{
					Log.log(Log.ERROR,this,io);
					in = null;
					out = null;
					thread = null;
					try
					{
						socket.close();
					}
					catch(IOException io2)
					{
						Log.log(Log.ERROR,this,io2);
					}
				}
			}
		}

		void closeStream()
		{
			if(thread != null)
			{
				output.print(console.getInfoColor(),
					jEdit.getProperty("factor.shell.closing"));
				thread.interrupt();
			}

			in = null;
			out = null;
			thread = null;
		}

		void userInput(String command) throws Exception
		{
			openStream();

			if(thread == null)
				return;

			out.write(command);
			out.write("\n");
			out.flush();
		}
	} //}}}
}
