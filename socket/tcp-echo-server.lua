local ffi = require "ffi"
local S = require "syscall"
local c, t = S.c, S.t

local fd = S.socket(c.AF.INET, c.SOCK.STREAM, 0)
print("fd", fd, "type(fd)", type(fd))

local res
res = S.setsockopt(fd, c.SOL.SOCKET, c.SO.REUSEADDR, true)
print("setsockopt res", res, "type(res)", type(res))
assert(res)

local addr = t.sockaddr_in(3000, "0.0.0.0")

res = S.bind(fd, addr)
print("bind res", res, "type(res)", type(res))
assert(res)

res = S.listen(fd)
assert(res)

client = S.accept(fd, 0, addr)
print("client.fd", client.fd)
print("client.addr", client.addr)

local BUFSIZE = 8192
local buf = ffi.new("uint8_t[?]", BUFSIZE)
local EOT = 4
while true do
  local bytesRead = S.read(client.fd, buf, ffi.sizeof(buf))
  print("bytesRead", bytesRead)
  if bytesRead <= 0 then
    break
  end
  local str = ffi.string(buf, bytesRead)
  print("buf", str)
  if bytesRead == 1 then
    if buf[0] == EOT then
      print("got EOT")
      break
    end
    print("buf[0]", buf[0])
    print("hex", string.format("%x", string.byte(str)))
  end
  local bytesWritten = S.write(client.fd, buf, bytesRead)
  print("bytesWritten", bytesWritten)
end

S.close(fd)
