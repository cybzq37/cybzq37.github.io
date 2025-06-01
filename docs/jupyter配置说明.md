 `conda` 环境配置文件 `environment.yml`
```yaml
name: ai
channels:
  - conda-forge
  - defaults
dependencies:
  - python=3.12
  - pip
  - psutil
  - jupyter
  - pandas
  - numpy
  - openpyxl
  - matplotlib
  - pytorch
```
执行 `conda env create -f environment.yml` 进行安装

生成配置文件, windows 一般在 `%USERPROFILE%\.jupyter` 目录
```bash
jupyter notebook --generate-config
```

配置文件说明 `jupyter_notebook_config.py` 
```python
c.NotebookApp.ip = '0.0.0.0'           # 允许远程访问（如绑定所有 IP）
c.NotebookApp.port = 8888              # 默认端口为 8888，可自行指定
c.NotebookApp.open_browser = False     #禁止自动打开浏览器
c.NotebookApp.notebook_dir = '/path/to/notebooks'    # 默认工作目录

''' 生成哈希密码
	from notebook.auth import passwd
	passwd()
'''
c.NotebookApp.password = '' #哈希密码,空字符串表示不使用密码
c.NotebookApp.token = ''    # 空字符串表示关闭 token 认证
c.NotebookApp.disable_check_xsrf = True
c.NotebookApp.certfile = u'/path/to/your/cert.pem'   # https配置
c.NotebookApp.keyfile = u'/path/to/your/key.key'
```

启动
```bash
jupyter notebook
# 可以指定读取配置文件
jupyter notebook --config=/full/path/to/jupyter_notebook_config.py
```

界面说明
![[assets/jupyter_panel_1.png]]
![[assets/jupyter_pancel_2.png]]

单元格共有两种类型: `Code` 和 `Markdown`

插件安装

