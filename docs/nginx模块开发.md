**开发入门**：
- **安装与运行**：下载 Nginx 源码包，解压后用`./configure`、`make`、`make install`命令安装，可通过`/usr/local/nginx/sbin/nginx`启动，以 Deamon 进程运行，用`curl -i http://localhost/`检测是否成功，`/usr/local/nginx/sbin/nginx -s stop`停止。  
- **配置文件结构**：配置文件是 Nginx 灵魂，以 block 形式组织，分 main、event、http 等层级，http 中含 server block，server block 又有 location block 。各层级有指令，指令格式为 `指令名 参数;`，配置文件可包含其他文件。  
- **模块工作原理**：Nginx 接到 HTTP 请求，映射到 location block，由其中指令启动不同模块工作。模块分 handler 和 filter，handler 处理请求生成响应内容，filter 处理响应内容。  
```bash
#user  nobody;
worker_processes  8;
error_log  logs/error.log;
pid        logs/nginx.pid;
events {
    worker_connections  1024;
}
http {
    include       mime.types;
    default_type  application/octet-stream;
 
    sendfile        on;
    #tcp_nopush     on;
    keepalive_timeout  65;
    #gzip  on;
 
    server {
        listen       80;
        server_name  localhost;
        location / {
            root   /home/yefeng/www;
            index  index.html index.htm;
        }
        #error_page  404              /404.html;
        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    }
}
```

Nginx的配置文件是以block的形式组织的，一个block通常使用大括号“{}”表示。block分为几个层级，整个配置文件为main层级，这是最大的层级；在main层级下可以有event、http等层级，而http中又会有server block，server block中可以包含location block。

每个层级可以有自己的指令 Directive，例如 worker_processes 是一个 main 层级指令，它指定 Nginx 服务的 Worker 进程数量。有的指令只能在一个层级中配置，如worker_processes 只能存在于main中，而有的指令可以存在于多个层级，在这种情况下，子block会继承父block的配置，同时如果子block配置了与父block不同的指令，则会覆盖掉父block的配置。指令的格式是 *指令名 参数1 参数2 … 参数N;*，注意参数间可用任意数量空格分隔，最后要加分号。

![[assets/Pasted image 20250528105931.png]]![[assets/Pasted image 20250528110125.png]]

**开发实战**：以开发 echo handler 模块为例，步骤如下：  
- **定义模块配置结构**：用`ngx_http_[module - name]_[main|srv|loc]_conf_t`命名结构存储指令参数，echo 模块只需 loc 层级，定义`ngx_http_echo_loc_conf_t`存储字符串参数。
- **定义指令**：Nginx 模块用`ngx_command_t`数组表示接收指令，echo 模块接收 “echo” 指令。通过`ngx_command_s`结构体各字段配置指令，如`name`指令名、`type`参数掩码标志位等。
- **创建合并配置信息**：定义`ngx_http_module_t`类型结构体变量作为模块 Context，如`ngx_http_echo_module_ctx`，设置各 Hook 函数，如`create_loc_conf`初始化配置结构体，`merge_loc_conf`合并配置信息。
- **编写 Handler**：handler 负责读配置、处理业务、产生 HTTP 头和主体。通过`ngx_http_get_module_loc_conf`获取配置，设置`headers_out`相关字段生成 HTTP 头，利用 Nginx 的 I/O 机制，将输出组织成链表，用`ngx_http_output_filter`输出。
- **组合 Nginx Module**：将各组件组合成`ngx_module_t`结构，如`ngx_http_echo_module`，填充 context、指令数组、模块类型等信息。


开发一个 echo 的 handler 模块，这个模块功能非常简单，它接收 echo 指令，指令可指定一个字符串参数，模块会输出这个字符串作为HTTP响应。例如，做如下配置：
```
location /echo {
    echo "hello nginx";
}
```
则访问 [http://hostname/echo](http://hostname/echo) 时会输出 hello nginx，要实现这个功能需要三步：
- 读入配置文件中echo指令及其参数；
- 进行HTTP包装（添加HTTP头等工作）；
- 将结果返回给客户端。


### 定义模块配置结构

首先我们需要一个结构用于存储从配置文件中读进来的相关指令参数，即模块配置信息结构。根据Nginx模块开发规则，这个结构的命名规则为：
```
ngx_http_[module-name]_[main|srv|loc]_conf_t
```
其中 main、srv 和 loc 分别用于表示同一模块在三层 block 中的配置信息。这里我们的echo模块只需要运行在loc层级下，需要存储一个字符串参数，因此我们可以定义如下的模块配置：
```c
typedef struct {
    ngx_str_t  ed;    // ngx_str_t定义在core/ngx_string
} ngx_http_echo_loc_conf_t;
```
字段 ed 用于存储 echo 指令指定的需要输出的字符串。

### 定义指令
下面是echo模块的指令定义：
```c
static ngx_command_t  ngx_http_echo_commands[] = {
    { 
	    ngx_string("echo"),
        NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
        ngx_http_echo,
        NGX_HTTP_LOC_CONF_OFFSET,
        offsetof(ngx_http_echo_loc_conf_t, ed),
        NULL 
    },
    ngx_null_command
};

static char *
ngx_http_echo(ngx_conf_t *cf, ngx_command_t *cmd, void *conf)
{
    ngx_http_core_loc_conf_t  *clcf;
    clcf = ngx_http_conf_get_module_loc_conf(cf, ngx_http_core_module);
    clcf->handler = ngx_http_echo_handler;
    ngx_conf_set_str_slot(cf,cmd,conf);
    return NGX_CONF_OK;
}
```
指令数组的命名规则为`ngx_http_[module-name]_commands`，注意数组最后一个元素要是ngx_null_command结束。
这个函数除了调用 ngx_conf_set_str_slot 转化 echo 指令的参数外，还将修改了核心模块配置（也就是这个location的配置），将其handler替换为我们编写的handler：ngx_http_echo_handler。这样就屏蔽了此location的默认handler，使用ngx_http_echo_handler产生HTTP响应。

### 创建合并配置信息

下一步是定义模块Context，这里首先需要定义一个 `ngx_http_module_t` 类型的结构体变量，命名规则为 `ngx_http_[module-name]_module_ctx`，这个结构主要用于定义各个Hook函数。下面是echo模块的context结构：

```c
static ngx_http_module_t  ngx_http_echo_module_ctx = {
    NULL,      /* preconfiguration */
    NULL,      /* postconfiguration */
    NULL,      /* create main configuration */
    NULL,      /* init main configuration */
    NULL,      /* create server configuration */
    NULL,      /* merge server configuration */
    ngx_http_echo_create_loc_conf,   /* create location configration */
    ngx_http_echo_merge_loc_conf     /* merge location configration */
};
```

可以看到一共有 8个 Hook 注入点，分别会在不同时刻被Nginx调用，由于我们的模块仅仅用于location域，这里将不需要的注入点设为NULL即可。其中create_loc_conf用于初始化一个配置结构体，如为配置结构体分配内存等工作；merge_loc_conf用于将其父block的配置信息合并到此结构体中，也就是实现配置的继承。这两个函数会被Nginx自动调用。注意这里的命名规则：`ngx_http_[module-name]_[create|merge]_[main|srv|loc]_conf` 。

下面是echo模块这个两个函数的代码：

```c
static void *
ngx_http_echo_create_loc_conf(ngx_conf_t *cf)
{
    ngx_http_echo_loc_conf_t  *conf;
    conf = ngx_pcalloc(cf->pool, sizeof(ngx_http_echo_loc_conf_t));
    if (conf == NULL) {
        return NGX_CONF_ERROR;
    }
    conf->ed.len = 0;
    conf->ed.data = NULL;
    return conf;
}
static char *
ngx_http_echo_merge_loc_conf(ngx_conf_t *cf, void *parent, void *child)
{
    ngx_http_echo_loc_conf_t *prev = parent;
    ngx_http_echo_loc_conf_t *conf = child;
    ngx_conf_merge_str_value(conf->ed, prev->ed, "");
    return NGX_CONF_OK;
}
```
 其中 ngx_pcalloc 用于在 Nginx 内存池中分配一块空间，是 pcalloc 的一个包装。使用ngx_pcalloc 分配的内存空间不必手工free，Nginx会自行管理，在适当是否释放。
create_loc_conf 新建一个 ngx_http_echo_loc_conf_t，分配内存，并初始化其中的数据，然后返回这个结构的指针；merge_loc_conf 将父 block 域的配置信息合并到 create_loc_conf新建的配置结构体中。
其中ngx_conf_merge_str_value不是一个函数，而是一个宏，其定义在core/ngx_conf_file.h中：
```c
define ngx_conf_merge_str_value(conf, prev, default)                     
    if (conf.data == NULL) {                                              
        if (prev.data) {                                                  
            conf.len = prev.len;                                          
            conf.data = prev.data;                                       
        } else {                                                         
            conf.len = sizeof(default) - 1;                              
            conf.data = (u_char *) default;                              
        }                                                                 
    }
```

同时可以看到，core/ngx_conf_file.h还定义了很多merge value的宏用于merge各种数据。它们的行为比较相似：使用prev填充conf，如果prev的数据为空则使用default填充。

### 编写Handler

下面的工作是编写handler。handler可以说是模块中真正干活的代码，它主要有以下四项职责：

读入模块配置。

处理功能业务。

产生HTTP header。

产生HTTP body。

下面先贴出echo模块的代码，然后通过分析代码的方式介绍如何实现这四步。这一块的代码比较复杂：
```c
static ngx_int_t
ngx_http_echo_handler(ngx_http_request_t *r)
{
    ngx_int_t rc;
    ngx_buf_t *b;
    ngx_chain_t out;
    ngx_http_echo_loc_conf_t *elcf;
    elcf = ngx_http_get_module_loc_conf(r, ngx_http_echo_module);
    if(!(r->method & (NGX_HTTP_HEAD|NGX_HTTP_GET|NGX_HTTP_POST)))
    {
        return NGX_HTTP_NOT_ALLOWED;
    }
    r->headers_out.content_type.len = sizeof("text/html") - 1;
    r->headers_out.content_type.data = (u_char *) "text/html";
    r->headers_out.status = NGX_HTTP_OK;
    r->headers_out.content_length_n = elcf->ed.len;
    if(r->method == NGX_HTTP_HEAD)
    {
        rc = ngx_http_send_header(r);
        if(rc != NGX_OK)
        {
            return rc;
        }
    }
    b = ngx_pcalloc(r->pool, sizeof(ngx_buf_t));
    if(b == NULL)
    {
        ngx_log_error(NGX_LOG_ERR, r->connection->log, 0, "Failed to allocate response buffer.");
        return NGX_HTTP_INTERNAL_SERVER_ERROR;
    }
    out.buf = b;
    out.next = NULL;
    b->pos = elcf->ed.data;
    b->last = elcf->ed.data + (elcf->ed.len);
    b->memory = 1;
    b->last_buf = 1;
    rc = ngx_http_send_header(r);
    if(rc != NGX_OK)
    {
        return rc;
    }
    return ngx_http_output_filter(r, &out);
}
```
 handler 会接收一个 ngx_http_request_t 指针类型的参数，这个参数指向一个ngx_http_request_t 结构体，此结构体存储了这次 HTTP 请求的一些信息，这个结构定义在http/ngx_http_request.h 中：

```c
struct ngx_http_request_s {
    uint32_t                          signature;         /* "HTTP" */
    ngx_connection_t                 *connection;
    void                            **ctx;
    void                            **main_conf;
    void                            **srv_conf;
    void                            **loc_conf;
    ngx_http_event_handler_pt         read_event_handler;
    ngx_http_event_handler_pt         write_event_handler;
#if (NGX_HTTP_CACHE)
    ngx_http_cache_t                 *cache;
#endif
    ngx_http_upstream_t              *upstream;
    ngx_array_t                      *upstream_states;
    /* of ngx_http_upstream_state_t */
    ngx_pool_t                       *pool;
    ngx_buf_t                        *header_in;
    ngx_http_headers_in_t             headers_in;
    ngx_http_headers_out_t            headers_out;
    ngx_http_request_body_t          *request_body;
    time_t                            lingering_time;
    time_t                            start_sec;
    ngx_msec_t                        start_msec;
    ngx_uint_t                        method;
    ngx_uint_t                        http_version;
    ngx_str_t                         request_line;
    ngx_str_t                         uri;
    ngx_str_t                         args;
    ngx_str_t                         exten;
    ngx_str_t                         unparsed_uri;
    ngx_str_t                         method_name;
    ngx_str_t                         http_protocol;
    ngx_chain_t                      *out;
    ngx_http_request_t               *main;
    ngx_http_request_t               *parent;
    ngx_http_postponed_request_t     *postponed;
    ngx_http_post_subrequest_t       *post_subrequest;
    ngx_http_posted_request_t        *posted_requests;
    ngx_http_virtual_names_t         *virtual_names;
    ngx_int_t                         phase_handler;
    ngx_http_handler_pt               content_handler;
    ngx_uint_t                        access_code;
    ngx_http_variable_value_t        *variables;
    /* ... */
}
```
 由于 ngx_http_request_s 定义比较长，这里我只截取了一部分。可以看到里面有诸如uri，args 和 request_body 等 HTTP 常用信息。这里需要特别注意的几个字段是 headers_in、headers_out 和 chain，它们分别表示 request header、response header和输出数据缓冲区链表（缓冲区链表是Nginx I/O中的重要内容，后面会单独介绍）。
第一步是获取模块配置信息，这一块只要简单使用ngx_http_get_module_loc_conf就可以了。
第二步是功能逻辑，因为echo模块非常简单，只是简单输出一个字符串，所以这里没有功能逻辑代码。
第三步是设置response header。Header内容可以通过填充headers_out实现，我们这里只设置了Content-type和Content-length等基本内容，ngx_http_headers_out_t定义了所有可以设置的HTTP Response Header信息：
```c
typedef struct {
    ngx_list_t                        headers;
    ngx_uint_t                        status;
    ngx_str_t                         status_line;
    ngx_table_elt_t                  *server;
    ngx_table_elt_t                  *date;
    ngx_table_elt_t                  *content_length;
    ngx_table_elt_t                  *content_encoding;
    ngx_table_elt_t                  *location;
    ngx_table_elt_t                  *refresh;
    ngx_table_elt_t                  *last_modified;
    ngx_table_elt_t                  *content_range;
    ngx_table_elt_t                  *accept_ranges;
    ngx_table_elt_t                  *www_authenticate;
    ngx_table_elt_t                  *expires;
    ngx_table_elt_t                  *etag;
    ngx_str_t                        *override_charset;
    size_t                            content_type_len;
    ngx_str_t                         content_type;
    ngx_str_t                         charset;
    u_char                           *content_type_lowcase;
    ngx_uint_t                        content_type_hash;
    ngx_array_t                       cache_control;
    off_t                             content_length_n;
    time_t                            date_time;
    time_t                            last_modified_time;
} ngx_http_headers_out_t;
```

这里并不包含所有HTTP头信息，如果需要可以使用agentzh（春来）开发的Nginx模块[HttpHeadersMore](http://wiki.nginx.org/HttpHeadersMoreModule) 在指令中指定更多的Header头信息。
设置好头信息后使用 ngx_http_send_header 就可以将头信息输出，ngx_http_send_header接受一个 ngx_http_request_t 类型的参数。
第四步也是最重要的一步是输出 Response body。这里首先要了解 Nginx 的 I/O 机制，Nginx 允许 handler 一次产生一组输出，可以产生多次，Nginx将输出组织成一个单链表结构，链表中的每个节点是一个chain_t，定义在core/ngx_buf.h：
```c
struct ngx_chain_s {
    ngx_buf_t    *buf;
    ngx_chain_t  *next;
};
```
 其中 ngx_chain_t 是 ngx_chain_s 的别名，buf为某个数据缓冲区的指针，next指向下一个链表节点，可以看到这是一个非常简单的链表。ngx_buf_t的定义比较长而且很复杂，这里就不贴出来了，请自行参考core/ngx_buf.h。ngx_but_t中比较重要的是pos和last，分别表示要缓冲区数据在内存中的起始地址和结尾地址，这里我们将配置中字符串传进去，last_buf是一个位域，设为1表示此缓冲区是链表中最后一个元素，为0表示后面还有元素。因为我们只有一组数据，所以缓冲区链表中只有一个节点，如果需要输入多组数据可将各组数据放入不同缓冲区后插入到链表。下图展示了Nginx缓冲链表的结构：

![](https://i-blog.csdnimg.cn/blog_migrate/33592a76ca8c92f78939a4889a8c526e.png)

缓冲数据准备好后，用ngx_http_output_filter就可以输出了（会送到filter进行各种过滤处理）。ngx_http_output_filter的第一个参数为ngx_http_request_t结构，第二个为输出链表的起始地址&out。ngx_http_out_put_filter会遍历链表，输出所有数据。

以上就是handler的所有工作，请对照描述理解上面贴出的handler代码。

### 组合Nginx Module

上面完成了Nginx模块各种组件的开发下面就是将这些组合起来了。一个Nginx模块被定义为一个ngx_module_t结构，这个结构的字段很多，不过开头和结尾若干字段一般可以通过Nginx内置的宏去填充，下面是我们echo模块的模块主体定义：

```c
ngx_module_t  ngx_http_echo_module = {
    NGX_MODULE_V1,
    &ngx_http_echo_module_ctx,             /* module context */
    ngx_http_echo_commands,                /* module directives */
    NGX_HTTP_MODULE,                       /* module type */
    NULL,                                  /* init master */
    NULL,                                  /* init module */
    NULL,                                  /* init process */
    NULL,                                  /* init thread */
    NULL,                                  /* exit thread */
    NULL,                                  /* exit process */
    NULL,                                  /* exit master */
    NGX_MODULE_V1_PADDING
};
```
 开头和结尾分别用NGX_MODULE_V1和NGX_MODULE_V1_PADDING 填充了若干字段，就不去深究了。这里主要需要填入的信息从上到下以依次为context、指令数组、模块类型以及若干特定事件的回调处理函数（不需要可以置为NULL），其中内容还是比较好理解的，注意我们的echo是一个HTTP模块，所以这里类型是NGX_HTTP_MODULE，其它可用类型还有NGX_EVENT_MODULE（事件处理模块）和NGX_MAIL_MODULE（邮件模块）。

这样，整个echo模块就写好了，下面给出echo模块的完整代码：

```c
include <ngx_config.h>
include <ngx_core.h>
include <ngx_http.h>

/* Module config */
typedef struct {
    ngx_str_t  ed;
} ngx_http_echo_loc_conf_t;

static char *ngx_http_echo(ngx_conf_t *cf, ngx_command_t *cmd, void *conf);
static void *ngx_http_echo_create_loc_conf(ngx_conf_t *cf);
static char *ngx_http_echo_merge_loc_conf(ngx_conf_t *cf, void *parent, void *child);

/* Directives */
static ngx_command_t  ngx_http_echo_commands[] = {
    { 
	    ngx_string("echo"),
        NGX_HTTP_LOC_CONF|NGX_CONF_TAKE1,
        ngx_http_echo,
        NGX_HTTP_LOC_CONF_OFFSET,
        offsetof(ngx_http_echo_loc_conf_t, ed),
        NULL 
    },
    ngx_null_command
};

/* Http context of the module */
static ngx_http_module_t  ngx_http_echo_module_ctx = {
    NULL,                                  /* preconfiguration */
    NULL,                                  /* postconfiguration */
    NULL,                                  /* create main configuration */
    NULL,                                  /* init main configuration */
    NULL,                                  /* create server configuration */
    NULL,                                  /* merge server configuration */
    ngx_http_echo_create_loc_conf,         /* create location configration */
    ngx_http_echo_merge_loc_conf           /* merge location configration */
};

/* Module */
ngx_module_t  ngx_http_echo_module = {
    NGX_MODULE_V1,
    &ngx_http_echo_module_ctx,             /* module context */
    ngx_http_echo_commands,                /* module directives */
    NGX_HTTP_MODULE,                       /* module type */
    NULL,                                  /* init master */
    NULL,                                  /* init module */
    NULL,                                  /* init process */
    NULL,                                  /* init thread */
    NULL,                                  /* exit thread */
    NULL,                                  /* exit process */
    NULL,                                  /* exit master */
    NGX_MODULE_V1_PADDING
};

/* Handler function */
static ngx_int_t ngx_http_echo_handler(ngx_http_request_t *r)
{
    ngx_int_t rc;
    ngx_buf_t *b;
    ngx_chain_t out;
    ngx_http_echo_loc_conf_t *elcf;
    elcf = ngx_http_get_module_loc_conf(r, ngx_http_echo_module);
    if(!(r->method & (NGX_HTTP_HEAD|NGX_HTTP_GET|NGX_HTTP_POST)))
    {
        return NGX_HTTP_NOT_ALLOWED;
    }
    r->headers_out.content_type.len = sizeof("text/html") - 1;
    r->headers_out.content_type.data = (u_char *) "text/html";
    r->headers_out.status = NGX_HTTP_OK;
    r->headers_out.content_length_n = elcf->ed.len;
    if(r->method == NGX_HTTP_HEAD)
    {
        rc = ngx_http_send_header(r);
        if(rc != NGX_OK)
        {
            return rc;
        }
    }
    b = ngx_pcalloc(r->pool, sizeof(ngx_buf_t));
    if(b == NULL)
    {
        ngx_log_error(NGX_LOG_ERR, r->connection->log, 0, "Failed to allocate response buffer.");
        return NGX_HTTP_INTERNAL_SERVER_ERROR;
    }
    out.buf = b;
    out.next = NULL;
    b->pos = elcf->ed.data;
    b->last = elcf->ed.data + (elcf->ed.len);
    b->memory = 1;
    b->last_buf = 1;
    rc = ngx_http_send_header(r);
    if(rc != NGX_OK)
    {
        return rc;
    }
    return ngx_http_output_filter(r, &out);
}

static char *
ngx_http_echo(ngx_conf_t *cf, ngx_command_t *cmd, void *conf)
{
    ngx_http_core_loc_conf_t  *clcf;
    // 获取核心模块的 location 配置结构体
    clcf = ngx_http_conf_get_module_loc_conf(cf, ngx_http_core_module);
    clcf->handler = ngx_http_echo_handler;
    ngx_conf_set_str_slot(cf,cmd,conf);
    return NGX_CONF_OK;
}

// 创建配置结构体实例
static void * ngx_http_echo_create_loc_conf(ngx_conf_t *cf)
{
    ngx_http_echo_loc_conf_t  *conf;
    conf = ngx_pcalloc(cf->pool, sizeof(ngx_http_echo_loc_conf_t));
    if (conf == NULL) {
        return NGX_CONF_ERROR;
    }
    conf->ed.len = 0;
    conf->ed.data = NULL;
    return conf;
}

// 合并不同层级的配置值，子层级继承父层级，并允许覆盖
static char * ngx_http_echo_merge_loc_conf(ngx_conf_t *cf, void *parent, void *child)
{
    ngx_http_echo_loc_conf_t *prev = parent;
    ngx_http_echo_loc_conf_t *conf = child;
    ngx_conf_merge_str_value(conf->ed, prev->ed, "");
    return NGX_CONF_OK;
}
```

整体流程：

**初始化阶段**
模块注册
nginx启动时读取配置文件config，通过 `ngx_http_echo_module` 结构体注册模块信息。
- `ngx_http_echo_module` 组合 nginx 各模块
	- `ngx_http_echo_module_ctx` 上下文
	- `ngx_http_echo_commands` 指令列表
	- `NGX_HTTP_MODULE` 模块类型
配置解析
nginx 解析 nginx.conf 中的 echo 指令，调用 ngx_http_echo 处理（由ngx_http_echo_commands 定义）


**请求处理阶段**
定位到模块处理
- 由于 `echo` 指令关联了 `ngx_http_echo`，Nginx 将执行该指令对应的处理逻辑。
- 执行 `ngx_http_echo_handler` 处理请求，并返回响应。

**请求处理**


配置模块 `ngx_http_echo_loc_conf_t`
指令列表 `ngx_http_echo_commands`
上下文模块，用于nginx回调 `ngx_http_echo_module_ctx` 
ngx_http_echo_create_loc_conf
ngx_http_echo_merge_loc_conf
handler模块 `ngx_http_echo_handler`



对于`echo`指令，Nginx 会调用`ngx_http_echo`函数（在`ngx_http_echo_commands`数组中定义）。该函数首先获取核心模块的位置配置`ngx_http_core_loc_conf_t`，将其`handler`设置为`ngx_http_echo_handler`，然后调用`ngx_conf_set_str_slot`函数将配置文件中`echo`指令的参数转化为`ngx_str_t`类型，并存储到模块的配置结构体`ngx_http_echo_loc_conf_t`中。

## Nginx模块的安装

Nginx不支持动态链接模块，所以安装模块需要将模块代码与Nginx源代码进行重新编译。安装模块的步骤如下：

1、编写模块config文件，这个文件需要放在和模块源代码文件放在同一目录下。文件内容如下：
1. ngx_addon_name=模块完整名称
2. HTTP_MODULES="$HTTP_MODULES 模块完整名称"
3. NGX_ADDON_SRCS="$NGX_ADDON_SRCS $ngx_addon_dir/源代码文件名"

2、进入Nginx源代码，使用下面命令编译安装

1. ./configure --prefix=安装目录 --add-module=模块源代码文件目录
2. make
3. make install

这样就完成安装了，例如，我的源代码文件放在/home/yefeng/ngxdev/ngx_http_echo下，我的config文件为：

1. ngx_addon_name=ngx_http_echo_module
2. HTTP_MODULES="$HTTP_MODULES ngx_http_echo_module"
3. NGX_ADDON_SRCS="$NGX_ADDON_SRCS $ngx_addon_dir/ngx_http_echo_module.c"

编译安装命令为：

 
 

1. ./configure --prefix=/usr/local/nginx --add-module=/home/yefeng/ngxdev/ngx_http_echo
2. make
3. sudo make install

这样echo模块就被安装在我的Nginx上了，下面测试一下，修改配置文件，增加以下一项配置：

 
 

1. location /echo {
2.     echo "This is my first nginx module!!!";
3. }

然后用curl测试一下：

 
 

1. curl -i http://localhost/echo

结果如下：

![](https://i-blog.csdnimg.cn/blog_migrate/c45dc30cdb71ee4edeb1ac71968c7dc8.png)

可以看到模块已经正常工作了，也可以在浏览器中打开网址，就可以看到结果：

![](https://i-blog.csdnimg.cn/blog_migrate/276a7e19286a62b555978a24240a3965.png)



* https://blog.csdn.net/baidu_36649389/article/details/78403566
* https://www.cnblogs.com/softidea/p/4090653.html  
* https://blog.csdn.net/stinkstone/article/details/78082748
* https://www.evanmiller.org/nginx-modules-guide.html