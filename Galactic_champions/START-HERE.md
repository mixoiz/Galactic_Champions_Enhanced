# Two game editions

Extract each ZIP into its own folder. Open its `game.swf` in Ruffle, then choose **NEW GAME** to initialize that edition. Use **CONTINUE** afterward to keep your test progress. Starting a new game again resets that edition to its starting setup.

Both editions include Ultimate Tournament 1, the eight original tournaments, and the existing improved AI. Each edition uses a different save name from the normal game and from the other edition.

## Everything Unlocked

- 1,000,000 coins.
- Omnitrix level 99.
- All 11 playable aliens in the uploaded package, each level 99 with full level-99 training in Strength, Defense, and Agility.
- 99 of each of the 24 configured item types.
- All eight original trophy cards.
- Tutorial skipped. Watch styles are already selectable in the original game.

The configuration mentions 26 species, but the uploaded package only supplies combat SWFs for 11. The remaining species are not unlocked because their missing assets would prevent battles from loading. All supplied playable species are included.

## Empty Start

- Omnitrix level 1, zero XP.
- Zero coins, zero items, and zero trophy cards.
- No aliens at the beginning; use the normal tutorial to select your first starter alien.
- All normal progression and tournament entry requirements apply. Ultimate Tournament 1 requires Omnitrix level 25 and 10,000 coins.

“Empty” refers to a fresh progression state. The starter-selection tutorial remains so this copy can be played normally.

## Checks

The Everything Unlocked initialization was compiled and re-exported for inspection. The seed is applied only by NEW GAME; CONTINUE loads saved progress normally. The Empty Start executable is identical to the previously delivered tournament build. Both copies retain all nine tournament configuration entries unchanged. All 11 unlocked aliens have matching combat assets. These two new starting profiles have not received an additional manual gameplay playthrough.

The existing Ultimate Tournament implementation notes are included in both archives. Their statements about ordinary starting resources describe the original tournament release; the edition-specific starting resources above take precedence for these copies.
