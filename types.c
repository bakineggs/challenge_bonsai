#include <stdlib.h>
#include <string>
#include "types.h"

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

Node* value_parent(Node* node) {
  Node* parent = new_node();
  parent->type = (char*) "Value";
  parent->children = node;
  node->parent = parent;
  return parent;
}

Node* bool_value(long int value) {
  Node* node = new_node();
  node->type = (char*) "Bool";
  node->integer_value = (long int*) malloc(sizeof(long int));
  *node->integer_value = value;
  return value_parent(node);
}

Node* integer_value(long int value) {
  Node* node = new_node();
  node->type = (char*) "Integer";
  node->integer_value = (long int*) malloc(sizeof(long int));
  *node->integer_value = value;
  return value_parent(node);
}

Node* real_value(double value) {
  Node* node = new_node();
  node->type = (char*) "Real";
  node->decimal_value = (double*) malloc(sizeof(double));
  *node->decimal_value = value;
  return value_parent(node);
}

Node* var_id(char* name, int length) {
  Node* node = new_node();
  node->type = (char*) "VarId";
  node->string_value = (char*) malloc(sizeof(char) * (length + 1));
  strcpy(node->string_value, name);
  return node;
}
