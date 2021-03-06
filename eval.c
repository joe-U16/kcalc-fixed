#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "fixed-point.h"

int main(int argc, char *argv[])
{
    if (argc < 2)
        return -1;

    fixedp ipt = {0};
    ipt.data = strtoul(argv[1], NULL, 10);
    char k_result[8];
    strncpy(k_result, "okokokk\0", 8);
    double result = 1;

    if (ipt.data == NAN_INT) {
        strncpy(k_result, "NAN_INT", 7);
        k_result[7] = '\0';
    } else if (ipt.data == INF_INT) {
        strncpy(k_result, "INF_INT", 7);
        k_result[7] = '\0';
    } else {
        result = (int) ipt.inte + ((double) ipt.frac / UINT32_MAX);
    }


    if (argc == 2) {
        if (result) {
            printf("%.16lf\n", result);
        } else {
            printf("%s\n", k_result);
        }
        return 0;
    }

    int bool_nan = strcmp("NAN_INT", argv[2]);
    int bool_inf = strcmp("INF_INT", argv[2]);

    if (bool_nan == 0) {
        if (strcmp(k_result, argv[2]))
            printf("FAIL: %s != NAN_INT\n", k_result);
        else
            printf("OK: NAN_INT == NAN_INT\n");
    } else if (bool_inf == 0) {
        if (strcmp(k_result, argv[2]))
            printf("FAIL: %s != INF_INT\n", k_result);
        else
            printf("OK: INF_INT == INF_INT\n");
    } else {
        double test = strtod(argv[2], NULL);

        if (fabs(result - test) > 0.01)
            printf("FAIL: %lf != %lf\n", result, test);
        else
            printf("OK: %lf == %lf\n", result, test);
    }

    return 0;
}
