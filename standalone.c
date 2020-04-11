#include <janet.h>
#include <string.h>
#include <curl.h>

#include "curl_wrap.c"

int
main (int argc, char *argv[])
{
  JanetTable *env;

  janet_init ();
  env = janet_core_env (NULL);
  janet_cfuns (env, "curl", cfuns);

  const char *embed = "(import standalone :as s) (s/main)";

  janet_dostring (env, embed, "main", NULL);
  janet_deinit();

  return 0;
}
