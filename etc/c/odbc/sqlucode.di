/**
 * ODBC Unicode (wide) and ANSI (narrow) Core API definitions.
 *
 * Cross-platform D translation of the ODBC 4.0 `sqlucode.h` header. It declares
 * the `W` (wide / `SQLWCHAR`) and `A` (ANSI / `SQLCHAR`) variants of the Core
 * API entry points. The width of `SQLWCHAR` is determined per platform by
 * $(D etc.c.odbc.sqltypes).
 *
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 */
module etc.c.odbc.sqlucode;

public import etc.c.odbc.sqlext;

enum SQL_WCHAR = -8;
enum SQL_WVARCHAR = -9;
enum SQL_WLONGVARCHAR = -10;
enum SQL_C_WCHAR = SQL_WCHAR;

/* Unicode SQL data type aliases (from the ODBC 3.0 extension section) */
enum SQL_UNICODE = SQL_WCHAR;
enum SQL_UNICODE_VARCHAR = SQL_WVARCHAR;
enum SQL_UNICODE_LONGVARCHAR = SQL_WLONGVARCHAR;
enum SQL_UNICODE_CHAR = SQL_WCHAR;

/*
 * `SQL_C_TCHAR` follows the application's character width. These bindings use
 * the wide API by default, so on Windows it maps to the wide C type; on the
 * narrow-by-default Posix driver managers it maps to the ANSI C type.
 */
version (Windows)
    enum SQL_C_TCHAR = SQL_C_WCHAR;
else
    enum SQL_C_TCHAR = SQL_C_CHAR;

enum SQL_SQLSTATE_SIZEW = 10; /* size of SQLSTATE for unicode */

/*
 * Both the wide and ANSI Core entry points share the platform calling
 * convention: `__stdcall` on Windows, the C convention everywhere else.
 */
extern (System):

@nogc:
nothrow:

/* ------------------------------------------------------------------ */
/* UNICODE (wide) versions                                            */
/* ------------------------------------------------------------------ */

version (Win64)
    SQLRETURN SQLColAttributeW(SQLHSTMT hstmt, SQLUSMALLINT iCol, SQLUSMALLINT iField,
            SQLPOINTER pCharAttr, SQLSMALLINT cbDescMax, SQLSMALLINT* pcbCharAttr,
            SQLLEN* pNumAttr);
else
    SQLRETURN SQLColAttributeW(SQLHSTMT hstmt, SQLUSMALLINT iCol, SQLUSMALLINT iField,
            SQLPOINTER pCharAttr, SQLSMALLINT cbDescMax, SQLSMALLINT* pcbCharAttr,
            SQLPOINTER pNumAttr);

SQLRETURN SQLColAttributesW(SQLHSTMT hstmt, SQLUSMALLINT icol, SQLUSMALLINT fDescType,
        SQLPOINTER rgbDesc, SQLSMALLINT cbDescMax, SQLSMALLINT* pcbDesc, SQLLEN* pfDesc);

SQLRETURN SQLConnectW(SQLHDBC hdbc, SQLWCHAR* szDSN, SQLSMALLINT cchDSN,
        SQLWCHAR* szUID, SQLSMALLINT cchUID, SQLWCHAR* szAuthStr, SQLSMALLINT cchAuthStr);

SQLRETURN SQLDescribeColW(SQLHSTMT hstmt, SQLUSMALLINT icol, SQLWCHAR* szColName,
        SQLSMALLINT cchColNameMax, SQLSMALLINT* pcchColName, SQLSMALLINT* pfSqlType,
        SQLULEN* pcbColDef, SQLSMALLINT* pibScale, SQLSMALLINT* pfNullable);

SQLRETURN SQLErrorW(SQLHENV henv, SQLHDBC hdbc, SQLHSTMT hstmt, SQLWCHAR* wszSqlState,
        SQLINTEGER* pfNativeError, SQLWCHAR* wszErrorMsg, SQLSMALLINT cchErrorMsgMax,
        SQLSMALLINT* pcchErrorMsg);

SQLRETURN SQLExecDirectW(SQLHSTMT hstmt, SQLWCHAR* szSqlStr, SQLINTEGER TextLength);

SQLRETURN SQLGetConnectAttrW(SQLHDBC hdbc, SQLINTEGER fAttribute, SQLPOINTER rgbValue,
        SQLINTEGER cbValueMax, SQLINTEGER* pcbValue);

SQLRETURN SQLGetCursorNameW(SQLHSTMT hstmt, SQLWCHAR* szCursor, SQLSMALLINT cchCursorMax,
        SQLSMALLINT* pcchCursor);

SQLRETURN SQLSetDescFieldW(SQLHDESC DescriptorHandle, SQLSMALLINT RecNumber,
        SQLSMALLINT FieldIdentifier, SQLPOINTER Value, SQLINTEGER BufferLength);

SQLRETURN SQLGetDescFieldW(SQLHDESC hdesc, SQLSMALLINT iRecord, SQLSMALLINT iField,
        SQLPOINTER rgbValue, SQLINTEGER cbBufferLength, SQLINTEGER* StringLength);

SQLRETURN SQLGetDescRecW(SQLHDESC hdesc, SQLSMALLINT iRecord, SQLWCHAR* szName,
        SQLSMALLINT cchNameMax, SQLSMALLINT* pcchName, SQLSMALLINT* pfType,
        SQLSMALLINT* pfSubType, SQLLEN* pLength, SQLSMALLINT* pPrecision,
        SQLSMALLINT* pScale, SQLSMALLINT* pNullable);

SQLRETURN SQLGetDiagFieldW(SQLSMALLINT fHandleType, SQLHANDLE handle, SQLSMALLINT iRecord,
        SQLSMALLINT fDiagField, SQLPOINTER rgbDiagInfo, SQLSMALLINT cbBufferLength,
        SQLSMALLINT* pcbStringLength);

SQLRETURN SQLGetDiagRecW(SQLSMALLINT fHandleType, SQLHANDLE handle, SQLSMALLINT iRecord,
        SQLWCHAR* szSqlState, SQLINTEGER* pfNativeError, SQLWCHAR* szErrorMsg,
        SQLSMALLINT cchErrorMsgMax, SQLSMALLINT* pcchErrorMsg);

SQLRETURN SQLPrepareW(SQLHSTMT hstmt, SQLWCHAR* szSqlStr, SQLINTEGER cchSqlStr);

SQLRETURN SQLSetConnectAttrW(SQLHDBC hdbc, SQLINTEGER fAttribute, SQLPOINTER rgbValue,
        SQLINTEGER cbValue);

SQLRETURN SQLSetCursorNameW(SQLHSTMT hstmt, SQLWCHAR* szCursor, SQLSMALLINT cchCursor);

SQLRETURN SQLColumnsW(SQLHSTMT hstmt, SQLWCHAR* szCatalogName, SQLSMALLINT cchCatalogName,
        SQLWCHAR* szSchemaName, SQLSMALLINT cchSchemaName, SQLWCHAR* szTableName,
        SQLSMALLINT cchTableName, SQLWCHAR* szColumnName, SQLSMALLINT cchColumnName);

SQLRETURN SQLGetConnectOptionW(SQLHDBC hdbc, SQLUSMALLINT fOption, SQLPOINTER pvParam);

SQLRETURN SQLGetInfoW(SQLHDBC hdbc, SQLUSMALLINT fInfoType, SQLPOINTER rgbInfoValue,
        SQLSMALLINT cbInfoValueMax, SQLSMALLINT* pcbInfoValue);

SQLRETURN SQLGetTypeInfoW(SQLHSTMT StatementHandle, SQLSMALLINT DataType);

SQLRETURN SQLSetConnectOptionW(SQLHDBC hdbc, SQLUSMALLINT fOption, SQLULEN vParam);

SQLRETURN SQLSpecialColumnsW(SQLHSTMT hstmt, SQLUSMALLINT fColType, SQLWCHAR* szCatalogName,
        SQLSMALLINT cchCatalogName, SQLWCHAR* szSchemaName, SQLSMALLINT cchSchemaName,
        SQLWCHAR* szTableName, SQLSMALLINT cchTableName, SQLUSMALLINT fScope,
        SQLUSMALLINT fNullable);

SQLRETURN SQLStatisticsW(SQLHSTMT hstmt, SQLWCHAR* szCatalogName, SQLSMALLINT cchCatalogName,
        SQLWCHAR* szSchemaName, SQLSMALLINT cchSchemaName, SQLWCHAR* szTableName,
        SQLSMALLINT cchTableName, SQLUSMALLINT fUnique, SQLUSMALLINT fAccuracy);

SQLRETURN SQLTablesW(SQLHSTMT hstmt, SQLWCHAR* szCatalogName, SQLSMALLINT cchCatalogName,
        SQLWCHAR* szSchemaName, SQLSMALLINT cchSchemaName, SQLWCHAR* szTableName,
        SQLSMALLINT cchTableName, SQLWCHAR* szTableType, SQLSMALLINT cchTableType);

SQLRETURN SQLDataSourcesW(SQLHENV henv, SQLUSMALLINT fDirection, SQLWCHAR* szDSN,
        SQLSMALLINT cchDSNMax, SQLSMALLINT* pcchDSN, SQLWCHAR* wszDescription,
        SQLSMALLINT cchDescriptionMax, SQLSMALLINT* pcchDescription);

SQLRETURN SQLDriverConnectW(SQLHDBC hdbc, SQLHWND hwnd, SQLWCHAR* szConnStrIn,
        SQLSMALLINT cchConnStrIn, SQLWCHAR* szConnStrOut, SQLSMALLINT cchConnStrOutMax,
        SQLSMALLINT* pcchConnStrOut, SQLUSMALLINT fDriverCompletion);

SQLRETURN SQLBrowseConnectW(SQLHDBC hdbc, SQLWCHAR* szConnStrIn, SQLSMALLINT cchConnStrIn,
        SQLWCHAR* szConnStrOut, SQLSMALLINT cchConnStrOutMax, SQLSMALLINT* pcchConnStrOut);

SQLRETURN SQLColumnPrivilegesW(SQLHSTMT hstmt, SQLWCHAR* szCatalogName,
        SQLSMALLINT cchCatalogName, SQLWCHAR* szSchemaName, SQLSMALLINT cchSchemaName,
        SQLWCHAR* szTableName, SQLSMALLINT cchTableName, SQLWCHAR* szColumnName,
        SQLSMALLINT cchColumnName);

SQLRETURN SQLGetStmtAttrW(SQLHSTMT hstmt, SQLINTEGER fAttribute, SQLPOINTER rgbValue,
        SQLINTEGER cbValueMax, SQLINTEGER* pcbValue);

SQLRETURN SQLSetStmtAttrW(SQLHSTMT hstmt, SQLINTEGER fAttribute, SQLPOINTER rgbValue,
        SQLINTEGER cbValueMax);

SQLRETURN SQLForeignKeysW(SQLHSTMT hstmt, SQLWCHAR* szPkCatalogName,
        SQLSMALLINT cchPkCatalogName, SQLWCHAR* szPkSchemaName, SQLSMALLINT cchPkSchemaName,
        SQLWCHAR* szPkTableName, SQLSMALLINT cchPkTableName, SQLWCHAR* szFkCatalogName,
        SQLSMALLINT cchFkCatalogName, SQLWCHAR* szFkSchemaName, SQLSMALLINT cchFkSchemaName,
        SQLWCHAR* szFkTableName, SQLSMALLINT cchFkTableName);

SQLRETURN SQLNativeSqlW(SQLHDBC hdbc, SQLWCHAR* szSqlStrIn, SQLINTEGER cchSqlStrIn,
        SQLWCHAR* szSqlStr, SQLINTEGER cchSqlStrMax, SQLINTEGER* pcchSqlStr);

SQLRETURN SQLPrimaryKeysW(SQLHSTMT hstmt, SQLWCHAR* szCatalogName,
        SQLSMALLINT cchCatalogName, SQLWCHAR* szSchemaName, SQLSMALLINT cchSchemaName,
        SQLWCHAR* szTableName, SQLSMALLINT cchTableName);

SQLRETURN SQLProcedureColumnsW(SQLHSTMT hstmt, SQLWCHAR* szCatalogName,
        SQLSMALLINT cchCatalogName, SQLWCHAR* szSchemaName, SQLSMALLINT cchSchemaName,
        SQLWCHAR* szProcName, SQLSMALLINT cchProcName, SQLWCHAR* szColumnName,
        SQLSMALLINT cchColumnName);

SQLRETURN SQLProceduresW(SQLHSTMT hstmt, SQLWCHAR* szCatalogName, SQLSMALLINT cchCatalogName,
        SQLWCHAR* szSchemaName, SQLSMALLINT cchSchemaName, SQLWCHAR* szProcName,
        SQLSMALLINT cchProcName);

SQLRETURN SQLTablePrivilegesW(SQLHSTMT hstmt, SQLWCHAR* szCatalogName,
        SQLSMALLINT cchCatalogName, SQLWCHAR* szSchemaName, SQLSMALLINT cchSchemaName,
        SQLWCHAR* szTableName, SQLSMALLINT cchTableName);

SQLRETURN SQLDriversW(SQLHENV henv, SQLUSMALLINT fDirection, SQLWCHAR* szDriverDesc,
        SQLSMALLINT cchDriverDescMax, SQLSMALLINT* pcchDriverDesc,
        SQLWCHAR* szDriverAttributes, SQLSMALLINT cchDrvrAttrMax, SQLSMALLINT* pcchDrvrAttr);

// ODBC 4.0 wide entry points (compiled in only when `ODBC4` is defined).
version (ODBC4)
{
    SQLRETURN SQLStructuredTypesW(SQLHSTMT hstmt, SQLWCHAR* szCatalogName,
            SQLSMALLINT cchCatalogName, SQLWCHAR* szSchemaName, SQLSMALLINT cchSchemaName,
            SQLWCHAR* szTypeName, SQLSMALLINT cchTypeName);

    SQLRETURN SQLStructuredTypeColumnsW(SQLHSTMT hstmt, SQLWCHAR* szCatalogName,
            SQLSMALLINT cchCatalogName, SQLWCHAR* szSchemaName, SQLSMALLINT cchSchemaName,
            SQLWCHAR* szTypeName, SQLSMALLINT cchTypeName, SQLWCHAR* szColumnName,
            SQLSMALLINT cchColumnName);
}

/* ------------------------------------------------------------------ */
/* ANSI (narrow) versions                                             */
/* ------------------------------------------------------------------ */

version (Win64)
    SQLRETURN SQLColAttributeA(SQLHSTMT hstmt, SQLSMALLINT iCol, SQLSMALLINT iField,
            SQLPOINTER pCharAttr, SQLSMALLINT cbCharAttrMax, SQLSMALLINT* pcbCharAttr,
            SQLLEN* pNumAttr);
else
    SQLRETURN SQLColAttributeA(SQLHSTMT hstmt, SQLSMALLINT iCol, SQLSMALLINT iField,
            SQLPOINTER pCharAttr, SQLSMALLINT cbCharAttrMax, SQLSMALLINT* pcbCharAttr,
            SQLPOINTER pNumAttr);

SQLRETURN SQLColAttributesA(SQLHSTMT hstmt, SQLUSMALLINT icol, SQLUSMALLINT fDescType,
        SQLPOINTER rgbDesc, SQLSMALLINT cbDescMax, SQLSMALLINT* pcbDesc, SQLLEN* pfDesc);

SQLRETURN SQLConnectA(SQLHDBC hdbc, SQLCHAR* szDSN, SQLSMALLINT cbDSN, SQLCHAR* szUID,
        SQLSMALLINT cbUID, SQLCHAR* szAuthStr, SQLSMALLINT cbAuthStr);

SQLRETURN SQLDescribeColA(SQLHSTMT hstmt, SQLUSMALLINT icol, SQLCHAR* szColName,
        SQLSMALLINT cbColNameMax, SQLSMALLINT* pcbColName, SQLSMALLINT* pfSqlType,
        SQLULEN* pcbColDef, SQLSMALLINT* pibScale, SQLSMALLINT* pfNullable);

SQLRETURN SQLErrorA(SQLHENV henv, SQLHDBC hdbc, SQLHSTMT hstmt, SQLCHAR* szSqlState,
        SQLINTEGER* pfNativeError, SQLCHAR* szErrorMsg, SQLSMALLINT cbErrorMsgMax,
        SQLSMALLINT* pcbErrorMsg);

SQLRETURN SQLExecDirectA(SQLHSTMT hstmt, SQLCHAR* szSqlStr, SQLINTEGER cbSqlStr);

SQLRETURN SQLGetConnectAttrA(SQLHDBC hdbc, SQLINTEGER fAttribute, SQLPOINTER rgbValue,
        SQLINTEGER cbValueMax, SQLINTEGER* pcbValue);

SQLRETURN SQLGetCursorNameA(SQLHSTMT hstmt, SQLCHAR* szCursor, SQLSMALLINT cbCursorMax,
        SQLSMALLINT* pcbCursor);

SQLRETURN SQLGetDescFieldA(SQLHDESC hdesc, SQLSMALLINT iRecord, SQLSMALLINT iField,
        SQLPOINTER rgbValue, SQLINTEGER cbBufferLength, SQLINTEGER* StringLength);

SQLRETURN SQLGetDescRecA(SQLHDESC hdesc, SQLSMALLINT iRecord, SQLCHAR* szName,
        SQLSMALLINT cbNameMax, SQLSMALLINT* pcbName, SQLSMALLINT* pfType,
        SQLSMALLINT* pfSubType, SQLLEN* pLength, SQLSMALLINT* pPrecision,
        SQLSMALLINT* pScale, SQLSMALLINT* pNullable);

SQLRETURN SQLGetDiagFieldA(SQLSMALLINT fHandleType, SQLHANDLE handle, SQLSMALLINT iRecord,
        SQLSMALLINT fDiagField, SQLPOINTER rgbDiagInfo, SQLSMALLINT cbDiagInfoMax,
        SQLSMALLINT* pcbDiagInfo);

SQLRETURN SQLGetDiagRecA(SQLSMALLINT fHandleType, SQLHANDLE handle, SQLSMALLINT iRecord,
        SQLCHAR* szSqlState, SQLINTEGER* pfNativeError, SQLCHAR* szErrorMsg,
        SQLSMALLINT cbErrorMsgMax, SQLSMALLINT* pcbErrorMsg);

SQLRETURN SQLGetStmtAttrA(SQLHSTMT hstmt, SQLINTEGER fAttribute, SQLPOINTER rgbValue,
        SQLINTEGER cbValueMax, SQLINTEGER* pcbValue);

SQLRETURN SQLGetTypeInfoA(SQLHSTMT StatementHandle, SQLSMALLINT DataType);

SQLRETURN SQLPrepareA(SQLHSTMT hstmt, SQLCHAR* szSqlStr, SQLINTEGER cbSqlStr);

SQLRETURN SQLSetConnectAttrA(SQLHDBC hdbc, SQLINTEGER fAttribute, SQLPOINTER rgbValue,
        SQLINTEGER cbValue);

SQLRETURN SQLSetCursorNameA(SQLHSTMT hstmt, SQLCHAR* szCursor, SQLSMALLINT cbCursor);

SQLRETURN SQLColumnsA(SQLHSTMT hstmt, SQLCHAR* szCatalogName, SQLSMALLINT cbCatalogName,
        SQLCHAR* szSchemaName, SQLSMALLINT cbSchemaName, SQLCHAR* szTableName,
        SQLSMALLINT cbTableName, SQLCHAR* szColumnName, SQLSMALLINT cbColumnName);

SQLRETURN SQLGetConnectOptionA(SQLHDBC hdbc, SQLUSMALLINT fOption, SQLPOINTER pvParam);

SQLRETURN SQLGetInfoA(SQLHDBC hdbc, SQLUSMALLINT fInfoType, SQLPOINTER rgbInfoValue,
        SQLSMALLINT cbInfoValueMax, SQLSMALLINT* pcbInfoValue);

SQLRETURN SQLGetStmtOptionA(SQLHSTMT hstmt, SQLUSMALLINT fOption, SQLPOINTER pvParam);

SQLRETURN SQLSetConnectOptionA(SQLHDBC hdbc, SQLUSMALLINT fOption, SQLULEN vParam);

SQLRETURN SQLSetStmtOptionA(SQLHSTMT hstmt, SQLUSMALLINT fOption, SQLULEN vParam);

SQLRETURN SQLSpecialColumnsA(SQLHSTMT hstmt, SQLUSMALLINT fColType, SQLCHAR* szCatalogName,
        SQLSMALLINT cbCatalogName, SQLCHAR* szSchemaName, SQLSMALLINT cbSchemaName,
        SQLCHAR* szTableName, SQLSMALLINT cbTableName, SQLUSMALLINT fScope,
        SQLUSMALLINT fNullable);

SQLRETURN SQLStatisticsA(SQLHSTMT hstmt, SQLCHAR* szCatalogName, SQLSMALLINT cbCatalogName,
        SQLCHAR* szSchemaName, SQLSMALLINT cbSchemaName, SQLCHAR* szTableName,
        SQLSMALLINT cbTableName, SQLUSMALLINT fUnique, SQLUSMALLINT fAccuracy);

SQLRETURN SQLTablesA(SQLHSTMT hstmt, SQLCHAR* szCatalogName, SQLSMALLINT cbCatalogName,
        SQLCHAR* szSchemaName, SQLSMALLINT cbSchemaName, SQLCHAR* szTableName,
        SQLSMALLINT cbTableName, SQLCHAR* szTableType, SQLSMALLINT cbTableType);

SQLRETURN SQLDataSourcesA(SQLHENV henv, SQLUSMALLINT fDirection, SQLCHAR* szDSN,
        SQLSMALLINT cbDSNMax, SQLSMALLINT* pcbDSN, SQLCHAR* szDescription,
        SQLSMALLINT cbDescriptionMax, SQLSMALLINT* pcbDescription);

SQLRETURN SQLDriverConnectA(SQLHDBC hdbc, SQLHWND hwnd, SQLCHAR* szConnStrIn,
        SQLSMALLINT cbConnStrIn, SQLCHAR* szConnStrOut, SQLSMALLINT cbConnStrOutMax,
        SQLSMALLINT* pcbConnStrOut, SQLUSMALLINT fDriverCompletion);

SQLRETURN SQLBrowseConnectA(SQLHDBC hdbc, SQLCHAR* szConnStrIn, SQLSMALLINT cbConnStrIn,
        SQLCHAR* szConnStrOut, SQLSMALLINT cbConnStrOutMax, SQLSMALLINT* pcbConnStrOut);

SQLRETURN SQLColumnPrivilegesA(SQLHSTMT hstmt, SQLCHAR* szCatalogName,
        SQLSMALLINT cbCatalogName, SQLCHAR* szSchemaName, SQLSMALLINT cbSchemaName,
        SQLCHAR* szTableName, SQLSMALLINT cbTableName, SQLCHAR* szColumnName,
        SQLSMALLINT cbColumnName);

SQLRETURN SQLDescribeParamA(SQLHSTMT hstmt, SQLUSMALLINT ipar, SQLSMALLINT* pfSqlType,
        SQLUINTEGER* pcbParamDef, SQLSMALLINT* pibScale, SQLSMALLINT* pfNullable);

SQLRETURN SQLForeignKeysA(SQLHSTMT hstmt, SQLCHAR* szPkCatalogName,
        SQLSMALLINT cbPkCatalogName, SQLCHAR* szPkSchemaName, SQLSMALLINT cbPkSchemaName,
        SQLCHAR* szPkTableName, SQLSMALLINT cbPkTableName, SQLCHAR* szFkCatalogName,
        SQLSMALLINT cbFkCatalogName, SQLCHAR* szFkSchemaName, SQLSMALLINT cbFkSchemaName,
        SQLCHAR* szFkTableName, SQLSMALLINT cbFkTableName);

SQLRETURN SQLNativeSqlA(SQLHDBC hdbc, SQLCHAR* szSqlStrIn, SQLINTEGER cbSqlStrIn,
        SQLCHAR* szSqlStr, SQLINTEGER cbSqlStrMax, SQLINTEGER* pcbSqlStr);

SQLRETURN SQLPrimaryKeysA(SQLHSTMT hstmt, SQLCHAR* szCatalogName, SQLSMALLINT cbCatalogName,
        SQLCHAR* szSchemaName, SQLSMALLINT cbSchemaName, SQLCHAR* szTableName,
        SQLSMALLINT cbTableName);

SQLRETURN SQLProcedureColumnsA(SQLHSTMT hstmt, SQLCHAR* szCatalogName,
        SQLSMALLINT cbCatalogName, SQLCHAR* szSchemaName, SQLSMALLINT cbSchemaName,
        SQLCHAR* szProcName, SQLSMALLINT cbProcName, SQLCHAR* szColumnName,
        SQLSMALLINT cbColumnName);

SQLRETURN SQLProceduresA(SQLHSTMT hstmt, SQLCHAR* szCatalogName, SQLSMALLINT cbCatalogName,
        SQLCHAR* szSchemaName, SQLSMALLINT cbSchemaName, SQLCHAR* szProcName,
        SQLSMALLINT cbProcName);

SQLRETURN SQLTablePrivilegesA(SQLHSTMT hstmt, SQLCHAR* szCatalogName,
        SQLSMALLINT cbCatalogName, SQLCHAR* szSchemaName, SQLSMALLINT cbSchemaName,
        SQLCHAR* szTableName, SQLSMALLINT cbTableName);

SQLRETURN SQLDriversA(SQLHENV henv, SQLUSMALLINT fDirection, SQLCHAR* szDriverDesc,
        SQLSMALLINT cbDriverDescMax, SQLSMALLINT* pcbDriverDesc,
        SQLCHAR* szDriverAttributes, SQLSMALLINT cbDrvrAttrMax, SQLSMALLINT* pcbDrvrAttr);

// ODBC 4.0 narrow entry points (compiled in only when `ODBC4` is defined).
version (ODBC4)
{
    SQLRETURN SQLStructuredTypesA(SQLHSTMT hstmt, SQLCHAR* szCatalogName,
            SQLSMALLINT cbCatalogName, SQLCHAR* szSchemaName, SQLSMALLINT cbSchemaName,
            SQLCHAR* szTypeName, SQLSMALLINT cbTypeName);

    SQLRETURN SQLStructuredTypeColumnsA(SQLHSTMT hstmt, SQLCHAR* szCatalogName,
            SQLSMALLINT cbCatalogName, SQLCHAR* szSchemaName, SQLSMALLINT cbSchemaName,
            SQLCHAR* szTypeName, SQLSMALLINT cbTypeName, SQLCHAR* szColumnName,
            SQLSMALLINT cbColumnName);
}
