local ffi = require("ffi")
local pcre = ffi.load("pcre")

ffi.cdef[[
typedef struct real_pcre pcre;
typedef struct pcre_extra pcre_extra;
typedef const char * PCRE_SPTR;

static const int PCRE_STUDY_JIT_COMPILE = 0x0001;

pcre *pcre_compile(const char *, int, const char **, int *,
                   const unsigned char *);
pcre_extra *pcre_study(const pcre *, int, const char **);
int pcre_exec(const pcre *, const pcre_extra *, PCRE_SPTR,
              int, int, int, int *, int);
void pcre_free_study(pcre_extra *);
void (*pcre_free)(void *);
]]

local pattern = "a.*d"
local str = "abcd"

local err = ffi.new("const char *[1]")
local erroffset = ffi.new("int[1]")
local r = pcre.pcre_compile(pattern, 0, err, erroffset, nil)
if err[0] ~= nil then
  print("err", ffi.string(err[0]))
  print("erroffset", erroffset[0])
end
assert(r ~= nil)

local re = pcre.pcre_study(r, pcre.PCRE_STUDY_JIT_COMPILE, err)
assert(re ~= nil)

local rc = pcre.pcre_exec(r, re, str, #str, 0, 0, nil, 0)
print("rc", rc)

pcre.pcre_free_study(re)
pcre.pcre_free(r)
