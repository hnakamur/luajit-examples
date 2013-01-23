local ffi = require "ffi"
local tf = ffi.load("thread_func")
local pt = ffi.load("pthread")

ffi.cdef[[
void *func1(void *data);
]]

ffi.cdef[[
typedef struct pthread_s { char opaque[8]; } pthread_t;
typedef struct pthread_attr_s { char opaque[64]; } pthread_attr_t;

int pthread_create(
  pthread_t *thread,
  const pthread_attr_t *attr,
  void *(*start_routine)(void *),
  void *arg
);

int pthread_join(
  pthread_t thread,
  void **value_ptr
);
]]

threadA = ffi.new("pthread_t[1]")
print("thread", threadA)
print("thread[0]", threadA[0])

local res = pt.pthread_create(threadA, nil, tf.func1, ffi.cast("void *", "A"))
print("A res", res)

threadB = ffi.new("pthread_t[1]")
res = pt.pthread_create(threadB, nil, tf.func1, ffi.cast("void *", "B"))
print("B res", res)

for i = 1, 10 do
  print("main", i)
end

local res2 = pt.pthread_join(threadB[0], nil)
print("B res2", res2)

res2 = pt.pthread_join(threadA[0], nil)
print("A res2", res2)
