%{
#include <iostream>
using namespace std;
#define YY_DECL extern "C" int yylex()

#include "parser.tab.h"

%}

DIGIT    [0-9]
LETTER   ([a-z]|[A-Z])
DIGITS   [0-9]+

%%
[ \t\n]          ;

[\(\)\{\},;]               { return yytext[0]; }
int                         { return INT; }
float                       { return FLOAT; }
boolean                     { return BOOLEAN; }
if                          { return IF; }
else                        { return ELSE; }
while                       { return WHILE; }
for                         { return FOR; }
[\=]                        { return ASSIGN; }
[\+]                        { return PLUS; }
[\-]                        { return MINUS; }
[\*]                        { return MUL; }
"/"                         { return DIV; }
"==" 	{ return EQU; }
"!="	{ return NEQU; }
">" 	{ return GRT; }
">="	{ return GTE; }
"<"	    { return SML; }
"<="    { return LTE; }

{LETTER}[{LETTER}{DIGIT}]*  { yylval.id_val = strdup(yytext); return ID; }
{DIGITS}                    { yylval.fval = atoi(yytext); return INT_VAL;}
{DIGITS}"."{DIGITS}         { yylval.fval = atof(yytext); return FLOAT_VAL; }
.                           { ;}
%%


//Remember to handle floats with all formats
