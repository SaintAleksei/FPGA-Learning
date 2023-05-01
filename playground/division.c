/*
 * (c) GPT-4
 */

#include <stdio.h>
#include <limits.h>

/*
 * non_restoring_division: Performs non-restoring division algorithm for unsigned integers
 * Parameters:
 *   unsigned int dividend: The number to be divided
 *   unsigned int divisor: The number to divide by
 *   unsigned int *quotient: Pointer to store the result of the division
 *   unsigned int *remainder: Pointer to store the remainder of the division
 * Returns: void
 */
void non_restoring_division(unsigned int dividend, unsigned int divisor, unsigned int *quotient, unsigned int *remainder) {
    // Edge case: division by 0
    if (divisor == 0) {
        printf("Error: Division by zero\n");
        return;
    }

    int n = sizeof(unsigned int) * 8; // Number of bits in an unsigned int
    int partial_remainder = 0;

    // Non-restoring division algorithm
    for (int i = n; i > 0; i--) {
        printf("Iteration i = [%d]\n", i);
        printf("\tquotient = %x\n", *quotient);
        printf("\tpartial_remainder = %x\n", partial_remainder);
        printf("\t...\n");

        partial_remainder <<= 1; // Shift partial_remainder left by 1
        partial_remainder |= (dividend & (1u << (n - 1))) != 0; // Bring down the next bit of the dividend
        dividend <<= 1; // Shift the dividend left by 1

        if (partial_remainder >= 0) {
            partial_remainder -= divisor;
        } else {
            partial_remainder += divisor;
        }


        *quotient <<= 1; // Shift quotient left by 1
        if (partial_remainder >= 0) {
            *quotient |= 1; // Set the least significant bit of the quotient
        }

        printf("\tpartial_remainder = %x\n", partial_remainder);
        printf("\tquotient = %x\n", *quotient);
    }

    // Adjust the partial_remainder based on its sign
    if (partial_remainder < 0) {
        partial_remainder += divisor;
    }

    // Assign the remainder value
    *remainder = (unsigned int) partial_remainder;

    printf("partial_remainder = %x\n", partial_remainder);
    printf("quotient = %x\n", *quotient);
}

int main() {
    unsigned int dividend, divisor;
    unsigned int quotient = 0;
    unsigned int remainder = 0;

    dividend = 100;
    divisor = 4;

    non_restoring_division(dividend, divisor, &quotient, &remainder);
    printf("%u / %u = %u, remainder = %u\n", dividend, divisor, quotient, remainder);

    return 0;
}
