local bir = require "bit"
local ffi = require "ffi"
require "cdef.socket"
require "cdef.epoll"
require "cdef.fcntl"
require "cdef.errno"
local C = ffi.C

local msg = "GET / HTTP/1.1\r\n"

function make_socket_non_blocking(fd)
  local flags = C.fcntl(fd, C.F_GETFL, 0)
  if flags == -1 then
    return -1
  end

  flags = bit.bor(flags, C.O_NONBLOCK)
  local rc = C.fcntl(fd, C.F_SETFL, ffi.new("int", flags))
  if rc == -1 then
    return -1
  end

  return 0
end

local sock_fd = C.socket(C.AF_INET, C.SOCK_STREAM, 0)
assert(sock_fd ~= -1)

rc = make_socket_non_blocking(sock_fd)
assert(rc ~= -1)

local addr = ffi.new("struct sockaddr_in[1]")
addr[0].sin_family = C.AF_INET
addr[0].sin_port = C.htons(8000);
C.inet_aton("127.0.0.1", addr[0].sin_addr)

local epfd = C.epoll_create1(0)
assert(epfd ~= -1)

local event = ffi.new("struct epoll_event[1]")
event[0].events = bit.bor(C.EPOLLIN, C.EPOLLOUT)
event[0].data.fd = sock_fd
rc = C.epoll_ctl(epfd, C.EPOLL_CTL_ADD, sock_fd, event)
assert(rc ~= -1)

rc = C.connect(sock_fd, ffi.cast("struct sockaddr *", addr), ffi.sizeof(addr))
if rc == -1 then
  print("after connect. rc:", rc, "errno:", C.errno, "EAGAIN:", C.EAGAIN, "EINPROGRESS:", C.EINPROGRESS)
  assert(C.errno ~= C.EAGAIN or C.errno ~= C.EINPROGRESS)
end

local MAXEVENTS = 64
local events = ffi.new("struct epoll_event[?]", MAXEVENTS)

local BUFSIZE = 512
local buf = ffi.new("uint8_t[?]", BUFSIZE)

local waiting = true
while waiting do
  local nfds = C.epoll_wait(epfd, events, MAXEVENTS, -1)
print("nfds", nfds)
  assert(nfds ~= -1)
  for i = 0, nfds - 1 do
print("i", i, "fd", events[i].data.fd, "events", events[i].events)
    if bit.band(events[i].events, C.EPOLLIN) ~= 0 then
      local done = false
      while true do
        count = C.read(events[i].data.fd, buf, BUFSIZE)
print("read count", count)
        if count == -1 then
          if C.errno ~= C.EAGAIN then
            print("read error", C.errno)
          end
          done = true
          break
        elseif count == 0 then
          done = true
          break
        elseif count > 0 then
          print(ffi.string(buf, count))
        end
      end

      if done then
        print("Closed connection on descriptor " .. events[i].data.fd)

        rc = C.close(events[i].data.fd)
        assert(rc ~= -1)

        waiting = false
      end
    elseif bit.band(events[i].events, C.EPOLLOUT) ~= 0 then
      local bytes_written = C.write(sock_fd, msg, #msg)
      assert(bytes_written == #msg)

      -- don't want output anymore
      event[0].events = C.EPOLLIN
      event[0].data.fd = sock_fd
      rc = C.epoll_ctl(epfd, C.EPOLL_CTL_MOD, sock_fd, event)
      assert(rc ~= -1)
    elseif bit.band(events[i].events, C.EPOLLERR) ~= 0 then
      print("epoll error. i:", i, "fd:", events[i].data.fd, "events:", events[i].events)

      C.close(events[i].data.fd)
      break
    end
  end
end
