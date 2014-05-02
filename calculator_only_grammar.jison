/* description: Parses end executes mathematical expressions. */

%token NUMBER ID E PI EOF
/* operator associations and precedence */
%right '='
%left '+' '-'
%left '*' '/'
%left '^'
%right '%'
%left UMINUS
%left '!'

%start prog

%% /* language grammar */
prog
    : expressions EOF
    ;

expressions
    : s  
    | expressions ';' s
    ;

s
    : /* empty */
    | e
    ;

e
    : ID '=' e
    | e '+' e
    | e '-' e
    | e '*' e
    | e '/' e
    | e '^' e
    | e '!'
    | e '%'
    | '-' e %prec UMINUS
    | '(' e ')'
    | NUMBER
    | E
    | PI
    | ID 
    ;

