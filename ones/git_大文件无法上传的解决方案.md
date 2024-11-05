### 背景: git repo默认commit 设置最大为5M,超过该size后无法上传

1. 思路:修改git的默认配置
2. 前提已安装lfs 支持(只有安装LFS才会创建xx_repo/.git/hooks/pre-commit等文件)
   ~~~
   git lfs install
   ~~~
3. 具体方法: 解除限制git commit 文件size，
    - 配置文件路径:xx_repo/.git/hooks/pre-commit文件
    - 限制说明: hard-limit和soft-limit,如下图分别是5M和2M ,如果上传文件大于0-2M,正常上传,超过2M-5M会提醒,不会影响上传; 超过5M 会无法上传
    - eg:修改方案: 将hard-limit默认size 调大.如,改为10000000, 即10M
        ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/d9c65166-9fcd-4894-a9eb-02fa8a66bf86)
### 2. 经验
1. 临时方案，git 命令
    ~~~
    git config hooks.filesizehardlimit 20000000
    git config hooks.filesizesoftlimit 2000000
    ~~~
2. 实测，github 无效，
3. gitcode 设置
	- 本地git 的限制放开
   		 -  ![image](https://github.com/user-attachments/assets/007320c2-3475-4109-b9b9-613106720acc)

        - 新增code
	        ~~~
	          [hooks]
	      	  	filesizehardlimit = 2000000000
	        ~~~
        - 不确定是否需要适配，:xx_repo/.git/hooks/pre-commit
	- git 仓 的设置
		- ![image](https://github.com/user-attachments/assets/0d1d33a0-5df6-4bb6-9ad2-fd490001d5d5)


### 3. 传送门
1. [Git禁止大文件提交到仓库中](https://cloud.tencent.com/developer/article/1559399)
2. [保姆级教程：如何在 GitHub 上传大文件](https://blog.csdn.net/wzk4869/article/details/131661472)
