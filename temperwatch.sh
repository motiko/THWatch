#!/bin/bash
. /opt/temper/float.sh
RECIEPENTS="indeecjo@gmail.com raz.kron@gmail.com shmuel777@gmail.com"
SENDMAIL=true
TRY=0
cd /opt/temper
while true;
do
TEMPERHUM=$(./temper 2>&1)
if [ $? != 0 ]; then
  let TRY++;
  echo "Device error: $TEMPERHUM"
  if [[ $TRY > 10 && $SENDMAIL ]]; then
     echo " Error: $TEMPERHUM" | cat mail-alert - | nullmailer-inject $RECIEPENTS
     SENDMAIL=false
  fi
  sleep 30s;
  continue;
else
  TRY=0
fi
export TEMPERATURE=$(echo $TEMPERHUM | grep -o '^[^ ]*')
export HUMIDITY=$(echo $TEMPERHUM | grep -o '[^ ]*$')
export DAY=$(date +%F)
export TIME=$(date +%R)
export MINUTE=$(date +%-M)
echo "temperature:$TEMPERATURE"
echo "humidity:$HUMIDITY"
if ((MINUTE % 5 == 0)) ; then
   echo "$TIME $TEMPERATURE $HUMIDITY" >> $DAY
   sed -e "s/DAY/$DAY/" plotdata.pg | gnuplot > /var/www/plot.png
   SENDMAIL=true
   sleep 1m
fi
set -f
if [ $SENDMAIL ]; then
  if float_cond "$TEMPERATURE > 32 || $TEMPERATURE < 14" ; then
     echo "Temperature: $TEMPERATURE " | cat /opt/temper/mail-alert - | nullmailer-inject $RECIEPENTS  
     SENDMAIL=$false
     echo "Mail notification sent"
  fi
  if float_cond "$HUMIDITY < 30 || $HUMIDITY > 85" ; then
     echo "Humidity: $HUMIDITY " | cat /opt/temper/mail-alert - | nullmailer-inject $RECIEPENTS  
     SENDMAIL=$false
     echo "Mail notification sent"
  fi
fi
set +f
sleep 15s
done

