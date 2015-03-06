var wsocks = function(message) {

  var connection = new WebSocket('ws://localhost:3000/channel');

  connection.onopen = function(message) {
    console.log('connected to channel');
    connection.send(JSON.stringify({event: 'ping', some: 'data from client'}));
  }

  connection.onmessage = function(message) {
    console.log('message', JSON.parse(message.data));
  }

  // TODO Implement on the backend
  connection.onerror = function(message) {
    console.error('channel', JSON.parse(message.data));
  }
}
