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
			state.packetLoop(output);
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
			state.readResponse(command,output);
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

	//{{{ ConsoleState class
	class ConsoleState
	{
		private Console console;
		private Output output;
		private FactorStream stream;
		private boolean waitingForInput;
		
		ConsoleState(Console console)
		{
			this.console = console;
			this.output = console.getShellState(FactorShell.this);
		}

		void openStream()
		{
			if(stream != null)
				return;

			output.print(console.getInfoColor(),
				jEdit.getProperty("factor.shell.opening"));

			stream = null;
			ExternalFactor external = FactorPlugin.getExternalInstance();
			if(external != null)
				stream = external.openStream();

			if(stream == null)
			{
				output.print(console.getInfoColor(),
					jEdit.getProperty("factor.shell.no-connection"));
			}
			else
			{
				try
				{
					packetLoop(output);
				}
				catch(Exception e)
				{
					Log.log(Log.ERROR,this,e);
				}
			}
		}

		void closeStream()
		{
			try
			{
				if(stream != null)
				{
					waitingForInput = false;
					output.print(console.getInfoColor(),
						jEdit.getProperty("factor.shell.closing"));
					stream.close();
				}
			}
			catch(IOException e)
			{
				throw new RuntimeException(e);
			}

			stream = null;
		}
		
		private void handleWritePacket(FactorStream.WritePacket w, Output output)
			throws Exception
		{
			Cons pair = FactorPlugin.getExternalInstance()
				.parseObject(w.getText());

			if(pair.car instanceof String)
			{
				String write = (String)pair.car;
				AttributeSet attrs = new ListenerAttributeSet(
					(Cons)pair.next().car);
	
				output.writeAttrs(attrs,write);
			}
			else
				Log.log(Log.ERROR,this,"Malformed write packet: " + pair);
		}
		
		void packetLoop(Output output) throws Exception
		{
			if(waitingForInput)
				return;

			if(stream == null)
				return;

			for(;;)
			{
				FactorStream.Packet p = stream.nextPacket();
				if(p == null)
				{
					/* EOF */
					closeStream();
					break;
				}
				else if(p instanceof FactorStream.ReadLinePacket)
				{
					waitingForInput = true;
					break;
				}
				else if(p instanceof FactorStream.WritePacket)
					handleWritePacket((FactorStream.WritePacket)p,output);
			}
		}

		void readResponse(String command, Output output) throws Exception
		{
			if(waitingForInput)
			{
				openStream();

				if(stream == null)
					return;

				stream.readResponse(command);
				waitingForInput = false;
				packetLoop(output);
			}
			else
			{
				output.print(console.getErrorColor(),
					jEdit.getProperty("factor.shell.not-waiting"));
			}
		}
	} //}}}
}
