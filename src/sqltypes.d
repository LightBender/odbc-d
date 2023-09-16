// D import file generated from 'src\sqltypes.c'
extern (C)
{
	alias BYTE = ubyte;
	alias DWORD = uint;
	alias WORD = ushort;
	alias UINT64 = ulong;
	alias INT64 = long;
	alias SQLCHAR = ubyte;
	alias SQLSCHAR = byte;
	alias SQLDATE = ubyte;
	alias SQLDECIMAL = ubyte;
	alias SQLDOUBLE = double;
	alias SQLFLOAT = double;
	alias SQLINTEGER = int;
	alias SQLUINTEGER = uint;
	alias SQLLEN = long;
	alias SQLULEN = ulong;
	alias SQLSETPOSIROW = ulong;
	alias SQLNUMERIC = ubyte;
	alias SQLPOINTER = void*;
	alias SQLREAL = float;
	alias SQLSMALLINT = short;
	alias SQLUSMALLINT = ushort;
	alias SQLTIME = ubyte;
	alias SQLTIMESTAMP = ubyte;
	alias SQLVARCHAR = ubyte;
	alias SQLRETURN = short;
	alias SQLHANDLE = void*;
	alias SQLHENV = void*;
	alias SQLHDBC = void*;
	alias SQLHSTMT = void*;
	alias SQLHDESC = void*;
	alias UCHAR = ubyte;
	alias SCHAR = byte;
	alias SQLSCHAR = byte;
	alias SDWORD = int;
	alias SWORD = short;
	alias UDWORD = uint;
	alias UWORD = ushort;
	alias SLONG = int;
	alias SSHORT = short;
	alias ULONG = uint;
	alias USHORT = ushort;
	alias SDOUBLE = double;
	alias LDOUBLE = double;
	alias SFLOAT = float;
	alias PTR = void*;
	alias HENV = void*;
	alias HDBC = void*;
	alias HSTMT = void*;
	alias RETCODE = short;
	alias SQLHWND = void*;
	align struct tagDATE_STRUCT
	{
		short year = void;
		ushort month = void;
		ushort day = void;
	}
	alias DATE_STRUCT = struct tagDATE_STRUCT;
	align struct tagDATE_STRUCT;
	alias SQL_DATE_STRUCT = struct tagDATE_STRUCT;
	align struct tagTIME_STRUCT
	{
		ushort hour = void;
		ushort minute = void;
		ushort second = void;
	}
	alias TIME_STRUCT = struct tagTIME_STRUCT;
	align struct tagTIME_STRUCT;
	alias SQL_TIME_STRUCT = struct tagTIME_STRUCT;
	align struct tagTIMESTAMP_STRUCT
	{
		short year = void;
		ushort month = void;
		ushort day = void;
		ushort hour = void;
		ushort minute = void;
		ushort second = void;
		uint fraction = void;
	}
	alias TIMESTAMP_STRUCT = struct tagTIMESTAMP_STRUCT;
	align struct tagTIMESTAMP_STRUCT;
	alias SQL_TIMESTAMP_STRUCT = struct tagTIMESTAMP_STRUCT;
	align struct tagTIME_WITH_TIMEZONE_STRUCT
	{
		ushort hour = void;
		ushort minute = void;
		ushort second = void;
		short timezone_hours = void;
		ushort timezone_minutes = void;
	}
	alias TIME_WITH_TIMEZONE_STRUCT = struct tagTIME_WITH_TIMEZONE_STRUCT;
	align struct tagTIMESTAMP_WITH_TIMEZONE_STRUCT
	{
		short year = void;
		ushort month = void;
		ushort day = void;
		ushort hour = void;
		ushort minute = void;
		ushort second = void;
		uint fraction = void;
		short timezone_hours = void;
		ushort timezone_minutes = void;
	}
	alias TIMESTAMP_WITH_TIMEZONE_STRUCT = struct tagTIMESTAMP_WITH_TIMEZONE_STRUCT;
	enum SQLINTERVAL;
	align struct tagSQL_YEAR_MONTH
	{
		uint year = void;
		uint month = void;
	}
	alias SQL_YEAR_MONTH_STRUCT = struct tagSQL_YEAR_MONTH;
	align struct tagSQL_DAY_SECOND
	{
		uint day = void;
		uint hour = void;
		uint minute = void;
		uint second = void;
		uint fraction = void;
	}
	alias SQL_DAY_SECOND_STRUCT = struct tagSQL_DAY_SECOND;
	align struct tagSQL_INTERVAL_STRUCT
	{
		SQLINTERVAL interval_type = void;
		short interval_sign = void;
		union  intval = void;
	}
	alias SQL_INTERVAL_STRUCT = struct tagSQL_INTERVAL_STRUCT;
	alias SQLBIGINT = long;
	alias SQLUBIGINT = ulong;
	align struct tagSQL_NUMERIC_STRUCT
	{
		ubyte precision = void;
		byte scale = void;
		ubyte sign = void;
		ubyte[16] val = void;
	}
	alias SQL_NUMERIC_STRUCT = struct tagSQL_NUMERIC_STRUCT;
	align struct tagSQLGUID
	{
		uint Data1 = void;
		ushort Data2 = void;
		ushort Data3 = void;
		ubyte[8] Data4 = void;
	}
	alias SQLGUID = struct tagSQLGUID;
	alias BOOKMARK = ulong;
	alias SQLWCHAR = ushort;
	alias SQLTCHAR = ubyte;
	enum int __IMPORTC__ = 1;
	enum int _M_X64 = 100;
	enum int _MSC_EXTENSIONS = 1;
	enum int WINAPI_FAMILY_GAMES = 6;
	enum int ODBCVER = 896;
	enum int _MSC_BUILD = 0;
	enum int _WIN64 = 1;
	enum int _IS_ASSIGNABLE_NOCHECK_SUPPORTED = 1;
	enum int _CRT_SECURE_NO_WARNINGS = 1;
	enum int __STDC_NO_VLA__ = 1;
	enum int _CRT_NONSTDC_NO_DEPRECATE = 1;
	enum int _M_AMD64 = 100;
	enum int WINAPI_FAMILY_PHONE_APP = 3;
	enum int _NO_CRT_STDIO_INLINE = 1;
	enum int _MT = 1;
	enum int _MSVC_WARNING_LEVEL = 1;
	enum int __STDC_HOSTED__ = 1;
	enum int WINAPI_FAMILY_SERVER = 5;
	enum int WINAPI_FAMILY_SYSTEM = 4;
	enum int WINAPI_FAMILY_PC_APP = 2;
	enum int _MSC_FULL_VER = 193732822;
	enum int _MSC_VER = 1937;
	enum int _MSVC_TRADITIONAL = 0;
	enum int WINAPI_FAMILY_DESKTOP_APP = 100;
	enum int _MSVC_EXECUTION_CHARACTER_SET = 1252;
	enum int _INTEGRAL_MAX_BITS = 64;
	enum int SQL_MAX_NUMERIC_LEN = 16;
	enum int _WIN32 = 1;
}
