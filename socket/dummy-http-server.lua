local ffi = require "ffi"
local S = require "syscall"
local c, t = S.c, S.t

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

local fd = S.socket(c.AF.INET, c.SOCK.STREAM, 0)
print("fd", fd, "type(fd)", type(fd))

local rc
rc = S.setsockopt(fd, c.SOL.SOCKET, c.SO.REUSEADDR, true)
print("setsockopt rc", rc, "type(rc)", type(rc))
assert(rc)

--[[
rc = S.ioctl(fd, c.IOCTL.FIONBIO, string.char(1))
assert(rc)
--]]

local addr = t.sockaddr_in(3000, "0.0.0.0")

rc = S.bind(fd, addr)
print("bind rc", rc, "type(rc)", type(rc))
assert(rc)

rc = S.listen(fd)
assert(rc)

while true do
  local client = S.accept(fd, 0, addr)
--  print("client.fd", client.fd)
--  print("client.addr", client.addr)

  local BUFSIZE = 8192
  local buf = ffi.new("uint8_t[?]", BUFSIZE)
  local EOT = 4
  while true do
    local bytesRead = S.read(client.fd, buf, ffi.sizeof(buf))
--    print("bytesRead", bytesRead)
    if bytesRead <= 0 then
      break
    end
    local str = ffi.string(buf, bytesRead)
    print("buf", str)
    if bytesRead == 1 then
      if buf[0] == EOT then
--        print("got EOT")
        break
      end
--      print("buf[0]", buf[0])
--      print("hex", string.format("%x", string.byte(str)))
    end
    local bytesWritten = S.write(client.fd, reply, #reply)
    assert(bytesWritten == #reply)
  end
end

S.close(fd)
