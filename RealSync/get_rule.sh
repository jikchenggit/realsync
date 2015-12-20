> rule.conf
echo "[RULES]" >> rule.conf

RULE="RULES="
DS_OWNER="DSG"
#FILTER="ID='PT'"
FILTER="ID=2"

CNT=1
for i in `cat tab.txt`
do
  if [ $CNT = 1 ]
  then
      RULE=$RULE"t$CNT"
  else
      RULE=$RULE",t$CNT"
  fi
  let CNT=CNT+1
done

echo $RULE
echo $RULE >> rule.conf

echo "" >> rule.conf

CNT=1
for i in `cat tab.txt`
do
  echo "[t$CNT]" >> rule.conf
  echo "DS_OWNER=$DS_OWNER" >> rule.conf
  echo "DS_TNAME=$i" >> rule.conf
  echo "ROW_FILTER=$FILTER" >>rule.conf
  echo "" >> rule.conf
  let CNT=CNT+1
done
