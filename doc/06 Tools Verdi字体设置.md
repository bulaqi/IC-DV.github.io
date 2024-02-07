[TOC]
### 1. 设置verdi 字体步骤
1. 如果本地home下有.fonts文件件.先删除, 然后拷贝字库目录到个人的home下, cp  -rf  /nfs/common/park/huangshuai03/.fonts  ~
2. 拷字体设置脚本.fonts_patch.sh到个人home下, cp  -rf  /nfs/common/park/huangshuai03/.fonts_patch ~
3. 在个人home下运行脚本fonts_patch
4. 打开verdi 设置需要的字体,方法如下 \
   [Verdi 改变字体大小方法](https://blog.csdn.net/qq_39876540/article/details/124734539#:~:text=%E5%9C%A8%E5%90%AF%E7%94%A8v%20erd%20i%E7%9C%8B%E4%BB%A3%E7%A0%81%E5%92%8C%E6%B3%A2%E5%BD%A2%E8%BF%9B%E8%A1%8Cdebug%E6%97%B6%EF%BC%8C%E6%98%BE%E7%A4%BA%E7%9A%84%E5%AD%97%E4%BD%93%E4%B8%80%E8%88%AC%E4%BC%9A%E5%BE%88%E5%B0%8F%E3%80%82%20%E8%B0%83%E6%95%B4%E7%9A%84%20%E6%96%B9%E6%B3%95%20%E6%98%AF%EF%BC%9A%20%E7%82%B9%E5%BC%80%E8%8F%9C%E5%8D%95%E6%A0%8F%E4%B8%AD%E7%9A%84Tools-%3EPreferences,%E7%84%B6%E5%90%8E%E5%A6%82%E5%9B%BE%E6%89%80%E7%A4%BA%EF%BC%8C%E9%80%89%E6%8B%A9General%2C%E5%86%8D%E9%80%89%E6%8B%A9Font%20and%20Size.%20%E5%9C%A8%E5%8F%B3%E4%BE%A7%E7%9A%84%E4%B8%A4%E4%B8%AAchoose%20Font%E4%B8%AD%E5%B0%B1%E5%8F%AF%E4%BB%A5%20%E6%94%B9%E5%8F%98%20%E4%BB%A3%E7%A0%81%E3%80%81%E6%B3%A2%E5%BD%A2%E7%AD%89%E7%9A%84%E6%98%BE%E7%A4%BA%E5%A4%A7%E5%B0%8F%E4%BA%86%E3%80%82)

5. 拷贝verid执行命令命令下的novas.rc文件 到个人home目录下
6. 修改个人.cshrc文件,使配置长期有效,添加一行
~~~
setenv NOVAS_RC  ~/novas.rc
~~~
7. 重新source .cshrc使配置生效

### 2. 补充说明
1. linux 环境重启后,只需要运行home下的fonts_patch 脚本,无其他操作

###  3. 参考
1. [Verdi 改变字体大小方法](https://blog.csdn.net/qq_39876540/article/details/124734539#:~:text=%E5%9C%A8%E5%90%AF%E7%94%A8v%20erd%20i%E7%9C%8B%E4%BB%A3%E7%A0%81%E5%92%8C%E6%B3%A2%E5%BD%A2%E8%BF%9B%E8%A1%8Cdebug%E6%97%B6%EF%BC%8C%E6%98%BE%E7%A4%BA%E7%9A%84%E5%AD%97%E4%BD%93%E4%B8%80%E8%88%AC%E4%BC%9A%E5%BE%88%E5%B0%8F%E3%80%82%20%E8%B0%83%E6%95%B4%E7%9A%84%20%E6%96%B9%E6%B3%95%20%E6%98%AF%EF%BC%9A%20%E7%82%B9%E5%BC%80%E8%8F%9C%E5%8D%95%E6%A0%8F%E4%B8%AD%E7%9A%84Tools-%3EPreferences,%E7%84%B6%E5%90%8E%E5%A6%82%E5%9B%BE%E6%89%80%E7%A4%BA%EF%BC%8C%E9%80%89%E6%8B%A9General%2C%E5%86%8D%E9%80%89%E6%8B%A9Font%20and%20Size.%20%E5%9C%A8%E5%8F%B3%E4%BE%A7%E7%9A%84%E4%B8%A4%E4%B8%AAchoose%20Font%E4%B8%AD%E5%B0%B1%E5%8F%AF%E4%BB%A5%20%E6%94%B9%E5%8F%98%20%E4%BB%A3%E7%A0%81%E3%80%81%E6%B3%A2%E5%BD%A2%E7%AD%89%E7%9A%84%E6%98%BE%E7%A4%BA%E5%A4%A7%E5%B0%8F%E4%BA%86%E3%80%82) 
2. [verdi工具的字体大小无法调节](https://blog.csdn.net/qq_44404407/article/details/125130511?spm=1001.2101.3001.6661.1&utm_medium=distribute.pc_relevant_t0.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-1-125130511-blog-107100592.235%5Ev35%5Epc_relevant_yljh&depth_1-utm_source=distribute.pc_relevant_t0.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-1-125130511-blog-107100592.235%5Ev35%5Epc_relevant_yljh&utm_relevant_index=1)
