const http = require('http');
const hostname = '0.0.0.0';
const port = 3000;


const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end('Hello World!');
});

server.on('request', (request, response) => {
  let body = [];
  request.on('data', (chunk) => {
    body.push(chunk);
  }).on('end', () => {
    body = Buffer.concat(body).toString();

    console.log(`==== ${request.method} ${request.url}`);
    console.log('> Headers');
    console.log(request.headers);

    console.log('> Body');
    console.log(body);
    response.end();
  });
}).listen(port, hostname);
