# Sapmle usage of the bench module

(import build/bench :as b)

# The main timing function - receives a lambda and profiles it.
(doc b/ftime)

# A useful macro, but will only work well if you use the module.
(use build/bench)

# See some memory/timing results of slurping a file we created and waiting.
(time
 (os/shell "dd if=/dev/zero of=/tmp/dummy.img bs=512 count=1024")
 (map (fn [x] (slurp "/tmp/dummy.img") x) (range 10))
 (os/sleep 1.3))

(doc time)
