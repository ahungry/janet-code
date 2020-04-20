# Super app/repl

So far the following builds in both/works in one or the other:

- IUP (GUI) - GNU/Linux (.so) / Windows (static)
- cURL - GNU/Linux (.so) / Windows (dll)
- circlet (HTTP server) - GNU/Linux (static) / Windows (segfault)
- FAIL - future (shm fork) - GNU/Linux (static) / Windows (no forking, will
  not work)
- sqlite3 - GNU/Linux (shared) / Windows (dll)
- json - GNU/Linux (static) / Windows (static)

The process had to be updated from modifying/including in app level to
recompiling the amalg janet source, otherwise non BIF will not work in
the thread callbacks due to symbol missing in global resolution stuff.

# TODO

Try out these:

    "https://github.com/janet-lang/sqlite3.git"
    "https://github.com/janet-lang/argparse.git"
    "https://github.com/janet-lang/path.git"
    "https://github.com/andrewchambers/janet-uri.git"
    "https://github.com/andrewchambers/janet-jdn.git"
    "https://github.com/andrewchambers/janet-flock.git"
    "https://github.com/andrewchambers/janet-process.git"
    "https://github.com/andrewchambers/janet-sh.git"
    "https://github.com/andrewchambers/janet-base16.git"
