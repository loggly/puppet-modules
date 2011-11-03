var net = require("net");
var url = require("url");

function to_dotted_notation(obj, parent_key, result) {
  if (typeof(parent_key) == 'undefined') parent_key = "";
  if (typeof(result) == 'undefined') result = {};

  if (typeof(obj) == 'object') {
    for (var i in obj) {
      var key = parent_key ? (parent_key + "." + i) : i;
      to_dotted_notation(obj[i], key, result);
    }
  } else if (typeof(obj) == 'number') {
    result[parent_key] = obj;
  }
  return result;
}

var stdin = process.openStdin();
var input = "";
stdin.on("data", function(chunk) {
  input += chunk;
});
stdin.on("end", function() {
  data = JSON.parse(input);
  results = to_dotted_notation(data);

  /* TODO(sissel): validate args */
  var targeturl = url.parse(process.argv[2]);
  var host = targeturl.hostname;
  var port = targeturl.port || 2003;
  var prefix = targeturl.pathname.slice(1); /* trim leading '/' */

  /* Only fetch matching keys */
  var args = process.argv.slice(3); /* argv[0] == 'node', argv[1] is script name */

  /* Create a regexp of (arg)|(arg)|(arg)... */
  var pattern = args.map(function(arg) { return "(" + arg + ")" }).join("|");
  var re = new RegExp(pattern);

  var now = Math.floor((new Date()).getTime() / 1000);
  var messages = []
  for (var key in results) { 
    if (re.test(key)) {
      var fullkey = key;
      if (prefix) {
        fullkey = prefix + "." + key;
      }
      messages.push([fullkey, results[key], now].join(" "));
    }
  }

  var graphite = net.createConnection(port, host);
  console.log("Sending to " + host + ":" + port);
  graphite.on('connect', function() {
    for (var i in messages) {
      var m = messages[i].toLowerCase();
      graphite.write(m + "\n");
      console.log(m);
    }
    graphite.end();
  });
});
