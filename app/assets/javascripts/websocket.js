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


  var vbm = new WebSocket('ws://localhost:3000/vbm');

  vbm.onopen = function(message) {
    console.log('connected to vbm');
    vbm.send(JSON.stringify({event: 'ping', some: 'data from client'}));
  }

  vbm.onmessage = function(message) {
    var vbm = document.getElementById("vbm");
    var lines = vbm.value.split(/\r\n|\r|\n/);

    if (lines.length > 10)
    {
      lines.splice(0,1);
    }

    lines.push(JSON.parse(message.data));
    vbm.value = lines.join('\n')
  }

  // TODO Implement on the backend
  vbm.onerror = function(message) {
    console.error('channel', JSON.parse(message.data));
  }







}
