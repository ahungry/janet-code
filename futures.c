#include <janet.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

#define MAP_ANONYMOUS 0x20

typedef struct node {
  int id;
  Janet *future_out;
  struct node * next;
} node_t;

// Push a node to end of list
node_t * push (int id, Janet* future_out, node_t *node) {
  while (node->next != NULL) {
    node = node->next;
  }

  node_t next = { id, future_out, NULL };
  int size = sizeof (node_t);
  // node->next = malloc (size);
  node->next = mmap (NULL, size, PROT_READ | PROT_WRITE,
                     MAP_SHARED | MAP_ANONYMOUS, -1, 0);
  memcpy (node->next, &next, size);
  return node;
}

node_t * get_by_id (int id, node_t *node) {
  while (node->id != id && node->next != NULL) {
    node = node->next;
  }
  if (node->id == id) return node;
  return NULL;
}

Janet *future_out;
int idx = 0;
node_t tmp_root_node = { -1, NULL, NULL };
node_t *root_node = NULL;

static Janet future (int32_t argc, const Janet *argv) {
  janet_fixarity (argc, 1);
  JanetFunction *func1 = janet_getfunction (argv, 0);

  if (root_node == NULL) {
    root_node = mmap (NULL, sizeof (node_t) * 20, PROT_READ | PROT_WRITE,
                      MAP_SHARED | MAP_ANONYMOUS, -1, 0);
    memcpy (root_node, &tmp_root_node, sizeof (node_t));
  }

  Janet *future_out;
  future_out = mmap (NULL, sizeof *future_out, PROT_READ | PROT_WRITE,
                     MAP_SHARED | MAP_ANONYMOUS, -1, 0);
  push (++idx, future_out, &root_node);

  if (fork() == 0) {
    Janet out = janet_call (func1, 0, NULL);
    *future_out = out;
    exit (0);
  } else {
    const uint8_t *str = janet_keyword ("PENDING", 7);
    *future_out = janet_wrap_keyword (str);
  }

  return janet_wrap_number (idx);
  // return *future_out; // janet_wrap_nil ();
}

// TODO: When we realize, we should spin here until it is not pending.
static Janet realize (int32_t argc, const Janet *argv) {
  janet_fixarity (argc, 1);
  int x = janet_getinteger (argv, 0);
  node_t *node_realized = get_by_id (x, &root_node);

  if (node_realized == NULL) {
    const uint8_t *str = janet_keyword ("MISSING", 7);
    return janet_wrap_keyword (str);
  }

  return *node_realized->future_out;
}

static const JanetReg cfuns[] = {
  {"future", future, "(futures/future)\n\nDo the future."},
  {"realize", realize, "(futures/realize)\n\nSee the future."},
  {NULL, NULL, NULL}
};

extern const unsigned char *futures_lib_embed;
extern size_t futures_lib_embed_size;

JANET_MODULE_ENTRY(JanetTable *env) {
  janet_cfuns (env, "futures", cfuns);
  janet_dobytes(env,
                futures_lib_embed,
                futures_lib_embed_size,
                "futures_lib.janet",
                NULL);
}
