/* Prologue. */
%option noyywrap

%{
#include "parsecalc.hh"

#define YY_USER_ACTION *yylloc += yyleng;
%}

%%

%{
  yylloc->step();
  typedef yy::parser::token token;
%}

"+"         return token::TOK_PLUS;
"-"         return token::TOK_MINUS;
"*"         return token::TOK_STAR;
"/"         return token::TOK_SLASH;
"("         return token::TOK_LPAREN;
")"         return token::TOK_RPAREN;
"{"         return token::TOK_LBRACK;
"}"         return token::TOK_RBRACK;
"=="        return token::TOK_EQUALS;
"&&"        return token::TOK_AND;
"||"        return token::TOK_OR;
"if"        return token::TOK_IF;
"while"     return token::TOK_WHILE;
[0-9]+      yylval->build<int>(strtol(yytext, 0, 10)) ;return token::TOK_INT;
" "+        yylloc->step(); continue;
"\n"        yylloc->end.line += 1; yylloc->end.column = 1; yylloc->step(); return token::TOK_EOL;
.           fprintf (stderr, "error: invalid character: %c\n", *yytext);
<<EOF>>		return token::TOK_EOF;
%%
/* Epilogue.  */
