#!/bin/bash

# 判断文件是否存在
if [ ! -f copyfileto.cfg ]; then
	echo "[copyfileto.cfg] not exist ."
	# echo "usr ip pw src_dir dst_dir" > configs
else
	echo "[copyfileto.cfg] has created ..."
fi

#分发到各个节点,这里分发到host文件中的主机中.
while read line
do
	usr=`echo $line | cut -d " " -f 2`
	ip=`echo $line | cut -d " " -f 1`
	pw=`echo $line | cut -d " " -f 3`
	src_dir=`echo $line | cut -d " " -f 4`
	dst_dir=`echo $line | cut -d " " -f 5`

	echo "send [$src_dir] to [$usr@$ip:$dst_dir]"

	expect <<EOF
	set timeout 60
	spawn scp -r $src_dir $usr@$ip:$dst_dir
	expect {
		"yes/no" { send "yes\n";exp_continue }
		"password" { send "$pw\n" }
	}
	expect "password" { send "$pw\n" }
	# expect eof
EOF
done <  copyfileto.cfg