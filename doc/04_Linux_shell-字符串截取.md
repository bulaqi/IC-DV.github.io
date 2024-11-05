![image](https://user-images.githubusercontent.com/55919713/225523927-0f6d07c2-c3d7-4892-9aec-b77c4e102a68.png)

示例:
~~~
#!/bin/bash

# #：从左向右，截取匹配字符串剩余字符为结果
str1="foodforthought.jpg"
echo ${str1##*fo}  #结果： rthought.jpg
echo ${str1#*fo}   #结果： odforthought.jpg

# %：从左向右，截取匹配字符串剩余字符为结果
str2="chickensouo.tar.gz"
echo ${str2%%.*}   #结果：chickensouo
echo ${str2%.*}    #结果：chickensouo.tar
~~~