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
import java.util.WeakHashMap;
import org.gjt.sp.jedit.ServiceManager;

public class FactorShell extends Shell
{
	//{{{ readLine() method
	/**
	 * Helper static method to simplify Factor code.
	 */
	public static void readLine(Cons continuation, Console console)
	{
		FactorShell shell = (FactorShell)ServiceManager.getService(
			"console.Shell","Factor");
		ConsoleState state = shell.getConsoleState(console);
		state.readLineContinuation = continuation;
	} //}}}
	
	//{{{ FactorShell constructor
	public FactorShell()
	{
		super("Factor");
		interp = FactorPlugin.getInterpreter();
		consoles = new WeakHashMap();
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
		getConsoleState(console);
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
		ConsoleState state = getConsoleState(console);
		Cons quot = new Cons(command,state.readLineContinuation);
		eval(quot);
		output.commandDone();
		error.commandDone();
	} //}}}
	
	//{{{ stop() method
	/**
	 * Stops the currently executing command, if any.
	 */
	public void stop(Console console)
	{
	} //}}}
	
	//{{{ Private members
	private FactorInterpreter interp;
	private WeakHashMap consoles;
	
	//{{{ getConsoleState() method
	private ConsoleState getConsoleState(Console console)
	{
		ConsoleState state = (ConsoleState)consoles.get(console);
		if(state == null)
		{
			state = new ConsoleState(console);
			consoles.put(console,state);

			eval(new Cons(console,
				new Cons(interp.searchVocabulary(
					"console","console-hook"),
					null)));
		}
		return state;
	} //}}}

	//{{{ eval() method
	private void eval(Cons cmd)
	{
		try
		{
			interp.call(cmd);
			interp.run();
		}
		catch(Exception e)
		{
			System.err.println("Failed to eval " + cmd + ":");
			e.printStackTrace();
		}
	} //}}}

	//}}}

	//{{{ ConsoleState class
	class ConsoleState
	{
		private Console console;
		Cons readLineContinuation;
		
		ConsoleState(Console console)
		{
			this.console = console;
		}
	} //}}}
}
