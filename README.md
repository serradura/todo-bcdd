# README

* System dependencies
  * Ruby `3.1.2`
    * bundler `>= 2.3.13`
  * Node.js `>= 16.13.2`
    * npm `>= 8.0`
    * yarn `>= 1.22.0`
  * PostgreSQL

* Configuration
  1. Install the system dependencies
  2. Configure `config/database.yml`
  3. Create the `master.key`
    ```sh
    echo '5e551f38b98371e0950af2403898ddf0' > config/master.key

    chmod 600 config/master.key
    ```
  4. Run `bin/setup` (the PostgresSQL must be up and running)

* Database creation
  * Run `bin/rails db:setup`

* How to run the test suite
  * `bin/rails spec`

* How to run the application locally
  1. `bin/dev`
  2. Open in your browser: `http://localhost:3000`
