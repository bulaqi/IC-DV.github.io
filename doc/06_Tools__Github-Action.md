#### 1. Github Action 是什么？
是 Github 推出的持续集成工具
#### 2. 持续集成是什么？
简单说就是自动化的打包程序——如果是前端程序员，这样解释比较顺畅：
每次提交代码到 Github 的仓库后，Github 都会自动创建一个虚拟机（Mac / Windows / Linux 任我们选），来执行一段或多段指令（由我们定），例如：
~~~
npm install
npm run build
~~~
#### 3. Yaml 是什么？
我们集成 Github Action 的做法，就是在我们仓库的根目录下，创建一个 .github 文件夹，里面放一个 *.yaml 文件——这个 Yaml 文件就是我们配置 Github Action 所用的文件。
它是一个非常容易地脚本语言，如果我们不会的话，也没啥大事继续往下看就成了。
参考文档：[五分钟学习 YAML](https://link.zhihu.com/?target=https%3A//www.codeproject.com/Articles/1214409/Learn-YAML-in-five-minutes)
#### 4. Github Action 的使用限制
- 每个 Workflow 中的 job 最多可以执行 6 个小时
- 每个 Workflow 最多可以执行 72 小时
- 每个 Workflow 中的 job 最多可以排队 24 小时
- 在一个存储库的所有 Action 中，一个小时最多可以执行 1000 个 API 请求
- 并发工作数：Linux：20，Mac：5（专业版可以最多提高到 180 / 50）
#### 5. 什么是 Workflow？
Workflow 是由一个或多个 job 组成的可配置的自动化过程。我们通过创建 YAML 文件来创建 Workflow 配置。
#### 5.1 如何定义 Workflow 的名字？
~~~
name
~~~
Workflow 的名称，Github 在存储库的 Action 页面上显示 Workflow 的名称。
如果我们省略 name，则 Github 会将其设置为相对于存储库根目录的工作流文件路径。
~~~
name: Greeting from Mona
on: push
~~~
#### 5.2 如何定义 Workflow 的触发器？
~~~
on
~~~
触发 Workflow 执行的 event 名称，比如：每当我提交代码到 Github 上的时候，或者是每当我打 TAG 的时候。
~~~
// 单个事件
on: push

// 多个事件
on: [push,pull_request]
~~~
事件大全：[https://docs.github.com/en/acti](https://link.zhihu.com/?target=https%3A//docs.github.com/en/actions/reference/events-that-trigger-workflows%23about-workflow-events)
#### 5.3 Workflow 的 job 是什么？
答：一个 Workflow 由一个或多个 jobs 构成，含义是一次持续集成的运行，可以完成多个任务。
##### 5.3.1 如何定义一个 job？
~~~
jobs:
  my_first_job:
    name: My first job
  my_second_job:
    name: My second job
~~~
答：通过 job 的 id 定义。
每个 job 必须具有一个 id 与之关联。
上面的 my_first_job 和 my_second_job 就是 job_id。
##### 5.3.2 如何定义 job 的名称？
~~~
jobs.<job_id>.name
~~~
name 会显示在 Github 上
##### 5.3.3 如何定义 job 的依赖？job 是否可以依赖于别的 job 的输出结果？
~~~
jobs.<job_id>.needs
~~~
答：needs 可以标识 job 是否依赖于别的 job——如果 job 失败，则会跳过所有需要该 job 的 job。
~~~
jobs:
  job1:
  job2:
    needs: job1
  job3:
    needs: [job1, job2]
~~~
~~~
jobs.<jobs_id>.outputs：用于和 need 打配合，outputs 输出=》need 输入
~~~
jobs 的输出，用于和 needs 打配合：可以看到 ouput
~~~
jobs:
  job1:
    runs-on: ubuntu-latest
    # Map a step output to a job output
    outputs:
      output1: ${{ steps.step1.outputs.test }}
      output2: ${{ steps.step2.outputs.test }}
    steps:
    - id: step1
      run: echo "::set-output name=test::hello"
    - id: step2
      run: echo "::set-output name=test::world"
  job2:
    runs-on: ubuntu-latest
    needs: job1
    steps:
    - run: echo ${{needs.job1.outputs.output1}} ${{needs.job1.outputs.output2}}
~~~
##### 5.3.4 如何定义 job 的运行环境？
~~~
jobs.<job_id>.runs-on
~~~
指定运行 job 的运行环境，Github 上可用的运行器为：
- windows-2019
- ubuntu-20.04
- ubuntu-18.04
- ubuntu-16.04
- macos-10.15
~~~
jobs:
  job1:
    runs-on: macos-10.15
  job2:
    runs-on: windows-2019
~~~
##### 5.3.5 如何给 job 定义环境变量？
~~~
jobs.<jobs_id>.env
~~~
~~~
jobs:
  job1:
    env:
      FIRST_NAME: Mona
~~~
##### 5.3.6 如何使用 job 的条件控制语句？
~~~
jobs.<job_id>.if
~~~
我们可以使用 if 条件语句来组织 job 运行


#### 5.4 Step 属性是什么？
答：每个 job 由多个 step 构成，它会从上至下依次执行。
step 运行的是什么？
step 可以运行：
- commands：命令行命令
- setup tasks：环境配置命令（比如安装个 Node 环境、安装个 Python 环境）
- action（in your repository, in public repository, in Docker registry）：一段 action（Action 是什么我们后面再说）\
**每个 step 都在自己的运行器环境中运行，并且可以访问工作空间和文件系统**  
因为每个 step 都在运行器环境中独立运行，所以 **step 之间不会保留对环境变量的更改。**
~~~
# 定义 Workflow 的名字
name: Greeting from Mona

# 定义 Workflow 的触发器
on: push

# 定义 Workflow 的 job
jobs:
  # 定义 job 的 id
  my-job:
    # 定义 job 的 name
    name: My Job
    # 定义 job 的运行环境
    runs-on: ubuntu-latest
    # 定义 job 的运行步骤
    steps:
    # 定义 step 的名称
    - name: Print a greeting
      # 定义 step 的环境变量
      env:
        MY_VAR: Hi there! My name is
        FIRST_NAME: Mona
        MIDDLE_NAME: The
        LAST_NAME: Octocat
      # 运行指令：输出环境变量
      run: |
        echo $MY_VAR $FIRST_NAME $MIDDLE_NAME $LAST_NAME.
~~~
#### 5.5 Action 是什么？
我们可以直接打开下面的 Action 市场来看看：\
[httpsithub.com/marketplace?type=actions://github.com/marketplace?type=actions
​github.com/marketplace?type=actions](https://github.com/marketplace?type=actions) \
Action 其实就是命令，比如 Github 官方给了我们一些默认的命令：\
https://github.com/marketplace?type=actions&query=actions \
比如最常用的，check-out 代码到 Workflow 工作区：\
https://link.zhihu.com/?target=https%3A//github.com/marketplace/actions/checkout

#### 5.5.1 我们应该如何使用 Action？
~~~
jobs.<job_id>.steps.uses
~~~
比如我们可以 check-out 仓库中最新的代码到 Workflow 的工作区：
~~~
steps:
  - uses: actions/checkout@v2
~~~
当然，我们还可以给它添加个名字：
~~~
steps:
  - name: Check out Git repository
    uses: actions/checkout@v2
~~~
再比如说，我们如果是 node 项目，我们可以安装 Node.js 与 NPM：
~~~
steps:
- uses: actions/checkout@v2
- uses: actions/setup-node@v2-beta
  with:
    node-version: '12'
~~~


#### 5.5.2 上面我们为什么要用：@v2 和 @v2-beta 呢？
答：首先，正如大家所想，这个 @v2 和 @v2-beta 的意思都是 Action 的版本。
我们如果不带版本号的话，其实就是默认使用最新版本的了。
但是 Github 官方强烈要求我们带上版本号——这样子的话，我们就不会出现：写好一个 Workflow，但是由于某个 Action 的作者一更新，我们的 Workflow 就崩了的问题。
#### 5.5.3 上面的 with 参数是什么意思？
答：有的 Action 可能会需要我们传入一些特定的值：比如上面的 node 版本啊之类的，这些需要我们传入的参数由 with 关键字来引入。\
具体的 Action 需要传入哪些参数，还请去 Github Action Market 中 Action 的页面中查看。
具体库的使用和参数，我们可以去官方的 Action 市场查看 \
https://link.zhihu.com/?target=https%3A//github.com/marketplace/actions/
#### 5.6 我们如何运行命令行命令？
~~~
jobs.<job_id>.steps.run
~~~
上文说到，**steps 可以运行：action 和 command-line programs**。
我们现在已经知道**可以使用 uses 来运行 action 了**，那么我们该如何运行 command-line programs 呢？
答案是：run
run 命令在默认状态下会启动一个没有登录的 shell 来作为命令输入器。
##### 5.6.1 如何运行多行命令？
每个 run 命令都会启动一个新的 shell，所以我们执行多行连续命令的时候需要写在同一个 run 下：
- 单行命令
~~~
- name: Install Dependencies
  run: npm install
~~~
- 多行命令
~~~
- name: Clean install dependencies and build
  run： |
    npm ci
    npm run build
~~~
##### 5.6.2 如何指定 command 运行的位置？
使用 working-directory 关键字，我们可以指定 command 的运行位置
~~~
- name: Clean temp directory
  run: rm -rf *
  working-directory: ./temp
~~~
##### 5.6.3 如何指定 shell 的类型？（使用 cmd or powershell or python？？）
使用 shell 关键字，来指定特定的 shell：
~~~
steps:
  - name: Display the path
    run: echo $PATH
    shell: bash
~~~
下面是各个系统支持的 shell 类型：
![image](https://user-images.githubusercontent.com/55919713/236362864-42bc34b7-b9c0-434a-8dba-624ef3ed2723.png)


#### 5.7 什么是矩阵？
答：就是有时候，我们的代码可能编译环境有多个。比如 electron 的程序，我们需要在 macos 上编译 dmg 压缩包，在 windows 上编译 exe 可执行文件。

这种时候，我们使用矩阵就可以啦~

比如下面的代码，我们使用了矩阵指定了：2 个操作系统，3 个 node 版本。

这时候下面这段代码就会执行 6 次—— 2 x 3 = 6！！！
~~~
runs-on: ${{ matrix.os }}
strategy:
  matrix:
    os: [ubuntu-16.04, ubuntu-18.04]
    node: [6, 8, 10]
steps:
  - uses: actions/setup-node@v1
    with:
      node-version: ${{ matrix.node }}
~~~


