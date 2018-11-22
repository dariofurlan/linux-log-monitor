const express = require('express');
const bodyParser = require('body-parser');
const hook_server = express().use(bodyParser.json());

const processSomething = callback => {
    setTimeout(callback, 0);
};
hook_server.get('/login', (req, res) => {
    processSomething(()=>{
        io.sockets.to("login").emit("login", JSON.stringify(req));
    });
    res.status(200).send('OK');
});
hook_server.get('/command', (req, res) => {
    processSomething(()=> {
        io.sockets.to("command").emit("command", JSON.stringify(req.query));
    });
    res.status(200).send('OK');
});


const sockio_server = require('http').createServer();
const io = require('socket.io')(sockio_server, {
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
const rooms = ["command", "login"];


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

sockio_server.listen(ports.socketio, () => {
    console.log("Socketi.IO is listening on port: " + ports.socketio);
});
hook_server.listen(ports.hook_server, 'localhost', () => console.log('Hook Server is listening on '+ports.hook_server));

process.on('SIGINT', () => {
    console.info('SIGINT signal received.');
    sockio_server.close((err)=> {
        // if error, log and exit with error (1 code)
        if (err) {
            console.error(err);
            process.exit(1);
        }

        // close your database connection and exit with success (0 code)
    });
    hook_server.close((err)=> {
        if (err) {
            console.error(err);
            process.exit(1);
        }

    });
});