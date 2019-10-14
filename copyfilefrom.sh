#!/bin/bash

start_time=`date +%s`

configfile=copyfilefrom.cfg
work=10
log=record

# 判断文件是否存在
if [ ! -f $configfile ]; then
	echo "[$configfile] not exist ."
	# echo "usr ip pw src_dir dst_dir" > configs
else
	echo "[$configfile] has created ..."
fi

# 增加记录文件
if [ ! -d $log ]; then
	mkdir $log
	echo "[$log] created ..."
fi

# 清空原来的记录文件
rm $log/* -rf

# 建立有名管道用于多进程数量控制
[ -e fd1 ] || mkfifo fd1
exec 3<>fd1
rm -f fd1

# 建立 work 个线程
for((i=1; i<=$work; i++)) do
	echo >&3
done

# 分发到各个节点,这里分发到 configfile 文件中的主机中.
while read line
do
	read -u3
	usr=`echo $line | cut -d " " -f 2`
	ip=`echo $line | cut -d " " -f 1`
	pw=`echo $line | cut -d " " -f 3`
	src_dir=`echo $line | cut -d " " -f 4`
	dst_dir=`echo $line | cut -d " " -f 5`
	echo "receive [$src_dir] from [$usr@$ip:$dst_dir]"
	{
		expect <<EOF
		set timeout 600
		spawn rsync -av $usr@$ip:$dst_dir $src_dir
		expect {
			"yes/no" { send "yes\n";exp_continue }
			"password" { send "$pw\n" }
		}
		expect "password" { send "$pw\n" }

EOF
	echo >&3
	echo "receive [$src_dir] from [$usr@$ip:$dst_dir] done."
	} >> $log/$usr@$ip.log & # 以追加的方式增加记录文件, 避免多条同一个设备的传输记录被覆盖
done < $configfile

wait

stop_time=`date +%s`
echo "TIME:`expr $stop_time - $start_time`"
exec 3<&-
exec 3>&-
