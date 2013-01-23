TARGET = libthread_func.so
OBJS = thread_func.o
CFLAGS = -fPIC -g -O2 -Wall
LDFLAGS = -shared -Wl,-soname,$(TARGET)

$(TARGET): $(OBJS)
	$(CC) -o $(TARGET) $(OBJS) $(LDFLAGS)

.c.o:
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	@rm -f $(OBJS) $(TARGET)
