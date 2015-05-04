%defines
%language "c++"
%error-verbose
%debug

%define api.token.prefix {TOK_}
%define api.value.type variant

%locations

%parse-param { unsigned* nerrs }

%code provides {

	#define YY_DECL \
		yy::parser::token_type yylex(yy::parser::semantic_type* yylval, yy::parser::location_type* yylloc)
	
	YY_DECL;
}

%code requires {
	#include <iostream>
	#include "ast.hh"
}

%code {
	Scope* globalScope = new Scope();

	Driver driver(globalScope);
	Evaluator evaluator;
}


%expect 0

%left "if" "while"
%right "{"
%left "}"

%left "=="
%left "+" "-"
%left "*" "/"
%left "&&" "||"




%token <int> INT "number"
%type <Exp*> exp line

%token
  LBRACK "{"
  RBRACK "}"
  LPAREN "("
  MINUS "-"
  PLUS "+"
  RPAREN ")"
  SLASH "/"
  STAR  "*"
  AND "&&"
  OR "||"
  EQUALS "=="
  IF "if"
  WHILE "while"
  EOL "end of line"
  EOF 0 "end of file"

%%
input:
  %empty
| input line  {

	// globalScope->addExp($2);
	std::cout << "Input: " << *$2 << "\nValue: " << $2->accept(evaluator) << "\n\n";

};

line:
  EOL       { $$ = driver.makeConst(-1); }
| exp EOL   { $$ = $1; }
| error EOL { $$ = driver.makeConst(666); yyerrok; }
;

exp:
  exp "+" exp                     { $$ = driver.makeBinop('+', $1, $3); }
| exp "-" exp                     { $$ = driver.makeBinop('-', $1, $3); }
| exp "*" exp                     { $$ = driver.makeBinop('*', $1, $3); }
| exp "/" exp                     { $$ = driver.makeBinop('/', $1, $3); }
| exp "&&" exp                    { $$ = driver.makeBinop('&', $1, $3); }
| exp "||" exp                    { $$ = driver.makeBinop('|', $1, $3); }
| exp "==" exp                    { $$ = driver.makeBinop('=', $1, $3); }
| "if" "(" exp ")" "{" exp "}"    { $$ = driver.makeScope('i', $3, $6); }
| "while" "(" exp ")" "{" exp "}" { $$ = driver.makeScope('w', $3, $6); }
| "{" exp "}"                     { $$ = driver.makeScope('n', driver.makeConst(1), $2); }

| "(" exp ")"                     { $$ = $2; }
| "(" error ")"                   { $$ = driver.makeConst(777); yyerrok;}
| INT                             { $$ = driver.makeConst($1); }
;




%%

void yy::parser::error (const location_type& loc, const std::string& msg) {
  std::cerr << loc;
  std::cerr << ": " << msg << std::endl;
  *nerrs += 1;
}

int main(int argc, char const *argv[]) {
	unsigned nerrs = 0;
	yy::parser p(&nerrs);
	nerrs += !!p.parse();
	return !!nerrs;
}