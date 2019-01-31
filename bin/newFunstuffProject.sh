#!/bin/sh

# thanks to thoughtbot laptop script
fancy_echo() {
  local fmt="$1"; shift
  printf "\n$fmt\n" "$0"
}

if [ ! $1 ]; then
  fancy_echo "Please supply a project name"
  exit
fi

fancy_echo "Creating folder structure"
mkdir $1
cd $1
mkdir -pv src/css
mkdir lib

fancy_echo "Creating package.json"
cat << EOF > ./package.json
{
  "name": "$1",
  "description": "Aji codes for fun: $1",
  "version": "1.0.0",
  "main": "index.js",
  "scripts": {
    "test": "mocha ./**/*.test.js",
    "start": "node devServer.js",
    "build": "babel src -d lib"
  },
  "author": "The Stabby Lambdas",
  "license": "MIT"
}
EOF

fancy_echo "Creating index.html"
cat << EOF > ./index.html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width" />
    <script>
      const Game = {};
      Game.setup = () => {};
      Game.loop = () => {};
    </script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/normalize/8.0.1/normalize.min.css" type="text/css" media="screen" title="no title" charset="utf-8">
    <link rel="stylesheet" href="./lib/style.css" type="text/css" media="screen" title="no title" charset="utf-8">
    <title>$1</title>
  </head>
  <body>
    body
    <script src="./lib/index.js"></script>
    <script charset="utf-8">
      window.WebSocket = window.WebSocket || window.MozWebSocket;

      const connection = new WebSocket('ws://127.0.0.1:4077');
      connection.onopen = () => { console.log("open connection") };
      connection.onerror = (err) => { console.log("err!", err) };
      connection.onmessage = message => {
        if (message.data === "update") {
          window.location.href = "http://localhost:4077";
        }
      }

      Game.setup();
      window.setInterval(Game.loop, 20);
    </script>
  </body>
</html>
EOF

fancy_echo "Creating initial js & css files"
cat << EOF > ./src/css/index.scss
body {

}
EOF
cat << EOF > ./src/index.js
const p = document.createElement("p");
p.innerHTML = "Javascript is ready"
document.body.appendChild(p)
EOF

yarn add -D @babel/core @babel/cli @babel/preset-env mocha chai chokidar websocket

fancy_echo "Creating babelrc"

cat << EOF > ./.babelrc
{
  "presets": ["@babel/preset-env"]
}
EOF

fancy_echo "Creating dev Server code"

cat << 'EOF' > ./devServer.js
const chokidar = require("chokidar");
const http = require("http");
const path = require("path");
const fs = require("fs");
const WebSocketServer = require("websocket").server;
const { exec } = require("child_process");

function createWatcher(path) {
  return chokidar.watch(path, {
    ignored: /^node_modules/,
  });
}

function detectedChange(path, type, isRebuilding = true) {
  console.log("\x1b[36m%s\x1b[0m", `\nCHANGE DETECTED in ${path}`);
  if (isRebuilding) {
    console.log("\x1b[33m%s\x1b[0m", `     rebuilding ${type}`);
  }
}

const devServer = {
  connections: [],
  hostname: "localhost",
  port: 4077,
  cssWatcher: createWatcher("./src/css/*.scss"),
  jsWatcher: createWatcher("./src/**/*.js"),
  htmlWatcher: createWatcher("./**/*.html"),
  sendFile: (res, contentType, file) => {
    res.writeHeader(200, {
      "Content-Type": contentType,
    });
    res.write(file);
    res.end();
  },

  loadFile: (path, instance, send = true) => {
    fs.readFile(path, {}, (err, file) => {
      devServer[instance] = file;
      send && devServer.sendUpdateCommand();
    });
  },

  sendUpdateCommand: () => {
    console.log("\x1b[33m%s\x1b[0m", `     sending update command\n`);
    devServer.connections.forEach(con => {
      con.sendUTF("update");
    });
  },

  js: undefined,
  compileJS: (send = true) => {
    exec("npx babel src --out-file lib/index.js", {}, () => {
      devServer.loadFile("./lib/index.js", "js", send);
    });
  },

  css: undefined,
  compileCSS: (send = true) => {
    exec("sass src/css/index.scss:lib/style.css", {}, () => {
      devServer.loadFile("./lib/style.css", "css", send);
    });
  },

  html: undefined,
};

devServer.compileJS(false);
devServer.compileCSS(false);
devServer.loadFile("./index.html", "html", false);

devServer.cssWatcher.on("change", (path, evt) => {
  detectedChange(path, "CSS");
  devServer.compileCSS();
});

devServer.htmlWatcher.on("change", path => {
  detectedChange(path, "HTML", false);
  devServer.loadFile("./index.html", "html");
});

devServer.jsWatcher.on("change", path => {
  detectedChange(path, "JavaScript");
  devServer.compileJS();
});

const server = http.createServer((req, res) => {
  switch (req.url) {
    case "/lib/index.js":
      devServer.sendFile(res, "text/javascript", devServer.js);
      break;

    case "/lib/style.css":
      devServer.sendFile(res, "text/css", devServer.css);
      break;

    case "/":
      devServer.sendFile(res, "text/html", devServer.html);
      break;

    default:
      res.writeHeader(204);
      res.end();
      break;
  }
});

const wsServer = new WebSocketServer({ httpServer: server });

wsServer.on("request", request => {
  if (new RegExp(`/${devServer.hostname}:${devServer.port}`).test(request.origin)) {
    const connection = request.accept(null, request.origin);
    devServer.connections.push(connection);

    console.log(
      new Date() + ": Connection from origin " + request.origin + " accepted",
    );
  }
});

wsServer.on("close", connection => {
  const index = devServer.connections.indexOf(connection);
  devServer.connections.splice(index, 1);
});

server.listen(devServer.port, devServer.hostname, () => {
  console.log(`Server running on http://${devServer.hostname}:${devServer.port}\n`);
});
EOF
