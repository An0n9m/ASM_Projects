// Copyright (C) 2024 An0n9m. All rights reserved.

# Simple HTTP Server

This project implements a basic HTTP server in x86 assembly language. The server listens on port 80 and can handle simple HTTP requests. It supports both `GET` and `POST` methods and demonstrates handling of HTTP requests using low-level system calls.

## Features

- **HTTP GET and POST Handling**: The server can process `GET` and `POST` requests and respond accordingly.
- **Low-Level System Calls**: Demonstrates usage of system calls for socket programming, file operations, and process management.
- **Basic Response Handling**: Responds with a fixed "200 OK" message for requests.

## Prerequisites

- **Assembler**: `as` (GNU Assembler)
- **Linker**: `ld` (GNU Linker)
- **Netcat (nc)**: To send test requests to the server

## Compilation

To compile the server, use the following commands:

```sh
as -o Server.o Server.s
ld -o Server Server.o


## Usage

### 1. Start the Server

Execute the compiled server binary:
./Server

echo -e "GET /home/an0n9m/Text \r\n\r\n Hello World! \n Hacked By An0n9m" | nc 127.0.0.1 80
echo -e "POST /home/an0n9m/Text \r\n\r\n Hello World! \n Written by an0n9m :)" | nc 127.0.0.1 80
echo -e "POST / HTTP/1.1\r\nHost: localhost\r\nUser-Agent: python-requests/2.32.3\r\nAccept-Encoding: gzip, deflate, zstd\r\nAccept: */*\r\nConnection: keep-alive\r\nContent-Length: 121\r\n\r\n SomeText" | nc 127.0.0.1 80

P.S. You can also use telnet and other HTTP clients to test the server's functionality
