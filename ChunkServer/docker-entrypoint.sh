#!/bin/bash

echo "Starting with argument(s): [$@]" | ts '[%Y-%m-%d %H:%M:%S]'

mkdir -p /etc/lizardfs
mkdir -p /var/lib/lizardfs
mkdir -p /home/LizardFS

if [ -f '/etc/lizardfs/mfschunkserver.cfg' ]; then mv '/etc/lizardfs/mfschunkserver.cfg' '/etc/lizardfs/mfschunkserver.cfg.last'; fi
if [ -f '/etc/lizardfs/mfshdd.cfg' ]; then mv '/etc/lizardfs/mfshdd.cfg' '/etc/lizardfs/mfshdd.cfg.last'; fi
if [ -f '/etc/lizardfs/mfshdd.cfg.tmp' ]; then rm '/etc/lizardfs/mfshdd.cfg.tmp'; fi

echo "#################################" | ts '[%Y-%m-%d %H:%M:%S]'
echo "Environment Variables:" | ts '[%Y-%m-%d %H:%M:%S]'
echo "---------------------------------" | ts '[%Y-%m-%d %H:%M:%S]'
env | while read -r var ; do
  Prefix=`echo $var | cut -d '-' -f 1`
  if [ "$Prefix" == "LFS_Chunkserver" ]; then
    echo $var | cut -d '-' -f 2 >> /etc/lizardfs/mfschunkserver.cfg
    echo "$var" | ts '[%Y-%m-%d %H:%M:%S] [Meta]   '
  elif [ "$Prefix" == "LFS_HDD" ]; then
    echo $var | cut -d '=' -f 2 >> /etc/lizardfs/mfshdd.cfg.tmp
    echo "$var" | ts '[%Y-%m-%d %H:%M:%S] [Goal]   '
  else
    echo "$var" | ts '[%Y-%m-%d %H:%M:%S] [Host]   '
  fi
done


echo "HDD_CONF_FILENAME = /etc/lizardfs/mfshdd.cfg" >> /etc/lizardfs/mfschunkserver.cfg
echo "DATA_PATH=/var/lib/lizardfs" >> /etc/lizardfs/mfschunkserver.cfg

cat /etc/lizardfs/mfshdd.cfg.tmp | sort > /etc/lizardfs/mfshdd.cfg

echo "#################################" | ts '[%Y-%m-%d %H:%M:%S]'
echo "Adjusting user file permissions..." | ts '[%Y-%m-%d %H:%M:%S]'
#Should we change User IDs?
usermod -u $PUID LizardFS | ts '[%Y-%m-%d %H:%M:%S]'
groupmod -g $PGID LizardFS | ts '[%Y-%m-%d %H:%M:%S]'

chown root:root -R /etc/lizardfs | ts '[%Y-%m-%d %H:%M:%S]'
chown $PUID:$PGID -R /var/lib/lizardfs | ts '[%Y-%m-%d %H:%M:%S]'
chown $PUID:$PGID -R /blocks | ts '[%Y-%m-%d %H:%M:%S]'

cd /home/LizardFS

echo "Starting LizardFS Chunk server..." | ts '[%Y-%m-%d %H:%M:%S]'
runuser -l LizardFS -c '/usr/sbin/lfschunkserver -c /etc/lizardfs/mfschunkserver.cfg $@'

while :
do
  pgrep lfschunkserver > /dev/null || exit 1
  sleep 15
done

#echo "We should not be here!  Did the server crash?" | ts '[%Y-%m-%d %H:%M:%S]'

#echo "Good bye."
#exit 0
