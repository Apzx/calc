/* Prologue. */
%option noyywrap
%{
#include "parsecalc.h"

# define YY_USER_ACTION                         \
  yylloc->last_column += yyleng;

# define STEP()                                 \
  do {                                          \
    yylloc->first_line = yylloc->last_line;     \
    yylloc->first_column = yylloc->last_column; \
  } while (0)

%}
%%
%{
  STEP();
%}
"+"         return PLUS;
"-"         return MINUS;
"*"         return STAR;
"/"         return SLASH;
"("         return LPAREN;
")"         return RPAREN;
[0-9]+      yylval->ival = strtol(yytext, 0, 10) ;return INT;
" "+        STEP(); continue;
"\n"        yylloc->last_line += 1; yylloc->last_column = 1; STEP(); return EOL;
.           fprintf (stderr, "error: invalid character: %c\n", *yytext);
%%
/* Epilogue.  */
