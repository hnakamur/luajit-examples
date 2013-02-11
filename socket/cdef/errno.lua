local ffi = require "ffi"

ffi.cdef[[
extern int errno;

static const int EPERM = 1; /* Operation not permitted */
static const int ENOENT = 2; /* No such file or directory */
static const int ESRCH = 3; /* No such process */
static const int EINTR = 4; /* Interrupted system call */
static const int EIO = 5; /* I/O error */
static const int ENXIO = 6; /* No such device or address */
static const int E2BIG = 7; /* Argument list too long */
static const int ENOEXEC = 8; /* Exec format error */
static const int EBADF = 9; /* Bad file number */
static const int ECHILD = 10; /* No child processes */
static const int EAGAIN = 11; /* Try again */
static const int ENOMEM = 12; /* Out of memory */
static const int EACCES = 13; /* Permission denied */
static const int EFAULT = 14; /* Bad address */
static const int ENOTBLK = 15; /* Block device required */
static const int EBUSY = 16; /* Device or resource busy */
static const int EEXIST = 17; /* File exists */
static const int EXDEV = 18; /* Cross-device link */
static const int ENODEV = 19; /* No such device */
static const int ENOTDIR = 20; /* Not a directory */
static const int EISDIR = 21; /* Is a directory */
static const int EINVAL = 22; /* Invalid argument */
static const int ENFILE = 23; /* File table overflow */
static const int EMFILE = 24; /* Too many open files */
static const int ENOTTY = 25; /* Not a typewriter */
static const int ETXTBSY = 26; /* Text file busy */
static const int EFBIG = 27; /* File too large */
static const int ENOSPC = 28; /* No space left on device */
static const int ESPIPE = 29; /* Illegal seek */
static const int EROFS = 30; /* Read-only file system */
static const int EMLINK = 31; /* Too many links */
static const int EPIPE = 32; /* Broken pipe */
static const int EDOM = 33; /* Math argument out of domain of func */
static const int ERANGE = 34; /* Math result not representable */

static const int EDEADLK = 35; /* Resource deadlock would occur */
static const int ENAMETOOLONG = 36; /* File name too long */
static const int ENOLCK = 37; /* No record locks available */
static const int ENOSYS = 38; /* Function not implemented */
static const int ENOTEMPTY = 39; /* Directory not empty */
static const int ELOOP = 40; /* Too many symbolic links encountered */
static const int EWOULDBLOCK = EAGAIN; /* Operation would block */
static const int ENOMSG = 42; /* No message of desired type */
static const int EIDRM = 43; /* Identifier removed */
static const int ECHRNG = 44; /* Channel number out of range */
static const int EL2NSYNC = 45; /* Level 2 not synchronized */
static const int EL3HLT = 46; /* Level 3 halted */
static const int EL3RST = 47; /* Level 3 reset */
static const int ELNRNG = 48; /* Link number out of range */
static const int EUNATCH = 49; /* Protocol driver not attached */
static const int ENOCSI = 50; /* No CSI structure available */
static const int EL2HLT = 51; /* Level 2 halted */
static const int EBADE = 52; /* Invalid exchange */
static const int EBADR = 53; /* Invalid request descriptor */
static const int EXFULL = 54; /* Exchange full */
static const int ENOANO = 55; /* No anode */
static const int EBADRQC = 56; /* Invalid request code */
static const int EBADSLT = 57; /* Invalid slot */

static const int EDEADLOCK = EDEADLK;

static const int EBFONT = 59; /* Bad font file format */
static const int ENOSTR = 60; /* Device not a stream */
static const int ENODATA = 61; /* No data available */
static const int ETIME = 62; /* Timer expired */
static const int ENOSR = 63; /* Out of streams resources */
static const int ENONET = 64; /* Machine is not on the network */
static const int ENOPKG = 65; /* Package not installed */
static const int EREMOTE = 66; /* Object is remote */
static const int ENOLINK = 67; /* Link has been severed */
static const int EADV = 68; /* Advertise error */
static const int ESRMNT = 69; /* Srmount error */
static const int ECOMM = 70; /* Communication error on send */
static const int EPROTO = 71; /* Protocol error */
static const int EMULTIHOP = 72; /* Multihop attempted */
static const int EDOTDOT = 73; /* RFS specific error */
static const int EBADMSG = 74; /* Not a data message */
static const int EOVERFLOW = 75; /* Value too large for defined data type */
static const int ENOTUNIQ = 76; /* Name not unique on network */
static const int EBADFD = 77; /* File descriptor in bad state */
static const int EREMCHG = 78; /* Remote address changed */
static const int ELIBACC = 79; /* Can not access a needed shared library */
static const int ELIBBAD = 80; /* Accessing a corrupted shared library */
static const int ELIBSCN = 81; /* .lib section in a.out corrupted */
static const int ELIBMAX = 82; /* Attempting to link in too many shared libraries */
static const int ELIBEXEC = 83; /* Cannot exec a shared library directly */
static const int EILSEQ = 84; /* Illegal byte sequence */
static const int ERESTART = 85; /* Interrupted system call should be restarted */
static const int ESTRPIPE = 86; /* Streams pipe error */
static const int EUSERS = 87; /* Too many users */
static const int ENOTSOCK = 88; /* Socket operation on non-socket */
static const int EDESTADDRREQ = 89; /* Destination address required */
static const int EMSGSIZE = 90; /* Message too long */
static const int EPROTOTYPE = 91; /* Protocol wrong type for socket */
static const int ENOPROTOOPT = 92; /* Protocol not available */
static const int EPROTONOSUPPORT = 93; /* Protocol not supported */
static const int ESOCKTNOSUPPORT = 94; /* Socket type not supported */
static const int EOPNOTSUPP = 95; /* Operation not supported on transport endpoint */
static const int EPFNOSUPPORT = 96; /* Protocol family not supported */
static const int EAFNOSUPPORT = 97; /* Address family not supported by protocol */
static const int EADDRINUSE = 98; /* Address already in use */
static const int EADDRNOTAVAIL = 99; /* Cannot assign requested address */
static const int ENETDOWN = 100; /* Network is down */
static const int ENETUNREACH = 101; /* Network is unreachable */
static const int ENETRESET = 102; /* Network dropped connection because of reset */
static const int ECONNABORTED = 103; /* Software caused connection abort */
static const int ECONNRESET = 104; /* Connection reset by peer */
static const int ENOBUFS = 105; /* No buffer space available */
static const int EISCONN = 106; /* Transport endpoint is already connected */
static const int ENOTCONN = 107; /* Transport endpoint is not connected */
static const int ESHUTDOWN = 108; /* Cannot send after transport endpoint shutdown */
static const int ETOOMANYREFS = 109; /* Too many references: cannot splice */
static const int ETIMEDOUT = 110; /* Connection timed out */
static const int ECONNREFUSED = 111; /* Connection refused */
static const int EHOSTDOWN = 112; /* Host is down */
static const int EHOSTUNREACH = 113; /* No route to host */
static const int EALREADY = 114; /* Operation already in progress */
static const int EINPROGRESS = 115; /* Operation now in progress */
static const int ESTALE = 116; /* Stale NFS file handle */
static const int EUCLEAN = 117; /* Structure needs cleaning */
static const int ENOTNAM = 118; /* Not a XENIX named type file */
static const int ENAVAIL = 119; /* No XENIX semaphores available */
static const int EISNAM = 120; /* Is a named type file */
static const int EREMOTEIO = 121; /* Remote I/O error */
static const int EDQUOT = 122; /* Quota exceeded */

static const int ENOMEDIUM = 123; /* No medium found */
static const int EMEDIUMTYPE = 124; /* Wrong medium type */
static const int ECANCELED = 125; /* Operation Canceled */
static const int ENOKEY = 126; /* Required key not available */
static const int EKEYEXPIRED = 127; /* Key has expired */
static const int EKEYREVOKED = 128; /* Key has been revoked */
static const int EKEYREJECTED = 129; /* Key was rejected by service */

/* for robust mutexes */
static const int EOWNERDEAD = 130; /* Owner died */
static const int ENOTRECOVERABLE = 131; /* State not recoverable */

static const int ERFKILL = 132; /* Operation not possible due to RF-kill */

static const int EHWPOISON = 133; /* Memory page has hardware error */
]]

