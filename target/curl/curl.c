#include <curl/curl.h>
#include <string.h>
#include <stdio.h>

int
main (int argc, char *argv[])
{
  CURL *result = curl_easy_init ();

  printf ("Success\n");

  return 0;
}
