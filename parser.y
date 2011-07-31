%{
  #include <stdlib.h>
  #include <stdio.h>

  #include "types.h"
  #include "okk/print.h"

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
%token OPENBLOCK CLOSEBLOCK STARTARGS ENDARGS

%token ERROR

%union {
  Node* node;
}

%type <node> firststmt stmt exp var_list exp_list;

%start firststmt

%%

firststmt : stmt { computation = $1; }

stmt : { $$ = NULL; }
     | stmt SEMI stmt { $$ = $1; if (!$$) $$ = $3; if ($1 && $3) { $1->next = $3; $3->previous = $1; } }
     | OPENBLOCK VARS var_list SEMI stmt CLOSEBLOCK {
       $$ = new_node("Block");
       Node* vars = new_node("Vars");
       vars->ordered = true;
       add_child($$, add_child(vars, $3));
       Node* body = new_node("Body");
       body->ordered = true;
       add_child($$, add_child(body, $5));
     }
     | IF exp THEN stmt ELSE stmt {
       $$ = add_child(new_node("If"), add_child(new_node("Condition"), unevaluated_node($2)));
       Node* then_stmt = add_child(new_node("Then"), $4);
       then_stmt->ordered = true;
       add_child($$, then_stmt);
       Node* else_stmt = add_child(new_node("Else"), $6);
       else_stmt->ordered = true;
       add_child($$, else_stmt);
     }
     | WHILE exp DO stmt {
       $$ = new_node("While");
       add_child($$, add_child(new_node("Condition"), unevaluated_node($2)));
       Node* body = new_node("Body");
       body->ordered = true;
       add_child($$, add_child(body, $4));
     }
     | OUTPUT exp { $$ = add_child(new_node("Output"), unevaluated_node($2)); }
     | exp ASSIGN exp { $$ = add_child(new_node("Assignment"), $1); add_child($$, unevaluated_node($3)); }
     | ASPECT stmt { $$ = add_child(new_node("Aspect"), $2); $$->ordered = true; }
     | SPAWN stmt { $$ = add_child(new_node("Spawn"), $2); $$->ordered = true; }
     | ACQUIRE exp { $$ = add_child(new_node("Acquire"), unevaluated_node($2)); }
     | FREE exp { $$ = add_child(new_node("Free"), unevaluated_node($2)); }
     | RELEASE exp { $$ = add_child(new_node("Release"), unevaluated_node($2)); }
     | RENDEZVOUS exp { $$ = add_child(new_node("Rendezvous"), unevaluated_node($2)); }
     | SEND_ASYNCH exp COMMA exp {
       $$ = new_node("SendAsynch");
       add_child($$, add_child(new_node("Receiver"), unevaluated_node($2)));
       add_child($$, add_child(new_node("Message"), unevaluated_node($4)));
     }
     | SEND_SYNCH exp COMMA exp {
       $$ = new_node("SendSynch");
       add_child($$, add_child(new_node("Receiver"), unevaluated_node($2)));
       add_child($$, add_child(new_node("Message"), unevaluated_node($4)));
     }
     | HALT_THREAD { $$ = new_node("HaltThread"); }
     | HALT_AGENT { $$ = new_node("HaltAgent"); }
     | HALT_SYSTEM { $$ = new_node("HaltSystem"); }

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
    | LAMBDA var_list DOT exp {
      $$ = new_node("LambdaAbstraction");
      Node* vars = new_node("Vars");
      vars->ordered = true;
      add_child($$, add_child(vars, $2));
      Node* body = new_node("Body");
      body->ordered = true;
      add_child($$, add_child(body, $4));
    }
    | exp STARTARGS exp_list ENDARGS {
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

var_list : VAR_ID
         | var_list COMMA VAR_ID { $$->next = $3; $3->previous = $$; }

exp_list : exp
         | exp_list COMMA exp { $$->next = $3; $3->previous = $$; }
%%

int main() {
  yyparse();

  Node* configuration = new_node("T");

  Node* agent = new_node("Agent");
  add_child(configuration, add_child(new_node("Agents"), agent));

  Node* thread = new_node("Thread");
  add_child(agent, add_child(new_node("Threads"), thread));

  Node* k = add_child(new_node("K"), computation);
  k->ordered = true;
  add_child(thread, k);

  add_child(thread, new_node("Env"));
  add_child(thread, new_node("Holds"));

  add_child(agent, new_node("Store"));
  add_child(agent, new_node("Aspect"));
  add_child(agent, new_node("Busy"));
  add_child(agent, new_node("Ptr"));

  Node* next_loc = new_node("NextLoc");
  next_loc->integer_value = (long int*) malloc(sizeof(long int));
  *next_loc->integer_value = 0;
  add_child(agent, next_loc);

  Node* me = new_node("Me");
  me->integer_value = (long int*) malloc(sizeof(long int));
  *me->integer_value = 0; // TODO: what is the starting Me value?
  add_child(agent, me);

  Node* parent = new_node("Parent");
  parent->integer_value = (long int*) malloc(sizeof(long int));
  *parent->integer_value = 0; // TODO: what is the starting Parent value?
  add_child(agent, parent);

  Node* output = new_node("Output");
  output->ordered = true;
  add_child(configuration, output);

  add_child(configuration, new_node("Messages"));

  Node* next_agent = new_node("NextAgent");
  next_agent->integer_value = (long int*) malloc(sizeof(long int));
  *next_agent->integer_value = 1;
  add_child(configuration, next_agent);

  print_node(configuration);
  return 0;
}
