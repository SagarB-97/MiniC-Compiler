/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison implementation for Yacc-like parsers in C

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

/* C LALR(1) parser skeleton written by Richard Stallman, by
   simplifying the original so-called "semantic" parser.  */

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */

/* Identify Bison output.  */
#define YYBISON 1

/* Bison version.  */
#define YYBISON_VERSION "3.0.4"

/* Skeleton name.  */
#define YYSKELETON_NAME "yacc.c"

/* Pure parsers.  */
#define YYPURE 0

/* Push parsers.  */
#define YYPUSH 0

/* Pull parsers.  */
#define YYPULL 1




/* Copy the first part of user declarations.  */
#line 1 "miniC.y" /* yacc.c:339  */

/*
        TO DO
- Check if id is array but used as a normal variable and vice versa. --
- void variables shouldn't be allowed (Low Priority) --
- Type checking in function call param list 
- better printing
*/

/*
        Done
- Scope eval
- Undeclared variable checking
- Undeclared function checking
- Redeclaration checking
- Illegal array size checking
- Wrong parameter count in function call detected
- Counting number of params
- Making list of params of a function
- array support
- had to add different arraynotation due to differing usage
- Checks if array size < 0
- some more stuff

*/
#include <stdio.h>
#include <stdlib.h>
#include "symbolTable.h"
#include "scope.h"

#define DEBUGY 0

#if defined(DEBUGY) && DEBUGY > 0
        #define DEBUGY_PRINT(fmt, args...) fprintf(stderr, fmt, ##args)
#else
        #define DEBUGY_PRINT(fmt, args...) /* Don't do anything in release builds */
#endif


#define RED   "\x1B[31m"
#define RESET "\x1B[0m"
#define GRN   "\x1B[32m"
#define BLU   "\x1B[34m"


int yyparse (void);
int yylex();
void yyerror(const char * s);

extern FILE *yyin, *yyout;

extern char *yytext;
extern int lineNo;
extern int curScope;

char type[100];

int isHigherPri(char * type1, char * type2){
        int type1_pri, type2_pri;

        if(strcmp(type1,"char")==0) type1_pri = 1;
        else if(strcmp(type1,"int")==0) type1_pri = 2;
        else if(strcmp(type1,"float")==0) type1_pri = 3;

        if(strcmp(type2,"char")==0) type2_pri = 1;
        else if(strcmp(type2,"int")==0) type2_pri = 2;
        else if(strcmp(type2,"float")==0) type2_pri = 3;

        return type1_pri>type2_pri;
}

void printUndecVarErr(int lineNo, char * s){
        printf(RED "Variable %s not declared at line %d\n" RESET, s,lineNo);
}
void printWrongIDUsageError(int lineNo, char * id){
        printf(RED "%s at Line %d is Array. No Subscript given\n" RESET, id,lineNo);
}
void printWrongArrayUsageError(int lineNo, char * id){
        printf(RED "%s at Line %d is not Array\n" RESET, id,lineNo);
}
void printReDecError(int lineNo, char *s){
        printf(RED "Variable %s redeclared at line %d\n" RESET, s,lineNo);
}
void printIllArrayError(int lineNo, char *s, int Dim){
        printf(RED "Array %s of illegal dimensions %d used at line %d\n" RESET, s, Dim, lineNo);
}
void printRetTypeError(int lineNo, char *ret, char *typ, char *name){
        printf(RED "Wrong return type of %s for Function %s of type %s at line %d\n" RESET, ret, typ, name, lineNo);
}
void printWrongParamCountError(int lineNo, int wrong, int actual, char *s){
        printf(RED "%s expects %d parameters and not %d parameters at line %d\n" RESET, s, actual, wrong, lineNo);
}
void printMismatchError(int lineNo, char *lhsType, char *rhsType){
        printf(RED "Error : Type Mismatch in expression at line %d. LHS : %s, RHS : %s\n" RESET, lineNo, lhsType, rhsType);
}
void printVoidVariableError(int lineNo){
        printf(RED "Error : Line - %d. void variables are not allowed\n" RESET, lineNo);
}
void printVoidFunctionReturningError(int lineNo, char *returnType){
        printf(RED "Void function at line %d returning %s" RESET, lineNo, returnType);
}
void printWrongParamError(int lineNo, char * fnName, char expectedParams[100][100], char gotParams[100][100], int count){
        printf(RED "Wrong parameters passed to function %s at line %d\n" RESET,fnName,lineNo);

        int i,j;        
        for(i=0,j=count-1; i<j;i++,j--){
                char temp[100];
                strcpy(temp,expectedParams[j]);
                strcpy(expectedParams[j],expectedParams[i]);
                strcpy(expectedParams[i],temp);
        }

        for(i=0,j=count-1; i<j;i++,j--){
                char temp[100];
                strcpy(temp,gotParams[j]);
                strcpy(gotParams[j],gotParams[i]);
                strcpy(gotParams[i],temp);
        }
        printf(RED "Expected : ");
        
        printf("(");
        for(i=0;i<count;i++){
                printf("%s,",expectedParams[i]);
        }
        printf(")");

        printf("\nGot : ");
        
        printf("(");
        for(i=0;i<count;i++){
                printf("%s,",gotParams[i]);
        }
        printf(")\n" RESET);
}
void printWrongArraySubscriptError(int lineNo, char * id){
        printf(RED "Wrong array subscript at line %d for %s\n" RESET, lineNo, id);
}

symbolItem* checkAncestors(char * s)
{
        //printf("%s\n", s);
        ScopeNode *node = findChild(root, curScope);
        while(node!=NULL)
        {
                //printf("%d\n", node->num);
                if(lookUpSymbolItem_scope(s,node->num))
                        return lookUpSymbolItem_scope(s,node->num); 
                        
                node = node->parent;
        }
        return NULL;
}

char pList[100];
int num = -1;
char returnType[100] = "void";

char params[100][100];
int pCount = 0;

void addToParamList(char *paramType, int position){
        strcpy(params[position],paramType);
}
int isCorrectParams(char params[][100], char * list, char * fnName){
        int i,j;
        // for(i=0,j=pCount-1; i<j;i++,j--){
        //         char temp[100];
        //         strcpy(temp,params[j]);
        //         strcpy(params[j],params[i]);
        //         strcpy(params[i],temp);
        // }
        i=0;
        char thisList[100][100];
        int l = 0;
        while(list[i]!='\0'){
                int k=0;
                char temp[100];
                while(list[i]!=' ' && list[i]!='\0'){
                        temp[k++] = list[i++];
                }
                temp[k]='\0';
                strcpy(thisList[l++],temp);

                while(list[i]!=',' && list[i]!='\0') i++;
                i+=2;
        }

        for(i=0;i<l;i++){
                if(strcmp(thisList[i],params[i])!=0){
                        printWrongParamError(lineNo, fnName, thisList, params, l);
                        return 0;
                }
        }
        return 1;
}


#line 264 "y.tab.c" /* yacc.c:339  */

# ifndef YY_NULLPTR
#  if defined __cplusplus && 201103L <= __cplusplus
#   define YY_NULLPTR nullptr
#  else
#   define YY_NULLPTR 0
#  endif
# endif

/* Enabling verbose error messages.  */
#ifdef YYERROR_VERBOSE
# undef YYERROR_VERBOSE
# define YYERROR_VERBOSE 1
#else
# define YYERROR_VERBOSE 0
#endif

/* In a future release of Bison, this section will be replaced
   by #include "y.tab.h".  */
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
    FLOATNUM = 274,
    STRING = 275,
    CHARCONST = 276,
    INCLUDE = 277,
    OPEN_PAR = 278,
    CLOSE_PAR = 279,
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
#define FLOATNUM 274
#define STRING 275
#define CHARCONST 276
#define INCLUDE 277
#define OPEN_PAR 278
#define CLOSE_PAR 279
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
#line 209 "miniC.y" /* yacc.c:355  */

	char id[100];
        int num;

#line 401 "y.tab.c" /* yacc.c:355  */
};

typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */

/* Copy the second part of user declarations.  */

#line 418 "y.tab.c" /* yacc.c:358  */

#ifdef short
# undef short
#endif

#ifdef YYTYPE_UINT8
typedef YYTYPE_UINT8 yytype_uint8;
#else
typedef unsigned char yytype_uint8;
#endif

#ifdef YYTYPE_INT8
typedef YYTYPE_INT8 yytype_int8;
#else
typedef signed char yytype_int8;
#endif

#ifdef YYTYPE_UINT16
typedef YYTYPE_UINT16 yytype_uint16;
#else
typedef unsigned short int yytype_uint16;
#endif

#ifdef YYTYPE_INT16
typedef YYTYPE_INT16 yytype_int16;
#else
typedef short int yytype_int16;
#endif

#ifndef YYSIZE_T
# ifdef __SIZE_TYPE__
#  define YYSIZE_T __SIZE_TYPE__
# elif defined size_t
#  define YYSIZE_T size_t
# elif ! defined YYSIZE_T
#  include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  define YYSIZE_T size_t
# else
#  define YYSIZE_T unsigned int
# endif
#endif

#define YYSIZE_MAXIMUM ((YYSIZE_T) -1)

#ifndef YY_
# if defined YYENABLE_NLS && YYENABLE_NLS
#  if ENABLE_NLS
#   include <libintl.h> /* INFRINGES ON USER NAME SPACE */
#   define YY_(Msgid) dgettext ("bison-runtime", Msgid)
#  endif
# endif
# ifndef YY_
#  define YY_(Msgid) Msgid
# endif
#endif

#ifndef YY_ATTRIBUTE
# if (defined __GNUC__                                               \
      && (2 < __GNUC__ || (__GNUC__ == 2 && 96 <= __GNUC_MINOR__)))  \
     || defined __SUNPRO_C && 0x5110 <= __SUNPRO_C
#  define YY_ATTRIBUTE(Spec) __attribute__(Spec)
# else
#  define YY_ATTRIBUTE(Spec) /* empty */
# endif
#endif

#ifndef YY_ATTRIBUTE_PURE
# define YY_ATTRIBUTE_PURE   YY_ATTRIBUTE ((__pure__))
#endif

#ifndef YY_ATTRIBUTE_UNUSED
# define YY_ATTRIBUTE_UNUSED YY_ATTRIBUTE ((__unused__))
#endif

#if !defined _Noreturn \
     && (!defined __STDC_VERSION__ || __STDC_VERSION__ < 201112)
# if defined _MSC_VER && 1200 <= _MSC_VER
#  define _Noreturn __declspec (noreturn)
# else
#  define _Noreturn YY_ATTRIBUTE ((__noreturn__))
# endif
#endif

/* Suppress unused-variable warnings by "using" E.  */
#if ! defined lint || defined __GNUC__
# define YYUSE(E) ((void) (E))
#else
# define YYUSE(E) /* empty */
#endif

#if defined __GNUC__ && 407 <= __GNUC__ * 100 + __GNUC_MINOR__
/* Suppress an incorrect diagnostic about yylval being uninitialized.  */
# define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN \
    _Pragma ("GCC diagnostic push") \
    _Pragma ("GCC diagnostic ignored \"-Wuninitialized\"")\
    _Pragma ("GCC diagnostic ignored \"-Wmaybe-uninitialized\"")
# define YY_IGNORE_MAYBE_UNINITIALIZED_END \
    _Pragma ("GCC diagnostic pop")
#else
# define YY_INITIAL_VALUE(Value) Value
#endif
#ifndef YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_END
#endif
#ifndef YY_INITIAL_VALUE
# define YY_INITIAL_VALUE(Value) /* Nothing. */
#endif


#if ! defined yyoverflow || YYERROR_VERBOSE

/* The parser invokes alloca or malloc; define the necessary symbols.  */

# ifdef YYSTACK_USE_ALLOCA
#  if YYSTACK_USE_ALLOCA
#   ifdef __GNUC__
#    define YYSTACK_ALLOC __builtin_alloca
#   elif defined __BUILTIN_VA_ARG_INCR
#    include <alloca.h> /* INFRINGES ON USER NAME SPACE */
#   elif defined _AIX
#    define YYSTACK_ALLOC __alloca
#   elif defined _MSC_VER
#    include <malloc.h> /* INFRINGES ON USER NAME SPACE */
#    define alloca _alloca
#   else
#    define YYSTACK_ALLOC alloca
#    if ! defined _ALLOCA_H && ! defined EXIT_SUCCESS
#     include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
      /* Use EXIT_SUCCESS as a witness for stdlib.h.  */
#     ifndef EXIT_SUCCESS
#      define EXIT_SUCCESS 0
#     endif
#    endif
#   endif
#  endif
# endif

# ifdef YYSTACK_ALLOC
   /* Pacify GCC's 'empty if-body' warning.  */
#  define YYSTACK_FREE(Ptr) do { /* empty */; } while (0)
#  ifndef YYSTACK_ALLOC_MAXIMUM
    /* The OS might guarantee only one guard page at the bottom of the stack,
       and a page size can be as small as 4096 bytes.  So we cannot safely
       invoke alloca (N) if N exceeds 4096.  Use a slightly smaller number
       to allow for a few compiler-allocated temporary stack slots.  */
#   define YYSTACK_ALLOC_MAXIMUM 4032 /* reasonable circa 2006 */
#  endif
# else
#  define YYSTACK_ALLOC YYMALLOC
#  define YYSTACK_FREE YYFREE
#  ifndef YYSTACK_ALLOC_MAXIMUM
#   define YYSTACK_ALLOC_MAXIMUM YYSIZE_MAXIMUM
#  endif
#  if (defined __cplusplus && ! defined EXIT_SUCCESS \
       && ! ((defined YYMALLOC || defined malloc) \
             && (defined YYFREE || defined free)))
#   include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#   ifndef EXIT_SUCCESS
#    define EXIT_SUCCESS 0
#   endif
#  endif
#  ifndef YYMALLOC
#   define YYMALLOC malloc
#   if ! defined malloc && ! defined EXIT_SUCCESS
void *malloc (YYSIZE_T); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
#  ifndef YYFREE
#   define YYFREE free
#   if ! defined free && ! defined EXIT_SUCCESS
void free (void *); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
# endif
#endif /* ! defined yyoverflow || YYERROR_VERBOSE */


#if (! defined yyoverflow \
     && (! defined __cplusplus \
         || (defined YYSTYPE_IS_TRIVIAL && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  yytype_int16 yyss_alloc;
  YYSTYPE yyvs_alloc;
};

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (sizeof (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (sizeof (yytype_int16) + sizeof (YYSTYPE)) \
      + YYSTACK_GAP_MAXIMUM)

# define YYCOPY_NEEDED 1

/* Relocate STACK from its old location to the new one.  The
   local variables YYSIZE and YYSTACKSIZE give the old and new number of
   elements in the stack, and YYPTR gives the new location of the
   stack.  Advance YYPTR to a properly aligned location for the next
   stack.  */
# define YYSTACK_RELOCATE(Stack_alloc, Stack)                           \
    do                                                                  \
      {                                                                 \
        YYSIZE_T yynewbytes;                                            \
        YYCOPY (&yyptr->Stack_alloc, Stack, yysize);                    \
        Stack = &yyptr->Stack_alloc;                                    \
        yynewbytes = yystacksize * sizeof (*Stack) + YYSTACK_GAP_MAXIMUM; \
        yyptr += yynewbytes / sizeof (*yyptr);                          \
      }                                                                 \
    while (0)

#endif

#if defined YYCOPY_NEEDED && YYCOPY_NEEDED
/* Copy COUNT objects from SRC to DST.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if defined __GNUC__ && 1 < __GNUC__
#   define YYCOPY(Dst, Src, Count) \
      __builtin_memcpy (Dst, Src, (Count) * sizeof (*(Src)))
#  else
#   define YYCOPY(Dst, Src, Count)              \
      do                                        \
        {                                       \
          YYSIZE_T yyi;                         \
          for (yyi = 0; yyi < (Count); yyi++)   \
            (Dst)[yyi] = (Src)[yyi];            \
        }                                       \
      while (0)
#  endif
# endif
#endif /* !YYCOPY_NEEDED */

/* YYFINAL -- State number of the termination state.  */
#define YYFINAL  19
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   441

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  63
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  32
/* YYNRULES -- Number of rules.  */
#define YYNRULES  139
/* YYNSTATES -- Number of states.  */
#define YYNSTATES  259

/* YYTRANSLATE[YYX] -- Symbol number corresponding to YYX as returned
   by yylex, with out-of-bounds checking.  */
#define YYUNDEFTOK  2
#define YYMAXUTOK   301

#define YYTRANSLATE(YYX)                                                \
  ((unsigned int) (YYX) <= YYMAXUTOK ? yytranslate[YYX] : YYUNDEFTOK)

/* YYTRANSLATE[TOKEN-NUM] -- Symbol number corresponding to TOKEN-NUM
   as returned by yylex, without out-of-bounds checking.  */
static const yytype_uint8 yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,    56,     2,    52,    54,     2,
       2,     2,    50,    48,    57,    49,    55,    51,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,    58,
       2,    32,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,    59,     2,    60,    53,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,    61,     2,    62,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     1,     2,     3,     4,
       5,     6,     7,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
      25,    26,    27,    28,    29,    30,    31,    33,    34,    35,
      36,    37,    38,    39,    40,    41,    42,    43,    44,    45,
      46,    47
};

#if YYDEBUG
  /* YYRLINE[YYN] -- Source line where rule number YYN was defined.  */
static const yytype_uint16 yyrline[] =
{
       0,   238,   238,   239,   240,   241,   242,   243,   246,   247,
     249,   252,   266,   275,   285,   286,   296,   305,   306,   310,
     313,   313,   313,   313,   313,   314,   314,   314,   314,   316,
     316,   316,   316,   319,   328,   342,   349,   359,   374,   375,
     381,   387,   388,   394,   400,   401,   404,   410,   416,   422,
     428,   434,   440,   446,   452,   458,   464,   465,   466,   467,
     468,   472,   473,   474,   477,   484,   491,   498,   505,   512,
     519,   526,   533,   540,   547,   550,   553,   556,   559,   562,
     565,   569,   570,   571,   572,   575,   576,   577,   578,   579,
     580,   581,   585,   586,   589,   593,   594,   597,   600,   609,
     610,   611,   612,   613,   614,   623,   632,   640,   641,   642,
     643,   648,   656,   664,   672,   682,   684,   685,   688,   689,
     690,   691,   692,   693,   694,   695,   696,   697,   699,   702,
     703,   706,   710,   711,   714,   715,   718,   719,   720,   723
};
#endif

#if YYDEBUG || YYERROR_VERBOSE || 0
/* YYTNAME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals.  */
static const char *const yytname[] =
{
  "$end", "error", "$undefined", "RETURN", "SIGNED", "UNSIGNED", "LONG",
  "SHORT", "SWITCH", "BREAK", "CONTINUE", "CASE", "DEFAULT", "STRUCT",
  "FOR", "WHILE", "DO", "IF", "ELSE", "FLOATNUM", "STRING", "CHARCONST",
  "INCLUDE", "OPEN_PAR", "CLOSE_PAR", "ID", "INT", "CHAR", "FLOAT",
  "DOUBLE", "VOID", "NUM", "'='", "PAS", "MAS", "DAS", "SAS", "AND", "OR",
  "NOT", "PP", "MM", "LE", "GE", "EQ", "NE", "LT", "GT", "'+'", "'-'",
  "'*'", "'/'", "'%'", "'^'", "'&'", "'.'", "'#'", "','", "';'", "'['",
  "']'", "'{'", "'}'", "$accept", "start", "IncludeStatement", "Include",
  "FunctionDef", "FormalParamList", "Declaration", "Type", "Modifiers",
  "FuncArrayNotation", "DefArrayNotation", "ArrayNotation", "IDList",
  "DefineAssign", "ParamList", "Assignment", "Expr", "Logical_Expr",
  "Relational_Expr", "Additive_Expr", "Multiplicative_Expr", "Primary",
  "CompoundStatement", "StatementList", "Statement", "ReturnStatement",
  "WhileStatement", "DoWhileStatement", "ForStatement", "IfStatement",
  "ElseStatement", "FunctionCall", YY_NULLPTR
};
#endif

# ifdef YYPRINT
/* YYTOKNUM[NUM] -- (External) token number corresponding to the
   (internal) symbol number NUM (which must be that of a token).  */
static const yytype_uint16 yytoknum[] =
{
       0,   256,   257,   258,   259,   260,   261,   262,   263,   264,
     265,   266,   267,   268,   269,   270,   271,   272,   273,   274,
     275,   276,   277,   278,   279,   280,   281,   282,   283,   284,
     285,   286,    61,   287,   288,   289,   290,   291,   292,   293,
     294,   295,   296,   297,   298,   299,   300,   301,    43,    45,
      42,    47,    37,    94,    38,    46,    35,    44,    59,    91,
      93,   123,   125
};
# endif

#define YYPACT_NINF -213

#define yypact_value_is_default(Yystate) \
  (!!((Yystate) == (-213)))

#define YYTABLE_NINF -1

#define yytable_value_is_error(Yytable_value) \
  0

  /* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
     STATE-NUM.  */
static const yytype_int16 yypact[] =
{
      27,  -213,  -213,  -213,  -213,  -213,  -213,  -213,  -213,  -213,
      -6,    25,  -213,    27,    27,    27,    11,    53,   -17,  -213,
    -213,  -213,  -213,   100,    14,    62,   -11,    28,  -213,  -213,
    -213,  -213,    45,   297,   323,   323,   323,   323,   323,    34,
      90,   202,   323,   323,   323,   323,   323,    34,  -213,    34,
     -12,    64,    49,  -213,  -213,  -213,   323,     1,  -213,   355,
      68,    92,   355,   355,    97,   103,  -213,  -213,    70,   249,
      93,    95,  -213,  -213,  -213,  -213,  -213,  -213,    33,  -213,
    -213,    -2,   323,   323,   323,   323,   323,    34,  -213,  -213,
    -213,  -213,  -213,  -213,  -213,  -213,   112,   113,    57,   123,
      94,   101,   323,  -213,  -213,   323,   249,  -213,  -213,  -213,
    -213,  -213,  -213,   355,   355,   355,   355,   355,   355,   355,
     355,   355,   355,   355,   355,   355,  -213,  -213,  -213,  -213,
    -213,  -213,  -213,   109,   259,  -213,   297,   291,   124,   297,
    -213,   156,   125,   126,   249,   249,    93,    93,    93,    93,
      93,    93,    95,    95,  -213,  -213,  -213,  -213,   323,   135,
     136,   172,   174,   113,   188,   143,   187,  -213,  -213,    34,
     301,   155,  -213,   160,   259,  -213,  -213,  -213,  -213,  -213,
    -213,  -213,   158,   297,  -213,  -213,   323,  -213,   166,  -213,
    -213,   387,   323,   217,   323,   323,   323,   323,   323,   323,
     324,   323,   323,   323,   323,   323,  -213,  -213,  -213,  -213,
    -213,  -213,  -213,   175,   215,   228,   229,  -213,  -213,  -213,
    -213,  -213,   323,   323,   323,   323,   323,  -213,  -213,  -213,
    -213,  -213,   323,   200,   323,   200,  -213,  -213,  -213,  -213,
    -213,   194,  -213,  -213,   231,   238,   238,   387,   199,   200,
    -213,  -213,   236,  -213,  -213,  -213,   200,  -213,  -213
};

  /* YYDEFACT[STATE-NUM] -- Default reduction number in state STATE-NUM.
     Performed when YYTABLE does not specify something else to do.  Zero
     means the default is an error.  */
static const yytype_uint8 yydefact[] =
{
       0,    32,    31,    30,    29,    20,    23,    21,    24,    22,
       0,     0,    10,     4,     2,     3,     0,     0,     0,     1,
       7,     5,     6,    42,     0,    38,     0,    45,    25,    28,
      26,    27,     0,    18,     0,     0,     0,     0,     0,     0,
       0,    43,     0,     0,     0,     0,     0,     0,    19,     0,
       0,     0,     0,   101,   103,   102,     0,   104,   100,     0,
       0,     0,     0,     0,     0,     0,   109,    46,    80,    81,
      85,    92,    95,   110,    47,    49,    50,    48,    42,    39,
      35,     0,     0,     0,     0,     0,     0,     0,    56,    57,
      59,    60,    58,    41,    44,     8,     0,     0,    12,     0,
      14,     0,    63,   112,   114,     0,    84,   111,   113,   108,
     107,   105,   106,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    36,    51,    52,    54,
      55,    53,    40,     0,   117,    11,    18,     0,    13,    18,
      99,     0,    61,     0,    82,    83,    89,    88,    90,    91,
      87,    86,    93,    94,    96,    97,    98,     9,     0,     0,
       0,     0,     0,     0,     0,   104,     0,   127,   119,     0,
     109,     0,    79,     0,   117,   123,   118,   124,   120,   121,
      15,    33,     0,    18,    17,   139,    63,    37,     0,   125,
     126,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     105,     0,     0,     0,     0,     0,   122,   115,   116,    34,
      16,    62,   128,     0,     0,     0,     0,    64,    65,    67,
      68,    66,     0,     0,     0,     0,     0,    74,    75,    77,
      78,    76,     0,     0,     0,     0,    69,    70,    72,    73,
      71,     0,   130,   129,     0,   138,   138,     0,     0,     0,
     135,   134,     0,   131,   136,   137,     0,   133,   132
};

  /* YYPGOTO[NTERM-NUM].  */
static const yytype_int16 yypgoto[] =
{
    -213,   140,  -213,  -213,  -213,  -119,    87,    13,  -213,  -213,
    -213,  -129,    -9,  -213,    81,  -184,   -34,  -213,   -41,   127,
      51,   -48,  -144,    96,  -212,  -213,  -213,  -213,  -213,  -213,
      26,  -213
};

  /* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int16 yydefgoto[] =
{
      -1,    11,    12,    13,    14,    51,   168,   169,    17,   100,
      25,    66,    26,    27,   141,   171,   142,    68,    69,    70,
      71,    72,   135,   173,   174,   175,   176,   177,   178,   179,
     250,    73
};

  /* YYTABLE[YYPACT[STATE-NUM]] -- What to do in state STATE-NUM.  If
     positive, shift that token.  If negative, reduce the rule whose
     number is the opposite.  If YYTABLE_NINF, syntax error.  */
static const yytype_uint16 yytable[] =
{
      67,    74,    75,    76,    77,   170,    81,   213,    88,    89,
      90,    91,    92,    16,   109,   110,    18,   180,   106,   193,
     184,   243,   101,   246,   102,    19,    16,    16,    16,    32,
      79,     1,     2,     3,     4,    95,    23,   255,    93,    41,
      94,   103,   104,    96,   258,   170,    52,    48,   127,   128,
     129,   130,   131,     5,     6,     7,     8,     9,   126,    78,
     105,    24,   170,   252,   210,    34,    35,    36,    37,    38,
      50,   143,   144,   145,    98,   154,   155,   156,   132,    28,
      29,    30,    31,    10,    24,    49,   172,    15,    97,   242,
      39,   245,    40,   107,    42,    43,    44,    45,    46,    99,
      15,    15,    15,   182,   170,   254,   170,   113,   114,    53,
      54,    55,   257,    56,   136,    57,   137,   108,   170,    47,
     170,    58,   111,    33,   188,   140,   172,   170,   112,    59,
      60,    61,    34,    35,    36,    37,    38,   133,    62,    63,
      64,   121,   122,   172,    65,   123,   124,   125,   138,    52,
      80,   139,    52,    20,    21,    22,   157,    39,   214,    40,
     216,   217,   218,   219,   220,   221,   102,   227,   228,   229,
     230,   231,   152,   153,   134,   195,   196,   197,   198,   199,
     185,   183,   186,   103,   104,   172,   187,   172,   236,   237,
     238,   239,   240,   189,   190,   191,    52,   192,   241,   172,
     244,   172,   105,   158,     1,     2,     3,     4,   172,   159,
     160,   194,   200,   206,   161,   162,   163,   164,   209,    53,
      54,    55,   207,    56,   212,   165,     5,     6,     7,     8,
       9,    58,   215,   232,    82,    83,    84,    85,    86,   233,
      60,    61,   146,   147,   148,   149,   150,   151,    62,    63,
     166,   234,   247,   235,    65,   248,   249,   253,   167,    87,
     256,   134,   158,     1,     2,     3,     4,   211,   159,   160,
     208,     0,   251,   161,   162,   163,   164,     0,    53,    54,
      55,     0,    56,     0,   165,     5,     6,     7,     8,     9,
      58,   115,   116,   117,   118,   119,   120,     0,     0,    60,
      61,     1,     2,     3,     4,     0,     0,    62,    63,   166,
      53,    54,    55,    65,    56,     0,    57,   167,     0,     0,
       0,     0,    58,     5,     6,     7,     8,     9,     0,     0,
      59,    60,    61,   201,   202,   203,   204,   205,     0,    62,
      63,    64,    53,    54,    55,    65,    56,     0,    57,     0,
       0,   181,     0,     0,    58,     0,   222,   223,   224,   225,
     226,     0,    59,    60,    61,     0,     0,     0,     0,     0,
       0,    62,    63,    64,    53,    54,    55,    65,    56,     0,
      57,     0,     0,     0,     0,     0,    58,     0,     0,     0,
       0,     0,     0,     0,     0,    60,    61,     0,     0,     0,
       0,     0,     0,    62,    63,    64,    53,    54,    55,    65,
      56,     0,   165,     0,     0,     0,     0,     0,    58,     0,
       0,     0,     0,     0,     0,     0,     0,    60,    61,     0,
       0,     0,     0,     0,     0,    62,    63,   166,     0,     0,
       0,    65
};

static const yytype_int16 yycheck[] =
{
      34,    35,    36,    37,    38,   134,    40,   191,    42,    43,
      44,    45,    46,     0,    62,    63,    22,   136,    59,   163,
     139,   233,    56,   235,    23,     0,    13,    14,    15,    46,
      39,     4,     5,     6,     7,    47,    25,   249,    47,    25,
      49,    40,    41,    55,   256,   174,    33,    58,    82,    83,
      84,    85,    86,    26,    27,    28,    29,    30,    60,    25,
      59,    50,   191,   247,   183,    32,    33,    34,    35,    36,
      25,   105,   113,   114,    25,   123,   124,   125,    87,    26,
      27,    28,    29,    56,    50,    57,   134,     0,    24,   233,
      57,   235,    59,    25,    32,    33,    34,    35,    36,    50,
      13,    14,    15,   137,   233,   249,   235,    37,    38,    19,
      20,    21,   256,    23,    57,    25,    59,    25,   247,    57,
     249,    31,    25,    23,   158,    24,   174,   256,    25,    39,
      40,    41,    32,    33,    34,    35,    36,    25,    48,    49,
      50,    48,    49,   191,    54,    50,    51,    52,    25,   136,
      60,    57,   139,    13,    14,    15,    47,    57,   192,    59,
     194,   195,   196,   197,   198,   199,    23,   201,   202,   203,
     204,   205,   121,   122,    61,    32,    33,    34,    35,    36,
      24,    57,    57,    40,    41,   233,    60,   235,   222,   223,
     224,   225,   226,    58,    58,    23,   183,    23,   232,   247,
     234,   249,    59,     3,     4,     5,     6,     7,   256,     9,
      10,    23,    25,    58,    14,    15,    16,    17,    60,    19,
      20,    21,    62,    23,    58,    25,    26,    27,    28,    29,
      30,    31,    15,    58,    32,    33,    34,    35,    36,    24,
      40,    41,   115,   116,   117,   118,   119,   120,    48,    49,
      50,    23,    58,    24,    54,    24,    18,    58,    58,    57,
      24,    61,     3,     4,     5,     6,     7,   186,     9,    10,
     174,    -1,   246,    14,    15,    16,    17,    -1,    19,    20,
      21,    -1,    23,    -1,    25,    26,    27,    28,    29,    30,
      31,    42,    43,    44,    45,    46,    47,    -1,    -1,    40,
      41,     4,     5,     6,     7,    -1,    -1,    48,    49,    50,
      19,    20,    21,    54,    23,    -1,    25,    58,    -1,    -1,
      -1,    -1,    31,    26,    27,    28,    29,    30,    -1,    -1,
      39,    40,    41,    32,    33,    34,    35,    36,    -1,    48,
      49,    50,    19,    20,    21,    54,    23,    -1,    25,    -1,
      -1,    60,    -1,    -1,    31,    -1,    32,    33,    34,    35,
      36,    -1,    39,    40,    41,    -1,    -1,    -1,    -1,    -1,
      -1,    48,    49,    50,    19,    20,    21,    54,    23,    -1,
      25,    -1,    -1,    -1,    -1,    -1,    31,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    40,    41,    -1,    -1,    -1,
      -1,    -1,    -1,    48,    49,    50,    19,    20,    21,    54,
      23,    -1,    25,    -1,    -1,    -1,    -1,    -1,    31,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    40,    41,    -1,
      -1,    -1,    -1,    -1,    -1,    48,    49,    50,    -1,    -1,
      -1,    54
};

  /* YYSTOS[STATE-NUM] -- The (internal number of the) accessing
     symbol of state STATE-NUM.  */
static const yytype_uint8 yystos[] =
{
       0,     4,     5,     6,     7,    26,    27,    28,    29,    30,
      56,    64,    65,    66,    67,    69,    70,    71,    22,     0,
      64,    64,    64,    25,    50,    73,    75,    76,    26,    27,
      28,    29,    46,    23,    32,    33,    34,    35,    36,    57,
      59,    25,    32,    33,    34,    35,    36,    57,    58,    57,
      25,    68,    70,    19,    20,    21,    23,    25,    31,    39,
      40,    41,    48,    49,    50,    54,    74,    79,    80,    81,
      82,    83,    84,    94,    79,    79,    79,    79,    25,    75,
      60,    79,    32,    33,    34,    35,    36,    57,    79,    79,
      79,    79,    79,    75,    75,    47,    55,    24,    25,    50,
      72,    79,    23,    40,    41,    59,    81,    25,    25,    84,
      84,    25,    25,    37,    38,    42,    43,    44,    45,    46,
      47,    48,    49,    50,    51,    52,    60,    79,    79,    79,
      79,    79,    75,    25,    61,    85,    57,    59,    25,    57,
      24,    77,    79,    79,    81,    81,    82,    82,    82,    82,
      82,    82,    83,    83,    84,    84,    84,    47,     3,     9,
      10,    14,    15,    16,    17,    25,    50,    58,    69,    70,
      74,    78,    84,    86,    87,    88,    89,    90,    91,    92,
      68,    60,    79,    57,    68,    24,    57,    60,    79,    58,
      58,    23,    23,    85,    23,    32,    33,    34,    35,    36,
      25,    32,    33,    34,    35,    36,    58,    62,    86,    60,
      68,    77,    58,    78,    79,    15,    79,    79,    79,    79,
      79,    79,    32,    33,    34,    35,    36,    79,    79,    79,
      79,    79,    58,    24,    23,    24,    79,    79,    79,    79,
      79,    79,    85,    87,    79,    85,    87,    58,    24,    18,
      93,    93,    78,    58,    85,    87,    24,    85,    87
};

  /* YYR1[YYN] -- Symbol number of symbol that rule YYN derives.  */
static const yytype_uint8 yyr1[] =
{
       0,    63,    64,    64,    64,    64,    64,    64,    65,    65,
      66,    67,    68,    68,    68,    68,    68,    68,    68,    69,
      70,    70,    70,    70,    70,    70,    70,    70,    70,    71,
      71,    71,    71,    72,    72,    73,    73,    74,    75,    75,
      75,    75,    75,    75,    75,    75,    76,    76,    76,    76,
      76,    76,    76,    76,    76,    76,    76,    76,    76,    76,
      76,    77,    77,    77,    78,    78,    78,    78,    78,    78,
      78,    78,    78,    78,    78,    78,    78,    78,    78,    78,
      79,    80,    80,    80,    80,    81,    81,    81,    81,    81,
      81,    81,    82,    82,    82,    83,    83,    83,    83,    84,
      84,    84,    84,    84,    84,    84,    84,    84,    84,    84,
      84,    84,    84,    84,    84,    85,    86,    86,    87,    87,
      87,    87,    87,    87,    87,    87,    87,    87,    88,    89,
      89,    90,    91,    91,    92,    92,    93,    93,    93,    94
};

  /* YYR2[YYN] -- Number of symbols on the right hand side of rule YYN.  */
static const yytype_uint8 yyr2[] =
{
       0,     2,     1,     1,     1,     2,     2,     2,     5,     7,
       1,     6,     2,     3,     2,     4,     5,     4,     0,     3,
       1,     1,     1,     1,     1,     2,     2,     2,     2,     1,
       1,     1,     1,     3,     4,     3,     4,     4,     1,     3,
       4,     3,     1,     2,     3,     1,     3,     3,     3,     3,
       3,     4,     4,     4,     4,     4,     3,     3,     3,     3,
       3,     1,     3,     0,     3,     3,     3,     3,     3,     4,
       4,     4,     4,     4,     3,     3,     3,     3,     3,     1,
       1,     1,     3,     3,     2,     1,     3,     3,     3,     3,
       3,     3,     1,     3,     3,     1,     3,     3,     3,     3,
       1,     1,     1,     1,     1,     2,     2,     2,     2,     1,
       1,     2,     2,     2,     2,     3,     2,     0,     1,     1,
       1,     1,     2,     1,     1,     2,     2,     1,     3,     5,
       5,     7,     9,     9,     6,     6,     2,     2,     0,     4
};


#define yyerrok         (yyerrstatus = 0)
#define yyclearin       (yychar = YYEMPTY)
#define YYEMPTY         (-2)
#define YYEOF           0

#define YYACCEPT        goto yyacceptlab
#define YYABORT         goto yyabortlab
#define YYERROR         goto yyerrorlab


#define YYRECOVERING()  (!!yyerrstatus)

#define YYBACKUP(Token, Value)                                  \
do                                                              \
  if (yychar == YYEMPTY)                                        \
    {                                                           \
      yychar = (Token);                                         \
      yylval = (Value);                                         \
      YYPOPSTACK (yylen);                                       \
      yystate = *yyssp;                                         \
      goto yybackup;                                            \
    }                                                           \
  else                                                          \
    {                                                           \
      yyerror (YY_("syntax error: cannot back up")); \
      YYERROR;                                                  \
    }                                                           \
while (0)

/* Error token number */
#define YYTERROR        1
#define YYERRCODE       256



/* Enable debugging if requested.  */
#if YYDEBUG

# ifndef YYFPRINTF
#  include <stdio.h> /* INFRINGES ON USER NAME SPACE */
#  define YYFPRINTF fprintf
# endif

# define YYDPRINTF(Args)                        \
do {                                            \
  if (yydebug)                                  \
    YYFPRINTF Args;                             \
} while (0)

/* This macro is provided for backward compatibility. */
#ifndef YY_LOCATION_PRINT
# define YY_LOCATION_PRINT(File, Loc) ((void) 0)
#endif


# define YY_SYMBOL_PRINT(Title, Type, Value, Location)                    \
do {                                                                      \
  if (yydebug)                                                            \
    {                                                                     \
      YYFPRINTF (stderr, "%s ", Title);                                   \
      yy_symbol_print (stderr,                                            \
                  Type, Value); \
      YYFPRINTF (stderr, "\n");                                           \
    }                                                                     \
} while (0)


/*----------------------------------------.
| Print this symbol's value on YYOUTPUT.  |
`----------------------------------------*/

static void
yy_symbol_value_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep)
{
  FILE *yyo = yyoutput;
  YYUSE (yyo);
  if (!yyvaluep)
    return;
# ifdef YYPRINT
  if (yytype < YYNTOKENS)
    YYPRINT (yyoutput, yytoknum[yytype], *yyvaluep);
# endif
  YYUSE (yytype);
}


/*--------------------------------.
| Print this symbol on YYOUTPUT.  |
`--------------------------------*/

static void
yy_symbol_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep)
{
  YYFPRINTF (yyoutput, "%s %s (",
             yytype < YYNTOKENS ? "token" : "nterm", yytname[yytype]);

  yy_symbol_value_print (yyoutput, yytype, yyvaluep);
  YYFPRINTF (yyoutput, ")");
}

/*------------------------------------------------------------------.
| yy_stack_print -- Print the state stack from its BOTTOM up to its |
| TOP (included).                                                   |
`------------------------------------------------------------------*/

static void
yy_stack_print (yytype_int16 *yybottom, yytype_int16 *yytop)
{
  YYFPRINTF (stderr, "Stack now");
  for (; yybottom <= yytop; yybottom++)
    {
      int yybot = *yybottom;
      YYFPRINTF (stderr, " %d", yybot);
    }
  YYFPRINTF (stderr, "\n");
}

# define YY_STACK_PRINT(Bottom, Top)                            \
do {                                                            \
  if (yydebug)                                                  \
    yy_stack_print ((Bottom), (Top));                           \
} while (0)


/*------------------------------------------------.
| Report that the YYRULE is going to be reduced.  |
`------------------------------------------------*/

static void
yy_reduce_print (yytype_int16 *yyssp, YYSTYPE *yyvsp, int yyrule)
{
  unsigned long int yylno = yyrline[yyrule];
  int yynrhs = yyr2[yyrule];
  int yyi;
  YYFPRINTF (stderr, "Reducing stack by rule %d (line %lu):\n",
             yyrule - 1, yylno);
  /* The symbols being reduced.  */
  for (yyi = 0; yyi < yynrhs; yyi++)
    {
      YYFPRINTF (stderr, "   $%d = ", yyi + 1);
      yy_symbol_print (stderr,
                       yystos[yyssp[yyi + 1 - yynrhs]],
                       &(yyvsp[(yyi + 1) - (yynrhs)])
                                              );
      YYFPRINTF (stderr, "\n");
    }
}

# define YY_REDUCE_PRINT(Rule)          \
do {                                    \
  if (yydebug)                          \
    yy_reduce_print (yyssp, yyvsp, Rule); \
} while (0)

/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args)
# define YY_SYMBOL_PRINT(Title, Type, Value, Location)
# define YY_STACK_PRINT(Bottom, Top)
# define YY_REDUCE_PRINT(Rule)
#endif /* !YYDEBUG */


/* YYINITDEPTH -- initial size of the parser's stacks.  */
#ifndef YYINITDEPTH
# define YYINITDEPTH 200
#endif

/* YYMAXDEPTH -- maximum size the stacks can grow to (effective only
   if the built-in stack extension method is used).

   Do not make this value too large; the results are undefined if
   YYSTACK_ALLOC_MAXIMUM < YYSTACK_BYTES (YYMAXDEPTH)
   evaluated with infinite-precision integer arithmetic.  */

#ifndef YYMAXDEPTH
# define YYMAXDEPTH 10000
#endif


#if YYERROR_VERBOSE

# ifndef yystrlen
#  if defined __GLIBC__ && defined _STRING_H
#   define yystrlen strlen
#  else
/* Return the length of YYSTR.  */
static YYSIZE_T
yystrlen (const char *yystr)
{
  YYSIZE_T yylen;
  for (yylen = 0; yystr[yylen]; yylen++)
    continue;
  return yylen;
}
#  endif
# endif

# ifndef yystpcpy
#  if defined __GLIBC__ && defined _STRING_H && defined _GNU_SOURCE
#   define yystpcpy stpcpy
#  else
/* Copy YYSRC to YYDEST, returning the address of the terminating '\0' in
   YYDEST.  */
static char *
yystpcpy (char *yydest, const char *yysrc)
{
  char *yyd = yydest;
  const char *yys = yysrc;

  while ((*yyd++ = *yys++) != '\0')
    continue;

  return yyd - 1;
}
#  endif
# endif

# ifndef yytnamerr
/* Copy to YYRES the contents of YYSTR after stripping away unnecessary
   quotes and backslashes, so that it's suitable for yyerror.  The
   heuristic is that double-quoting is unnecessary unless the string
   contains an apostrophe, a comma, or backslash (other than
   backslash-backslash).  YYSTR is taken from yytname.  If YYRES is
   null, do not copy; instead, return the length of what the result
   would have been.  */
static YYSIZE_T
yytnamerr (char *yyres, const char *yystr)
{
  if (*yystr == '"')
    {
      YYSIZE_T yyn = 0;
      char const *yyp = yystr;

      for (;;)
        switch (*++yyp)
          {
          case '\'':
          case ',':
            goto do_not_strip_quotes;

          case '\\':
            if (*++yyp != '\\')
              goto do_not_strip_quotes;
            /* Fall through.  */
          default:
            if (yyres)
              yyres[yyn] = *yyp;
            yyn++;
            break;

          case '"':
            if (yyres)
              yyres[yyn] = '\0';
            return yyn;
          }
    do_not_strip_quotes: ;
    }

  if (! yyres)
    return yystrlen (yystr);

  return yystpcpy (yyres, yystr) - yyres;
}
# endif

/* Copy into *YYMSG, which is of size *YYMSG_ALLOC, an error message
   about the unexpected token YYTOKEN for the state stack whose top is
   YYSSP.

   Return 0 if *YYMSG was successfully written.  Return 1 if *YYMSG is
   not large enough to hold the message.  In that case, also set
   *YYMSG_ALLOC to the required number of bytes.  Return 2 if the
   required number of bytes is too large to store.  */
static int
yysyntax_error (YYSIZE_T *yymsg_alloc, char **yymsg,
                yytype_int16 *yyssp, int yytoken)
{
  YYSIZE_T yysize0 = yytnamerr (YY_NULLPTR, yytname[yytoken]);
  YYSIZE_T yysize = yysize0;
  enum { YYERROR_VERBOSE_ARGS_MAXIMUM = 5 };
  /* Internationalized format string. */
  const char *yyformat = YY_NULLPTR;
  /* Arguments of yyformat. */
  char const *yyarg[YYERROR_VERBOSE_ARGS_MAXIMUM];
  /* Number of reported tokens (one for the "unexpected", one per
     "expected"). */
  int yycount = 0;

  /* There are many possibilities here to consider:
     - If this state is a consistent state with a default action, then
       the only way this function was invoked is if the default action
       is an error action.  In that case, don't check for expected
       tokens because there are none.
     - The only way there can be no lookahead present (in yychar) is if
       this state is a consistent state with a default action.  Thus,
       detecting the absence of a lookahead is sufficient to determine
       that there is no unexpected or expected token to report.  In that
       case, just report a simple "syntax error".
     - Don't assume there isn't a lookahead just because this state is a
       consistent state with a default action.  There might have been a
       previous inconsistent state, consistent state with a non-default
       action, or user semantic action that manipulated yychar.
     - Of course, the expected token list depends on states to have
       correct lookahead information, and it depends on the parser not
       to perform extra reductions after fetching a lookahead from the
       scanner and before detecting a syntax error.  Thus, state merging
       (from LALR or IELR) and default reductions corrupt the expected
       token list.  However, the list is correct for canonical LR with
       one exception: it will still contain any token that will not be
       accepted due to an error action in a later state.
  */
  if (yytoken != YYEMPTY)
    {
      int yyn = yypact[*yyssp];
      yyarg[yycount++] = yytname[yytoken];
      if (!yypact_value_is_default (yyn))
        {
          /* Start YYX at -YYN if negative to avoid negative indexes in
             YYCHECK.  In other words, skip the first -YYN actions for
             this state because they are default actions.  */
          int yyxbegin = yyn < 0 ? -yyn : 0;
          /* Stay within bounds of both yycheck and yytname.  */
          int yychecklim = YYLAST - yyn + 1;
          int yyxend = yychecklim < YYNTOKENS ? yychecklim : YYNTOKENS;
          int yyx;

          for (yyx = yyxbegin; yyx < yyxend; ++yyx)
            if (yycheck[yyx + yyn] == yyx && yyx != YYTERROR
                && !yytable_value_is_error (yytable[yyx + yyn]))
              {
                if (yycount == YYERROR_VERBOSE_ARGS_MAXIMUM)
                  {
                    yycount = 1;
                    yysize = yysize0;
                    break;
                  }
                yyarg[yycount++] = yytname[yyx];
                {
                  YYSIZE_T yysize1 = yysize + yytnamerr (YY_NULLPTR, yytname[yyx]);
                  if (! (yysize <= yysize1
                         && yysize1 <= YYSTACK_ALLOC_MAXIMUM))
                    return 2;
                  yysize = yysize1;
                }
              }
        }
    }

  switch (yycount)
    {
# define YYCASE_(N, S)                      \
      case N:                               \
        yyformat = S;                       \
      break
      YYCASE_(0, YY_("syntax error"));
      YYCASE_(1, YY_("syntax error, unexpected %s"));
      YYCASE_(2, YY_("syntax error, unexpected %s, expecting %s"));
      YYCASE_(3, YY_("syntax error, unexpected %s, expecting %s or %s"));
      YYCASE_(4, YY_("syntax error, unexpected %s, expecting %s or %s or %s"));
      YYCASE_(5, YY_("syntax error, unexpected %s, expecting %s or %s or %s or %s"));
# undef YYCASE_
    }

  {
    YYSIZE_T yysize1 = yysize + yystrlen (yyformat);
    if (! (yysize <= yysize1 && yysize1 <= YYSTACK_ALLOC_MAXIMUM))
      return 2;
    yysize = yysize1;
  }

  if (*yymsg_alloc < yysize)
    {
      *yymsg_alloc = 2 * yysize;
      if (! (yysize <= *yymsg_alloc
             && *yymsg_alloc <= YYSTACK_ALLOC_MAXIMUM))
        *yymsg_alloc = YYSTACK_ALLOC_MAXIMUM;
      return 1;
    }

  /* Avoid sprintf, as that infringes on the user's name space.
     Don't have undefined behavior even if the translation
     produced a string with the wrong number of "%s"s.  */
  {
    char *yyp = *yymsg;
    int yyi = 0;
    while ((*yyp = *yyformat) != '\0')
      if (*yyp == '%' && yyformat[1] == 's' && yyi < yycount)
        {
          yyp += yytnamerr (yyp, yyarg[yyi++]);
          yyformat += 2;
        }
      else
        {
          yyp++;
          yyformat++;
        }
  }
  return 0;
}
#endif /* YYERROR_VERBOSE */

/*-----------------------------------------------.
| Release the memory associated to this symbol.  |
`-----------------------------------------------*/

static void
yydestruct (const char *yymsg, int yytype, YYSTYPE *yyvaluep)
{
  YYUSE (yyvaluep);
  if (!yymsg)
    yymsg = "Deleting";
  YY_SYMBOL_PRINT (yymsg, yytype, yyvaluep, yylocationp);

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  YYUSE (yytype);
  YY_IGNORE_MAYBE_UNINITIALIZED_END
}




/* The lookahead symbol.  */
int yychar;

/* The semantic value of the lookahead symbol.  */
YYSTYPE yylval;
/* Number of syntax errors so far.  */
int yynerrs;


/*----------.
| yyparse.  |
`----------*/

int
yyparse (void)
{
    int yystate;
    /* Number of tokens to shift before error messages enabled.  */
    int yyerrstatus;

    /* The stacks and their tools:
       'yyss': related to states.
       'yyvs': related to semantic values.

       Refer to the stacks through separate pointers, to allow yyoverflow
       to reallocate them elsewhere.  */

    /* The state stack.  */
    yytype_int16 yyssa[YYINITDEPTH];
    yytype_int16 *yyss;
    yytype_int16 *yyssp;

    /* The semantic value stack.  */
    YYSTYPE yyvsa[YYINITDEPTH];
    YYSTYPE *yyvs;
    YYSTYPE *yyvsp;

    YYSIZE_T yystacksize;

  int yyn;
  int yyresult;
  /* Lookahead token as an internal (translated) token number.  */
  int yytoken = 0;
  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;

#if YYERROR_VERBOSE
  /* Buffer for error messages, and its allocated size.  */
  char yymsgbuf[128];
  char *yymsg = yymsgbuf;
  YYSIZE_T yymsg_alloc = sizeof yymsgbuf;
#endif

#define YYPOPSTACK(N)   (yyvsp -= (N), yyssp -= (N))

  /* The number of symbols on the RHS of the reduced rule.
     Keep to zero when no symbol should be popped.  */
  int yylen = 0;

  yyssp = yyss = yyssa;
  yyvsp = yyvs = yyvsa;
  yystacksize = YYINITDEPTH;

  YYDPRINTF ((stderr, "Starting parse\n"));

  yystate = 0;
  yyerrstatus = 0;
  yynerrs = 0;
  yychar = YYEMPTY; /* Cause a token to be read.  */
  goto yysetstate;

/*------------------------------------------------------------.
| yynewstate -- Push a new state, which is found in yystate.  |
`------------------------------------------------------------*/
 yynewstate:
  /* In all cases, when you get here, the value and location stacks
     have just been pushed.  So pushing a state here evens the stacks.  */
  yyssp++;

 yysetstate:
  *yyssp = yystate;

  if (yyss + yystacksize - 1 <= yyssp)
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYSIZE_T yysize = yyssp - yyss + 1;

#ifdef yyoverflow
      {
        /* Give user a chance to reallocate the stack.  Use copies of
           these so that the &'s don't force the real ones into
           memory.  */
        YYSTYPE *yyvs1 = yyvs;
        yytype_int16 *yyss1 = yyss;

        /* Each stack pointer address is followed by the size of the
           data in use in that stack, in bytes.  This used to be a
           conditional around just the two extra args, but that might
           be undefined if yyoverflow is a macro.  */
        yyoverflow (YY_("memory exhausted"),
                    &yyss1, yysize * sizeof (*yyssp),
                    &yyvs1, yysize * sizeof (*yyvsp),
                    &yystacksize);

        yyss = yyss1;
        yyvs = yyvs1;
      }
#else /* no yyoverflow */
# ifndef YYSTACK_RELOCATE
      goto yyexhaustedlab;
# else
      /* Extend the stack our own way.  */
      if (YYMAXDEPTH <= yystacksize)
        goto yyexhaustedlab;
      yystacksize *= 2;
      if (YYMAXDEPTH < yystacksize)
        yystacksize = YYMAXDEPTH;

      {
        yytype_int16 *yyss1 = yyss;
        union yyalloc *yyptr =
          (union yyalloc *) YYSTACK_ALLOC (YYSTACK_BYTES (yystacksize));
        if (! yyptr)
          goto yyexhaustedlab;
        YYSTACK_RELOCATE (yyss_alloc, yyss);
        YYSTACK_RELOCATE (yyvs_alloc, yyvs);
#  undef YYSTACK_RELOCATE
        if (yyss1 != yyssa)
          YYSTACK_FREE (yyss1);
      }
# endif
#endif /* no yyoverflow */

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;

      YYDPRINTF ((stderr, "Stack size increased to %lu\n",
                  (unsigned long int) yystacksize));

      if (yyss + yystacksize - 1 <= yyssp)
        YYABORT;
    }

  YYDPRINTF ((stderr, "Entering state %d\n", yystate));

  if (yystate == YYFINAL)
    YYACCEPT;

  goto yybackup;

/*-----------.
| yybackup.  |
`-----------*/
yybackup:

  /* Do appropriate processing given the current state.  Read a
     lookahead token if we need one and don't already have one.  */

  /* First try to decide what to do without reference to lookahead token.  */
  yyn = yypact[yystate];
  if (yypact_value_is_default (yyn))
    goto yydefault;

  /* Not known => get a lookahead token if don't already have one.  */

  /* YYCHAR is either YYEMPTY or YYEOF or a valid lookahead symbol.  */
  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token: "));
      yychar = yylex ();
    }

  if (yychar <= YYEOF)
    {
      yychar = yytoken = YYEOF;
      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else
    {
      yytoken = YYTRANSLATE (yychar);
      YY_SYMBOL_PRINT ("Next token is", yytoken, &yylval, &yylloc);
    }

  /* If the proper action on seeing token YYTOKEN is to reduce or to
     detect an error, take that action.  */
  yyn += yytoken;
  if (yyn < 0 || YYLAST < yyn || yycheck[yyn] != yytoken)
    goto yydefault;
  yyn = yytable[yyn];
  if (yyn <= 0)
    {
      if (yytable_value_is_error (yyn))
        goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }

  /* Count tokens shifted since error; after three, turn off error
     status.  */
  if (yyerrstatus)
    yyerrstatus--;

  /* Shift the lookahead token.  */
  YY_SYMBOL_PRINT ("Shifting", yytoken, &yylval, &yylloc);

  /* Discard the shifted token.  */
  yychar = YYEMPTY;

  yystate = yyn;
  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END

  goto yynewstate;


/*-----------------------------------------------------------.
| yydefault -- do the default action for the current state.  |
`-----------------------------------------------------------*/
yydefault:
  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;
  goto yyreduce;


/*-----------------------------.
| yyreduce -- Do a reduction.  |
`-----------------------------*/
yyreduce:
  /* yyn is the number of a rule to reduce with.  */
  yylen = yyr2[yyn];

  /* If YYLEN is nonzero, implement the default value of the action:
     '$$ = $1'.

     Otherwise, the following line sets YYVAL to garbage.
     This behavior is undocumented and Bison
     users should not rely upon it.  Assigning to YYVAL
     unconditionally makes the parser a bit smaller, and it avoids a
     GCC warning that YYVAL may be used uninitialized.  */
  yyval = yyvsp[1-yylen];


  YY_REDUCE_PRINT (yyn);
  switch (yyn)
    {
        case 11:
#line 252 "miniC.y" /* yacc.c:1646  */
    {
                                                                                        if(strcmp(returnType,(yyvsp[-5].id))!=0)
                                                                                                printRetTypeError(lineNo, returnType, (yyvsp[-5].id), (yyvsp[-4].id));
                                                                                        else if(strcmp((yyvsp[-5].id),"void")==0 && strcmp(returnType,"void")!=0)
                                                                                                printVoidFunctionReturningError(lineNo, returnType);
                                                                                        else{
                                                                                                strcpy(returnType, "");
                                                                                                insertFunctionItem((yyvsp[-4].id),(yyvsp[-5].id),lineNo,curScope,0,pList, pCount);
                                                                                                strcpy(pList, "");
                                                                                                pCount = 0;
                                                                                        }
                                                                                        strcpy(returnType, "void");
                                                                                }
#line 1727 "y.tab.c" /* yacc.c:1646  */
    break;

  case 12:
#line 266 "miniC.y" /* yacc.c:1646  */
    {       
                                                                        pCount++;
                                                                        char temp[100];
                                                                        strcpy(temp, (yyvsp[-1].id));
                                                                        insertSymbolItem((yyvsp[0].id),temp,lineNo,nextNum + 1,0);
                                                                        strcat(pList,strcat(temp," "));
                                                                        strcpy(temp, (yyvsp[0].id));
                                                                        strcat(pList,strcat(temp,", "));                                                                       
                                                                }
#line 1741 "y.tab.c" /* yacc.c:1646  */
    break;

  case 13:
#line 275 "miniC.y" /* yacc.c:1646  */
    {
                                                                        pCount++;
                                                                        char temp[100];
                                                                        strcpy(temp, (yyvsp[-2].id));
                                                                        insertSymbolItem((yyvsp[0].id),temp,lineNo,nextNum + 1,0);
                                                                        strcat(pList,strcat(temp," "));
                                                                        strcpy(temp, (yyvsp[0].id));
                                                                        strcat(pList,strcat(temp,", "));
                                                                        
                                                                }
#line 1756 "y.tab.c" /* yacc.c:1646  */
    break;

  case 14:
#line 285 "miniC.y" /* yacc.c:1646  */
    {DEBUGY_PRINT("FLIST Call 3\n");}
#line 1762 "y.tab.c" /* yacc.c:1646  */
    break;

  case 15:
#line 286 "miniC.y" /* yacc.c:1646  */
    {       
                                                                        pCount++;
                                                                        char temp[100];
                                                                        strcpy(temp, (yyvsp[-3].id));
                                                                        insertSymbolItem((yyvsp[-2].id),temp,lineNo,nextNum + 1,0);
                                                                        strcat(pList,strcat(temp," "));
                                                                        strcpy(temp, (yyvsp[-2].id));
                                                                        strcat(pList,strcat(temp,", "));
                                                                        
                                                                }
#line 1777 "y.tab.c" /* yacc.c:1646  */
    break;

  case 16:
#line 296 "miniC.y" /* yacc.c:1646  */
    {
                                                                        pCount++;
                                                                        char temp[100];
                                                                        strcpy(temp, (yyvsp[-4].id));
                                                                        insertSymbolItem((yyvsp[-2].id),temp,lineNo,nextNum + 1,0);
                                                                        strcat(pList,strcat(temp," "));
                                                                        strcpy(temp, (yyvsp[-2].id));
                                                                        strcat(pList,strcat(temp,", "));
                                                                }
#line 1791 "y.tab.c" /* yacc.c:1646  */
    break;

  case 17:
#line 305 "miniC.y" /* yacc.c:1646  */
    {DEBUGY_PRINT("FLIST Call 6\n");}
#line 1797 "y.tab.c" /* yacc.c:1646  */
    break;

  case 19:
#line 310 "miniC.y" /* yacc.c:1646  */
    {if(strcmp((yyvsp[-2].id),"void")==0) printVoidVariableError(lineNo);}
#line 1803 "y.tab.c" /* yacc.c:1646  */
    break;

  case 20:
#line 313 "miniC.y" /* yacc.c:1646  */
    {strcpy(type,(yyvsp[0].id));strcpy((yyval.id),(yyvsp[0].id));}
#line 1809 "y.tab.c" /* yacc.c:1646  */
    break;

  case 21:
#line 313 "miniC.y" /* yacc.c:1646  */
    {strcpy(type,(yyvsp[0].id));strcpy((yyval.id),(yyvsp[0].id));}
#line 1815 "y.tab.c" /* yacc.c:1646  */
    break;

  case 22:
#line 313 "miniC.y" /* yacc.c:1646  */
    {strcpy(type,(yyvsp[0].id));strcpy((yyval.id),(yyvsp[0].id));}
#line 1821 "y.tab.c" /* yacc.c:1646  */
    break;

  case 23:
#line 313 "miniC.y" /* yacc.c:1646  */
    {strcpy(type,(yyvsp[0].id));strcpy((yyval.id),(yyvsp[0].id));}
#line 1827 "y.tab.c" /* yacc.c:1646  */
    break;

  case 24:
#line 313 "miniC.y" /* yacc.c:1646  */
    {strcpy(type,(yyvsp[0].id));strcpy((yyval.id),(yyvsp[0].id));}
#line 1833 "y.tab.c" /* yacc.c:1646  */
    break;

  case 25:
#line 314 "miniC.y" /* yacc.c:1646  */
    {strcpy(type,(yyvsp[0].id));}
#line 1839 "y.tab.c" /* yacc.c:1646  */
    break;

  case 26:
#line 314 "miniC.y" /* yacc.c:1646  */
    {strcpy(type,(yyvsp[0].id));}
#line 1845 "y.tab.c" /* yacc.c:1646  */
    break;

  case 27:
#line 314 "miniC.y" /* yacc.c:1646  */
    {strcpy(type,(yyvsp[0].id));}
#line 1851 "y.tab.c" /* yacc.c:1646  */
    break;

  case 28:
#line 314 "miniC.y" /* yacc.c:1646  */
    {strcpy(type,(yyvsp[0].id));}
#line 1857 "y.tab.c" /* yacc.c:1646  */
    break;

  case 33:
#line 319 "miniC.y" /* yacc.c:1646  */
    {
                                        pCount++;
                                        char temp[100];
                                        strcpy(temp, type);
                                        strcat(pList,strcat(temp," "));
                                        strcpy(temp, (yyvsp[-2].id));
                                        strcat(pList,strcat(temp,"[], "));
                                        insertArrayItem((yyvsp[-2].id),type,lineNo,nextNum + 1,0,0);
                                }
#line 1871 "y.tab.c" /* yacc.c:1646  */
    break;

  case 34:
#line 328 "miniC.y" /* yacc.c:1646  */
    {       if(num<=0)
                                                printIllArrayError(lineNo,(yyvsp[-3].id),num);
                                        else{
                                                pCount++;
                                                char temp[100];
                                                strcpy(temp, type);
                                                strcat(pList,strcat(temp," "));
                                                strcpy(temp, (yyvsp[-3].id));
                                                strcat(pList,strcat(temp,"[], "));
                                                insertArrayItem((yyvsp[-3].id),type,lineNo,nextNum + 1,0,num);
                                        }    
                                }
#line 1888 "y.tab.c" /* yacc.c:1646  */
    break;

  case 35:
#line 342 "miniC.y" /* yacc.c:1646  */
    {
                                if(lookUpSymbolItem_scope((yyvsp[-2].id), curScope))
                                        printReDecError(lineNo, (yyvsp[-2].id));
                                else{
                                        insertSymbolItem((yyvsp[-2].id),type,lineNo,curScope,0);
                                    }
                                }
#line 1900 "y.tab.c" /* yacc.c:1646  */
    break;

  case 36:
#line 349 "miniC.y" /* yacc.c:1646  */
    {
                                if(lookUpSymbolItem_scope((yyvsp[-3].id), curScope))
                                        printReDecError(lineNo, (yyvsp[-3].id));
                                else if(num<=0)
                                        printIllArrayError(lineNo,(yyvsp[-3].id),num);
                                else{
                                        insertArrayItem((yyvsp[-3].id),type,lineNo,curScope,0,num);
                                    }
                                }
#line 1914 "y.tab.c" /* yacc.c:1646  */
    break;

  case 37:
#line 359 "miniC.y" /* yacc.c:1646  */
    {if(!checkAncestors((yyvsp[-3].id)))
                                        printUndecVarErr(lineNo, (yyvsp[-3].id));
                                  else if(checkAncestors((yyvsp[-3].id))->arrayDim==-1)
                                        printWrongArrayUsageError(lineNo,(yyvsp[-3].id));
                                  else if(strcmp((yyvsp[-1].id),"int")!=0)
                                        printWrongArraySubscriptError(lineNo, (yyvsp[-3].id));
                                  else if(num<=0)
                                        printIllArrayError(lineNo,(yyvsp[-3].id),num);
                                  else{
                                        strcpy((yyval.id),checkAncestors((yyvsp[-3].id))->tokenType);
                                  }
                                }
#line 1931 "y.tab.c" /* yacc.c:1646  */
    break;

  case 39:
#line 375 "miniC.y" /* yacc.c:1646  */
    {
                                                if(lookUpSymbolItem_scope((yyvsp[-2].id), curScope))
                                                        printReDecError(lineNo, (yyvsp[-2].id));
                                                else
                                                        insertSymbolItem((yyvsp[-2].id),type,lineNo,curScope,0);
                                               }
#line 1942 "y.tab.c" /* yacc.c:1646  */
    break;

  case 40:
#line 381 "miniC.y" /* yacc.c:1646  */
    {
                                                if(lookUpSymbolItem_scope((yyvsp[-2].id), curScope))
                                                        printReDecError(lineNo, (yyvsp[-2].id));
                                                else
                                                        insertSymbolItem((yyvsp[-2].id),type,lineNo,curScope,0);
                                               }
#line 1953 "y.tab.c" /* yacc.c:1646  */
    break;

  case 42:
#line 388 "miniC.y" /* yacc.c:1646  */
    {
                                                if(lookUpSymbolItem_scope((yyvsp[0].id),curScope))
                                                        printReDecError(lineNo, (yyvsp[0].id));
                                                else
                                                        insertSymbolItem((yyvsp[0].id),type,lineNo,curScope,0);
                                               }
#line 1964 "y.tab.c" /* yacc.c:1646  */
    break;

  case 43:
#line 394 "miniC.y" /* yacc.c:1646  */
    {
                                                if(lookUpSymbolItem_scope((yyvsp[0].id),curScope))
                                                        printReDecError(lineNo, (yyvsp[0].id));
                                                else
                                                        insertSymbolItem((yyvsp[0].id),type,lineNo,curScope,0);
                                               }
#line 1975 "y.tab.c" /* yacc.c:1646  */
    break;

  case 46:
#line 404 "miniC.y" /* yacc.c:1646  */
    {
                                                if(lookUpSymbolItem_scope((yyvsp[-2].id),curScope))
                                                        printReDecError(lineNo, (yyvsp[-2].id));
                                                else
                                                        insertSymbolItem((yyvsp[-2].id),type,lineNo,curScope,0);
                                               }
#line 1986 "y.tab.c" /* yacc.c:1646  */
    break;

  case 47:
#line 410 "miniC.y" /* yacc.c:1646  */
    {
                                                if(lookUpSymbolItem_scope((yyvsp[-2].id),curScope))
                                                        printReDecError(lineNo, (yyvsp[-2].id));
                                                else
                                                        insertSymbolItem((yyvsp[-2].id),type,lineNo,curScope,0);
                                               }
#line 1997 "y.tab.c" /* yacc.c:1646  */
    break;

  case 48:
#line 416 "miniC.y" /* yacc.c:1646  */
    {
                                                if(lookUpSymbolItem_scope((yyvsp[-2].id),curScope))
                                                        printReDecError(lineNo, (yyvsp[-2].id));
                                                else
                                                        insertSymbolItem((yyvsp[-2].id),type,lineNo,curScope,0);
                                               }
#line 2008 "y.tab.c" /* yacc.c:1646  */
    break;

  case 49:
#line 422 "miniC.y" /* yacc.c:1646  */
    {
                                                if(lookUpSymbolItem_scope((yyvsp[-2].id),curScope))
                                                        printReDecError(lineNo, (yyvsp[-2].id));
                                                else
                                                        insertSymbolItem((yyvsp[-2].id),type,lineNo,curScope,0);
                                               }
#line 2019 "y.tab.c" /* yacc.c:1646  */
    break;

  case 50:
#line 428 "miniC.y" /* yacc.c:1646  */
    {
                                                if(lookUpSymbolItem_scope((yyvsp[-2].id),curScope))
                                                        printReDecError(lineNo, (yyvsp[-2].id));
                                                else
                                                        insertSymbolItem((yyvsp[-2].id),type,lineNo,curScope,0);
                                               }
#line 2030 "y.tab.c" /* yacc.c:1646  */
    break;

  case 51:
#line 434 "miniC.y" /* yacc.c:1646  */
    {
                                                if(lookUpSymbolItem_scope((yyvsp[-2].id),curScope))
                                                        printReDecError(lineNo, (yyvsp[-2].id));
                                                else
                                                        insertSymbolItem((yyvsp[-2].id),type,lineNo,curScope,0);
                                               }
#line 2041 "y.tab.c" /* yacc.c:1646  */
    break;

  case 52:
#line 440 "miniC.y" /* yacc.c:1646  */
    {
                                                if(lookUpSymbolItem_scope((yyvsp[-2].id),curScope))
                                                        printReDecError(lineNo, (yyvsp[-2].id));
                                                else
                                                        insertSymbolItem((yyvsp[-2].id),type,lineNo,curScope,0);
                                               }
#line 2052 "y.tab.c" /* yacc.c:1646  */
    break;

  case 53:
#line 446 "miniC.y" /* yacc.c:1646  */
    {
                                                if(lookUpSymbolItem_scope((yyvsp[-2].id),curScope))
                                                        printReDecError(lineNo, (yyvsp[-2].id));
                                                else
                                                        insertSymbolItem((yyvsp[-2].id),type,lineNo,curScope,0);
                                               }
#line 2063 "y.tab.c" /* yacc.c:1646  */
    break;

  case 54:
#line 452 "miniC.y" /* yacc.c:1646  */
    {
                                                if(lookUpSymbolItem_scope((yyvsp[-2].id),curScope))
                                                        printReDecError(lineNo, (yyvsp[-2].id));
                                                else
                                                        insertSymbolItem((yyvsp[-2].id),type,lineNo,curScope,0);
                                               }
#line 2074 "y.tab.c" /* yacc.c:1646  */
    break;

  case 55:
#line 458 "miniC.y" /* yacc.c:1646  */
    {
                                                if(lookUpSymbolItem_scope((yyvsp[-2].id),curScope))
                                                        printReDecError(lineNo, (yyvsp[-2].id));
                                                else
                                                        insertSymbolItem((yyvsp[-2].id),type,lineNo,curScope,0);
                                               }
#line 2085 "y.tab.c" /* yacc.c:1646  */
    break;

  case 61:
#line 472 "miniC.y" /* yacc.c:1646  */
    {addToParamList((yyvsp[0].id), pCount); pCount++; }
#line 2091 "y.tab.c" /* yacc.c:1646  */
    break;

  case 62:
#line 473 "miniC.y" /* yacc.c:1646  */
    {addToParamList((yyvsp[-2].id), pCount); pCount++; }
#line 2097 "y.tab.c" /* yacc.c:1646  */
    break;

  case 64:
#line 477 "miniC.y" /* yacc.c:1646  */
    {if(!checkAncestors((yyvsp[-2].id)))
                                                printUndecVarErr(lineNo, (yyvsp[-2].id));
                                           else if(strcmp(checkAncestors((yyvsp[-2].id))->tokenType,(yyvsp[0].id))!=0)
                                                  printMismatchError(lineNo,checkAncestors((yyvsp[-2].id))->tokenType,(yyvsp[0].id));
                                           else if(checkAncestors((yyvsp[-2].id))->arrayDim!=-1)
                                                printWrongIDUsageError(lineNo,(yyvsp[-2].id));
                                          }
#line 2109 "y.tab.c" /* yacc.c:1646  */
    break;

  case 65:
#line 484 "miniC.y" /* yacc.c:1646  */
    {if(!checkAncestors((yyvsp[-2].id)))
                                                printUndecVarErr(lineNo, (yyvsp[-2].id));
                                           else if(strcmp(checkAncestors((yyvsp[-2].id))->tokenType,(yyvsp[0].id))!=0)
                                                  printMismatchError(lineNo,checkAncestors((yyvsp[-2].id))->tokenType,(yyvsp[0].id));
                                           else if(checkAncestors((yyvsp[-2].id))->arrayDim!=-1)
                                                printWrongIDUsageError(lineNo,(yyvsp[-2].id));
                                          }
#line 2121 "y.tab.c" /* yacc.c:1646  */
    break;

  case 66:
#line 491 "miniC.y" /* yacc.c:1646  */
    {if(!checkAncestors((yyvsp[-2].id)))
                                                printUndecVarErr(lineNo, (yyvsp[-2].id));
                                          else if(strcmp(checkAncestors((yyvsp[-2].id))->tokenType,(yyvsp[0].id))!=0)
                                                  printMismatchError(lineNo,checkAncestors((yyvsp[-2].id))->tokenType,(yyvsp[0].id));
                                          else if(checkAncestors((yyvsp[-2].id))->arrayDim!=-1)
                                                printWrongIDUsageError(lineNo,(yyvsp[-2].id));
                                          }
#line 2133 "y.tab.c" /* yacc.c:1646  */
    break;

  case 67:
#line 498 "miniC.y" /* yacc.c:1646  */
    {if(!checkAncestors((yyvsp[-2].id)))
                                                printUndecVarErr(lineNo, (yyvsp[-2].id));
                                          else if(strcmp(checkAncestors((yyvsp[-2].id))->tokenType,(yyvsp[0].id))!=0)
                                                  printMismatchError(lineNo,checkAncestors((yyvsp[-2].id))->tokenType,(yyvsp[0].id));
                                          else if(checkAncestors((yyvsp[-2].id))->arrayDim!=-1)
                                                printWrongIDUsageError(lineNo,(yyvsp[-2].id));
                                          }
#line 2145 "y.tab.c" /* yacc.c:1646  */
    break;

  case 68:
#line 505 "miniC.y" /* yacc.c:1646  */
    {if(!checkAncestors((yyvsp[-2].id)))
                                                printUndecVarErr(lineNo, (yyvsp[-2].id));
                                           else if(strcmp(checkAncestors((yyvsp[-2].id))->tokenType,(yyvsp[0].id))!=0)
                                                  printMismatchError(lineNo,checkAncestors((yyvsp[-2].id))->tokenType,(yyvsp[0].id));
                                          else if(checkAncestors((yyvsp[-2].id))->arrayDim!=-1)
                                                printWrongIDUsageError(lineNo,(yyvsp[-2].id));
                                          }
#line 2157 "y.tab.c" /* yacc.c:1646  */
    break;

  case 69:
#line 512 "miniC.y" /* yacc.c:1646  */
    {if(!checkAncestors((yyvsp[-2].id)))
                                                printUndecVarErr(lineNo, (yyvsp[-2].id));
                                           else if(strcmp(checkAncestors((yyvsp[-2].id))->tokenType,(yyvsp[0].id))!=0)
                                                  printMismatchError(lineNo,checkAncestors((yyvsp[-2].id))->tokenType,(yyvsp[0].id));
                                          else if(checkAncestors((yyvsp[-2].id))->arrayDim!=-1)
                                                printWrongIDUsageError(lineNo,(yyvsp[-2].id));
                                          }
#line 2169 "y.tab.c" /* yacc.c:1646  */
    break;

  case 70:
#line 519 "miniC.y" /* yacc.c:1646  */
    {if(!checkAncestors((yyvsp[-2].id)))
                                                printUndecVarErr(lineNo, (yyvsp[-2].id));
                                          else if(strcmp(checkAncestors((yyvsp[-2].id))->tokenType,(yyvsp[0].id))!=0)
                                                  printMismatchError(lineNo,checkAncestors((yyvsp[-2].id))->tokenType,(yyvsp[0].id));
                                          else if(checkAncestors((yyvsp[-2].id))->arrayDim!=-1)
                                                printWrongIDUsageError(lineNo,(yyvsp[-2].id));
                                          }
#line 2181 "y.tab.c" /* yacc.c:1646  */
    break;

  case 71:
#line 526 "miniC.y" /* yacc.c:1646  */
    {if(!checkAncestors((yyvsp[-2].id)))
                                                printUndecVarErr(lineNo, (yyvsp[-2].id));
                                           else if(strcmp(checkAncestors((yyvsp[-2].id))->tokenType,(yyvsp[0].id))!=0)
                                                  printMismatchError(lineNo,checkAncestors((yyvsp[-2].id))->tokenType,(yyvsp[0].id));
                                          else if(checkAncestors((yyvsp[-2].id))->arrayDim!=-1)
                                                printWrongIDUsageError(lineNo,(yyvsp[-2].id));
                                          }
#line 2193 "y.tab.c" /* yacc.c:1646  */
    break;

  case 72:
#line 533 "miniC.y" /* yacc.c:1646  */
    {if(!checkAncestors((yyvsp[-2].id)))
                                                printUndecVarErr(lineNo, (yyvsp[-2].id));
                                           else if(strcmp(checkAncestors((yyvsp[-2].id))->tokenType,(yyvsp[0].id))!=0)
                                                  printMismatchError(lineNo,checkAncestors((yyvsp[-2].id))->tokenType,(yyvsp[0].id));
                                          else if(checkAncestors((yyvsp[-2].id))->arrayDim!=-1)
                                                printWrongIDUsageError(lineNo,(yyvsp[-2].id));
                                          }
#line 2205 "y.tab.c" /* yacc.c:1646  */
    break;

  case 73:
#line 540 "miniC.y" /* yacc.c:1646  */
    {if(!checkAncestors((yyvsp[-2].id)))
                                                printUndecVarErr(lineNo, (yyvsp[-2].id));
                                           else if(strcmp(checkAncestors((yyvsp[-2].id))->tokenType,(yyvsp[0].id))!=0)
                                                  printMismatchError(lineNo,checkAncestors((yyvsp[-2].id))->tokenType,(yyvsp[0].id));
                                          else if(checkAncestors((yyvsp[-2].id))->arrayDim!=-1)
                                                printWrongIDUsageError(lineNo,(yyvsp[-2].id));
                                          }
#line 2217 "y.tab.c" /* yacc.c:1646  */
    break;

  case 74:
#line 547 "miniC.y" /* yacc.c:1646  */
    {if(strcmp((yyvsp[-2].id),(yyvsp[0].id))!=0){
                                                  printMismatchError(lineNo,checkAncestors((yyvsp[-2].id))->tokenType,(yyvsp[0].id));
                                          }}
#line 2225 "y.tab.c" /* yacc.c:1646  */
    break;

  case 75:
#line 550 "miniC.y" /* yacc.c:1646  */
    {if(strcmp((yyvsp[-2].id),(yyvsp[0].id))!=0){
                                                  printMismatchError(lineNo,checkAncestors((yyvsp[-2].id))->tokenType,(yyvsp[0].id));
                                          }}
#line 2233 "y.tab.c" /* yacc.c:1646  */
    break;

  case 76:
#line 553 "miniC.y" /* yacc.c:1646  */
    {if(strcmp((yyvsp[-2].id),(yyvsp[0].id))!=0){
                                                  printMismatchError(lineNo,checkAncestors((yyvsp[-2].id))->tokenType,(yyvsp[0].id));
                                          }}
#line 2241 "y.tab.c" /* yacc.c:1646  */
    break;

  case 77:
#line 556 "miniC.y" /* yacc.c:1646  */
    {if(strcmp((yyvsp[-2].id),(yyvsp[0].id))!=0){
                                                  printMismatchError(lineNo,checkAncestors((yyvsp[-2].id))->tokenType,(yyvsp[0].id));
                                          }}
#line 2249 "y.tab.c" /* yacc.c:1646  */
    break;

  case 78:
#line 559 "miniC.y" /* yacc.c:1646  */
    {if(strcmp((yyvsp[-2].id),(yyvsp[0].id))!=0){
                                                  printMismatchError(lineNo,checkAncestors((yyvsp[-2].id))->tokenType,(yyvsp[0].id));
                                          }}
#line 2257 "y.tab.c" /* yacc.c:1646  */
    break;

  case 80:
#line 565 "miniC.y" /* yacc.c:1646  */
    { strcpy((yyval.id), (yyvsp[0].id)); }
#line 2263 "y.tab.c" /* yacc.c:1646  */
    break;

  case 81:
#line 569 "miniC.y" /* yacc.c:1646  */
    { strcpy((yyval.id), (yyvsp[0].id)); }
#line 2269 "y.tab.c" /* yacc.c:1646  */
    break;

  case 82:
#line 570 "miniC.y" /* yacc.c:1646  */
    { strcpy((yyval.id), "int"); }
#line 2275 "y.tab.c" /* yacc.c:1646  */
    break;

  case 83:
#line 571 "miniC.y" /* yacc.c:1646  */
    { strcpy((yyval.id), "int"); }
#line 2281 "y.tab.c" /* yacc.c:1646  */
    break;

  case 84:
#line 572 "miniC.y" /* yacc.c:1646  */
    { strcpy((yyval.id), "int"); }
#line 2287 "y.tab.c" /* yacc.c:1646  */
    break;

  case 85:
#line 575 "miniC.y" /* yacc.c:1646  */
    { strcpy((yyval.id), (yyvsp[0].id)); }
#line 2293 "y.tab.c" /* yacc.c:1646  */
    break;

  case 86:
#line 576 "miniC.y" /* yacc.c:1646  */
    { strcpy((yyval.id), "int"); }
#line 2299 "y.tab.c" /* yacc.c:1646  */
    break;

  case 87:
#line 577 "miniC.y" /* yacc.c:1646  */
    { strcpy((yyval.id), "int"); }
#line 2305 "y.tab.c" /* yacc.c:1646  */
    break;

  case 88:
#line 578 "miniC.y" /* yacc.c:1646  */
    { strcpy((yyval.id), "int"); }
#line 2311 "y.tab.c" /* yacc.c:1646  */
    break;

  case 89:
#line 579 "miniC.y" /* yacc.c:1646  */
    { strcpy((yyval.id), "int"); }
#line 2317 "y.tab.c" /* yacc.c:1646  */
    break;

  case 90:
#line 580 "miniC.y" /* yacc.c:1646  */
    { strcpy((yyval.id), "int"); }
#line 2323 "y.tab.c" /* yacc.c:1646  */
    break;

  case 91:
#line 581 "miniC.y" /* yacc.c:1646  */
    { strcpy((yyval.id), "int"); }
#line 2329 "y.tab.c" /* yacc.c:1646  */
    break;

  case 92:
#line 585 "miniC.y" /* yacc.c:1646  */
    { strcpy((yyval.id), (yyvsp[0].id)); }
#line 2335 "y.tab.c" /* yacc.c:1646  */
    break;

  case 93:
#line 586 "miniC.y" /* yacc.c:1646  */
    { if(isHigherPri((yyvsp[-2].id),(yyvsp[0].id))) strcpy((yyval.id),(yyvsp[-2].id));
                                                         else strcpy((yyval.id),(yyvsp[0].id));
                                                        }
#line 2343 "y.tab.c" /* yacc.c:1646  */
    break;

  case 94:
#line 589 "miniC.y" /* yacc.c:1646  */
    { if(isHigherPri((yyvsp[-2].id),(yyvsp[0].id))) strcpy((yyval.id),(yyvsp[-2].id));
                                                         else strcpy((yyval.id),(yyvsp[0].id));
                                                        }
#line 2351 "y.tab.c" /* yacc.c:1646  */
    break;

  case 95:
#line 593 "miniC.y" /* yacc.c:1646  */
    { strcpy((yyval.id), (yyvsp[0].id)); }
#line 2357 "y.tab.c" /* yacc.c:1646  */
    break;

  case 96:
#line 594 "miniC.y" /* yacc.c:1646  */
    { if(isHigherPri((yyvsp[-2].id),(yyvsp[0].id))) strcpy((yyval.id),(yyvsp[-2].id));
                                                         else strcpy((yyval.id),(yyvsp[0].id));
                                                        }
#line 2365 "y.tab.c" /* yacc.c:1646  */
    break;

  case 97:
#line 597 "miniC.y" /* yacc.c:1646  */
    { if(isHigherPri((yyvsp[-2].id),(yyvsp[0].id))) strcpy((yyval.id),(yyvsp[-2].id));
                                                         else strcpy((yyval.id),(yyvsp[0].id));
                                                        }
#line 2373 "y.tab.c" /* yacc.c:1646  */
    break;

  case 98:
#line 600 "miniC.y" /* yacc.c:1646  */
    { if(strcmp((yyvsp[-2].id),"int")!=0 || strcmp((yyvsp[0].id),"int")!=0){
                                                                printf(RED "Error : Modulus operator expects int\n" RESET);
                                                                strcpy((yyval.id), "int");
                                                        }
                                                        else{
                                                                strcpy((yyval.id), "int");
                                                        }
                                                        }
#line 2386 "y.tab.c" /* yacc.c:1646  */
    break;

  case 99:
#line 609 "miniC.y" /* yacc.c:1646  */
    { strcpy((yyval.id), (yyvsp[-1].id)); }
#line 2392 "y.tab.c" /* yacc.c:1646  */
    break;

  case 100:
#line 610 "miniC.y" /* yacc.c:1646  */
    {num = (yyvsp[0].num); strcpy((yyval.id),"int"); }
#line 2398 "y.tab.c" /* yacc.c:1646  */
    break;

  case 101:
#line 611 "miniC.y" /* yacc.c:1646  */
    { strcpy((yyval.id),"float"); }
#line 2404 "y.tab.c" /* yacc.c:1646  */
    break;

  case 102:
#line 612 "miniC.y" /* yacc.c:1646  */
    { strcpy((yyval.id),"char"); }
#line 2410 "y.tab.c" /* yacc.c:1646  */
    break;

  case 103:
#line 613 "miniC.y" /* yacc.c:1646  */
    { strcpy((yyval.id),"string"); }
#line 2416 "y.tab.c" /* yacc.c:1646  */
    break;

  case 104:
#line 614 "miniC.y" /* yacc.c:1646  */
    {if(!checkAncestors((yyvsp[0].id))){
                                                printUndecVarErr(lineNo, (yyvsp[0].id));
                                         }
                                        else if(checkAncestors((yyvsp[0].id))->arrayDim!=-1)
                                                printWrongIDUsageError(lineNo,(yyvsp[0].id));
                                         else{
                                                 strcpy((yyval.id),checkAncestors((yyvsp[0].id))->tokenType);
                                         }
                                        }
#line 2430 "y.tab.c" /* yacc.c:1646  */
    break;

  case 105:
#line 623 "miniC.y" /* yacc.c:1646  */
    {if(!checkAncestors((yyvsp[0].id))){
                                                printUndecVarErr(lineNo, (yyvsp[0].id));
                                        }
                                        else if(checkAncestors((yyvsp[0].id))->arrayDim!=-1)
                                                printWrongIDUsageError(lineNo,(yyvsp[0].id));
                                        else{
                                                 strcpy((yyval.id),checkAncestors((yyvsp[0].id))->tokenType);
                                         }
                                        }
#line 2444 "y.tab.c" /* yacc.c:1646  */
    break;

  case 106:
#line 632 "miniC.y" /* yacc.c:1646  */
    {if(!checkAncestors((yyvsp[0].id))){
                                                printUndecVarErr(lineNo, (yyvsp[0].id));
                                        }
                                        else if(checkAncestors((yyvsp[0].id))->arrayDim!=-1)
                                                printWrongIDUsageError(lineNo,(yyvsp[0].id));
                                        else{
                                                 strcpy((yyval.id),checkAncestors((yyvsp[0].id))->tokenType);
                                         }}
#line 2457 "y.tab.c" /* yacc.c:1646  */
    break;

  case 107:
#line 640 "miniC.y" /* yacc.c:1646  */
    {num = -num; strcpy((yyval.id),(yyvsp[0].id));}
#line 2463 "y.tab.c" /* yacc.c:1646  */
    break;

  case 108:
#line 641 "miniC.y" /* yacc.c:1646  */
    {strcpy((yyval.id),(yyvsp[0].id));}
#line 2469 "y.tab.c" /* yacc.c:1646  */
    break;

  case 109:
#line 642 "miniC.y" /* yacc.c:1646  */
    {strcpy((yyval.id),(yyvsp[0].id));}
#line 2475 "y.tab.c" /* yacc.c:1646  */
    break;

  case 110:
#line 643 "miniC.y" /* yacc.c:1646  */
    {       if(!checkAncestors((yyvsp[0].id)))
                                                        printUndecVarErr(lineNo, (yyvsp[0].id));
                                                else 
                                                        strcpy((yyval.id),checkAncestors((yyvsp[0].id))->tokenType);
                                        }
#line 2485 "y.tab.c" /* yacc.c:1646  */
    break;

  case 111:
#line 648 "miniC.y" /* yacc.c:1646  */
    {if(!checkAncestors((yyvsp[0].id))){
                                                printUndecVarErr(lineNo, (yyvsp[0].id));
                                        }
                                        else if(checkAncestors((yyvsp[0].id))->arrayDim!=-1)
                                                printWrongIDUsageError(lineNo,(yyvsp[0].id));
                                        else{
                                                 strcpy((yyval.id),checkAncestors((yyvsp[0].id))->tokenType);
                                         }}
#line 2498 "y.tab.c" /* yacc.c:1646  */
    break;

  case 112:
#line 656 "miniC.y" /* yacc.c:1646  */
    {if(!checkAncestors((yyvsp[-1].id))){
                                                printUndecVarErr(lineNo, (yyvsp[-1].id));
                                        }
                                        else if(checkAncestors((yyvsp[-1].id))->arrayDim!=-1)
                                                printWrongIDUsageError(lineNo,(yyvsp[-1].id));
                                        else{
                                                 strcpy((yyval.id),checkAncestors((yyvsp[-1].id))->tokenType);
                                         }}
#line 2511 "y.tab.c" /* yacc.c:1646  */
    break;

  case 113:
#line 664 "miniC.y" /* yacc.c:1646  */
    {if(!checkAncestors((yyvsp[0].id))){
                                                printUndecVarErr(lineNo, (yyvsp[0].id));
                                        }
                                        else if(checkAncestors((yyvsp[0].id))->arrayDim!=-1)
                                                printWrongIDUsageError(lineNo,(yyvsp[0].id));
                                        else{
                                                 strcpy((yyval.id),checkAncestors((yyvsp[0].id))->tokenType);
                                         }}
#line 2524 "y.tab.c" /* yacc.c:1646  */
    break;

  case 114:
#line 672 "miniC.y" /* yacc.c:1646  */
    {if(!checkAncestors((yyvsp[-1].id))){
                                                printUndecVarErr(lineNo, (yyvsp[-1].id));
                                        }
                                        else if(checkAncestors((yyvsp[-1].id))->arrayDim!=-1)
                                                printWrongIDUsageError(lineNo,(yyvsp[-1].id));
                                        else{
                                                 strcpy((yyval.id),checkAncestors((yyvsp[-1].id))->tokenType);
                                         }}
#line 2537 "y.tab.c" /* yacc.c:1646  */
    break;

  case 128:
#line 699 "miniC.y" /* yacc.c:1646  */
    { strcpy(returnType, (yyvsp[-1].id)); }
#line 2543 "y.tab.c" /* yacc.c:1646  */
    break;

  case 139:
#line 723 "miniC.y" /* yacc.c:1646  */
    {
                                                 if(!checkAncestors((yyvsp[-3].id)))
                                                       printUndecVarErr(lineNo, (yyvsp[-3].id));
                                                 else if(pCount!=(lookUpSymbolItem((yyvsp[-3].id)))->paramCount)
                                                        {
                                                                printWrongParamCountError(lineNo,pCount,(lookUpSymbolItem((yyvsp[-3].id)))->paramCount, (yyvsp[-3].id));
                                                                pCount = 0;
                                                        }
                                                else if(!isCorrectParams(params,lookUpSymbolItem((yyvsp[-3].id))->paramList,(yyvsp[-3].id))){
                                                        //printWrongParamError(lineNo, $1);
                                                }
                                                 pCount = 0;
                                                 strcpy((yyval.id),(yyvsp[-3].id));
                                                }
#line 2562 "y.tab.c" /* yacc.c:1646  */
    break;


#line 2566 "y.tab.c" /* yacc.c:1646  */
      default: break;
    }
  /* User semantic actions sometimes alter yychar, and that requires
     that yytoken be updated with the new translation.  We take the
     approach of translating immediately before every use of yytoken.
     One alternative is translating here after every semantic action,
     but that translation would be missed if the semantic action invokes
     YYABORT, YYACCEPT, or YYERROR immediately after altering yychar or
     if it invokes YYBACKUP.  In the case of YYABORT or YYACCEPT, an
     incorrect destructor might then be invoked immediately.  In the
     case of YYERROR or YYBACKUP, subsequent parser actions might lead
     to an incorrect destructor call or verbose syntax error message
     before the lookahead is translated.  */
  YY_SYMBOL_PRINT ("-> $$ =", yyr1[yyn], &yyval, &yyloc);

  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);

  *++yyvsp = yyval;

  /* Now 'shift' the result of the reduction.  Determine what state
     that goes to, based on the state we popped back to and the rule
     number reduced by.  */

  yyn = yyr1[yyn];

  yystate = yypgoto[yyn - YYNTOKENS] + *yyssp;
  if (0 <= yystate && yystate <= YYLAST && yycheck[yystate] == *yyssp)
    yystate = yytable[yystate];
  else
    yystate = yydefgoto[yyn - YYNTOKENS];

  goto yynewstate;


/*--------------------------------------.
| yyerrlab -- here on detecting error.  |
`--------------------------------------*/
yyerrlab:
  /* Make sure we have latest lookahead translation.  See comments at
     user semantic actions for why this is necessary.  */
  yytoken = yychar == YYEMPTY ? YYEMPTY : YYTRANSLATE (yychar);

  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;
#if ! YYERROR_VERBOSE
      yyerror (YY_("syntax error"));
#else
# define YYSYNTAX_ERROR yysyntax_error (&yymsg_alloc, &yymsg, \
                                        yyssp, yytoken)
      {
        char const *yymsgp = YY_("syntax error");
        int yysyntax_error_status;
        yysyntax_error_status = YYSYNTAX_ERROR;
        if (yysyntax_error_status == 0)
          yymsgp = yymsg;
        else if (yysyntax_error_status == 1)
          {
            if (yymsg != yymsgbuf)
              YYSTACK_FREE (yymsg);
            yymsg = (char *) YYSTACK_ALLOC (yymsg_alloc);
            if (!yymsg)
              {
                yymsg = yymsgbuf;
                yymsg_alloc = sizeof yymsgbuf;
                yysyntax_error_status = 2;
              }
            else
              {
                yysyntax_error_status = YYSYNTAX_ERROR;
                yymsgp = yymsg;
              }
          }
        yyerror (yymsgp);
        if (yysyntax_error_status == 2)
          goto yyexhaustedlab;
      }
# undef YYSYNTAX_ERROR
#endif
    }



  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse lookahead token after an
         error, discard it.  */

      if (yychar <= YYEOF)
        {
          /* Return failure if at end of input.  */
          if (yychar == YYEOF)
            YYABORT;
        }
      else
        {
          yydestruct ("Error: discarding",
                      yytoken, &yylval);
          yychar = YYEMPTY;
        }
    }

  /* Else will try to reuse lookahead token after shifting the error
     token.  */
  goto yyerrlab1;


/*---------------------------------------------------.
| yyerrorlab -- error raised explicitly by YYERROR.  |
`---------------------------------------------------*/
yyerrorlab:

  /* Pacify compilers like GCC when the user code never invokes
     YYERROR and the label yyerrorlab therefore never appears in user
     code.  */
  if (/*CONSTCOND*/ 0)
     goto yyerrorlab;

  /* Do not reclaim the symbols of the rule whose action triggered
     this YYERROR.  */
  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);
  yystate = *yyssp;
  goto yyerrlab1;


/*-------------------------------------------------------------.
| yyerrlab1 -- common code for both syntax error and YYERROR.  |
`-------------------------------------------------------------*/
yyerrlab1:
  yyerrstatus = 3;      /* Each real token shifted decrements this.  */

  for (;;)
    {
      yyn = yypact[yystate];
      if (!yypact_value_is_default (yyn))
        {
          yyn += YYTERROR;
          if (0 <= yyn && yyn <= YYLAST && yycheck[yyn] == YYTERROR)
            {
              yyn = yytable[yyn];
              if (0 < yyn)
                break;
            }
        }

      /* Pop the current state because it cannot handle the error token.  */
      if (yyssp == yyss)
        YYABORT;


      yydestruct ("Error: popping",
                  yystos[yystate], yyvsp);
      YYPOPSTACK (1);
      yystate = *yyssp;
      YY_STACK_PRINT (yyss, yyssp);
    }

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END


  /* Shift the error token.  */
  YY_SYMBOL_PRINT ("Shifting", yystos[yyn], yyvsp, yylsp);

  yystate = yyn;
  goto yynewstate;


/*-------------------------------------.
| yyacceptlab -- YYACCEPT comes here.  |
`-------------------------------------*/
yyacceptlab:
  yyresult = 0;
  goto yyreturn;

/*-----------------------------------.
| yyabortlab -- YYABORT comes here.  |
`-----------------------------------*/
yyabortlab:
  yyresult = 1;
  goto yyreturn;

#if !defined yyoverflow || YYERROR_VERBOSE
/*-------------------------------------------------.
| yyexhaustedlab -- memory exhaustion comes here.  |
`-------------------------------------------------*/
yyexhaustedlab:
  yyerror (YY_("memory exhausted"));
  yyresult = 2;
  /* Fall through.  */
#endif

yyreturn:
  if (yychar != YYEMPTY)
    {
      /* Make sure we have latest lookahead translation.  See comments at
         user semantic actions for why this is necessary.  */
      yytoken = YYTRANSLATE (yychar);
      yydestruct ("Cleanup: discarding lookahead",
                  yytoken, &yylval);
    }
  /* Do not reclaim the symbols of the rule whose action triggered
     this YYABORT or YYACCEPT.  */
  YYPOPSTACK (yylen);
  YY_STACK_PRINT (yyss, yyssp);
  while (yyssp != yyss)
    {
      yydestruct ("Cleanup: popping",
                  yystos[*yyssp], yyvsp);
      YYPOPSTACK (1);
    }
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif
#if YYERROR_VERBOSE
  if (yymsg != yymsgbuf)
    YYSTACK_FREE (yymsg);
#endif
  return yyresult;
}
#line 739 "miniC.y" /* yacc.c:1906  */

#include<ctype.h>
int count=0;

int main(int argc, char *argv[])
{
        initScope();
        yyin = fopen(argv[1], "r");
	
        if(!yyparse())
                printf("\nParsing complete\n");
        else
                printf(RED "\nParsing failed\n" RESET);

        fclose(yyin);

        showSymbolTable();
        return 0;
}
         
void yyerror(const char *s) {
	printf(RED "%d : %s %s\n" RESET, lineNo, s, yytext );
}
