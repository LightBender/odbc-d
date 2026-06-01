/**
 * A D-native API over the ODBC 4.0 C interface.
 *
 * Every routine here wraps a single ODBC C entry point, accepting and
 * returning D-native types (`string`, `void[]`, the scalar `SQL*` aliases, and
 * small result structs) and reporting outcomes through `Result`. The
 * wide-character (`W`) entry points are used throughout so D `string`s are
 * carried losslessly; conversion to and from the platform `SQLWCHAR` encoding
 * is handled internally.
 *
 * On failure each routine collects the full ODBC diagnostic record stack from
 * the relevant handle into the returned `Result`, including the consolidated
 * driver-specific error text.
 *
 * The complete, unwrapped C API remains available through `etc.c.odbc`.
 *
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 */
module odbc.api;

import etc.c.odbc;
import odbc.result;
import odbc.core;

/*
 * ---------------------------------------------------------------------------
 * Result value structs
 * ---------------------------------------------------------------------------
 */

/// Result-set column metadata produced by `describeColumn`.
struct ColumnDescription
{
    string name; /// Column name.
    SQLSMALLINT dataType; /// SQL data type (one of the `SQL_*` type codes).
    SQLULEN columnSize; /// Column size (precision) in characters or digits.
    SQLSMALLINT decimalDigits; /// Number of decimal digits (scale).
    SQLSMALLINT nullable; /// Nullability (`SQL_NO_NULLS`/`SQL_NULLABLE`/`SQL_NULLABLE_UNKNOWN`).
}

/// Parameter metadata produced by `describeParam`.
struct ParamDescription
{
    SQLSMALLINT dataType; /// SQL data type of the parameter.
    SQLULEN paramSize; /// Size (precision) of the parameter.
    SQLSMALLINT decimalDigits; /// Number of decimal digits (scale).
    SQLSMALLINT nullable; /// Nullability of the parameter.
}

/// Descriptor record fields produced by `getDescRec`.
struct DescRecord
{
    string name; /// Record (column) name.
    SQLSMALLINT type; /// Concise type.
    SQLSMALLINT subType; /// Datetime/interval sub-type.
    SQLLEN length; /// Octet length.
    SQLSMALLINT precision; /// Precision.
    SQLSMALLINT scale; /// Scale.
    SQLSMALLINT nullable; /// Nullability.
}

/// One data source entry produced by `dataSources`.
struct DataSourceInfo
{
    string name; /// Data source name (DSN).
    string description; /// Associated driver description.
}

/// One installed driver entry produced by `drivers`.
struct DriverInfo
{
    string description; /// Driver description.
    string attributes; /// Null-delimited driver attribute keywords.
}

/*
 * ---------------------------------------------------------------------------
 * Internal helpers
 * ---------------------------------------------------------------------------
 */

// Encodes a possibly-null D string into a wide buffer, preserving the
// NULL-vs-empty distinction that ODBC catalog functions depend on. The
// encoded storage is written back through `storage` so it outlives the call.
private SQLWCHAR* widePtr(ref SQLWCHAR[] storage, scope const(char)[] s) @trusted
{
    if (s is null)
    {
        storage = null;
        return null;
    }
    storage = toSqlWide(s);
    return storage.ptr;
}

// Clamps a driver-reported length to the usable portion of a buffer of
// capacity `cap` (reserving one element for a terminator on truncation).
private size_t clampLen(L)(L outLen, size_t cap) @safe pure nothrow @nogc
{
    if (outLen <= 0)
        return 0;
    immutable n = cast(size_t) outLen;
    return n < cap ? n : cap - 1;
}

// Reads a wide string from an ODBC entry point that measures its buffer in
// characters via the (buffer, capacityChars, *lengthChars) pattern. Grows the
// buffer once if the first call reports truncation.
private Result!string readWideStringChars(L)(
        scope SQLRETURN delegate(SQLWCHAR*, L, L*) @system call,
        SQLSMALLINT handleType, SQLHANDLE handle) @trusted
{
    auto buf = new SQLWCHAR[256];
    L outLen = 0;
    auto rc = call(buf.ptr, cast(L) buf.length, &outLen);
    if (!isSuccess(rc))
        return fail!string(rc, handleType, handle);

    if (outLen >= cast(L) buf.length)
    {
        buf = new SQLWCHAR[outLen + 1];
        rc = call(buf.ptr, cast(L) buf.length, &outLen);
        if (!isSuccess(rc))
            return fail!string(rc, handleType, handle);
    }
    return Result!string.ok(fromSqlWide(buf[0 .. clampLen(outLen, buf.length)]), rc);
}

// Reads a wide string from an ODBC entry point that measures its buffer in
// bytes via the (buffer, capacityBytes, *lengthBytes) pattern.
private Result!string readWideStringBytes(L)(
        scope SQLRETURN delegate(SQLPOINTER, L, L*) @system call,
        SQLSMALLINT handleType, SQLHANDLE handle) @trusted
{
    auto buf = new SQLWCHAR[256];
    L outBytes = 0;
    auto rc = call(buf.ptr, cast(L)(buf.length * SQLWCHAR.sizeof), &outBytes);
    if (!isSuccess(rc))
        return fail!string(rc, handleType, handle);

    immutable chars = outBytes / cast(L) SQLWCHAR.sizeof;
    if (chars >= cast(L) buf.length)
    {
        buf = new SQLWCHAR[chars + 1];
        rc = call(buf.ptr, cast(L)(buf.length * SQLWCHAR.sizeof), &outBytes);
        if (!isSuccess(rc))
            return fail!string(rc, handleType, handle);
    }
    return Result!string.ok(
            fromSqlWide(buf[0 .. clampLen(outBytes / cast(L) SQLWCHAR.sizeof, buf.length)]), rc);
}

/*
 * ---------------------------------------------------------------------------
 * Handle and resource lifecycle
 * ---------------------------------------------------------------------------
 */

/**
 * Allocates an ODBC handle of `handleType` (`SQL_HANDLE_ENV`/`SQL_HANDLE_DBC`/
 * `SQL_HANDLE_STMT`/`SQL_HANDLE_DESC`) parented by `inputHandle`. On failure
 * the diagnostics are read from the parent handle.
 */
Result!SQLHANDLE allocHandle(SQLSMALLINT handleType, SQLHANDLE inputHandle) @trusted
{
    SQLHANDLE output;
    const rc = SQLAllocHandle(handleType, inputHandle, &output);
    if (isSuccess(rc))
        return Result!SQLHANDLE.ok(output, rc);

    immutable parentType = handleType == SQL_HANDLE_DBC ? SQL_HANDLE_ENV
        : handleType == SQL_HANDLE_STMT ? SQL_HANDLE_DBC
        : handleType == SQL_HANDLE_DESC ? SQL_HANDLE_DBC : SQL_HANDLE_ENV;
    return fail!SQLHANDLE(rc, parentType, inputHandle);
}

/// Allocates a new environment handle.
Result!SQLHANDLE allocEnv() @trusted
{
    return allocHandle(SQL_HANDLE_ENV, SQL_NULL_HANDLE);
}

/// Allocates a connection handle on environment `env`.
Result!SQLHANDLE allocConnection(SQLHENV env) @trusted
{
    return allocHandle(SQL_HANDLE_DBC, env);
}

/// Allocates a statement handle on connection `dbc`.
Result!SQLHANDLE allocStatement(SQLHDBC dbc) @trusted
{
    return allocHandle(SQL_HANDLE_STMT, dbc);
}

/// Allocates a descriptor handle on connection `dbc`.
Result!SQLHANDLE allocDescriptor(SQLHDBC dbc) @trusted
{
    return allocHandle(SQL_HANDLE_DESC, dbc);
}

/// Frees the handle `handle` of type `handleType`.
Result!void freeHandle(SQLSMALLINT handleType, SQLHANDLE handle) @trusted
{
    return check(SQLFreeHandle(handleType, handle), handleType, handle);
}

/// Frees or resets statement resources according to `option` (`SQL_CLOSE`,
/// `SQL_UNBIND`, `SQL_RESET_PARAMS`, ...).
Result!void freeStmt(SQLHSTMT stmt, SQLUSMALLINT option) @trusted
{
    return check(SQLFreeStmt(stmt, option), SQL_HANDLE_STMT, stmt);
}

/// Cancels processing on a statement.
Result!void cancel(SQLHSTMT stmt) @trusted
{
    return check(SQLCancel(stmt), SQL_HANDLE_STMT, stmt);
}

/// Cancels processing on an arbitrary handle.
///
/// $(B ODBC 3.8.) Excluded under the `ODBC35` version (the iODBC baseline on
/// macOS), which caps the surface at ODBC 3.5.
version (ODBC35)
{
}
else
Result!void cancelHandle(SQLSMALLINT handleType, SQLHANDLE handle) @trusted
{
    return check(SQLCancelHandle(handleType, handle), handleType, handle);
}

/// Closes the cursor open on a statement and discards pending results.
Result!void closeCursor(SQLHSTMT stmt) @trusted
{
    return check(SQLCloseCursor(stmt), SQL_HANDLE_STMT, stmt);
}

/// Completes an asynchronously executing operation, returning its final code.
///
/// $(B ODBC 3.8.) Only implemented on Windows.
version (Windows)
Result!RETCODE completeAsync(SQLSMALLINT handleType, SQLHANDLE handle) @trusted
{
    RETCODE asyncRet;
    const rc = SQLCompleteAsync(handleType, handle, &asyncRet);
    return checkValue(rc, asyncRet, handleType, handle);
}

/// Commits or rolls back the transaction associated with `handle`
/// (`completionType` is `SQL_COMMIT` or `SQL_ROLLBACK`).
Result!void endTran(SQLSMALLINT handleType, SQLHANDLE handle, SQLSMALLINT completionType) @trusted
{
    return check(SQLEndTran(handleType, handle, completionType), handleType, handle);
}

/*
 * ---------------------------------------------------------------------------
 * Connecting
 * ---------------------------------------------------------------------------
 */

/// Connects `dbc` to a data source by DSN and optional credentials.
Result!void connect(SQLHDBC dbc, scope const(char)[] dsn,
        scope const(char)[] user = null, scope const(char)[] password = null) @trusted
{
    auto wdsn = toSqlWide(dsn);
    auto wuser = toSqlWide(user);
    auto wpass = toSqlWide(password);
    const rc = SQLConnectW(dbc, wdsn.ptr, SQL_NTS, wuser.ptr, SQL_NTS, wpass.ptr, SQL_NTS);
    return check(rc, SQL_HANDLE_DBC, dbc);
}

/// Connects `dbc` using a driver connection string, returning the completed
/// connection string reported by the driver.
Result!string driverConnect(SQLHDBC dbc, scope const(char)[] connectionString,
        SQLHWND windowHandle = null, SQLUSMALLINT completion = SQL_DRIVER_NOPROMPT) @trusted
{
    auto win = toSqlWide(connectionString);
    return readWideStringChars!SQLSMALLINT(
            (SQLWCHAR* buf, SQLSMALLINT cap, SQLSMALLINT* outLen) => SQLDriverConnectW(dbc,
                windowHandle, win.ptr, SQL_NTS, buf, cap, outLen, completion),
            SQL_HANDLE_DBC, dbc);
}

/// Iteratively builds a connection string, returning the driver's next
/// browse-result string.
Result!string browseConnect(SQLHDBC dbc, scope const(char)[] connectionString) @trusted
{
    auto win = toSqlWide(connectionString);
    return readWideStringChars!SQLSMALLINT(
            (SQLWCHAR* buf, SQLSMALLINT cap, SQLSMALLINT* outLen) => SQLBrowseConnectW(dbc,
                win.ptr, SQL_NTS, buf, cap, outLen), SQL_HANDLE_DBC, dbc);
}

/// Disconnects `dbc` from its data source.
Result!void disconnect(SQLHDBC dbc) @trusted
{
    return check(SQLDisconnect(dbc), SQL_HANDLE_DBC, dbc);
}

/// Returns the data-source-translated form of an SQL statement.
Result!string nativeSql(SQLHDBC dbc, scope const(char)[] sql) @trusted
{
    auto win = toSqlWide(sql);
    return readWideStringChars!SQLINTEGER(
            (SQLWCHAR* buf, SQLINTEGER cap, SQLINTEGER* outLen) => SQLNativeSqlW(dbc,
                win.ptr, SQL_NTS, buf, cap, outLen), SQL_HANDLE_DBC, dbc);
}

/*
 * ---------------------------------------------------------------------------
 * Information and capability queries
 * ---------------------------------------------------------------------------
 */

/// Retrieves a string-valued `SQLGetInfo` item.
Result!string getInfoString(SQLHDBC dbc, SQLUSMALLINT infoType) @trusted
{
    return readWideStringBytes!SQLSMALLINT(
            (SQLPOINTER buf, SQLSMALLINT cap, SQLSMALLINT* outLen) => SQLGetInfoW(dbc,
                infoType, buf, cap, outLen), SQL_HANDLE_DBC, dbc);
}

/// Retrieves a 16-bit integer `SQLGetInfo` item.
Result!SQLUSMALLINT getInfoUShort(SQLHDBC dbc, SQLUSMALLINT infoType) @trusted
{
    SQLUSMALLINT value;
    SQLSMALLINT len;
    const rc = SQLGetInfoW(dbc, infoType, &value, cast(SQLSMALLINT) value.sizeof, &len);
    return checkValue(rc, value, SQL_HANDLE_DBC, dbc);
}

/// Retrieves a 32-bit integer `SQLGetInfo` item.
Result!SQLUINTEGER getInfoUInt(SQLHDBC dbc, SQLUSMALLINT infoType) @trusted
{
    SQLUINTEGER value;
    SQLSMALLINT len;
    const rc = SQLGetInfoW(dbc, infoType, &value, cast(SQLSMALLINT) value.sizeof, &len);
    return checkValue(rc, value, SQL_HANDLE_DBC, dbc);
}

/// Reports whether the driver supports the ODBC function `functionId`.
Result!bool supportsFunction(SQLHDBC dbc, SQLUSMALLINT functionId) @trusted
{
    SQLUSMALLINT supported;
    const rc = SQLGetFunctions(dbc, functionId, &supported);
    return checkValue(rc, supported != 0, SQL_HANDLE_DBC, dbc);
}

/// Retrieves information about the SQL types supported by the data source,
/// producing a result set fetched with `fetch`.
Result!void getTypeInfo(SQLHSTMT stmt, SQLSMALLINT dataType) @trusted
{
    return check(SQLGetTypeInfoW(stmt, dataType), SQL_HANDLE_STMT, stmt);
}

/*
 * ---------------------------------------------------------------------------
 * Attributes
 * ---------------------------------------------------------------------------
 */

/// Sets an integer-valued environment attribute.
Result!void setEnvAttr(SQLHENV env, SQLINTEGER attribute, SQLINTEGER value) @trusted
{
    return check(SQLSetEnvAttr(env, attribute, cast(SQLPOINTER) cast(size_t) value, 0),
            SQL_HANDLE_ENV, env);
}

/// Sets a buffer-valued environment attribute.
Result!void setEnvAttrRaw(SQLHENV env, SQLINTEGER attribute, void[] value) @trusted
{
    return check(SQLSetEnvAttr(env, attribute, value.ptr, cast(SQLINTEGER) value.length),
            SQL_HANDLE_ENV, env);
}

/// Retrieves an integer-valued environment attribute.
Result!SQLINTEGER getEnvAttr(SQLHENV env, SQLINTEGER attribute) @trusted
{
    SQLINTEGER value;
    const rc = SQLGetEnvAttr(env, attribute, &value, 0, null);
    return checkValue(rc, value, SQL_HANDLE_ENV, env);
}

/// Sets an integer-valued connection attribute.
Result!void setConnectAttr(SQLHDBC dbc, SQLINTEGER attribute, SQLUINTEGER value) @trusted
{
    return check(SQLSetConnectAttrW(dbc, attribute, cast(SQLPOINTER) cast(size_t) value, 0),
            SQL_HANDLE_DBC, dbc);
}

/// Sets a string-valued connection attribute.
Result!void setConnectAttr(SQLHDBC dbc, SQLINTEGER attribute, scope const(char)[] value) @trusted
{
    auto w = toSqlWide(value);
    return check(SQLSetConnectAttrW(dbc, attribute, w.ptr, SQL_NTS), SQL_HANDLE_DBC, dbc);
}

/// Sets a buffer-valued connection attribute.
Result!void setConnectAttrRaw(SQLHDBC dbc, SQLINTEGER attribute, void[] value) @trusted
{
    return check(SQLSetConnectAttrW(dbc, attribute, value.ptr, cast(SQLINTEGER) value.length),
            SQL_HANDLE_DBC, dbc);
}

/// Retrieves an integer-valued connection attribute.
Result!SQLUINTEGER getConnectAttrUInt(SQLHDBC dbc, SQLINTEGER attribute) @trusted
{
    SQLUINTEGER value;
    const rc = SQLGetConnectAttrW(dbc, attribute, &value, cast(SQLINTEGER) value.sizeof, null);
    return checkValue(rc, value, SQL_HANDLE_DBC, dbc);
}

/// Retrieves a string-valued connection attribute.
Result!string getConnectAttrString(SQLHDBC dbc, SQLINTEGER attribute) @trusted
{
    return readWideStringBytes!SQLINTEGER(
            (SQLPOINTER buf, SQLINTEGER cap, SQLINTEGER* outLen) => SQLGetConnectAttrW(dbc,
                attribute, buf, cap, outLen), SQL_HANDLE_DBC, dbc);
}

/// Sets an integer-valued statement attribute.
Result!void setStmtAttr(SQLHSTMT stmt, SQLINTEGER attribute, SQLLEN value) @trusted
{
    return check(SQLSetStmtAttrW(stmt, attribute, cast(SQLPOINTER) value, 0),
            SQL_HANDLE_STMT, stmt);
}

/// Sets a buffer-valued statement attribute.
Result!void setStmtAttrRaw(SQLHSTMT stmt, SQLINTEGER attribute, void[] value) @trusted
{
    return check(SQLSetStmtAttrW(stmt, attribute, value.ptr, cast(SQLINTEGER) value.length),
            SQL_HANDLE_STMT, stmt);
}

/// Retrieves an integer-valued statement attribute.
Result!SQLLEN getStmtAttr(SQLHSTMT stmt, SQLINTEGER attribute) @trusted
{
    SQLLEN value;
    const rc = SQLGetStmtAttrW(stmt, attribute, &value, 0, null);
    return checkValue(rc, value, SQL_HANDLE_STMT, stmt);
}

/*
 * ---------------------------------------------------------------------------
 * Statement preparation and execution
 * ---------------------------------------------------------------------------
 */

/// Prepares an SQL statement for later execution.
Result!void prepare(SQLHSTMT stmt, scope const(char)[] sql) @trusted
{
    auto w = toSqlWide(sql);
    return check(SQLPrepareW(stmt, w.ptr, SQL_NTS), SQL_HANDLE_STMT, stmt);
}

/// Executes an SQL statement directly, preparing and executing in one step.
Result!void execDirect(SQLHSTMT stmt, scope const(char)[] sql) @trusted
{
    auto w = toSqlWide(sql);
    return check(SQLExecDirectW(stmt, w.ptr, SQL_NTS), SQL_HANDLE_STMT, stmt);
}

/// Executes a previously prepared statement.
Result!void execute(SQLHSTMT stmt) @trusted
{
    return check(SQLExecute(stmt), SQL_HANDLE_STMT, stmt);
}

/// Advances to the next row of the result set.
Result!void fetch(SQLHSTMT stmt) @trusted
{
    return check(SQLFetch(stmt), SQL_HANDLE_STMT, stmt);
}

/// Positions the cursor and fetches a row according to `orientation` and
/// `offset` (e.g. `SQL_FETCH_NEXT`).
Result!void fetchScroll(SQLHSTMT stmt, SQLSMALLINT orientation, SQLLEN offset) @trusted
{
    return check(SQLFetchScroll(stmt, orientation, offset), SQL_HANDLE_STMT, stmt);
}

/// Advances to the next result set of a multi-result statement.
Result!void moreResults(SQLHSTMT stmt) @trusted
{
    return check(SQLMoreResults(stmt), SQL_HANDLE_STMT, stmt);
}

/// Returns the number of columns in the current result set.
Result!SQLSMALLINT numResultCols(SQLHSTMT stmt) @trusted
{
    SQLSMALLINT count;
    const rc = SQLNumResultCols(stmt, &count);
    return checkValue(rc, count, SQL_HANDLE_STMT, stmt);
}

/// Returns the number of rows affected by an insert, update, or delete.
Result!SQLLEN rowCount(SQLHSTMT stmt) @trusted
{
    SQLLEN count;
    const rc = SQLRowCount(stmt, &count);
    return checkValue(rc, count, SQL_HANDLE_STMT, stmt);
}

/// Returns the number of parameters in a prepared statement.
Result!SQLSMALLINT numParams(SQLHSTMT stmt) @trusted
{
    SQLSMALLINT count;
    const rc = SQLNumParams(stmt, &count);
    return checkValue(rc, count, SQL_HANDLE_STMT, stmt);
}

/*
 * ---------------------------------------------------------------------------
 * Binding and data transfer
 * ---------------------------------------------------------------------------
 */

/// Binds application storage `buffer` to result-set column `column`. The
/// `strLenOrInd` pointer must remain valid for the lifetime of the binding.
Result!void bindCol(SQLHSTMT stmt, SQLUSMALLINT column, SQLSMALLINT targetType,
        void[] buffer, SQLLEN* strLenOrInd) @trusted
{
    const rc = SQLBindCol(stmt, column, targetType, buffer.ptr,
            cast(SQLLEN) buffer.length, strLenOrInd);
    return check(rc, SQL_HANDLE_STMT, stmt);
}

/// Binds a parameter marker to application storage. The `strLenOrInd` pointer
/// must remain valid until the statement is executed.
Result!void bindParameter(SQLHSTMT stmt, SQLUSMALLINT parameter, SQLSMALLINT ioType,
        SQLSMALLINT valueType, SQLSMALLINT paramType, SQLULEN columnSize,
        SQLSMALLINT decimalDigits, void[] buffer, SQLLEN* strLenOrInd) @trusted
{
    const rc = SQLBindParameter(stmt, parameter, ioType, valueType, paramType, columnSize,
            decimalDigits, buffer.ptr, cast(SQLLEN) buffer.length, strLenOrInd);
    return check(rc, SQL_HANDLE_STMT, stmt);
}

/// Retrieves data for a single column of the current row into `buffer`,
/// returning the length-or-indicator value reported by the driver.
Result!SQLLEN getData(SQLHSTMT stmt, SQLUSMALLINT column, SQLSMALLINT targetType,
        void[] buffer) @trusted
{
    SQLLEN indicator;
    const rc = SQLGetData(stmt, column, targetType, buffer.ptr,
            cast(SQLLEN) buffer.length, &indicator);
    return checkValue(rc, indicator, SQL_HANDLE_STMT, stmt);
}

/// Sends part of a data-at-execution parameter value to the driver.
Result!void putData(SQLHSTMT stmt, scope const(void)[] data) @trusted
{
    const rc = SQLPutData(stmt, cast(SQLPOINTER) data.ptr, cast(SQLLEN) data.length);
    return check(rc, SQL_HANDLE_STMT, stmt);
}

/// Returns the next data-at-execution parameter requiring data, as the value
/// pointer the application associated with it.
Result!SQLPOINTER paramData(SQLHSTMT stmt) @trusted
{
    SQLPOINTER value;
    const rc = SQLParamData(stmt, &value);
    return checkValue(rc, value, SQL_HANDLE_STMT, stmt);
}

/*
 * ---------------------------------------------------------------------------
 * Result-set and parameter metadata
 * ---------------------------------------------------------------------------
 */

/// Describes result-set column `column`.
Result!ColumnDescription describeColumn(SQLHSTMT stmt, SQLUSMALLINT column) @trusted
{
    auto name = new SQLWCHAR[1024];
    SQLSMALLINT nameLen, dataType, decimalDigits, nullable;
    SQLULEN columnSize;
    const rc = SQLDescribeColW(stmt, column, name.ptr, cast(SQLSMALLINT) name.length,
            &nameLen, &dataType, &columnSize, &decimalDigits, &nullable);
    if (!isSuccess(rc))
        return fail!ColumnDescription(rc, SQL_HANDLE_STMT, stmt);

    auto desc = ColumnDescription(fromSqlWide(name[0 .. clampLen(nameLen, name.length)]),
            dataType, columnSize, decimalDigits, nullable);
    return Result!ColumnDescription.ok(desc, rc);
}

/// Describes parameter marker `parameter` of a prepared statement.
Result!ParamDescription describeParam(SQLHSTMT stmt, SQLUSMALLINT parameter) @trusted
{
    SQLSMALLINT dataType, decimalDigits, nullable;
    SQLULEN paramSize;
    const rc = SQLDescribeParam(stmt, parameter, &dataType, &paramSize, &decimalDigits, &nullable);
    if (!isSuccess(rc))
        return fail!ParamDescription(rc, SQL_HANDLE_STMT, stmt);
    return Result!ParamDescription.ok(
            ParamDescription(dataType, paramSize, decimalDigits, nullable), rc);
}

/// Retrieves a character (string) descriptor field of result-set column
/// `column`.
Result!string colAttributeString(SQLHSTMT stmt, SQLUSMALLINT column, SQLUSMALLINT field) @trusted
{
    auto buf = new SQLWCHAR[512];
    SQLSMALLINT strLenBytes;
    version (Win64)
    {
        SQLLEN numeric;
        const rc = SQLColAttributeW(stmt, column, field, buf.ptr,
                cast(SQLSMALLINT)(buf.length * SQLWCHAR.sizeof), &strLenBytes, &numeric);
    }
    else
    {
        const rc = SQLColAttributeW(stmt, column, field, buf.ptr,
                cast(SQLSMALLINT)(buf.length * SQLWCHAR.sizeof), &strLenBytes, null);
    }
    if (!isSuccess(rc))
        return fail!string(rc, SQL_HANDLE_STMT, stmt);

    immutable chars = strLenBytes / cast(int) SQLWCHAR.sizeof;
    return Result!string.ok(fromSqlWide(buf[0 .. clampLen(chars, buf.length)]), rc);
}

/// Retrieves a numeric descriptor field of result-set column `column`.
Result!SQLLEN colAttributeNumeric(SQLHSTMT stmt, SQLUSMALLINT column, SQLUSMALLINT field) @trusted
{
    SQLLEN numeric;
    SQLSMALLINT strLen;
    version (Win64)
        const rc = SQLColAttributeW(stmt, column, field, null, 0, &strLen, &numeric);
    else
        const rc = SQLColAttributeW(stmt, column, field, null, 0, &strLen,
                cast(SQLPOINTER)&numeric);
    return checkValue(rc, numeric, SQL_HANDLE_STMT, stmt);
}

/*
 * ---------------------------------------------------------------------------
 * Cursors
 * ---------------------------------------------------------------------------
 */

/// Assigns a name to the cursor open on a statement.
Result!void setCursorName(SQLHSTMT stmt, scope const(char)[] name) @trusted
{
    auto w = toSqlWide(name);
    return check(SQLSetCursorNameW(stmt, w.ptr, SQL_NTS), SQL_HANDLE_STMT, stmt);
}

/// Returns the name of the cursor open on a statement.
Result!string getCursorName(SQLHSTMT stmt) @trusted
{
    return readWideStringChars!SQLSMALLINT(
            (SQLWCHAR* buf, SQLSMALLINT cap, SQLSMALLINT* outLen) => SQLGetCursorNameW(stmt,
                buf, cap, outLen), SQL_HANDLE_STMT, stmt);
}

/// Sets the cursor position within a rowset and optionally performs an
/// operation (`SQL_POSITION`, `SQL_REFRESH`, `SQL_UPDATE`, ...).
Result!void setPos(SQLHSTMT stmt, SQLSETPOSIROW row, SQLUSMALLINT operation,
        SQLUSMALLINT lockType) @trusted
{
    return check(SQLSetPos(stmt, row, operation, lockType), SQL_HANDLE_STMT, stmt);
}

/// Performs a bulk insert, update, delete, or fetch by bookmark.
Result!void bulkOperations(SQLHSTMT stmt, SQLSMALLINT operation) @trusted
{
    return check(SQLBulkOperations(stmt, operation), SQL_HANDLE_STMT, stmt);
}

/// Fetches a rowset and scrolls the cursor, returning the number of rows
/// fetched. The optional `rowStatus` buffer receives per-row status values.
Result!SQLULEN extendedFetch(SQLHSTMT stmt, SQLUSMALLINT fetchType, SQLLEN row,
        SQLUSMALLINT* rowStatus = null) @trusted
{
    SQLULEN rowsFetched;
    const rc = SQLExtendedFetch(stmt, fetchType, row, &rowsFetched, rowStatus);
    return checkValue(rc, rowsFetched, SQL_HANDLE_STMT, stmt);
}

/*
 * ---------------------------------------------------------------------------
 * Descriptors
 * ---------------------------------------------------------------------------
 */

/// Copies the fields of one descriptor to another.
Result!void copyDesc(SQLHDESC source, SQLHDESC target) @trusted
{
    return check(SQLCopyDesc(source, target), SQL_HANDLE_DESC, target);
}

/// Retrieves a descriptor field into `buffer`, returning the byte length the
/// driver reported for the field.
Result!SQLINTEGER getDescField(SQLHDESC desc, SQLSMALLINT recNumber, SQLSMALLINT field,
        void[] buffer) @trusted
{
    SQLINTEGER outLen;
    const rc = SQLGetDescFieldW(desc, recNumber, field, buffer.ptr,
            cast(SQLINTEGER) buffer.length, &outLen);
    return checkValue(rc, outLen, SQL_HANDLE_DESC, desc);
}

/// Sets a descriptor field from `value`.
Result!void setDescField(SQLHDESC desc, SQLSMALLINT recNumber, SQLSMALLINT field,
        void[] value) @trusted
{
    const rc = SQLSetDescFieldW(desc, recNumber, field, value.ptr, cast(SQLINTEGER) value.length);
    return check(rc, SQL_HANDLE_DESC, desc);
}

/// Retrieves the commonly used fields of a descriptor record.
Result!DescRecord getDescRec(SQLHDESC desc, SQLSMALLINT recNumber) @trusted
{
    auto name = new SQLWCHAR[1024];
    SQLSMALLINT nameLen, type, subType, precision, scale, nullable;
    SQLLEN length;
    const rc = SQLGetDescRecW(desc, recNumber, name.ptr, cast(SQLSMALLINT) name.length,
            &nameLen, &type, &subType, &length, &precision, &scale, &nullable);
    if (!isSuccess(rc))
        return fail!DescRecord(rc, SQL_HANDLE_DESC, desc);

    auto rec = DescRecord(fromSqlWide(name[0 .. clampLen(nameLen, name.length)]),
            type, subType, length, precision, scale, nullable);
    return Result!DescRecord.ok(rec, rc);
}

/// Sets the commonly used fields of a descriptor record. The `stringLength`
/// and `indicator` pointers must remain valid for the lifetime of the record.
Result!void setDescRec(SQLHDESC desc, SQLSMALLINT recNumber, SQLSMALLINT type,
        SQLSMALLINT subType, SQLLEN length, SQLSMALLINT precision, SQLSMALLINT scale,
        void[] data, SQLLEN* stringLength, SQLLEN* indicator) @trusted
{
    const rc = SQLSetDescRec(desc, recNumber, type, subType, length, precision, scale,
            data.ptr, stringLength, indicator);
    return check(rc, SQL_HANDLE_DESC, desc);
}

/*
 * ---------------------------------------------------------------------------
 * Diagnostics
 * ---------------------------------------------------------------------------
 */

/// Retrieves a single diagnostic record from `handle`. A `Result` whose code
/// is `SQL_NO_DATA` indicates `recNumber` is past the end of the stack.
Result!SqlDiagnostic getDiagRec(SQLSMALLINT handleType, SQLHANDLE handle,
        SQLSMALLINT recNumber) @trusted
{
    SQLWCHAR[6] state;
    auto msg = new SQLWCHAR[SQL_MAX_MESSAGE_LENGTH];
    SQLINTEGER nativeError;
    SQLSMALLINT msgLen;
    const rc = SQLGetDiagRecW(handleType, handle, recNumber, state.ptr, &nativeError,
            msg.ptr, cast(SQLSMALLINT) msg.length, &msgLen);
    if (!isSuccess(rc))
        return Result!SqlDiagnostic.err(rc);

    auto diag = SqlDiagnostic(fromSqlWide(state[0 .. 5]), nativeError,
            fromSqlWide(msg[0 .. clampLen(msgLen, msg.length)]));
    return Result!SqlDiagnostic.ok(diag, rc);
}

/// Retrieves a diagnostic field into `buffer`, returning the byte length the
/// driver reported for the field.
Result!SQLSMALLINT getDiagField(SQLSMALLINT handleType, SQLHANDLE handle,
        SQLSMALLINT recNumber, SQLSMALLINT diagField, void[] buffer) @trusted
{
    SQLSMALLINT outLen;
    const rc = SQLGetDiagFieldW(handleType, handle, recNumber, diagField, buffer.ptr,
            cast(SQLSMALLINT) buffer.length, &outLen);
    if (!isSuccess(rc))
        return Result!SQLSMALLINT.err(rc);
    return Result!SQLSMALLINT.ok(outLen, rc);
}

/*
 * ---------------------------------------------------------------------------
 * Catalog functions
 * ---------------------------------------------------------------------------
 */

/// Lists tables, catalogs, or schemas matching the given filters. Pass `null`
/// for a filter to leave it unrestricted.
Result!void tables(SQLHSTMT stmt, scope const(char)[] catalog = null,
        scope const(char)[] schema = null, scope const(char)[] table = null,
        scope const(char)[] tableType = null) @trusted
{
    SQLWCHAR[] c, s, t, tt;
    const rc = SQLTablesW(stmt, widePtr(c, catalog), SQL_NTS, widePtr(s, schema),
            SQL_NTS, widePtr(t, table), SQL_NTS, widePtr(tt, tableType), SQL_NTS);
    return check(rc, SQL_HANDLE_STMT, stmt);
}

/// Lists the columns of the tables matching the given filters.
Result!void columns(SQLHSTMT stmt, scope const(char)[] catalog = null,
        scope const(char)[] schema = null, scope const(char)[] table = null,
        scope const(char)[] column = null) @trusted
{
    SQLWCHAR[] c, s, t, col;
    const rc = SQLColumnsW(stmt, widePtr(c, catalog), SQL_NTS, widePtr(s, schema),
            SQL_NTS, widePtr(t, table), SQL_NTS, widePtr(col, column), SQL_NTS);
    return check(rc, SQL_HANDLE_STMT, stmt);
}

/// Lists the access privileges for the columns of a table.
Result!void columnPrivileges(SQLHSTMT stmt, scope const(char)[] catalog,
        scope const(char)[] schema, scope const(char)[] table,
        scope const(char)[] column = null) @trusted
{
    SQLWCHAR[] c, s, t, col;
    const rc = SQLColumnPrivilegesW(stmt, widePtr(c, catalog), SQL_NTS, widePtr(s, schema),
            SQL_NTS, widePtr(t, table), SQL_NTS, widePtr(col, column), SQL_NTS);
    return check(rc, SQL_HANDLE_STMT, stmt);
}

/// Lists the access privileges for the tables matching the given filters.
Result!void tablePrivileges(SQLHSTMT stmt, scope const(char)[] catalog,
        scope const(char)[] schema, scope const(char)[] table) @trusted
{
    SQLWCHAR[] c, s, t;
    const rc = SQLTablePrivilegesW(stmt, widePtr(c, catalog), SQL_NTS,
            widePtr(s, schema), SQL_NTS, widePtr(t, table), SQL_NTS);
    return check(rc, SQL_HANDLE_STMT, stmt);
}

/// Lists the columns that uniquely identify a row, or that are automatically
/// updated. `identifierType` is `SQL_BEST_ROWID` or `SQL_ROWVER`.
Result!void specialColumns(SQLHSTMT stmt, SQLUSMALLINT identifierType,
        scope const(char)[] catalog, scope const(char)[] schema, scope const(char)[] table,
        SQLUSMALLINT scopeOfResult, SQLUSMALLINT nullable) @trusted
{
    SQLWCHAR[] c, s, t;
    const rc = SQLSpecialColumnsW(stmt, identifierType, widePtr(c, catalog), SQL_NTS,
            widePtr(s, schema), SQL_NTS, widePtr(t, table), SQL_NTS, scopeOfResult, nullable);
    return check(rc, SQL_HANDLE_STMT, stmt);
}

/// Lists the statistics and indexes for a single table.
Result!void statistics(SQLHSTMT stmt, scope const(char)[] catalog,
        scope const(char)[] schema, scope const(char)[] table, SQLUSMALLINT unique,
        SQLUSMALLINT reserved) @trusted
{
    SQLWCHAR[] c, s, t;
    const rc = SQLStatisticsW(stmt, widePtr(c, catalog), SQL_NTS, widePtr(s, schema),
            SQL_NTS, widePtr(t, table), SQL_NTS, unique, reserved);
    return check(rc, SQL_HANDLE_STMT, stmt);
}

/// Lists the primary-key columns of a single table.
Result!void primaryKeys(SQLHSTMT stmt, scope const(char)[] catalog,
        scope const(char)[] schema, scope const(char)[] table) @trusted
{
    SQLWCHAR[] c, s, t;
    const rc = SQLPrimaryKeysW(stmt, widePtr(c, catalog), SQL_NTS, widePtr(s, schema),
            SQL_NTS, widePtr(t, table), SQL_NTS);
    return check(rc, SQL_HANDLE_STMT, stmt);
}

/// Lists the foreign-key relationships between a primary-key table and a
/// foreign-key table.
Result!void foreignKeys(SQLHSTMT stmt, scope const(char)[] pkCatalog,
        scope const(char)[] pkSchema, scope const(char)[] pkTable,
        scope const(char)[] fkCatalog, scope const(char)[] fkSchema,
        scope const(char)[] fkTable) @trusted
{
    SQLWCHAR[] pc, ps, pt, fc, fs, ft;
    const rc = SQLForeignKeysW(stmt, widePtr(pc, pkCatalog), SQL_NTS, widePtr(ps, pkSchema),
            SQL_NTS, widePtr(pt, pkTable), SQL_NTS, widePtr(fc, fkCatalog), SQL_NTS,
            widePtr(fs, fkSchema), SQL_NTS, widePtr(ft, fkTable), SQL_NTS);
    return check(rc, SQL_HANDLE_STMT, stmt);
}

/// Lists the stored procedures matching the given filters.
Result!void procedures(SQLHSTMT stmt, scope const(char)[] catalog,
        scope const(char)[] schema, scope const(char)[] procedure) @trusted
{
    SQLWCHAR[] c, s, p;
    const rc = SQLProceduresW(stmt, widePtr(c, catalog), SQL_NTS, widePtr(s, schema),
            SQL_NTS, widePtr(p, procedure), SQL_NTS);
    return check(rc, SQL_HANDLE_STMT, stmt);
}

/// Lists the input/output parameters and result columns of stored procedures.
Result!void procedureColumns(SQLHSTMT stmt, scope const(char)[] catalog,
        scope const(char)[] schema, scope const(char)[] procedure,
        scope const(char)[] column = null) @trusted
{
    SQLWCHAR[] c, s, p, col;
    const rc = SQLProcedureColumnsW(stmt, widePtr(c, catalog), SQL_NTS, widePtr(s, schema),
            SQL_NTS, widePtr(p, procedure), SQL_NTS, widePtr(col, column), SQL_NTS);
    return check(rc, SQL_HANDLE_STMT, stmt);
}

/// Lists the structured (user-defined) types matching the given filters.
///
/// $(B ODBC 4.0.) Available only when compiled with the `ODBC4` version
/// (always on Windows; opt-in elsewhere via the `odbc4` DUB configuration).
version (ODBC4)
Result!void structuredTypes(SQLHSTMT stmt, scope const(char)[] catalog,
        scope const(char)[] schema, scope const(char)[] typeName) @trusted
{
    SQLWCHAR[] c, s, t;
    const rc = SQLStructuredTypesW(stmt, widePtr(c, catalog), SQL_NTS, widePtr(s, schema),
            SQL_NTS, widePtr(t, typeName), SQL_NTS);
    return check(rc, SQL_HANDLE_STMT, stmt);
}

/// Lists the attributes (columns) of structured types.
///
/// $(B ODBC 4.0.) Available only when compiled with the `ODBC4` version.
version (ODBC4)
Result!void structuredTypeColumns(SQLHSTMT stmt, scope const(char)[] catalog,
        scope const(char)[] schema, scope const(char)[] typeName,
        scope const(char)[] column = null) @trusted
{
    SQLWCHAR[] c, s, t, col;
    const rc = SQLStructuredTypeColumnsW(stmt, widePtr(c, catalog), SQL_NTS, widePtr(s, schema),
            SQL_NTS, widePtr(t, typeName), SQL_NTS, widePtr(col, column), SQL_NTS);
    return check(rc, SQL_HANDLE_STMT, stmt);
}

/// Returns the next column produced by a catalog function that streams its
/// columns, as the running column count.
///
/// $(B ODBC 4.0.) Available only when compiled with the `ODBC4` version.
version (ODBC4)
Result!SQLUSMALLINT nextColumn(SQLHSTMT stmt) @trusted
{
    SQLUSMALLINT count;
    const rc = SQLNextColumn(stmt, &count);
    return checkValue(rc, count, SQL_HANDLE_STMT, stmt);
}

/// Opens the nested statement for a column or parameter of structured type.
///
/// $(B ODBC 4.0.) Available only when compiled with the `ODBC4` version.
version (ODBC4)
Result!SQLHANDLE getNestedHandle(SQLHSTMT parentStmt, SQLUSMALLINT colOrParam) @trusted
{
    SQLHSTMT child;
    const rc = SQLGetNestedHandle(parentStmt, colOrParam, &child);
    return checkValue!SQLHANDLE(rc, child, SQL_HANDLE_STMT, parentStmt);
}

/*
 * ---------------------------------------------------------------------------
 * Driver and data-source enumeration
 * ---------------------------------------------------------------------------
 */

/// Returns one data source on environment `env`. Use `SQL_FETCH_FIRST` /
/// `SQL_FETCH_NEXT` for `direction`; a `Result` code of `SQL_NO_DATA` marks the
/// end of the list.
Result!DataSourceInfo dataSources(SQLHENV env, SQLUSMALLINT direction) @trusted
{
    auto nameBuf = new SQLWCHAR[256];
    auto descBuf = new SQLWCHAR[1024];
    SQLSMALLINT nameLen, descLen;
    const rc = SQLDataSourcesW(env, direction, nameBuf.ptr, cast(SQLSMALLINT) nameBuf.length,
            &nameLen, descBuf.ptr, cast(SQLSMALLINT) descBuf.length, &descLen);
    if (!isSuccess(rc))
        return Result!DataSourceInfo.err(rc);

    auto info = DataSourceInfo(fromSqlWide(nameBuf[0 .. clampLen(nameLen, nameBuf.length)]),
            fromSqlWide(descBuf[0 .. clampLen(descLen, descBuf.length)]));
    return Result!DataSourceInfo.ok(info, rc);
}

/// Returns one installed driver on environment `env`. A `Result` code of
/// `SQL_NO_DATA` marks the end of the list.
Result!DriverInfo drivers(SQLHENV env, SQLUSMALLINT direction) @trusted
{
    auto descBuf = new SQLWCHAR[512];
    auto attrBuf = new SQLWCHAR[2048];
    SQLSMALLINT descLen, attrLen;
    const rc = SQLDriversW(env, direction, descBuf.ptr, cast(SQLSMALLINT) descBuf.length,
            &descLen, attrBuf.ptr, cast(SQLSMALLINT) attrBuf.length, &attrLen);
    if (!isSuccess(rc))
        return Result!DriverInfo.err(rc);

    auto info = DriverInfo(fromSqlWide(descBuf[0 .. clampLen(descLen, descBuf.length)]),
            fromSqlWide(attrBuf[0 .. clampLen(attrLen, attrBuf.length)]));
    return Result!DriverInfo.ok(info, rc);
}

@safe unittest
{
    // Pure compile/instantiation coverage: the wrappers must type-check and the
    // result structs must be constructible. ODBC calls are not exercised here
    // because no driver manager is guaranteed to be present.
    ColumnDescription col = {"id", SQL_INTEGER, 10, 0, SQL_NO_NULLS};
    assert(col.name == "id");

    auto e = Result!SQLHANDLE.err(-1);
    assert(e.isErr);

    static assert(is(typeof(connect(null, "dsn")) == Result!void));
    static assert(is(typeof(describeColumn(null, 1)) == Result!ColumnDescription));
    static assert(is(typeof(getCursorName(null)) == Result!string));
    static assert(is(typeof(dataSources(null, SQL_FETCH_FIRST)) == Result!DataSourceInfo));
}
