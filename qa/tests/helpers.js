// tests/helpers.js
const WebSocket = require('ws');

function connectWs(url, opts = {}) {
  return new Promise((resolve, reject) => {
    const ws = new WebSocket(url, opts);
    ws.once('open', () => resolve(ws));
    ws.once('error', (err) => reject(err));
  });
}

function waitForMessage(ws, predicate, timeout = 5000) {
  return new Promise((resolve, reject) => {
    const timer = setTimeout(() => {
      ws.removeListener('message', onMsg);
      reject(new Error('timeout waiting for message'));
    }, timeout);

    function onMsg(data) {
      let msg;
      try {
        msg = JSON.parse(data.toString());
      } catch (e) {
        // if invalid JSON, still forward as raw
        msg = data.toString();
      }
      try {
        if (predicate(msg)) {
          clearTimeout(timer);
          ws.removeListener('message', onMsg);
          resolve(msg);
        }
      } catch (err) {
        // predicate threw
      }
    }

    ws.on('message', onMsg);
  });
}

function sendJson(ws, obj) {
  ws.send(JSON.stringify(obj));
}

module.exports = {
  connectWs,
  waitForMessage,
  sendJson
};

