#include "header.h"
#include <papi.h>

void initialize(int m, int k, int n, float* A, float* B, float* C);
void multiply(int m, int k, int n, float *A, float *B, float *C);

int main(int argc, char **argv) {
  int m = atoi(argv[1]);
  int k = atoi(argv[2]);
  int n = atoi(argv[3]);

  float *A = (float*) malloc(m * k * sizeof(float));
  float *B = (float*) malloc(k * n * sizeof(float));
  float *C = (float*) malloc(m * n * sizeof(float));

  int Events[] = {PAPI_FP_INS, PAPI_TOT_CYC};
  long_long values[2];
#define NUM_EVENTS 2

  initialize(m, k, n, A, B, C);

  /* Start counting events */
  if (PAPI_start_counters(Events, NUM_EVENTS) != PAPI_OK)
	  exit(10);

  multiply(m, k, n, A, B, C);

  /* Stop counting events */
  if (PAPI_stop_counters(values, NUM_EVENTS) != PAPI_OK)
	  exit(10);

  printf("Counter values: %ld, %ld\n", values[0], values[1]);

  free(A);
  free(B);
  free(C);
  return 0;
}
