local ffi = require "ffi"

ffi.cdef[[
int epoll_create(int size);

enum {
  EPOLL_CLOEXEC = 02000000,
  EPOLL_NONBLOCK = 04000
};

int epoll_create1(int size);

static const int EPOLL_CTL_ADD = 1;
static const int EPOLL_CTL_DEL = 2;
static const int EPOLL_CTL_MOD = 3;

typedef union epoll_data {
  void *ptr;
  int fd;
  uint32_t u32;
  uint64_t u64;
} epoll_data_t;

enum EPOLL_EVENTS {
  EPOLLIN = 0x001,
  EPOLLPRI = 0x002,
  EPOLLOUT = 0x004,
  EPOLLRDNORM = 0x040,
  EPOLLRDBAND = 0x080,
  EPOLLWRNORM = 0x100,
  EPOLLWRBAND = 0x200,
  EPOLLMSG = 0x400,
  EPOLLERR = 0x008,
  EPOLLHUP = 0x010,
  EPOLLRDHUP = 0x2000,
  EPOLLONESHOT = (1 << 30) /*,
  EPOLLET = (1 << 31)*/
};
static const uint32_t EPOLLET = (1 << 31);

int epoll_ctl(int epfd, int op, int fd, struct epoll_event *event);

int epoll_wait(int epfd, struct epoll_event *events, int maxevents,
    int timeout);
]]

require("cdef." .. ffi.arch .. ".epoll")
