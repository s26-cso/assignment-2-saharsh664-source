#include <stdio.h>
#include <dlfcn.h>

int main() {
//store the operator and operands(10 char simply)
    char op[10];
    int x, y;
//while true loop to read the operator and operands until EOF
    while (1) {
//reads input
        if (scanf("%s %d %d", op, &x, &y) != 3) break;
//build library name
        char lib[20] = "./lib";
        int i = 0;
//copy operator to library name
        while (op[i]) {
            lib[5 + i] = op[i];
            i++;
        }
//append .so
        lib[5 + i] = '.';
        lib[6 + i] = 's';
        lib[7 + i] = 'o';
        lib[8 + i] = '\0';

//loads the shared library during runtime
        void *h = dlopen(lib, RTLD_LAZY);
//finds function with name op
//stores it in function pointer f
        int (*f)(int, int) = dlsym(h, op);

        printf("%d\n", f(x, y));

        dlclose(h);
    }

    return 0;
}
