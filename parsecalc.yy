%language "c++"
%define api.token.prefix {TOK_}

%define api.value.type variant
%defines
%error-verbose
%debug

%locations
%parse-param { unsigned* nerrs }

%code provides
{
#define YY_DECL                                 \
  yy::parser::token_type yylex(yy::parser::semantic_type* yylval, yy::parser::location_type* yylloc)
  YY_DECL;
}

%code top
{
#include <stdio.h>
#include <stdlib.h>
}


%expect 0
%left "+" "-"
%left "*" "/"

%token <int> INT "number"
%type <int> exp line

%printer { yyo << $$; } <int>

%token
  LPAREN "("
  MINUS "-"
  PLUS "+"
  RPAREN ")"
  SLASH "/"
  STAR  "*"
  EOL "end of line"
  EOF 0 "end of file"
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
                     error (@3, "division by 0");
                     YYERROR;
                   }
               }
| "(" exp ")"  { $$ = $2; }
| "(" error ")"{ $$ = 777; }
| INT          { $$ = $1; }
;

%%

void yy::parser::error (const location_type& loc, const std::string& msg)
{
  std::cerr << loc;
  std::cerr << ": " << msg << std::endl;
  *nerrs += 1;
}

int main()
{
  unsigned nerrs = 0;
  yy::parser p(&nerrs);
  nerrs += !!p.parse();
  return !!nerrs;
}
