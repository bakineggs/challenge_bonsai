%{
  #include "okk/types.h"
  #include "okk/print.h"

  extern int yylex();

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

%token <bool> BOOL
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

%type <node> stmt exp;

%start stmt

%%

stmt : stmt SEMI stmt
     | IF exp THEN stmt ELSE stmt

exp : BOOL
    | INT
    | REAL
    | VAR_ID

%%
