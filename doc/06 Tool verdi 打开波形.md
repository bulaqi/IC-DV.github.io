### 1. 基础知识
##### 1. 命令行打开波形
  1.verdi -lib $env_repo/playground/project_lib/vcsmx/work/work.lib++ -top xxx_top
  2.verdi -elab $env_repo/playground/project_lib/vcsobj/xxxx_simv.daidir/kdb.elab++ -top xxx_top
  3.verdi -dbdir $env_repo/playground/project_lib/vcsobj/xxxx_simv.daidir
  上述几种方法都需要提前编译，也有不需要编译的方法，但是需要准备一个filelist，这种方式麻烦点而且没有特别必须的应用场景就不推举了。
#### 2. 先开ui，然后选择加载波形


#### 3. vcsmx和vcsobj 目录
1. vcsmx
   - vcsmx 文件是VCS生成的一种**数据库**文件，它包含了仿真模型的信息。
   - 当VCS进行编译时，它会分析和优化Verilog/System Verilog源代码，然后将编译后的**中间表示存储**在vcsmx文件中。
   - 这个文件对于后续的仿真运行至关重要，因为它包含了必要的信息来执行仿真。
2. vcsobj
   - 通常在这个目录下存放的是由VCS编译过程产生的各种对象文件和辅助文件。
   - 这些对象文件是编译阶段的**结果**，它们被链接在一起以形成最终的可执行仿真器。
   - vcsobj目录还可能包含其他临时文件和数据，这些对于仿真的执行和调试都是必要的。

### 2. 经验
### 3. 传送门
