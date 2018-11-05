#!/bin/bash

usage() {
cat <<EOF
Usage: redmine_bak [ -r | -h ] [commit msg]

-r --restore

-h --help

EOF
exit $1
}

DATABASE=`cat /etc/redmine/default/database.yml | sed -rn 's/ *database: (.+)/\1/p'`
USERNAME=`cat /etc/redmine/default/database.yml | sed -rn 's/ *username: (.+)/\1/p'`
PASSWORD=`cat /etc/redmine/default/database.yml | sed -rn 's/ *password: (.+)/\1/p'`
FILES=/var/lib/redmine/default/files
cd /root/redmine

# Help
if [ "$1" = "-h" -o "$1" = "--help" ]; then
  usage 0

# Restore
elif [ "$1" = "-r" -o "$1" = "--restore" ]; then
  /usr/bin/mysql --user=${USERNAME} --password=${PASSWORD} $DATABASE < redmine.sql
  cp -f [!r][!e][!d][!m][!i][!n][!e]* $FILES

# Backup
else
  if [ "$1" ]; then MSG="$@"; else MSG="`date`"; fi
  /usr/bin/mysqldump --user=${USERNAME} --password=${PASSWORD} --skip-extended-insert $DATABASE > redmine.sql
  cp -f ${FILES}/* .
  git add *
  git commit -m "$MSG" 
  git push --all origin

fi
