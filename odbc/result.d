/**
 * A lightweight result type for the D-native ODBC wrapper.
 *
 * ODBC reports outcomes through `SQLRETURN` codes and an associated diagnostic
 * record stack rather than exceptions. This module mirrors that model with a
 * `Result` value type so wrapper functions can return either a value or rich
 * error information without throwing.
 *
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 */
module odbc.result;

import etc.c.odbc.sql : SQLRETURN, SQL_SUCCESS, SQL_SUCCESS_WITH_INFO;
import etc.c.odbc.sqltypes : SQLINTEGER;

/**
 * A single ODBC diagnostic record, as produced by `SQLGetDiagRec`.
 *
 * Strings are stored as D-native `string`s already decoded from the driver's
 * character encoding.
 */
struct SqlDiagnostic
{
    /// The five-character SQLSTATE code (e.g. `"08001"`).
    string sqlState;

    /// The data-source-specific native error code.
    SQLINTEGER nativeError;

    /// The human-readable diagnostic message for this record.
    string message;
}

/**
 * Returns `true` when `code` represents success (`SQL_SUCCESS` or
 * `SQL_SUCCESS_WITH_INFO`).
 */
bool isSuccess(SQLRETURN code) @nogc nothrow pure @safe
{
    return code == SQL_SUCCESS || code == SQL_SUCCESS_WITH_INFO;
}

/**
 * The outcome of an ODBC operation.
 *
 * Carries the raw `SQLRETURN` code, an optional success value of type `T`, the
 * full stack of diagnostic records, and a consolidated text message built from
 * those records. The consolidated message is intended to surface
 * database-specific error text to application developers for debugging.
 *
 * Use `Result!void` for operations that produce no value.
 */
struct Result(T)
{
    private SQLRETURN _code = SQL_SUCCESS;
    private SqlDiagnostic[] _diagnostics;
    private string _message;

    static if (!is(T == void))
        private T _value;

    /// Constructs a successful result wrapping `value`.
    static if (!is(T == void))
        static Result ok(T value, SQLRETURN code = SQL_SUCCESS) @safe
        {
            Result r;
            r._code = code;
            r._value = value;
            return r;
        }
    else
        static Result ok(SQLRETURN code = SQL_SUCCESS) @safe
        {
            Result r;
            r._code = code;
            return r;
        }

    /// Constructs a failed result from a return code and diagnostics.
    static Result err(SQLRETURN code, SqlDiagnostic[] diagnostics = null,
            string message = null) @safe
    {
        Result r;
        r._code = code;
        r._diagnostics = diagnostics;
        r._message = message;
        return r;
    }

    /// The raw `SQLRETURN` code returned by the driver.
    SQLRETURN code() const @nogc nothrow pure @safe
    {
        return _code;
    }

    /// `true` if the operation succeeded.
    bool isOk() const @nogc nothrow pure @safe
    {
        return isSuccess(_code);
    }

    /// `true` if the operation failed.
    bool isErr() const @nogc nothrow pure @safe
    {
        return !isOk();
    }

    /// Allows `if (result)` to test for success.
    bool opCast(B : bool)() const @nogc nothrow pure @safe
    {
        return isOk();
    }

    static if (!is(T == void))
    {
        /// The success value. Only meaningful when `isOk` is `true`.
        ref inout(T) value() inout @nogc nothrow pure @safe
        {
            return _value;
        }
    }

    /// The full stack of diagnostic records (empty on success).
    const(SqlDiagnostic)[] diagnostics() const @nogc nothrow pure @safe
    {
        return _diagnostics;
    }

    /**
     * A consolidated, human-readable error message assembled from the
     * diagnostic records, including any database-specific text.
     */
    string message() const @nogc nothrow pure @safe
    {
        return _message;
    }
}

@safe unittest
{
    auto ok = Result!int.ok(42);
    assert(ok.isOk);
    assert(!ok.isErr);
    assert(ok.value == 42);
    assert(cast(bool) ok);
    assert(ok.diagnostics.length == 0);
    assert(ok.message is null);
}

@safe unittest
{
    auto diags = [SqlDiagnostic("08001", 17, "Cannot connect")];
    auto err = Result!int.err(-1, diags, "08001: Cannot connect");
    assert(err.isErr);
    assert(!err.isOk);
    assert(!cast(bool) err);
    assert(err.code == -1);
    assert(err.diagnostics.length == 1);
    assert(err.diagnostics[0].sqlState == "08001");
    assert(err.diagnostics[0].nativeError == 17);
    assert(err.message == "08001: Cannot connect");
}

@safe unittest
{
    // SQL_SUCCESS_WITH_INFO still counts as success.
    auto withInfo = Result!void.ok(SQL_SUCCESS_WITH_INFO);
    assert(withInfo.isOk);

    auto voidErr = Result!void.err(-2);
    assert(voidErr.isErr);
    assert(voidErr.code == -2);
}
