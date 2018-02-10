# Phase 2 - Syntax Analyser Report

## Introduction

The second phase of the compiler is syntax analysis or parsing. The parser uses the tokens produced by the lexical analyzer to create a tree-like intermediate representation that depicts the grammatical structure
of the token stream. It also checks for correct syntax in the process. A typical representation is a syntax tree in which each interior node represents an operation and the children of the node represent the arguments of the operation. The subsequent phases of the compiler use the grammatical structure to help analyze the source program and generate the target program.
<br><br>
 By design, every programming language has precise rules that prescribe the
syntactic structure of well-formed programs. In C, for example, a program is made up of functions, a function out of declarations and statements, a statement out of expressions, and so on. The syntax of programming language constructs can be specied by context-free grammars or BNF (Backus-Naur Form) notation.Grammars offer significant benefits for both language designers and compiler writers.
<br><br>

## Type of Parsers

The job of the parser is to determine how to represent the input as a derivation of the start state. There are multiple ways to achieve this:
- **Top-Down Parsing:** Top-down parsing can be viewed as an attempt to find left-most derivations of an input-stream by searching for parse trees using a top-down expansion of the given formal grammar rules. Tokens are consumed from left to right. Inclusive choice is used to accommodate ambiguity by expanding all alternative right-hand-sides of grammar rules. Ex: LL parser and recursive descent parsers.
- **Bottom-Up Parsing:** A parser can start with the input and attempt to rewrite it to the start symbol. Intuitively, the parser attempts to locate the most basic elements, then the elements containing these, and so on. LR parsers are examples of bottom-up parsers. Another term used for this type of parser is Shift-Reduce parsing.

## Yacc

Yacc (Yet Another Compiler Compiler) is a program that is used to generate a parser for a programming language. It is a LALR (Look Ahead Left-to-Right) parser generator written in a notation similar to BNF. The input to Yacc is a grammar with snippets of C code (called "actions") attached to its rules. Its output is a shift-reduce parser in C that executes the C snippets associated with each rule as soon as the rule is recognized. Typical actions involve the construction of parse trees. Yacc produces only a parser; for full syntactic analysis this requires an external lexical analyzer (here Lex) to perform the first tokenization stage (word analysis), which is then followed by the parsing stage proper.



