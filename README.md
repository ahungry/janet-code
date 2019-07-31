# Janet Code

Tinkering with Janet language - what things could I do with it...hmm...

See https://janet-lang.org for a cool language.

# Custom modules
Well, it turns out I was able to do some neat things.

## Bench

This is a module for benchmarking memory usage and time usage of
various forms.

```clojure
# See some memory/timing results of slurping a file we created and waiting.
(time
 (os/shell "dd if=/dev/zero of=/tmp/dummy.img bs=512 count=1024")
 (map (fn [x] (slurp "/tmp/dummy.img") x) (range 10))
 (os/sleep 1.3))
```

Evals to nil and prints out:

```sh
1024+0 records in
1024+0 records out
524288 bytes (524 kB, 512 KiB) copied, 0.00287159 s, 183 MB/s
RSS:                8286208 (7.90 MB)
Form memory usage:  5140480 (4.90 MB)
CPU time taken:     0.004529 (sec)
Real time taken:    1.316339 (sec)
```

## Futures

This is a module for Clojure like futures.

```clojure
(import build/futures :as f)

(defn sleep-future [n]
  (f/future
   (fn []
       (os/sleep n)
       n)))

(defn test-realize-all []
  (let [futures (map sleep-future (range 5))]
    (f/realize-all futures)))

# Will resolve in 4 seconds, not in 10. :)
(test-realize-all)
```
