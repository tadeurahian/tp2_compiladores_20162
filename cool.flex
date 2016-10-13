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

extern YYSTYPE cool_yylval;

/*
 *  Add Your own definitions here
 */

%}

/*
 * Define names for regular expressions here.
 */

DARROW          =>

%%

 /*
  *  Nested comments
  */

// Comments enclosed by (**)

<INITIAL>"*)"	{
  cool_yylval.error_msg = "Unmatched *)";
  return ERROR;
}

<INITIAL>{BEGIN_COMMENT} {
  commentSize = 1;
  BEGIN(comment);
}

<comment>{BEGIN_COMMENT} {
  commentSize++;
}

<comment>.

<comment>\n {
  currentLine++;
}

<comment>"*)" {
  commentSize--;
  if (commentSize == 0) {
    BEGIN(INITIAL);
  }
}

// You can't have an EOF in the middle of an (* *) enclosed comment

<comment><<EOF>> {
  BEGIN(INITIAL);
  cool_yylval.error_msg = "EOF in comment";
  return ERROR;
}

// One line comment started by --

"--".*	{  }

{STRING_START} {
  BEGIN(string);
  is_broken_string = 0;
  string_length = 0;
  extra_length = 0;
  memset(&string_buf, 0, MAX_STR_CONST);
}

<string>"\""		{ BEGIN(INITIAL); string_buf[string_length++] = '\0'; if (string_length > MAX_STR_CONST) { cool_yylval.error_msg = "String constant too long"; return ERROR; } else if (!is_broken_string) { cool_yylval.symbol = stringtable.add_string(string_buf); return STR_CONST; } }

<string>"\\\""		{ string_buf[string_length++] = '"'; }

<string>\n		{   
				curr_lineno++;
				BEGIN(INITIAL);
				if (!is_broken_string) {
  				cool_yylval.error_msg = "Unterminated string constant";
				return ERROR;
				}
			}

<string><<EOF>>		{
  				cool_yylval.error_msg = "EOF in string constant";
  				BEGIN(INITIAL); 
				return ERROR;
			}

<string>.		{ string_buf[string_length++] = *yytext; }	

 /*
  *  The multiple-character operators.
  */
{DARROW}		{ return (DARROW); }

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


%%
