# Pilsung Fighter Classes

- Bracket
- Contestant
- Division
- Match
- Ring
- Round

## Bracket

## Contestant

    {
        "id" : <conid>,
        "name" : <name>,
        "gender" : f | m,
        "age" : <age>,
        "weight" : <weight>,
        "rank" : <rank>,
    }

## Match

    {
        "id" : <mid>,
        "chung" : {
            "contestant" : <conid>,
            "score" : {
                "presentation" : <presentation>,
                "technical" : <technical>,
                "deduction" : <deduction>,
                "decision" : <decision>,
            }
        }
        "hong" : <conid>
    }

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
