/**
 * Internal helper routines shared by the D-native ODBC wrapper.
 *
 * This module provides the building blocks used by `odbc.api`:
 *
 * $(UL
 *   $(LI string conversion between D `string`s and the platform `SQLWCHAR`
 *        encoding,)
 *   $(LI extraction of the ODBC diagnostic record stack, and)
 *   $(LI helpers that fold a raw `SQLRETURN` plus optional value into a
 *        `Result`.)
 * )
 *
 * The wrapper favours the wide-character (`W`) entry points throughout. The
 * complete C API remains available through `etc.c.odbc`.
 *
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 */
module odbc.core;

import etc.c.odbc;
import odbc.result;

import std.array : appender, Appender;
import std.utf : byUTF;

/*
 * ---------------------------------------------------------------------------
 * String conversion helpers
 * ---------------------------------------------------------------------------
 */

/**
 * Converts a UTF-8 D string to a null-terminated `SQLWCHAR` buffer in the
 * platform's wide encoding (UTF-16 on Windows/unixODBC, UTF-32 on iODBC).
 */
SQLWCHAR[] toSqlWide(scope const(char)[] s) @safe
{
    auto buf = appender!(SQLWCHAR[]);
    buf.reserve(s.length + 1);
    foreach (c; s.byUTF!(SQLWCHAR))
        buf.put(cast(SQLWCHAR) c);
    buf.put(cast(SQLWCHAR) 0);
    return buf.data;
}

/**
 * Decodes a `SQLWCHAR` slice in the platform's wide encoding into a UTF-8 D
 * string. The slice must not include a trailing null terminator.
 */
string fromSqlWide(scope const(SQLWCHAR)[] s) @safe
{
    auto buf = appender!string;
    buf.reserve(s.length);
    foreach (c; s.byUTF!char)
        buf.put(c);
    return buf.data;
}

@safe unittest
{
    auto wide = toSqlWide("héllo");
    assert(wide.length >= 6); // at least 5 chars + null terminator
    assert(wide[$ - 1] == 0);
    assert(fromSqlWide(wide[0 .. $ - 1]) == "héllo");

    // ASCII round-trips one code unit per character plus the terminator.
    auto ascii = toSqlWide("abc");
    assert(ascii.length == 4);
    assert(fromSqlWide(ascii[0 .. $ - 1]) == "abc");
}

/*
 * ---------------------------------------------------------------------------
 * Diagnostics
 * ---------------------------------------------------------------------------
 */

/**
 * Retrieves the full diagnostic record stack for `handle` (of type
 * `handleType`, one of `SQL_HANDLE_ENV`/`SQL_HANDLE_DBC`/`SQL_HANDLE_STMT`/
 * `SQL_HANDLE_DESC`) and assembles a consolidated message.
 */
private void collectDiagnostics(SQLSMALLINT handleType, SQLHANDLE handle,
        out SqlDiagnostic[] records, out string consolidated) @trusted
{
    auto recs = appender!(SqlDiagnostic[]);
    auto text = appender!string;

    SQLWCHAR[6] stateBuf;
    SQLWCHAR[SQL_MAX_MESSAGE_LENGTH] msgBuf;

    for (SQLSMALLINT i = 1;; ++i)
    {
        SQLINTEGER nativeError;
        SQLSMALLINT msgLen;
        const rc = SQLGetDiagRecW(handleType, handle, i, stateBuf.ptr,
                &nativeError, msgBuf.ptr, cast(SQLSMALLINT) msgBuf.length, &msgLen);
        if (rc == SQL_NO_DATA || !isSuccess(rc))
            break;

        immutable usable = msgLen < msgBuf.length ? msgLen : cast(SQLSMALLINT)(msgBuf.length - 1);
        auto state = fromSqlWide(stateBuf[0 .. 5]);
        auto message = fromSqlWide(msgBuf[0 .. usable]);
        recs.put(SqlDiagnostic(state, nativeError, message));

        if (i > 1)
            text.put('\n');
        text.put('[');
        text.put(state);
        text.put("] ");
        text.put(message);
    }

    records = recs.data;
    consolidated = text.data;
}

/**
 * Builds a failed `Result` of type `T` by collecting the diagnostics from
 * `handle`.
 */
package Result!T fail(T)(SQLRETURN code, SQLSMALLINT handleType, SQLHANDLE handle) @trusted
{
    SqlDiagnostic[] records;
    string consolidated;
    collectDiagnostics(handleType, handle, records, consolidated);
    return Result!T.err(code, records, consolidated);
}

/**
 * Folds a raw `SQLRETURN` into a `Result!void`, collecting diagnostics from
 * `handle` on failure.
 */
package Result!void check(SQLRETURN code, SQLSMALLINT handleType, SQLHANDLE handle) @trusted
{
    if (isSuccess(code))
        return Result!void.ok(code);
    return fail!void(code, handleType, handle);
}

/**
 * Folds a raw `SQLRETURN` plus a computed `value` into a `Result!T`,
 * collecting diagnostics from `handle` on failure.
 */
package Result!T checkValue(T)(SQLRETURN code, T value, SQLSMALLINT handleType,
        SQLHANDLE handle) @trusted
{
    if (isSuccess(code))
        return Result!T.ok(value, code);
    return fail!T(code, handleType, handle);
}
