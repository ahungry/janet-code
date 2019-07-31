#include <janet.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

static Janet myfun (int32_t argc, const Janet *argv)
{
  janet_fixarity (argc, 0);
  printf ("hello from a module!\n");

  return janet_wrap_nil ();
}

static Janet my_get_one (int32_t argc, const Janet *argv)
{
  janet_fixarity (argc, 0);

  return janet_wrap_number (1);
}

int32_t x = 0;
int32_t y = 0;
int32_t z = 0;

int my_sum_compute () {
  sleep (10);
  z = x + y;
  return z;
}

static Janet my_sum (int32_t argc, const Janet *argv)
{
  janet_fixarity (argc, 2);
  x = janet_unwrap_integer (argv[0]);
  y = janet_unwrap_integer (argv[1]);
  pthread_t pth;
  pthread_create (&pth, NULL, my_sum_compute, NULL);
  // my_sum_compute ();
  return janet_wrap_nil ();
}

static Janet my_sum_get (int32_t argc, const Janet *argv) {
  janet_fixarity (argc, 0);
  return janet_wrap_number (z);
}

// Finally! Working function invocation...
static Janet my_fn (int32_t argc, const Janet *argv) {
  janet_fixarity (argc, 1);
  JanetFunction *func = janet_getfunction (argv, 0);
  JanetFiber *fiber = janet_fiber (func, 64, 0, NULL);
  Janet out;
  JanetFiberStatus status = janet_continue (fiber, janet_wrap_nil (), &out);

  if (status != JANET_STATUS_PENDING) {
    janet_stacktrace (fiber, out);
  }

  return out;
}

// For the callback concurrency support.
struct arg_struct {
  JanetFunction *fn1;
  JanetFunction *fn2;
  JanetTable *env;
  JanetFiber *fiber;
};

// Segfaults and panics galore - probably due to running on a thread
// that is not on the VM itself and trying to call into the interpreter.
void *pthread_fn (void *arguments) {
  struct arg_struct *args = arguments;
  JanetFunction *func1 = args->fn1;
  JanetFunction *func2 = args->fn2;
  JanetTable *env = args->env;
  // JanetFiber *fiber = args->fiber;

  printf ("hello from a module pre-init! \n");
  janet_init ();

  JanetFiber *fiber = janet_fiber (func1, 64, 0, NULL);
  // Janet out;
  // JanetFiberStatus status = janet_continue (fiber, janet_wrap_nil (), &out);

  janet_continue (fiber, janet_wrap_nil (), NULL);
  printf ("hello from a module post-fiber! \n");
  // Janet out1 = janet_call (func1, 0, NULL);

  /* Janet out1 = janet_call (func1, 0, NULL); */
  /* Janet func2Args[] = { out1 }; */
  /* Janet out2 = janet_call (func2, 1, func2Args); */

  // pthread_exit (NULL);
  return NULL;
}

static Janet my_fnx_pthread (int32_t argc, const Janet *argv) {
  janet_fixarity (argc, 2);
  pthread_t ptr;
  struct arg_struct args;
  JanetFunction *func1 = janet_getfunction (argv, 0);
  JanetFunction *func2 = janet_getfunction (argv, 1);
  JanetFiber *currentFiber = janet_current_fiber ();
  JanetTable *currentEnv = currentFiber->env;
  args.fn1 = func1;
  args.fn2 = func2;
  args.env = currentEnv;
  args.fiber = currentFiber;

  if (pthread_create (&ptr, NULL, &pthread_fn, (void *) &args) != 0) {
    // TODO: Signal an ERROR keyword
    return janet_wrap_nil ();
  }

  // TODO: Signal a PENDING keyword
  return janet_wrap_nil ();
}

// Sample of eval fn1 and passing as input to fn2
static Janet my_fnx (int32_t argc, const Janet *argv) {
  janet_fixarity (argc, 2);
  JanetFunction *func1 = janet_getfunction (argv, 0);
  JanetFunction *func2 = janet_getfunction (argv, 1);

  Janet out1 = janet_call (func1, 0, NULL);
  Janet func2Args[] = { out1 };
  Janet out2 = janet_call (func2, 1, func2Args);

  return out2;
}


#define MAP_ANONYMOUS 0x20

typedef struct node {
  int id;
  Janet *future_out;
  struct node * next;
} node_t;

// Push a node to end of list
// https://cboard.cprogramming.com/c-programming/108964-problem-linked-list-shared-memory.html
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

// We would probably need a way to have a linked list of all
// futures, otherwise we're going to have one at a time...
// We can ensure main call returns a reference to pull out in realize.
Janet *future_out;
int idx = 0;
node_t tmp_root_node = { -1, NULL, NULL };
node_t *root_node = NULL;

// Run something that we can get in the future.
// Weird, managed to hit a "janet out of memory" error.
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

  // Evaluation can work against the entire current ENV.
  // But, it immediately returns and does not give us any useful info.
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
  {"myfun", myfun, "(mymod/myfun)\n\nPrints a hello message."},
  {"my-get-one", my_get_one, "(mymod/my-get-one)\n\nReturns the number 1."},
  {"my-sum", my_sum, "(mymod/my-sum x y)\n\nReturns the sum of x and y."},
  {"my-sum-get", my_sum_get, "(mymod/my-sum-get)\n\nReturns the result of sum of x and y."},
  {"my-fn", my_fn, "(mymod/my-fn)\n\nReturns the result of invoking a closure."},
  {"my-fnx", my_fnx, "(mymod/my-fnx)\n\nReturns the result of invoking a closure f(g())."},
  {"future", future, "(mymod/future)\n\nDo the future."},
  {"realize", realize, "(mymod/realize)\n\nSee the future."},
  {NULL, NULL, NULL}
};

JANET_MODULE_ENTRY(JanetTable *env) {
  janet_cfuns (env, "mymod", cfuns);
}
