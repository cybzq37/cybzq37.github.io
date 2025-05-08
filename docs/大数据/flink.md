---
outline: deep
---

# flink


流处理框架经历了3代的更新迭代，大数据处理也随之经历了从Lambda架构到Kappa架构的演进。

### Lambda架构

Lambda架构主要分为3部分：批处理层、流处理层和在线服务层。

![lambda architecture](lambda_architecture.png)

数据流来自Kafka这样的消息队列。

批处理层，数据流首先会被持久化保存到批处理数据仓库中，积累一段时间后，再使用批处理引擎来进行计算。这个积累时间可以是一小时、一天，也可以是一个月。处理结果最后导入一个可供在线应用系统查询的数据库上。
批处理层中的批处理数据仓库可以是HDFS、Amazon S3或其他数据仓库，批处理引擎可以是MapReduce或Spark。

流处理，会导致用户必须等待很久才能获取计算结果，一般有几小时的延迟。电商数据分析部门只能查看前一天的统计分析结果，无法获取当前的结果，这对实时决策来说是一个巨大的时间鸿沟，很可能导致管理者错过最佳决策时机。因此，在批处理层的基础上，Lambda架构增加了一个流处理层，用户行为日志会实时流入流处理层，流处理引擎生成预处理结果，并导入一个数据库。分析人员可以查看前一小时或前几分钟内的数据结果，这大大增强了整个系统的实时性。但数据流会有事件乱序等问题，使用早期的流处理引擎，只能得到一个近似准确的计算结果，相当于牺牲了一定的准确性来换取实时性。

### Kappa架构

Kafka的创始人杰·克雷普斯认为在很多场景下，维护一套Lambda架构的大数据处理平台耗时耗力，于是提出在某些场景下，没有必要维护一个批处理层，直接使用一个流处理层即可满足需求。



The main `useData()` API can be used to access site, theme, and page data for the current page. It works in both `.md` and `.vue` files:

```md
<script setup>
import { useData } from 'vitepress'

const { theme, page, frontmatter } = useData()
</script>

## Results

### Theme Data
<pre>{{ theme }}</pre>

### Page Data
<pre>{{ page }}</pre>

### Page Frontmatter
<pre>{{ frontmatter }}</pre>
```

<script setup>
import { useData } from 'vitepress'

const { site, theme, page, frontmatter } = useData()
</script>

## Results

### Theme Data

<pre>{{ theme }}</pre>

### Page Data

<pre>{{ page }}</pre>

### Page Frontmatter

<pre>{{ frontmatter }}</pre>

## More

Check out the documentation for the [full list of runtime APIs](https://vitepress.dev/reference/runtime-api#usedata).
