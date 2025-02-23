/**
 * ODBC Header Module
 *
 * ImportC translation from the $(LINK2 https://github.com/microsoft/ODBC-Specification,
                                  ODBC 4.0 Specification) Headers.
 *
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 * Source: $(PHOBOSSRC etc/c/odbc/_package.d)

Declarations for interfacing with the ODBC library.

The prior version of the ODBC bindings has been deprecated and will be removed in a future release.

See_Also: $(LINK2 https://docs.microsoft.com/en-us/sql/odbc/reference/syntax/odbc-api-reference,
            ODBC API Reference on MSDN)
 */

module etc.c.odbc;

//64-bit architectures
version(X86_64) {
    public import etc.c.odbc.odbc64;
}
version(AArch64) {
    public import etc.c.odbc.odbc64;
}
version(PPC64) {
    public import etc.c.odbc.odbc64;
}
version(MIPS64) {
    public import etc.c.odbc.odbc64;
}
version(RISCV64) {
    public import etc.c.odbc.odbc64;
}
version(SPARC64) {
    public import etc.c.odbc.odbc64;
}
version(HPPA64) {
    public import etc.c.odbc.odbc64;
}

//32-bit architectures
version(X86) {
    public import etc.c.odbc.odbc32;
}
version(ARM) {
    public import etc.c.odbc.odbc32;
}
version(PPC32) {
    public import etc.c.odbc.odbc32;
}
version(MIPS32) {
    public import etc.c.odbc.odbc32;
}
version(RISCV32) {
    public import etc.c.odbc.odbc32;
}
version(SPARC) {
    public import etc.c.odbc.odbc32;
}
version(HPPA) {
    public import etc.c.odbc.odbc32;
}

// Manually converted enums
public enum int ODBCVER = 0x0400;
public enum int SQL_CA2_MAX_ROWS_AFFECTS_ALL = SQL_CA2_MAX_ROWS_SELECT | SQL_CA2_MAX_ROWS_INSERT |
                SQL_CA2_MAX_ROWS_DELETE | SQL_CA2_MAX_ROWS_UPDATE | SQL_CA2_MAX_ROWS_CATALOG;
public enum string SQL_ALL_CATALOGS = "%";
public enum string SQL_ALL_SCHEMAS = "%";
public enum string SQL_ALL_TABLE_TYPES = "%";
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

// Manually converted macros
public long SQL_LEN_DATA_AT_EXEC(long length)
{
    return (-(length)+SQL_LEN_DATA_AT_EXEC_OFFSET);
}

public long SQL_LEN_BINARY_ATTR(long length)
{
    return (-(length)+SQL_LEN_BINARY_ATTR_OFFSET);
}

public SQLRETURN SQL_POSITION_TO(SQLHSTMT hstmt, SQLSETPOSIROW irow) 
{
    return SQLSetPos(hstmt,irow,SQL_POSITION,SQL_LOCK_NO_CHANGE);
}

public SQLRETURN SQL_LOCK_RECORD(SQLHSTMT hstmt, SQLSETPOSIROW irow, SQLUSMALLINT fLock) 
{
    return SQLSetPos(hstmt,irow,SQL_POSITION,fLock);
}

public SQLRETURN SQL_REFRESH_RECORD(SQLHSTMT hstmt, SQLSETPOSIROW irow, SQLUSMALLINT fLock) 
{
    return SQLSetPos(hstmt,irow,SQL_REFRESH,fLock);
}

public SQLRETURN SQL_UPDATE_RECORD(SQLHSTMT hstmt, SQLSETPOSIROW irow) 
{
    return SQLSetPos(hstmt,irow,SQL_UPDATE,SQL_LOCK_NO_CHANGE);
}

public SQLRETURN SQL_DELETE_RECORD(SQLHSTMT hstmt, SQLSETPOSIROW irow) 
{
    return SQLSetPos(hstmt,irow,SQL_DELETE,SQL_LOCK_NO_CHANGE);
}

public SQLRETURN SQL_ADD_RECORD(SQLHSTMT hstmt, SQLSETPOSIROW irow) 
{
    return SQLSetPos(hstmt,irow,SQL_ADD,SQL_LOCK_NO_CHANGE);
}
