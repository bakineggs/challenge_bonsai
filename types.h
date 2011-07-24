#include "okk/types.h"

Node* new_node();

Node* bool_value(long int value);
Node* integer_value(long int value);
Node* real_value(double value);
Node* var_id(char* name, int length);
