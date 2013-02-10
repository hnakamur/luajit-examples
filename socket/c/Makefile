TARGET = epoll-server
OBJS = epoll-server.o
CFLAGS = -g -O2 -Wall
LDFLAGS =

epoll-server: $(OBJS)
	$(CC) -o $(TARGET) $(OBJS) $(LDFLAGS)

.c.o:
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	@rm -f $(OBJS) $(TARGET)
