%{
  #include <stdlib.h>
  #include <stdio.h>

  #include "types.h"
  #include "okk/print.h"
  #include "okk/node_builder.h"

  extern int yylex();
  void yyerror(const char* error) { fprintf(stderr, "%s\n", error); }

  Node* computation;
%}

%token <node> BOOLEAN
%token <node> INT
%token <node> REAL
%token <node> VAR_ID
%token PLUS STAR DIV LEQ NOT AND INCREMENT SEMI MALLOC REF LAMBDA DOT MU CALLCC
%token RANDOM_BOOL NEW_AGENT ME PARENT RECEIVE RECEIVE_FROM QUOTE UNQUOTE EVAL
%token VARS IF THEN ELSE WHILE DO OUTPUT ASSIGN ASPECT SPAWN ACQUIRE FREE RELEASE
%token RENDEZVOUS SEND_ASYNCH SEND_SYNCH HALT_THREAD HALT_AGENT HALT_SYSTEM COMMA
%token OPENBLOCK CLOSEBLOCK LPAREN RPAREN

%union {
  Node* node;
}

%type <node> firststmt stmt exp var_list exp_list;

%start firststmt

%right SEMI
%nonassoc ELSE
%left COMMA
%nonassoc MALLOC REF DOT CALLCC NEW_AGENT INCREMENT RECEIVE_FROM EVAL QUOTE UNQUOTE DO OUTPUT ASSIGN ASPECT SPAWN ACQUIRE FREE RELEASE RENDEZVOUS
%nonassoc NOT
%left AND
%nonassoc LEQ
%left PLUS
%right LPAREN
%left STAR DIV

%%

firststmt : stmt { computation = $1; }

stmt : { $$ = NULL; }
     | stmt SEMI stmt {
       $$ = $1 ? $1 : $3;
       if ($1 && $3) {
         $1->next = $3;
         $3->previous = $1;
       }
     }
     | OPENBLOCK VARS var_list SEMI stmt CLOSEBLOCK {
       set_node("Vars", $3);
       set_node("Body", $5);
       $$ = build_node("
         Block:
           Vars::
             $Vars
           Body::
             $Body
       ");
     }
     | OPENBLOCK stmt CLOSEBLOCK {
       set_node("Body", $2);
       $$ = build_node("
         Block:
           Vars::
           Body::
             $Body
       ");
     }
     | IF exp THEN stmt ELSE stmt {
       set_node("Condition", $2);
       set_node("Then", $4);
       set_node("Else", $6);
       $$ = build_node("
         If:
           Condition:
             Unevaluated::
               $Condition
           Then::
             $Then
           Else::
             $Else
       ");
     }
     | WHILE exp DO stmt {
       set_node("Condition", $2);
       set_node("Body", $4);
       $$ = build_node("
         While:
           Condition:
             Unevaluated::
               $Condition
           Body::
             $Body
       ");
     }
     | OUTPUT exp {
       set_node("Output", $2);
       $$ = build_node("
         Output:
           Unevaluated::
             $Output
       ");
     }
     | exp ASSIGN exp {
       set_node("VarId", $1);
       set_node("Value", $3);
       $$ = build_node("
         Assignment:
           $VarId
           Unevaluated::
             $Value
       ");
     }
     | ASPECT stmt {
       set_node("Body", $2);
       $$ = build_node("
         Aspect::
           $Body
       ");
     }
     | SPAWN stmt {
       set_node("Body", $2);
       $$ = build_node("
         Spawn::
           $Body
       ");
     }
     | ACQUIRE exp {
       set_node("Value", $2);
       $$ = build_node("
         Acquire:
           Unevaluated::
             $Value
       ");
     }
     | FREE exp {
       set_node("Value", $2);
       $$ = build_node("
         Free:
           Unevaluated::
             $Value
       ");
     }
     | RELEASE exp {
       set_node("Value", $2);
       $$ = build_node("
         Release:
           Unevaluated::
             $Value
       ");
     }
     | RENDEZVOUS exp {
       set_node("Value", $2);
       $$ = build_node("
         Rendezvous:
           Unevaluated::
             $Value
       ");
     }
     | SEND_ASYNCH exp COMMA exp {
       set_node("Receiver", $2);
       set_node("Message", $4);
       $$ = build_node("
         SendAsynch:
           Receiver:
             Unevaluated::
               $Receiver
           Message:
             Unevaluated::
               $Message
       ");
     }
     | SEND_SYNCH exp COMMA exp {
       set_node("Receiver", $2);
       set_node("Message", $4);
       $$ = build_node("
         SendSynch:
           Receiver:
             Unevaluated::
               $Receiver
           Message:
             Unevaluated::
               $Message
       ");
     }
     | HALT_THREAD { $$ = build_node("HaltThread:"); }
     | HALT_AGENT { $$ = build_node("HaltAgent:"); }
     | HALT_SYSTEM { $$ = build_node("HaltSystem:"); }

exp : BOOLEAN
    | INT
    | REAL
    | VAR_ID
    | exp PLUS exp { $$ = new_node("Addition"); add_child($$, unevaluated_node($1)); add_child($$, unevaluated_node($3)); }
    | exp STAR exp { $$ = new_node("Multiplication"); add_child($$, unevaluated_node($1)); add_child($$, unevaluated_node($3)); }
    | exp DIV exp {
      $$ = new_node("Division");
      add_child($$, add_child(new_node("Dividend"), unevaluated_node($1)));
      add_child($$, add_child(new_node("Divisor"), unevaluated_node($3)));
    }
    | exp LEQ exp {
      $$ = new_node("LessThanOrEqualTo");
      add_child($$, add_child(new_node("Smaller"), unevaluated_node($1)));
      add_child($$, add_child(new_node("Larger"), unevaluated_node($3)));
    }
    | NOT exp { $$ = add_child(new_node("Not"), unevaluated_node($2)); }
    | exp AND exp {
      $$ = new_node("And");
      add_child($$, add_child(new_node("First"), unevaluated_node($1)));
      add_child($$, add_child(new_node("Second"), unevaluated_node($1)));
    }
    | INCREMENT exp { $$ = add_child(new_node("Increment"), unevaluated_node($2)); }
    | stmt SEMI exp { $$ = $1; if (!$$) $$ = $3; if ($1 && $3) { $1->next = $3; $3->previous = $1; } }
    | MALLOC exp { $$ = add_child(new_node("Malloc"), unevaluated_node($2)); }
    | REF exp { $$ = add_child(new_node("Reference"), $2); }
    | STAR exp { $$ = add_child(new_node("Dereference"), unevaluated_node($2)); }
    | LAMBDA var_list DOT stmt {
      $$ = new_node("LambdaAbstraction");
      Node* vars = new_node("Vars");
      vars->ordered = true;
      add_child($$, add_child(vars, $2));
      Node* body = new_node("Body");
      body->ordered = true;
      add_child($$, add_child(body, $4));
    }
    | exp LPAREN exp_list RPAREN {
      $$ = new_node("Application");
      add_child($$, unevaluated_node($1));
      Node* arguments = new_node("Arguments");
      arguments->ordered = true;
      add_child($$, add_child(arguments, $3));
    }
    | MU VAR_ID DOT exp {
      $$ = new_node("MuConstruct");
      add_child($$, $2);
      Node* body = new_node("Body");
      body->ordered = true;
      add_child($$, add_child(body, $4));
    }
    | CALLCC exp { $$ = add_child(new_node("Callcc"), unevaluated_node($2)); }
    | RANDOM_BOOL { $$ = new_node("RandomBool"); }
    | NEW_AGENT stmt { $$ = add_child(new_node("NewAgent"), $2); $$->ordered = true; }
    | ME { $$ = new_node("Me"); }
    | PARENT { $$ = new_node("Parent"); }
    | RECEIVE { $$ = new_node("Receive"); }
    | RECEIVE_FROM exp { $$ = add_child(new_node("ReceiveFrom"), unevaluated_node($2)); }
    | QUOTE exp { $$ = NULL; }
    | UNQUOTE exp { $$ = NULL; }
    | EVAL exp { $$ = NULL; }
    | LPAREN exp RPAREN { $$ = $2; }

var_list : VAR_ID
         | var_list COMMA VAR_ID { $$->next = $3; $3->previous = $$; }

exp_list : exp
         | exp_list COMMA exp { $$->next = $3; $3->previous = $$; }
%%
