/* Copyright (c) 2014, Vitaly Bursov <vitaly<AT>bursov.com>
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the author nor the names of its contributors may
 *       be used to endorse or promote products derived from this software
 *       without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "csp_defs.h"
#include "csp_api.h"
#include "csp_vm.h"

#define eprintf(s, p...) \
		fprintf(stderr, s, ## p)


char *txt = NULL;
char *txt_ptr;
int dataleft;

int csp_text_input_callback(char *buf, int max_size)
{
    if (dataleft < max_size)
	max_size = dataleft;

    if (max_size == 0)
	return -1;

    memcpy(buf, txt_ptr, max_size);
    dataleft -= max_size;
    txt_ptr += max_size;

    //printf("@@ %d\n", max_size);
    return max_size;
}


void dumpmem(uint8_t *ptr, uint32_t size)
{
    uint32_t addr = 0;
    int idx;

    printf("dumping, size %d:\n", size);

    idx = 0;
    while (size > 0){
	if (idx == 0)
	    printf("\r\n%08x: ", addr);

	printf("%02x ", *ptr++);

	idx = (idx + 1) & 0xf;
	size--;
	addr++;
    }

    printf("\r\n");

}

static struct csp_names my_functions = {
    .buf =
	"\004_add"
	"\004_sub"
	"\005_addx"
	,
    .idx = 3,
    .tail = 16,
};

int csp_vm_api_call_callback(int num, int argc, int *argv, int *res)
{
    fprintf(stderr, "xcall %d\n", num);

    if (num == 0){
	*res = argv[0] + argv[1];
    } else
    if (num == 1){
	*res = argv[0] - argv[1];
    } else
    if (num == 2){
	int i, t = 0;

	for (i=0;i<argc;i++)
	    t += argv[i];

	*res = t;
    } else
	return -110;

    return 0;
}

int csp_get_const_value(const char *name, int len, int *value)
{

#define xl(l) (len < (l) ? len : (l))

    if (strncmp(name, "TRUE", xl(4)) == 0){
	*value = 1;
    } else
    if (strncmp(name, "FALSE", xl(5)) == 0){
	*value = 0;
    } else
    if (strncmp(name, "TEST7", xl(5)) == 0){
	*value = 7;
    } else
    if (strncmp(name, "TEST8", xl(5)) == 0){
	*value = 8;
    } else
    if (strncmp(name, "TEST9", xl(5)) == 0){
	*value = 9;
    } else {
	return -1;
    }

#undef xl
    return 0;
}


int load_file(char *fn)
{
    FILE *f;
    int l;

    f = fopen(fn, "r+b");
    if (f == NULL){
	perror("file open: ");
	return -1;
    }
    txt = malloc(1024*1024);
    l = fread(txt, 1, 1024*1024, f);
    fclose(f);
    if (l<=0){
	free(txt);
	perror("file read: ");
	return -1;
    }
    txt[l] = 0;
    return 0;
}

int call_func(int argc, char **argv)
{
    int cargs[10];
    int cargc;
    int i;
    int fidx;
    int exec_res;

    if (argc < 2)
	return 0;

    fidx = csp_vm_find_func(argv[0]);
    if (fidx < 0){
	printf("\nRESULT: function %s() not found\n", argv[0]);
	return -1;
    }

    cargc = atoi(argv[1]);

    if (argc < cargc+2){
	printf("\nRESULT: need %d args for function %s()\n", cargc, argv[0]);
	return -1;
    }

    for (i=0;i<cargc;i++){
	cargs[i] = atoi(argv[i+2]);
    }

    exec_res = csp_vm_run_function(1000, fidx, cargc, cargs);
    printf("\nRESULT: exec %s(): %d %d\n", argv[0], exec_res, csp_vm_get_call_result());

    return cargc + 2;
}

int main(int argc, char **argv)
{
    int progsize = 2000;
    uint8_t prog[progsize];
    int parse_res, exec_res;
    int api_fncnt = my_functions.idx;

    if (argc < 2){
	fprintf(stderr, "usage: %s <filename>\n", argv[0]);
	return -1;
    }

    if (load_file(argv[1])<0){
	return -1;
    }


    eprintf("stack top: %p\n", &parse_res);


    csp_init();
    csp_set_environ(&my_functions);

    txt_ptr = txt;
    dataleft = strlen(txt);

    printf("program text size: %d\n", dataleft);
    parse_res = csp_parse(prog, progsize);


    if (parse_res){
	printf("\nRESULT: parse failed: line:%d code:%d %s\n", csp_errline, csp_errno, csp_errstr);
    } else {
	uint8_t vmbuf[1000];
	int sft;

	progsize = csp_get_program_size(prog, progsize);
	dumpmem(prog, progsize);

	csp_vm_init(vmbuf, sizeof(vmbuf));

	exec_res = csp_vm_load_program(prog, progsize, api_fncnt);
	if (exec_res){
	    printf("\nRESULT: load error %d\n", exec_res);
	    return 1;
	}

	argc-=2;
	argv+=2;

	sft = call_func(argc, argv);
	while (sft > 0){
	    argc -= sft;
	    argv += sft;
	    sft = call_func(argc, argv);
	}
    }


    return 0;
}
