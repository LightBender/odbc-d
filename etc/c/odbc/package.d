/**
 * ODBC Header Module
 *
 * Cross-platform D translation of the $(LINK2 https://github.com/microsoft/ODBC-Specification,
 * ODBC 4.0 Specification) headers. This package publicly re-exports the full
 * ODBC 4.0 C API surface and adds D translations of the function-like C macros
 * from the original headers (in D, C macros are expressed as functions).
 *
 * The platform is selected purely from D's predefined version identifiers:
 *
 * $(UL
 *   $(LI `version (Windows)` links `odbc32` and uses the `__stdcall` ABI;
 *        `SQLWCHAR` is a 2-byte `wchar`.)
 *   $(LI `version (OSX)` links `iodbc`; `SQLWCHAR` is a 4-byte `dchar`.)
 *   $(LI other Posix platforms link `odbc` (unixODBC); `SQLWCHAR` is a
 *        2-byte `wchar`.)
 * )
 *
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 * Source: $(PHOBOSSRC etc/c/odbc/_package.d)
 *
 * See_Also: $(LINK2 https://docs.microsoft.com/en-us/sql/odbc/reference/syntax/odbc-api-reference,
 *           ODBC API Reference on MSDN)
 */

module etc.c.odbc;

public import etc.c.odbc.sqltypes;
public import etc.c.odbc.sql;
public import etc.c.odbc.sqlext;
public import etc.c.odbc.sqlucode;

// Manually converted enums
public enum int SQL_CA2_MAX_ROWS_AFFECTS_ALL = SQL_CA2_MAX_ROWS_SELECT | SQL_CA2_MAX_ROWS_INSERT |
                SQL_CA2_MAX_ROWS_DELETE | SQL_CA2_MAX_ROWS_UPDATE | SQL_CA2_MAX_ROWS_CATALOG;

public enum string SQL_ODBC_KEYWORDS = "ABSOLUTE,ACTION,ADA,ADD,ALL,ALLOCATE,ALTER,AND,ANY,ARE,AS,
ASC,ASSERTION,AT,AUTHORIZATION,AVG,
BEGIN,BETWEEN,BIT,BIT_LENGTH,BOTH,BY,CASCADE,CASCADED,CASE,CAST,CATALOG,
CHAR,CHAR_LENGTH,CHARACTER,CHARACTER_LENGTH,CHECK,CLOSE,COALESCE,
COLLATE,COLLATION,COLUMN,COMMIT,CONNECT,CONNECTION,CONSTRAINT,
CONSTRAINTS,CONTINUE,CONVERT,CORRESPONDING,COUNT,CREATE,CROSS,CURRENT,
CURRENT_DATE,CURRENT_TIME,CURRENT_TIMESTAMP,CURRENT_USER,CURSOR,
DATE,DAY,DEALLOCATE,DEC,DECIMAL,DECLARE,DEFAULT,DEFERRABLE,
DEFERRED,DELETE,DESC,DESCRIBE,DESCRIPTOR,DIAGNOSTICS,DISCONNECT,
DISTINCT,DOMAIN,DOUBLE,DROP,
ELSE,END,END-EXEC,ESCAPE,EXCEPT,EXCEPTION,EXEC,EXECUTE,
EXISTS,EXTERNAL,EXTRACT,
FALSE,FETCH,FIRST,FLOAT,FOR,FOREIGN,FORTRAN,FOUND,FROM,FULL,
GET,GLOBAL,GO,GOTO,GRANT,GROUP,HAVING,HOUR,
IDENTITY,IMMEDIATE,IN,INCLUDE,INDEX,INDICATOR,INITIALLY,INNER,
INPUT,INSENSITIVE,INSERT,INT,INTEGER,INTERSECT,INTERVAL,INTO,IS,ISOLATION,
JOIN,KEY,LANGUAGE,LAST,LEADING,LEFT,LEVEL,LIKE,LOCAL,LOWER,
MATCH,MAX,MIN,MINUTE,MODULE,MONTH,
NAMES,NATIONAL,NATURAL,NCHAR,NEXT,NO,NONE,NOT,NULL,NULLIF,NUMERIC,
OCTET_LENGTH,OF,ON,ONLY,OPEN,OPTION,OR,ORDER,OUTER,OUTPUT,OVERLAPS,
PAD,PARTIAL,PASCAL,PLI,POSITION,PRECISION,PREPARE,PRESERVE,
PRIMARY,PRIOR,PRIVILEGES,PROCEDURE,PUBLIC,
READ,REAL,REFERENCES,RELATIVE,RESTRICT,REVOKE,RIGHT,ROLLBACK,ROWS,
SCHEMA,SCROLL,SECOND,SECTION,SELECT,SESSION,SESSION_USER,SET,SIZE,
SMALLINT,SOME,SPACE,SQL,SQLCA,SQLCODE,SQLERROR,SQLSTATE,SQLWARNING,
SUBSTRING,SUM,SYSTEM_USER,
TABLE,TEMPORARY,THEN,TIME,TIMESTAMP,TIMEZONE_HOUR,TIMEZONE_MINUTE,
TO,TRAILING,TRANSACTION,TRANSLATE,TRANSLATION,TRIM,TRUE,
UNION,UNIQUE,UNKNOWN,UPDATE,UPPER,USAGE,USER,USING,
VALUE,VALUES,VARCHAR,VARYING,VIEW,WHEN,WHENEVER,WHERE,WITH,WORK,WRITE,
YEAR,ZONE";

/*
 * The original ODBC headers expose a number of function-like preprocessor
 * macros. D has no preprocessor, so they are translated to ordinary functions
 * here. They are kept `@nogc nothrow` to match the bindings; the pure helpers
 * are additionally `pure @safe`.
 */

/// Returns `true` if `rc` is `SQL_SUCCESS` or `SQL_SUCCESS_WITH_INFO`.
pragma(inline, true)
bool SQL_SUCCEEDED(SQLRETURN rc) @nogc nothrow pure @safe
{
    return (rc & ~1) == 0;
}

/// Encodes a data-at-execution length for `SQLBindParameter`'s indicator value.
pragma(inline, true)
SQLLEN SQL_LEN_DATA_AT_EXEC(SQLLEN length) @nogc nothrow pure @safe
{
    return -length + SQL_LEN_DATA_AT_EXEC_OFFSET;
}

/// Encodes a binary length for a driver-specific descriptor attribute.
pragma(inline, true)
SQLLEN SQL_LEN_BINARY_ATTR(SQLLEN length) @nogc nothrow pure @safe
{
    return -length + SQL_LEN_BINARY_ATTR_OFFSET;
}

/// Tests the bit for `uwAPI` in a `SQLGetFunctions` existence bitmap.
pragma(inline, true)
SQLUSMALLINT SQL_FUNC_EXISTS(scope const(SQLUSMALLINT)* pfExists, SQLUSMALLINT uwAPI) @nogc nothrow pure
{
    return (pfExists[uwAPI >> 4] & (1 << (uwAPI & 0x000F))) ? SQL_TRUE : SQL_FALSE;
}

/// Convenience wrapper for `SQLSetPos` positioning the cursor at `irow`.
pragma(inline, true)
SQLRETURN SQL_POSITION_TO(SQLHSTMT hstmt, SQLSETPOSIROW irow) @nogc nothrow
{
    return SQLSetPos(hstmt, irow, SQL_POSITION, SQL_LOCK_NO_CHANGE);
}

/// Convenience wrapper for `SQLSetPos` locking record `irow`.
pragma(inline, true)
SQLRETURN SQL_LOCK_RECORD(SQLHSTMT hstmt, SQLSETPOSIROW irow, SQLUSMALLINT fLock) @nogc nothrow
{
    return SQLSetPos(hstmt, irow, SQL_POSITION, fLock);
}

/// Convenience wrapper for `SQLSetPos` refreshing record `irow`.
pragma(inline, true)
SQLRETURN SQL_REFRESH_RECORD(SQLHSTMT hstmt, SQLSETPOSIROW irow, SQLUSMALLINT fLock) @nogc nothrow
{
    return SQLSetPos(hstmt, irow, SQL_REFRESH, fLock);
}

/// Convenience wrapper for `SQLSetPos` updating record `irow`.
pragma(inline, true)
SQLRETURN SQL_UPDATE_RECORD(SQLHSTMT hstmt, SQLSETPOSIROW irow) @nogc nothrow
{
    return SQLSetPos(hstmt, irow, SQL_UPDATE, SQL_LOCK_NO_CHANGE);
}

/// Convenience wrapper for `SQLSetPos` deleting record `irow`.
pragma(inline, true)
SQLRETURN SQL_DELETE_RECORD(SQLHSTMT hstmt, SQLSETPOSIROW irow) @nogc nothrow
{
    return SQLSetPos(hstmt, irow, SQL_DELETE, SQL_LOCK_NO_CHANGE);
}

/// Convenience wrapper for `SQLSetPos` adding a record at `irow`.
pragma(inline, true)
SQLRETURN SQL_ADD_RECORD(SQLHSTMT hstmt, SQLSETPOSIROW irow) @nogc nothrow
{
    return SQLSetPos(hstmt, irow, SQL_ADD, SQL_LOCK_NO_CHANGE);
}
