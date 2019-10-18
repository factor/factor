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

package factor.listener;

import factor.*;
import java.awt.*;
import java.awt.event.*;
import java.util.*;
import javax.swing.*;
import javax.swing.text.*;
import javax.swing.text.html.*;

public class FactorListenerPanel extends JPanel
{
	private FactorInterpreter interp;
	private FactorListener listener;

	//{{{ newInterpreter() method
	public static FactorInterpreter newInterpreter(String[] args)
	{
		try
		{
			FactorInterpreter interp = new FactorInterpreter();
			interp.interactive = false;
			interp.init(args);
			return interp;
		}
		catch(Exception e)
		{
			System.err.println("Failed to initialize interpreter:");
			e.printStackTrace();
			return null;
		}
	} //}}}

	//{{{ FactorListenerPanel constructor
	public FactorListenerPanel(FactorInterpreter interp)
	{
		setLayout(new BorderLayout());

		this.interp = interp;

		add(BorderLayout.CENTER,new JScrollPane(
			listener = newListener()));
	} //}}}

	//{{{ getListener() method
	public FactorListener getListener()
	{
		return listener;
	} //}}}

	//{{{ newListener() method
	private FactorListener newListener()
	{
		final FactorListener listener = new FactorListener();
		listener.addEvalListener(new EvalHandler());

		eval(new Cons(listener,
			new Cons(interp.searchVocabulary(
				"listener","new-listener-hook"),
			null)));

		return listener;
	} //}}}

	//{{{ requestDefaultFocus() method
	public boolean requestDefaultFocus()
	{
		listener.requestFocus();
		return true;
	} //}}}

	//{{{ getInterpreter() method
	public FactorInterpreter getInterpreter()
	{
		return interp;
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

	//{{{ EvalHandler class
	class EvalHandler implements EvalListener
	{
		public void eval(Cons cmd)
		{
			FactorListenerPanel.this.eval(cmd);
		}
	} //}}}
}
