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
import javax.swing.*;
import java.awt.event.*;
import java.awt.*;
import org.gjt.sp.jedit.gui.EnhancedDialog;
import org.gjt.sp.jedit.*;
import org.gjt.sp.util.Log;

public abstract class WordListDialog extends EnhancedDialog
{
	protected View view;
	protected JList list;
	protected JTextArea preview;
	protected JButton ok, cancel;

	//{{{ WordListDialog constructor
	public WordListDialog(View view, FactorSideKickParser parser,
		String title)
	{
		super(view,title,true);

		this.view = view;

		JPanel content = new JPanel(new BorderLayout(12,12));
		content.setBorder(new EmptyBorder(12,12,12,12));
		setContentPane(content);

		JScrollPane listScroll = new JScrollPane(
			list = new JList());
		list.setCellRenderer(new FactorWordRenderer(parser,true));
		list.addListSelectionListener(new ListHandler());

		JScrollPane previewScroll = new JScrollPane(
			preview = new JTextArea(12,60));
		preview.setEditable(false);

		listScroll.setPreferredSize(previewScroll.getPreferredSize());

		JSplitPane split = new JSplitPane(JSplitPane.VERTICAL_SPLIT,
			listScroll,previewScroll);
		split.setDividerLocation(0.5);
		split.setResizeWeight(0.5);
		content.add(BorderLayout.CENTER,split);

		content.add(BorderLayout.SOUTH,createButtonPanel());
	} //}}}

	//{{{ updatePreview() method
	protected void updatePreview()
	{
		FactorWord word = (FactorWord)list.getSelectedValue();
		if(word == null)
		{
			preview.setText("");
			return;
		}

		try
		{
			String text = FactorPlugin.evalInWire(
				FactorPlugin.factorWord(word) + " see").trim();
			preview.setText(text);
			preview.setCaretPosition(text.length());
		}
		catch(Exception e)
		{
			Log.log(Log.ERROR,this,e);
		}
	} //}}}

	//{{{ createButtonPanel() method
	private Box createButtonPanel()
	{
		Box buttons = new Box(BoxLayout.X_AXIS);
		buttons.add(Box.createGlue());
		buttons.add(ok = new JButton(jEdit.getProperty(
			"common.ok")));
		getRootPane().setDefaultButton(ok);
		ok.addActionListener(new ActionHandler());
		buttons.add(Box.createHorizontalStrut(12));
		buttons.add(cancel = new JButton(jEdit.getProperty(
			"common.cancel")));
		cancel.addActionListener(new ActionHandler());
		buttons.add(Box.createGlue());
		
		return buttons;
	} //}}}

	//{{{ ActionHandler class
	class ActionHandler implements ActionListener
	{
		public void actionPerformed(ActionEvent evt)
		{
			if(evt.getSource() == ok)
				ok();
			else if(evt.getSource() == cancel)
				cancel();
		}
	} //}}}

	//{{{ ListHandler class
	class ListHandler implements ListSelectionListener
	{
		public void valueChanged(ListSelectionEvent evt)
		{
			updatePreview();
		}
	} //}}}
}
