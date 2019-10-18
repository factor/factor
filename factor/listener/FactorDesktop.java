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
import javax.swing.*;
import javax.swing.text.*;
import javax.swing.text.html.*;

public class FactorDesktop extends JFrame implements FactorObject
{
	private JTabbedPane tabs;
	private FactorInterpreter interp;
	private FactorNamespace namespace;

	//{{{ main() method
	public static void main(String[] args)
	{
		new FactorDesktop(args);
	} //}}}

	//{{{ FactorDesktop constructor
	public FactorDesktop(String[] args)
	{
		super("Factor");
		tabs = new JTabbedPane();

		getContentPane().add(BorderLayout.CENTER,tabs);

		try
		{
			interp = new FactorInterpreter();
			interp.interactive = false;
			interp.init(args,this);
		}
		catch(Exception e)
		{
			System.err.println("Failed to initialize interpreter:");
			e.printStackTrace();
		}

		newListener();

		setSize(640,480);
		setDefaultCloseOperation(EXIT_ON_CLOSE);
		show();
	} //}}}

	//{{{ getNamespace() method
	public FactorNamespace getNamespace(FactorInterpreter interp)
		throws Exception
	{
		if(namespace == null)
			namespace = new FactorNamespace(interp.global,this);
		return namespace;
	} //}}}

	//{{{ newListener() method
	public FactorListener newListener()
	{
		FactorListener listener = new FactorListener();
		listener.addEvalListener(new EvalHandler());

		try
		{
			interp.call(new Cons(listener,
				new Cons(interp.intern("new-listener-hook"),
				null)));
			interp.run();
		}
		catch(Exception e)
		{
			System.err.println("Failed to initialize listener:");
			e.printStackTrace();
		}

		tabs.addTab("Listener",new JScrollPane(listener));
		return listener;
	} //}}}

	//{{{ getInterpreter() method
	public FactorInterpreter getInterpreter()
	{
		return interp;
	} //}}}

	//{{{ eval() method
	public void eval(Cons cmd)
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
			FactorDesktop.this.eval(cmd);
		}
	} //}}}

	//{{{ EvalAction class
	class EvalAction extends AbstractAction
	{
		private Cons code;

		public EvalAction(String label, Cons code)
		{
			super(label);
			this.code = code;
		}

		public void actionPerformed(ActionEvent evt)
		{
			FactorDesktop.this.eval(code);
		}
	} //}}}
}
