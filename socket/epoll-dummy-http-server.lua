local bir = require "bit"
local ffi = require "ffi"
require "cdef.socket"
require "cdef.epoll"
require "cdef.fcntl"
require "cdef.errno"
local C = ffi.C

local msg = [[
<html>
<head>
<title>performance test</title>
</head>
<body>
test
</body>
</html>
]]

local reply = table.concat({
"HTTP/1.0 200 OK",
"Content-type: text/html",
"Connection: close",
"Content-Length: " .. #msg,
"",
msg,
}, "\r\n")

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

rc = make_socket_non_blocking(listen_fd)
assert(rc ~= -1)

rc = C.listen(listen_fd, C.SOMAXCONN)
assert(rc ~= -1)

local epfd = C.epoll_create1(0)
assert(epfd ~= -1)

local event = ffi.new("struct epoll_event[1]")
event[0].events = bit.bor(C.EPOLLIN, C.EPOLLET)
--print("event[0].events", event[0].events, "listen_fd", listen_fd)
event[0].data.fd = listen_fd
rc = C.epoll_ctl(epfd, C.EPOLL_CTL_ADD, listen_fd, event)
assert(rc ~= -1)

local MAXEVENTS = 64
local events = ffi.new("struct epoll_event[?]", MAXEVENTS)

local BUFSIZE = 512
local buf = ffi.new("uint8_t[?]", BUFSIZE)

while true do
  local nfds = C.epoll_wait(epfd, events, MAXEVENTS, -1)
--print("nfds", nfds)
  assert(nfds ~= -1)
  for i = 0, nfds - 1 do
--print("i", i, "fd", events[i].data.fd, "events", events[i].events)
    if bit.band(events[i].events, C.EPOLLIN) ~= 0 then
      if events[i].data.fd == listen_fd then
        while true do
          local peer_addr = ffi.new("struct sockaddr_in[1]")
          local peer_addr_size = ffi.new("int32_t[1]", ffi.sizeof(peer_addr))
          local conn_fd = C.accept(listen_fd,
              ffi.cast("struct sockaddr *", peer_addr),
              peer_addr_size)
          if conn_fd == -1 then
            if C.errno == C.EAGAIN or C.errno == C.EWOULDBLOCK then
              -- We have processed all incoming connections.
              break
            else
              print("accept error")
              break
            end
          end
--print("conn_fd", conn_fd)

          rc = make_socket_non_blocking(conn_fd)
          assert(rc ~= -1)

          --event = ffi.new("struct epoll_event[1]")
          event[0].data.fd = conn_fd
          event[0].events = bit.bor(C.EPOLLIN, C.EPOLLET)
          rc = C.epoll_ctl(epfd, C.EPOLL_CTL_ADD, conn_fd, event)
          assert(rc ~= -1)
        end
      else
        local done = false
        while true do
          count = C.read(events[i].data.fd, buf, BUFSIZE)
          if count == -1 then
            if C.errno ~= C.EAGAIN then
              print("read error", C.errno)
              done = true
            end
            break
          elseif count == 0 then
            done = true
            break
          end

          local n = C.write(events[i].data.fd, reply, #reply)
          assert(n >= 0)
        end

        if done then
--          print("Closed connection on descriptor " .. events[i].data.fd)

          rc = C.close(events[i].data.fd)
          assert(rc ~= -1)
        end
      end
    end

    if bit.band(events[i].events, C.EPOLLERR) ~= 0 then
      print("epoll error. i:", i, "fd:", events[i].data.fd, "events:", events[i].events)

      C.close(events[i].data.fd)
    end
  end
end
rc = C.close(listen_fd)
assert(rc ~= -1)
