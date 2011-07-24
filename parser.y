%{
  #include <stdlib.h>
  #include <stdio.h>

  #include "okk/types.h"
  #include "okk/print.h"

  extern int yylex();
  void yyerror(const char* error) { printf("%s\n", error); }

  Node* state;

  Node* new_node() {
    Node* node = (Node*) malloc(sizeof(Node));
    node->previous = NULL;
    node->next = NULL;
    node->type = NULL;
    node->ordered = false;
    node->integer_value = NULL;
    node->decimal_value = NULL;
    node->string_value = NULL;
    node->parent = NULL;
    node->children = NULL;
    return node;
  }
%}

%token <bool> BOOLEAN
%token <int> INT
%token <real> REAL
%token <var_id> VAR_ID
%token PLUS STAR DIV LEQ NOT AND INCREMENT SEMI MALLOC REF LAMBDA DOT MU CALLCC
%token RANDOM_BOOL NEW_AGENT ME PARENT RECEIVE RECEIVE_FROM QUOTE UNQUOTE EVAL
%token VARS IF THEN ELSE WHILE DO OUTPUT ASSIGN ASPECT SPAWN ACQUIRE FREE RELEASE
%token RENDEZVOUS SEND_ASYNCH SEND_SYNCH HALT_THREAD HALT_AGENT HALT_SYSTEM

%token ERROR

%union {
  Node* node;
}

%type <node> firststmt stmt exp;

%start firststmt

%%

firststmt : stmt { state = $1; }

stmt : { $$ = NULL; }
     | stmt SEMI stmt { $$ = $1; if (!$$) $$ = $3; if ($1 && $3) { $1->next = $3; $3->previous = $1; } }
     | IF exp THEN stmt ELSE stmt { $$ = new_node(); }

exp : BOOLEAN { $$ = new_node(); }
    | INT { $$ = new_node(); }
    | REAL { $$ = new_node(); }
    | VAR_ID { $$ = new_node(); }

%%

int main() {
  yyparse();
  print_node(state);
  return 0;
}
