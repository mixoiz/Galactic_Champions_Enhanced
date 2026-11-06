# Ultimate Tournament 1

Extract the ZIP completely, then open `Galactic-Champions-Modded-eng/game.swf` in Ruffle. Keep the SWF, config, texts, and aliens folders together. The new tournament is the ninth selection, after the eight original tournaments.

## Implemented rules

- Omnitrix level 25 required.
- Entry costs 10,000 coins, charged once when accepting the tournament. Canceling team selection, leaving, or losing does not refund it. Later rounds do not charge again.
- Four knockout matches. The existing tournament loss flow eliminates the player and returns to the map; it has no retry button.
- Player team: 1–4 aliens, following the existing final tournaments' team limit.

| Match | Opponent lineup, in order | Coins for winning |
|---|---|---:|
| 1 | Four random level-25 aliens | 1,000 |
| 2 | Three random level-25 aliens, one random level-26 alien | 2,000 |
| 3 | Two random level-25 aliens, two random level-26 aliens | 4,000 |
| Final | Three random level-26 aliens, then level-27 Splixson | 8,000 |

Random selections use the game's existing weighted, available alien pool at level 25. Teams have distinct species. Splixson is excluded from all random slots. His final slot is reserved until the three support aliens are defeated, including protection from random forced switching. Other opponents have zero added training; no extra training requirement was specified for them.

Splixson uses 100% of his normal level-27 Strength, Defense, and Agility training allowance. Engine-verified stats: **HP 163, MP 135, Strength 171, Defense 171, Agility 199**. HP and MP have no artificial boost. Training is capped at level 27, not level 99.

Rewards are coins only: no player XP, alien XP, items, alien unlocks, medal, or additional completion payment. All four wins total 15,000 coins, for a net gain of 5,000 after entry. Existing reward bonus effects cannot increase these payouts. As in the original game, won coins are accumulated in the saved pending rewards and credited through the map reward flow when the player returns, including after elimination. The selection screen displays the 15,000 total.

The selection cover uses Splixson's existing animated vector idle pose from `aliens/splixson.swf`. It reuses the first tournament's planet background. The new heading uses a system font because the modified embedded title font maps the digit 1 to an accented letter.

## Preservation and changes

All eight original tournament configuration objects are unchanged. All other original configuration sections and `config.xml` are unchanged. Original asset files, including the alien animation files, are unchanged except for `tournamentselection.swf`, which adds the new cover frame and copies the existing vector artwork into its own unused character IDs.

The existing improved AI `ChooseAction` method is unchanged. Only its next-alien choice gains a rule for reserving this tournament's final boss. The original tournaments retain their original entry-fee behavior, prizes, cards, and opponent generation.

Changed files: `game.swf`, `tournamentselection.swf`, `config/config.json`, and the three `texts/texts-*.xml` files. The added name is English in all three text files; this remains the English game package.

Six ActionScript classes were patched: `battle.Tournament` (fixed rewards and opponent pool), `battle.Battle` (fixed payout and boss switch protection), `players.AIPlayer` (boss reservation), `ui.UITournamentSelection` (new card, heading, fee), `ui.UIMap` and `ui.UIFixture` (retain eight collectible cards and the original eight-card achievement threshold). Reviewable sources are in `mod-source/`.

## Verification and limits

- Recompiled the modified classes with the installed JPEXS FFDec 26.4.0, then re-exported the resulting SWF for inspection.
- Compared original and edited configuration and original files; only the six files listed above changed.
- Verified the existing AI's complete `ChooseAction` source is unchanged after recompilation.
- Opened the edited game in installed Ruffle 0.7.1, visually checked the ninth card, animated Splixson artwork, title, requirements, total prize, team selection, and 16-team/four-round bracket.
- A separate instrumented test build ran the real game code across 250 randomized brackets (4,000 opponent slots), checking levels, distinct valid species, Splixson placement, exact round rewards, no extra completion prizes, and level-27 stat caps. It also checked repeated fee calls, reward bonus handling, and generation/prizes of all eight original tournaments.
- Test configuration used a separate save name. No test save, boosted starting resources, diagnostics overlay, or instrumented SWF is included in the release.

A complete four-battle manual playthrough, every combat/status-effect interaction, and other Flash runtimes were not tested. The existing loss/map flow was inspected in code; a full played defeat was not exercised. Because there is no medal prize, this tournament does not add a collectible card or a permanent tournament-won marker. Existing save compatibility is retained by keeping the original save name and data format, but save discovery can depend on where a Flash player runs the files.
