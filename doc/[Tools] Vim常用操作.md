#### 1. 分屏后跳转：
ctrl+w+v,ctrl+w+s

#### 2. 替换
1. 通常我们会在命令中使用%指代整个文件做为替换范围：
~~~
:%s/search/replace/g
~~~
2. 以下命令指定只在第5至第15行间进行替换:
~~~
:5,15s/dog/cat/g
~~~
3. 以下命令指定只在当前行至文件结尾间进行替换:
~~~
:.,$s/dog/cat/g
~~~
4. 以下命令指定只在后续9行内进行替换:
~~~
:.,.+8s/dog/cat/g
~~~
你还可以将特定字符做为替换范围。比如，将SQL语句从FROM至分号部分中的所有等号（=）替换为不等号
5. 指定行行尾替换
~~~
:5,15s/$/cat/g
~~~
6. 批量缩进
  eg,光标处3行都缩进:3, shift+>(两次)
### 传送门:
https://www.cnblogs.com/gujiangtaoFuture/articles/10363988.html
[批量缩进](https://blog.csdn.net/TomorrowAndTuture/article/details/109390352#:~:text=%E6%89%B9%E9%87%8F%E7%BC%A9%E8%BF%9B%20%E6%91%81%E4%B8%8B%20Ctrl%20%2B%20v%20%E6%88%96%E8%80%85%20v%EF%BC%8C%E7%84%B6%E5%90%8E%E6%96%B9%E5%90%91%E9%94%AE%20%E2%86%90%E2%86%92%E2%86%91%E2%86%93,Shift%20%2B%20%3E%20%EF%BC%88%E6%88%96%E8%80%85%20Shift%20%2B%20%3C%20%EF%BC%89%E8%BF%9B%E8%A1%8C%E5%B7%A6%E5%8F%B3%E7%BC%A9%E8%BF%9B%E3%80%82)
