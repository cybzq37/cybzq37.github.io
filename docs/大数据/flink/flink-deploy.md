集群规划

```bash
# 下载
wget https://dist.apache.org/repos/dist/release/flink/flink-1.20.0/flink-1.20.0-bin-scala_2.12.tgz
# 解压
tar -zxvf flink-1.17.1-bin-scala_2.12.tgz -C /home/flink/
# 修改配置
cd /home/flink/flink-1.20.0/conf
vim flink-conf.yaml
```

修改内容如下：

::: code-group
```yaml [flink-conf.yaml]

# JobManager节点地址.
jobmanager.rpc.address: node01
jobmanager.bind-host: 0.0.0.0
rest.address: node01
rest.bind-address: 0.0.0.0
# TaskManager节点地址.需要配置为当前机器名
taskmanager.bind-host: 0.0.0.0
taskmanager.host: node01
```

```yaml [works]
# vim works
node01
node02
node03
```

```yaml [masters]
# vim masters
node01:8081
```
:::

