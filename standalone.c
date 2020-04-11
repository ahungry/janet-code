#include <string.h>

#include <curl.h>

#include "amalg/janet.h"

int
main (int argc, char *argv[])
{
  JanetTable *env;
  JanetTable *replacements;

  janet_init ();

  replacements = janet_table (0);
  env = janet_core_env (replacements);

  janet_table_put(env, janet_ckeywordv("executable"), janet_cstringv(argv[0]));

  const char *embed = "(pp 32)";

  janet_dostring (env, embed, "standalone.janet", NULL);
  janet_deinit();

  printf ("%s\n", LIBCURL_VERSION);

  return 0;
}
