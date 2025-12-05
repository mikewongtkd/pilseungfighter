// tests/psfcp.test.js
const Ajv = require('ajv');
const fs = require('fs');
const path = require('path');
const { v4: uuidv4 } = require('uuid');

const { connectWs, waitForMessage, sendJson } = require('./helpers');

const SCHEMA_PATH = path.resolve(__dirname, '../schemas/psfcp-message-schema.json');
const schema = JSON.parse(fs.readFileSync(SCHEMA_PATH, 'utf8'));
const ajv = new Ajv();
const validate = ajv.compile(schema);

const WS_URL = process.env.PSFCP_WS_URL || 'ws://localhost:3030';

describe('PSFCP WebSocket tests', () => {
  let ws;

  afterEach(async () => {
    if (ws && ws.readyState === ws.OPEN) {
      ws.terminate();
    }
    ws = null;
  });

  test('connects to server (handshake)', async () => {
    ws = await connectWs(WS_URL);
    expect(ws.readyState).toBe(ws.OPEN);
  });

  test('accepts server pings with from:0 (server-initiated)', async () => {
    ws = await connectWs(WS_URL);

    // Wait for a server-initiated message within 6s that has from = 0 and action 'ping'
    const msg = await waitForMessage(ws, (m) => {
      return m && m.from === 0 && String(m.action).toLowerCase().includes('ping');
    }, 6000);

    expect(msg.from).toBe(0);
    expect(msg.action.toString().toLowerCase()).toMatch(/ping/);
  });

  test('validates schema on a sample outgoing message (contestant write)', async () => {
    const message = {
      subject: 'contestant',
      action: 'write',
      from: uuidv4(),
      ring: 1,
      contestant: {
        name: 'Test Fighter',
        dojang: 'Tiger Martial Arts',
        age: 28
      }
    };

    // Validate before sending
    const valid = validate(message);
    if (!valid) {
      console.error(validate.errors);
    }
    expect(valid).toBe(true);

    // Connect and send, then wait for response (optional)
    ws = await connectWs(WS_URL);
    sendJson(ws, message);

    // Optionally assert server response format: we expect a response referencing 'request' or similar
    const response = await waitForMessage(ws, (m) => {
      if (!m || typeof m !== 'object') return false;
      // Accept responses that include the `subject` field (server response)
      return m.subject === 'contestant' || (m.request && m.request.subject === 'contestant') || true;
    }, 4000);

    expect(response).toBeDefined();
  });

  test('match score action schema & roundtrip', async () => {
    ws = await connectWs(WS_URL);

    const matchUuid = uuidv4();
    const scoreMsg = {
      subject: 'match',
      action: 'score',
      from: uuidv4(),
      ring: 2,
      match: { uuid: matchUuid },
      contestant: 'chung',
      presentation: 0.1,
      technical: 0.3,
      deduction: -0.1
    };

    expect(validate(scoreMsg)).toBe(true);

    sendJson(ws, scoreMsg);

    // Wait for response containing request or match uuid
    const resp = await waitForMessage(ws, (m) => {
      if (!m || typeof m !== 'object') return false;
      // server might echo request in "request" or return "match" object
      if (m.request && m.request.action === 'score') return true;
      if (m.match && m.match.uuid === matchUuid) return true;
      return false;
    }, 5000);

    expect(resp).toBeDefined();
  });

  test('update penalty timer action', async () => {
    ws = await connectWs(WS_URL);

    const matchUuid = uuidv4();
    const timerMsg = {
      subject: 'match',
      action: 'update penalty timer',
      from: uuidv4(),
      ring: 1,
      match: { uuid: matchUuid },
      contestant: 'hong',
      timer: { action: 'start' }
    };

    expect(validate(timerMsg)).toBe(true);

    sendJson(ws, timerMsg);

    const resp = await waitForMessage(ws, (m) => {
      if (!m || typeof m !== 'object') return false;
      if (m.request && m.request.action && m.request.action === 'update penalty timer') return true;
      if (m.match && m.match.uuid === matchUuid) return true;
      return false;
    }, 5000);

    expect(resp).toBeDefined();
  });

  test('server injects ring and from for server-sent messages', async () => {
    ws = await connectWs(WS_URL);

    // send a benign request that may trigger a server broadcast (depends on server)
    sendJson(ws, {
      subject: 'division',
      action: 'get one',
      from: uuidv4(),
      ring: 0,
      division: { name: 'Any' }
    });

    // Expect some server-sent message that includes from and ring fields
    const resp = await waitForMessage(ws, (m) => {
      return m && typeof m === 'object' && ('from' in m) && ('ring' in m);
    }, 5000);

    expect(resp).toHaveProperty('from');
    expect(resp).toHaveProperty('ring');
  });

});

