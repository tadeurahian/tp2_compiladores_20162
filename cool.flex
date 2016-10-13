/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

int commentSize;
int stringSize;

extern YYSTYPE cool_yylval;

/*
 *  Add Your own definitions here
 */

%}

%x string

%x comment

/*
 * Regular Expressions and Names
 */

IF		(?i:if)

FI		(?i:fi)

IN		(?i:in)

INHERITS	(?i:inherits)

LET		(?i:let)

WHILE		(?i:while)

CASE		(?i:case)

LOOP		(?i:loop)

POOL		(?i:pool)

THEN		(?i:then)

NEW_COMMENT	"(*"

STRING_START	"\""

DARROW          =>

NEW		(?i:new)

INT_CONST	[0-9]+

TRUE		t(?i:rue)

FALSE		f(?i:alse)

ASSIGN		<-

NOT		(?i:not)

TYPEID 		[A-Z][A-Za-z0-9_]*

OBJECTID 	[a-z][A-Za-z0-9_]*

CLASS		(?i:class)

ELSE		(?i:else)

ESAC		(?i:esac)

OF		(?i:of)

ISVOID		(?i:isvoid)

LE		<=

%%

{NEW}	{
	return NEW;
}

{CLASS} {
	return CLASS;
}

{ELSE} {
	return ELSE;
}

{IF} {
	return IF;
}

{FI} {
	return FI;
}

{IN} {
	return IN;
}

{INHERITS} {
	return INHERITS;
}

{LET} {
	return LET;
}

{LOOP} {
	return LOOP;
}

{POOL} {
	return POOL;
}

{THEN} {
	return THEN;
}

{WHILE} {
	return WHILE;
}

{CASE} {
	return CASE;
}

{ESAC} { 
	return ESAC;
}

{OF} {
	return OF;
}

{ISVOID} {
	return ISVOID;
}

{LE} {
	return LE;
}

{INT_CONST} {
	cool_yylval.symbol = inttable.add_string(yytext);
	return INT_CONST;
}

{TRUE} {
	cool_yylval.boolean = 1;
	return BOOL_CONST;
}

{FALSE} {
	cool_yylval.boolean = 0;
	return BOOL_CONST;
}

{ASSIGN} {
	return ASSIGN;
}

{NOT} {
	return NOT;
}

{TYPEID} {
	cool_yylval.symbol = stringtable.add_string(yytext);
	return TYPEID;
}

{OBJECTID} {
	cool_yylval.symbol = stringtable.add_string(yytext);
	return OBJECTID;
}

 /*
  *  Comments
  */  

<INITIAL>"*)" { cool_yylval.error_msg = "Unmatched *)"; return ERROR; }

<INITIAL>{NEW_COMMENT} { commentSize = 0; BEGIN(comment); 	}

<comment>{NEW_COMMENT} { commentSize++; }

<comment>.

<comment>\n { curr_lineno++; }

<comment>"*)" { 	if (commentSize == 0) { BEGIN(INITIAL); } }

<comment><<EOF>> { 	cool_yylval.error_msg = "EOF in comment"; BEGIN(INITIAL); return ERROR; }

"--".*	{  }

{STRING_START} { stringSize = 0; memset(&string_buf, 0, MAX_STR_CONST); BEGIN(string); 	}

<string>\n { curr_lineno++; BEGIN(INITIAL); }

<string><<EOF>> { cool_yylval.error_msg = "EOF in string constant"; BEGIN(INITIAL); return ERROR; }

 /*
  *  The multiple-character operators.
  */

{DARROW} { 
	return (DARROW); 
}

 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */

 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */

  /* return ASCII code from char */

"."	{ 
	return (int)'.'; 
}

";"	{ 
	return (int)';'; 
}

","	{ 
	return (int)','; 
}

"<"	{ 
	return (int)'<'; 
}

":"	{ 
	return (int)':'; 
}

"="	{ 
	return (int)'='; 
}

"+"	{ 
	return (int)'+'; 
}

"-"	{ 
	return (int)'-'; 
}

"*"	{ 
	return (int)'*'; 
}

"/"	{ 
	return (int)'/'; 
}

"~"	{ 
	return (int)'~'; 
}

"@"	{ 
	return (int)'@'; 
}

")"	{ 
	return (int)')'; 
}

"("	{ 
	return (int)'('; 
}

"}"	{ 
	return (int)'}'; 
}

"{"	{ 
	return (int)'{'; 
}

\n	{ 
	curr_lineno++; 
}

%%
