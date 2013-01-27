local ffi = require("ffi")
local pt = ffi.load("pthread")

if ffi.os == "Linux" then
  if ffi.arch == "x64" then
ffi.cdef[[
    static const int __SIZEOF_PTHREAD_ATTR_T = 56;
]]
  else
ffi.cdef[[
    static const int __SIZEOF_PTHREAD_ATTR_T = 36;
]]
  end
end

ffi.cdef[[
typedef uint64_t pthread_t;

typedef union {
  int8_t __size[__SIZEOF_PTHREAD_ATTR_T];
  int64_t __align;
} pthread_attr_t;

typedef void *(*thread_func)(void *);

int pthread_create(
  pthread_t *thread,
  const pthread_attr_t *attr,
  void *(*start_routine)(void *),
  void *arg
);

int pthread_join(
  pthread_t thread,
  void **value_ptr
);
]]

ffi.cdef[[
typedef struct lua_State lua_State;
lua_State *luaL_newstate(void);
void luaL_openlibs(lua_State *L);
void lua_close(lua_State *L);
int luaL_loadstring(lua_State *L, const char *s);
int lua_pcall(lua_State *L, int nargs, int nresults, int errfunc);

static const int LUA_GLOBALSINDEX = -10002;
void lua_getfield(lua_State *L, int index, const char *k);
ptrdiff_t lua_tointeger(lua_State *L, int index);
void lua_settop(lua_State *L, int index);
]]

local C = ffi.C

local L = C.luaL_newstate()
assert(L ~= nil)
C.luaL_openlibs(L)
assert(C.luaL_loadstring(L, [[
local ffi = require("ffi")
local function hello()
  print("Hello from another Lua state!")
end

cb_hello = tonumber(ffi.cast('intptr_t', ffi.cast('void *(*)(void *)', hello)))
]]) == 0)
local res
res = C.lua_pcall(L, 0, 1, 0)
assert(res == 0)

C.lua_getfield(L, C.LUA_GLOBALSINDEX, 'cb_hello')
local func_ptr = C.lua_tointeger(L, -1);
C.lua_settop(L, -2);

threadA = ffi.new("pthread_t[1]")
res = pt.pthread_create(threadA, nil, ffi.cast("thread_func", func_ptr), nil)
assert(res == 0)

res = pt.pthread_join(threadA[0], nil)
assert(res == 0)

C.lua_close(L)
