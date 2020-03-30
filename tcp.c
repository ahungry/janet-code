#include <janet.h>

#include <arpa/inet.h>  /* IP address conversion stuff */
#include <ctype.h>
#include <errno.h>
#include <netdb.h>      /* gethostbyname */
#include <netinet/in.h> /* INET constants and stuff */
#include <string.h>
#include <sys/socket.h> /* socket specific definitions */
#include <sys/types.h>
#include <unistd.h>

#define MAXBUF 1024 * 1024

struct world
{
  unsigned char tcp_listen_received[MAXBUF];
  int tcp_listen_received_len;
};

struct world world;

void
die (const char *s)
{
  perror (s);
  exit (1);
}

/**
 * Make a connected TCP socket.  Will return 0 on failure, else the sd.
 */
int
make_tcp_socket (int port, char *addr)
{
  int sock = 0;
  struct sockaddr_in remote;

  sock = socket (AF_INET, SOCK_STREAM, 0);

  if (0 > sock)
    {
      printf ("make_tcp_socket failure.\n");

      return 0;
    }

  remote.sin_family = AF_INET;
  remote.sin_port = htons (port);
  remote.sin_addr.s_addr = inet_addr (addr);

  if (connect (sock, (struct sockaddr *) &remote, sizeof (remote)))
    {
      printf ("Could not connect to that host and port\n");

      return 0;
    }

  return sock;
}

/**
 * Send some string to the destination socket.
 */
int
send_tcp (int sock, char *buf)
{
  int len = strlen (buf);

  return send (sock, buf, len, 0);
}


/**
 * Read some string from the destination socket.
 */
int
read_tcp (int sock, char *buf, int size)
{
  return read (sock, buf, size);
}

/**
 * Wrapper to handle making a TCP socket.
 */
static Janet
make_sock (int32_t argc, const Janet *argv)
{
  janet_fixarity (argc, 2);

  const uint8_t *host = janet_getstring (argv, 0);
  int port = janet_getinteger (argv, 1);
  int sock = make_tcp_socket (port, (char*) host);

  return janet_wrap_integer (sock);
}

/**
 * Wrapper to handle sending a string to a socket.
 */
static Janet
send_sock (int32_t argc, const Janet *argv)
{
  janet_fixarity (argc, 2);

  int sock = janet_getinteger (argv, 0);
  const uint8_t *s = janet_getstring (argv, 1);
  int res = send_tcp (sock, (char*) s);

  return janet_wrap_integer (res);
}

/**
 * Wrapper to handle reading a string from a socket.
 */
static Janet
read_sock (int32_t argc, const Janet *argv)
{
  janet_fixarity (argc, 2);

  int sock = janet_getinteger (argv, 0);
  int size = janet_getinteger (argv, 1);
  unsigned char buf[size]; // TODO: Allow user to specify max read size.

  // TODO: Inspect return value and send something out if it fails.
  read_tcp (sock, (char*) buf, size);

  const uint8_t *s = janet_string (buf, size);

  return janet_wrap_string (s);
}

static const JanetReg
cfuns[] = {
  {"make-sock", make_sock, "(tcp/make-sock host port)\n\nCreate connection to host:port over TCP."},
  {"send-sock", send_sock, "(tcp/send-sock sock string)\n\nSend string to sock over TCP."},
  {"read-sock", read_sock, "(tcp/read-sock sock)\n\nRead for incoming TCP."},
  {NULL, NULL, NULL}
};

JANET_MODULE_ENTRY(JanetTable *env) {
  janet_cfuns (env, "tcp", cfuns);
}
