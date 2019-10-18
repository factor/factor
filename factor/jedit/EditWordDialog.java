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
import javax.swing.border.*;
import javax.swing.event.*;
import javax.swing.text.Document;
import javax.swing.*;
import java.awt.event.*;
import java.awt.*;
import java.io.IOException;
import java.util.List;
import org.gjt.sp.jedit.gui.EnhancedDialog;
import org.gjt.sp.jedit.*;
import org.gjt.sp.util.Log;

public class EditWordDialog extends WordListDialog
{
	private JTextField field;
	private Timer timer;

	//{{{ EditWordDialog constructor
	public EditWordDialog(View view, FactorSideKickParser parser)
	{
		super(view,parser,jEdit.getProperty("factor.edit-word.title"));

		Box top = new Box(BoxLayout.X_AXIS);
		top.add(new JLabel(jEdit.getProperty(
			"factor.edit-word.caption")));
		top.add(Box.createHorizontalStrut(12));
		top.add(field = new JTextField(16));
		field.getDocument().addDocumentListener(new DocumentHandler());
		field.addKeyListener(new KeyHandler());
		getContentPane().add(BorderLayout.NORTH,top);

		list.setFixedCellHeight(list.getFontMetrics(list.getFont())
			.getHeight());
		list.addKeyListener(new KeyHandler());

		timer = new Timer(0,new UpdateTimer());

		pack();
		setLocationRelativeTo(view);
		setVisible(true);
	} //}}}
	
	//{{{ ok() method
	public void ok()
	{
		FactorWord word = (FactorWord)list.getSelectedValue();
		if(word == null)
		{
			getToolkit().beep();
			return;
		}

		try
		{
			FactorPlugin.evalInWire(FactorPlugin.factorWord(word) + " jedit");
		}
		catch(IOException e)
		{
			throw new RuntimeException(e);
		}
		dispose();
	} //}}}

	//{{{ cancel() method
	public void cancel()
	{
		dispose();
	} //}}}
	
	//{{{ updateListWithDelay() method
	private void updateListWithDelay()
	{
		timer.stop();
		String text = field.getText();
		if(text.length() <= 1)
			list.setListData(new Object[0]);
		else
		{
			timer.setInitialDelay(100);
			timer.setRepeats(false);
			timer.start();
		}
	} //}}}
	
	//{{{ updateList() method
	private void updateList()
	{
		FactorWord[] completions = FactorPlugin.toWordArray(
			FactorPlugin.getWordCompletions(
			field.getText(),true));
		list.setListData(completions);
		if(completions.length != 0)
		{
			list.setSelectedIndex(0);
			list.ensureIndexIsVisible(0);
		}

		updatePreview();
	} //}}}
	
	//{{{ UpdateTimer class
	class UpdateTimer implements ActionListener
	{
		public void actionPerformed(ActionEvent evt)
		{
			updateList();
		}
	} //}}}

	//{{{ KeyHandler class
	class KeyHandler extends KeyAdapter
	{
		public void keyPressed(KeyEvent evt)
		{
			switch(evt.getKeyCode())
			{
			case KeyEvent.VK_UP:
				int selected = list.getSelectedIndex();

				if(selected == 0)
					selected = list.getModel().getSize() - 1;
				else if(getFocusOwner() == list)
					return;
				else
					selected = selected - 1;

				list.setSelectedIndex(selected);
				list.ensureIndexIsVisible(selected);

				evt.consume();
				break;
			case KeyEvent.VK_DOWN:
				/* int */ selected = list.getSelectedIndex();

				if(selected == list.getModel().getSize() - 1)
					selected = 0;
				else if(getFocusOwner() == list)
					return;
				else
					selected = selected + 1;

				list.setSelectedIndex(selected);
				list.ensureIndexIsVisible(selected);

				evt.consume();
				break;
			}
		}
	} //}}}
	
	//{{{ DocumentHandler class
	class DocumentHandler implements DocumentListener
	{
		public void insertUpdate(DocumentEvent evt)
		{
			updateListWithDelay();
		}
		
		public void removeUpdate(DocumentEvent evt)
		{
			updateListWithDelay();
		}
		
		public void changedUpdate(DocumentEvent evt)
		{
		}
	} //}}}
}
