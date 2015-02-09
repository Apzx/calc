%defines
%error-verbose
%debug
%define api.pure full
%locations
%parse-param { unsigned* nerrs }
%union
{
  int ival;
}

%code provides
{
#define YY_DECL                                 \
  enum yytokentype yylex(YYSTYPE* yylval, YYLTYPE* yylloc)
  YY_DECL;
}

%code top
{
#include <stdio.h>
#include <stdlib.h>
}

%code
{
  void yyerror(YYLTYPE* loc, unsigned* nerrs, const char* msg);
}


%expect 0
%left "+" "-"
%left "*" "/"

%token <ival> INT "number"
%type <ival> exp line

%printer { fprintf(yyo, "%d", $$); } <ival>

%token
  LPAREN "("
  MINUS "-"
  PLUS "+"
  RPAREN ")"
  SLASH "/"
  STAR  "*"
  EOL "end of line"
%%
input:
  %empty
| input line  { printf("%d\n", $2); }
;

line:
  EOL       { $$ = -1; }
| exp EOL   { $$ = $1; }
| error EOL { $$ = 666; yyerrok; }
;

exp:
  exp "+" exp  { $$ = $1 + $3; }
| exp "-" exp  { $$ = $1 - $3; }
| exp "*" exp  { $$ = $1 * $3; }
| exp "/" exp  {
                 if ($3)
                   $$ = $1 / $3;
                 else
                   {
                     yyerror (&@3, nerrs, "division by 0");
                     YYERROR;
                   }
               }
| "(" exp ")"  { $$ = $2; }
| "(" error ")"{ $$ = 777; }
| INT          { $$ = $1; }
;

%%
void yyerror(YYLTYPE* loc, unsigned* nerrs, const char* msg)
{
  YY_LOCATION_PRINT(stderr, *loc);
  fprintf(stderr, ": %s\n", msg);
  *nerrs += 1;
}

int main()
{
  yydebug = !!getenv("YYDEBUG");
  unsigned nerrs = 0;
  nerrs += !!yyparse(&nerrs);
  return !!nerrs;
}
