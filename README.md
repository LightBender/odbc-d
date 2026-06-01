# odbc-d

Cross-platform D bindings and a lightweight, D-native wrapper for the ODBC 4.0 C API.

`odbc-d` provides a full 1:1 translation of the C ODBC APIs (`etc.c.odbc.*`), as well as a thin, idiomatic wrapper (`odbc.*`) that simplifies usage in D applications. The wrapper handles UTF-8 ↔ wide character conversions natively, exposes result structures, and relies on a robust `Result` type for error handling without throwing exceptions.

## Features

* **D-Native Wrapper:** Use modern D idioms, slices, and standard UTF-8 strings.
* **Result-Type Error Handling:** No exceptions. Every ODBC operation returns a `Result` carrying a success value or a full stack of diagnostic records alongside a consolidated error message.
* **Cross-Platform:** Automatically adjusts the API level and calling conventions to the target platform and library (`odbc32` on Windows, `iodbc` on macOS, `odbc` / `unixODBC` on Posix).
* **ODBC 4.0 Support:** Gives access to modern ODBC 4.0 features when supported by the underlying driver manager.

## Installation

Add `odbc-d` to your project using DUB:

```console
dub add odbc-d
```

Or add it to your `dub.sdl`:
```sdl
dependency "odbc-d" version="~>1.0.0"
```

## Platform API Levels

Different operating systems and driver managers support different versions of the ODBC specification. `odbc-d` automatically exposes the highest safe baseline per platform.

| Platform | Default API Level | Driver Manager | Notes |
|----------|--- |---|---|
| **Windows** | **ODBC 4.0** | Windows Driver Manager | Native support for ODBC 4.0 APIs. |
| **macOS** | **ODBC 3.5** | iODBC | iODBC is capped at ODBC 3.5. Excludes ODBC 3.8+ functionality. |
| **POSIX (Linux)** | **ODBC 3.8** | unixODBC | Default assumption for unixODBC. |

If you need to override these defaults, several DUB configurations are available:
* `library` (Default): Uses the OS defaults as listed above.
* `odbc4`: Opt-in to the ODBC 4.0 additions on every platform.
* `odbc35`: Cap the entire API surface at ODBC 3.5 regardless of platform (avoids link errors on older driver managers).

## Usage Examples

Here is a quick example of connecting to a data source, executing a query, and checking for errors using the D-native `Result` types.

```d
import odbc;
import std.stdio;

void main()
{
    // 1. Allocate an environment handle
    auto envResult = allocEnv();
    if (envResult.isErr) {
        writeln("Failed to allocate environment: ", envResult.message);
        return;
    }
    auto env = envResult.value;

    // Optional but typical for modern ODBC: Set application version to ODBC 3
    setEnvAttr(env, SQL_ATTR_ODBC_VERSION, SQL_OV_ODBC3);

    // 2. Allocate a connection
    auto dbcResult = allocConnection(env);
    if (dbcResult.isErr) {
        writeln("Failed to allocate connection: ", dbcResult.message);
        return;
    }
    auto dbc = dbcResult.value;

    // 3. Connect to a database
    auto connResult = connect(dbc, "MyDSN", "db_username", "db_password");
    if (connResult.isErr) {
        writeln("Connection failed: ", connResult.message);
        return;
    }

    // 4. Allocate a statement and execute a query
    auto stmtResult = allocStatement(dbc);
    if (stmtResult.isOk) {
        auto stmt = stmtResult.value;

        // Execute SQL directly
        auto execResult = execDirect(stmt, "SELECT id, name FROM users");
        if (execResult.isOk) {
            
            // Fetch rows iteratively
            while (fetch(stmt).isOk) {
                // For example, retrieve column 2 as a string
                char[256] nameBuf;
                auto dataRes = getData(stmt, 2, SQL_C_CHAR, nameBuf[]);
                if (dataRes.isOk) {
                    writeln("Name: ", nameBuf[0 .. dataRes.value]);
                }
            }
        } else {
            writeln("Query failed: ", execResult.message);
        }

        // Clean up statement
        freeHandle(SQL_HANDLE_STMT, stmt);
    }

    // Clean up connection and environment
    disconnect(dbc);
    freeHandle(SQL_HANDLE_DBC, dbc);
    freeHandle(SQL_HANDLE_ENV, env);
}
```

## Contributing

Contributions to `odbc-d` are welcome! Please submit patches and features via Pull Requests.

**Important LLM Guideline:** If you use a Large Language Model (such as GitHub Copilot, ChatGPT, Claude, etc.) to generate or assist heavily with your contribution, **you must include the exact prompt(s) you used to generate the code in the `PROMPTS.txt` file at the root of the repository.**

## License

This project is licensed under the Boost Software License 1.0. See the `LICENSE` file for details.
