<div align="center">

<img src="https://github.com/SPiceZ21/spz-core-media-kit/raw/main/Banner/Banner%232.png" alt="SPiceZ-Core Banner" width="100%"/>

<br/>

# spz-progression
> XP, SR, iRating, ranks, license promotion · `v1.1.9`

## Scripts

| Side   | File                   | Purpose                                           |
| ------ | ---------------------- | ------------------------------------------------- |
| Shared | `shared/init.lua`      | Shared initialization and type definitions        |
| Shared | `points.lua`           | Points-to-XP conversion table                    |
| Shared | `ranks.lua`            | Rank thresholds and display data                  |
| Shared | `licenses.lua`         | License promotion criteria                        |
| Server | `@oxmysql`             | oxmysql database library import                   |
| Server | `config.lua`           | Progression configuration and multipliers         |
| Server | `server/main.lua`      | Entry point, race result listener, export registration |
| Server | `xp.lua`               | XP award and levelling logic                      |
| Server | `points.lua`           | Championship points calculation                   |
| Server | `sr.lua`               | Safety Rating (SR) calculation and clamping       |
| Server | `irating.lua`          | iRating Elo-style calculation                     |
| Server | `ranks.lua`            | Rank promotion and demotion                       |
| Server | `promotion.lua`        | License promotion evaluation and grant            |
| Server | `season.lua`           | Season reset and archiving                        |
| Client | `client/main.lua`      | Progression event handling and UI feedback        |

## Dependencies
- spz-lib
- spz-core
- spz-identity
- spz-races

## CI
Built and released via `.github/workflows/release.yml` on push to `main`.
