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
import factor.Cons;
import javax.swing.text.*;
import javax.swing.Action;
import java.awt.Color;

public class ListenerAttributeSet extends SimpleAttributeSet
{
	//{{{ ListenerAttributeSet constructor
	ListenerAttributeSet(Cons alist)
	{
		while(alist != null)
		{
			Cons pair = (Cons)alist.car;
			handleAttribute(pair.car,pair.cdr);
			alist = alist.next();
		}
	} //}}}
	
	//{{{ handleAttribute() method
	private void handleAttribute(Object key, Object value)
	{
		if("bold".equals(key))
			addAttribute(StyleConstants.Bold,Boolean.TRUE);
		else if("italics".equals(key))
			addAttribute(StyleConstants.Italic,Boolean.TRUE);
		else if("underline".equals(key))
			addAttribute(StyleConstants.Underline,Boolean.TRUE);
		else if("fg".equals(key))
			addAttribute(StyleConstants.Foreground,toColor((Cons)value));
		else if("bg".equals(key))
			addAttribute(StyleConstants.Background,toColor((Cons)value));
		else if("font".equals(key))
			addAttribute(StyleConstants.FontFamily,value);
		else if("size".equals(key))
			addAttribute(StyleConstants.FontSize,value);
		else if("actions".equals(key))
			addAttribute(ConsolePane.Actions,createActionsMenu((Cons)value));
	} //}}}
	
	//{{{ toColor() method
	private Color toColor(Cons color)
	{
		Number r = (Number)color.car;
		Number g = (Number)color.next().car;
		Number b = (Number)color.next().next().car;
		return new Color(r.intValue(),g.intValue(),b.intValue());
	} //}}}
	
	//{{{ createActionsMenu() method
	private Action[] createActionsMenu(Cons alist)
	{
		if(alist == null)
			return null;

		int length = alist.length();
		int i = 0;
		Action[] actions = new Action[length];
		while(alist != null)
		{
			Cons pair = (Cons)alist.car;
			actions[i++] = new Console.EvalAction(
				(String)pair.car,(String)pair.cdr);
			alist = alist.next();
		}
		
		return actions;
	} //}}}
}
