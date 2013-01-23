#include <stdio.h>

void *func1(void *data) {
  int i;

  for (i = 0; i < 100; i++) {
    printf("func1 %s %d\n", (char *)data, i);
  }
  return data;
}

/*
int main(int argc, char *argv[]) {
  func1(NULL);
  return 0;
}
*/
