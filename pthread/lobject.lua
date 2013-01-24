local ffi = require "ffi"

ffi.cdef[[
typedef uint8_t lu_byte;
typedef union GCObject GCObject;

typedef struct GCheader {
  /* CommonHeader start */
  GCObject *next;
  lu_byte tt;
  lu_byte marked;
  /* CommonHeader end */
} GCheader;

typedef double lua_Number;

typedef union {
  GCObject *gc;
  void *p;
  lua_Number n;
  int b;
} Value;

typedef struct lua_TValue {
  /* TValuefields start */
  Value value;
  int tt;
  /* TValuefields end */
} TValue;

typedef union TKey {
  struct {
    /* TValuefields start */
    Value value;
    int tt;
    /* TValuefields end */
    struct Node *next;  /* for chaining */
  } nk;
  TValue tvk;
} TKey;

typedef struct Node {
  TValue i_val;
  TKey i_key;
} Node;

typedef struct Table {
  GCObject *next;
  lu_byte tt;
  lu_byte marked;
  lu_byte flags;  /* 1<<p means tagmethod(p) is not present */ 
  lu_byte lsizenode;  /* log2 of size of `node' array */
  struct Table *metatable;
  TValue *array;  /* array part */
  Node *node;
  Node *lastfree;  /* any free position is before this position */
  GCObject *gclist;
  int32_t /*int*/ sizearray;  /* size of `array' array */
} Table;

typedef union { double u; void *s; long l; } L_Umaxalign;

typedef union TString {
  L_Umaxalign dummy;  /* ensures maximum alignment for strings */
  struct {
    /* CommonHeader start */
    GCObject *next;
    lu_byte tt;
    lu_byte marked;
    /* CommonHeader end */
    lu_byte reserved;
    uint32_t/*unsigned int*/ hash;
    size_t len;
  } tsv;
} TString;

typedef union Udata {
  L_Umaxalign dummy;  /* ensures maximum alignment for `local' udata */
  struct {
    /* CommonHeader start */
    GCObject *next;
    lu_byte tt;
    lu_byte marked;
    /* CommonHeader end */
    struct Table *metatable;
    struct Table *env;
    size_t len;
  } uv;
} Udata;

typedef struct lua_State lua_State;
typedef int (*lua_CFunction) (lua_State *L);

typedef struct CClosure {
  /* CommonHeader start */
  GCObject *next;
  lu_byte tt;
  lu_byte marked;
  /* CommonHeader end */
	lu_byte isC;
  lu_byte nupvalues;
  GCObject *gclist;
	struct Table *env;
  lua_CFunction f;
  TValue upvalue[1];
} CClosure;

typedef uint32_t lu_int32;
typedef lu_int32 Instruction;

typedef struct LocVar {
  TString *varname;
  int32_t/*int*/ startpc;  /* first point where variable is active */
  int32_t/*int*/ endpc;    /* first point where variable is dead */
} LocVar;

typedef struct Proto {
  /* CommonHeader start */
  GCObject *next;
  lu_byte tt;
  lu_byte marked;
  /* CommonHeader end */
  TValue *k;  /* constants used by the function */
  Instruction *code;
  struct Proto **p;  /* functions defined inside the function */
  int32_t/*int*/ *lineinfo;  /* map from opcodes to source lines */
  struct LocVar *locvars;  /* information about local variables */
  TString **upvalues;  /* upvalue names */
  TString  *source;
  int32_t/*int*/ sizeupvalues;
  int32_t/*int*/ sizek;  /* size of `k' */
  int32_t/*int*/ sizecode;
  int32_t/*int*/ sizelineinfo;
  int32_t/*int*/ sizep;  /* size of `p' */
  int32_t/*int*/ sizelocvars;
  int32_t/*int*/ linedefined;
  int32_t/*int*/ lastlinedefined;
  GCObject *gclist;
  lu_byte nups;  /* number of upvalues */
  lu_byte numparams;
  lu_byte is_vararg;
  lu_byte maxstacksize;
} Proto;

typedef struct UpVal {
  /* CommonHeader start */
  GCObject *next;
  lu_byte tt;
  lu_byte marked;
  /* CommonHeader end */
  TValue *v;  /* points to stack or to its own value */
  union {
    TValue value;  /* the value (when closed) */
    struct {  /* double linked list (when open) */
      struct UpVal *prev;
      struct UpVal *next;
    } l;
  } u;
} UpVal;

union GCObject {
  GCheader gch;
  union TString ts;
  union Udata u;
  union Closure cl;
  struct Table h;
  struct Proto p;
  struct UpVal uv;
  struct lua_State th;  /* thread */
};

typedef struct stringtable {
  GCObject **hash;
  lu_int32 nuse;  /* number of elements */
  int32_t/*int*/ size;
} stringtable;

typedef void * (*lua_Alloc) (void *ud, void *ptr, size_t osize, size_t nsize);

typedef struct Mbuffer {
  int8_t/*char*/ *buffer;
  size_t n;
  size_t buffsize;
} Mbuffer;

typedef size_t LUAI_UMEM;
typedef LUAI_UMEM lu_mem;

typedef struct global_State {
  stringtable strt;  /* hash table for strings */
  lua_Alloc frealloc;  /* function to reallocate memory */
  void *ud;         /* auxiliary data to `frealloc' */
  lu_byte currentwhite;
  lu_byte gcstate;  /* state of garbage collector */
  int32_t/*int*/ sweepstrgc;  /* position of sweep in `strt' */
  GCObject *rootgc;  /* list of all collectable objects */
  GCObject **sweepgc;  /* position of sweep in `rootgc' */
  GCObject *gray;  /* list of gray objects */
  GCObject *grayagain;  /* list of objects to be traversed atomically */
  GCObject *weak;  /* list of weak tables (to be cleared) */
  GCObject *tmudata;  /* last element of list of userdata to be GC */
  Mbuffer buff;  /* temporary buffer for string concatentation */
  lu_mem GCthreshold;
  lu_mem totalbytes;  /* number of bytes currently allocated */
  lu_mem estimate;  /* an estimate of number of bytes actually in use */
  lu_mem gcdept;  /* how much GC is `behind schedule' */
  int32_t/*int*/ gcpause;  /* size of pause between successive GCs */
  int32_t/*int*/ gcstepmul;  /* GC `granularity' */
  lua_CFunction panic;  /* to be called in unprotected errors */
  TValue l_registry;
  struct lua_State *mainthread;
  UpVal uvhead;  /* head of double-linked list of all open upvalues */
  struct Table *mt[NUM_TAGS];  /* metatables for basic types */
  TString *tmname[TM_N];  /* array with tag-method names */
} global_State;

typedef TValue *StkId;  /* index to stack elements */

typedef struct CallInfo {
  StkId base;  /* base for this function */
  StkId func;  /* function index in the stack */
  StkId	top;  /* top for this function */
  const Instruction *savedpc;
  int32_t/*int*/ nresults;  /* expected number of results from this function */
  int32_t/*int*/ tailcalls;  /* number of tail calls lost under this entry */
} CallInfo;

typedef struct lua_Debug lua_Debug;  /* activation record */
struct lua_Debug {
  int32_t/*int*/ event;
  const int8_t/*char*/ *name;	/* (n) */
  const int8_t/*char*/ *namewhat;	/* (n) `global', `local', `field', `method' */
  const int8_t/*char*/ *what;	/* (S) `Lua', `C', `main', `tail' */
  const int8_t/*char*/ *source;	/* (S) */
  int32_t/*int*/ currentline;	/* (l) */
  int32_t/*int*/ nups;		/* (u) number of upvalues */
  int32_t/*int*/ linedefined;	/* (S) */
  int32_t/*int*/ lastlinedefined;	/* (S) */
  int8_t/*char*/ short_src[LUA_IDSIZE]; /* (S) */
  /* private part */
  int32_t/*int*/ i_ci;  /* active function */
};

typedef void (*lua_Hook) (lua_State *L, lua_Debug *ar);

typedef luai_jmpbuf	int32_t/*int*/;  /* dummy variable */

struct lua_longjmp {
  struct lua_longjmp *previous;
  luai_jmpbuf b;
  volatile int32_t/*int*/ status;  /* error code */
};

struct lua_State {
  /* CommonHeader start */
  GCObject *next;
  lu_byte tt;
  lu_byte marked;
  /* CommonHeader end */
  lu_byte status;
  StkId top;  /* first free slot in the stack */
  StkId base;  /* base of current function */
  global_State *l_G;
  CallInfo *ci;  /* call info for current function */
  const Instruction *savedpc;  /* `savedpc' of current function */
  StkId stack_last;  /* last free slot in the stack */
  StkId stack;  /* stack base */
  CallInfo *end_ci;  /* points after end of ci array*/
  CallInfo *base_ci;  /* array of CallInfo's */
  int32_t/*int*/ stacksize;
  int32_t/*int*/ size_ci;  /* size of array `base_ci' */
  uint16_t/*unsigned short*/ nCcalls;  /* number of nested C calls */
  uint16_t/*unsigned short*/ baseCcalls;  /* nested C calls when resuming coroutine */
  lu_byte hookmask;
  lu_byte allowhook;
  int32_t/*int*/ basehookcount;
  int32_t/*int*/ hookcount;
  lua_Hook hook;
  TValue l_gt;  /* table of globals */
  TValue env;  /* temporary place for environments */
  GCObject *openupval;  /* list of open upvalues in this stack */
  GCObject *gclist;
  struct lua_longjmp *errorJmp;  /* current error recover point */
  ptrdiff_t errfunc;  /* current error handling function (stack index) */
};

lua_State *luaL_newstate(void);
]]
