https://blog.csdn.net/qq_33371766/article/details/142660115





es快照恢复:

删除历史版本快照仓库

```bash
curl -u <username>:<password> -H "Content-Type:application/json" -X DELETE http://<ip>:<port>/_snapshot/<22m9d218>
```

创建快照仓库

```bash
curl -H "Content-Type:application/json" -X PUT -d '{ 
    "type": "fs",
    "settings": {
        "location": "24m3d430",
        "compress": "true"
    }
}' http://10.201.21.197:9200/_snapshot/24m3d430
```



查询快照仓库

```bash
curl -H "Content-Type:application/json"  http://10.201.21.197:9200/_snapshot
```



解压数据

```bash
cat 22m9d218.tgz.* | tar zxvf -
```

将解压后的快照数据拷贝到创建快照仓库时设置的location目录下



快照恢复

```bash
curl -H "Content-Type:application/json" -X POST -d '{ 
    "indices": "navinfo-*", 
    "ignore_unavailable": true,
    "include_aliases": false
}' http://10.201.21.197:9200/_snapshot/24m3d430/search/_restore?wait_for_completion=true
```

恢复快照并重命名索引(快照中有索引后缀, 所以不用设置)

```bash
curl -u <username>:<password> -H "Content-Type:application/json" -X POST -d '{ 
    "indices": "navinfo-*", 
    "ignore_unavailable": true,
    "rename_pattern": "navinfo-(.+)",          
    "rename_replacement": "navinfo-$1-<后缀名称>",
    "include_aliases": false
}' http://<ip>:<port>/_snapshot/<快照仓库名>/search/_restore?wait_for_completion=true
```

```bash
curl -H "Content-Type:application/json" -X POST -d '{ 
    "indices": "navinfo-*", 
    "ignore_unavailable": true,
    "rename_pattern": "navinfo-(.+)",          
    "rename_replacement": "navinfo-$1-24m3d430",
    "include_aliases": false
}' http://10.201.21.197:9200/_snapshot/24m3d430/search/_restore?wait_for_completion=true
```





设置索引副本

**副本数量必须小于集群节点数量，非集群环境单节点副本数量必须为0**

```bash
curl -H "Content-Type:application/json" -X PUT -d '{ 
    "index": {
        "number_of_replicas": 1
    }
}' http://10.201.21.197:9200/<索引名称>/_settings
```



查询索引别名

```bash
curl -H "Content-Type:application/json"  http://10.201.21.197:9200/_alias
```

删除索引别名

```bash
curl -H "Content-Type:application/json" -X DELETE  http://10.201.21.197:9200/<索引名称>/_alias/<索引别名>
```

创建索引别名

```bash
curl -H "Content-Type:application/json" -X PUT http://10.201.21.197:9200/<索引名称>/_alias/<索引别名>
```

```bash
curl -H "Content-Type:application/json" -X PUT http://10.201.21.197:9200/navinfo-cityanalyzer-index-24m3d430/_alias/navinfo-cityanalyzer-index
curl -H "Content-Type:application/json" -X PUT http://10.201.21.197:9200/navinfo-search-index-24m3d430/_alias/navinfo-search-index
curl -H "Content-Type:application/json" -X PUT http://10.201.21.197:9200/navinfo-suggest-index-24m3d430/_alias/navinfo-suggest-index
```



查询索引

```bash
curl -H "Content-Type:application/json"  http://10.201.21.197:9200/_cat/indices/*?v
```

删除历史索引

```bash
curl -X DELETE "http://10.201.21.197:9200/navinfo-cityanalyzer-index-24m3d430"
```


查看集群健康状态
```bash
curl http://${eshost}:9200/_cluster/health
```

索引模版定义
```bash
curl -X PUT "http://10.180.8.181:9200/_index_template/statcounter-template" \
  -H "Content-Type: application/json" \
  -d '{
    "index_patterns": ["statcounter-*"],
    "template": {
      "mappings": {
        "properties": {
          "timestamp_mill": {
            "type": "date",
            "format": "epoch_millis"
          },
          "target_id": {
            "type": "keyword",
            "ignore_above": 256
          },
          "module_id": {
            "type": "keyword",
            "ignore_above": 256
          },
          "type": {
            "type": "keyword",
            "ignore_above": 256
          }
        }
      },
      "settings": {
        "number_of_shards": 1,
        "number_of_replicas": 0
      }
    },
    "priority": 10,
    "composed_of": [],
    "version": 1,
    "_meta": {
      "description": "Template for statcounter indices with 1 primary shard and 0 replicas"
    }
  }'

curl http://10.180.8.181:9200/_index_template/statcounter-template?pretty

```