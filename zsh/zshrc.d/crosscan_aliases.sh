# Crosscan related aliases
[ -f "${HOME}/.CROSSCAN_ENV_CONFIGURATION" ] && source "${HOME}/.CROSSCAN_ENV_CONFIGURATION"
## Connect

### Connect to mysql readonly slave
alias mysqlro="mysql -A -h ${crosscan_mysql_readonly_host} -D${crosscan_connect_database} -u${crosscan_mysql_readonly_username} -p${crosscan_mysql_readonly_password}"
alias mysqlwrite="mysql -A -h ${crosscan_mysql_write_host} -D${crosscan_connect_database} -u${crosscan_mysql_write_username} -p${crosscan_mysql_write_password}"

