/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    RETURN = 258,
    SIGNED = 259,
    UNSIGNED = 260,
    LONG = 261,
    SHORT = 262,
    SWITCH = 263,
    BREAK = 264,
    CONTINUE = 265,
    CASE = 266,
    DEFAULT = 267,
    STRUCT = 268,
    FOR = 269,
    WHILE = 270,
    DO = 271,
    IF = 272,
    ELSE = 273,
    STRING = 274,
    INCLUDE = 275,
    OPEN_PAR = 276,
    CLOSE_PAR = 277,
    FLOATNUM = 278,
    CHARCONST = 279,
    ID = 280,
    INT = 281,
    CHAR = 282,
    FLOAT = 283,
    DOUBLE = 284,
    VOID = 285,
    NUM = 286,
    PAS = 287,
    MAS = 288,
    DAS = 289,
    SAS = 290,
    AND = 291,
    OR = 292,
    NOT = 293,
    PP = 294,
    MM = 295,
    LE = 296,
    GE = 297,
    EQ = 298,
    NE = 299,
    LT = 300,
    GT = 301
  };
#endif
/* Tokens.  */
#define RETURN 258
#define SIGNED 259
#define UNSIGNED 260
#define LONG 261
#define SHORT 262
#define SWITCH 263
#define BREAK 264
#define CONTINUE 265
#define CASE 266
#define DEFAULT 267
#define STRUCT 268
#define FOR 269
#define WHILE 270
#define DO 271
#define IF 272
#define ELSE 273
#define STRING 274
#define INCLUDE 275
#define OPEN_PAR 276
#define CLOSE_PAR 277
#define FLOATNUM 278
#define CHARCONST 279
#define ID 280
#define INT 281
#define CHAR 282
#define FLOAT 283
#define DOUBLE 284
#define VOID 285
#define NUM 286
#define PAS 287
#define MAS 288
#define DAS 289
#define SAS 290
#define AND 291
#define OR 292
#define NOT 293
#define PP 294
#define MM 295
#define LE 296
#define GE 297
#define EQ 298
#define NE 299
#define LT 300
#define GT 301

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED

union YYSTYPE
{
#line 255 "miniC.y" /* yacc.c:1909  */

	char id[100];
        int num;
        float floatNum;
        char charConst;
        //symbolAttrib symAttrib;
        struct{
                char type[100];
                char val[100];
        } symAttrib;

#line 158 "y.tab.h" /* yacc.c:1909  */
};

typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
