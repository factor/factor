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

import factor.*;
import java.awt.Component;
import javax.swing.*;
import org.gjt.sp.jedit.*;

public class FactorWordRenderer extends DefaultListCellRenderer
{
	//{{{ getWordHTMLString() method
	public static String getWordHTMLString(FactorInterpreter interp,
		FactorWord word, FactorWordDefinition def, boolean showIn)
	{
		String prop = "factor.completion.plain";
		String stackEffect = null;

		if(def == null)
		{
			if(word.parsing != null)
				prop = "factor.completion.parsing";
			else
				prop = "factor.completion.defer";
		}
		else if(def instanceof FactorShuffleDefinition)
		{
			prop = "factor.completion.shuffle";
			StringBuffer buf = new StringBuffer();
			Cons d = def.toList(interp);
			while(d != null)
			{
				if(buf.length() != 0)
					buf.append(' ');

				buf.append(d.car);
				d = d.next();
			}
			stackEffect = buf.toString();
		}
		else if(def instanceof FactorSymbolDefinition)
		{
			prop = "factor.completion.symbol";
		}
		else
		{
			Cons d = def.toList(interp);
			if(d != null && d.car instanceof FactorDocComment)
			{
				FactorDocComment comment = (FactorDocComment)
					d.car;
				if(comment.isStackComment())
				{
					prop = "factor.completion.stack";
					stackEffect = comment.toString();
				}
			}
		}

		String in;
		if(showIn)
		{
			in = jEdit.getProperty("factor.completion.in",
				new Object[] {
					MiscUtilities.charsToEntities(word.vocabulary)
				});
		}
		else
			in = "";

		return "<html>" + in + jEdit.getProperty(prop,
			new Object[] {
				MiscUtilities.charsToEntities(word.name),
				stackEffect == null
				? null :
				MiscUtilities.charsToEntities(stackEffect)
			});
	} //}}}

	private FactorSideKickParser parser;
	private boolean showIn;

	//{{{ FactorWordRenderer constructor
	public FactorWordRenderer(FactorSideKickParser parser, boolean showIn)
	{
		this.parser = parser;
		this.showIn = showIn;
	} //}}}

	//{{{ getListCellRendererComponent() method
	public Component getListCellRendererComponent(
		JList list,
		Object value,
		int index,
		boolean isSelected,
		boolean cellHasFocus)
	{
		super.getListCellRendererComponent(list,value,index,
			isSelected,cellHasFocus);

		if(!(value instanceof FactorWord))
			return this;

		FactorWord word = (FactorWord)value;
		setText(getWordHTMLString(parser.getInterpreter(),
			word,
			parser.getWordDefinition(word),
			showIn));

		return this;
	} //}}}
}
