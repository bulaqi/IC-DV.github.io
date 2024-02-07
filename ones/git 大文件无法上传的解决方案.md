背景: git repo默认commit 设置最大为5M,超过该size后无法上传

解决方案:

1. 思路:修改git的默认配置

2. 具体方法: 解除限制git commit 文件size，

配置文件路径:xx_repo/.git/hooks/pre-commit文件

限制说明: hard-limit和soft-limit,如下图分别是5M和2M ,如果上传文件大于0-2M,正常上传,超过2M-5M会提醒,不会影响上传; 超过5M 会无法上传

修改方案: 将hard-limit默认size 调大.如,改为10000000, 即10M