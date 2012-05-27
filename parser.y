%{
  #include <stdio.h>
  #include "bonsai/node_builder.h"

  extern int yylex();
  void yyerror(const char* error) { fprintf(stderr, "%s\n", error); }

  Node* computation;
%}

%token <node> VALUE
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
       set_node("Statement1", $1);
       set_node("Statement2", $3);
       $$ = build_node("\
         $Statement1\
         $Statement2\
       ");
     }

     | VARS var_list {
       set_node("Vars", $2);
       $$ = build_node("\
         Vars:\
           $Vars\
       ");
     }

     | OPENBLOCK stmt CLOSEBLOCK {
       set_node("Body", $2);
       $$ = build_node("\
         Block::\
           $Body\
       ");
     }

     | IF exp THEN stmt ELSE stmt {
       set_node("Condition", $2);
       set_node("Then", $4);
       set_node("Else", $6);
       $$ = build_node("\
         If:\
           Condition:\
             Unevaluated::\
               $Condition\
           Then::\
             $Then\
           Else::\
             $Else\
       ");
     }

     | WHILE exp DO stmt {
       set_node("Condition", $2);
       set_node("Body", $4);
       $$ = build_node("\
         While:\
           Condition:\
             Unevaluated::\
               $Condition\
           Body::\
             $Body\
       ");
     }

     | OUTPUT exp {
       set_node("Output", $2);
       $$ = build_node("\
         Output:\
           Unevaluated::\
             $Output\
       ");
     }

     | exp ASSIGN exp {
       set_node("VarId", $1);
       set_node("Value", $3);
       $$ = build_node("\
         Assignment:\
           $VarId\
           Unevaluated::\
             $Value\
       ");
     }

     | ASPECT stmt {
       set_node("Body", $2);
       $$ = build_node("\
         Aspect::\
           $Body\
       ");
     }

     | SPAWN stmt {
       set_node("Body", $2);
       $$ = build_node("\
         Spawn::\
           $Body\
       ");
     }

     | ACQUIRE exp {
       set_node("Value", $2);
       $$ = build_node("\
         Acquire:\
           Unevaluated::\
             $Value\
       ");
     }

     | FREE exp {
       set_node("Value", $2);
       $$ = build_node("\
         Free:\
           Unevaluated::\
             $Value\
       ");
     }

     | RELEASE exp {
       set_node("Value", $2);
       $$ = build_node("\
         Release:\
           Unevaluated::\
             $Value\
       ");
     }

     | RENDEZVOUS exp {
       set_node("Value", $2);
       $$ = build_node("\
         Rendezvous:\
           Unevaluated::\
             $Value\
       ");
     }

     | SEND_ASYNCH exp COMMA exp {
       set_node("Receiver", $2);
       set_node("Message", $4);
       $$ = build_node("\
         SendAsynch:\
           Receiver:\
             Unevaluated::\
               $Receiver\
           Message:\
             Unevaluated::\
               $Message\
       ");
     }

     | SEND_SYNCH exp COMMA exp {
       set_node("Receiver", $2);
       set_node("Message", $4);
       $$ = build_node("\
         SendSynch:\
           Receiver:\
             Unevaluated::\
               $Receiver\
           Message:\
             Unevaluated::\
               $Message\
       ");
     }

     | HALT_THREAD { $$ = build_node("HaltThread:"); }

     | HALT_AGENT { $$ = build_node("HaltAgent:"); }

     | HALT_SYSTEM { $$ = build_node("HaltSystem:"); }

exp : VALUE {
      set_node("Value", $1);
      $$ = build_node("\
        Value:\
          $Value\
      ");
    }

    | VAR_ID

    | exp PLUS exp {
      set_node("Addend1", $1);
      set_node("Addend2", $3);
      $$ = build_node("\
        Addition:\
          Unevaluated::\
            $Addend1\
          Unevaluated::\
            $Addend2\
      ");
    }

    | exp STAR exp {
      set_node("Multiplicand1", $1);
      set_node("Multiplicand2", $3);
      $$ = build_node("\
        Multiplication:\
          Unevaluated::\
            $Multiplicand1\
          Unevaluated::\
            $Multiplicand2\
      ");
    }

    | exp DIV exp {
      set_node("Dividend", $1);
      set_node("Divisor", $3);
      $$ = build_node("\
        Division:\
          Dividend:\
            Unevaluated::\
              $Dividend\
          Divisor:\
            Unevaluated::\
              $Divisor\
      ");
    }

    | exp LEQ exp {
      set_node("Smaller", $1);
      set_node("Larger", $3);
      $$ = build_node("\
        LessThanOrEqualTo:\
          Smaller:\
            Unevaluated::\
              $Smaller\
          Larger:\
            Unevaluated::\
              $Larger\
      ");
    }

    | NOT exp {
      set_node("Expression", $2);
      $$ = build_node("\
        Not:\
          Unevaluated::\
            $Expression\
      ");
    }

    | exp AND exp {
      set_node("First", $1);
      set_node("Second", $3);
      $$ = build_node("\
        And:\
          First:\
            Unevaluated::\
              $First\
          Second:\
            Unevaluated::\
              $Second\
      ");
    }

    | INCREMENT exp {
      set_node("Expression", $2);
      $$ = build_node("\
        Increment:\
          Unevaluated::\
            $Expression\
      ");
    }

    | stmt SEMI exp {
      set_node("Statement", $1);
      set_node("Expression", $3);
      $$ = build_node("\
        $Statement\
        $Expression\
      ");
    }

    | MALLOC exp {
      set_node("Size", $2);
      $$ = build_node("\
        Malloc:\
          Unevaluated::\
            $Size\
      ");
    }

    | REF VAR_ID {
      set_node("Variable", $2);
      $$ = build_node("\
        Reference:\
          $Variable\
      ");
    }

    | STAR exp {
      set_node("Location", $2);
      $$ = build_node("\
        Dereference:\
          Unevaluated::\
            $Location\
      ");
    }

    | LAMBDA var_list DOT stmt {
      set_node("Vars", $2);
      set_node("Body", $4);
      $$ = build_node("\
        LambdaAbstraction:\
          Vars::\
            $Vars\
          Body::\
            $Body\
      ");
    }

    | exp LPAREN exp_list RPAREN {
      set_node("Function", $1);
      set_node("Arguments", $3);
      $$ = build_node("\
        Application:\
          Unevaluated::\
            $Function\
          Arguments::\
            $Arguments\
      ");
    }

    | MU VAR_ID DOT exp {
      set_node("Var", $2);
      set_node("Body", $4);
      $$ = build_node("\
        MuConstruct:\
          $Var\
          Body::\
            $Body\
      ");
    }

    | CALLCC exp {
      set_node("Expression", $2);
      $$ = build_node("\
        Callcc:\
          Unevaluated::\
            $Expression\
      ");
    }

    | RANDOM_BOOL { $$ = build_node("RandomBool:"); }

    | NEW_AGENT stmt {
      set_node("Statement", $2);
      $$ = build_node("\
        NewAgent::\
          $Statement\
      ");
    }

    | ME { $$ = build_node("Me:"); }

    | PARENT { $$ = build_node("Parent:"); }

    | RECEIVE { $$ = build_node("Receive:"); }

    | RECEIVE_FROM exp {
      set_node("Agent", $2);
      $$ = build_node("\
        ReceiveFrom:\
          Unevaluated::\
            $Agent\
      ");
    }

    | QUOTE exp {
      set_node("Exp", $2);
      $$ = build_node("\
        Quote::\
          $Exp\
      ");
    }

    | UNQUOTE exp {
      set_node("Exp", $2);
      $$ = build_node("\
        Unquote::\
          $Exp\
      ");
    }

    | EVAL exp {
      set_node("Exp", $2);
      $$ = build_node("\
        Eval:\
          Unevaluated::=\
            $Exp\
      ");
    }

    | LPAREN exp RPAREN { $$ = $2; }

var_list : VAR_ID
         | var_list COMMA VAR_ID {
           set_node("Vars", $1);
           set_node("Var", $3);
           $$ = build_node("\
             $Vars\
             $Var\
           ");
         }

exp_list : exp {
           set_node("Expression", $1);
           $$ = build_node("\
             Unevaluated::\
               $Expression\
           ");
         }

         | exp_list COMMA exp {
           set_node("Expressions", $1);
           set_node("Expression", $3);
           $$ = build_node("\
             $Expressions\
             Unevaluated::\
               $Expression\
           ");
         }
%%
