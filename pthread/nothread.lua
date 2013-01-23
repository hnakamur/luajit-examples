local ffi = require "ffi"
local tf = ffi.load("thread_func")

ffi.cdef[[
void *func1(void *data);
]]

tf.func1(nil)
