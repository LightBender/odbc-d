// D import file generated from 'src\sql.c'
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
	__gshared short SQLAllocConnect(void* EnvironmentHandle, void** ConnectionHandle);
	__gshared short SQLAllocEnv(void** EnvironmentHandle);
	__gshared short SQLAllocHandle(short HandleType, void* InputHandle, void** OutputHandle);
	__gshared short SQLAllocStmt(void* ConnectionHandle, void** StatementHandle);
	__gshared short SQLBindCol(void* StatementHandle, ushort ColumnNumber, short TargetType, void* TargetValue, long BufferLength, long* StrLen_or_Ind);
	deprecated("ODBC API: SQLBindParam is deprecated. Please use SQLBindParameter instead.") deprecated __gshared short SQLBindParam(void* StatementHandle, ushort ParameterNumber, short ValueType, short ParameterType, ulong LengthPrecision, short ParameterScale, void* ParameterValue, long* StrLen_or_Ind);
	__gshared short SQLCancel(void* StatementHandle);
	__gshared short SQLCancelHandle(short HandleType, void* InputHandle);
	__gshared short SQLCloseCursor(void* StatementHandle);
	__gshared short SQLColAttribute(void* StatementHandle, ushort ColumnNumber, ushort FieldIdentifier, void* CharacterAttribute, short BufferLength, short* StringLength, long* NumericAttribute);
	__gshared short SQLColumns(void* StatementHandle, ubyte* CatalogName, short NameLength1, ubyte* SchemaName, short NameLength2, ubyte* TableName, short NameLength3, ubyte* ColumnName, short NameLength4);
	__gshared short SQLCompleteAsync(short HandleType, void* Handle, short* AsyncRetCodePtr);
	__gshared short SQLConnect(void* ConnectionHandle, ubyte* ServerName, short NameLength1, ubyte* UserName, short NameLength2, ubyte* Authentication, short NameLength3);
	__gshared short SQLCopyDesc(void* SourceDescHandle, void* TargetDescHandle);
	__gshared short SQLDataSources(void* EnvironmentHandle, ushort Direction, ubyte* ServerName, short BufferLength1, short* NameLength1Ptr, ubyte* Description, short BufferLength2, short* NameLength2Ptr);
	__gshared short SQLDescribeCol(void* StatementHandle, ushort ColumnNumber, ubyte* ColumnName, short BufferLength, short* NameLength, short* DataType, ulong* ColumnSize, short* DecimalDigits, short* Nullable);
	__gshared short SQLDisconnect(void* ConnectionHandle);
	__gshared short SQLEndTran(short HandleType, void* Handle, short CompletionType);
	__gshared short SQLError(void* EnvironmentHandle, void* ConnectionHandle, void* StatementHandle, ubyte* Sqlstate, int* NativeError, ubyte* MessageText, short BufferLength, short* TextLength);
	__gshared short SQLExecDirect(void* StatementHandle, ubyte* StatementText, int TextLength);
	__gshared short SQLExecute(void* StatementHandle);
	__gshared short SQLFetch(void* StatementHandle);
	__gshared short SQLFetchScroll(void* StatementHandle, short FetchOrientation, long FetchOffset);
	__gshared short SQLFreeConnect(void* ConnectionHandle);
	__gshared short SQLFreeEnv(void* EnvironmentHandle);
	__gshared short SQLFreeHandle(short HandleType, void* Handle);
	__gshared short SQLFreeStmt(void* StatementHandle, ushort Option);
	__gshared short SQLGetConnectAttr(void* ConnectionHandle, int Attribute, void* Value, int BufferLength, int* StringLengthPtr);
	deprecated("ODBC API: SQLGetConnectOption is deprecated. Please use SQLGetConnectAttr instead.") deprecated __gshared short SQLGetConnectOption(void* ConnectionHandle, ushort Option, void* Value);
	__gshared short SQLGetCursorName(void* StatementHandle, ubyte* CursorName, short BufferLength, short* NameLengthPtr);
	__gshared short SQLGetData(void* StatementHandle, ushort ColumnNumber, short TargetType, void* TargetValue, long BufferLength, long* StrLen_or_IndPtr);
	__gshared short SQLGetDescField(void* DescriptorHandle, short RecNumber, short FieldIdentifier, void* Value, int BufferLength, int* StringLength);
	__gshared short SQLGetDescRec(void* DescriptorHandle, short RecNumber, ubyte* Name, short BufferLength, short* StringLengthPtr, short* TypePtr, short* SubTypePtr, long* LengthPtr, short* PrecisionPtr, short* ScalePtr, short* NullablePtr);
	__gshared short SQLGetDiagField(short HandleType, void* Handle, short RecNumber, short DiagIdentifier, void* DiagInfo, short BufferLength, short* StringLength);
	__gshared short SQLGetDiagRec(short HandleType, void* Handle, short RecNumber, ubyte* Sqlstate, int* NativeError, ubyte* MessageText, short BufferLength, short* TextLength);
	__gshared short SQLGetEnvAttr(void* EnvironmentHandle, int Attribute, void* Value, int BufferLength, int* StringLength);
	__gshared short SQLGetFunctions(void* ConnectionHandle, ushort FunctionId, ushort* Supported);
	__gshared short SQLGetInfo(void* ConnectionHandle, ushort InfoType, void* InfoValue, short BufferLength, short* StringLengthPtr);
	__gshared short SQLGetStmtAttr(void* StatementHandle, int Attribute, void* Value, int BufferLength, int* StringLength);
	deprecated("ODBC API: SQLGetStmtOption is deprecated. Please use SQLGetStmtAttr instead.") deprecated __gshared short SQLGetStmtOption(void* StatementHandle, ushort Option, void* Value);
	__gshared short SQLGetTypeInfo(void* StatementHandle, short DataType);
	__gshared short SQLNumResultCols(void* StatementHandle, short* ColumnCount);
	__gshared short SQLParamData(void* StatementHandle, void** Value);
	__gshared short SQLPrepare(void* StatementHandle, ubyte* StatementText, int TextLength);
	__gshared short SQLPutData(void* StatementHandle, void* Data, long StrLen_or_Ind);
	__gshared short SQLRowCount(void* StatementHandle, long* RowCount);
	__gshared short SQLSetConnectAttr(void* ConnectionHandle, int Attribute, void* Value, int StringLength);
	deprecated("ODBC API: SQLSetConnectOption is deprecated. Please use SQLSetConnectAttr instead.") deprecated __gshared short SQLSetConnectOption(void* ConnectionHandle, ushort Option, ulong Value);
	__gshared short SQLSetCursorName(void* StatementHandle, ubyte* CursorName, short NameLength);
	__gshared short SQLSetDescField(void* DescriptorHandle, short RecNumber, short FieldIdentifier, void* Value, int BufferLength);
	__gshared short SQLSetDescRec(void* DescriptorHandle, short RecNumber, short Type, short SubType, long Length, short Precision, short Scale, void* Data, long* StringLength, long* Indicator);
	__gshared short SQLSetEnvAttr(void* EnvironmentHandle, int Attribute, void* Value, int StringLength);
	deprecated("ODBC API: SQLSetParam is deprecated. Please use SQLBindParameter instead.") deprecated __gshared short SQLSetParam(void* StatementHandle, ushort ParameterNumber, short ValueType, short ParameterType, ulong LengthPrecision, short ParameterScale, void* ParameterValue, long* StrLen_or_Ind);
	__gshared short SQLSetStmtAttr(void* StatementHandle, int Attribute, void* Value, int StringLength);
	deprecated("ODBC API: SQLSetStmtOption is deprecated. Please use SQLSetStmtAttr instead.") deprecated __gshared short SQLSetStmtOption(void* StatementHandle, ushort Option, ulong Value);
	__gshared short SQLSpecialColumns(void* StatementHandle, ushort IdentifierType, ubyte* CatalogName, short NameLength1, ubyte* SchemaName, short NameLength2, ubyte* TableName, short NameLength3, ushort Scope, ushort Nullable);
	__gshared short SQLStatistics(void* StatementHandle, ubyte* CatalogName, short NameLength1, ubyte* SchemaName, short NameLength2, ubyte* TableName, short NameLength3, ushort Unique, ushort Reserved);
	__gshared short SQLTables(void* StatementHandle, ubyte* CatalogName, short NameLength1, ubyte* SchemaName, short NameLength2, ubyte* TableName, short NameLength3, ubyte* TableType, short NameLength4);
	__gshared short SQLTransact(void* EnvironmentHandle, void* ConnectionHandle, ushort CompletionType);
	enum int SQL_SERVER_NAME = 13;
	enum int SQL_DIAG_CREATE_SCHEMA = 64;
	enum int SQL_INDEX_UNIQUE = 0;
	enum int SQL_TC_NONE = 0;
	enum int SQL_API_SQLPUTDATA = 49;
	enum int SQL_SCROLL_CONCURRENCY = 43;
	enum int SQL_DIAG_CREATE_VIEW = 84;
	enum int SQL_FETCH_LAST = 3;
	enum int SQL_FETCH_ABSOLUTE = 5;
	enum int __IMPORTC__ = 1;
	enum int SQL_OJ_NESTED = 8;
	enum int SQL_DESC_ALLOC_AUTO = 1;
	enum int SQL_ATTR_IMP_ROW_DESC = 10012;
	enum int SQL_FALSE = 0;
	enum int SQL_HANDLE_DESC = 4;
	enum int SQL_PARAM_DATA_AVAILABLE = 101;
	enum int SQL_DEFAULT_TXN_ISOLATION = 26;
	enum int SQL_DESC_TYPE = 1002;
	enum int SQL_DESC_OCTET_LENGTH_PTR = 1004;
	enum int _M_X64 = 100;
	enum int SQL_API_SQLSETPARAM = 22;
	enum int SQL_API_SQLGETDESCREC = 1009;
	enum int SQL_COLLATION_SEQ = 10004;
	enum int SQL_API_SQLROWCOUNT = 20;
	enum int _MSC_EXTENSIONS = 1;
	enum int SQL_API_SQLSETENVATTR = 1019;
	enum int SQL_MAX_INDEX_SIZE = 102;
	enum int SQL_DIAG_CREATE_TABLE = 77;
	enum int SQL_DESC_SCALE = 1006;
	enum int SQL_SCOPE_SESSION = 2;
	enum int SQL_API_SQLEXECDIRECT = 11;
	enum int SQL_TYPE_TIME = 92;
	enum int SQL_ORDER_BY_COLUMNS_IN_SELECT = 90;
	enum int SQL_DIAG_DROP_DOMAIN = 27;
	enum int SQL_DBMS_VER = 18;
	enum int SQL_PRED_CHAR = 1;
	enum int SQL_PC_PSEUDO = 2;
	enum int SQL_DATA_SOURCE_NAME = 2;
	enum int _USE_ATTRIBUTES_FOR_SAL = 0;
	enum int SQL_NUMERIC = 2;
	enum int SQL_SUCCESS_WITH_INFO = 1;
	enum int SQL_MAX_STATEMENT_LEN = 105;
	enum int SQL_ACCESSIBLE_TABLES = 19;
	enum int SQL_MAX_DRIVER_CONNECTIONS = 0;
	enum int SQL_OJ_INNER = 32;
	enum int WINAPI_FAMILY_GAMES = 6;
	enum int SQL_INDEX_ALL = 1;
	enum int SQL_MAX_MESSAGE_LENGTH = 512;
	enum int SQL_API_SQLGETCONNECTATTR = 1007;
	enum int SQL_DIAG_ALTER_DOMAIN = 3;
	enum int SQL_DESC_PRECISION = 1005;
	enum int ODBCVER = 896;
	enum int SQL_HANDLE_DBC = 2;
	enum int SQL_MAX_COLUMNS_IN_GROUP_BY = 97;
	enum int SQL_NULL_HANDLE = 0;
	enum int _MSC_BUILD = 0;
	enum int SQL_API_SQLALLOCCONNECT = 1;
	enum int SQL_DIAG_CALL = 7;
	enum int SQL_DIAG_DROP_SCHEMA = 31;
	enum int SQL_VARCHAR = 12;
	enum int SQL_IC_LOWER = 2;
	enum int SQL_GD_ANY_ORDER = 2;
	enum int SQL_DIAG_CREATE_DOMAIN = 23;
	enum int SQL_CURSOR_SENSITIVITY = 10001;
	enum int SQL_MAX_SCHEMA_NAME_LEN = 32;
	enum int SQL_NULL_HDBC = 0;
	enum int SQL_ATTR_IMP_PARAM_DESC = 10013;
	enum int SQL_DBMS_NAME = 17;
	enum int SQL_API_SQLGETDATA = 43;
	enum int SQL_SCOPE_CURROW = 0;
	enum int SQL_NC_LOW = 1;
	enum int SQL_DIAG_UPDATE_WHERE = 82;
	enum int SQL_DATA_SOURCE_READ_ONLY = 25;
	enum int SQL_SCCO_LOCK = 2;
	enum int SQL_HANDLE_STMT = 3;
	enum int SQL_DIAG_NATIVE = 5;
	enum int SQL_CLOSE = 0;
	enum int SQL_TYPE_TIMESTAMP = 93;
	enum int SQL_GD_ANY_COLUMN = 1;
	enum int SQL_MAX_CATALOG_NAME_LEN = 34;
	enum int SQL_DIAG_SELECT_CURSOR = 85;
	enum int SQL_API_SQLCANCEL = 5;
	enum int SQL_NEED_DATA = 99;
	enum int SQL_DIAG_DROP_CHARACTER_SET = 25;
	enum int SQL_API_SQLPREPARE = 19;
	enum int SQL_CODE_TIMESTAMP = 3;
	enum int SQL_API_SQLSETCURSORNAME = 21;
	enum int SQL_API_SQLCOLATTRIBUTE = 6;
	enum int SQL_API_SQLCLOSECURSOR = 1003;
	enum int SQL_CB_DELETE = 0;
	enum int SQL_UNBIND = 2;
	enum int SQL_STILL_EXECUTING = 2;
	enum int SQL_DECIMAL = 3;
	enum int SQL_DIAG_CREATE_TRANSLATION = 79;
	enum int SQL_API_SQLGETFUNCTIONS = 44;
	enum int _WIN64 = 1;
	enum int SQL_IC_MIXED = 4;
	enum int SQL_API_SQLBINDCOL = 4;
	enum int SQL_GETDATA_EXTENSIONS = 81;
	enum int SQL_NULLABLE_UNKNOWN = 2;
	enum int SQL_DIAG_NUMBER = 2;
	enum int SQL_CATALOG_NAME = 10003;
	enum int SQL_ROW_IDENTIFIER = 1;
	enum int SQL_API_SQLTABLES = 54;
	enum int SQL_DIAG_GRANT = 48;
	enum int SQL_SENSITIVE = 2;
	enum int SQL_AT_DROP_COLUMN = 2;
	enum int SQL_CHAR = 1;
	enum int SQL_ATTR_APP_ROW_DESC = 10010;
	enum int SQL_DIAG_SERVER_NAME = 11;
	enum int SQL_DIAG_SUBCLASS_ORIGIN = 9;
	enum int SQL_INDEX_HASHED = 2;
	enum int SQL_MAX_IDENTIFIER_LEN = 10005;
	enum int SQL_API_SQLCOPYDESC = 1004;
	enum int _IS_ASSIGNABLE_NOCHECK_SUPPORTED = 1;
	enum int SQL_NO_NULLS = 0;
	enum int SQL_API_SQLSETSTMTATTR = 1020;
	enum int _CRT_SECURE_NO_WARNINGS = 1;
	enum int SQL_ACCESSIBLE_PROCEDURES = 20;
	enum int SQL_DIAG_DYNAMIC_DELETE_CURSOR = 38;
	enum int SQL_DESC_DATA_PTR = 1010;
	enum int SQL_DIAG_CREATE_ASSERTION = 6;
	enum int SQL_INTEGER = 4;
	enum int SQL_DIAG_DYNAMIC_UPDATE_CURSOR = 81;
	enum int SQL_DIAG_DROP_ASSERTION = 24;
	enum int __STDC_NO_VLA__ = 1;
	enum int SQL_FETCH_FIRST = 2;
	enum int SQL_API_SQLGETCONNECTOPTION = 42;
	enum int _CRT_NONSTDC_NO_DEPRECATE = 1;
	enum int _M_AMD64 = 100;
	enum int __SAL_H_VERSION = 180000000;
	enum int _USE_DECLSPECS_FOR_SAL = 0;
	enum int SQL_DIAG_CONNECTION_NAME = 10;
	enum int SQL_SPECIAL_CHARACTERS = 94;
	enum int SQL_FD_FETCH_FIRST = 2;
	enum int SQL_OJ_ALL_COMPARISON_OPS = 64;
	enum int SQL_DROP = 1;
	enum int SQL_FD_FETCH_LAST = 4;
	enum int SQL_ATTR_APP_PARAM_DESC = 10011;
	enum int SQL_API_SQLFREEHANDLE = 1006;
	enum int SQL_DESC_ALLOC_USER = 2;
	enum int SQL_API_SQLGETDIAGREC = 1011;
	enum int SQL_API_SQLFETCH = 13;
	enum int WINAPI_FAMILY_PHONE_APP = 3;
	enum int SQL_DIAG_DELETE_WHERE = 19;
	enum int SQL_API_SQLGETDESCFIELD = 1008;
	enum int SQL_FETCH_PRIOR = 4;
	enum int SQL_IDENTIFIER_CASE = 28;
	enum int SQL_HANDLE_ENV = 1;
	enum int SQL_MAX_ROW_SIZE = 104;
	enum int SQL_XOPEN_CLI_YEAR = 10000;
	enum int SQL_DATE_LEN = 10;
	enum int SQL_ATTR_AUTO_IPD = 10001;
	enum int SQL_FETCH_NEXT = 1;
	enum int SQL_IC_UPPER = 1;
	enum int SQL_TC_DML = 1;
	enum int SQL_NULL_HSTMT = 0;
	enum int SQL_API_SQLCANCELHANDLE = 1550;
	enum int SQL_SCCO_OPT_VALUES = 8;
	enum int SQL_ALTER_TABLE = 86;
	enum int SQL_API_SQLSETCONNECTATTR = 1016;
	enum int SQL_API_SQLCONNECT = 7;
	enum int SQL_DIAG_MESSAGE_TEXT = 6;
	enum int SQL_SUCCESS = 0;
	enum int SQL_DIAG_CREATE_CHARACTER_SET = 8;
	enum int _NO_CRT_STDIO_INLINE = 1;
	enum int SQL_API_SQLGETDIAGFIELD = 1010;
	enum int SQL_NC_HIGH = 0;
	enum int SQL_DIAG_DROP_TABLE = 32;
	enum int SQL_API_SQLSETCONNECTOPTION = 50;
	enum int SQL_DIAG_DROP_VIEW = 36;
	enum int SQL_MAX_CURSOR_NAME_LEN = 31;
	enum int SQL_API_SQLALLOCHANDLE = 1001;
	enum int SQL_DIAG_DYNAMIC_FUNCTION = 7;
	enum int _MT = 1;
	enum int SQL_API_SQLFETCHSCROLL = 1021;
	enum int SQL_TIMESTAMP_LEN = 19;
	enum int SQL_DIAG_DROP_COLLATION = 26;
	enum int SQL_ROLLBACK = 1;
	enum int SQL_INDEX_CLUSTERED = 1;
	enum int SQL_PRED_NONE = 0;
	enum int SQL_API_SQLALLOCENV = 2;
	enum int SQL_CODE_DATE = 1;
	enum int SQL_API_SQLENDTRAN = 1005;
	enum int SQL_API_SQLSTATISTICS = 53;
	enum int SQL_API_SQLSETDESCREC = 1018;
	enum int SQL_SMALLINT = 5;
	enum int _MSVC_WARNING_LEVEL = 1;
	enum int SQL_FD_FETCH_NEXT = 1;
	enum int SQL_DESC_ALLOC_TYPE = 1099;
	enum int SQL_API_SQLDESCRIBECOL = 8;
	enum int SQL_DEFAULT = 99;
	enum int SQL_AT_ADD_CONSTRAINT = 8;
	enum int SQL_API_SQLBINDPARAM = 1002;
	enum int SQL_CB_CLOSE = 1;
	enum int SQL_SCCO_READ_ONLY = 1;
	enum int SQL_MAX_TABLE_NAME_LEN = 35;
	enum int SQL_OJ_NOT_ORDERED = 16;
	enum int SQL_MAX_COLUMNS_IN_SELECT = 100;
	enum int SQL_API_SQLGETCURSORNAME = 17;
	enum int SQL_DESC_COUNT = 1001;
	enum int SQL_DIAG_CREATE_COLLATION = 10;
	enum int SQL_API_SQLCOLUMNS = 40;
	enum int SQL_AM_NONE = 0;
	enum int SQL_TC_ALL = 2;
	enum int SQL_DESC_OCTET_LENGTH = 1013;
	enum int SQL_UNSPECIFIED = 0;
	enum int SQL_FD_FETCH_PRIOR = 8;
	enum int SQL_NAMED = 0;
	enum int SQL_API_SQLGETINFO = 45;
	enum int SQL_INDEX_OTHER = 3;
	enum int __STDC_HOSTED__ = 1;
	enum int SQL_IDENTIFIER_QUOTE_CHAR = 29;
	enum int SQL_FLOAT = 6;
	enum int WINAPI_FAMILY_SERVER = 5;
	enum int SQL_DIAG_ROW_COUNT = 3;
	enum int SQL_DESC_LENGTH = 1003;
	enum int SQL_API_SQLCOMPLETEASYNC = 1551;
	enum int SQL_SCCO_OPT_ROWVER = 4;
	enum int SQL_DIAG_REVOKE = 59;
	enum int SQL_NULL_COLLATION = 85;
	enum int WINAPI_FAMILY_SYSTEM = 4;
	enum int SQL_DATETIME = 9;
	enum int SQL_API_SQLGETENVATTR = 1012;
	enum int SQL_TXN_SERIALIZABLE = 8;
	enum int SQL_DESC_NAME = 1011;
	enum int SQL_API_SQLTRANSACT = 23;
	enum int SQL_PRED_BASIC = 2;
	enum int SQL_DIAG_SQLSTATE = 4;
	enum int SQL_CB_PRESERVE = 2;
	enum int SQL_MAX_COLUMN_NAME_LEN = 30;
	enum int SQL_UNNAMED = 1;
	enum int SQL_RESET_PARAMS = 3;
	enum int SQL_API_SQLFREESTMT = 16;
	enum int SQL_TXN_READ_UNCOMMITTED = 1;
	enum int SQL_API_SQLDISCONNECT = 9;
	enum int WINAPI_FAMILY_PC_APP = 2;
	enum int SQL_DESC_UNNAMED = 1012;
	enum int SQL_DIAG_DROP_TRANSLATION = 33;
	enum int SQL_TIME_LEN = 8;
	enum int SQL_DESC_NULLABLE = 1008;
	enum int SQL_ATTR_METADATA_ID = 10014;
	enum int SQL_NULL_HENV = 0;
	enum int SQL_NO_DATA = 100;
	enum int SQL_MAX_COLUMNS_IN_INDEX = 98;
	enum int SQL_TXN_ISOLATION_OPTION = 72;
	enum int SQL_DIAG_CLASS_ORIGIN = 8;
	enum int SQL_OJ_LEFT = 1;
	enum int SQL_DIAG_DYNAMIC_FUNCTION_CODE = 12;
	enum int SQL_DESCRIBE_PARAMETER = 10002;
	enum int SQL_MAX_CONCURRENT_ACTIVITIES = 1;
	enum int SQL_NULLABLE = 1;
	enum int SQL_API_SQLALLOCSTMT = 3;
	enum int SQL_AM_STATEMENT = 2;
	enum int SQL_API_SQLSPECIALCOLUMNS = 52;
	enum int SQL_IC_SENSITIVE = 3;
	enum int SQL_TC_DDL_COMMIT = 3;
	enum int SQL_API_SQLERROR = 10;
	enum int _MSC_FULL_VER = 193732822;
	enum int SQL_CODE_TIME = 2;
	enum int SQL_PC_UNKNOWN = 0;
	enum int _MSC_VER = 1937;
	enum int _MSVC_TRADITIONAL = 0;
	enum int SQL_API_SQLGETSTMTOPTION = 46;
	enum int SQL_OJ_RIGHT = 2;
	enum int SQL_FETCH_RELATIVE = 6;
	enum int SQL_DESC_INDICATOR_PTR = 1009;
	enum int SQL_FD_FETCH_ABSOLUTE = 16;
	enum int SQL_TXN_REPEATABLE_READ = 4;
	enum int SQL_API_SQLEXECUTE = 12;
	enum int SQL_API_SQLFREECONNECT = 14;
	enum int SQL_INSENSITIVE = 1;
	enum int SQL_API_SQLSETSTMTOPTION = 51;
	enum int SQL_MAX_COLUMNS_IN_TABLE = 101;
	enum int SQL_REAL = 7;
	enum int SQL_AM_CONNECTION = 1;
	enum int SQL_TRUE = 1;
	enum int SQL_API_SQLDATASOURCES = 57;
	enum int SQL_ALL_TYPES = 0;
	enum int SQL_API_SQLNUMRESULTCOLS = 18;
	enum int SQL_PC_NON_PSEUDO = 1;
	enum int SQL_FD_FETCH_RELATIVE = 32;
	enum int SQL_USER_NAME = 47;
	enum int SQL_API_SQLPARAMDATA = 48;
	enum int SQL_CURSOR_COMMIT_BEHAVIOR = 23;
	enum int SQL_MAX_USER_NAME_LEN = 107;
	enum int SQL_API_SQLGETTYPEINFO = 47;
	enum int SQL_DIAG_ALTER_TABLE = 4;
	enum int SQL_NULL_HDESC = 0;
	enum int SQL_TC_DDL_IGNORE = 4;
	enum int SQL_AT_ADD_COLUMN = 1;
	enum int SQL_OJ_CAPABILITIES = 115;
	enum int WINAPI_FAMILY_DESKTOP_APP = 100;
	enum int SQL_DESC_DATETIME_INTERVAL_CODE = 1007;
	enum int SQL_SCROLLABLE = 1;
	enum int SQL_TXN_CAPABLE = 46;
	enum int SQL_INTEGRITY = 73;
	enum int SQL_COMMIT = 0;
	enum int SQL_DOUBLE = 8;
	enum int SQL_DIAG_RETURNCODE = 1;
	enum int SQL_OJ_FULL = 4;
	enum int SQL_ATTR_OUTPUT_NTS = 10001;
	enum int _MSVC_EXECUTION_CHARACTER_SET = 1252;
	enum int SQL_TXN_READ_COMMITTED = 2;
	enum int _SAL_VERSION = 20;
	enum int _INTEGRAL_MAX_BITS = 64;
	enum int SQL_MAX_COLUMNS_IN_ORDER_BY = 99;
	enum int SQL_API_SQLFREEENV = 15;
	enum int SQL_FETCH_DIRECTION = 8;
	enum int SQL_SEARCH_PATTERN_ESCAPE = 14;
	enum int SQL_MAX_NUMERIC_LEN = 16;
	enum int SQL_MAX_TABLES_IN_SELECT = 106;
	enum int SQL_API_SQLGETSTMTATTR = 1014;
	enum int SQL_API_SQLSETDESCFIELD = 1017;
	enum int SQL_UNKNOWN_TYPE = 0;
	enum int SQL_TYPE_DATE = 91;
	enum int SQL_DIAG_INSERT = 50;
	enum int _WIN32 = 1;
	enum int SQL_DIAG_UNKNOWN_STATEMENT = 0;
	enum int SQL_NONSCROLLABLE = 0;
	enum int SQL_SCOPE_TRANSACTION = 1;
}