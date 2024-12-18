# AquariumDatabase
PostgreeSQL aquarium database with JAVA interface

---

## Creating the database

### 1. Login in as superuser:

After setting up PostgreeSQL, log in as the superuser
` psql -U postgres`

### 2. Create the database:

As the superuser, create the main database:
```sql
CREATE DATABASE aquarium_db;
```

### 3. Create a new user

Always working as the superuser is unsafe, it is recommended
to create a new user and grant it the needed privileges.
The credentials should match credentials in `src/DataBaseConnection/java`


```sql
CREATE USER judr0384 WITH PASSWORD 'judr0384';
GRANT ALL PRIVILEGES ON DATABASE aquarium_db TO aquarium_user;
```

### 4. Log in as the new user
If still logged on as the superuser (if you see something like `postgres=#` in your terminal),
Quit by typing `\q` and log as the newly created user into the database with:

`psql -U <username> -d <database>`.
In this example the command would look like this:
`psql -U judr0384 -d aquarium_db`.

If logged in successfully, the terminal should have this line:
`aquarium_db=> `

### 5. Run creation scripts

The database creation is split into multiple files: 
* `schema.sql` conatins creation scripts for the structural parts (tables, views).
* `triggers.sql` contains creation scripts for the necessary triggers.
* `test_data.sql` contains inserts of mock data for database testing.

The scripts can be run like this:

`\i <filename>`
In this examlpe the commands would look like this:

```bash
\i sql/schema.sql
\i sql/triggers.sql
\i sql/test_data.sql
```
---