#include "okk/types.h"

Node* new_node(const char* type);

Node* bool_value(long int value);
Node* integer_value(long int value);
Node* real_value(double value);
Node* var_id(char* name, int length);

Node* unevaluated_node(Node* children);
Node* add_child(Node* parent, Node* new_child);
