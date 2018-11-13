const net = require('net');
const server = require('http').createServer();
const io = require('socket.io')(server, {
    origins: '*:*',
    serveClient: false,
    pingInterval: 10000,
    pingTimeout: 5000,
    cookie: false
});
const ports = {
    socketio: 9001,
    hook_server: 9000
};
const rooms = ["commands", "login"];
io.on('connection', socket => {
    socket.on('join', room => {
        if (rooms.includes(room)) {
            console.log("user joined room: " + room);
            socket.join(room);
        } else {
            console.log("wrong room");
            socket.emit("exception", "wrong room");
        }
    });
    socket.on('leave', room => {
        if (rooms.includes(room)) {
            socket.leave(room, () => {
            });
            console.log("user left %s" % room);
        } else {
            console.log("wrong room");
            socket.emit("exception", "wrong room");
        }
    });
});


const local_hook_server = net.createServer((sock) => {
    sock.on('data', data => {
        try {
            let js = JSON.parse(data);
            let event = js["event"];
            console.log(event);
            switch (event) {
                case "commands":
                    io.sockets.to("commands").emit("commands", JSON.stringify(js));
                    break;
                case "login":
                    io.sockets.to("login").emit("login", JSON.stringify(js));
                    break;
                default:
                    break;
            }
        } catch (e) {
            console.error(e);
            console.error(data.toString('utf8'));
        }
    });
});

server.listen(ports.socketio, () => {
    console.log("Socketi.IO is listening on port: " + ports.socketio);
});
local_hook_server.listen({port: ports.hook_server}, () => {
    console.log("Hook Server is listening on port: " + ports.hook_server);
});