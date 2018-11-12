const net = require('net');

// to send message  from bash
/*
 * echo "{\"event\":\"login\"}" >/dev/tcp/127.0.0.1/9000
 */


const server = net.createServer((sock) => {
    sock.on('data', data => {
        let js = JSON.parse(data);
        console.log(js["event"]);
    });
});

server.listen({port: 9000}, () => {
    console.log('Server is listening');
});