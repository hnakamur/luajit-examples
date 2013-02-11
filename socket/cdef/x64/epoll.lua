local ffi = require "ffi"

ffi.cdef[[
struct epoll_event {
  uint32_t events;   /* Epoll events */
  epoll_data_t data; /* User data variable */
} __attribute__ ((__packed__));
]]
