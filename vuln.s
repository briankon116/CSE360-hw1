   1              		.file	"vuln.c"
   2              		.text
   3              	.Ltext0:
   4              		.section	.rodata
   5              	.LC0:
   6 0000 5C782530 		.string	"\\x%02hhx"
   6      32686878 
   6      00
   7              		.text
   8              		.globl	print_escaped
  10              	print_escaped:
  11              	.LFB2:
  12              		.file 1 "vuln.c"
   1:vuln.c        **** #include <stdlib.h>
   2:vuln.c        **** #include <strings.h>
   3:vuln.c        **** #include <unistd.h>
   4:vuln.c        **** #include <stdio.h>
   5:vuln.c        **** #include <string.h>
   6:vuln.c        **** #include <alloca.h>
   7:vuln.c        **** #include <ctype.h>
   8:vuln.c        **** 
   9:vuln.c        **** #include "my_malloc.h"
  10:vuln.c        **** 
  11:vuln.c        **** #define MAX_GRP 100
  12:vuln.c        **** 
  13:vuln.c        **** #define err_abort(x) do { \
  14:vuln.c        ****       if (!(x)) {\
  15:vuln.c        ****          fprintf(stderr, "Fatal error: %s:%d: ", __FILE__, __LINE__);   \
  16:vuln.c        ****          perror(""); \
  17:vuln.c        ****          exit(1);\
  18:vuln.c        ****       }\
  19:vuln.c        ****    } while (0)
  20:vuln.c        **** 
  21:vuln.c        **** void print_escaped(FILE *fp, const char* buf, unsigned len) {
  13              		.loc 1 21 0
  14              		.cfi_startproc
  15 0000 55       		pushl	%ebp
  16              		.cfi_def_cfa_offset 8
  17              		.cfi_offset 5, -8
  18 0001 89E5     		movl	%esp, %ebp
  19              		.cfi_def_cfa_register 5
  20 0003 83EC18   		subl	$24, %esp
  22:vuln.c        ****    int i;
  23:vuln.c        ****    for (i=0; i < len; i++) {
  21              		.loc 1 23 0
  22 0006 C745F400 		movl	$0, -12(%ebp)
  22      000000
  23 000d EB74     		jmp	.L2
  24              	.L5:
  24:vuln.c        ****       if (isprint(buf[i]))
  25              		.loc 1 24 0
  26 000f E8FCFFFF 		call	__ctype_b_loc
  26      FF
  27 0014 8B00     		movl	(%eax), %eax
  28 0016 8B4DF4   		movl	-12(%ebp), %ecx
  29 0019 8B550C   		movl	12(%ebp), %edx
  30 001c 01CA     		addl	%ecx, %edx
  31 001e 0FB612   		movzbl	(%edx), %edx
  32 0021 0FBED2   		movsbl	%dl, %edx
  33 0024 01D2     		addl	%edx, %edx
  34 0026 01D0     		addl	%edx, %eax
  35 0028 0FB700   		movzwl	(%eax), %eax
  36 002b 0FB7C0   		movzwl	%ax, %eax
  37 002e 25004000 		andl	$16384, %eax
  37      00
  38 0033 85C0     		testl	%eax, %eax
  39 0035 7423     		je	.L3
  25:vuln.c        ****          fputc(buf[i], stderr);
  40              		.loc 1 25 0
  41 0037 8B150000 		movl	stderr, %edx
  41      0000
  42 003d 8B4DF4   		movl	-12(%ebp), %ecx
  43 0040 8B450C   		movl	12(%ebp), %eax
  44 0043 01C8     		addl	%ecx, %eax
  45 0045 0FB600   		movzbl	(%eax), %eax
  46 0048 0FBEC0   		movsbl	%al, %eax
  47 004b 83EC08   		subl	$8, %esp
  48 004e 52       		pushl	%edx
  49 004f 50       		pushl	%eax
  50 0050 E8FCFFFF 		call	fputc
  50      FF
  51 0055 83C410   		addl	$16, %esp
  52 0058 EB25     		jmp	.L4
  53              	.L3:
  26:vuln.c        ****       else fprintf(stderr, "\\x%02hhx", buf[i]);
  54              		.loc 1 26 0
  55 005a 8B55F4   		movl	-12(%ebp), %edx
  56 005d 8B450C   		movl	12(%ebp), %eax
  57 0060 01D0     		addl	%edx, %eax
  58 0062 0FB600   		movzbl	(%eax), %eax
  59 0065 0FBED0   		movsbl	%al, %edx
  60 0068 A1000000 		movl	stderr, %eax
  60      00
  61 006d 83EC04   		subl	$4, %esp
  62 0070 52       		pushl	%edx
  63 0071 68000000 		pushl	$.LC0
  63      00
  64 0076 50       		pushl	%eax
  65 0077 E8FCFFFF 		call	fprintf
  65      FF
  66 007c 83C410   		addl	$16, %esp
  67              	.L4:
  23:vuln.c        ****       if (isprint(buf[i]))
  68              		.loc 1 23 0 discriminator 2
  69 007f 8345F401 		addl	$1, -12(%ebp)
  70              	.L2:
  23:vuln.c        ****       if (isprint(buf[i]))
  71              		.loc 1 23 0 is_stmt 0 discriminator 1
  72 0083 8B45F4   		movl	-12(%ebp), %eax
  73 0086 3B4510   		cmpl	16(%ebp), %eax
  74 0089 7284     		jb	.L5
  27:vuln.c        ****    }
  28:vuln.c        **** }
  75              		.loc 1 28 0 is_stmt 1
  76 008b 90       		nop
  77 008c C9       		leave
  78              		.cfi_restore 5
  79              		.cfi_def_cfa 4, 4
  80 008d C3       		ret
  81              		.cfi_endproc
  82              	.LFE2:
  84              		.globl	auth
  86              	auth:
  87              	.LFB3:
  29:vuln.c        **** 
  30:vuln.c        **** /************ Function vulnerable to buffer overflow on stack ***************/
  31:vuln.c        **** 
  32:vuln.c        **** int auth(const char *username, int ulen, const char *pass, int plen) {
  88              		.loc 1 32 0
  89              		.cfi_startproc
  90 008e 55       		pushl	%ebp
  91              		.cfi_def_cfa_offset 8
  92              		.cfi_offset 5, -8
  93 008f 89E5     		movl	%esp, %ebp
  94              		.cfi_def_cfa_register 5
  95 0091 83EC28   		subl	$40, %esp
  96 0094 8B4508   		movl	8(%ebp), %eax
  97 0097 8945E4   		movl	%eax, -28(%ebp)
  98 009a 8B4510   		movl	16(%ebp), %eax
  99 009d 8945E0   		movl	%eax, -32(%ebp)
 100              		.loc 1 32 0
 101 00a0 65A11400 		movl	%gs:20, %eax
 101      0000
 102 00a6 8945F4   		movl	%eax, -12(%ebp)
 103 00a9 31C0     		xorl	%eax, %eax
  33:vuln.c        ****   char *user = alloca(LEN2 + (random() % LEN2)); // 322 bytes long
 104              		.loc 1 33 0
 105 00ab E8FCFFFF 		call	random
 105      FF
 106 00b0 89C2     		movl	%eax, %edx
 107 00b2 89D0     		movl	%edx, %eax
 108 00b4 C1F81F   		sarl	$31, %eax
 109 00b7 C1E818   		shrl	$24, %eax
 110 00ba 01C2     		addl	%eax, %edx
 111 00bc 0FB6D2   		movzbl	%dl, %edx
 112 00bf 29C2     		subl	%eax, %edx
 113 00c1 89D0     		movl	%edx, %eax
 114 00c3 05000100 		addl	$256, %eax
 114      00
 115 00c8 8D500F   		leal	15(%eax), %edx
 116 00cb B8100000 		movl	$16, %eax
 116      00
 117 00d0 83E801   		subl	$1, %eax
 118 00d3 01D0     		addl	%edx, %eax
 119 00d5 B9100000 		movl	$16, %ecx
 119      00
 120 00da BA000000 		movl	$0, %edx
 120      00
 121 00df F7F1     		divl	%ecx
 122 00e1 6BC010   		imull	$16, %eax, %eax
 123 00e4 29C4     		subl	%eax, %esp
 124 00e6 89E0     		movl	%esp, %eax
 125 00e8 83C00F   		addl	$15, %eax
 126 00eb C1E804   		shrl	$4, %eax
 127 00ee C1E004   		sall	$4, %eax
 128 00f1 8945EC   		movl	%eax, -20(%ebp)
  34:vuln.c        ****   // make offsets unique for each group
  35:vuln.c        **** 
  36:vuln.c        ****   bcopy(username, user, ulen); // possible buffer overflow
 129              		.loc 1 36 0
 130 00f4 8B450C   		movl	12(%ebp), %eax
 131 00f7 83EC04   		subl	$4, %esp
 132 00fa 50       		pushl	%eax
 133 00fb FF75EC   		pushl	-20(%ebp)
 134 00fe FF75E4   		pushl	-28(%ebp)
 135 0101 E8FCFFFF 		call	bcopy
 135      FF
 136 0106 83C410   		addl	$16, %esp
  37:vuln.c        **** 
  38:vuln.c        ****   unsigned l = (plen < ulen) ? plen : ulen;
 137              		.loc 1 38 0
 138 0109 8B4514   		movl	20(%ebp), %eax
 139 010c 39450C   		cmpl	%eax, 12(%ebp)
 140 010f 0F4E450C 		cmovle	12(%ebp), %eax
 141 0113 8945F0   		movl	%eax, -16(%ebp)
  39:vuln.c        ****   return (strncmp(user, pass, l) == 0);
 142              		.loc 1 39 0
 143 0116 83EC04   		subl	$4, %esp
 144 0119 FF75F0   		pushl	-16(%ebp)
 145 011c FF75E0   		pushl	-32(%ebp)
 146 011f FF75EC   		pushl	-20(%ebp)
 147 0122 E8FCFFFF 		call	strncmp
 147      FF
 148 0127 83C410   		addl	$16, %esp
 149 012a 85C0     		testl	%eax, %eax
 150 012c 0F94C0   		sete	%al
 151 012f 0FB6C0   		movzbl	%al, %eax
  40:vuln.c        **** }
 152              		.loc 1 40 0
 153 0132 8B4DF4   		movl	-12(%ebp), %ecx
 154 0135 65330D14 		xorl	%gs:20, %ecx
 154      000000
 155 013c 7405     		je	.L8
 156 013e E8FCFFFF 		call	__stack_chk_fail
 156      FF
 157              	.L8:
 158 0143 C9       		leave
 159              		.cfi_restore 5
 160              		.cfi_def_cfa 4, 4
 161 0144 C3       		ret
 162              		.cfi_endproc
 163              	.LFE3:
 165              		.globl	wrauth
 167              	wrauth:
 168              	.LFB4:
  41:vuln.c        **** 
  42:vuln.c        **** int wrauth(const char *username, int ulen, const char *pass, int plen) {
 169              		.loc 1 42 0
 170              		.cfi_startproc
 171 0145 55       		pushl	%ebp
 172              		.cfi_def_cfa_offset 8
 173              		.cfi_offset 5, -8
 174 0146 89E5     		movl	%esp, %ebp
 175              		.cfi_def_cfa_register 5
 176 0148 83EC08   		subl	$8, %esp
  43:vuln.c        ****    return auth(username, ulen, pass, plen);
 177              		.loc 1 43 0
 178 014b FF7514   		pushl	20(%ebp)
 179 014e FF7510   		pushl	16(%ebp)
 180 0151 FF750C   		pushl	12(%ebp)
 181 0154 FF7508   		pushl	8(%ebp)
 182 0157 E8FCFFFF 		call	auth
 182      FF
 183 015c 83C410   		addl	$16, %esp
  44:vuln.c        **** }
 184              		.loc 1 44 0
 185 015f C9       		leave
 186              		.cfi_restore 5
 187              		.cfi_def_cfa 4, 4
 188 0160 C3       		ret
 189              		.cfi_endproc
 190              	.LFE4:
 192              		.comm	login_attempts,4,4
 193              		.section	.rodata
 194              	.LC1:
 195 0009 2F62696E 		.string	"/bin/ls"
 195      2F6C7300 
 196              	.LC2:
 197 0011 2F62696E 		.string	"/bin/false"
 197      2F66616C 
 197      736500
 198              		.align 4
 199              	.LC3:
 200 001c 41757468 		.string	"Authentication succeeded, executing ls\n"
 200      656E7469 
 200      63617469 
 200      6F6E2073 
 200      75636365 
 201              	.LC4:
 202 0044 6C7300   		.string	"ls"
 203              	.LC5:
 204 0047 76756C6E 		.string	"vuln.c"
 204      2E6300
 205              	.LC6:
 206 004e 46617461 		.string	"Fatal error: %s:%d: "
 206      6C206572 
 206      726F723A 
 206      2025733A 
 206      25643A20 
 207              	.LC7:
 208 0063 00       		.string	""
 209              	.LC8:
 210 0064 4C6F6769 		.string	"Login denied, "
 210      6E206465 
 210      6E696564 
 210      2C2000
 211              	.LC9:
 212 0073 65786563 		.string	"executing /bin/false\n"
 212      7574696E 
 212      67202F62 
 212      696E2F66 
 212      616C7365 
 213              	.LC10:
 214 0089 66616C73 		.string	"false"
 214      6500
 215              	.LC11:
 216 008f 74727920 		.string	"try again\n"
 216      61676169 
 216      6E0A00
 217              		.text
 218              		.globl	g
 220              	g:
 221              	.LFB5:
  45:vuln.c        **** 
  46:vuln.c        **** int login_attempts;
  47:vuln.c        **** void g(const char *username, int ulen, const char *pass, int plen) {
 222              		.loc 1 47 0
 223              		.cfi_startproc
 224 0161 55       		pushl	%ebp
 225              		.cfi_def_cfa_offset 8
 226              		.cfi_offset 5, -8
 227 0162 89E5     		movl	%esp, %ebp
 228              		.cfi_def_cfa_register 5
 229 0164 83EC18   		subl	$24, %esp
  48:vuln.c        ****   int authd=0;
 230              		.loc 1 48 0
 231 0167 C745EC00 		movl	$0, -20(%ebp)
 231      000000
  49:vuln.c        ****   char *s1 = "/bin/ls";
 232              		.loc 1 49 0
 233 016e C745F009 		movl	$.LC1, -16(%ebp)
 233      000000
  50:vuln.c        ****   char *s2 = "/bin/false";
 234              		.loc 1 50 0
 235 0175 C745F411 		movl	$.LC2, -12(%ebp)
 235      000000
  51:vuln.c        ****   if (RANDOM)
  52:vuln.c        ****      authd |= wrauth(username, ulen, pass, plen);
  53:vuln.c        ****   else authd |= auth(username, ulen, pass, plen);
 236              		.loc 1 53 0
 237 017c FF7514   		pushl	20(%ebp)
 238 017f FF7510   		pushl	16(%ebp)
 239 0182 FF750C   		pushl	12(%ebp)
 240 0185 FF7508   		pushl	8(%ebp)
 241 0188 E8FCFFFF 		call	auth
 241      FF
 242 018d 83C410   		addl	$16, %esp
 243 0190 0945EC   		orl	%eax, -20(%ebp)
  54:vuln.c        **** 
  55:vuln.c        ****   if (authd) {
 244              		.loc 1 55 0
 245 0193 837DEC00 		cmpl	$0, -20(%ebp)
 246 0197 7468     		je	.L12
  56:vuln.c        ****      // Successfully authenticated
  57:vuln.c        ****      fprintf(stderr, "Authentication succeeded, executing ls\n");
 247              		.loc 1 57 0
 248 0199 A1000000 		movl	stderr, %eax
 248      00
 249 019e 50       		pushl	%eax
 250 019f 6A27     		pushl	$39
 251 01a1 6A01     		pushl	$1
 252 01a3 681C0000 		pushl	$.LC3
 252      00
 253 01a8 E8FCFFFF 		call	fwrite
 253      FF
 254 01ad 83C410   		addl	$16, %esp
  58:vuln.c        ****      err_abort(execl(s1, "ls", NULL)>=0); // Execute a shell, or
 255              		.loc 1 58 0
 256 01b0 83EC04   		subl	$4, %esp
 257 01b3 6A00     		pushl	$0
 258 01b5 68440000 		pushl	$.LC4
 258      00
 259 01ba FF75F0   		pushl	-16(%ebp)
 260 01bd E8FCFFFF 		call	execl
 260      FF
 261 01c2 83C410   		addl	$16, %esp
 262 01c5 85C0     		testl	%eax, %eax
 263 01c7 0F89D900 		jns	.L15
 263      0000
 264              		.loc 1 58 0 is_stmt 0 discriminator 1
 265 01cd A1000000 		movl	stderr, %eax
 265      00
 266 01d2 6A3A     		pushl	$58
 267 01d4 68470000 		pushl	$.LC5
 267      00
 268 01d9 684E0000 		pushl	$.LC6
 268      00
 269 01de 50       		pushl	%eax
 270 01df E8FCFFFF 		call	fprintf
 270      FF
 271 01e4 83C410   		addl	$16, %esp
 272 01e7 83EC0C   		subl	$12, %esp
 273 01ea 68630000 		pushl	$.LC7
 273      00
 274 01ef E8FCFFFF 		call	perror
 274      FF
 275 01f4 83C410   		addl	$16, %esp
 276 01f7 83EC0C   		subl	$12, %esp
 277 01fa 6A01     		pushl	$1
 278 01fc E8FCFFFF 		call	exit
 278      FF
 279              	.L12:
  59:vuln.c        ****   }
  60:vuln.c        ****   else { // Authentication failure
  61:vuln.c        ****      fprintf(stderr, "Login denied, ");
 280              		.loc 1 61 0 is_stmt 1
 281 0201 A1000000 		movl	stderr, %eax
 281      00
 282 0206 50       		pushl	%eax
 283 0207 6A0E     		pushl	$14
 284 0209 6A01     		pushl	$1
 285 020b 68640000 		pushl	$.LC8
 285      00
 286 0210 E8FCFFFF 		call	fwrite
 286      FF
 287 0215 83C410   		addl	$16, %esp
  62:vuln.c        ****      if (login_attempts++ > 3) {
 288              		.loc 1 62 0
 289 0218 A1000000 		movl	login_attempts, %eax
 289      00
 290 021d 8D5001   		leal	1(%eax), %edx
 291 0220 89150000 		movl	%edx, login_attempts
 291      0000
 292 0226 83F803   		cmpl	$3, %eax
 293 0229 7E64     		jle	.L14
  63:vuln.c        ****         fprintf(stderr, "executing /bin/false\n");
 294              		.loc 1 63 0
 295 022b A1000000 		movl	stderr, %eax
 295      00
 296 0230 50       		pushl	%eax
 297 0231 6A15     		pushl	$21
 298 0233 6A01     		pushl	$1
 299 0235 68730000 		pushl	$.LC9
 299      00
 300 023a E8FCFFFF 		call	fwrite
 300      FF
 301 023f 83C410   		addl	$16, %esp
  64:vuln.c        ****         err_abort(execl(s2, "false", NULL)>=0); // a program that prints an error
 302              		.loc 1 64 0
 303 0242 83EC04   		subl	$4, %esp
 304 0245 6A00     		pushl	$0
 305 0247 68890000 		pushl	$.LC10
 305      00
 306 024c FF75F4   		pushl	-12(%ebp)
 307 024f E8FCFFFF 		call	execl
 307      FF
 308 0254 83C410   		addl	$16, %esp
 309 0257 85C0     		testl	%eax, %eax
 310 0259 794B     		jns	.L15
 311              		.loc 1 64 0 is_stmt 0 discriminator 1
 312 025b A1000000 		movl	stderr, %eax
 312      00
 313 0260 6A40     		pushl	$64
 314 0262 68470000 		pushl	$.LC5
 314      00
 315 0267 684E0000 		pushl	$.LC6
 315      00
 316 026c 50       		pushl	%eax
 317 026d E8FCFFFF 		call	fprintf
 317      FF
 318 0272 83C410   		addl	$16, %esp
 319 0275 83EC0C   		subl	$12, %esp
 320 0278 68630000 		pushl	$.LC7
 320      00
 321 027d E8FCFFFF 		call	perror
 321      FF
 322 0282 83C410   		addl	$16, %esp
 323 0285 83EC0C   		subl	$12, %esp
 324 0288 6A01     		pushl	$1
 325 028a E8FCFFFF 		call	exit
 325      FF
 326              	.L14:
  65:vuln.c        ****      }
  66:vuln.c        ****      else fprintf(stderr, "try again\n");
 327              		.loc 1 66 0 is_stmt 1
 328 028f A1000000 		movl	stderr, %eax
 328      00
 329 0294 50       		pushl	%eax
 330 0295 6A0A     		pushl	$10
 331 0297 6A01     		pushl	$1
 332 0299 688F0000 		pushl	$.LC11
 332      00
 333 029e E8FCFFFF 		call	fwrite
 333      FF
 334 02a3 83C410   		addl	$16, %esp
 335              	.L15:
  67:vuln.c        ****   }
  68:vuln.c        **** }
 336              		.loc 1 68 0
 337 02a6 90       		nop
 338 02a7 C9       		leave
 339              		.cfi_restore 5
 340              		.cfi_def_cfa 4, 4
 341 02a8 C3       		ret
 342              		.cfi_endproc
 343              	.LFE5:
 345              		.section	.rodata
 346              	.LC12:
 347 009a 6F776E6D 		.string	"ownme called\n"
 347      65206361 
 347      6C6C6564 
 347      0A00
 348              		.text
 349              		.globl	ownme
 351              	ownme:
 352              	.LFB6:
  69:vuln.c        **** 
  70:vuln.c        **** #ifndef ASM_ONLY
  71:vuln.c        **** void padding() {
  72:vuln.c        **** int i, z;
  73:vuln.c        **** #include "padding.h"
  74:vuln.c        **** }
  75:vuln.c        **** #endif
  76:vuln.c        **** 
  77:vuln.c        **** void ownme() {
 353              		.loc 1 77 0
 354              		.cfi_startproc
 355 02a9 55       		pushl	%ebp
 356              		.cfi_def_cfa_offset 8
 357              		.cfi_offset 5, -8
 358 02aa 89E5     		movl	%esp, %ebp
 359              		.cfi_def_cfa_register 5
 360 02ac 83EC08   		subl	$8, %esp
  78:vuln.c        ****    fprintf(stderr, "ownme called\n");
 361              		.loc 1 78 0
 362 02af A1000000 		movl	stderr, %eax
 362      00
 363 02b4 50       		pushl	%eax
 364 02b5 6A0D     		pushl	$13
 365 02b7 6A01     		pushl	$1
 366 02b9 689A0000 		pushl	$.LC12
 366      00
 367 02be E8FCFFFF 		call	fwrite
 367      FF
 368 02c3 83C410   		addl	$16, %esp
  79:vuln.c        **** }
 369              		.loc 1 79 0
 370 02c6 90       		nop
 371 02c7 C9       		leave
 372              		.cfi_restore 5
 373              		.cfi_def_cfa 4, 4
 374 02c8 C3       		ret
 375              		.cfi_endproc
 376              	.LFE6:
 378              		.section	.rodata
 379              	.LC13:
 380 00a8 76756C6E 		.string	"vuln: quitting\n"
 380      3A207175 
 380      69747469 
 380      6E670A00 
 381              	.LC14:
 382 00b8 76756C6E 		.string	"vuln: Received:'"
 382      3A205265 
 382      63656976 
 382      65643A27 
 382      00
 383              	.LC15:
 384 00c9 270A00   		.string	"'\n"
 385              	.LC16:
 386 00cc 76756C6E 		.string	"vuln: Got user=%s, pass=%s\n"
 386      3A20476F 
 386      74207573 
 386      65723D25 
 386      732C2070 
 387              		.align 4
 388              	.LC17:
 389 00e8 76756C6E 		.string	"vuln: Use u and p commands before logging in\n"
 389      3A205573 
 389      65207520 
 389      616E6420 
 389      7020636F 
 390 0116 0000     		.align 4
 391              	.LC18:
 392 0118 76756C6E 		.string	"vuln: Invalid operation. Valid commands are:\n"
 392      3A20496E 
 392      76616C69 
 392      64206F70 
 392      65726174 
 393              	.LC19:
 394 0146 0965203C 		.string	"\te <data>: echo <data>\n"
 394      64617461 
 394      3E3A2065 
 394      63686F20 
 394      3C646174 
 395              	.LC20:
 396 015e 0975203C 		.string	"\tu <user>: enter username\n"
 396      75736572 
 396      3E3A2065 
 396      6E746572 
 396      20757365 
 397              	.LC21:
 398 0179 0970203C 		.string	"\tp <pass>: enter password\n"
 398      70617373 
 398      3E3A2065 
 398      6E746572 
 398      20706173 
 399              		.align 4
 400              	.LC22:
 401 0194 096C3A20 		.string	"\tl: login using previously provided username/password\n"
 401      6C6F6769 
 401      6E207573 
 401      696E6720 
 401      70726576 
 402              	.LC23:
 403 01cb 09713A20 		.string	"\tq: quit\n"
 403      71756974 
 403      0A00
 404              		.text
 405              		.globl	main_loop
 407              	main_loop:
 408              	.LFB7:
  80:vuln.c        **** 
  81:vuln.c        **** int main_loop(unsigned seed) {
 409              		.loc 1 81 0
 410              		.cfi_startproc
 411 02c9 55       		pushl	%ebp
 412              		.cfi_def_cfa_offset 8
 413              		.cfi_offset 5, -8
 414 02ca 89E5     		movl	%esp, %ebp
 415              		.cfi_def_cfa_register 5
 416 02cc 83EC38   		subl	$56, %esp
 417              		.loc 1 81 0
 418 02cf 65A11400 		movl	%gs:20, %eax
 418      0000
 419 02d5 8945F4   		movl	%eax, -12(%ebp)
 420 02d8 31C0     		xorl	%eax, %eax
  82:vuln.c        ****    int nread;
  83:vuln.c        ****    char *user=NULL, *pass=NULL;
 421              		.loc 1 83 0
 422 02da C745D000 		movl	$0, -48(%ebp)
 422      000000
 423 02e1 C745D400 		movl	$0, -44(%ebp)
 423      000000
  84:vuln.c        ****    unsigned ulen=0, plen=0;
 424              		.loc 1 84 0
 425 02e8 C745D800 		movl	$0, -40(%ebp)
 425      000000
 426 02ef C745DC00 		movl	$0, -36(%ebp)
 426      000000
  85:vuln.c        **** 
  86:vuln.c        ****    srandom(seed);
 427              		.loc 1 86 0
 428 02f6 83EC0C   		subl	$12, %esp
 429 02f9 FF7508   		pushl	8(%ebp)
 430 02fc E8FCFFFF 		call	srandom
 430      FF
 431 0301 83C410   		addl	$16, %esp
  87:vuln.c        ****    unsigned s = (unsigned)random();
 432              		.loc 1 87 0
 433 0304 E8FCFFFF 		call	random
 433      FF
 434 0309 8945E0   		movl	%eax, -32(%ebp)
  88:vuln.c        ****    s = s % LEN1;
 435              		.loc 1 88 0
 436 030c 8B4DE0   		movl	-32(%ebp), %ecx
 437 030f BA6D90C0 		movl	$12619885, %edx
 437      00
 438 0314 89C8     		movl	%ecx, %eax
 439 0316 F7E2     		mull	%edx
 440 0318 89C8     		movl	%ecx, %eax
 441 031a 29D0     		subl	%edx, %eax
 442 031c D1E8     		shrl	%eax
 443 031e 01D0     		addl	%edx, %eax
 444 0320 C1E809   		shrl	$9, %eax
 445 0323 69C0FD03 		imull	$1021, %eax, %eax
 445      0000
 446 0329 29C1     		subl	%eax, %ecx
 447 032b 89C8     		movl	%ecx, %eax
 448 032d 8945E0   		movl	%eax, -32(%ebp)
  89:vuln.c        ****    char *rdbuf = (char*)alloca(s+LEN1);
 449              		.loc 1 89 0
 450 0330 8B45E0   		movl	-32(%ebp), %eax
 451 0333 05FD0300 		addl	$1021, %eax
 451      00
 452 0338 8D500F   		leal	15(%eax), %edx
 453 033b B8100000 		movl	$16, %eax
 453      00
 454 0340 83E801   		subl	$1, %eax
 455 0343 01D0     		addl	%edx, %eax
 456 0345 B9100000 		movl	$16, %ecx
 456      00
 457 034a BA000000 		movl	$0, %edx
 457      00
 458 034f F7F1     		divl	%ecx
 459 0351 6BC010   		imull	$16, %eax, %eax
 460 0354 29C4     		subl	%eax, %esp
 461 0356 89E0     		movl	%esp, %eax
 462 0358 83C00F   		addl	$15, %eax
 463 035b C1E804   		shrl	$4, %eax
 464 035e C1E004   		sall	$4, %eax
 465 0361 8945E4   		movl	%eax, -28(%ebp)
  90:vuln.c        ****    char *tbuf;
  91:vuln.c        ****    unsigned tbufsz = ((unsigned)random()) % LEN1;
 466              		.loc 1 91 0
 467 0364 E8FCFFFF 		call	random
 467      FF
 468 0369 89C1     		movl	%eax, %ecx
 469 036b BA6D90C0 		movl	$12619885, %edx
 469      00
 470 0370 89C8     		movl	%ecx, %eax
 471 0372 F7E2     		mull	%edx
 472 0374 89C8     		movl	%ecx, %eax
 473 0376 29D0     		subl	%edx, %eax
 474 0378 D1E8     		shrl	%eax
 475 037a 01D0     		addl	%edx, %eax
 476 037c C1E809   		shrl	$9, %eax
 477 037f 8945E8   		movl	%eax, -24(%ebp)
 478 0382 8B45E8   		movl	-24(%ebp), %eax
 479 0385 69C0FD03 		imull	$1021, %eax, %eax
 479      0000
 480 038b 29C1     		subl	%eax, %ecx
 481 038d 89C8     		movl	%ecx, %eax
 482 038f 8945E8   		movl	%eax, -24(%ebp)
  92:vuln.c        ****    tbuf = (char*)alloca(tbufsz);
 483              		.loc 1 92 0
 484 0392 8B45E8   		movl	-24(%ebp), %eax
 485 0395 8D500F   		leal	15(%eax), %edx
 486 0398 B8100000 		movl	$16, %eax
 486      00
 487 039d 83E801   		subl	$1, %eax
 488 03a0 01D0     		addl	%edx, %eax
 489 03a2 B9100000 		movl	$16, %ecx
 489      00
 490 03a7 BA000000 		movl	$0, %edx
 490      00
 491 03ac F7F1     		divl	%ecx
 492 03ae 6BC010   		imull	$16, %eax, %eax
 493 03b1 29C4     		subl	%eax, %esp
 494 03b3 89E0     		movl	%esp, %eax
 495 03b5 83C00F   		addl	$15, %eax
 496 03b8 C1E804   		shrl	$4, %eax
 497 03bb C1E004   		sall	$4, %eax
 498 03be 8945EC   		movl	%eax, -20(%ebp)
 499              	.L31:
  93:vuln.c        **** 
  94:vuln.c        ****    do {
  95:vuln.c        ****       err_abort((nread = read(0, rdbuf, s-1)) >= 0);
 500              		.loc 1 95 0
 501 03c1 8B45E0   		movl	-32(%ebp), %eax
 502 03c4 83E801   		subl	$1, %eax
 503 03c7 83EC04   		subl	$4, %esp
 504 03ca 50       		pushl	%eax
 505 03cb FF75E4   		pushl	-28(%ebp)
 506 03ce 6A00     		pushl	$0
 507 03d0 E8FCFFFF 		call	read
 507      FF
 508 03d5 83C410   		addl	$16, %esp
 509 03d8 8945F0   		movl	%eax, -16(%ebp)
 510 03db 837DF000 		cmpl	$0, -16(%ebp)
 511 03df 7934     		jns	.L18
 512              		.loc 1 95 0 is_stmt 0 discriminator 1
 513 03e1 A1000000 		movl	stderr, %eax
 513      00
 514 03e6 6A5F     		pushl	$95
 515 03e8 68470000 		pushl	$.LC5
 515      00
 516 03ed 684E0000 		pushl	$.LC6
 516      00
 517 03f2 50       		pushl	%eax
 518 03f3 E8FCFFFF 		call	fprintf
 518      FF
 519 03f8 83C410   		addl	$16, %esp
 520 03fb 83EC0C   		subl	$12, %esp
 521 03fe 68630000 		pushl	$.LC7
 521      00
 522 0403 E8FCFFFF 		call	perror
 522      FF
 523 0408 83C410   		addl	$16, %esp
 524 040b 83EC0C   		subl	$12, %esp
 525 040e 6A01     		pushl	$1
 526 0410 E8FCFFFF 		call	exit
 526      FF
 527              	.L18:
  96:vuln.c        ****       if (nread == 0) {
 528              		.loc 1 96 0 is_stmt 1
 529 0415 837DF000 		cmpl	$0, -16(%ebp)
 530 0419 7521     		jne	.L19
  97:vuln.c        ****          fprintf(stderr, "vuln: quitting\n");
 531              		.loc 1 97 0
 532 041b A1000000 		movl	stderr, %eax
 532      00
 533 0420 50       		pushl	%eax
 534 0421 6A0F     		pushl	$15
 535 0423 6A01     		pushl	$1
 536 0425 68A80000 		pushl	$.LC13
 536      00
 537 042a E8FCFFFF 		call	fwrite
 537      FF
 538 042f 83C410   		addl	$16, %esp
  98:vuln.c        ****          return 0;
 539              		.loc 1 98 0
 540 0432 B8000000 		movl	$0, %eax
 540      00
 541 0437 E9490200 		jmp	.L20
 541      00
 542              	.L19:
  99:vuln.c        ****       }
 100:vuln.c        ****       fprintf(stderr, "vuln: Received:'");
 543              		.loc 1 100 0
 544 043c A1000000 		movl	stderr, %eax
 544      00
 545 0441 50       		pushl	%eax
 546 0442 6A10     		pushl	$16
 547 0444 6A01     		pushl	$1
 548 0446 68B80000 		pushl	$.LC14
 548      00
 549 044b E8FCFFFF 		call	fwrite
 549      FF
 550 0450 83C410   		addl	$16, %esp
 101:vuln.c        ****       print_escaped(stderr, rdbuf, nread);
 551              		.loc 1 101 0
 552 0453 8B55F0   		movl	-16(%ebp), %edx
 553 0456 A1000000 		movl	stderr, %eax
 553      00
 554 045b 83EC04   		subl	$4, %esp
 555 045e 52       		pushl	%edx
 556 045f FF75E4   		pushl	-28(%ebp)
 557 0462 50       		pushl	%eax
 558 0463 E8FCFFFF 		call	print_escaped
 558      FF
 559 0468 83C410   		addl	$16, %esp
 102:vuln.c        ****       fprintf(stderr, "'\n");
 560              		.loc 1 102 0
 561 046b A1000000 		movl	stderr, %eax
 561      00
 562 0470 50       		pushl	%eax
 563 0471 6A02     		pushl	$2
 564 0473 6A01     		pushl	$1
 565 0475 68C90000 		pushl	$.LC15
 565      00
 566 047a E8FCFFFF 		call	fwrite
 566      FF
 567 047f 83C410   		addl	$16, %esp
 103:vuln.c        ****       rdbuf[nread] = '\0'; // null-terminate
 568              		.loc 1 103 0
 569 0482 8B55F0   		movl	-16(%ebp), %edx
 570 0485 8B45E4   		movl	-28(%ebp), %eax
 571 0488 01D0     		addl	%edx, %eax
 572 048a C60000   		movb	$0, (%eax)
 104:vuln.c        ****       switch (rdbuf[0]) {
 573              		.loc 1 104 0
 574 048d 8B45E4   		movl	-28(%ebp), %eax
 575 0490 0FB600   		movzbl	(%eax), %eax
 576 0493 0FBEC0   		movsbl	%al, %eax
 577 0496 83E865   		subl	$101, %eax
 578 0499 83F810   		cmpl	$16, %eax
 579 049c 0F875301 		ja	.L21
 579      0000
 580 04a2 8B0485D8 		movl	.L23(,%eax,4), %eax
 580      010000
 581 04a9 FFE0     		jmp	*%eax
 582              		.section	.rodata
 583 01d5 000000   		.align 4
 584              		.align 4
 585              	.L23:
 586 01d8 AB040000 		.long	.L22
 587 01dc F5050000 		.long	.L21
 588 01e0 F5050000 		.long	.L21
 589 01e4 F5050000 		.long	.L21
 590 01e8 F5050000 		.long	.L21
 591 01ec F5050000 		.long	.L21
 592 01f0 F5050000 		.long	.L21
 593 01f4 41050000 		.long	.L24
 594 01f8 F5050000 		.long	.L21
 595 01fc F5050000 		.long	.L21
 596 0200 F5050000 		.long	.L21
 597 0204 0A050000 		.long	.L25
 598 0208 D4050000 		.long	.L26
 599 020c F5050000 		.long	.L21
 600 0210 F5050000 		.long	.L21
 601 0214 F5050000 		.long	.L21
 602 0218 D3040000 		.long	.L27
 603              		.text
 604              	.L22:
 105:vuln.c        **** 
 106:vuln.c        ****       case 'e': // echo command: e <string_to_echo>
 107:vuln.c        ****          printf(&rdbuf[2]);
 605              		.loc 1 107 0
 606 04ab 8B45E4   		movl	-28(%ebp), %eax
 607 04ae 83C002   		addl	$2, %eax
 608 04b1 83EC0C   		subl	$12, %esp
 609 04b4 50       		pushl	%eax
 610 04b5 E8FCFFFF 		call	printf
 610      FF
 611 04ba 83C410   		addl	$16, %esp
 108:vuln.c        ****          fflush(stdout);
 612              		.loc 1 108 0
 613 04bd A1000000 		movl	stdout, %eax
 613      00
 614 04c2 83EC0C   		subl	$12, %esp
 615 04c5 50       		pushl	%eax
 616 04c6 E8FCFFFF 		call	fflush
 616      FF
 617 04cb 83C410   		addl	$16, %esp
 109:vuln.c        ****          break;
 618              		.loc 1 109 0
 619 04ce E9AD0100 		jmp	.L28
 619      00
 620              	.L27:
 110:vuln.c        **** 
 111:vuln.c        ****       case 'u': // provide username
 112:vuln.c        ****          ulen = nread-3; // skips last char
 621              		.loc 1 112 0
 622 04d3 8B45F0   		movl	-16(%ebp), %eax
 623 04d6 83E803   		subl	$3, %eax
 624 04d9 8945D8   		movl	%eax, -40(%ebp)
 113:vuln.c        ****          user = malloc(ulen);
 625              		.loc 1 113 0
 626 04dc 83EC0C   		subl	$12, %esp
 627 04df FF75D8   		pushl	-40(%ebp)
 628 04e2 E8FCFFFF 		call	my_malloc
 628      FF
 629 04e7 83C410   		addl	$16, %esp
 630 04ea 8945D0   		movl	%eax, -48(%ebp)
 114:vuln.c        ****          bcopy(&rdbuf[2], user, ulen);
 631              		.loc 1 114 0
 632 04ed 8B45E4   		movl	-28(%ebp), %eax
 633 04f0 83C002   		addl	$2, %eax
 634 04f3 83EC04   		subl	$4, %esp
 635 04f6 FF75D8   		pushl	-40(%ebp)
 636 04f9 FF75D0   		pushl	-48(%ebp)
 637 04fc 50       		pushl	%eax
 638 04fd E8FCFFFF 		call	bcopy
 638      FF
 639 0502 83C410   		addl	$16, %esp
 115:vuln.c        ****          break;
 640              		.loc 1 115 0
 641 0505 E9760100 		jmp	.L28
 641      00
 642              	.L25:
 116:vuln.c        **** 
 117:vuln.c        ****       case 'p': // provide username
 118:vuln.c        ****          pass = malloc(plen);
 643              		.loc 1 118 0
 644 050a 83EC0C   		subl	$12, %esp
 645 050d FF75DC   		pushl	-36(%ebp)
 646 0510 E8FCFFFF 		call	my_malloc
 646      FF
 647 0515 83C410   		addl	$16, %esp
 648 0518 8945D4   		movl	%eax, -44(%ebp)
 119:vuln.c        ****          plen = nread-3;
 649              		.loc 1 119 0
 650 051b 8B45F0   		movl	-16(%ebp), %eax
 651 051e 83E803   		subl	$3, %eax
 652 0521 8945DC   		movl	%eax, -36(%ebp)
 120:vuln.c        ****          bcopy(&rdbuf[2], pass, plen);
 653              		.loc 1 120 0
 654 0524 8B45E4   		movl	-28(%ebp), %eax
 655 0527 83C002   		addl	$2, %eax
 656 052a 83EC04   		subl	$4, %esp
 657 052d FF75DC   		pushl	-36(%ebp)
 658 0530 FF75D4   		pushl	-44(%ebp)
 659 0533 50       		pushl	%eax
 660 0534 E8FCFFFF 		call	bcopy
 660      FF
 661 0539 83C410   		addl	$16, %esp
 121:vuln.c        ****          break;
 662              		.loc 1 121 0
 663 053c E93F0100 		jmp	.L28
 663      00
 664              	.L24:
 122:vuln.c        **** 
 123:vuln.c        ****       case 'l': { // login using previously supplied username and password
 124:vuln.c        ****          if (user != NULL && pass != NULL) {
 665              		.loc 1 124 0
 666 0541 837DD000 		cmpl	$0, -48(%ebp)
 667 0545 7471     		je	.L29
 668              		.loc 1 124 0 is_stmt 0 discriminator 1
 669 0547 837DD400 		cmpl	$0, -44(%ebp)
 670 054b 746B     		je	.L29
 125:vuln.c        ****             fprintf(stderr, "vuln: Got user=%s, pass=%s\n", user, pass);
 671              		.loc 1 125 0 is_stmt 1
 672 054d A1000000 		movl	stderr, %eax
 672      00
 673 0552 FF75D4   		pushl	-44(%ebp)
 674 0555 FF75D0   		pushl	-48(%ebp)
 675 0558 68CC0000 		pushl	$.LC16
 675      00
 676 055d 50       		pushl	%eax
 677 055e E8FCFFFF 		call	fprintf
 677      FF
 678 0563 83C410   		addl	$16, %esp
 126:vuln.c        ****             g(user, ulen, pass, plen);
 679              		.loc 1 126 0
 680 0566 8B55DC   		movl	-36(%ebp), %edx
 681 0569 8B45D8   		movl	-40(%ebp), %eax
 682 056c 52       		pushl	%edx
 683 056d FF75D4   		pushl	-44(%ebp)
 684 0570 50       		pushl	%eax
 685 0571 FF75D0   		pushl	-48(%ebp)
 686 0574 E8FCFFFF 		call	g
 686      FF
 687 0579 83C410   		addl	$16, %esp
 127:vuln.c        ****             free(pass);
 688              		.loc 1 127 0
 689 057c 83EC0C   		subl	$12, %esp
 690 057f FF75D4   		pushl	-44(%ebp)
 691 0582 E8FCFFFF 		call	my_free
 691      FF
 692 0587 83C410   		addl	$16, %esp
 128:vuln.c        ****             free(user);
 693              		.loc 1 128 0
 694 058a 83EC0C   		subl	$12, %esp
 695 058d FF75D0   		pushl	-48(%ebp)
 696 0590 E8FCFFFF 		call	my_free
 696      FF
 697 0595 83C410   		addl	$16, %esp
 129:vuln.c        ****             user=pass=NULL;
 698              		.loc 1 129 0
 699 0598 C745D400 		movl	$0, -44(%ebp)
 699      000000
 700 059f 8B45D4   		movl	-44(%ebp), %eax
 701 05a2 8945D0   		movl	%eax, -48(%ebp)
 130:vuln.c        ****             ulen=0; plen=0;
 702              		.loc 1 130 0
 703 05a5 C745D800 		movl	$0, -40(%ebp)
 703      000000
 704 05ac C745DC00 		movl	$0, -36(%ebp)
 704      000000
 131:vuln.c        ****          }
 132:vuln.c        ****          else fprintf(stderr, "vuln: Use u and p commands before logging in\n");
 133:vuln.c        ****          break;
 705              		.loc 1 133 0
 706 05b3 E9C80000 		jmp	.L28
 706      00
 707              	.L29:
 132:vuln.c        ****          break;
 708              		.loc 1 132 0
 709 05b8 A1000000 		movl	stderr, %eax
 709      00
 710 05bd 50       		pushl	%eax
 711 05be 6A2D     		pushl	$45
 712 05c0 6A01     		pushl	$1
 713 05c2 68E80000 		pushl	$.LC17
 713      00
 714 05c7 E8FCFFFF 		call	fwrite
 714      FF
 715 05cc 83C410   		addl	$16, %esp
 716              		.loc 1 133 0
 717 05cf E9AC0000 		jmp	.L28
 717      00
 718              	.L26:
 134:vuln.c        ****       }
 135:vuln.c        **** 
 136:vuln.c        ****       case 'q':
 137:vuln.c        ****          fprintf(stderr, "vuln: quitting\n");
 719              		.loc 1 137 0
 720 05d4 A1000000 		movl	stderr, %eax
 720      00
 721 05d9 50       		pushl	%eax
 722 05da 6A0F     		pushl	$15
 723 05dc 6A01     		pushl	$1
 724 05de 68A80000 		pushl	$.LC13
 724      00
 725 05e3 E8FCFFFF 		call	fwrite
 725      FF
 726 05e8 83C410   		addl	$16, %esp
 138:vuln.c        ****          return 0;
 727              		.loc 1 138 0
 728 05eb B8000000 		movl	$0, %eax
 728      00
 729 05f0 E9900000 		jmp	.L20
 729      00
 730              	.L21:
 139:vuln.c        **** 
 140:vuln.c        ****       default:
 141:vuln.c        ****          fprintf(stderr, "vuln: Invalid operation. Valid commands are:\n");
 731              		.loc 1 141 0
 732 05f5 A1000000 		movl	stderr, %eax
 732      00
 733 05fa 50       		pushl	%eax
 734 05fb 6A2D     		pushl	$45
 735 05fd 6A01     		pushl	$1
 736 05ff 68180100 		pushl	$.LC18
 736      00
 737 0604 E8FCFFFF 		call	fwrite
 737      FF
 738 0609 83C410   		addl	$16, %esp
 142:vuln.c        ****          fprintf(stderr, "\te <data>: echo <data>\n");
 739              		.loc 1 142 0
 740 060c A1000000 		movl	stderr, %eax
 740      00
 741 0611 50       		pushl	%eax
 742 0612 6A17     		pushl	$23
 743 0614 6A01     		pushl	$1
 744 0616 68460100 		pushl	$.LC19
 744      00
 745 061b E8FCFFFF 		call	fwrite
 745      FF
 746 0620 83C410   		addl	$16, %esp
 143:vuln.c        ****          fprintf(stderr, "\tu <user>: enter username\n");
 747              		.loc 1 143 0
 748 0623 A1000000 		movl	stderr, %eax
 748      00
 749 0628 50       		pushl	%eax
 750 0629 6A1A     		pushl	$26
 751 062b 6A01     		pushl	$1
 752 062d 685E0100 		pushl	$.LC20
 752      00
 753 0632 E8FCFFFF 		call	fwrite
 753      FF
 754 0637 83C410   		addl	$16, %esp
 144:vuln.c        ****          fprintf(stderr, "\tp <pass>: enter password\n");
 755              		.loc 1 144 0
 756 063a A1000000 		movl	stderr, %eax
 756      00
 757 063f 50       		pushl	%eax
 758 0640 6A1A     		pushl	$26
 759 0642 6A01     		pushl	$1
 760 0644 68790100 		pushl	$.LC21
 760      00
 761 0649 E8FCFFFF 		call	fwrite
 761      FF
 762 064e 83C410   		addl	$16, %esp
 145:vuln.c        ****          fprintf(stderr,
 763              		.loc 1 145 0
 764 0651 A1000000 		movl	stderr, %eax
 764      00
 765 0656 50       		pushl	%eax
 766 0657 6A36     		pushl	$54
 767 0659 6A01     		pushl	$1
 768 065b 68940100 		pushl	$.LC22
 768      00
 769 0660 E8FCFFFF 		call	fwrite
 769      FF
 770 0665 83C410   		addl	$16, %esp
 146:vuln.c        ****                  "\tl: login using previously provided username/password\n");
 147:vuln.c        ****          fprintf(stderr, "\tq: quit\n");
 771              		.loc 1 147 0
 772 0668 A1000000 		movl	stderr, %eax
 772      00
 773 066d 50       		pushl	%eax
 774 066e 6A09     		pushl	$9
 775 0670 6A01     		pushl	$1
 776 0672 68CB0100 		pushl	$.LC23
 776      00
 777 0677 E8FCFFFF 		call	fwrite
 777      FF
 778 067c 83C410   		addl	$16, %esp
 148:vuln.c        ****          break;
 779              		.loc 1 148 0
 780 067f 90       		nop
 781              	.L28:
 149:vuln.c        ****       }
 150:vuln.c        ****    } while (1);
 782              		.loc 1 150 0 discriminator 1
 783 0680 E93CFDFF 		jmp	.L31
 783      FF
 784              	.L20:
 151:vuln.c        **** }
 785              		.loc 1 151 0
 786 0685 8B4DF4   		movl	-12(%ebp), %ecx
 787 0688 65330D14 		xorl	%gs:20, %ecx
 787      000000
 788 068f 7405     		je	.L32
 789 0691 E8FCFFFF 		call	__stack_chk_fail
 789      FF
 790              	.L32:
 791 0696 C9       		leave
 792              		.cfi_restore 5
 793              		.cfi_def_cfa 4, 4
 794 0697 C3       		ret
 795              		.cfi_endproc
 796              	.LFE7:
 798              		.section	.rodata
 799              	.LC24:
 800 021c 55736167 		.string	"Usage: %s <group_id>\n"
 800      653A2025 
 800      73203C67 
 800      726F7570 
 800      5F69643E 
 801 0232 0000     		.align 4
 802              	.LC25:
 803 0234 3C67726F 		.string	"<group_id> must be between 0 and %d\n"
 803      75705F69 
 803      643E206D 
 803      75737420 
 803      62652062 
 804              		.text
 805              		.globl	main
 807              	main:
 808              	.LFB8:
 152:vuln.c        **** 
 153:vuln.c        **** int main(int argc, char *argv[]) {
 809              		.loc 1 153 0
 810              		.cfi_startproc
 811 0698 8D4C2404 		leal	4(%esp), %ecx
 812              		.cfi_def_cfa 1, 0
 813 069c 83E4F0   		andl	$-16, %esp
 814 069f FF71FC   		pushl	-4(%ecx)
 815 06a2 55       		pushl	%ebp
 816              		.cfi_escape 0x10,0x5,0x2,0x75,0
 817 06a3 89E5     		movl	%esp, %ebp
 818 06a5 53       		pushl	%ebx
 819 06a6 51       		pushl	%ecx
 820              		.cfi_escape 0xf,0x3,0x75,0x78,0x6
 821              		.cfi_escape 0x10,0x3,0x2,0x75,0x7c
 822 06a7 83EC10   		subl	$16, %esp
 823 06aa 89CB     		movl	%ecx, %ebx
 154:vuln.c        **** 
 155:vuln.c        ****    unsigned seed=GRP;
 824              		.loc 1 155 0
 825 06ac C745F404 		movl	$4, -12(%ebp)
 825      000000
 156:vuln.c        **** 
 157:vuln.c        ****    if (argc >= 2) seed = atoi(argv[1]);
 826              		.loc 1 157 0
 827 06b3 833B01   		cmpl	$1, (%ebx)
 828 06b6 7E17     		jle	.L34
 829              		.loc 1 157 0 is_stmt 0 discriminator 1
 830 06b8 8B4304   		movl	4(%ebx), %eax
 831 06bb 83C004   		addl	$4, %eax
 832 06be 8B00     		movl	(%eax), %eax
 833 06c0 83EC0C   		subl	$12, %esp
 834 06c3 50       		pushl	%eax
 835 06c4 E8FCFFFF 		call	atoi
 835      FF
 836 06c9 83C410   		addl	$16, %esp
 837 06cc 8945F4   		movl	%eax, -12(%ebp)
 838              	.L34:
 158:vuln.c        ****    if (seed > MAX_GRP) {
 839              		.loc 1 158 0 is_stmt 1
 840 06cf 837DF464 		cmpl	$100, -12(%ebp)
 841 06d3 763E     		jbe	.L35
 159:vuln.c        ****       fprintf(stderr, "Usage: %s <group_id>\n", argv[0]);
 842              		.loc 1 159 0
 843 06d5 8B4304   		movl	4(%ebx), %eax
 844 06d8 8B10     		movl	(%eax), %edx
 845 06da A1000000 		movl	stderr, %eax
 845      00
 846 06df 83EC04   		subl	$4, %esp
 847 06e2 52       		pushl	%edx
 848 06e3 681C0200 		pushl	$.LC24
 848      00
 849 06e8 50       		pushl	%eax
 850 06e9 E8FCFFFF 		call	fprintf
 850      FF
 851 06ee 83C410   		addl	$16, %esp
 160:vuln.c        ****       fprintf(stderr, "<group_id> must be between 0 and %d\n", MAX_GRP);
 852              		.loc 1 160 0
 853 06f1 A1000000 		movl	stderr, %eax
 853      00
 854 06f6 83EC04   		subl	$4, %esp
 855 06f9 6A64     		pushl	$100
 856 06fb 68340200 		pushl	$.LC25
 856      00
 857 0700 50       		pushl	%eax
 858 0701 E8FCFFFF 		call	fprintf
 858      FF
 859 0706 83C410   		addl	$16, %esp
 161:vuln.c        ****       exit(1);
 860              		.loc 1 161 0
 861 0709 83EC0C   		subl	$12, %esp
 862 070c 6A01     		pushl	$1
 863 070e E8FCFFFF 		call	exit
 863      FF
 864              	.L35:
 162:vuln.c        ****    }
 163:vuln.c        **** 
 164:vuln.c        ****   return main_loop(seed);
 865              		.loc 1 164 0
 866 0713 83EC0C   		subl	$12, %esp
 867 0716 FF75F4   		pushl	-12(%ebp)
 868 0719 E8FCFFFF 		call	main_loop
 868      FF
 869 071e 83C410   		addl	$16, %esp
 165:vuln.c        **** };
 870              		.loc 1 165 0
 871 0721 8D65F8   		leal	-8(%ebp), %esp
 872 0724 59       		popl	%ecx
 873              		.cfi_restore 1
 874              		.cfi_def_cfa 1, 0
 875 0725 5B       		popl	%ebx
 876              		.cfi_restore 3
 877 0726 5D       		popl	%ebp
 878              		.cfi_restore 5
 879 0727 8D61FC   		leal	-4(%ecx), %esp
 880              		.cfi_def_cfa 4, 4
 881 072a C3       		ret
 882              		.cfi_endproc
 883              	.LFE8:
 885              	.Letext0:
 886              		.file 2 "/usr/lib/gcc/i686-linux-gnu/5/include/stddef.h"
 887              		.file 3 "/usr/include/i386-linux-gnu/bits/types.h"
 888              		.file 4 "/usr/include/stdio.h"
 889              		.file 5 "/usr/include/libio.h"
 890              		.file 6 "/usr/include/ctype.h"
