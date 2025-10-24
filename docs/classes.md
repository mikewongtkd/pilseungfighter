# Pilsung Fighter Classes

- Bracket
- Clock
  - Update
- Contestant
- Division
- Match
  - Round
- Ring
- Round
- Score
  - Update

## Clock

    {
        "name" : <name:text>,
        "start" : <start:timestamp>,
        "finish" : <finish:timestamp>,
        "duration" : <seconds:float>,
        "current" : <seconds:float>,
        "status" : ready | running | paused | expired
    }

## Clock::Update

    {
        "clock" : <Clock>,
        "at" : <seconds:float>,
        "action" : start | pause | resume | reset
    }

## Contestant

    {
        "name" : <name:text>,
        "gender" : f | m,
        "age" : <age:int>,
        "weight" : <weight:float>,
        "rank" : <rank:text>,
        "seed" : <seed:float>
    }

## Division

    {
        "id" : <divid:text>,
        "name" : <name:text>,
        "method" : <method:text>,
        "gender" : f | m | null,
        "age" : [ <min:int> | null, <max:int> | null ],
        "weight" : [ <min:float> | null, <max:float> | null ],
        "rank" : [ <rank:text>, ... ],
        "contestant" : [ <Contestant>, ... ],
        "round_count" : <count:int>,
        "round_duration" : <seconds:float>,
        "rest_duration" : <seconds:float>,
        "head_contact" : full | light | none,
        "notes" : <notes:text>
    }

## Division::Round

    {
        "name" : <name:text>,
        "code" : <code:text>,
        "order" : <order:int>,
        "division" : <Division>,
        "contestant" : [ <Contestant> ]
    }

## Match

    {
        "id" : <mid:int>,
        "number" : <number:int>,
        "division" : <Division>,
        "ring" : <Ring> | null,
        "round" : <Round>,
        "contestant" : [ <Contestant> | null, <Contestant> | null ],
        "winner" : chung | hong,
        "start" : <start:timestamp> | null,
        "finish" : <finish:timestamp> | null,
    }

## Match::Round

    {
        "match" : <Match>,
        "number" : <rnum:int>,
        "clock" : <Clock>,
        "kyeshi" : <Clock>,
        "medical" : <Clock>,
        "chung" : <Score>,
        "hong" : <Score>,
        "winner" : chung | hong,
        "current" : <current:boolean>,
    }

## Ring

    {
        "name" : <name:text>,
        "number" : <number:int>,
    }

External references

- Bracket
- Division
- Match

## Score

    {
        "contestant" : <Contestant> | null (bye),
        "presentation" : <presentation:float>,
        "technical" : <technical:float>,
        "deduction" : <deduction:float>,
        "penalty_timer" : <Clock>,
        "decision" : bye | dsq | wdr | rsc | null
    }

## Score::Update

    {
        "score" : <Score>,
        "from" : j1 | j2 | j3 | j4 | j5 | co | pc,
        "to" : chung | hong,
        "presentation" : <presentation:float>,
        "technical" : <technical:float>,
        "deduction" : <deduction:float>,
        "decision" : dsq | wdr | rsc | clear | null
    }

**co**: Computer Operator
**ap**: Autopilot

There are two scoring methods:

1. Judges only (Presentation)
2. Judges and PSS (Presentation and Technical)

### Presentation

If the scoring is *Judges only*, then presentation ranges from 0.0 to 10.0 (1 decimal precision, but displayed with 2 decimal precision). Otherwise, presentation is weighted by 60% and rounded to 2 decimal precision.

Judges scores start at 8.0 and drops to 4.0 over time. The rate of loss is inversely proportional to the duration of the match. If the match lasts 20 seconds, then the rate is 4.0/20 = 0.2 points per second = 0.1 points per half-second. If the match lasts 30 seconds then the rate = 4.0/30 = 0.133 points per second, or 0.1 points every 0.75 seconds.

Judges may reward or penalize contestants in 0.1 increments based on specific criteria at any time during the match.




| Column  | Type | Default | Description   |
| ------- | ---- | ------- | ------------- |
| uuid    | text | autogen | Unique ID     |
| type    | text | none    | Document type |
| data    | text | '{}'    | Document data |
| created | text | now()   | Timestamp     |
| deleted | text | null    | Timestamp     |
