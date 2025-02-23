import std.array;
import std.ascii;
import std.algorithm.searching;
import std.conv;
import std.datetime;
import std.file;
import std.path;
import std.process;
import std.stdio;
import std.string;

version(Windows)
{

void main()
{
	string specPath = buildNormalizedPath(getcwd(), "spec");
	runCommand("git clean -fdx", specPath);
	runCommand("git reset --hard HEAD", specPath);

	//Build Windows static libraries for x86/x64.
	string msbuildroot = "C:\\Program Files\\";
	version (X86_64) msbuildroot = "C:\\Program Files (x86)\\";

	string msbuildpath = "C:\\Program Files\\Microsoft Visual Studio\\2022\\Professional\\MSBuild\\Current\\Bin\\MSBuild.exe";
	if (!exists(msbuildpath)) {
		msbuildpath = "C:\\Program Files\\Microsoft Visual Studio\\2022\\Enterprise\\MSBuild\\Current\\Bin\\MSBuild.exe";
		if (!exists(msbuildpath)) {
			msbuildpath = msbuildroot ~ "Microsoft Visual Studio\\2019\\Enterprise\\MSBuild\\Current\\Bin\\MSBuild.exe";
			if (!exists(msbuildpath)) {
				msbuildpath = msbuildroot ~ "Microsoft Visual Studio\\2019\\Professional\\MSBuild\\Current\\Bin\\MSBuild.exe";
				if (!exists(msbuildpath)) {
					msbuildpath = msbuildroot ~ "Microsoft Visual Studio\\2017\\Enterprise\\MSBuild\\15.0\\Bin\\MSBuild.exe";
					if (!exists(msbuildpath)) {
						msbuildpath = msbuildroot ~ "Microsoft Visual Studio\\2017\\Professional\\MSBuild\\15.0\\Bin\\MSBuild.exe";
						if (!exists(msbuildpath)) {
							writeln("Unable to locate a suitable MSBuild.");
							return;
						}
					}
				}
			}
		}
	}

	alterHeader("sqltypes");
	alterHeader("sql");
	alterHeader("sqlucode");
	alterHeader("sqlext");

	string vcvarspath = buildNormalizedPath(dirName(msbuildpath), "..\\..\\..\\", "VC", "Auxiliary", "Build", "vcvarsall.bat");
	runCommand(i"\"$(vcvarspath)\" x86 && cl /P /C source\\odbc32.c -Figenerated\\odbc32.i".text, getcwd());
	runCommand(i"\"$(vcvarspath)\" x86 && cl /P /C source\\odbc64.c -Figenerated\\odbc64.i".text, getcwd());

	alterIntermediateFile("odbc32");
	alterIntermediateFile("odbc64");

	runCommand(i"\"$(vcvarspath)\" x86_amd64 && dmd generated\\odbc32.i -Hf=etc\\c\\odbc\\odbc32.d -verrors=0 -main".text, getcwd());
	runCommand(i"\"$(vcvarspath)\" x86_amd64 && dmd generated\\odbc64.i -Hf=etc\\c\\odbc\\odbc64.d -verrors=0 -main".text, getcwd());

	alterDFile("odbc32");
	alterDFile("odbc64");

	runCommand("git reset --hard HEAD", specPath);
}

private void runCommand(string command, string workDir) {
	writeln(command);
	auto gitpid = pipeShell(command, Redirect.all, null, Config.none, workDir);
	wait(gitpid.pid);
	foreach (line; gitpid.stdout.byLine) writeln(line);
	foreach (line; gitpid.stderr.byLine) writeln(line);
	writeln();
}

private void alterHeader(string fileName) {
	string headerPath = buildNormalizedPath(getcwd(), "spec", "Windows", "inc", fileName ~ ".h");
	string result = string.init;
	auto header = File(headerPath, "r");

	bool skipMultiline = false;
	foreach (line; header.byLine()) {
		string tline = line.text.strip();

		//Skip these Windows specific lines
		if (tline.canFind("#pragma") && tline.canFind("region")) continue;
		if (tline.canFind("WINAPI_FAMILY_PARTITION")) continue;
		if (tline.canFind("<winapifamily.h>")) continue;

		//Skip multi-line enums
		if (tline.strip().length > 0 && tline.strip()[$-1] == '\\') {
			skipMultiline = true;
			continue;
		} else if (skipMultiline) {
			skipMultiline = false;
			continue;
		}

		if (tline.canFind("<sqlext.h>")) {
			tline = tline.replace("<", "\"").replace(">", "\"");
		}

		if (tline.canFind("#define") && tline.canFind("SQL_")) {
			tline = "//" ~ tline;
		}

		if (tline.canFind("#define OBDCVER")) {
			tline = "//" ~ tline;
		}

		result ~= tline ~ "\n";
	}

	auto output = File(headerPath, "w");
	output.write(result);
	output.flush();
	output.close();
}

private void alterIntermediateFile(string fileName) {
	string intermediatePath = buildNormalizedPath(getcwd(), "generated", fileName ~ ".i");
	string result = string.init;

	auto intermediate = File(intermediatePath, "r");
	bool skipUnusedTypes = false;
	bool skipDeprecated = false;
	foreach (line; intermediate.byLine())
	{
		if (line.strip() == string.init) continue;
		if (line.canFind("#define SQL_API")) continue;

		if (line.canFind("//#define") && line.canFind("SQL_")) {
			line = line[2..$];
		}

		if (line.canFind("#line 122") && line.canFind("sqltypes.h")) skipUnusedTypes = true;
		if (skipUnusedTypes && line.canFind("RETCODE")) skipUnusedTypes = false;
		if (skipUnusedTypes) continue;

		if (line.canFind("#line 2278") && line.canFind("sqlext.h")) skipDeprecated = true;
		if (line.canFind("#line 2380") && line.canFind("sqlext.h")) skipDeprecated = false;
		if (skipDeprecated) continue;

		result ~= line ~ "\n";
	}
	result ~= "#pragma pack(pop)" ~ newline;
	intermediate.close();

	auto output = File(intermediatePath, "w");
	output.write(result.replace("SQL_API ", string.init));
	output.flush();
	output.close();
}

private void alterDFile(string fileName) {
	string diPath = buildNormalizedPath(getcwd(), "etc", "c", "odbc", fileName ~ ".d");
	string result = string.init;

	auto difilein = File(diPath, "r");
	int c = 0;
	foreach (line; difilein.byLine())
	{
		if (c == 0) {
			c++;
			continue;
		}

		result ~= line ~ "\n";
	}
	difilein.close();

	result = result.replace("union  intval = void;", "union intval { SQL_YEAR_MONTH_STRUCT year_month = void; SQL_DAY_SECOND_STRUCT day_second = void; }");

	auto output = File(diPath, "w");
	output.writeln(i"module etc.c.odbc.$(fileName);".text);
	output.writeln("public:");
	output.writeln();
	output.write(result);
	output.flush();
	output.close();
}

}
else
{
	static assert("This app can only be run on Windows.");
}