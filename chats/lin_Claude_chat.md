# lin - LLM conversation about backup.sh (Claude)

Tool used: Claude (Anthropic), via claude.ai
Topic: writing and understanding `backup.sh` for our Drupal + Docker project.

## Conversation

**lin:** The project is missing a few small things. One of them is `backup.sh`.
Can you write it?

**Claude:** I wrote `backup.sh` based on the names in Liad's `setup.sh`
(containers `drupal-db` and `drupal-web`, database `drupal`, user `root`).
The script:
1. Checks that both containers are running, otherwise it asks to run `./setup.sh`.
2. Backs up the database with `docker exec drupal-db pg_dump -U root drupal`
   into `drupal_db_backup.sql`.
3. Backs up the Drupal sites folder with
   `docker exec drupal-web tar czf - -C /var/www/html sites`
   into `drupal_sites_backup.tar.gz`.
4. Prints `[OK]` / `[ERROR]` messages and lists the created files.

**Claude (warnings):** Running the script overwrites the existing backup files,
so do not run it on an empty site, or a good backup will be replaced by an empty
one. Before running, check `docker ps`, then `chmod +x backup.sh` and
`bash -n backup.sh` to check the syntax.

**lin:** How do I upload it to Git?

**Claude:**
```bash
git add backup.sh
git commit -m "Add backup.sh script"
git push
```

## What I learned
- `pg_dump` exports a PostgreSQL database to a SQL file, and it must run
  inside the container through `docker exec`.
- `tar` over `docker exec` backs up the Drupal sites folder (settings and files).
- Changes in the website live in the database, so a new backup is needed
  for them to reach Git.
- A script should check that its prerequisites exist (running containers)
  and print clear messages.
