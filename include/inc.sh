#!/bin/bash

source /etc/profile



source $SCRIPTS/functions/archive.sh
source $SCRIPTS/functions/archive_full.sh

source $SCRIPTS/functions/backups.sh
source $SCRIPTS/functions/backups_full.sh

source $SCRIPTS/functions/backups_input.sh
source $SCRIPTS/functions/backups_input_full.sh

source $SCRIPTS/functions/files.sh
source $SCRIPTS/functions/files_full.sh

source $SCRIPTS/functions/functions.sh
source $SCRIPTS/functions/git.sh
source $SCRIPTS/functions/menu.sh

source $SCRIPTS/functions/mysql.sh
source $SCRIPTS/functions/mysql_full.sh

source $SCRIPTS/functions/mysql_input.sh
source $SCRIPTS/functions/search.sh
source $SCRIPTS/functions/sites.sh
source $SCRIPTS/functions/sites_input.sh

source $SCRIPTS/functions/ssh.sh
source $SCRIPTS/functions/ssh_full.sh

#source $SCRIPTS/functions/ssh.sh
source $SCRIPTS/functions/ufw.sh

source $SCRIPTS/functions/users.sh
source $SCRIPTS/functions/users_full.sh

source $SCRIPTS/functions/users_input.sh
source $SCRIPTS/functions/users_input_full.sh

source $SCRIPTS/functions/webserver.sh
source $SCRIPTS/functions/webserver_full.sh

source $SCRIPTS/external_scripts/dev-shell-essentials-master/dev-shell-essentials.sh
