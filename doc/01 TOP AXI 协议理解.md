### 1. 基础知识
#### 1. ostd
- 不需要等下本信号的回复，即可发送下一个新请求
#### 2. out order（不同ID间）
- trans 粒度，不同的ID的trans可以不按照发送顺序回复
- 受众：主要针对的是slave端，而与master的行为无关
- 读乱序：slave，收到的ARID的顺序和发送数据RID的顺序不一致(其中ARID可以是不同master,也可以是相同master)
- 写乱序：slave，收到的AWID/WID的顺序和BRESP发送数据ID的顺序不一致(其中AWID/WID可以是不同master,也可以是相同master)
- 优点：提高总线的性能
 1. 已读为例分析，![image](https://github.com/user-attachments/assets/6ae70ab2-36db-48a2-9db4-5337691b690f)
 2. 当slave连续收到ARID分别为ID0和ID1的读请求，由于未知原因，对ID1的响应速度比对ID0更快，slave可以先返回RID为ID1的读数据，再返回RID为ID0的读数据。
 3. 读乱序机制可以提高总线的性能。
 4. 如果严格保序，RID为ID1的读数据需等到ID0的读数据都返回之后才可返回，明显造成了性能的浪费。
 5. 其中读乱序的深度由read data reordering depth决定，代表slave中允许pending的adress个数。当read data reordering depth = 1时代表不允许读乱序。

#### 3. intervaling（不同ID间）
- 读乱序的例子展示的是transaction粒度的乱序，读交织进一步允许transfer粒度的乱序
- 读交织是out of order乱序的其中一种实现形式
- 是否支持读交织，**只与slave**有关。
- 读交织
  1.  ![image](https://github.com/user-attachments/assets/74954fe8-1ffd-4a05-a4b4-c7ccc8b66da0)
  2.  slave在返回了一个RID为ID2的读数据后，中间间插返回了ID0与ID1的读数据，最后才返回一个的ID2的读数据。
  3.  但同一RID的读数据之间需要保序。由此可见，在读交织机制下，同一个transaction中间插了来自其他transaction的transfer，所以乱序的粒度是transfer级的。
- 写交织（AIX4已删除）
  1. 类似于读交织，每个transaction的写数据也会有一个WID，不同WID的写数据transfer可以间插发送。但同一WID的写数据之间需要保序
  2. 此时，乱序的粒度也精确到了transfer级。
  3. 值得注意的是，相比于读交织，写交织还有两点额外的要求：
    - 虽然允许不同WID的写交织，但是每笔transaction的第一个transfer需与写请求（AW req）发送的顺序严格一致。
    - 为了避免死锁dead lock，支持写交织的slave必须一直支持写交织，不能某些时候支持，而某些时候不支持。
  4. 被弃用，即在AXI4中，写乱序只能在transaction粒度上进行，无法再精确到transfer粒度
  5. WID的删除：
    transaction粒度的乱序，只需要用每笔transaction的写响应BID进行描述，而每个写数据transfer是不允许间插交织的，于是AXI4中也删除了W channel中的WID信号
  6. AXI4不支持写交织的原因：
   - 其相较于读交织有着额外的要求，这也意味着要实现写交织，在总线系统设计中需要增加复杂的逻辑，且容易产生死锁。
   - 对于同一master，master可以自行规划写数据的顺序（比如将不同写事务进行拆解重组），达到与写交织一样的效果。
   - 而只有在多master，且master的写速度不同时，写交织才能够派上用场，因此写交织的应用场景也不够广泛。

#### 4. AXI4协议去掉了WID信号，因此不再支持write interleaving。这是AXI4和AXI3的很重要和很大的一个改变
- [AXI3与AXI4区别及互联](https://zhuanlan.zhihu.com/p/193006656#:~:text=AXI4%E5%8D%8F%E8%AE%AE%E5%8E%BB%E6%8E%89%E4%BA%86WID%E4%BF%A1%E5%8F%B7%EF%BC%8C%E5%9B%A0%E6%AD%A4%E4%B8%8D%E5%86%8D%E6%94%AF%E6%8C%81write%20interleaving%E3%80%82%20%E8%BF%99%E6%98%AFAXI4%E5%92%8CAXI3%E7%9A%84%E5%BE%88%E9%87%8D%E8%A6%81%E5%92%8C%E5%BE%88%E5%A4%A7%E7%9A%84%E4%B8%80%E4%B8%AA%E6%94%B9%E5%8F%98%E3%80%82,Write%20interleaving%E7%9A%84%E5%8E%BB%E9%99%A4%E4%BD%BF%E5%BE%97%E5%9C%A8WID%E4%BF%A1%E5%8F%B7%E4%B8%8A%E4%BC%A0%E9%80%92%E7%9A%84%E4%BF%A1%E6%81%AF%E6%98%AF%E5%A4%9A%E4%BD%99%E7%9A%84%E3%80%82%20%E6%89%80%E6%9C%89%E5%86%99%E5%85%A5%E6%95%B0%E6%8D%AE%E5%BF%85%E9%A1%BB%E4%B8%8E%E7%9B%B8%E5%85%B3%E7%9A%84%E5%86%99%E5%85%A5%E5%9C%B0%E5%9D%80%E9%A1%BA%E5%BA%8F%E7%9B%B8%E5%90%8C%EF%BC%8C%E4%BB%BB%E4%BD%95%E9%9C%80%E8%A6%81WID%E4%BF%A1%E6%81%AF%E9%83%BD%E5%8F%AF%E4%BB%A5%E4%BB%8E%E5%86%99%E5%85%A5%E5%9C%B0%E5%9D%80%E9%80%9A%E9%81%93%E4%BF%A1%E5%8F%B7AWID%E4%B8%AD%E8%8E%B7%E5%BE%97%E8%BF%99%E4%BA%9B%E4%BF%A1%E6%81%AF%E3%80%82)
### 2. 经验总结
1. AXI的读写事务可以通过ID来进行区分，从而引入顺序的概念。
2. out of order与interleaving的区别在于前者是transaction粒度的乱序，而后者是transfer粒度的乱序，可以说后者是前者的一种实现方式。
3. 是否支持乱序只与slave有关，与master无关。
4. AXI3中支持写交织，而AXI4中不再支持写交织

### 3. 传送门
