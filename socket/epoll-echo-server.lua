local ffi = require "ffi"
require "cdef/socket"
require "cdef/epoll"
local C = ffi.C
local bir = require "bit"

ffi.cdef[[
static const int BUFSIZE = 1024;

struct clientinfo {
  int fd;
  char buf[BUFSIZE];
  int n;
};
]]

local listen_fd = C.socket(C.AF_INET, C.SOCK_STREAM, 0)
assert(listen_fd ~= -1)

local on = ffi.new("int32_t[1]", 1)
local rc = C.setsockopt(listen_fd, C.SOL_SOCKET, C.SO_REUSEADDR, on,
    ffi.sizeof(on))
assert(rc ~= -1)

local addr = ffi.new("struct sockaddr_in[1]")
addr[0].sin_family = C.AF_INET
addr[0].sin_port = C.htons(8000);
addr[0].sin_addr.s_addr = C.INADDR_ANY
rc = C.bind(listen_fd, ffi.cast("struct sockaddr *", addr), ffi.sizeof(addr))
assert(rc ~= -1)

rc = C.listen(listen_fd, 128)
assert(rc ~= -1)

local MAXEVENTS = 16
local epfd = C.epoll_create(MAXEVENTS)
assert(epfd ~= -1)

local event = ffi.new("struct epoll_event[1]")
event[0].events = C.EPOLLIN
event[0].data.fd = listen_fd
rc = C.epoll_ctl(epfd, C.EPOLL_CTL_ADD, listen_fd, event)
assert(rc ~= -1)

local events = ffi.new("struct epoll_event[?]", MAXEVENTS)
rc = C.epoll_wait(epfd, events, MAXEVENTS, -1)
assert(rc ~= -1)

while true do
  local nfds = C.epoll_wait(epfd, events, MAXEVENTS, -1)
  assert(nfds ~= -1)
  for i = 0, nfds - 1 do
    if events[i].data.fd == listen_fd then
      local peer_addr = ffi.new("struct sockaddr_in[1]")
      local peer_addr_size = ffi.new("int32_t[1]")
      local conn_fd = C.accept(listen_fd,
          ffi.cast("struct sockaddr *", peer_addr),
          peer_addr_size)
      assert(conn_fd ~= -1)

      local ci = ffi.new("struct clientinfo[1]")
      ci[0].fd = conn_fd
      event[0].events = bit.bor(C.EPOLLIN, C.EPOLLONESHOT)
      event[0].data.ptr = ci

      rc = C.epoll_ctl(epfd, C.EPOLL_CTL_ADD, conn_fd, event)
      assert(rc ~= -1)
    else
      local ci = ffi.cast("struct clientinfo *", events[i].data.ptr)
      if bit.band(events[i].events, C.EPOLLIN) ~= 0 then
        ci[0].n = C.read(ci[0].fd, ci[0].buf, C.BUFSIZE)
        assert(ci[0].n >= 0)

        events[i].events = C.EPOLLOUT
        rc = C.epoll_ctl(epfd, C.EPOLL_CTL_MOD, ci[0].fd, events[i])
        assert(rc ~= -1)
      elseif bit.band(events[i].events, C.EPOLLOUT) ~= 0 then
        local n = C.write(ci[0].fd, ci[0].buf, ci[0].n)
        assert(n >= 0)

        rc = C.epoll_ctl(epfd, C.EPOLL_CTL_DEL, ci[0].fd, events[i])
        assert(rc ~= -1)

        rc = C.close(ci[0].fd)
        assert(rc ~= -1)
      end
    end
  end
end
rc = C.close(cfd)
assert(rc ~= -1)
