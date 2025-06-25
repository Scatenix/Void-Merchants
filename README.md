Unfinished Readme.
Just some quick notes for now.

Currently about 2000 tokens left for the game code.

In it's current state, the game consumes
- never more than 300 KiB ram
- for max 15 enemies at lvl 20 in one screen: rarely more than 0.3 CPUs (a score of > 1.0 = game slowdown)
    - 15 enemies at the same time is almost unplayable because of the difficulty
    - Theoretically, 20 enemies at the same time are possible, but it's unlikely and I won't bother with it for now

Currently known bugs:
- Minor: Sounds or music sometimes skips
    - Unavoidable at the moment because of only 4 sound channels. Game design would need to improve here.
- Not a bug but important: Explain short names like wps, sts, and so on
- Not a bug but important: Explain controls (move, shoot, advance dialog)
