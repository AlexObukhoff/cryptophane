unit Call;

interface

uses SysUtils;

type
  TDataReceivedCallback = procedure(command: string; lineNumber: integer; isFragment: boolean;
                               var write_stdin: THandle; var terminateProgram: boolean) of object;
  TProcessStartedCallback = procedure(var write_stdin: THandle; var terminateProgram: boolean) of object;

  CallProgramException = class(Exception);


function CallProgram(const commandLine: string;
                     out data: string;
                     dataReceivedCallback: TDataReceivedCallback = nil;
                     const dataReceivedCallbackPrefix: string = '';
                     const processStartWriteData: PChar = nil;
                     processStartWriteDataLength: cardinal = 0 
                    ): boolean;

function CommandQuote(s: string; encloseInQuotes: boolean = true): string;

function IsValidFilename(s: string): boolean;


implementation

uses Windows, Classes, Utils;

procedure CloseHandleAndNil(var a: THandle);
begin
  if a <> 0 then
  begin
    CloseHandle(a);
    a := 0;
  end;
end;

function CommandQuote(s: string; encloseInQuotes: boolean): string;
var
  i: integer;
begin
  result := '';
  for i := 1 to Length(s) do
  begin
    if s[i] = '"' then
      result := result + '\"'
    else if (Ord(s[i]) >= 32) then
      result := result + s[i];
  end;

  if encloseInQuotes then result := '"' + result + '"';
end;

function IsValidFilename(s: string): boolean;
var
  i: integer;
begin
  result := false;

  if s = '' then Exit;
  for i := 1 to Length(s) do
  begin
    if (Ord(s[i]) < 32) or (Pos(s[i], #127 + '/"*?|<>') > 0) then Exit;
  end;

  if s = '-' then Exit;
  if (s[1] = ':') or (Pos(':', Copy(s, 3, Length(s))) > 0) then Exit;

  result := true;
end;

function GetLastErrorString(errno: integer): string;
var
  msg: PChar;
begin
  msg := AllocMem(4096);
  try
    FormatMessage(
      FORMAT_MESSAGE_FROM_SYSTEM,
      nil,
      errno,
      LANG_NEUTRAL or (SUBLANG_DEFAULT shl 10), // Default language
      msg,
      4096,
      nil
    );

    result := msg;
  finally
    FreeMem(msg);
  end;
end;

function CallProgram(const commandLine: string;
                     out data: string;
                     dataReceivedCallback: TDataReceivedCallback = nil;
                     const dataReceivedCallbackPrefix: string = '';
                     const processStartWriteData: PChar = nil;
                     processStartWriteDataLength: cardinal = 0
                    ): boolean;
var
  sa: TSecurityAttributes;
//  sd: TSecurityDescriptor;
  si: TStartupInfo;
  pi: TProcessInformation;
  newstdin, write_stdin: THandle;
  newstdout, read_stdout: THandle;
  stdcopy: THandle;
  bufLen, count, exitCode: cardinal;
  buf: PByte;
  bufs: TBytes;
  b: boolean;
  inputLines: TStringList;
  lineFragment, s: string;
  i: integer;
  lineNumber: integer;
  terminate: boolean;
begin
  result := false;
  data := '';
  lineNumber := 0;
  {if Win32Platform = VER_PLATFORM_WIN32_NT then
  begin
    InitializeSecurityDescriptor(@sd, SECURITY_DESCRIPTOR_REVISION);
    SetSecurityDescriptorDacl(@sd, true, nil, false);
    sa.lpSecurityDescriptor := @sd;
  end
  else
  begin
    sa.lpSecurityDescriptor := nil;
  end;}
  sa.nLength := sizeof(SECURITY_ATTRIBUTES);
  sa.bInheritHandle := false;
  sa.lpSecurityDescriptor := nil;
  if not CreatePipe(newstdin, write_stdin, @sa, 0) then Exit;
  if not CreatePipe(read_stdout, newstdout, @sa, 0) then
  begin
    CloseHandle(newstdin);
    CloseHandle(write_stdin);
    Exit;
  end;

  // OK, this is a bit weird, so here it is explained.
  // We want to be able to signal EOF to the process we're about to create.
  // The only way to do that using pipes is to close the pipe handle associated
  // with the input into the process (i.e. write_stdin).  So we create the pipes
  // uninheritable (above), make the half of the pipe that is passed to the
  // process inheritable (otherwise it wouldn't get it), leaving the other half
  // uninheritable.  If we have both sides inheritable, it'll take a copy itself
  // of write_stdin, so when we go to close it the process will still be holding
  // its copy open.

  if not DuplicateHandle(
    GetCurrentProcess, newstdin,
    GetCurrentProcess, @stdcopy,
    0, { ignored }
    true, { inheritable }
    DUPLICATE_CLOSE_SOURCE or DUPLICATE_SAME_ACCESS
  ) then
  begin
    raise CallProgramException.Create(GetLastErrorString(GetLastError));
  end;
  newstdin := stdcopy;

  if not DuplicateHandle(
    GetCurrentProcess, newstdout,
    GetCurrentProcess, @stdcopy,
    0, { ignored }
    true, { inheritable }
    DUPLICATE_CLOSE_SOURCE or DUPLICATE_SAME_ACCESS
  ) then
  begin
    raise CallProgramException.Create(GetLastErrorString(GetLastError));
  end;
  newstdout := stdcopy;

  inputLines := TStringList.Create;
  try
    GetStartupInfo(si);
    si.dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;
    si.wShowWindow := SW_HIDE; //SW_SHOW, SW_HIDE, SW_SHOWMINIMIZED
    si.hStdOutput := newstdout;
    si.hStdError := newstdout;
    si.hStdInput := newstdin;

    if not CreateProcess(
      nil,
      PChar(commandLine),
      nil,
      nil,
      true, { inherit handles }
      CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, {CREATE_NEW_CONSOLE, DETACHED_PROCESS}
      nil,
      nil,
      si,
      pi
    ) then
    begin
      Exit;
    end;

    CloseHandle(newstdin);
    CloseHandle(newstdout);
    newstdin := 0;
    newstdout := 0;

    bufLen := 65536;
    buf := AllocMem(bufLen);
    terminate := false;
    try
      if Assigned(processStartWriteData) then
      begin
        bufs := TEncoding.GetEncoding(CP_UTF8).GetBytes(string(processStartWriteData));

        WriteFile(write_stdin, bufs[0], Length(bufs), count, nil);
        CloseHandleAndNil(write_stdin);
        SetLength(bufs, 0);
      end;

      exitCode := STILL_ACTIVE;
      while exitCode = STILL_ACTIVE do
      begin
        GetExitCodeProcess(pi.hProcess, exitCode);

        b := ReadFile(read_stdout, buf^, bufLen - 1, count, nil);
        if not b then
        begin
          if GetLastError <> ERROR_MORE_DATA then
          begin
            result := true;
            Exit;
          end;
        end;

        // Test for EOF
        if count = 0 then break;

        buf[count] := 0;
        SetLength(bufs, 0);
        SetLength(bufs, count);
        Move(buf[0], bufs[0], count);
        data := data + TEncoding.GetEncoding(CP_UTF8).GetString(bufs);

        if Assigned(dataReceivedCallback) then
        begin
          terminate := false;

          s := lineFragment + TEncoding.GetEncoding(CP_UTF8).GetString(bufs);
          Split(#10, s, inputLines);
          if inputLines.Count > 0 then
          begin
            lineFragment := inputLines[inputLines.Count - 1];
            for i := 0 to inputLines.Count - 2 do
            begin
              Inc(lineNumber);
              if (dataReceivedCallbackPrefix = '') or
                 (Copy(inputLines[i], 1, Length(dataReceivedCallbackPrefix)) = dataReceivedCallbackPrefix) then
              begin
                dataReceivedCallback(StripCR(inputLines[i]), lineNumber, false, write_stdin, terminate);
              end;
            end;

            if (lineFragment <> '') and (
              (dataReceivedCallbackPrefix = '') or
              (Copy(lineFragment, 1, Length(dataReceivedCallbackPrefix)) = dataReceivedCallbackPrefix)
            ) then
            begin
              dataReceivedCallback(lineFragment, lineNumber + 1, true, write_stdin, terminate);
            end;
          end;

          if terminate then
          begin
            CloseHandleAndNil(write_stdin);
            CloseHandleAndNil(read_stdout);
          end;
        end;
      end;
      result := true;

    finally
      if exitCode = STILL_ACTIVE then TerminateProcess(pi.hProcess, 0);
      CloseHandle(pi.hProcess);
      CloseHandle(pi.hThread);
      FreeMem(buf);
    end;

  finally
    inputLines.Free;
    CloseHandleAndNil(newstdin);
    CloseHandleAndNil(newstdout);
    CloseHandleAndNil(write_stdin);
    CloseHandleAndNil(read_stdout);
  end;

end;

end.
