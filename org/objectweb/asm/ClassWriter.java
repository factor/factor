/***
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

package org.objectweb.asm;

/**
 * A {@link ClassVisitor ClassVisitor} that generates Java class files. More
 * precisely this visitor generates a byte array conforming to the Java class
 * file format. It can be used alone, to generate a Java class "from scratch",
 * or with one or more {@link ClassReader ClassReader} and adapter class
 * visitor to generate a modified class from one or more existing Java classes.
 */

public class ClassWriter implements ClassVisitor {

  /**
   * The type of CONSTANT_Class constant pool items.
   */

  final static int CLASS = 7;

  /**
   * The type of CONSTANT_Fieldref constant pool items.
   */

  final static int FIELD = 9;

  /**
   * The type of CONSTANT_Methodref constant pool items.
   */

  final static int METH = 10;

  /**
   * The type of CONSTANT_InterfaceMethodref constant pool items.
   */

  final static int IMETH = 11;

  /**
   * The type of CONSTANT_String constant pool items.
   */

  final static int STR = 8;

  /**
   * The type of CONSTANT_Integer constant pool items.
   */

  final static int INT = 3;

  /**
   * The type of CONSTANT_Float constant pool items.
   */

  final static int FLOAT = 4;

  /**
   * The type of CONSTANT_Long constant pool items.
   */

  final static int LONG = 5;

  /**
   * The type of CONSTANT_Double constant pool items.
   */

  final static int DOUBLE = 6;

  /**
   * The type of CONSTANT_NameAndType constant pool items.
   */

  final static int NAME_TYPE = 12;

  /**
   * The type of CONSTANT_Utf8 constant pool items.
   */

  final static int UTF8 = 1;

  /**
   * Minor and major version numbers of the class to be generated.
   */

  private int version;

  /**
   * Index of the next item to be added in the constant pool.
   */

  private short index;

  /**
   * The constant pool of this class.
   */

  private ByteVector pool;

  /**
   * The constant pool's hash table data.
   */

  private Item[] items;

  /**
   * The threshold of the constant pool's hash table.
   */

  private int threshold;

  /**
   * The access flags of this class.
   */

  private int access;

  /**
   * The constant pool item that contains the internal name of this class.
   */

  private int name;

  /**
   * The constant pool item that contains the internal name of the super class
   * of this class.
   */

  private int superName;

  /**
   * Number of interfaces implemented or extended by this class or interface.
   */

  private int interfaceCount;

  /**
   * The interfaces implemented or extended by this class or interface. More
   * precisely, this array contains the indexes of the constant pool items
   * that contain the internal names of these interfaces.
   */

  private int[] interfaces;

  /**
   * The index of the constant pool item that contains the name of the source
   * file from which this class was compiled.
   */

  private int sourceFile;

  /**
   * Number of fields of this class.
   */

  private int fieldCount;

  /**
   * The fields of this class.
   */

  private ByteVector fields;

  /**
   * <tt>true</tt> if the maximum stack size and number of local variables must
   * be automatically computed.
   */

  private boolean computeMaxs;

  /**
   * The methods of this class. These methods are stored in a linked list of
   * {@link CodeWriter CodeWriter} objects, linked to each other by their {@link
   * CodeWriter#next} field. This field stores the first element of this list.
   */

  CodeWriter firstMethod;

  /**
   * The methods of this class. These methods are stored in a linked list of
   * {@link CodeWriter CodeWriter} objects, linked to each other by their {@link
   * CodeWriter#next} field. This field stores the last element of this list.
   */

  CodeWriter lastMethod;

  /**
   * The number of entries in the InnerClasses attribute.
   */

  private int innerClassesCount;

  /**
   * The InnerClasses attribute.
   */

  private ByteVector innerClasses;

  /**
   * The non standard attributes of the class.
   */

  private Attribute attrs;

  /**
   * A reusable key used to look for items in the hash {@link #items items}.
   */

  Item key;

  /**
   * A reusable key used to look for items in the hash {@link #items items}.
   */

  Item key2;

  /**
   * A reusable key used to look for items in the hash {@link #items items}.
   */

  Item key3;

  /**
   * The type of instructions without any label.
   */

  final static int NOARG_INSN = 0;

  /**
   * The type of instructions with an signed byte label.
   */

  final static int SBYTE_INSN = 1;

  /**
   * The type of instructions with an signed short label.
   */

  final static int SHORT_INSN = 2;

  /**
   * The type of instructions with a local variable index label.
   */

  final static int VAR_INSN = 3;

  /**
   * The type of instructions with an implicit local variable index label.
   */

  final static int IMPLVAR_INSN = 4;

  /**
   * The type of instructions with a type descriptor argument.
   */

  final static int TYPE_INSN = 5;

  /**
   * The type of field and method invocations instructions.
   */

  final static int FIELDORMETH_INSN = 6;

  /**
   * The type of the INVOKEINTERFACE instruction.
   */

  final static int ITFMETH_INSN = 7;

  /**
   * The type of instructions with a 2 bytes bytecode offset label.
   */

  final static int LABEL_INSN = 8;

  /**
   * The type of instructions with a 4 bytes bytecode offset label.
   */

  final static int LABELW_INSN = 9;

  /**
   * The type of the LDC instruction.
   */

  final static int LDC_INSN = 10;

  /**
   * The type of the LDC_W and LDC2_W instructions.
   */

  final static int LDCW_INSN = 11;

  /**
   * The type of the IINC instruction.
   */

  final static int IINC_INSN = 12;

  /**
   * The type of the TABLESWITCH instruction.
   */

  final static int TABL_INSN = 13;

  /**
   * The type of the LOOKUPSWITCH instruction.
   */

  final static int LOOK_INSN = 14;

  /**
   * The type of the MULTIANEWARRAY instruction.
   */

  final static int MANA_INSN = 15;

  /**
   * The type of the WIDE instruction.
   */

  final static int WIDE_INSN = 16;

  /**
   * The instruction types of all JVM opcodes.
   */

  static byte[] TYPE;

  // --------------------------------------------------------------------------
  // Static initializer
  // --------------------------------------------------------------------------

  /**
   * Computes the instruction types of JVM opcodes.
   */

  static {
    int i;
    byte[] b = new byte[220];
    String s =
      "AAAAAAAAAAAAAAAABCKLLDDDDDEEEEEEEEEEEEEEEEEEEEAAAAAAAADDDDDEEEEEEEEE" +
      "EEEEEEEEEEEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMAAA" +
      "AAAAAAAAAAAAAAAAAIIIIIIIIIIIIIIIIDNOAAAAAAGGGGGGGHAFBFAAFFAAQPIIJJII" +
      "IIIIIIIIIIIIIIII";
    for (i = 0; i < b.length; ++i) {
      b[i] = (byte)(s.charAt(i) - 'A');
    }
    TYPE = b;

    /* code to generate the above string

    // SBYTE_INSN instructions
    b[Constants.NEWARRAY] = SBYTE_INSN;
    b[Constants.BIPUSH] = SBYTE_INSN;

    // SHORT_INSN instructions
    b[Constants.SIPUSH] = SHORT_INSN;

    // (IMPL)VAR_INSN instructions
    b[Constants.RET] = VAR_INSN;
    for (i = Constants.ILOAD; i <= Constants.ALOAD; ++i) {
      b[i] = VAR_INSN;
    }
    for (i = Constants.ISTORE; i <= Constants.ASTORE; ++i) {
      b[i] = VAR_INSN;
    }
    for (i = 26; i <= 45; ++i) { // ILOAD_0 to ALOAD_3
      b[i] = IMPLVAR_INSN;
    }
    for (i = 59; i <= 78; ++i) { // ISTORE_0 to ASTORE_3
      b[i] = IMPLVAR_INSN;
    }

    // TYPE_INSN instructions
    b[Constants.NEW] = TYPE_INSN;
    b[Constants.ANEWARRAY] = TYPE_INSN;
    b[Constants.CHECKCAST] = TYPE_INSN;
    b[Constants.INSTANCEOF] = TYPE_INSN;

    // (Set)FIELDORMETH_INSN instructions
    for (i = Constants.GETSTATIC; i <= Constants.INVOKESTATIC; ++i) {
      b[i] = FIELDORMETH_INSN;
    }
    b[Constants.INVOKEINTERFACE] = ITFMETH_INSN;

    // LABEL(W)_INSN instructions
    for (i = Constants.IFEQ; i <= Constants.JSR; ++i) {
      b[i] = LABEL_INSN;
    }
    b[Constants.IFNULL] = LABEL_INSN;
    b[Constants.IFNONNULL] = LABEL_INSN;
    b[200] = LABELW_INSN; // GOTO_W
    b[201] = LABELW_INSN; // JSR_W
    // temporary opcodes used internally by ASM - see Label and CodeWriter
    for (i = 202; i < 220; ++i) {
      b[i] = LABEL_INSN;
    }

    // LDC(_W) instructions
    b[Constants.LDC] = LDC_INSN;
    b[19] = LDCW_INSN; // LDC_W
    b[20] = LDCW_INSN; // LDC2_W

    // special instructions
    b[Constants.IINC] = IINC_INSN;
    b[Constants.TABLESWITCH] = TABL_INSN;
    b[Constants.LOOKUPSWITCH] = LOOK_INSN;
    b[Constants.MULTIANEWARRAY] = MANA_INSN;
    b[196] = WIDE_INSN; // WIDE

    for (i = 0; i < b.length; ++i) {
      System.err.print((char)('A' + b[i]));
    }
    System.err.println();
    */
  }

  // --------------------------------------------------------------------------
  // Constructor
  // --------------------------------------------------------------------------

  /**
   * Constructs a new {@link ClassWriter ClassWriter} object.
   *
   * @param computeMaxs <tt>true</tt> if the maximum stack size and the maximum
   *      number of local variables must be automatically computed. If this flag
   *      is <tt>true</tt>, then the arguments of the {@link
   *      CodeVisitor#visitMaxs visitMaxs} method of the {@link CodeVisitor
   *      CodeVisitor} returned by the {@link #visitMethod visitMethod} method
   *      will be ignored, and computed automatically from the signature and
   *      the bytecode of each method.
   */

  public ClassWriter (final boolean computeMaxs) {
    this(computeMaxs, 45, 3);
  }

  /**
   * Constructs a new {@link ClassWriter ClassWriter} object.
   *
   * @param computeMaxs <tt>true</tt> if the maximum stack size and the maximum
   *      number of local variables must be automatically computed. If this flag
   *      is <tt>true</tt>, then the arguments of the {@link
   *      CodeVisitor#visitMaxs visitMaxs} method of the {@link CodeVisitor
   *      CodeVisitor} returned by the {@link #visitMethod visitMethod} method
   *      will be ignored, and computed automatically from the signature and
   *      the bytecode of each method.
   * @param major the major version of the class to be generated.
   * @param minor the minor version of the class to be generated.
   */

  public ClassWriter (final boolean computeMaxs, final int major, final int minor) {
    index = 1;
    pool = new ByteVector();
    items = new Item[64];
    threshold = (int)(0.75d*items.length);
    key = new Item();
    key2 = new Item();
    key3 = new Item();
    this.computeMaxs = computeMaxs;
    this.version = minor << 16 | major;
  }

  // --------------------------------------------------------------------------
  // Implementation of the ClassVisitor interface
  // --------------------------------------------------------------------------

  public void visit (
    final int access,
    final String name,
    final String superName,
    final String[] interfaces,
    final String sourceFile)
  {
    this.access = access;
    this.name = newClass(name);
    this.superName = superName == null ? 0 : newClass(superName);
    if (interfaces != null && interfaces.length > 0) {
      interfaceCount = interfaces.length;
      this.interfaces = new int[interfaceCount];
      for (int i = 0; i < interfaceCount; ++i) {
        this.interfaces[i] = newClass(interfaces[i]);
      }
    }
    if (sourceFile != null) {
      newUTF8("SourceFile");
      this.sourceFile = newUTF8(sourceFile);
    }
    if ((access & Constants.ACC_DEPRECATED) != 0) {
      newUTF8("Deprecated");
    }
  }

  public void visitInnerClass (
    final String name,
    final String outerName,
    final String innerName,
    final int access)
  {
    if (innerClasses == null) {
      newUTF8("InnerClasses");
      innerClasses = new ByteVector();
    }
    ++innerClassesCount;
    innerClasses.putShort(name == null ? 0 : newClass(name));
    innerClasses.putShort(outerName == null ? 0 : newClass(outerName));
    innerClasses.putShort(innerName == null ? 0 : newUTF8(innerName));
    innerClasses.putShort(access);
  }

  public void visitField (
    final int access,
    final String name,
    final String desc,
    final Object value,
    final Attribute attrs)
  {
    ++fieldCount;
    if (fields == null) {
      fields = new ByteVector();
    }
    fields.putShort(access).putShort(newUTF8(name)).putShort(newUTF8(desc));
    int attributeCount = 0;
    if (value != null) {
      ++attributeCount;
    }
    if ((access & Constants.ACC_SYNTHETIC) != 0) {
      ++attributeCount;
    }
    if ((access & Constants.ACC_DEPRECATED) != 0) {
      ++attributeCount;
    }
    if (attrs != null) {
      attributeCount += attrs.getCount();
    }
    fields.putShort(attributeCount);
    if (value != null) {
      fields.putShort(newUTF8("ConstantValue"));
      fields.putInt(2).putShort(newCst(value).index);
    }
    if ((access & Constants.ACC_SYNTHETIC) != 0) {
      fields.putShort(newUTF8("Synthetic")).putInt(0);
    }
    if ((access & Constants.ACC_DEPRECATED) != 0) {
      fields.putShort(newUTF8("Deprecated")).putInt(0);
    }
    if (attrs != null) {
      attrs.getSize(this, null, 0, -1, -1);
      attrs.put(this, null, 0, -1, -1, fields);
    }
  }

  public CodeVisitor visitMethod (
    final int access,
    final String name,
    final String desc,
    final String[] exceptions,
    final Attribute attrs)
  {
    CodeWriter cw = new CodeWriter(this, computeMaxs);
    cw.init(access, name, desc, exceptions, attrs);
    return cw;
  }

  public void visitAttribute (final Attribute attr) {
    attr.next = attrs;
    attrs = attr;
  }

  public void visitEnd () {
  }

  // --------------------------------------------------------------------------
  // Other public methods
  // --------------------------------------------------------------------------

  /**
   * Returns the bytecode of the class that was build with this class writer.
   *
   * @return the bytecode of the class that was build with this class writer.
   */

  public byte[] toByteArray () {
    // computes the real size of the bytecode of this class
    int size = 24 + 2*interfaceCount;
    if (fields != null) {
      size += fields.length;
    }
    int nbMethods = 0;
    CodeWriter cb = firstMethod;
    while (cb != null) {
      ++nbMethods;
      size += cb.getSize();
      cb = cb.next;
    }
    int attributeCount = 0;
    if (sourceFile != 0) {
      ++attributeCount;
      size += 8;
    }
    if ((access & Constants.ACC_DEPRECATED) != 0) {
      ++attributeCount;
      size += 6;
    }
    if (innerClasses != null) {
      ++attributeCount;
      size += 8 + innerClasses.length;
    }
    if (attrs != null) {
      attributeCount += attrs.getCount();
      size += attrs.getSize(this, null, 0, -1, -1);
    }
    size += pool.length;
    // allocates a byte vector of this size, in order to avoid unnecessary
    // arraycopy operations in the ByteVector.enlarge() method
    ByteVector out = new ByteVector(size);
    out.putInt(0xCAFEBABE).putInt(version);
    out.putShort(index).putByteArray(pool.data, 0, pool.length);
    out.putShort(access).putShort(name).putShort(superName);
    out.putShort(interfaceCount);
    for (int i = 0; i < interfaceCount; ++i) {
      out.putShort(interfaces[i]);
    }
    out.putShort(fieldCount);
    if (fields != null) {
      out.putByteArray(fields.data, 0, fields.length);
    }
    out.putShort(nbMethods);
    cb = firstMethod;
    while (cb != null) {
      cb.put(out);
      cb = cb.next;
    }
    out.putShort(attributeCount);
    if (sourceFile != 0) {
      out.putShort(newUTF8("SourceFile")).putInt(2).putShort(sourceFile);
    }
    if ((access & Constants.ACC_DEPRECATED) != 0) {
      out.putShort(newUTF8("Deprecated")).putInt(0);
    }
    if (innerClasses != null) {
      out.putShort(newUTF8("InnerClasses"));
      out.putInt(innerClasses.length + 2).putShort(innerClassesCount);
      out.putByteArray(innerClasses.data, 0, innerClasses.length);
    }
    if (attrs != null) {
      attrs.put(this, null, 0, -1, -1, out);
    }
    return out.data;
  }

  // --------------------------------------------------------------------------
  // Utility methods: constant pool management
  // --------------------------------------------------------------------------

  /**
   * Adds a number or string constant to the constant pool of the class being
   * build. Does nothing if the constant pool already contains a similar item.
   *
   * @param cst the value of the constant to be added to the constant pool. This
   *      parameter must be an {@link java.lang.Integer Integer}, a {@link
   *      java.lang.Float Float}, a {@link java.lang.Long Long}, a {@link
          java.lang.Double Double} or a {@link String String}.
   * @return a new or already existing constant item with the given value.
   */

  Item newCst (final Object cst) {
    if (cst instanceof Integer) {
      int val = ((Integer)cst).intValue();
      return newInteger(val);
    } else if (cst instanceof Float) {
      float val = ((Float)cst).floatValue();
      return newFloat(val);
    } else if (cst instanceof Long) {
      long val = ((Long)cst).longValue();
      return newLong(val);
    } else if (cst instanceof Double) {
      double val = ((Double)cst).doubleValue();
      return newDouble(val);
    } else if (cst instanceof String) {
      return newString((String)cst);
    } else {
      throw new IllegalArgumentException("value " + cst);
    }
  }

  /**
   * Adds a number or string constant to the constant pool of the class being
   * build. Does nothing if the constant pool already contains a similar item.
   * <i>This method is intended for {@link Attribute} sub classes, and is
   * normally not needed by class generators or adapters.</i>
   *
   * @param cst the value of the constant to be added to the constant pool. This
   *      parameter must be an {@link java.lang.Integer Integer}, a {@link
   *      java.lang.Float Float}, a {@link java.lang.Long Long}, a {@link
          java.lang.Double Double} or a {@link String String}.
   * @return the index of a new or already existing constant item with the given
   *      value.
   */

  public int newConst (final Object cst) {
    return newCst(cst).index;
  }

  /**
   * Adds an UTF8 string to the constant pool of the class being build. Does
   * nothing if the constant pool already contains a similar item. <i>This
   * method is intended for {@link Attribute} sub classes, and is normally not
   * needed by class generators or adapters.</i>
   *
   * @param value the String value.
   * @return the index of a new or already existing UTF8 item.
   */

  public int newUTF8 (final String value) {
    key.set(UTF8, value, null, null);
    Item result = get(key);
    if (result == null) {
      pool.putByte(UTF8).putUTF8(value);
      result = new Item(index++, key);
      put(result);
    }
    return result.index;
  }

  /**
   * Adds a class reference to the constant pool of the class being build. Does
   * nothing if the constant pool already contains a similar item. <i>This
   * method is intended for {@link Attribute} sub classes, and is normally not
   * needed by class generators or adapters.</i>
   *
   * @param value the internal name of the class.
   * @return the index of a new or already existing class reference item.
   */

  public int newClass (final String value) {
    key2.set(CLASS, value, null, null);
    Item result = get(key2);
    if (result == null) {
      pool.put12(CLASS, newUTF8(value));
      result = new Item(index++, key2);
      put(result);
    }
    return result.index;
  }

  /**
   * Adds a field reference to the constant pool of the class being build. Does
   * nothing if the constant pool already contains a similar item. <i>This
   * method is intended for {@link Attribute} sub classes, and is normally not
   * needed by class generators or adapters.</i>
   *
   * @param owner the internal name of the field's owner class.
   * @param name the field's name.
   * @param desc the field's descriptor.
   * @return the index of a new or already existing field reference item.
   */

  public int newField (
    final String owner,
    final String name,
    final String desc)
  {
    key3.set(FIELD, owner, name, desc);
    Item result = get(key3);
    if (result == null) {
      put122(FIELD, newClass(owner), newNameType(name, desc));
      result = new Item(index++, key3);
      put(result);
    }
    return result.index;
  }

  /**
   * Adds a method reference to the constant pool of the class being build. Does
   * nothing if the constant pool already contains a similar item.
   *
   * @param owner the internal name of the method's owner class.
   * @param name the method's name.
   * @param desc the method's descriptor.
   * @param itf <tt>true</tt> if <tt>owner</tt> is an interface.
   * @return a new or already existing method reference item.
   */

  Item newMethodItem (
    final String owner,
    final String name,
    final String desc,
    final boolean itf)
  {
    key3.set(itf ? IMETH : METH, owner, name, desc);
    Item result = get(key3);
    if (result == null) {
      put122(itf ? IMETH : METH, newClass(owner), newNameType(name, desc));
      result = new Item(index++, key3);
      put(result);
    }
    return result;
  }

  /**
   * Adds a method reference to the constant pool of the class being build. Does
   * nothing if the constant pool already contains a similar item. <i>This
   * method is intended for {@link Attribute} sub classes, and is normally not
   * needed by class generators or adapters.</i>
   *
   * @param owner the internal name of the method's owner class.
   * @param name the method's name.
   * @param desc the method's descriptor.
   * @param itf <tt>true</tt> if <tt>owner</tt> is an interface.
   * @return the index of a new or already existing method reference item.
   */

  public int newMethod (
    final String owner,
    final String name,
    final String desc,
    final boolean itf)
  {
    return newMethodItem(owner, name, desc, itf).index;
  }

  /**
   * Adds an integer to the constant pool of the class being build. Does nothing
   * if the constant pool already contains a similar item.
   *
   * @param value the int value.
   * @return a new or already existing int item.
   */

  private Item newInteger (final int value) {
    key.set(value);
    Item result = get(key);
    if (result == null) {
      pool.putByte(INT).putInt(value);
      result = new Item(index++, key);
      put(result);
    }
    return result;
  }

  /**
   * Adds a float to the constant pool of the class being build. Does nothing if
   * the constant pool already contains a similar item.
   *
   * @param value the float value.
   * @return a new or already existing float item.
   */

  private Item newFloat (final float value) {
    key.set(value);
    Item result = get(key);
    if (result == null) {
      pool.putByte(FLOAT).putInt(Float.floatToIntBits(value));
      result = new Item(index++, key);
      put(result);
    }
    return result;
  }

  /**
   * Adds a long to the constant pool of the class being build. Does nothing if
   * the constant pool already contains a similar item.
   *
   * @param value the long value.
   * @return a new or already existing long item.
   */

  private Item newLong (final long value) {
    key.set(value);
    Item result = get(key);
    if (result == null) {
      pool.putByte(LONG).putLong(value);
      result = new Item(index, key);
      put(result);
      index += 2;
    }
    return result;
  }

  /**
   * Adds a double to the constant pool of the class being build. Does nothing
   * if the constant pool already contains a similar item.
   *
   * @param value the double value.
   * @return a new or already existing double item.
   */

  private Item newDouble (final double value) {
    key.set(value);
    Item result = get(key);
    if (result == null) {
      pool.putByte(DOUBLE).putLong(Double.doubleToLongBits(value));
      result = new Item(index, key);
      put(result);
      index += 2;
    }
    return result;
  }

  /**
   * Adds a string to the constant pool of the class being build. Does nothing
   * if the constant pool already contains a similar item.
   *
   * @param value the String value.
   * @return a new or already existing string item.
   */

  private Item newString (final String value) {
    key2.set(STR, value, null, null);
    Item result = get(key2);
    if (result == null) {
      pool.put12(STR, newUTF8(value));
      result = new Item(index++, key2);
      put(result);
    }
    return result;
  }

  /**
   * Adds a name and type to the constant pool of the class being build. Does
   * nothing if the constant pool already contains a similar item.
   *
   * @param name a name.
   * @param desc a type descriptor.
   * @return the index of a new or already existing name and type item.
   */

  private int newNameType (final String name, final String desc) {
    key2.set(NAME_TYPE, name, desc, null);
    Item result = get(key2);
    if (result == null) {
      put122(NAME_TYPE, newUTF8(name), newUTF8(desc));
      result = new Item(index++, key2);
      put(result);
    }
    return result.index;
  }

  /**
   * Returns the constant pool's hash table item which is equal to the given
   * item.
   *
   * @param key a constant pool item.
   * @return the constant pool's hash table item which is equal to the given
   *      item, or <tt>null</tt> if there is no such item.
   */

  private Item get (final Item key) {
    int h = key.hashCode;
    Item i = items[h % items.length];
    while (i != null) {
      if (i.hashCode == h && key.isEqualTo(i)) {
        return i;
      }
      i = i.next;
    }
    return null;
  }

  /**
   * Puts the given item in the constant pool's hash table. The hash table
   * <i>must</i> not already contains this item.
   *
   * @param i the item to be added to the constant pool's hash table.
   */

  private void put (final Item i) {
    if (index > threshold) {
      Item[] newItems = new Item[items.length * 2 + 1];
      for (int l = items.length - 1; l >= 0; --l) {
        Item j = items[l];
        while (j != null) {
          int index = j.hashCode % newItems.length;
          Item k = j.next;
          j.next = newItems[index];
          newItems[index] = j;
          j = k;
        }
      }
      items = newItems;
      threshold = (int)(items.length * 0.75);
    }
    int index = i.hashCode % items.length;
    i.next = items[index];
    items[index] = i;
  }

  /**
   * Puts one byte and two shorts into the constant pool.
   *
   * @param b a byte.
   * @param s1 a short.
   * @param s2 another short.
   */

  private void put122 (final int b, final int s1, final int s2) {
    pool.put12(b, s1).putShort(s2);
  }
}
