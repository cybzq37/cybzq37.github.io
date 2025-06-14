---
title: python语法
description: 编程语言, python
date:
    created: 2025-06-02
    updated: 2025-06-02
---


## 注意事项
- 1.四个空格缩进
- 2.注释：#
- 3.逻辑操作：and、or、not
- 4.函数可选参数：f(x=1)
- 5.函数注释：""" \n """

## 字符串
- 乘法："shafish" * 3
- 格式化："hello {}".format("shafish")

## 容器
- 列表（数组）：
    - 定义
        - data = list()
        - data = []
    - 注意
        - 负索引
- 元组（保存不可修改的数据）：
    - 定义
        - data = tuple()
        - data = ()
- 字典（map）：
    - 定义
        - data = dict()
        - data = {}

- 嵌套：
    - 列表中保存列表：
        - data = []
        - data1 = ["shafish","fisha"]
        - data.apend(data1)
    - 列表中添加元组：
        - data = []
        - data2 = (22.1, 188.3)
        - data.append(data2)
    - 列表中存储字典：
        - data3 = {"name":"shafish"}
        - data = [data3]
    - 元组中添加列表：
        - data3 = ["graham"]
        - data = (data3)
    - 元组中添加字典：
        - data4 = {"name":"graham"}
        - data = (data4,)
    - 列表、字典、元组都可以作为字典的value值
## 模块
- 导入：import 模块名
- 模块中不希望被别的模块导入时立刻执行的代码，放在`if __name__ == "__main__"`中
``` python
import math


math.pow(2, 3)
```
- hello.py
``` python
def print_hello():
    print("hello, shafish")
```
- project.py
``` python
import hello


hello.print_hello()
```

## 文件
``` python
with open("xxx.txt", "w") as f:
    f.write("hello, shafish")
```

## 类
- 必须接受至少一个参数，第一个参数总是被命名为self，因为调用时会自动将方法的对象作为入参
- __init__魔法方法：创建对象时执行
- 实例变量：属于对象的变量，在魔法方法中通过`self.变量名=变量值`定义
- 私有变量、私有方法：在变量获取名称前加下划线_
- 类变量可以在不使用全局变量的情况下，在类的`所有实例之间`共享数据

``` python
class Organe():
    def __init__(self, w, c):
        self.weight = w
        self.color = c
        self.mold = 0
    

    def rot(self, days, temp):
        self.mold = days * temp


orange = Orange(6, "橘色")
print(organe.mold)
orange.rot(10, 98)
print(organe.mold)
```
``` python
class Rectangle():
    recs = []


    def __init__(self, w, l):
        self.width = w
        self.len = l
        self.recs.append((self.width, self.len))


    def print_size(self):
        print("{} by {}".format(self.width, self.len))


r1 = Rectangle(10, 24)
r2 = Rectangle(20, 24)
r3 = Rectangle(30, 24)


print(Rectangle.recs)
```