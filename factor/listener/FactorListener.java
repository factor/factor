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
import javax.swing.event.*;
import javax.swing.text.*;

public class FactorListener extends JTextPane
{
	private static final Cursor MoveCursor
		= Cursor.getPredefinedCursor
		(Cursor.HAND_CURSOR);
	private static final Cursor DefaultCursor
		= Cursor.getPredefinedCursor
		(Cursor.TEXT_CURSOR);
	private static final Cursor WaitCursor
		= Cursor.getPredefinedCursor
		(Cursor.WAIT_CURSOR);

	public static final Object Link = new Object();

	private EventListenerList listenerList;

	private Cons readLineContinuation;
	private int cmdStart = -1;

	//{{{ FactorListener constructor
	public FactorListener()
	{
		MouseHandler mouse = new MouseHandler();
		addMouseListener(mouse);
		addMouseMotionListener(mouse);

		listenerList = new EventListenerList();

		getInputMap().put(KeyStroke.getKeyStroke('\n'),
			new EnterAction());
	} //}}}

	//{{{ insertWithAttrs() method
	public void insertWithAttrs(String text, AttributeSet attrs)
		throws BadLocationException
	{
		if(text == null)
			throw new NullPointerException();

		StyledDocument doc = (StyledDocument)getDocument();
		int offset1 = doc.getLength();
		doc.insertString(offset1,text,null);
		int offset2 = offset1 + text.length();
		doc.setCharacterAttributes(offset1,offset2,attrs,false);
		setCaretPosition(offset2);
	} //}}}

	//{{{ readLine() method
	public void readLine(Cons continuation)
		throws BadLocationException
	{
		StyledDocument doc = (StyledDocument)getDocument();
		setCursor(DefaultCursor);
		this.readLineContinuation = continuation;
		cmdStart = doc.getLength();
		setCaretPosition(cmdStart);
		/* doc.setCharacterAttributes(cmdStart,cmdStart,input,false);
		setCharacterAttributes(input,false); */
	} //}}}

	//{{{ getLine() method
	private String getLine() throws BadLocationException
	{
		StyledDocument doc = (StyledDocument)getDocument();
		int length = doc.getLength();
		if(cmdStart > length)
			return "";
		else
			return doc.getText(cmdStart,length - cmdStart);
	} //}}}

	//{{{ addEvalListener() method
	public void addEvalListener(EvalListener l)
	{
		listenerList.add(EvalListener.class,l);
	} //}}}

	//{{{ removeEvalListener() method
	public void removeEvalListener(EvalListener l)
	{
		listenerList.remove(EvalListener.class,l);
	} //}}}

	//{{{ eval() method
	public void eval(String eval)
	{
		if(eval == null)
			return;

		try
		{
			StyledDocument doc = (StyledDocument)getDocument();
			doc.insertString(doc.getLength(),eval + "\n",
				getCharacterAttributes());
		}
		catch(BadLocationException ble)
		{
			ble.printStackTrace();
		}
		fireEvalEvent(eval);
	} //}}}

	//{{{ fireEvalEvent() method
	public void fireEvalEvent(String code)
	{
		setCursor(WaitCursor);

		Cons quot = new Cons(code,readLineContinuation);
		//readLineContinuation = null;

		Object[] listeners = listenerList.getListenerList();
		for(int i = 0; i < listeners.length; i++)
		{
			if(listeners[i] == EvalListener.class)
			{
				EvalListener l = (EvalListener)listeners[i+1];
				l.eval(quot);
			}
		}
	} //}}}

	//{{{ getLinkAt() method
	private String getLinkAt(int pos)
	{
		StyledDocument doc = (StyledDocument)getDocument();
		Element e = doc.getCharacterElement(pos);
		AttributeSet a = e.getAttributes();
		if(a == null)
			return null;
		else
			return (String)a.getAttribute(Link);
	} //}}}

	//{{{ MouseHandler class
	class MouseHandler extends MouseInputAdapter
	{
		public void mouseClicked(MouseEvent e)
		{
			JEditorPane editor = (JEditorPane) e.getSource();

			Point pt = new Point(e.getX(), e.getY());
			int pos = editor.viewToModel(pt);
			if(pos >= 0)
				eval(getLinkAt(pos));
		}

		public void mouseMoved(MouseEvent e)
		{
			JEditorPane editor = (JEditorPane) e.getSource();

			Point pt = new Point(e.getX(), e.getY());
			int pos = editor.viewToModel(pt);
			if(pos >= 0)
			{
				Cursor cursor;
				if(getLinkAt(pos) != null)
					cursor = MoveCursor;
				else
					cursor = DefaultCursor;

				if(getCursor() != cursor)
					setCursor(cursor);
			}
		}
	} //}}}

	//{{{ EnterAction class
	class EnterAction extends AbstractAction
	{
		public void actionPerformed(ActionEvent evt)
		{
			try
			{
				fireEvalEvent(getLine());
			}
			catch(BadLocationException e)
			{
				e.printStackTrace();
			}
		}
	} //}}}
}
