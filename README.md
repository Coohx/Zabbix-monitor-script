##自定义的zabbix远程监控脚本.

Note: Those scripts is used to monitor the Zabbix-agent server.

>>>客户端设置：

	 ### Option: Server	
	 Server=192.168.8.112
	 ### Option: ServerActive
     #   List of comma delimited IP:port (or hostname:port) pairs of Zabbix servers for active checks.
	 ServerActive=0.0.0.0:10050
	 ### Option: Hostname
     #   Unique, case sensitive hostname.
	 Hostname=web_aa
	 ### Option: UnsafeUserParameters
	 #   Allow all characters to be passed in arguments to user-defined parameters.
	 #   0 - do not allow
	 #   1 - allow
	 UnsafeUserParameters=1
 	 ### Option: UserParameter
	 #   User-defined parameter to monitor. There can be several user-defined parameters.
	 #   Format: UserParameter=<key>,<shell command>
	 #   See 'zabbix_agentd' directory for examples.
     UserParameter=my.net.if[*],/usr/local/sbin/zabbix/bin/net.sh $1 $2

>>>>服务端web页面设置

The example site is http://yangrong.blog.51cto.com/6945369/1542271

