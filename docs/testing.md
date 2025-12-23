# **Pilsung Fighter Communication Protocol (PSFCP) – Testing Framework**

This document defines a full testing framework for verifying compliance of a PSFCP-enabled web application (default WebSocket port **3030**) with the expected communication structure, behaviors, subjects, actions, and server–client lifecycle.

---

# **1. Overview**

This testing framework covers:

* WebSocket connectivity & handshake
* Message schema validation
* Subject/action routing
* Universal request behaviors
* Subject-specific behaviors (division, match, etc.)
* Server-initiated events (e.g., pings)
* Error handling and malformed input
* Security, proxying, and port configuration tests

All test cases assume communication over **ws://<host>:3030** unless secured via reverse proxy (Apache).

---

# **2. Testing Environment**

## 2.1 Required Tools

* WebSocket client (e.g., `websocat`, browser WS client, or automated test harness)
* JSON schema validator
* PSFCP test harness (recommended node/python test runner)
* Server logs enabled for debugging

## 2.2 Connection Setup

* Connect to `ws://localhost:3030`
* If Apache → HTTPS proxy: `wss://example.com/psfcp/`

Expected:

* Server acknowledges connection
* Optional: periodic server pings

---

# **3. Testing Categories**

1. **Connectivity Tests**
2. **Schema Validation Tests**
3. **Universal Request Tests**
4. **Subject Action Tests**
5. **Server-Initiated Event Tests**
6. **Error and Edge Case Tests**
7. **Security Tests**

---

# **4. Connectivity Tests**

## **4.1 WebSocket Handshake**

**Test**: Client opens a connection
**Expected**: Connection accepted; server may send optional ping

---

## **4.2 Server Ping Handling**

**Test**: Server sends unsolicited pings
**Expected**:

* Client receives ping
* Ping contains:

  ```
  {
    "subject": "client",
    "action": "ping",
    "from": 0
  }
  ```
* Client responds (if protocol requires)

---

# **5. Schema Validation Tests**

Each incoming/outgoing message must satisfy:

```
{
  "subject": <subject>,
  "action": <action>,
  "from": <cid>,       // injected by server
  "ring": <rnum>,      // injected by server
  ...
}
```

## **Tests**

| Test                    | Description                      | Expected                                    |
| ----------------------- | -------------------------------- | ------------------------------------------- |
| Missing subject         | Send payload without `"subject"` | Server returns error                        |
| Missing action          | Missing `"action"` field         | Server returns error                        |
| Invalid subject         | `"subject": "dragon"`            | Server rejects                              |
| Invalid action          | `"action": "explode"`            | Server rejects                              |
| Unexpected extra fields | Provide unknown fields           | Server ignores or rejects depending on spec |

---

# **6. Universal Request Tests**

Universal actions: **write**, **delete**, **read**, **get one**, **get**

Each PSFCP class must implement `_subject()` and `_factory()`.

---

## **6.1 Write (Create/Update)**

### Create Test

```
{
  "subject": "contestant",
  "action": "write",
  "contestant": { "name": "Test User" }
}
```

**Expected**:

* New UUID assigned
* Returned object contains full contestant record

### Update Test

```
{
  "subject": "contestant",
  "action": "write",
  "contestant": { "uuid": "<existing>", "name": "Updated Name" }
}
```

**Expected**: Success and updated record.

---

## **6.2 Delete**

```
{
  "subject": "division",
  "action": "delete",
  "division": "<uuid>"
}
```

**Expected**: Deletion success or not-found error.

---

## **6.3 Read**

```
{
  "subject": "match",
  "action": "read",
  "match": "<uuid>"
}
```

**Expected**: Match object returned.

---

## **6.4 First (Get One)**

```
{
  "subject": "division",
  "action": "get one",
  "division": { "rank": "1st Dan" }
}
```

**Expected**:

* One object or `null`

---

## **6.5 Search (Get)**

```
{
  "subject": "contestant",
  "action": "get",
  "contestant": { "dojang": "Fresno TKD" }
}
```

**Expected**:

* Array of 0..n matching objects

---

# **7. Subject-Specific Tests**

## **7.1 Division**

### **Add Contestant**

```
{
  "subject": "division",
  "action": "add_contestant",
  "contestant": { "uuid": "<uuid>" }
}
```

**Expected**:

* Contestant successfully added
* Division object returned

---

### **Add Match**

```
{
  "subject": "division",
  "action": "add_match",
  "round": "R1",
  "match": { "chung": "<uuid>", "hong": "<uuid>" }
}
```

**Expected**:

* Match added to round
* Division updated correctly

---

## **7.2 Match**

### **Score**

```
{
  "subject": "match",
  "action": "score",
  "contestant": "chung",
  "presentation": 0.1,
  "technical": 0.3,
  "deduction": -0.1
}
```

**Expected**:

* Score applied to correct contestant
* Updated match object returned

---

### **Update Penalty Timer**

```
{
  "subject": "match",
  "action": "update penalty timer",
  "match": { "uuid": "<uuid>" },
  "contestant": "hong",
  "timer": { "action": "start" }
}
```

**Expected**:

* Timer state updated (start/pause/resume/reset)
* Timer status reflected in match object

---

# **8. Server-Initiated Event Tests**

## **8.1 Server Broadcast**

Test: Server broadcasts division or match updates when triggered.

Expected:

* All connected clients receive synchronous update
* Message includes `"from": 0`

---

## **8.2 Server Ring Assignment Logic**

Test: Server auto-assigns `"ring": <rnum>` appropriately.

Expected:

* Client doesn’t supply ring
* Server always injects it

---

# **9. Error & Edge Case Tests**

| Case                       | Example                              | Expected                                         |
| -------------------------- | ------------------------------------ | ------------------------------------------------ |
| Invalid UUID               | `"match": "not-a-uuid"`              | Error                                            |
| Mismatched subject/action  | `"subject": "match", "division": {}` | Error                                            |
| Simultaneous score updates | Two score msgs within 50ms           | Deterministic ordering                           |
| Empty search params        | `"action": "get", "contestant": {}`  | Full list or error (depending on implementation) |
| Server restarts            | Drop + reconnection                  | State sync on reconnect                          |

---

# **10. Security Tests**

## **10.1 Proxy/Reverse Proxy TLS**

* Validate WSS handshake through Apache
* Confirm HSTS, no mixed content

## **10.2 Malformed JSON**

Send partial or corrupted JSON.

Expected:

* Server responds with error
* Does not crash

## **10.3 Unauthorized Actions**

If authorization layer exists:

* Low-privilege user attempts `"delete"`
* Unauthorized division edits

Expected:

* Rejected with error message

---

# **11. Test Automation Structure**

```
tests/
 ├── connectivity/
 ├── schema/
 ├── universal/
 ├── division/
 ├── match/
 ├── server_events/
 ├── security/
 ├── regression/
 └── helpers/
```

Recommended:

* YAML definitions per test
* Automated JSON schema validation
* WebSocket test driver for replay sequences

---

# **12. Appendix: Sample Valid Response**

```
{
  "request": {
      "subject": "match",
      "action": "score"
  },
  "subject": "match",
  "match": {
      "uuid": "<uuid>",
      "chung_score": { ... },
      "hong_score": { ... }
  }
}
```
