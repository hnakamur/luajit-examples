local ffi = require "ffi"
require "cdef/socket"
local C = ffi.C

local fd = C.socket(C.AF_INET, C.SOCK_STREAM, 0)
print("fd", fd, "type(fd)", type(fd))

local addr = ffi.new("struct sockaddr_in[1]")
addr[0].sin_family = C.AF_INET
addr[0].sin_port = C.htons(8000);
C.inet_aton("127.0.0.1", addr[0].sin_addr)

local rc = C.connect(fd, ffi.cast("struct sockaddr *", addr), ffi.sizeof(addr))
assert(rc == 0)

local BUFSIZE = 8192
local buf = ffi.new("uint8_t[?]", BUFSIZE)

for _, str in ipairs{"hello", "goodbye"} do
  local bytes_written = C.write(fd, str, #str)

  local bytes_read = C.read(fd, buf, ffi.sizeof(buf))
  print("bytes_read", bytes_read)
  if bytes_read > 0 then
    local response = ffi.string(buf, bytes_read)
    print("response", response)
  end
end
rc = C.close(fd)
assert(rc == 0)
