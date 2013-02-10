#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <sys/epoll.h>
#include <errno.h>

#define NEVENTS 16
#define BUFSIZE 1024

static const char reply[] =
"HTTP/1.0 200 OK\r\n"
"Content-type: text/html\r\n"
"Connection: close\r\n"
"Content-Length: 82\r\n"
"\r\n"
"<html>\n"
"<head>\n"
"<title>performance test</title>\n"
"</head>\n"
"<body>\n"
"test\n"
"</body>\n"
"</html>"
;

int
main()
{
  int sock0;
  struct sockaddr_in addr;
  struct sockaddr_in client;
  socklen_t len;
  int sock;
  int n, i;
  struct epoll_event ev, ev_ret[NEVENTS];
  int epfd;
  int nfds;
  struct clientinfo {
    int fd;
    char buf[1024];
    int n;
  };
  int on = 1;

  /* (1) */
  /* ã½ã±ããã®ä½æ */
  sock0 = socket(AF_INET, SOCK_STREAM, 0);

  setsockopt(sock0, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on));
  /* ã½ã±ããã®è¨­å® */
  addr.sin_family = AF_INET;
  addr.sin_port = htons(12345);
  addr.sin_addr.s_addr = INADDR_ANY;
  bind(sock0, (struct sockaddr *)&addr, sizeof(addr));
  /* TCPã¯ã©ã¤ã¢ã³ãããã®æ¥ç¶è¦æ±ãå¾ã¦ãç¶æã«ãã */
  listen(sock0, 5);
  /* (1) çµãã */
  /* (2) */
  epfd = epoll_create(NEVENTS);
  if (epfd < 0) {
    perror("epoll_create");
    return 1;
  }
  /* (3) */
  memset(&ev, 0, sizeof(ev));
  ev.events = EPOLLIN;
  ev.data.ptr = malloc(sizeof(struct clientinfo));
  if (ev.data.ptr == NULL) {
    perror("malloc");
    return 1;
  }
  memset(ev.data.ptr, 0, sizeof(struct clientinfo));
  ((struct clientinfo *)ev.data.ptr)->fd = sock0;
  if (epoll_ctl(epfd, EPOLL_CTL_ADD, sock0, &ev) != 0) {
    perror("epoll_ctl");
    return 1;
  }
  /* (4) */
  for (;;) {
    nfds = epoll_wait(epfd, ev_ret, NEVENTS, -1);
    if (nfds < 0) {
      perror("epoll_wait");
      return 1;
    }

    /* (5) */
    /* printf("after epoll_wait : nfds=%d\n", nfds); */

    for (i=0; i<nfds; i++) {

      struct clientinfo *ci = ev_ret[i].data.ptr;
      /* printf("fd=%d\n", ci->fd); */

      if (ci->fd == sock0) {
        /* (6) */
        /* TCPã¯ã©ã¤ã¢ã³ãããã®æ¥ç¶è¦æ±ãåãä»ãã */
        len = sizeof(client);
        sock = accept(sock0, (struct sockaddr *)&client, &len);
        if (sock < 0) {
          perror("accept");
          return 1;
        }

        /* printf("accept sock=%d\n", sock); */

        memset(&ev, 0, sizeof(ev));
        ev.events = EPOLLIN | EPOLLONESHOT;
        ev.data.ptr = malloc(sizeof(struct clientinfo));
        if (ev.data.ptr == NULL) {
          perror("malloc");
          return 1;
        }

        memset(ev.data.ptr, 0, sizeof(struct clientinfo));
        ((struct clientinfo *)ev.data.ptr)->fd = sock;

        if (epoll_ctl(epfd, EPOLL_CTL_ADD, sock, &ev) != 0) {
          perror("epoll_ctl");
          return 1;
        }

      } else {
        /* (7) */
        if (ev_ret[i].events & EPOLLIN) {
          ci->n = read(ci->fd, ci->buf, BUFSIZE);
          if (ci->n < 0) {
            perror("read");
            return 1;
          }

          ev_ret[i].events = EPOLLOUT;

          if (epoll_ctl(epfd, EPOLL_CTL_MOD, ci->fd, &ev_ret[i]) != 0) {
            perror("epoll_ctl");
            return 1;
          }
        } else if (ev_ret[i].events & EPOLLOUT) {
          /* (8) */
          n = write(ci->fd, reply, sizeof(reply));
          if (n < 0) {
            perror("write");
            return 1;
          }

          if (epoll_ctl(epfd, EPOLL_CTL_DEL, ci->fd, &ev_ret[i]) != 0) {
            perror("epoll_ctl");
            return 1;
          }

          close(ci->fd);
          free(ev_ret[i].data.ptr);
        }
      }
    }
  }

  /* (9) */
  /* listen ããsocketã®çµäº */
  close(sock0);

  return 0;
}
