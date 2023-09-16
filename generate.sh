dmd src/sqltypes.c -Hf=src/sqltypes.d -verrors=0 -main -P="/I\"C:\\Program Files (x86)\\Windows Kits\\10\\Include\\10.0.22621.0\\shared\""
dmd src/sql.c -Hf=src/sql.d -verrors=0 -main -P="/Zc:wchar_t /I\"C:\\Program Files (x86)\\Windows Kits\\10\\Include\\10.0.22621.0\\shared\""
dmd src/sqlucode.c -Hf=src/sqlucode.d -verrors=0 -main -P="/Zc:wchar_t /I\"C:\\Program Files (x86)\\Windows Kits\\10\\Include\\10.0.22621.0\\shared\"" -v
dmd src/sqlext.c -Hf=src/sqlext.d -verrors=0 -main -P="/Zc:wchar_t /I\"C:\\Program Files (x86)\\Windows Kits\\10\\Include\\10.0.22621.0\\shared\""
rm -f *.exe
rm -f *.obj
