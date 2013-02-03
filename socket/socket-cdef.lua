local ffi = require "ffi"

ffi.cdef[[
static const int PF_INET = 2;
static const int AF_INET = PF_INET;

static const int SOCK_STREAM = 1;

int socket(int domain, int type, int protocol);

typedef uint32_t socklen_t;

static const int SOL_SOCKET = 1;
static const int SO_REUSEADDR = 2;

int setsockopt(int sockfd, int level, int optname, const void *optval,
  socklen_t optlen);

typedef unsigned short int sa_family_t;
typedef uint16_t in_port_t;
typedef uint32_t in_addr_t;
struct in_addr {
  in_addr_t s_addr;
};

struct sockaddr {
  sa_family_t sin_family;
  char sa_data[14];		/* Address data.  */
};

struct sockaddr_in {
  sa_family_t sin_family;
  in_port_t sin_port;
  struct in_addr sin_addr;

  /* Pad to size of `struct sockaddr'.  */
  unsigned char sin_zero[sizeof(struct sockaddr) -
       sizeof(sa_family_t) -
       sizeof(in_port_t) -
       sizeof(struct in_addr)];
};

uint16_t htons(uint16_t hostshort);
int inet_aton(const char *cp, struct in_addr *inp);

int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen);

int listen(int sockfd, int backlog);

int accept(int sockfd, struct sockaddr *addr, socklen_t *addrlen);

int connect(int sockfd, const struct sockaddr *addr, socklen_t addrlen);

typedef int ssize_t;
ssize_t read(int fd, void *buf, size_t count);

ssize_t write(int fd, const void *buf, size_t count);

int close(int fd);
]]
