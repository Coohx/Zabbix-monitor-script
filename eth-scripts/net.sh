#!/bin/bash
####  zabbix 自定义监控脚本
#
#   根据/proc/net/dev网卡流量信息，获取某一时刻当前网卡上的总流量信息，
# 记录到临时文件中，自此时刻开始，过一段时间再获取一次总流量信息，计算
# 两个时刻的时间差dt与网卡上的流量差dn,用dn/dt算出这一时间段的流量平均
# 值，作为网卡的负载衡量值. 
#
#   $1:某一块网卡 $2:进或出的流量

eth=$1
io=$2
net_file="/proc/net/dev"

# 初始化生成网卡in 记录文件
if [ -f /tmp/net_"$eth"_in.log ];then
	echo "File exist." > /dev/null
else
	touch /tmp/net_"$eth"_in.log
	date +%s >> /tmp/net_"$eth"_in.log
	grep "$eth" $net_file |awk '{print $2}'  >> /tmp/net_"$eth"_in.log
	# 开始文件不存在，创建完之后，只需修改一次属主。
    chown zabbix /tmp/net_"$eth"_in.log 
fi
# 初始化生成网卡out 记录文件
if [ -f /tmp/net_"$eth"_out.log ];then
	echo "File exist." > /dev/null
else
	touch /tmp/net_"$eth"_out.log
	date +%s >> /tmp/net_"$eth"_out.log
	grep "$eth" $net_file |awk '{print $10}'  >> /tmp/net_"$eth"_out.log
	# 开始文件不存在，创建完之后，只需修改一次属主。
    chown zabbix /tmp/net_"$eth"_out.log 
	sleep 1
fi

# 开始计算网卡平均流量
if [ $2 == "in" ];then
	# 过滤出当前时刻进网卡$eth的流量
	n_new=`grep "$eth" $net_file |awk '{print $2}'`
	# 对每一张网卡单独写一个文件
	n_old=`tail -1 /tmp/net_"$eth"_in.log`
	# bc 类似于python,支持数学运算，从标准输入读取.
	dn=`echo "$n_new-$n_old" |bc`
	
	t_new=`date +%s`
	# 总是取倒数第二行
	t_old=`tail -2 /tmp/net_"$eth"_in.log |head -1`
	dt=`echo "$t_new-$t_old" |bc`
	if_net=`echo "$dn/$dt" |bc`
	echo $if_net
	# 保存当前时刻的时间戳和进网卡流量
	date +%s >> /tmp/net_"$eth"_in.log
	grep "$eth" $net_file |awk '{print $2}' >> /tmp/net_"$eth"_in.log
elif [ $2 == "out" ];then
	# 过滤出当前时刻出网卡$eth的流量
	n_new=`grep "$eth" $net_file |awk '{print $10}'`
	n_old=`tail -1 /tmp/net_"$eth"_out.log`
	dn=`echo "$n_new-$n_old" |bc`
	
	t_new=`date +%s`
	t_old=`tail -2 /tmp/net_"$eth"_out.log |head -1`
	dt=`echo "$t_new-$t_old" |bc`
	if_net=`echo "$dn/$dt" |bc`
	echo $if_net
	# 保存当前时刻的时间戳和出网卡流量
	date +%s >> /tmp/net_"$eth"_out.log
	grep "$eth" $net_file |awk '{print $10}' >> /tmp/net_"$eth"_out.log
else
	echo 0
fi
