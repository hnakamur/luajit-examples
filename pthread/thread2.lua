local ffi = require("ffi")
local pt = ffi.load("pthread")

ffi.cdef[[
typedef uint64_t pthread_t;

/* On a 64-bit system. */
static const int __SIZEOF_PTHREAD_ATTR_T = 56;
/* static const int __SIZEOF_PTHREAD_ATTR_T = 36; */

typedef union
{
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
const void *lua_topointer(lua_State *L, int index);
void lua_settop(lua_State *L, int index);
]]

local C = ffi.C

local L = C.luaL_newstate()
assert(L ~= nil)
C.luaL_openlibs(L)
assert(C.luaL_loadstring(L, [[
function hello()
  print("Hello from another Lua state!")
end

print(hello)
]]) == 0)
assert(C.lua_pcall(L, 0, 1, 0) == 0)

C.lua_getfield(L, C.LUA_GLOBALSINDEX, 'hello')
local func_ptr = C.lua_topointer(L, -1);
print('func_ptr', func_ptr)
C.lua_settop(L, -2);

threadA = ffi.new("pthread_t[1]")
print("thread", threadA)
print("thread[0]", threadA[0])

local res = pt.pthread_create(threadA, nil,
  ffi.cast("thread_func", func_ptr), nil)
print("A res", res)

local res2 = pt.pthread_join(threadA[0], nil)

C.lua_close(L)
