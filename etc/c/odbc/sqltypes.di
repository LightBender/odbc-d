/**
 * ODBC type definitions.
 *
 * Cross-platform D translation of the ODBC 4.0 `sqltypes.h` header.
 *
 * The platform is selected purely through D's predefined version identifiers:
 *
 *  $(UL
 *    $(LI `version(Windows)` &mdash; the Windows ODBC Driver Manager (`odbc32`).
 *         `SQLWCHAR` is a 2-byte UTF-16 code unit.)
 *    $(LI `version(OSX)` &mdash; the iODBC Driver Manager. `SQLWCHAR` is a
 *         4-byte UTF-32 code unit (`wchar_t`).)
 *    $(LI otherwise &mdash; the unixODBC Driver Manager. `SQLWCHAR` is a
 *         2-byte UTF-16 code unit.)
 *  )
 *
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 */
module etc.c.odbc.sqltypes;

extern (C):
@nogc:
nothrow:

/* API declaration data types */
alias SQLCHAR = ubyte;
alias SQLSCHAR = byte;
alias SQLDATE = ubyte;
alias SQLDECIMAL = ubyte;
alias SQLDOUBLE = double;
alias SQLFLOAT = double;
alias SQLINTEGER = int;
alias SQLUINTEGER = uint;

/*
 * `SQLLEN` / `SQLULEN` are pointer-sized on every supported platform:
 *  - Win64:        __int64 / unsigned __int64
 *  - Win32:        SQLINTEGER / SQLUINTEGER (C `long` is 32-bit on Windows)
 *  - unixODBC,
 *    iODBC (LP64): C `long` / `unsigned long`
 *  - 32-bit POSIX: C `long` / `unsigned long`
 * In all of these cases the width matches the machine pointer width, so
 * `ptrdiff_t` / `size_t` reproduce the correct ABI.
 */
alias SQLLEN = ptrdiff_t;
alias SQLULEN = size_t;

version (Windows)
{
    static if (size_t.sizeof == 8)
        alias SQLSETPOSIROW = ulong;
    else
        alias SQLSETPOSIROW = SQLUSMALLINT;
}
else
{
    alias SQLSETPOSIROW = SQLULEN;
}

alias SQLNUMERIC = ubyte;
alias SQLPOINTER = void*;
alias SQLREAL = float;
alias SQLSMALLINT = short;
alias SQLUSMALLINT = ushort;
alias SQLTIME = ubyte;
alias SQLTIMESTAMP = ubyte;
alias SQLVARCHAR = ubyte;
alias SQLTIMEWITHTIMEZONE = ubyte;
alias SQLTIMESTAMPWITHTIMEZONE = ubyte;

/* function return type */
alias SQLRETURN = SQLSMALLINT;

/*
 * Generic handle types. Every supported Driver Manager (Windows `odbc32`,
 * unixODBC and iODBC) declares these as opaque pointers, so a `void*` matches
 * the ABI on all platforms.
 */
alias SQLHANDLE = void*;
alias SQLHENV = SQLHANDLE;
alias SQLHDBC = SQLHANDLE;
alias SQLHSTMT = SQLHANDLE;
alias SQLHDESC = SQLHANDLE;

/* SQL portable types for C */
alias UCHAR = ubyte;
alias SCHAR = byte;
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

/*
 * Window-handle type. Only meaningful on Windows (an `HWND`); on every other
 * platform it degrades to an opaque pointer.
 */
alias SQLHWND = SQLPOINTER;

/* transfer types for DATE, TIME, TIMESTAMP */
struct tagDATE_STRUCT
{
    SQLSMALLINT year;
    SQLUSMALLINT month;
    SQLUSMALLINT day;
}

alias DATE_STRUCT = tagDATE_STRUCT;
alias SQL_DATE_STRUCT = tagDATE_STRUCT;

struct tagTIME_STRUCT
{
    SQLUSMALLINT hour;
    SQLUSMALLINT minute;
    SQLUSMALLINT second;
}

alias TIME_STRUCT = tagTIME_STRUCT;
alias SQL_TIME_STRUCT = tagTIME_STRUCT;

struct tagTIMESTAMP_STRUCT
{
    SQLSMALLINT year;
    SQLUSMALLINT month;
    SQLUSMALLINT day;
    SQLUSMALLINT hour;
    SQLUSMALLINT minute;
    SQLUSMALLINT second;
    SQLUINTEGER fraction;
}

alias TIMESTAMP_STRUCT = tagTIMESTAMP_STRUCT;
alias SQL_TIMESTAMP_STRUCT = tagTIMESTAMP_STRUCT;

struct tagTIME_WITH_TIMEZONE_STRUCT
{
    SQLUSMALLINT hour;
    SQLUSMALLINT minute;
    SQLUSMALLINT second;
    SQLSMALLINT timezone_hours;
    SQLUSMALLINT timezone_minutes;
}

alias TIME_WITH_TIMEZONE_STRUCT = tagTIME_WITH_TIMEZONE_STRUCT;
alias SQL_TIME_WITH_TIMEZONE_STRUCT = tagTIME_WITH_TIMEZONE_STRUCT;

struct tagTIMESTAMP_WITH_TIMEZONE_STRUCT
{
    SQLSMALLINT year;
    SQLUSMALLINT month;
    SQLUSMALLINT day;
    SQLUSMALLINT hour;
    SQLUSMALLINT minute;
    SQLUSMALLINT second;
    SQLUINTEGER fraction;
    SQLSMALLINT timezone_hours;
    SQLUSMALLINT timezone_minutes;
}

alias TIMESTAMP_WITH_TIMEZONE_STRUCT = tagTIMESTAMP_WITH_TIMEZONE_STRUCT;
alias SQL_TIMESTAMP_WITH_TIMEZONE_STRUCT = tagTIMESTAMP_WITH_TIMEZONE_STRUCT;

/*
 * Enumerations for DATETIME_INTERVAL_SUBCODE values for interval data types;
 * these values are from SQL-92.
 */
enum SQLINTERVAL
{
    SQL_IS_YEAR = 1,
    SQL_IS_MONTH = 2,
    SQL_IS_DAY = 3,
    SQL_IS_HOUR = 4,
    SQL_IS_MINUTE = 5,
    SQL_IS_SECOND = 6,
    SQL_IS_YEAR_TO_MONTH = 7,
    SQL_IS_DAY_TO_HOUR = 8,
    SQL_IS_DAY_TO_MINUTE = 9,
    SQL_IS_DAY_TO_SECOND = 10,
    SQL_IS_HOUR_TO_MINUTE = 11,
    SQL_IS_HOUR_TO_SECOND = 12,
    SQL_IS_MINUTE_TO_SECOND = 13
}

alias SQL_IS_YEAR = SQLINTERVAL.SQL_IS_YEAR;
alias SQL_IS_MONTH = SQLINTERVAL.SQL_IS_MONTH;
alias SQL_IS_DAY = SQLINTERVAL.SQL_IS_DAY;
alias SQL_IS_HOUR = SQLINTERVAL.SQL_IS_HOUR;
alias SQL_IS_MINUTE = SQLINTERVAL.SQL_IS_MINUTE;
alias SQL_IS_SECOND = SQLINTERVAL.SQL_IS_SECOND;
alias SQL_IS_YEAR_TO_MONTH = SQLINTERVAL.SQL_IS_YEAR_TO_MONTH;
alias SQL_IS_DAY_TO_HOUR = SQLINTERVAL.SQL_IS_DAY_TO_HOUR;
alias SQL_IS_DAY_TO_MINUTE = SQLINTERVAL.SQL_IS_DAY_TO_MINUTE;
alias SQL_IS_DAY_TO_SECOND = SQLINTERVAL.SQL_IS_DAY_TO_SECOND;
alias SQL_IS_HOUR_TO_MINUTE = SQLINTERVAL.SQL_IS_HOUR_TO_MINUTE;
alias SQL_IS_HOUR_TO_SECOND = SQLINTERVAL.SQL_IS_HOUR_TO_SECOND;
alias SQL_IS_MINUTE_TO_SECOND = SQLINTERVAL.SQL_IS_MINUTE_TO_SECOND;

struct tagSQL_YEAR_MONTH
{
    SQLUINTEGER year;
    SQLUINTEGER month;
}

alias SQL_YEAR_MONTH_STRUCT = tagSQL_YEAR_MONTH;

struct tagSQL_DAY_SECOND
{
    SQLUINTEGER day;
    SQLUINTEGER hour;
    SQLUINTEGER minute;
    SQLUINTEGER second;
    SQLUINTEGER fraction;
}

alias SQL_DAY_SECOND_STRUCT = tagSQL_DAY_SECOND;

struct tagSQL_INTERVAL_STRUCT
{
    SQLINTERVAL interval_type;
    SQLSMALLINT interval_sign;
    union intval
    {
        SQL_YEAR_MONTH_STRUCT year_month;
        SQL_DAY_SECOND_STRUCT day_second;
    }
}

alias SQL_INTERVAL_STRUCT = tagSQL_INTERVAL_STRUCT;

/* the ODBC C types for SQL_C_SBIGINT and SQL_C_UBIGINT */
alias SQLBIGINT = long;
alias SQLUBIGINT = ulong;

/* internal representation of numeric data type */
enum SQL_MAX_NUMERIC_LEN = 16;

struct tagSQL_NUMERIC_STRUCT
{
    SQLCHAR precision;
    SQLSCHAR scale;
    SQLCHAR sign; /* 1 if positive, 0 if negative */
    SQLCHAR[SQL_MAX_NUMERIC_LEN] val;
}

alias SQL_NUMERIC_STRUCT = tagSQL_NUMERIC_STRUCT;

/* globally unique identifier (size is 16) */
struct tagSQLGUID
{
    uint Data1;
    ushort Data2;
    ushort Data3;
    ubyte[8] Data4;
}

alias SQLGUID = tagSQLGUID;

alias BOOKMARK = SQLULEN;

/*
 * Wide-character code unit. UTF-16 on Windows / unixODBC, UTF-32 on iODBC
 * (macOS).
 */
version (Windows)
    alias SQLWCHAR = wchar;
else version (OSX)
    alias SQLWCHAR = dchar;
else
    alias SQLWCHAR = wchar;

/*
 * Generic text character. These bindings call the explicit ANSI / wide
 * entry points, so `SQLTCHAR` is fixed to the narrow form here.
 */
alias SQLTCHAR = SQLCHAR;
