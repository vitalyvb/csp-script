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

#include "csp_incl.h"
#include "csp_defs.h"
#include "csp_api.h"
#include "parser.tab.h"
#include "gen.h"
#include "lexer.h"

#define TOKEN_UNDEFINED -2

#define YY_USER_ACTION do { yylval->d.line = YY->lineno; } while (0)
#define YY_PREPARE_TOK do { saved_tok_char = *YY->te; *YY->te = 0; } while (0)
#define YY_RELEASE_TOK do { *YY->te = saved_tok_char; } while (0)

%%{
	machine clex;
	access YY->;
	alphtype unsigned char;


	newline = '\n' @{YY->lineno += 1;};
	any_count_line = any | newline;

	number = ('0x' xdigit+) | digit+;
	identifier = ( alpha | '_' ) (alnum | '_')*;


#	c_comment := any_count_line* :>> '*/' @{fgoto main;};


	main := |*

	'//' [^\n]* newline?;
#	'/*' { fgoto c_comment; };

	[+\-*/(),{}\[\]=|~!&^%<>;]
			=> { YY_USER_ACTION; tok = YY->ts[0]; fbreak; };

	"if"		=> { YY_USER_ACTION; tok = KW_IF; fbreak; };
	"else"		=> { YY_USER_ACTION; tok = KW_ELSE; fbreak; };
	"for"		=> { YY_USER_ACTION; tok = KW_FOR; fbreak; };
	"do"		=> { YY_USER_ACTION; tok = KW_DO; fbreak; };
	"while"		=> { YY_USER_ACTION; tok = KW_WHILE; fbreak; };
	"break"		=> { YY_USER_ACTION; tok = KW_BREAK; fbreak; };
	"continue"	=> { YY_USER_ACTION; tok = KW_CONTINUE; fbreak; };
	"return"	=> { YY_USER_ACTION; tok = KW_RETURN; fbreak; };
	"global"	=> { YY_USER_ACTION; tok = KW_GLOBAL; fbreak; };
	"function"	=> { YY_USER_ACTION; tok = KW_FUNCTION; fbreak; };
	"map"		=> { YY_USER_ACTION; tok = KW_MAP; fbreak; };

	"||"		=> { YY_USER_ACTION; tok = SY_OROR; fbreak; };
	"&&"		=> { YY_USER_ACTION; tok = SY_ANDAND; fbreak; };

	">="		=> { YY_USER_ACTION; tok = SY_GE; fbreak; };
	"<="		=> { YY_USER_ACTION; tok = SY_LE; fbreak; };
	"=="		=> { YY_USER_ACTION; tok = SY_EQ; fbreak; };
	"!="		=> { YY_USER_ACTION; tok = SY_NEQ; fbreak; };

	number		=> {
		char *stft;
		YY_USER_ACTION;
		YY_PREPARE_TOK;

		yylval->d.num = strtol(YY->ts, &stft, 0);
		if (*stft != '\0') {
		    /* is it even posttible? */
		    set_error(CSP_ERR_LEX_BAD_NUMBER, YY->lineno, "not a number '%s'", YY->ts);
		    tok = EOS;
		} else {
		    tok = NUM;
		}

		YY_RELEASE_TOK;
		fbreak;
	};
	identifier	=> {
		int t, leng = YY->te-YY->ts;
		YY_USER_ACTION;

		/* check and return function identifier */
		t = func_get(YY->ts, leng);
		if (t >= 0){
		    yylval->d.num = t;
		    tok = FUNC;
		    fbreak;
		}

		/* variable */
		t = visible_var_get(YY->ts, leng);
		if (t >= 0){
		    yylval->d.num = t;
		    tok = VAR;
		    fbreak;
		}

		YY->token = YY->ts;
		YY->token_len = leng;

		tok = NEW_ID;

		fbreak;
	};

	newline | space;
	*|;
}%%

%% write data nofinal;



static int _yylex(YYSTYPE *yylval, struct ragel_lexer_t *YY)
{
    uint8_t *p, *pe, *eof=NULL;

    int tok = TOKEN_UNDEFINED;
    uint8_t saved_tok_char;
    int buffree, buflen, len;

    if (prog_check_free_space()){
	set_error(CSP_ERR_CODE_OVERFLOW, YY->lineno, "Out of program space");
	return -1;
    }

    if (csp_errno){
	/* if error condition set - fail parser */
	if (csp_errline <= 0)
	    csp_errline = YY->lineno;
	return -1;
    }

    p = YY->buffer + YY->p_offs;
    pe = YY->buffer + YY->pe_offs;

    /* perform a buffer management like in ragel pullscan example */
    while (p == pe && (YY->status == LEX_STATUS_WIP)) {

	if (YY->ts == 0){
	    buflen = 0;
	} else {
	    /* There is data that needs to be shifted over. */
	    buflen = pe - YY->ts;
	    memmove(YY->buffer, YY->ts, buflen);
	    YY->te -= (YY->ts - YY->buffer);
	    YY->ts = YY->buffer;
	}

	p = YY->buffer + buflen;
	buffree = YY->bufsize - buflen;
	pe = p;

	if (buffree == 0) {
	    set_error(CSP_ERR_LEX_OVERFLOW, YY->lineno, "token too long");
	    YY->status = LEX_STATUS_OVERFLOW;
	    break;
	}

	len = CSP_TEXT_INPUT_CALLBACK(p, buffree);
	if (len < 0){
	    YY->status = LEX_STATUS_EOF;
	    break;
	} else {
	    pe += len;
	}
    }

    if (YY->status >= LEX_STATUS_ERR)
	return -1;

    if (YY->status != LEX_STATUS_WIP)
	eof = pe;

    /*******************************/
    %% write exec;
    /*******************************/

    YY->p_offs = p - YY->buffer;
    YY->pe_offs = pe - YY->buffer;

    if ( YY->cs == clex_error ) {
	/* unexpected token */
	set_error(CSP_ERR_LEX_BAD_TOKEN, YY->lineno, "invalid token");
	YY->status = LEX_STATUS_BAD_TOKEN;
	return -1;
    }

    if (YY->status == LEX_STATUS_EOF &&
		tok == TOKEN_UNDEFINED &&
		p == pe && pe == eof){
	return EOS;
    }

    return tok;
}

int yylex(void *yylval, void *lex_state)
{
    int res;

    do {
	res = _yylex((YYSTYPE*)yylval, (struct ragel_lexer_t*)lex_state);
    } while (res == TOKEN_UNDEFINED);
    /*printf(">>>> %d\n", res);*/
    return res;
}

int scanner_init(struct ragel_lexer_t *YY, uint8_t *buffer, uint16_t size)
{
    memset(YY, 0, sizeof(struct ragel_lexer_t));

    %% write init;

    YY->lineno = 1;

    YY->status = LEX_STATUS_WIP;

    YY->buffer = buffer;
    YY->bufsize = size;

    return 0;
}

