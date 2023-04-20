#!/bin/bash
set -uo pipefail

if [ $# != 2 ]; then
	echo "use $0 [recipient] [url]"
	exit 1;
fi

url=`echo $2 | grep -oE 'http(s)?:\\/\\/[0-9a-zA-Z.\\-]+(:[0-9]{1,5})?\\/api\\/push\\/[a-zA-Z0-9]+'`

recipient=`echo $1 | grep -oE '[0-9a-zA-Z.]+@[0-9a-zA-Z.]+.[a-zA-Z]{2,}'`

if [[ -z $url ]]; then
	echo "use $0 [recipient] [url]"
	exit 2;
fi

if [[ $recipient != $1 ]]; then
	echo "use $0 [recipient] [url]"
	exit 3;
fi

if [[ -z $recipient ]]; then
	echo "use $0 [recipient] [url]"
	exit 4;
fi

dir=`dirname -- "$0"`
cd $dir

start=`date +%s%N`

echo ping | sendxmpp -t -f .sendxmpprc $recipient > /dev/null 2>&1
r=$?

end=`date +%s%N`
runtime=$( echo "($end - $start) / 1000000" | bc -l )

ping=`printf %.0f $(echo "$runtime")`

if [ $r == 0 ]; then
	wget -O - $url"?status=up&msg=ok&ping="$ping >/dev/null 2>&1
else
	wget -O - $url"?status=down&msg=down" >/dev/null 2>&1
fi

