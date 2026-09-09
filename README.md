# stock db

## Set up
copy `.env.example` to `.env` and set J-Quants API key to `JQUANTS_API_KEY`.

## How to execute batch
### terminal
```
$docker compose run --rm batch python main.py brand
$docker compose run --rm batch python main.py equity_history --days 5
$docker compose run --rm batch python main.py fin_summary --date 2026-09-08
```
