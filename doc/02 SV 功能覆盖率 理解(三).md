### 1. 场景1：定义一个covergroup，实现对多个功能类似信号的采样和覆盖率统计。实现步骤如下
#### 1. 定义covergroup，并在sample函数中增加一个形参变量，例如speed_mode，
![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/1ec3f895-9b39-431d-8b68-d21b7bc2ba20)
#### 2. 对covergroup进行多次实例化
![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/224bb982-e425-468e-8266-8bfb3355a6e9)
#### 3. 对每个实例进行new
![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/cd0efa14-0bc9-4b3e-8384-f7c7fed1dcad)
#### 4. 在合适的采样时机进行sample，下图中vif.speed_mode数组中的每一个元素对应一个功能信号。
![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/9c7aaf3e-e125-45e2-81ad-17356d83908e)

### 2. 场景2： 定义一个covergroup，实现对多bit信号中每一个bit的采样和覆盖率统计。实现步骤如下
#### 1. 定义covergroup，并在sample函数中增加两个形参变量，signal_a和用于指示bit位的变量index,其中coverpoint对应的采样信号定义为signal_a[index]
![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/958db10c-06ed-4817-b937-e86e4deb6a45)
#### 2. 对covergroup进行多次实例化
![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/0ca8c913-514c-45f0-9e63-af0dbf42104d)
#### 3. 对每个实例进行new
![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/eac37c49-f973-414e-aa43-828e36163909)
#### 4. 在合适的采样时机进行sample，采样函数sample中传入被采样信号vif.signal_a, 以及期望的被采样比特k
![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/867c0026-0d26-4800-a850-f82045a19ba9)

### 3. 注意事项：
1. 如果在class中对covergroup进行多次实例化，那么covergroup的定义需要在class的外部，否则编译报错
2. 如果想对多个covergroup实例单独分析各自覆盖率结果，需要在covergroup定义中设置option.per_instance=1，否则多个实例的覆盖率结果会合并到一起。
