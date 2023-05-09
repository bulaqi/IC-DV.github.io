#### 一、LSF 基本介绍
LSF（Load Sharing Facility）是IBM旗下的一款分布式集群管理系统软件，负责计算资源的管理和批处理作业的调度。它给用户提供统一的集群资源访问接口，让用户透明地访问整个集群资源。\
LSF的功能和命令非常多，这里主要介绍普通用户常用命令，更详细的命令文档参见 \
https://www.ibm.com/docs/en/spectrum-lsf/10.1.0?topic=reference-command
#### 二、提交作业
与PBS不同，大部分情况下，可以不需要写作业脚本，直接一行命令就可以提交作业：
~~~
bsub -J blast -n 10 -R span[hosts=1] -o %J.out -e %J.err -q normal "blastn -query ./ZS97_cds.fa -out ZS97_cds -db ./MH63_cds -outfmt 6 -evalue 1e-5 -num_threads \$LSB_DJOB_NUMPROC"
~~~
##### 1.LSF作业脚本1-串行作业（单节点）
LSF中用户运行作业的主要方式为，编写LSF作业脚本，使用bsub命令提交作业脚本。如下所示为使用LSF脚本blastn.lsf
~~~
#BSUB -J blast         ### -J 指定作业名称
#BSUB -n 10            ### -n 作业使用核心数，LSF中一般称之为slot
#BSUB -R span[hosts=1] ### 指定作业只能在单个节点运行，不能跨节点
#BSUB -o %J.out        ###  作业标准输出
#BSUB -e %J.err        ###  作业错误输出
#BSUB -q normal        ### 作业提交的作业队列
time blastn -query ./ZS97_cds.fa -out ZS97_cds -db ./MH63_cds -outfmt 6 -evalue 1e-5 -num_threads $LSB_DJOB_NUMPROC
~~~
或者可以提交作业blastn.lsf
~~~
bsub < blastn.lsf
~~~
脚本中每行内容解释：
- -J 指定作业名称
- -n 作业使用核心数，LSF中一般称之为slot
- -R span[hosts=1] 指定作业只能在单个节点运行，不能跨节点（跨节点作业需要MPI支持，生物中比较少），-R 可以使得作业在需要满足某种条件的节点上运行
- -o 作业标准输出，%J为作业ID，即此处的作业输出文件为 jobid.out
- -e 作业错误输出，%J为作业ID，即此处的作业输出文件为 jobid.err
- **-q 作业提交的作业队列** \
$LSB_DJOB_NUMPROC 为LSF系统变量，表示作业脚本申请的CPU核心数 \
另外还有一些常用选项：
- -M 内存控制参数，作业占用的内存超过其指定值时，作业会被系统杀掉。如 -M 20GB -R "rusage[mem=20GB]" 申请20GB的内存，且其内存使用量不能超过20G
- **-m 指定作业运行节点**
- -W hh:mm 设置作业运行时间
- -w 作业依赖，方便写流程，如-w "done(JobA)"，作业名为JobA的作业完成之后，该作业才开始运行；[作业依赖详细用法](https://link.zhihu.com/?target=https%3A//www.ibm.com/support/knowledgecenter/en/SSWRJV_10.1.0/lsf_admin/job_dep_sched.html)
- -K 提交作业并等待作业结束，在写流程时会用得上，可以见后面的例子
- -P 指定project name，如果我们需要统计某个项目消耗的计算资源，如CPU时等，可以将相关的作业都指定为同一个project name，然后根据project name统计资源消耗
- -r rerun选项，即作业失败后自动重新运行，提交大量作业时此选项比较有用
- **-I 非交互式模式,此时终端不能输入**

##### 2.LSF作业脚本2-并行作业（多节点）
~~~
#BSUB -J MPIJob       	### set the job Name
#BSUB -q normal        	### specify queue
#BSUB -n 400           	### ask for number of cores (default: 1)
#BSUB -R "span[ptile=20]"  	### ask for 20 cores per node
#BSUB -W 10:00        	### set walltime limit: hh:mm
#BSUB -o stdout_%J.out  	### Specify the output and error file. %J is the job-id 
#BSUB -e stderr_%J.err  	### -o and -e mean append, -oo and -eo mean overwrite 
 
# here follow the commands you want to execute
 
# load the necessary modules
# NOTE: this is just an example, check with the available modules
module load intel/2018.4
module load mpi/intel/2018.4
 
### This uses the LSB_DJOB_NUMPROC to assign all the cores reserved
### This is a very basic syntax. For more complex examples, see the documentation
mpirun -np $LSB_DJOB_NUMPROC ./MPI_program
~~~
此脚本申请400核，每个节点20个核。\
多节点并行作业需要程序本身支持，使用mpirun等MPI命令运行，绝大部分生物软件不支持多节点并行。如不确定程序是否支持多节点并行，请勿使用，避免资源浪费。\
使用系统范围的intelmpi / openmpi时，可以省略-np $ LSB_DJOB_NUMPROC命令，因为程序会自动获取有关核心总数的信息。如果使用不同的MPI库，可能需要明确指定MPI的数量 以这种方式在命令行上进行处

#### 三、LSF批量提交作业及注意事项
以跑多样本的STAR为例，将下面的脚本保存为run_STAR.sh，运行该脚本，即可同时提交一批作业，而不用一个个手动提交。如果对作业需要消耗的资源不是很清楚的用户，建议在提交批量作业前，先用交互模式跑一个，看看资源消耗情况，然后再合理申请资源，使用诸如-n 4 -M 20GB -R "rusage[mem=20GB]" 等选项，限制每个作业占用的资源，避免多个作业挤在一个节点，导致节点负载过高或内存耗尽而崩溃。
~~~
for sample in /public/home/test/haoliu/work/lsf_bwait/raw_data/*trim_1.fq.gz;do
 
index=$(basename $sample |sed 's/_trim_1.fq.gz//')
prefix=$(dirname $sample)
 
star_index=/public/home/test/haoliu/work/lsf_bwait/star/
gtf=/public/home/test/haoliu/work/lsf_bwait/MH63.gtf
 
 
bsub  -J ${index} -n 8 -o %J.${index}.out -e %J.${index}.err -R span[hosts=1] \
   "STAR --runThreadN 8 --genomeDir ${star_index} --readFilesIn ${prefix}/${index}_trim_1.fq.gz  ${prefix}/${index}_trim_2.fq.gz  --outFileNamePrefix ${index}. --sjdbGTFfile $gtf"
sleep 10
done
~~~
#### 四、LSF提交批量流程作业
生信中经常会遇到需要跑大量作业以及复杂流程的情况，特别是当流程中使用的软件为多线程和单线程混杂时，如果把所有流程步骤写到同一个shell脚本，并按多线程需要的线程数来申请CPU 核心数，无疑会造成比较大的浪费。\
在此建议将流程中的主要运行步骤直接用bsub提交，按需要申请核心数、内存等，需要用上文中提到的bsub的 -K 参数。\
这里写了一个跑RNA-Seq流程的example，主要是2个脚本，RNA.sh 为具体处理每个样本的流程脚本，在batch_run.sh 对每个样本都提交运行RNA.sh脚本。\
使用时，提交batch_run.lsf脚本即可, bsub < batch_run.lsf \
RNA.sh
~~~
#!/bin/sh
sample=$1
 
index=$(basename $sample |sed 's/_trim_1.fq.gz//')
prefix=$(dirname $sample)
 
star_index=/public/home/test/haoliu/work/lsf_bwait/star/
gtf=/public/home/test/haoliu/work/lsf_bwait/MH63.gtf
 
 
bsub -K -J STAR1 -n 8 -o %J.STAR1.out -e %J.STAR1.err -R span[hosts=1] "module purge;module load STAR/2.6.0a-foss-2016b;STAR --runThreadN 8 --genomeDir ${star_index} \
--readFilesIn ${prefix}/${index}_trim_1.fq.gz  ${prefix}/${index}_trim_2.fq.gz \
--outSAMtype SAM --readFilesCommand zcat --alignIntronMax 50000 --outFileNamePrefix ${index}. --sjdbGTFfile $gtf  --outReadsUnmapped None"
 
 
bsub -K -J STAR2 -n 1 -o %J.STAR2.out -e %J.STAR2.err -R span[hosts=1] "grep -E '@|NH:i:1' ${index}.Aligned.out.sam >${index}.Aligned.out.uniq.sam"
 
bsub -K -J STAR3 -n 2 -o %J.STAR3.out -e %J.STAR3.err -R span[hosts=1] "module purge;module load SAMtools/1.3;samtools sort -@2  ${index}.Aligned.out.uniq.sam > ${index}.Aligned.out.bam"
 
rm ${index}.Aligned.out.sam
 
rm ${index}.Aligned.out.uniq.sam
 
rm ${index}.Aligned.out.uniq.bam
 
bsub -K -J STAR4 -n 1 -o %J.STAR4.out -e %J.STAR4.err -R span[hosts=1] "module purge;module load HTSeq/0.8.0;htseq-count -f bam -s no ${index}.Aligned.out.bam -t gene $gtf >${index}.G
~~~
batch_run.lsf
~~~
#BSUB -J STAR
#BSUB -n 1
#BSUB -R span[hosts=1]
#BSUB -o %J.out
#BSUB -e %J.err
 
for sample in /public/home/test/haoliu/work/lsf_bwait/raw_data/*trim_1.fq.gz;do
	index=$(basename $sample |sed 's/_trim_1.fq.gz//')
	sh RNA.sh ${sample} &
        sleep 10
done
wait
~~~
#### 五、LSF交互作业
类似于PBS中的qsub -I，为了防止滥用（开了之后长期不关等）交互模式，目前只允许在interactive队列使用交互模式，且时间限制为48h，超时会被杀掉。
~~~
bsub -q interactive -Is bash
~~~
也可以
~~~
bsub -q interactive -Is sh
~~~
此时不会加载~/.bashrc 如果需要进行图形转发，如画图等，可以加-XF 参数
~~~
bsub -q interactive -XF -Is bash
~~~
#### 六、查询作业
使用bjobs查看作业信息 \
![image](https://user-images.githubusercontent.com/55919713/236450158-a6b6a27a-5e8f-42ab-9f7f-a734600845b9.png)
可以查看作业的运行状态、队列、提交节点、运行节点及核心数、作业名称、提交时间，作业状态主要有:
- PEND 正在排队
- RUN 正在运行
- DONE 正常退出
- EXIT 异常退出
- SSUSP 被系统挂起
- USUSP 被用户自己挂起
bjobs还有一些常用的选项，
- -r 查看正在运行的作业
- -pe 查看排队作业
- -p 查看作业排队的原因
- -l 查看作业详细信息
- -sum 查看所有未完成作业的汇总信息
![image](https://user-images.githubusercontent.com/55919713/236450434-4945fdf7-803a-4629-89e1-2613c39c26a7.png)

#### 七、修改排队作业运行参数
- bmod可更改正在排队的作业的多个参数，如
- bmod -n 2 jobid 更改作业申请的核心数
- bmod -q q2680v2 jobid 更改作业运行队列
#### 八、挂起/恢复作业
- 用户可自行挂起或者继续运行被挂起的作业，
- bstop jobid 挂起作业，如被系统挂起（节点超负荷系统会自动挂起该节点上的部分作业），则作业状态为SSUSP；如被用户自己或管理员挂起，则作业状态为USUSP
- bresume bjoid 继续运行被挂起的作业
#### 九、调整排队作业顺序
- bbot jobid 将排队的作业移动到队列最后（bottom）
- btop jobid 将排队的作业移动到队列最前（top）
#### 十、查询输出文件
在作业完成之前，输出文件out和error被保存在系统文件中无法查看，可以使用bpeek命令查看输出文件
#### 十一、终止作业
如果用户要在作业提交后终止自己的作业，可以使用bkill命令，用法为bkill jobid。非root用户只能查看、删除自己提交的作业。
#### 十二、资源查看
##### 1. bhosts查看所有节点核心数使用情况
![image](https://user-images.githubusercontent.com/55919713/236450603-190ecbd2-b2ca-412a-bbb1-5d431c64abbf.png)
- HOST_NAME 节点名称
- STATUS： ok：表示可以接收新作业，只有这种状态可以接受新作业 closed：表示已被作业占满，不接受新作业 unavail和unreach：系统停机或作业调度系统服务有问题
- JL/U 每个用户在该节点最多能使用的核数，- 表示没有限制
- MAX 最大可以同时运行的核数
- NJOBS 当前所有运行和待运行作业所需的核数
- RUN 已经开始运行的作业占据的核数
- SSUSP 系统所挂起的作业所使用的核数
- USUSP 用户自行挂起的作业所使用的核数
- RSV 系统为你预约所保留的核数
##### 2. lsload查看所有节点的负载、内存使用等
![image](https://user-images.githubusercontent.com/55919713/236450717-ada1fb1d-8d45-4bf4-8576-fb5699d44da7.png)
##### 3. bqueue查看队列信息 
- -l 查看队列的详细信息 
- -u 查看所用所能使用的队列
- -m 查看节点所在的队列
![image](https://user-images.githubusercontent.com/55919713/236450750-716c96fa-dddd-4302-8205-7ae608ec7fd8.png)
![image](https://user-images.githubusercontent.com/55919713/236450802-2a3296f6-fd9c-47e0-a26c-193da53e6515.png)

