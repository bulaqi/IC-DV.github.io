
<!-- TOC -->

- [SV](#sv)
    - [SystemVerilog和Verilog中的表达式位宽](#systemverilog%E5%92%8Cverilog%E4%B8%AD%E7%9A%84%E8%A1%A8%E8%BE%BE%E5%BC%8F%E4%BD%8D%E5%AE%BD)
    - [dist 权重](#dist-%E6%9D%83%E9%87%8D)
    - [常用的约束](#%E5%B8%B8%E7%94%A8%E7%9A%84%E7%BA%A6%E6%9D%9F)
    - [Systemverilog 最简单的编程实例](#systemverilog-%E6%9C%80%E7%AE%80%E5%8D%95%E7%9A%84%E7%BC%96%E7%A8%8B%E5%AE%9E%E4%BE%8B)
    - [合并数组](#%E5%90%88%E5%B9%B6%E6%95%B0%E7%BB%84)
    - [slove before](https://blog.csdn.net/qq_39794062/article/details/113047725)
    - [SV 语法合计（包含slove_before）](https://www.cnblogs.com/lyc-seu/p/12797099.html)
    - [UVM的随机 约束 内含数组](https://www.jianshu.com/p/9132ade4d60e)

- [UVM](#uvm)
- [VCS](#vcs)
    - [vcs常用仿真选项](#vcs%E5%B8%B8%E7%94%A8%E4%BB%BF%E7%9C%9F%E9%80%89%E9%A1%B9)
    - [VCS基本选项命令介绍](#vcs%E5%9F%BA%E6%9C%AC%E9%80%89%E9%A1%B9%E5%91%BD%E4%BB%A4%E4%BB%8B%E7%BB%8D)
    - [VCS & Verdi 联合仿真总结](#vcs--verdi-%E8%81%94%E5%90%88%E4%BB%BF%E7%9C%9F%E6%80%BB%E7%BB%93)
- [Verdi](#verdi)
    - [verdi常用操作](#verdi%E5%B8%B8%E7%94%A8%E6%93%8D%E4%BD%9C)
- [Vim](#vim)
    - [Vim 使用系统粘贴板复制粘贴](#vim-%E4%BD%BF%E7%94%A8%E7%B3%BB%E7%BB%9F%E7%B2%98%E8%B4%B4%E6%9D%BF%E5%A4%8D%E5%88%B6%E7%B2%98%E8%B4%B4)
    - [Nerdtree 导航按照内容跳转](#nerdtree-%E5%AF%BC%E8%88%AA%E6%8C%89%E7%85%A7%E5%86%85%E5%AE%B9%E8%B7%B3%E8%BD%AC)
    - [VIM学习笔记 键盘映射 Map](#vim%E5%AD%A6%E4%B9%A0%E7%AC%94%E8%AE%B0-%E9%94%AE%E7%9B%98%E6%98%A0%E5%B0%84-map)
- [Linux](#linux)

<!-- /TOC -->
### 1. SV  
   #### 1.1 [SystemVerilog和Verilog中的表达式位宽](https://blog.csdn.net/m0_46345246/article/details/121758747)   
   #### 1.2 [dist 权重](https://www.cnblogs.com/yanli0302/p/12691967.html)  
   #### 1.3 [常用的约束](https://zhuanlan.zhihu.com/p/404706442#:~:text=%E6%9D%A1%E4%BB%B6%E7%BA%A6%E6%9D%9F%EF%BC%9A,SV%E4%B8%AD%E6%9C%89%E4%B8%A4%E7%A7%8D%E5%86%99%E6%9D%A1%E4%BB%B6%E7%BA%A6%E6%9D%9F%E7%9A%84%E6%96%B9%E5%BC%8F%EF%BC%9Aimplication%EF%BC%88%E6%9C%89%E4%BA%9B%E5%9C%B0%E6%96%B9%E4%BC%9A%E7%BF%BB%E8%AF%91%E6%88%90%E8%95%B4%E8%97%8F%E6%88%96%E8%80%85%E5%85%B3%E8%81%94%E7%AD%89%E7%AD%89%EF%BC%89%E5%92%8C%20if-else%EF%BC%8C%E7%94%A8%E6%9D%A5%E6%8C%87%E5%AE%9A%E5%9C%A8%E6%9F%90%E4%BA%9B%E6%9D%A1%E4%BB%B6%E4%B8%8B%E6%89%8D%E5%81%9A%E8%BF%9B%E4%B8%80%E6%AD%A5%E7%9A%84%E7%BA%A6%E6%9D%9F%EF%BC%8C%E8%BF%99%E4%B8%A4%E7%A7%8D%E6%96%B9%E6%B3%95%E4%BD%BF%E7%94%A8%E4%B8%8A%E5%87%A0%E4%B9%8E%E6%B2%A1%E6%9C%89%E5%8C%BA%E5%88%AB%E3%80%82)  
   #### 1.4 [Systemverilog 最简单的编程实例](https://blog.csdn.net/liujingyu_1205/article/details/81561781?spm=1001.2101.3001.6650.17&utm_medium=distribute.pc_relevant.none-task-blog-2%7Edefault%7EBlogCommendFromBaidu%7ERate-17-81561781-blog-115303326.pc_relevant_recovery_v2&depth_1-utm_source=distribute.pc_relevant.none-task-blog-2%7Edefault%7EBlogCommendFromBaidu%7ERate-17-81561781-blog-115303326.pc_relevant_recovery_v2&utm_relevant_index=21)    
   #### 1.5 [合并数组](https://github.com/bulaqi/IC-DV.github.io/wiki/%E3%80%90SV%E3%80%91%E5%90%88%E5%B9%B6%E6%95%B0%E7%BB%84)

### 2. UVM  
### 3. VCS  
   #### 3.1 [vcs常用仿真选项](https://blog.csdn.net/bcs_01/article/details/79803304)  
   #### 3.2 [VCS基本选项命令介绍](https://blog.csdn.net/bulaqi/article/details/129260375)  
   #### 3.3 [VCS & Verdi 联合仿真总结](https://mp.csdn.net/mp_blog/creation/editor/new/128918834)  

### 4. Verdi   
   #### 4.1 [verdi常用操作](https://www.cnblogs.com/wt-seu/p/16010306.html)  

### 5. Vim  
   #### 5.1 [Vim 使用系统粘贴板复制粘贴](https://blog.csdn.net/blue_bm/article/details/17619797)  
   #### 5.2 [Nerdtree 导航按照内容跳转](https://blog.csdn.net/u014789533/article/details/115371770)   
   #### 5.3 [VIM学习笔记 键盘映射 (Map)](https://zhuanlan.zhihu.com/p/24713018)

### 6. Linux  