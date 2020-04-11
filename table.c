// FIXME: This needs a bit of fixing up, its not quite right.
// https://janet-lang.org/capi/memory-model.html

#include <janet.h>

#include <stdio.h>
#include <string.h>

static Janet
make_table (int32_t argc, const Janet *argv)
{
  janet_fixarity (argc, 2);

  int x = janet_getinteger (argv, 0);
  int y = janet_getinteger (argv, 1);

  struct JanetGCObject gc = { 0, NULL };
  unsigned char k[2];
  k[0] = 'x';
  Janet key = janet_wrap_string (janet_string (k, 1));
  Janet val = janet_wrap_integer (x);
  struct JanetKV kv = { key, val };
  struct JanetTable t = {
    gc,
    2,
    2,
    0,
    &kv,
    NULL
  };

  return janet_wrap_table (&t);
}

static const JanetReg
cfuns[] = {
  {"make-table", make_table, "(table/make-table x y)"},
  {NULL, NULL, NULL}
};

JANET_MODULE_ENTRY (JanetTable *env)
{
  janet_cfuns (env, "tcp", cfuns);
}
