https://blog.csdn.net/qq_33371766/article/details/142660115


```
curl -H "Content-Type:application/json" -X POST -d '{ 
    "analyzer" : "ncs_smart", 
    "text" : "北京天安门广场"
}' http://192.168.113.4:9200/_analyze
```



#### es快照恢复

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
curl -H "Content-Type:application/json" -X PUT http://192.168.113.4:9200/navinfo-cityanalyzer-index-24m9d51/_alias/navinfo-cityanalyzer-index

curl -H "Content-Type:application/json" -X PUT http://192.168.113.4:9200/navinfo-search-index-24m9d51/_alias/navinfo-search-index

curl -H "Content-Type:application/json" -X PUT http://192.168.113.4:9200/navinfo-suggest-index-24m9d51/_alias/navinfo-suggest-index
```

```bash
curl -H "Content-Type:application/json" -X PUT http://192.168.113.3:19200/navinfo-regeo-poi-index-24m9d0403/_alias/navinfo-regeo-poi-index

curl -H "Content-Type:application/json" -X PUT http://192.168.113.3:19200/navinfo-regeo-admin-index-24m9d0403/_alias/navinfo-regeo-admin-index

curl -H "Content-Type:application/json" -X PUT http://192.168.113.3:19200/navinfo-regeo-aoi-index-24m9d0403/_alias/navinfo-regeo-aoi-index

curl -H "Content-Type:application/json" -X PUT http://192.168.113.3:19200/navinfo-regeo-road-index-24m9d0403/_alias/navinfo-regeo-road-index

curl -H "Content-Type:application/json" -X PUT http://192.168.113.3:19200/navinfo-regeo-cross-index-24m9d0403/_alias/navinfo-regeo-cross-index
```

查询索引

```bash
curl -H "Content-Type:application/json"  http://10.201.21.197:9200/_cat/indices/*?v
```

删除历史索引

```bash
curl -X DELETE "http://10.201.21.197:9200/navinfo-cityanalyzer-index-24m3d430"
```

