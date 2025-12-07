# PSF Use Cases

## Registration

Athletes and coaches register for PSF using a system external to PSF. Athletes provide the following information:

- Last Name (surname/family name)
- First Name (given name)
- Date of birth
- Gender
- Rank
- Weight
- Team
- Seed
- Event(s) to compete in (competition level)

Coaches provide the following

- Last Name (surname/family name)
- First Name (given name)
- School
- Coaching level

## Brackets

Brackets are formualated for each division in each event. Seeding data are used to rank the contestants, and the following "randomization" algorithm shall be employed to avoid team kills.

- Rank all teams by number of participants with equivalent seeding
- Partition the group in two, with the largest team in one partition and the 2nd largest in the other partition
  - If one team has more than half the group, let the remainder spill over into the other partition
- For each member of the 1st partition, select a member of the 2nd partition that is NOT on the same team
  - If there are no other choices proceed with the team kill
