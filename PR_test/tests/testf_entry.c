/*
 * Copyright (c) Bao Project and Contributors. All rights reserved
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include "testf.h"
#include <stdio.h>
#include <string.h>

unsigned int testframework_tests;
unsigned int testframework_fails;

void testf_entry(void)
{
    // codegen.py section begin
	#if defined TEST_A || HELLO
	entry_test_HELLO_TEST_A();
	#endif

	#if defined TEST_B || HELLO
	entry_test_HELLO_TEST_B();
	#endif    // codegen.py section end

    if (testframework_tests > 0) {
        LOG_TESTS();
    } else {
        INFO_TAG();
        printf("No tests were executed!\n");
    }
    return;
}
