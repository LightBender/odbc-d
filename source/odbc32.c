#pragma attribute(push, nogc, nothrow)

#define BYTE unsigned char
#define DWORD unsigned long
#define WORD unsigned short
#define __int64 long long

#define ODBCVER 0x0400

#include <sal.h>
#include <no_sal2.h>

//Do not change the order of the files
#include "..\spec\Windows\inc\sqltypes.h"
#include "..\spec\Windows\inc\sql.h"
#include "..\spec\Windows\inc\sqlucode.h"
#include "..\spec\Windows\inc\sqlext.h"

#pragma pack(pop)