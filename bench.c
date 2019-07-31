/*
 * Author:  David Robert Nadeau
 * Site:    http://NadeauSoftware.com/
 * License: Creative Commons Attribution 3.0 Unported License
 *          http://creativecommons.org/licenses/by/3.0/deed.en_US
 */

#if defined(_WIN32)
#include <windows.h>
#include <psapi.h>

#elif defined(__unix__) || defined(__unix) || defined(unix) || (defined(__APPLE__) && defined(__MACH__))
#include <unistd.h>
#include <sys/resource.h>

#if defined(__APPLE__) && defined(__MACH__)
#include <mach/mach.h>

#elif (defined(_AIX) || defined(__TOS__AIX__)) || (defined(__sun__) || defined(__sun) || defined(sun) && (defined(__SVR4) || defined(__svr4__)))
#include <fcntl.h>
#include <procfs.h>

#elif defined(__linux__) || defined(__linux) || defined(linux) || defined(__gnu_linux__)
#include <stdio.h>

#endif

#else
#error "Cannot define getPeakRSS( ) or getCurrentRSS( ) for an unknown OS."
#endif





/**
 * Returns the peak (maximum so far) resident set size (physical
 * memory use) measured in bytes, or zero if the value cannot be
 * determined on this OS.
 */
size_t getPeakRSS( )
{
#if defined(_WIN32)
    /* Windows -------------------------------------------------- */
    PROCESS_MEMORY_COUNTERS info;
    GetProcessMemoryInfo( GetCurrentProcess( ), &info, sizeof(info) );
    return (size_t)info.PeakWorkingSetSize;

#elif (defined(_AIX) || defined(__TOS__AIX__)) || (defined(__sun__) || defined(__sun) || defined(sun) && (defined(__SVR4) || defined(__svr4__)))
    /* AIX and Solaris ------------------------------------------ */
    struct psinfo psinfo;
    int fd = -1;
    if ( (fd = open( "/proc/self/psinfo", O_RDONLY )) == -1 )
        return (size_t)0L;      /* Can't open? */
    if ( read( fd, &psinfo, sizeof(psinfo) ) != sizeof(psinfo) )
    {
        close( fd );
        return (size_t)0L;      /* Can't read? */
    }
    close( fd );
    return (size_t)(psinfo.pr_rssize * 1024L);

#elif defined(__unix__) || defined(__unix) || defined(unix) || (defined(__APPLE__) && defined(__MACH__))
    /* BSD, Linux, and OSX -------------------------------------- */
    struct rusage rusage;
    getrusage( RUSAGE_SELF, &rusage );
#if defined(__APPLE__) && defined(__MACH__)
    return (size_t)rusage.ru_maxrss;
#else
    return (size_t)(rusage.ru_maxrss * 1024L);
#endif

#else
    /* Unknown OS ----------------------------------------------- */
    return (size_t)0L;          /* Unsupported. */
#endif
}





/**
 * Returns the current resident set size (physical memory use) measured
 * in bytes, or zero if the value cannot be determined on this OS.
 */
size_t getCurrentRSS( )
{
#if defined(_WIN32)
    /* Windows -------------------------------------------------- */
    PROCESS_MEMORY_COUNTERS info;
    GetProcessMemoryInfo( GetCurrentProcess( ), &info, sizeof(info) );
    return (size_t)info.WorkingSetSize;

#elif defined(__APPLE__) && defined(__MACH__)
    /* OSX ------------------------------------------------------ */
    struct mach_task_basic_info info;
    mach_msg_type_number_t infoCount = MACH_TASK_BASIC_INFO_COUNT;
    if ( task_info( mach_task_self( ), MACH_TASK_BASIC_INFO,
        (task_info_t)&info, &infoCount ) != KERN_SUCCESS )
        return (size_t)0L;      /* Can't access? */
    return (size_t)info.resident_size;

#elif defined(__linux__) || defined(__linux) || defined(linux) || defined(__gnu_linux__)
    /* Linux ---------------------------------------------------- */
    long rss = 0L;
    FILE* fp = NULL;
    if ( (fp = fopen( "/proc/self/statm", "r" )) == NULL )
        return (size_t)0L;      /* Can't open? */
    if ( fscanf( fp, "%*s%ld", &rss ) != 1 )
    {
        fclose( fp );
        return (size_t)0L;      /* Can't read? */
    }
    fclose( fp );
    return (size_t)rss * (size_t)sysconf( _SC_PAGESIZE);

#else
    /* AIX, BSD, Solaris, and Unknown OS ------------------------ */
    return (size_t)0L;          /* Unsupported. */
#endif
}

// Custom stuff from my side.

#include <janet.h>
#include <time.h>

// Benchmark/profile a call, tracking pre-call memory and post-call, as well as time taken.
static Janet ftime (int32_t argc, const Janet *argv) {
  struct timeval t0;
  struct timeval t1;
  gettimeofday(&t0, 0);
  clock_t time_start = clock ();
  int mem_start = getCurrentRSS ();
  janet_fixarity (argc, 1);
  JanetFunction *func1 = janet_getfunction (argv, 0);
  Janet out = janet_call (func1, 0, NULL);
  clock_t time_end = clock ();
  int mem_end = getCurrentRSS ();
  double time_taken_seconds = (time_end - time_start) / (double) CLOCKS_PER_SEC;
  double mem_end_mb = (double) mem_end / 1024.0 / 1024.0;
  double mem_taken_mb = (double) (mem_end - mem_start) / 1024.0 / 1024.0;
  gettimeofday(&t1, 0);
  long elapsed_microseconds = (t1.tv_sec - t0.tv_sec) * 1000000 + t1.tv_usec - t0.tv_usec;
  double elapsed_seconds = (double) elapsed_microseconds / 1000.0 / 1000.0;

  // Divide by 1000 more if we want milliseconds
  printf ("RSS:                %d (%0.2f MB)\n"
          "Form memory usage:  %d (%0.2f MB)\n"
          "CPU time taken:     %f (sec)\n"
          "Real time taken:    %f (sec)\n\n",
          mem_end, mem_end_mb,
          mem_end - mem_start, mem_taken_mb,
          time_taken_seconds,
          elapsed_seconds);

  return janet_wrap_nil ();
}

static const JanetReg cfuns[] = {
  {"ftime", ftime, "(bench/ftime)\n\nCompute memory and time taken for form evaluation."},
  {NULL, NULL, NULL}
};

extern const unsigned char *bench_lib_embed;
extern size_t bench_lib_embed_size;

JANET_MODULE_ENTRY(JanetTable *env) {
  janet_cfuns (env, "bench", cfuns);
  janet_dobytes(env,
                bench_lib_embed,
                bench_lib_embed_size,
                "bench_lib.janet",
                NULL);
}
