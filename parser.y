%{
  #include <stdio.h>
  #include "bonsai/implementations/c/node_builder.h"
  #include "bonsai/implementations/c/print.h"

  extern int yylex();
  int yyparse();
  void yyerror(const char* error) { fprintf(stderr, "%s\n", error); }

  Node* computation;

  int main() {
    yyparse();
    print_node(computation, stdout);
    return 0;
  }
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
       if ($1 != NULL && $3 != NULL) {
         $$ = $1;
         Node* last_sibling = $$;
         while (last_sibling->next_sibling != NULL)
           last_sibling = last_sibling->next_sibling;
         last_sibling->next_sibling = $3;
         $3->previous_sibling = last_sibling;
       } else if ($1 != NULL) {
         $$ = $1;
       } else {
         $$ = $3;
       }
     }

     | VARS var_list { $$ = $2; }

     | OPENBLOCK stmt CLOSEBLOCK {
       set_node("Body", $2);
       $$ = build_node("\
         Block::\n\
           $Body\n\
       ");
     }

     | IF exp THEN stmt ELSE stmt {
       set_node("Condition", $2);
       set_node("Then", $4);
       set_node("Else", $6);
       $$ = build_node("\
         If:\n\
           Condition:\n\
             Unevaluated::\n\
               $Condition\n\
           Then::\n\
             $Then\n\
           Else::\n\
             $Else\n\
       ");
     }

     | WHILE exp DO stmt {
       set_node("Condition", $2);
       set_node("Body", $4);
       $$ = build_node("\
         While:\n\
           Condition:\n\
             Unevaluated::\n\
               $Condition\n\
           Body::\n\
             $Body\n\
       ");
     }

     | OUTPUT exp {
       set_node("Output", $2);
       $$ = build_node("\
         Output:\n\
           Unevaluated::\n\
             $Output\n\
       ");
     }

     | exp ASSIGN exp {
       set_node("VarId", $1);
       set_node("Value", $3);
       $$ = build_node("\
         Assignment:\n\
           $VarId\n\
           Unevaluated::\n\
             $Value\n\
       ");
     }

     | ASPECT stmt {
       set_node("Body", $2);
       $$ = build_node("\
         Aspect::\n\
           $Body\n\
       ");
     }

     | SPAWN stmt {
       set_node("Body", $2);
       $$ = build_node("\
         Spawn::\n\
           $Body\n\
       ");
     }

     | ACQUIRE exp {
       set_node("Value", $2);
       $$ = build_node("\
         Acquire:\n\
           Unevaluated::\n\
             $Value\n\
       ");
     }

     | FREE exp {
       set_node("Value", $2);
       $$ = build_node("\
         Free:\n\
           Unevaluated::\n\
             $Value\n\
       ");
     }

     | RELEASE exp {
       set_node("Value", $2);
       $$ = build_node("\
         Release:\n\
           Unevaluated::\n\
             $Value\n\
       ");
     }

     | RENDEZVOUS exp {
       set_node("Value", $2);
       $$ = build_node("\
         Rendezvous:\n\
           Unevaluated::\n\
             $Value\n\
       ");
     }

     | SEND_ASYNCH exp COMMA exp {
       set_node("Receiver", $2);
       set_node("Message", $4);
       $$ = build_node("\
         SendAsynch:\n\
           Receiver:\n\
             Unevaluated::\n\
               $Receiver\n\
           Message:\n\
             Unevaluated::\n\
               $Message\n\
       ");
     }

     | SEND_SYNCH exp COMMA exp {
       set_node("Receiver", $2);
       set_node("Message", $4);
       $$ = build_node("\
         SendSynch:\n\
           Receiver:\n\
             Unevaluated::\n\
               $Receiver\n\
           Message:\n\
             Unevaluated::\n\
               $Message\n\
       ");
     }

     | HALT_THREAD { $$ = build_node("HaltThread:"); }

     | HALT_AGENT { $$ = build_node("HaltAgent:"); }

     | HALT_SYSTEM { $$ = build_node("HaltSystem:"); }

exp : VALUE {
      set_node("Value", $1);
      $$ = build_node("\
        Value:\n\
          $Value\n\
      ");
    }

    | VAR_ID

    | exp PLUS exp {
      set_node("Addend1", $1);
      set_node("Addend2", $3);
      $$ = build_node("\
        Addition:\n\
          Unevaluated::\n\
            $Addend1\n\
          Unevaluated::\n\
            $Addend2\n\
      ");
    }

    | exp STAR exp {
      set_node("Multiplicand1", $1);
      set_node("Multiplicand2", $3);
      $$ = build_node("\
        Multiplication:\n\
          Unevaluated::\n\
            $Multiplicand1\n\
          Unevaluated::\n\
            $Multiplicand2\n\
      ");
    }

    | exp DIV exp {
      set_node("Dividend", $1);
      set_node("Divisor", $3);
      $$ = build_node("\
        Division:\n\
          Dividend:\n\
            Unevaluated::\n\
              $Dividend\n\
          Divisor:\n\
            Unevaluated::\n\
              $Divisor\n\
      ");
    }

    | exp LEQ exp {
      set_node("Left", $1);
      set_node("Right", $3);
      $$ = build_node("\
        LessThanOrEqualTo:\n\
          Left:\n\
            Unevaluated::\n\
              $Left\n\
          Right:\n\
            Unevaluated::\n\
              $Right\n\
      ");
    }

    | NOT exp {
      set_node("Expression", $2);
      $$ = build_node("\
        Not:\n\
          Unevaluated::\n\
            $Expression\n\
      ");
    }

    | exp AND exp {
      set_node("First", $1);
      set_node("Second", $3);
      $$ = build_node("\
        And:\n\
          First:\n\
            Unevaluated::\n\
              $First\n\
          Second:\n\
            Unevaluated::\n\
              $Second\n\
      ");
    }

    | INCREMENT exp {
      set_node("Expression", $2);
      $$ = build_node("\
        Increment:\n\
          Unevaluated::\n\
            $Expression\n\
      ");
    }

    | stmt SEMI exp {
      if ($1 != NULL) {
        $$ = $1;
        Node* last_sibling = $$;
        while (last_sibling->next_sibling != NULL)
          last_sibling = last_sibling->next_sibling;
        last_sibling->next_sibling = $3;
        $3->previous_sibling = last_sibling;
      } else
        $$ = $3;
    }

    | MALLOC exp {
      set_node("Size", $2);
      $$ = build_node("\
        Malloc:\n\
          Unevaluated::\n\
            $Size\n\
      ");
    }

    | REF VAR_ID {
      set_node("Variable", $2);
      $$ = build_node("\
        Reference:\n\
          $Variable\n\
      ");
    }

    | STAR exp {
      set_node("Location", $2);
      $$ = build_node("\
        Dereference:\n\
          Unevaluated::\n\
            $Location\n\
      ");
    }

    | LAMBDA var_list DOT stmt {
      set_node("Vars", $2);
      set_node("Body", $4);
      $$ = build_node("\
        LambdaAbstraction:\n\
          $Vars\n\
          Body::\n\
            $Body\n\
      ");
    }

    | exp LPAREN exp_list RPAREN {
      set_node("Function", $1);
      set_node("Arguments", $3);
      $$ = build_node("\
        Application:\n\
          Unevaluated::\n\
            $Function\n\
          $Arguments\n\
      ");
    }

    | MU VAR_ID DOT exp {
      set_node("Var", $2);
      set_node("Body", $4);
      $$ = build_node("\
        MuConstruct:\n\
          $Var\n\
          Body::\n\
            $Body\n\
      ");
    }

    | CALLCC exp {
      set_node("Expression", $2);
      $$ = build_node("\
        Callcc:\n\
          Unevaluated::\n\
            $Expression\n\
      ");
    }

    | RANDOM_BOOL { $$ = build_node("RandomBool:"); }

    | NEW_AGENT stmt {
      set_node("Statement", $2);
      $$ = build_node("\
        NewAgent::\n\
          $Statement\n\
      ");
    }

    | ME { $$ = build_node("Me:"); }

    | PARENT { $$ = build_node("Parent:"); }

    | RECEIVE { $$ = build_node("Receive:"); }

    | RECEIVE_FROM exp {
      set_node("Agent", $2);
      $$ = build_node("\
        ReceiveFrom:\n\
          Unevaluated::\n\
            $Agent\n\
      ");
    }

    | QUOTE exp {
      set_node("Exp", $2);
      $$ = build_node("\
        Quote::\n\
          $Exp\n\
      ");
    }

    | UNQUOTE exp {
      set_node("Exp", $2);
      $$ = build_node("\
        Unquote::\n\
          $Exp\n\
      ");
    }

    | EVAL exp {
      set_node("Exp", $2);
      $$ = build_node("\
        Eval:\n\
          Unevaluated::=\n\
            $Exp\n\
      ");
    }

    | LPAREN exp RPAREN { $$ = $2; }

var_list : VAR_ID {
           set_node("Var", $1);
           $$ = build_node("\
             Vars::\n\
               $Var\n\
           ");
         }

         | var_list COMMA VAR_ID {
           $$ = $1;
           Node* last_child = $$->children;
           while (last_child->next_sibling != NULL)
             last_child = last_child->next_sibling;
           $3->parent = $$;
           last_child->next_sibling = $3;
           $3->previous_sibling = last_child;
         }

exp_list : exp {
           set_node("Expression", $1);
           $$ = build_node("\
             Arguments::\n\
               Unevaluated::\n\
                 $Expression\n\
           ");
         }

         | exp_list COMMA exp {
           $$ = $1;
           Node* last_child = $$->children;
           while (last_child->next_sibling != NULL)
             last_child = last_child->next_sibling;

           Node* new_child = build_node("\
             Unevaluated::\n\
               $Expression\n\
           ");

           new_child->parent = $$;
           last_child->next_sibling = new_child;
           new_child->previous_sibling = last_child;
         }
%%
