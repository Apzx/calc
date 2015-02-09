/* Prologue. */
%option noyywrap
%{
#include "parsecalc.hh"

# define YY_USER_ACTION                         \
  yylloc->end.column += yyleng;

# define STEP()                                 \
  do {                                          \
    yylloc->begin.line = yylloc->end.line;     \
    yylloc->begin.column = yylloc->end.column; \
  } while (0)

%}
%%
%{
  STEP();
  typedef yy::parser::token token;
%}
"+"         return token::TOK_PLUS;
"-"         return token::TOK_MINUS;
"*"         return token::TOK_STAR;
"/"         return token::TOK_SLASH;
"("         return token::TOK_LPAREN;
")"         return token::TOK_RPAREN;
[0-9]+      yylval->build<int>(strtol(yytext, 0, 10)) ;return token::TOK_INT;
" "+        STEP(); continue;
"\n"        yylloc->end.line += 1; yylloc->end.column = 1; STEP(); return token::TOK_EOL;
.           fprintf (stderr, "error: invalid character: %c\n", *yytext);
<<EOF>>		return token::TOK_EOF;
%%
/* Epilogue.  */
