/* C√≥digo de soporte */

%{

  /*Codigo para el analisis de ambito!!!*/
  
var symbolTables = [{ name: '', father: null, vars: {} }];
var scope = 0; 
var symbolTable = symbolTables[scope];

function getScope() {
  return scope;
}

function getFormerScope() {
   scope--;
   symbolTable = symbolTables[scope];
}

function makeNewScope(id) {
   scope++;
   symbolTable.vars[id].symbolTable = symbolTables[scope] =  { name: id, father: symbolTable, vars: {} };
   symbolTable = symbolTables[scope];
   return symbolTable;
}

function findSymbol(x) {
  var f;
  var s = scope;
  do {
    f = symbolTables[s].vars[x];
    s--;
  } while (s >= 0 && !f);
  s++;
  return [f, s];
}

var myCounter = 0;
function newLabel(x) {
  return String(x)+myCounter++;
}

function functionCall(name, arglist) {
  var info = findSymbol(name);
  var s = info[1];
  info = info[0];

  if (!info || info.type != 'FUNC') {
    throw new Error("Can't call '"+name+"' ");
  }
  else if(arglist.length != info.arity) {
    throw new Error("Can't call '"+name+"' with "+arglist.length+
                    " arguments. Expected "+info.arity+" arguments.");
  }
  
  return arglist.join('')+
         unary("call "+":"+findFuncName(findSymbol(name)[0].symbolTable),"jump");
}

  
  
/*********************************************************
 *********************************************************
 *********************************************************
 */
  
  
function buildBlock(cd, vd, pd, c) {
  return {
    type: 'BLOCK',
    DEC_CONSTS: cd,
    DEC_VARS: vd,
    DEC_PROCS: pd,
    content: c
  };
}

%}

/* Reglas de precedencia */

%right ASSIGN
%left ADD
%left MUL

%right THEN ELSE

/* Declaraci√≥n de tokens */

%token END_SYMBOL EOF CONST END_SENTENCE COMMA ID ASSIGN PROCEDURE BEGIN CALL COMPARISON_OP DO END
%token IF LEFTPAR RIGHTPAR NUMBER ODD VAR WHILE

%start PROGRAM

/* Comienzo de la descripci√≥n de la gram√°tica */

%%

PROGRAM
  : BLOCK END_SYMBOL EOF
    {
      return $1;
    }
  ;

BLOCK
  : DEC_CONSTS DEC_VARS DEC_PROCS STATEMENT
    {
      $$ = buildBlock($1, $2, $3, $4);
    }
  | DEC_VARS DEC_PROCS STATEMENT
    {
      $$ = buildBlock(null, $1, $2, $3);
    }
  | DEC_CONSTS DEC_PROCS STATEMENT
    {
      $$ = buildBlock($1, null, $2, $3);
    }
  | DEC_PROCS STATEMENT
    {
      $$ = buildBlock(null, null, $1, $2);
    }
  ;

DEC_PROCS
  : DEC_PROC DEC_PROCS
    {
      $$ = [$1];
      if ($2 && $2.length > 0)
        $$ = $$.concat($2);
    }
  | /* nada */
  ;

DEC_CONSTS
  : CONST DEC_CONST COMMA_CONST END_SENTENCE
    {
      $$ = [$2];
      if ($3 && $3.length > 0)
        $$ = $$.concat($3);
    }
  ;

COMMA_CONST
  : COMMA DEC_CONST COMMA_CONST
    {
      $$ = [$2];
      if ($3 && $3.length > 0)
        $$ = $$.concat($3);
    }
  | /* nada */
  ;

DEC_CONST
  : ID_ ASSIGN NUMBER_
    {
      $$ = {
        type: 'CONST VAR',
        name: $1.value,
        value: $3.value
      };
    }
  ;

DEC_VARS
  : VAR ID_ COMMA_VARS END_SENTENCE
    {
      $$ = [{
        type: 'VAR',
        name: $2.value
      }];

      if ($3 && $3.length > 0)
        $$ = $$.concat($3);
    }
  ;

COMMA_VARS
  : COMMA ID_ COMMA_VARS
    {
      $$ = [{
        type: 'VAR',
        name: $2.value
      }];

      if ($3 && $3.length > 0)
        $$ = $$.concat($3);
    }
  | /* nada */
  ;

DEC_PROC
  : PROCEDURE ID_ ARGLIST END_SENTENCE BLOCK END_SENTENCE
    {
      $$ = {
        type: 'PROCEDURE',
        name: $2.value,
        args: $3,
        block: $5
      };
    }
  | PROCEDURE ID_ END_SENTENCE BLOCK END_SENTENCE
    {
      $$ = {
        type: 'PROCEDURE',
        name: $2.value,
        args: null,
        block: $4
      };
    }
  ;

ARGLIST
  : LEFTPAR ID_ COMMA_ARGLIST RIGHTPAR
    {
      $$ = [{
        type: 'ARG',
        content: $2.value
      }];

      if ($3 && $3.length > 0)
        $$ = $$.concat($3);
    }
  ;

COMMA_ARGLIST
  : COMMA ID_ COMMA_ARGLIST
    {
      $$ = [{
        type: 'ARG',
        content: $2.value
      }];

      if ($3 && $3.length > 0)
        $$ = $$.concat($3);
    }
  | /* nada */
  ;

ARGLISTEXP
  : LEFTPAR EXPRESSION COMMA_ARGLISTEXP RIGHTPAR
    {
      $$ = [{
        type: 'ARGEXP',
        content: $2
      }];

      if ($3 && $3.length > 0)
        $$ = $$.concat($3);
    }
  ;

COMMA_ARGLISTEXP
  : COMMA EXPRESSION COMMA_ARGLISTEXP
    {
      $$ = [{
        type: 'ARGEXP',
        content: $2
      }];

      if ($3 && $3.length > 0)
        $$ = $$.concat($3);
    }
  | /* nada */
  ;
  
STATEMENT
	: CALL ID_ ARGEXPLIST
		{
			$$ = {
				type: 'PROC_CALL',
				name: $2.value,
				args: $3
			};
		}
	| ID_ ASSIGN EXPRESSION
		{
			$$ = {
				type: '=',
				left: $1,
				rigth: $3
			};
		}
	| CALL ID_
		{
			$$ = {
				type: 'PROC_CALL',
				name: $2.value
			};
		}
	| BEGIN STATEMENT STATEMENT_LIST END
		{
			$$ = [$2];
			if ($3 && $3.length > 0)
				$$ = $$.concat($3);
		}
	| IF LEFTPAR CONDITION RIGHTPAR THEN STATEMENT ELSE STATEMENT
		{
			$$ = {
				type: 'IFELSE',
				condition: $3,
				true_sentence: $6,
				false_sentence: $8
			};
		}
		
	| IF LEFTPAR CONDITION RIGHTPAR THEN STATEMENT
		{
			$$ = {
				type: 'IF',
				condition: $3,
				true_sentence: $6
			};
		}
	| WHILE LEFTPAR CONDITION RIGHTPAR DO STATEMENT
		{
			$$ = {
				type: 'WHILE',
				condition: $3,
				statement: $6
			};
		}
	| /* empty */
	;
	
STATEMENT_LIST
	: END_SENTENCE STATEMENT STATEMENT_LIST
		{
			$$ = [$2];
			if ($3 && $3.length > 0)
				$$ = $$.concat($3);
		}
	| /* empty */
	;
	
CONDITION
	: ODD EXPRESSION
		{
			$$ = {
				type: 'ODD',
				exp: $2
			};
		}
	| EXPRESSION COMPARISON_OP EXPRESSION
		{
			$$ = {
				type: $2,
				left: $1,
				right: $3
			};
		}
	;

EXPRESSION
  : TERM
  | TERM ADD EXPRESSION
    {
      $$ = {
        type: $2,
        left: $1,
        right: $3
      };
    }
  ;

TERM
  : FACTOR
  | FACTOR MUL TERM
    {
      $$ = {
        type: $2,
        left: $1,
        right: $3
      };
    }
  ;

FACTOR
  : NUMBER_
  | ID_
  | LEFTPAR EXPRESSION RIGHTPAR
    {
      $$ = $2;
    }
  ;

//ID se declara con un _ porque ese considera un terminal y da problemas al compilar en jison
ID_: ID
  {
    $$ = {
      type: 'ID',
      value: yytext
    };
  }
  ;

NUMBER_: NUMBER
  {
    $$ = {
      type: 'NUMBER',
      value: yytext
    };
  }
  ;

%%
/* Fin de la gramatica */