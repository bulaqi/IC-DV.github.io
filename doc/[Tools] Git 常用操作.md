[TOC]
### 1. 概述
  git 新建分支的目的是为了多分支并行独立开发，完成后merger 到主分支

### 2. 其他常用操作
~~~
1. git stash VS  git stash pop
2. git stash list
3. git branch -vv //查看当前的本地分支与远程分支的关联关系
4. git remote -v  //当前分支所属的远程仓库地址
5. git branch -d <branchname> //删除分支
6. git checkout -b <branchname> //新建并切换至新分支,不影响远本地未add的数据
7. git pull -r --autostash
8. git show tag_name //查看该tag_name的信息
9. git tag -l //
10. gitk //git图形化界面
11. git checkout tag_name // 可能会提示你当前处于一个“detached HEAD" 状态。 tag 相当于是一个快照，是不能更改它的代码的。
12. git checkout -b branch_name tag_name //如果要在 tag 代码的基础上做修改，你需要一个分支
13. 限制git commit 文件size，配置.git/hooks/pre-commit文件，hard-limit和soft-limi
~~~

### 3. git 上库(autostash)
~~~
1. git pull -r --autostash   //(git pull --rebase --autostash) autostash 选项自动隐藏并弹出未提交的更改
    //git stash
    //git  pull -r  //rebase
   //git stash popm
   //补充命令：git stash list
2. 解冲突
3. git add . // 解冲后，一般退到resbase状态，需要重新add commit
4. git commit -m "modify"
5. git push  origin master   
6. 备注：原型git push <远程主机名> <本地分支名>:<远程分支名>，如果分支名称一致，可以以省略冒号，eg:it push <远程主机名> <本地分支名>
~~~

### 4. git撤销、还原、放弃本地文件修改
1. 未使用git add 缓存代码
2. 已使用git add 缓存代码，未使用git commit
   ~~~
   git reset HEAD filepathname
   git reset HEAD   //放弃所有文件修改 (相当于撤销 git add 命令所在的工作。)

   // 补充知识
   git reset --soft HEAD    //参数用于回退到某个版本
   git reset --hard HEAD    //--hard 参数撤销工作区中所有未提交的修改内容，将暂存区与工作区都回到上一次版本，并删除之前的所有信息提交：
   git reset HEAD^            # 回退所有内容到上一个版本  
   git reset HEAD^^            # 回退所有内容到上上一个版本  
   ~~~
3. 已经用 git commit 提交了代码
   ~~~
   使用 git reset --hard HEAD^来回退到上一次commit的状态
   git reset --hard HEAD^
   git reset --hard commitid，或者回退到任意版本，使用git log命令查看git提交历史和commitid
   ~~~
   备注:使用本命令后，本地的修改并不会消失，而是回到了第一步1；未使用git add 缓存代码，继续使用git checkout -- filepathname，就可以放弃本地修改

4. 已经用 git commit 提交了代码
   ~~~
   使用 git reset --hard HEAD^来回退到上一次commit的状态
   git reset --hard HEAD^
   git reset --hard commitid，或者回退到任意版本，使用git log命令查看git提交历史和commitid
   ~~~
   
### 5. 多分支互不干扰方案
1. 方法1,拉2个分支,独立工作 (推荐)
   ~~~
   1. 本地已有分支dev，写了需求a，先commit，即将工作区的内容提交到版本库中，否则切换到其他分支时，就会覆盖当前工作区的代码。（这步很重要）
   2. 在本地创建dev_bug分支，从远程dev分支中check（git checkout -b dev_bug origin/dev）
   3. 在本地dev_bug上修改bug，并commit、push到远程dev上
   4. 在本地变换到dev，继续做需求a
   ~~~
2. 方法2,stash 暂存
   ~~~
   1. 本地已有分支dev，写了需求a，但是不要提交。
   2. 执行git stash命令，将工作区的内容“储存起来”
   3. 接着在dev分支上修改bug，并提交，push
   4. 执行git stash pop，恢复工作区原来的内容
   ~~~

### 6. 拉分支
1. 场景:本地已经创建了分支dev（以dev为例，下同），而远程没有
   ~~~
   方法1： git push -u origin dev
   方法2： git push --set-upstream origin dev
   ~~~
2. 场景:远程已经创建了分支dev,而本地没有
   ~~~
   在pull远程分支的同时，创建本地分支并与之进行关联
   git pull origin dev:dev-------两个dev分别表示远程分支名：本地分支名
   ~~~
3. 场景:远程已经创建了分支dev,而本地新建分支需要关联 远端分支
   ~~~
   git branch -u origin/分支名   其中origin/分支名 中分支名 为远程分支名
   或者
   git branch --set-upstream-to origin/分支名  
   ~~~
### 7. 个人案例
#### 案例 1
   1. 问题：pull 后提示本地AEM分支比origin aem分支新，本地有3次commit，所以pull后到rebase状态
   2. 解决方法：
      ~~~
      git rebase --abort
      git status // 提示本地分支比远端分支 新
      git reset --soft HEAD^
      git status //提示本地分支和远端分支 一致了
      git commit -m "add xx"
      git push //更新至远端
      ~~~


### 8. 传送门
1. [git操作本地和远程仓库 新建分支 切换分支 合并分支 解决冲突](https://link.zhihu.com/?target=https%3A//javaweixin6.blog.csdn.net/article/details/105884936%3Fspm%3D1001.2101.3001.6650.6%26utm_medium%3Ddistribute.pc_relevant.none-task-blog-2%257Edefault%257EBlogCommendFromBaidu%257ERate-6-105884936-blog-75213159.pc_relevant_3mothn_strategy_and_data_recovery%26depth_1-utm_source%3Ddistribute.pc_relevant.none-task-blog-2%257Edefault%257EBlogCommendFromBaidu%257ERate-6-105884936-blog-75213159.pc_relevant_3mothn_strategy_and_data_recovery%26utm_relevant_index%3D7)
2. [腾讯技术工程：这才是真正的Git——Git内部原理揭秘！](https://zhuanlan.zhihu.com/p/96631135)
3. [git reset 命令 | 菜鸟教程](https://link.zhihu.com/?target=https%3A//www.runoob.com/git/git-reset.html)
4. [git本地创建多个分支互不干扰](https://www.cnblogs.com/BonnieWss/p/10711835.html)
5. [git撤销、还原、放弃本地文件修改](https://link.zhihu.com/?target=https%3A//blog.csdn.net/qq_27674439/article/details/121124869)