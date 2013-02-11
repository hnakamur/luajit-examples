local ffi = require "ffi"
require "cdef/socket"
local C = ffi.C

local fd = C.socket(C.AF_INET, C.SOCK_STREAM, 0)
print("fd", fd, "type(fd)", type(fd))

local on = ffi.new("int32_t[1]", 1)
print("on[0]", on[0])
local rc = C.setsockopt(fd, C.SOL_SOCKET, C.SO_REUSEADDR, on, ffi.sizeof(on))
assert(rc == 0)

local addr = ffi.new("struct sockaddr_in[1]")
addr[0].sin_family = C.AF_INET
addr[0].sin_port = C.htons(8000);
C.inet_aton("127.0.0.1", addr[0].sin_addr)
rc = C.bind(fd, ffi.cast("struct sockaddr *", addr), ffi.sizeof(addr))
assert(rc == 0)

rc = C.listen(fd, 128)
assert(rc == 0)

local peer_addr = ffi.new("struct sockaddr_in[1]")
local peer_addr_size = ffi.new("int32_t[1]")
local cfd = C.accept(fd, ffi.cast("struct sockaddr *", peer_addr),
    peer_addr_size)
assert(cfd >= 0)

local buf = ffi.new("uint8_t[?]", 4096)
while true do
  local bytes_read = C.read(cfd, buf, ffi.sizeof(buf))
  print("bytes_read", bytes_read)
  if bytes_read <= 0 then
    break
  end

  local str = ffi.string(buf, bytes_read)
  print("str", str)

  local bytes_written = C.write(cfd, buf, bytes_read)
  assert(bytes_written == bytes_read)
end
rc = C.close(cfd)
assert(rc == 0)
