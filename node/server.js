var app = require('express')();
var http = require('http').Server(app);
var io = require('socket.io')(http);
var httpProxy = require('http-proxy');

//新建一个代理 Proxy Server 对象
var proxy = httpProxy.createProxyServer({});
//捕获异常
proxy.on('error',
	function(err, req, res) {
		res.writeHead(500, {
			'Content-Type' : 'text/plain'
		});
		res.end('Something went wrong. And we are reporting a custom error message.');
	});

app.get('/eye/*', function(req, res){
	// 在这里可以自定义你的路由分发
	var host = req.headers.host, ip = req.headers['x-forwarded-for']
			|| req.connection.remoteAddress;
	console.log("client ip:" + ip + ", host:" + host);
	switch (host) {
	case 'solr.qhkly.com':
	case 'neo4j.qhkly.com':
		proxy.web(req, res, {
			target : 'http://192.168.0.96:8008/eye/'
		});
		break;
	default:
		res.writeHead(200, {
			'Content-Type' : 'text/plain'
		});
		res.end('Welcome to my server!');
	}
});
app.get('/', function(req, res){
  res.sendFile(__dirname + '/index.html');
});

io.on('connection', function(socket){
  console.log('a user connected');
  socket.emit('get room');
  socket.on('subscribe', function(data) {
	  console.log('subscribe ' + data.room);
	  socket.join(data.room);
  });
  socket.on('unsubscribe', function(data) {
      console.log('unsubscribe ' + data.room);
      socket.leave(data.room);
  });
  socket.on('disconnect', function(){
	  console.log('user disconnected');
  });
  socket.on('chat message', function(msg){
//	  //给除了自己以外的客户端广播消息
//	  socket.broadcast.emit("msg",{data:"hello,everyone"}); 
//	  //给所有客户端广播消息
//	  io.sockets.emit("msg",{data:"hello,all"});
//	  //不包括自己
//	  socket.broadcast.to('group1').emit('event_name', data);
//	  //包括自己
//	  io.sockets.in('group1').emit('event_name', data);
//	  //获取所有房间（分组）信息
//	  io.sockets.manager.rooms
//	  //获取此socketid进入的房间信息
//	  io.sockets.manager.roomClients[socket.id]
//	  //获取particular room中的客户端，返回所有在此房间的socket实例
//	  io.sockets.clients('particular room')
	  //给自己所在的rooms发消息
	  for(var room in socket.rooms) {
		  if(room != socket.id){
			  io.to(room).emit('chat message', msg);
		  }
	  }
	  socket.join('cached');
//	  console.log(JSON.stringify(socket.rooms));
//	  io.emit('chat message', msg);
  });
});

http.listen(80, function(){
  console.log('listening on *:80');
});