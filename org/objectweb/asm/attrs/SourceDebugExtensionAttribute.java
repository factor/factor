/**
 * ASM: a very small and fast Java bytecode manipulation framework
 * Copyright (c) 2000,2002,2003 INRIA, France Telecom
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the copyright holders nor the names of its
 *    contributors may be used to endorse or promote products derived from
 *    this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE.
 *
 * Contact: Eric.Bruneton@rd.francetelecom.com
 *
 * Author: Eric Bruneton
 */

package org.objectweb.asm.attrs;

import org.objectweb.asm.Attribute;
import org.objectweb.asm.ByteVector;
import org.objectweb.asm.ClassReader;
import org.objectweb.asm.ClassWriter;
import org.objectweb.asm.Label;

import java.util.Map;

/**
 * The SourceDebugExtension attribute is an optional attribute defined in JSR-045
 * in the attributes table of the ClassFile structure. There can be no more than one
 * SourceDebugExtension attribute in the attributes table of a given ClassFile
 * structure. The SourceDebugExtension attribute has the following format:
 * <pre>
 *   SourceDebugExtension_attribute {
 *     u2 attribute_name_index;
 *     u4 attribute_length;
 *     u1 debug_extension[attribute_length];
 *   }
 * </pre>
 * The items of the SourceDebugExtension_attribute structure are as follows:
 * <dl>
 * <dt>attribute_name_index</dt>
 * <dd>The value of the attribute_name_index item must be a valid index into the
 *     constant_pool table. The constant_pool entry at that index must be a
 *     CONSTANT_Utf8_info structure representing the string "SourceDebugExtension".</dd>
 * <dt>attribute_length</dt>
 * <dd>The value of the attribute_length item indicates the length of
 *     the attribute, excluding the initial six bytes. The value of the
 *     attribute_length item is thus the number of bytes in the debug_extension[]
 *     item.</dd>
 * <dt>debug_extension[]</dt>
 * <dd>The debug_extension array holds a string, which must be in UTF-8 format.
 *     There is no terminating zero byte. The string in the debug_extension item
 *     will be interpreted as extended debugging information. The content of this
 *     string has no semantic effect on the Java Virtual Machine.</dd>
 * </dl>
 *
 * @see <a href="http://www.jcp.org/en/jsr/detail?id=45">JSR-045: Debugging
 * Support for Other Languages</a>
 *
 * @author Eugene Kuleshov
 */

public class SourceDebugExtensionAttribute
  extends Attribute implements Dumpable
 {

  public String debugExtension;

  public SourceDebugExtensionAttribute () {
    super("SourceDebugExtension");
  }

  public SourceDebugExtensionAttribute (String debugExtension) {
    this();
    this.debugExtension = debugExtension;
  }

  protected Attribute read (ClassReader cr, int off,
                            int len, char[] buf, int codeOff, Label[] labels) {
    return new SourceDebugExtensionAttribute(readUTF8(cr, off, len));
  }

  protected ByteVector write (ClassWriter cw, byte[] code,
                              int len, int maxStack, int maxLocals) {
    byte[] b = putUTF8(debugExtension);
    return new ByteVector().putByteArray(b, 0, b.length);
  }

  public void dump (StringBuffer buf, String varName, Map labelNames) {
    buf.append("SourceDebugExtensionAttribute ").append(varName)
      .append(" = new SourceDebugExtensionAttribute(\"")
      .append(debugExtension).append("\");\n");
  }

  private String readUTF8 (ClassReader cr, int index, int utfLen) {
    int endIndex = index + utfLen;
    byte[] b = cr.b;
    char[] buf = new char[utfLen];
    int strLen = 0;
    int c, d, e;
    while (index < endIndex) {
      c = b[index++] & 0xFF;
      switch (c >> 4) {
        case 0:
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
        case 6:
        case 7:
          // 0xxxxxxx
          buf[strLen++] = (char)c;
          break;

        case 12:
        case 13:
          // 110x xxxx   10xx xxxx
          d = b[index++];
          buf[strLen++] = (char)(((c & 0x1F) << 6) | (d & 0x3F));
          break;

        default:
          // 1110 xxxx  10xx xxxx  10xx xxxx
          d = b[index++];
          e = b[index++];
          buf[strLen++] = (char)(((c & 0x0F) << 12) | ((d & 0x3F) << 6) | (e & 0x3F));
          break;
      }
    }

    return new String(buf, 0, strLen);
  }

  private byte[] putUTF8 (String s) {
    int charLength = s.length();
    int byteLength = 0;
    for (int i = 0; i < charLength; ++i) {
      char c = s.charAt(i);
      if (c >= '\001' && c <= '\177') {
        byteLength++;
      } else if (c > '\u07FF') {
        byteLength += 3;
      } else {
        byteLength += 2;
      }
    }
    /*if (byteLength > 65535) {
      throw new IllegalArgumentException();
    }*/
    byte[] data = new byte[byteLength];
    for (int i = 0; i < charLength;) {
      char c = s.charAt(i);
      if (c >= '\001' && c <= '\177') {
        data[i++] = (byte)c;
      } else if (c > '\u07FF') {
        data[i++] = (byte)(0xE0 | c >> 12 & 0xF);
        data[i++] = (byte)(0x80 | c >> 6 & 0x3F);
        data[i++] = (byte)(0x80 | c & 0x3F);
      } else {
        data[i++] = (byte)(0xC0 | c >> 6 & 0x1F);
        data[i++] = (byte)(0x80 | c & 0x3F);
      }
    }
    return data;
  }

  public String toString () {
    return debugExtension;
  }
}
