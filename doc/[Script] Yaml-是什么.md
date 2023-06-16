### 1.YAML 是什么？
YAML 是一种可读性高，以数据为中心的数据序列化格式。可以表达 对象（键值对），数组，标量 这几种数据形式 能够被多种编程语言和脚本语言解析
~~~
什么是序列化？
序列化指的是将自定义的对象或者其他数据进行持久化，从而方便进行传输和存储。一般情况下，能够序列化的数据一定能够通过反序列化恢复。
~~~

### 2. YAML 语法与格式

#### 2.1 基本语法
- 以 k: v 的形式来表示键值对的关系，冒号后面必须有一个空格
-# 表示注释
- 对大小写敏感
- 通过缩进来表示层级关系，缩排中空格的数目不重要，只要相同阶层的元素左侧对齐就可以了
- 缩进只能使用空格，不能使用 tab 缩进键
- 字符串可以不用双引号
#### 2.2 格式
#### 2.3 对象和键值对
通过 k: v 的方式表示对象或者键值对，冒号后必须要加一个空格
~~~
Name: Astron
Sex: female
School: TJU
~~~
通过缩进来表示对象的多个属性：
~~~
People: 
   Name: Astron
   Sex: female
   School: TJU
~~~
也可以写成
~~~
people: {name: Astron, sex: female}
~~~

#### 2.4 数组
数组（或者列表）中的元素采用 - 表示，以 - 开头的行表示构成一个数组
eg1：
~~~
- A
- B
- C
~~~
eg2:
~~~
people: 
    - yyy
    - zzz
    - www
~~~
行内表示：
people: [yyy, zzz, www]
eg3: 对象数组
~~~
people: 
    - 
      name: yyy
      age: 18
    - 
      name: zzz
      age: 19
~~~
使用流式表示：
people: [{name: yyy, age: 18},{name: zzz, age: 19}]

#### 2.5 标量
标量是最基本的不可再分的值，包括：
- 整数
- 浮点数
- 字符串
- 布尔值
- Null
- 时间
- 日期
eg:
~~~
boolean:
   - true # 大小写都可以
   - false

float:
   - 3.14
   - 3.25e+5 # 科学计数法

int: 12

null: 
   nodeName: name

string: 123

date: 2020-01-01 # 格式为 yyyy-MM-dd

datetime: 2020-01-10T15:02:08+08:00 # 日期和时间使用T连接，+表示时区
~~~

#### 2.6 引用
& 用于建立锚点，* 用于引用锚点，<< 表示合并到当前数据
eg1:
~~~
defaults: &defaults
   adapter: ppp
   host: qqq

development: 
   database: mq
   <<: *defaults
~~~
相当于：
~~~
defaults:
   adapter: ppp
   host: qqq

development: 
   database: mq
   adapter: ppp
   host: qqq
~~~
eg2:
~~~
- &showell steve
- clark
- eve
- *showell
~~~
相当于:
~~~
- steve
- clark
- eve
- steve
~~~

### 1.3 使用场景
- 脚本语言:YAML 实现简单，解析成本低，所以特别适合在脚本语言中使用
- 序列化
- 配置文件:写 YAML 比 XML 方便，所以 YAML 也可以用来做配置文件，但是，不同语言间的数据流转不建议使用YAML。

### 1.4 传输门
[一文看懂yaml](https://zhuanlan.zhihu.com/p/145173920) \
[YAML 教程,指定显示类型](https://juejin.cn/post/7040030169670631437) 