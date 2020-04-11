#include <string.h>

#include "janet.h"

int
main (int argc, char *argv[])
{
  JanetTable *env;
  JanetTable *replacements;

  janet_init ();

  replacements = janet_table (0);
  env = janet_core_env (replacements);

  janet_table_put(env, janet_ckeywordv("executable"), janet_cstringv(argv[0]));

  const unsigned char *embed = (unsigned char *) "(pp 32)";
  size_t embed_size = strlen ((char *) embed);

  janet_dobytes (env, embed, embed_size, "standalone.janet", NULL);
  janet_deinit();

  return 0;
}
