/**
 * The D-native ODBC wrapper package.
 *
 * Importing `odbc` brings in the high-level, D-native API together with its
 * `Result` type and the string/diagnostic helpers:
 *
 * $(UL
 *   $(LI `odbc.api` — one D-native function per ODBC C entry point, accepting
 *        and returning D types and reporting outcomes through `Result`,)
 *   $(LI `odbc.result` — the `Result` type and `SqlDiagnostic` record, and)
 *   $(LI `odbc.core` — string conversion and diagnostic helpers.)
 * )
 *
 * The raw C API remains available separately through `etc.c.odbc`.
 *
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 */
module odbc;

public import odbc.result;
public import odbc.core;
public import odbc.api;
