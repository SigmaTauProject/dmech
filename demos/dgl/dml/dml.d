/*
Copyright (c) 2015 Timur Gafarov 

Boost Software License - Version 1.0 - August 17th, 2003

Permission is hereby granted, free of charge, to any person or organization
obtaining a copy of the software and accompanying documentation covered by
this license (the "Software") to use, reproduce, display, distribute,
execute, and transmit the Software, and to prepare derivative works of the
Software, and to permit third-parties to whom the Software is furnished to
do so, all subject to the following:

The copyright notices in the Software and this entire statement, including
the above license grant, this restriction and the following disclaimer,
must be included in all copies of the Software, in whole or in part, and
all derivative works of the Software, unless such copies or derivative
works are solely in the form of machine-executable object code generated by
a source language processor.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
*/

module dgl.dml.dml;

import std.stdio;
import std.conv;
import dlib.core.memory;
import dlib.container.dict;
import dlib.container.hash;
import dlib.math.vector;
import dlib.image.color;
import dgl.dml.lexer;
import dgl.dml.stringconv;

struct DMLValue
{
    string data;

    string toString()
    {
        return data;
    }

    double toDouble()
    {
        return to!double(data);
    }

    float toFloat()
    {
        return to!float(data);
    }

    int toInt()
    {
        return to!int(data);
    }

    bool toBool()
    {
        return cast(bool)to!int(data);
    }

    Vector3f toVector3f()
    {
        return Vector3f(data);
    }

    Vector4f toVector4f()
    {
        return Vector4f(data);
    }

    Color4f toColor4f()
    {
        return Color4f(Vector4f(data));
    }
}

//TODO: rewrite without GC
struct DMLStruct
{
    //DMLValue[string] data;
    Dict!(DMLValue, string) data;
    alias data this;
    
    static DMLStruct opCall()
    {
        DMLStruct s;
        s.data = dict!(DMLValue, string);
        return s;
    }

    bool set(Lexeme key, Lexeme val)
    {
        string k = convToStr(key.str.data);
        string v = convToStr(val.str.data[1..$-1]);
		return set(k, v);
    }
	
    bool set(string k, string v)
    {
        if (data is null)
            data = dict!(DMLValue, string);
        
        data[k] = DMLValue(v);
        return true;
    }

    void free()
    {
        if (data !is null)
            Delete(data);
    }
}

struct DMLData
{
    DMLStruct root;
    alias root this;
    
    static DMLData opCall()
    {
        DMLData d;
        d.root = DMLStruct();
        return d;
    }

    void free()
    {
        root.free();
    }
}

bool parseDML(string text, DMLData* data)
{    
    Lexer lexer = Lexer(text);

    Lexeme lexeme;
    lexeme = lexer.get();
    if (lexeme.valid)
    {
        if (lexeme.str.data == "{")
        {
            lexeme.free();
            return parseStruct(&lexer, &data.root);
        }
        else
        {
            lexeme.valid = false;
            writefln("DML error at line %s: expected \"{\", not \"%s\"", lexer.line, lexeme.str.data);
            return false;
        }
    }
    else
    {
        writeln("DML error: empty string");
        return false;
    }
}

bool parseStruct(Lexer* lexer, DMLStruct* stru)
{
    Lexeme lexeme = lexer.current;
    bool noError = true;
    while(noError && lexeme.valid && lexeme.str.data != "}")
    {
        lexeme = lexer.get();
        if (lexeme.str.data != "}")
        {
            noError = parseStatement(lexer, stru);
            lexeme = lexer.current;
        }
    }

    if (lexeme.str.data != "}")
    {
        lexeme.free();
        writefln("DML syntax error at line %s: missing \"}\"", lexer.line);
        return false;
    }

    lexeme.free();
    return noError;
}

bool parseStatement(Lexer* lexer, DMLStruct* stru)
{
    Lexeme id, value;
    Lexeme lexeme = lexer.current;
    // TODO: assert identifier

    id = lexeme;
    lexeme = lexer.get();
    if (lexeme.str.data != "=")
    {
        writefln("DML syntax error at line %s: \"=\" expected, got \"%s\"", lexer.line, lexeme.str.data);
        lexeme.free();
        return false;
    }
    lexeme.free();
    lexeme = lexer.get();
    if (!isString(lexeme))
    {
        writefln("DML syntax error at line %s: string expected, got \"%s\"", lexer.line, lexeme.str.data);
        lexeme.free();
        return false;
    }
    value = lexeme;
    lexeme = lexer.get();
    if (lexeme.str.data != ";")
    {
        writefln("DML syntax error at line %s: \";\" expected, got \"%s\"", lexer.line, lexeme.str.data);
        lexeme.free();
        return false;
    }
    lexeme.free();

    stru.set(id, value);
    id.free();
    value.free();

    return true;
}

bool isString(Lexeme lexeme)
{
    return lexeme.str.data[0] == '\"' &&
           lexeme.str.data[$-1] == '\"';
}
