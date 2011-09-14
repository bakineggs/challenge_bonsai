#include <stdlib.h>
#include <string>
#include "types.h"

Node* new_node(const char* type) {
  Node* node = (Node*) malloc(sizeof(Node));
  node->previous = NULL;
  node->next = NULL;
  node->type = (char*) malloc(sizeof(char) * (strlen(type) + 1));
  strcpy(node->type, type);
  node->ordered = false;
  node->value_type = none;
  node->parent = NULL;
  node->children = NULL;
  return node;
}

Node* add_child(Node* parent, Node* new_child) {
  Node* sibling = new_child;
  do { sibling->parent = parent; } while (sibling = sibling->next);

  if (parent->children) {
    Node* child = parent->children;
    while (child->next) child = child->next;
    new_child->previous = child;
    child->next = new_child;
  } else
    parent->children = new_child;

  return parent;
}

Node* bool_value(long int value) {
  Node* bool_node = new_node("Bool");
  bool_node->value_type = integer;
  bool_node->integer_value = value;

  Node* value_node = new_node("Value");
  add_child(value_node, bool_node);
  return value_node;
}

Node* integer_value(long int value) {
  Node* integer_node = new_node("Integer");
  integer_node->value_type = integer;
  integer_node->integer_value = value;

  Node* value_node = new_node("Value");
  add_child(value_node, integer_node);
  return value_node;
}

Node* real_value(double value) {
  Node* real_node = new_node("Real");
  real_node->value_type = decimal;
  real_node->decimal_value = value;

  Node* value_node = new_node("Value");
  add_child(value_node, real_node);
  return value_node;
}

Node* var_id(char* name, int length) {
  Node* node = new_node("VarId");
  node->string_value = (char*) malloc(sizeof(char) * (length + 1));
  strcpy(node->string_value, name);
  return node;
}

Node* unevaluated_node(Node* children) {
  Node* unevaluated = new_node("Unevaluated");
  unevaluated->ordered = true;
  add_child(unevaluated, children);
  return unevaluated;
}
