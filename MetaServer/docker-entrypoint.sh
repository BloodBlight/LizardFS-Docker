#!/bin/bash

echo "Starting with argument(s): [$@]" | ts '[%Y-%m-%d %H:%M:%S]'

mkdir -p /etc/lizardfs
mkdir -p /var/lib/lizardfs
mkdir -p /home/LizardFS

if [ -f '/etc/lizardfs/metaserver.cfg' ]; then mv '/etc/lizardfs/metaserver.cfg' '/etc/lizardfs/metaserver.cfg.last'; fi
if [ -f '/etc/lizardfs/exports.cfg' ]; then mv '/etc/lizardfs/exports.cfg' '/etc/lizardfs/exports.cfg.last'; fi
if [ -f '/etc/lizardfs/exports.cfg.tmp' ]; then rm '/etc/lizardfs/exports.cfg.tmp'; fi
if [ -f '/etc/lizardfs/goals.cfg' ]; then mv '/etc/lizardfs/goals.cfg' '/etc/lizardfs/goals.cfg.last'; fi
if [ -f '/etc/lizardfs/goals.cfg.tmp' ]; then rm '/etc/lizardfs/goals.cfg.tmp'; fi

echo "#################################" | ts '[%Y-%m-%d %H:%M:%S]'
echo "Environment Variables:" | ts '[%Y-%m-%d %H:%M:%S]'
echo "---------------------------------" | ts '[%Y-%m-%d %H:%M:%S]'
env | while read -r var ; do
  Prefix=`echo $var | cut -d '-' -f 1`
  if [ "$Prefix" == "LFS_Master" ]; then
    echo $var | cut -d '-' -f 2 >> /etc/lizardfs/metaserver.cfg
    echo "$var" | ts '[%Y-%m-%d %H:%M:%S] [Meta]   '
  elif [ "$Prefix" == "LFS_Goal" ]; then
    echo $var | cut -d '=' -f 2 >> /etc/lizardfs/goals.cfg.tmp
    echo "$var" | ts '[%Y-%m-%d %H:%M:%S] [Goal]   '
  elif [ "$Prefix" == "LFS_Export" ]; then
    echo $var | cut -d '=' -f 2 >> /etc/lizardfs/exports.cfg.tmp
    echo "$var" | ts '[%Y-%m-%d %H:%M:%S] [Export] '
  else
    echo "$var" | ts '[%Y-%m-%d %H:%M:%S] [Host]   '
  fi
done

echo "CUSTOM_GOALS_FILENAME=/etc/lizardfs/mfsgoals.cfg" >> /etc/lizardfs/metaserver.cfg
echo "DATA_PATH=/var/lib/lizardfs" >> /etc/lizardfs/metaserver.cfg
echo "TOPOLOGY_FILENAME=/etc/lizardfs/topology.cfg" >> /etc/lizardfs/metaserver.cfg
echo "EXPORTS_FILENAME=/etc/lizardfs/exports.cfg" >> /etc/lizardfs/metaserver.cfg


cat /etc/lizardfs/goals.cfg.tmp | sort > /etc/lizardfs/goals.cfg
cat /etc/lizardfs/exports.cfg.tmp | sort > /etc/lizardfs/exports.cfg

echo "#################################" | ts '[%Y-%m-%d %H:%M:%S]'

echo "Adjusting user file permissions..." | ts '[%Y-%m-%d %H:%M:%S]'
#Should we change User IDs?
usermod -u $PUID LizardFS | ts '[%Y-%m-%d %H:%M:%S]'
groupmod -g $PGID LizardFS | ts '[%Y-%m-%d %H:%M:%S]'

chown root:root -R /etc/lizardfs | ts '[%Y-%m-%d %H:%M:%S]'
chown $PUID:$PGID -R /var/lib/lizardfs | ts '[%Y-%m-%d %H:%M:%S]'

cd /home/LizardFS

echo "Starting LizardFS CGI server..." | ts '[%Y-%m-%d %H:%M:%S]'
ps -aux | grep lizardfs-cgiserver | grep -v grep | tr -s ' ' | cut -d ' ' -f 2 | xargs kill &> /dev/null
runuser -l LizardFS -c '/usr/sbin/lizardfs-cgiserver -H 0.0.0.0 -P 9425 -R /usr/share/mfscgi'
# &
echo "Starting LizardFS Meta server..." | ts '[%Y-%m-%d %H:%M:%S]'
#runuser -l LizardFS -c '/usr/sbin/lfsmaster -c /etc/lizardfs/metaserver.cfg -d start'
#runuser -l LizardFS -c "/usr/sbin/lfsmaster -c /etc/lizardfs/metaserver.cfg -d $@"
/usr/sbin/lfsmaster -u -p /var/lib/lizardfs/metaserver-pid.txt -c /etc/lizardfs/metaserver.cfg -d $@

echo "We should not be here!  Did the server crash?" | ts '[%Y-%m-%d %H:%M:%S]'

#echo "Starting LizardFS Meta server..."
#/usr/sbin/lfsmaster -c /etc/lizardfs/metaserver.cfg $1

#echo "Good bye."
#exit 0
#HEALTHCHECK CMD curl --fail http://localhost:9425 || exit 1


