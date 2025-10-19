# Pilsung Fighter Communication Protocol (PSFCP)

## Server-Client Communication

Server-Client communication is established using websockets, which may be configured for direct port-to-port communication or via proxy/reverse proxy (for encrypted communications) using the Apache webserver.

The default port for PSFCP is 3030.

Most communication is initiated by a client. Typically a client makes a request to the server to provide some service, and the server provides a response or an error in return.

One notable exception is server pings to gauge client connection strength. 

### Requests

- subject:
- action:
- from: cid
- ring: rnum
- *other parameters as needed*

### Responses

    {
        "request": <request>
        "subject": bracket | contestant | division | match | ring | round,
        <subject>
    }

## Subjects

### Match

A minimal request template is shown below. Requests are based on the minimal template, with the listed *action* specified and additional parameters specified as needed.

**Minimal Request**

    {
        "subject": "match",
        "action": <action>,
        "from": <cid>,
        "ring": <rnum>
    }

#### Match Read

    "action" : "read"

#### Match Score

    "action" : "score",
    "contestant" : chung | hong
    "presentation" : -0.1 | 0.1

#### Match Update

    "action" : "update"
    <parameter to update> : <parameter value>

Examples
