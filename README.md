# Liad_Lin_Ravid_Final-Project

## Who we are
Team of three students in the Dev Tools course (Summer 2026):
- **Liad salhi** - team leader
- **Lin sabag**
- **Ravid amar**

## What we were asked to do
Build a Drupal website containing the course glossary terms, running entirely
on Docker:
- A PostgreSQL container and a Drupal container on a shared Docker network
- Configure Drupal (language, DB connection, site name, admin and team users)
- Create content from the course glossary
- Back up the database and site files, and restore them on a different Linux machine
- Automate everything with scripts: `setup.sh`, `backup.sh`, `restore.sh`, `cleanup.sh`
- Store everything in a shared Git repository, with a README and a `chats` folder
  documenting LLM usage

## What we did
1. Created a Docker network and ran PostgreSQL and Drupal containers (`setup.sh`)
2. Installed Drupal through the browser, connected it to PostgreSQL, and created
   the `demoadmin` administrator and a user account for each team member
3. Created a `Term` content type and added 19 glossary terms
4. Backed up the database (`drupal_db_backup.sql`) and the Drupal `sites` folder
   (`drupal_sites_backup.tar.gz`)
5. Wrote `backup.sh` and `restore.sh` to back up and restore the data
6. Wrote `cleanup.sh` to remove all containers, volumes, images and the network
7. Wrote this README and documented our LLM conversations in the `chats` folder

## Technologies
- Docker
- Drupal (latest image)
- PostgreSQL (latest image)
- Bash scripting
- Git and GitHub
- Ubuntu Linux

## Repository contents
| File | Purpose |
|---|---|
| `setup.sh` | Creates the network, pulls images, runs the DB and Drupal containers |
| `backup.sh` | Backs up the database and the Drupal sites volume |
| `restore.sh` | Restores the database and sites files from the backups |
| `cleanup.sh` | Removes all containers, volumes, images and the network |
| `drupal_db_backup.sql` | PostgreSQL database backup |
| `drupal_sites_backup.tar.gz` | Backup of Drupal's `sites` folder |
| `chats/` | Documentation of our LLM conversations |

## Names used in the project
| Item | Name |
|---|---|
| Docker network | `drupal-net` |
| Database container | `drupal-db` |
| Drupal container | `drupal-web` |
| Database volume | `drupal-db-data` |
| Sites volume | `drupal-sites` |
| Database name | `drupal` |
| Site address | http://localhost:8080 |

## Step-by-step: restore the site on a clean Linux machine

### Prerequisites
Linux with Docker and Git installed:
```bash
sudo apt update
sudo apt install -y git docker.io
```

### 1. Clone the repository
```bash
git clone <repository address>
cd Liad_Lin_Ravid_Final-Project
```

### 2. Make the scripts executable
```bash
chmod +x *.sh
```

### 3. Build the Docker infrastructure
```bash
./setup.sh
```
This creates the `drupal-net` network, downloads the latest `postgres` and `drupal`
images, and starts both containers. Wait for the message `Setup complete`.

### 4. Restore the data
```bash
./restore.sh
```
This loads the database backup into PostgreSQL and restores the Drupal sites files.

### 5. Open the site
Browse to http://localhost:8080 and verify that the site opens and the
19 glossary terms appear.

### 6. Log in
- Username: `demoadmin`
- Password: `secretpass`

### 7. (Optional) Create a new backup
```bash
./backup.sh
```

### 8. Clean up the machine
```bash
./cleanup.sh
```
This removes the Drupal and database containers, the volumes, the downloaded
images and the Docker network, leaving the machine as it was before.

Verify with:
```bash
docker ps -a
docker volume ls
docker network ls
```

## Additional information
- All scripts print status messages (`[OK]`, `[--]`, `[..]`) so the user can
  follow each step.
- `setup.sh` and `cleanup.sh` are safe to run more than once: they check whether
  each item exists before creating or removing it.
- If port 8080 or 5432 is already in use on the machine, stop the other service first.
- Our LLM conversations are saved in the `chats` folder.
