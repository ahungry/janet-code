#include <janet.h>
#include <string.h>
#include <iup.h>

#include "iup_wrap.c"

int
main (int argc, char *argv[])
{
  JanetTable *env;

  janet_init ();
  env = janet_core_env (NULL);
  janet_cfuns (env, "iup", cfuns);

  const char *embed = "(import iup :as i) (i/main)";

  janet_dostring (env, embed, "main", NULL);
  janet_deinit();

  return 0;
}
