# sender.py
import socket

host = "192.168.1.12"  # Change to listener IP if remote
port = 1337

command = "Start-Process mspaint.exe"

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.connect((host, port))
    s.sendall(command.encode())

print("Command sent.")
