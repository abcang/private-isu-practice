#!/bin/bash
set -eux
set -o pipefail

export PATH="$HOME/.local/go/bin:/home/isucon/go/bin:$PATH"
export GOROOT="$HOME/.local/go"

BRANCH="${1:-"master"}"

cd "$(dirname "$0")"
if [ -d ".git" ]; then
	git fetch
	git checkout "$BRANCH"
	git reset --hard origin/"$BRANCH"
fi

sudo test -f "/var/log/nginx/access.log" && sudo mv /var/log/nginx/access.log /var/log/nginx/access.log.`date "+%Y%m%d_%H%M%S"`
sudo test -f "/var/log/nginx/error.log" && sudo mv /var/log/nginx/error.log /var/log/nginx/error.log.`date "+%Y%m%d_%H%M%S"`
sudo test -f "/var/log/mysql/mysql-slow.log" && sudo mv /var/log/mysql/mysql-slow.log /var/log/mysql/mysql-slow.log.`date "+%Y%m%d_%H%M%S"`

cd golang/
make

hostname="$(hostname)"
case "${hostname}" in
	"118-27-113-127") # nginx + API (File Upload)
		sudo systemctl restart nginx
		sudo systemctl restart isu-go.service
		sudo systemctl restart mysql
	;;
	*)
		echo "${hostname} Didn't match anything"
		exit 1
esac

