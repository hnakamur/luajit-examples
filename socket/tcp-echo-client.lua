local ffi = require "ffi"
local S = require "syscall"
local c, t = S.c, S.t

local fd = S.socket(c.AF.INET, c.SOCK.STREAM, 0)
print("fd", fd, "type(fd)", type(fd))

local addr = t.sockaddr_in(3000, "0.0.0.0")

local rc
rc = S.connect(fd, addr)
assert(rc)

local str = "hello"
local bytesWritten = S.write(fd, str)
print("bytesWritten", bytesWritten)

local BUFSIZE = 8192
local buf = ffi.new("uint8_t[?]", BUFSIZE)

local bytesRead = S.read(fd, buf, BUFSIZE)
print("bytesRead", bytesRead)

S.close(fd)
