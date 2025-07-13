---
title: HMM 隐马尔可夫模型详解
date: 2025-01-13
tags:
  - 机器学习
  - 概率论
  - 算法
  - 自然语言处理
---

# HMM 隐马尔可夫模型

## 掷骰子的例子

假设有三个不同的骰子：

![](assets/Pasted%20image%2020250713160906.png)

- **D6**：常见的六面骰子，每个面（1，2，3，4，5，6）出现的概率是1/6
- **D4**：四面体骰子，每个面（1，2，3，4）出现的概率是1/4  
- **D8**：八面骰子，每个面（1，2，3，4，5，6，7，8）出现的概率是1/8

我们开始掷骰子的过程：
1. 从三个骰子里挑一个，挑到每一个骰子的概率都是1/3
2. 掷骰子，得到一个数字（1-8中的一个）
3. 重复上述过程

例如，我们可能得到这么一串数字（掷骰子10次）：
```
1 6 3 5 2 7 3 5 2 4
```

这串数字叫做**可见状态链**（观测序列）。

在隐马尔可夫模型中，我们还有一串**隐含状态链**，在这个例子里就是使用的骰子序列。比如：
```
D6 D8 D8 D6 D4 D8 D6 D6 D4 D8
```

一般来说，HMM中说到的马尔可夫链其实是指隐含状态链，因为隐含状态（骰子）之间存在转换概率（transition probability）。在这个例子中：

- $P(D_6 \rightarrow D_4) = P(D_6 \rightarrow D_6) = P(D_6 \rightarrow D_8) = \frac{1}{3}$
- $P(D_4 \rightarrow D_4) = P(D_4 \rightarrow D_6) = P(D_4 \rightarrow D_8) = \frac{1}{3}$
- $P(D_8 \rightarrow D_4) = P(D_8 \rightarrow D_6) = P(D_8 \rightarrow D_8) = \frac{1}{3}$

尽管可见状态之间没有转换概率，但是隐含状态和可见状态之间有一个概率叫做输出概率（emission probability）。就我们的例子来说：

- $P(1|D_6) = P(2|D_6) = P(3|D_6) = P(4|D_6) = P(5|D_6) = P(6|D_6) = \frac{1}{6}$
- $P(1|D_4) = P(2|D_4) = P(3|D_4) = P(4|D_4) = \frac{1}{4}$
- $P(1|D_8) = P(2|D_8) = P(3|D_8) = P(4|D_8) = P(5|D_8) = P(6|D_8) = P(7|D_8) = P(8|D_8) = \frac{1}{8}$

![](assets/Pasted%20image%2020250713161321.png)

- **隐状态集合**：$Q = \{D_4, D_6, D_8\}$
- **观测值集合**：$V = \{1, 2, 3, 4, 5, 6, 7, 8\}$
- **初始概率分布**：$\pi = \{\pi_{D_4} = \frac{1}{3}, \pi_{D_6} = \frac{1}{3}, \pi_{D_8} = \frac{1}{3}\}$
- **转移概率矩阵A**：
  $$A = \begin{bmatrix}
  P(D_4|D_4) & P(D_6|D_4) & P(D_8|D_4) \\
  P(D_4|D_6) & P(D_6|D_6) & P(D_8|D_6) \\
  P(D_4|D_8) & P(D_6|D_8) & P(D_8|D_8)
  \end{bmatrix} = \begin{bmatrix}
  \frac{1}{3} & \frac{1}{3} & \frac{1}{3} \\
  \frac{1}{3} & \frac{1}{3} & \frac{1}{3} \\
  \frac{1}{3} & \frac{1}{3} & \frac{1}{3}
  \end{bmatrix}$$
- **发射概率矩阵B**：
  $$B = \begin{bmatrix}
  P(1|D_4) & P(2|D_4) & P(3|D_4) & P(4|D_4) & P(5|D_4) & P(6|D_4) & P(7|D_4) & P(8|D_4) \\
  P(1|D_6) & P(2|D_6) & P(3|D_6) & P(4|D_6) & P(5|D_6) & P(6|D_6) & P(7|D_6) & P(8|D_6) \\
  P(1|D_8) & P(2|D_8) & P(3|D_8) & P(4|D_8) & P(5|D_8) & P(6|D_8) & P(7|D_8) & P(8|D_8)
  \end{bmatrix} = \begin{bmatrix}
  \frac{1}{4} & \frac{1}{4} & \frac{1}{4} & \frac{1}{4} & 0 & 0 & 0 & 0 \\
  \frac{1}{6} & \frac{1}{6} & \frac{1}{6} & \frac{1}{6} & \frac{1}{6} & \frac{1}{6} & 0 & 0 \\
  \frac{1}{8} & \frac{1}{8} & \frac{1}{8} & \frac{1}{8} & \frac{1}{8} & \frac{1}{8} & \frac{1}{8} & \frac{1}{8}
  \end{bmatrix}$$

### 解码问题（求最可能的隐状态序列）

**问题描述**：知道骰子有几种，每种骰子是什么，根据掷骰子的结果，求最可能的骰子序列。

**例子**：观测序列为 $O = [1, 6, 3]$，求最可能的隐状态序列。

**解法**：使用Viterbi算法

**计算过程**：

1. **第一次掷骰子（观测值=1）**：
   - $P(D_4|1) = P(D_4) \times P(1|D_4) = \frac{1}{3} \times \frac{1}{4} = \frac{1}{12} \approx 0.083$
   - $P(D_6|1) = P(D_6) \times P(1|D_6) = \frac{1}{3} \times \frac{1}{6} = \frac{1}{18} \approx 0.056$  
   - $P(D_8|1) = P(D_8) \times P(1|D_8) = \frac{1}{3} \times \frac{1}{8} = \frac{1}{24} \approx 0.042$
   - 最大概率：$D_4$

2. **第二次掷骰子（观测值=6）**：
   - 从$D_4$转移：$P(D_4 \rightarrow D_4) \times P(6|D_4) = 0$（$D_4$不能产生6）
   - 从$D_4$转移：$P(D_4 \rightarrow D_6) \times P(6|D_6) = \frac{1}{3} \times \frac{1}{6} = \frac{1}{18}$
   - 从$D_4$转移：$P(D_4 \rightarrow D_8) \times P(6|D_8) = \frac{1}{3} \times \frac{1}{8} = \frac{1}{24}$
   - 从$D_6$转移：$P(D_6 \rightarrow D_4) \times P(6|D_4) = 0$
   - 从$D_6$转移：$P(D_6 \rightarrow D_6) \times P(6|D_6) = \frac{1}{3} \times \frac{1}{6} = \frac{1}{18}$
   - 从$D_6$转移：$P(D_6 \rightarrow D_8) \times P(6|D_8) = \frac{1}{3} \times \frac{1}{8} = \frac{1}{24}$
   - 从$D_8$转移：$P(D_8 \rightarrow D_4) \times P(6|D_4) = 0$
   - 从$D_8$转移：$P(D_8 \rightarrow D_6) \times P(6|D_6) = \frac{1}{3} \times \frac{1}{6} = \frac{1}{18}$
   - 从$D_8$转移：$P(D_8 \rightarrow D_8) \times P(6|D_8) = \frac{1}{3} \times \frac{1}{8} = \frac{1}{24}$
   
   考虑前一步的最大概率路径（$D_4$），当前最大概率路径为：$D_4 \rightarrow D_6$

3. **第三次掷骰子（观测值=3）**：
   - 从$D_6$转移：$P(D_6 \rightarrow D_4) \times P(3|D_4) = \frac{1}{3} \times \frac{1}{4} = \frac{1}{12}$
   - 从$D_6$转移：$P(D_6 \rightarrow D_6) \times P(3|D_6) = \frac{1}{3} \times \frac{1}{6} = \frac{1}{18}$
   - 从$D_6$转移：$P(D_6 \rightarrow D_8) \times P(3|D_8) = \frac{1}{3} \times \frac{1}{8} = \frac{1}{24}$
   
   最大概率路径为：$D_4 \rightarrow D_6 \rightarrow D_4$

**结果**：最可能的隐状态序列是 $[D_4, D_6, D_4]$

### 评估问题（计算观测序列的概率）

**问题描述**：知道骰子有几种，每种骰子是什么，根据掷骰子的结果，计算产生这个结果的概率。

**例子**：观测序列为 $O = [1, 6, 3]$，计算产生这个序列的概率。

**解法**：使用前向算法（Forward Algorithm）

**计算过程**：

1. **第一次掷骰子（观测值=1）**：
   - $\alpha_1(D_4) = P(D_4) \times P(1|D_4) = \frac{1}{3} \times \frac{1}{4} = \frac{1}{12}$
   - $\alpha_1(D_6) = P(D_6) \times P(1|D_6) = \frac{1}{3} \times \frac{1}{6} = \frac{1}{18}$
   - $\alpha_1(D_8) = P(D_8) \times P(1|D_8) = \frac{1}{3} \times \frac{1}{8} = \frac{1}{24}$
   - 总概率 $= \frac{1}{12} + \frac{1}{18} + \frac{1}{24} = \frac{13}{72} \approx 0.18$

2. **第二次掷骰子（观测值=6）**：
   - $\alpha_2(D_4) = 0$（$D_4$不能产生6）
   - $\alpha_2(D_6) = [\alpha_1(D_4) \times P(D_4 \rightarrow D_6) + \alpha_1(D_6) \times P(D_6 \rightarrow D_6) + \alpha_1(D_8) \times P(D_8 \rightarrow D_6)] \times P(6|D_6)$
   - $\alpha_2(D_6) = [\frac{1}{12} \times \frac{1}{3} + \frac{1}{18} \times \frac{1}{3} + \frac{1}{24} \times \frac{1}{3}] \times \frac{1}{6} = \frac{13}{72} \times \frac{1}{3} \times \frac{1}{6} = \frac{13}{1296}$
   - $\alpha_2(D_8) = [\alpha_1(D_4) \times P(D_4 \rightarrow D_8) + \alpha_1(D_6) \times P(D_6 \rightarrow D_8) + \alpha_1(D_8) \times P(D_8 \rightarrow D_8)] \times P(6|D_8)$
   - $\alpha_2(D_8) = [\frac{1}{12} \times \frac{1}{3} + \frac{1}{18} \times \frac{1}{3} + \frac{1}{24} \times \frac{1}{3}] \times \frac{1}{8} = \frac{13}{72} \times \frac{1}{3} \times \frac{1}{8} = \frac{13}{1728}$
   - 总概率 $= \frac{13}{1296} + \frac{13}{1728} \approx 0.05$

3. **第三次掷骰子（观测值=3）**：
   - 继续类似计算...
   - 最终总概率 $\approx 0.03$

**结果**：观测序列 $[1, 6, 3]$ 的概率约为 $0.03$

### 学习问题（参数估计）

**问题描述**：知道骰子有几种，不知道每种骰子是什么，观测到很多次掷骰子的结果，反推出每种骰子的参数。

**解法**：使用Baum-Welch算法（EM算法）

这个问题的目的是从观测数据中学习HMM的参数（转移概率和发射概率）。

给定观测序列 $O = \{o_1, o_2, ..., o_T\}$，我们需要估计：
- 转移概率矩阵 $A = [a_{ij}]$，其中 $a_{ij} = P(q_j|q_i)$
- 发射概率矩阵 $B = [b_j(k)]$，其中 $b_j(k) = P(v_k|q_j)$
- 初始概率分布 $\pi = \{\pi_i\}$


## 隐马尔可夫模型

隐马尔可夫模型（Hidden Markov Model，HMM）是统计模型，它用来描述一个含有隐含未知参数的马尔可夫过程。

![](assets/Pasted%20image%2020250713152035.png)

### 状态序列

隐状态序列 $H$ 可表示为： $H = \{H_1, H_2, ..., H_T\}$

假设总共有 $n$ 个状态，即每个状态序列必为状态集合之一，状态值集合 $Q$ 为：

$$Q = \{q_1, q_2, ..., q_n\}$$

### 观测序列 

观测序列 $O$ 表示为：$O = \{O_1, O_2, ..., O_T\}$

假设观测值总共有 $m$ 个，则观测值集合为：

$$V = \{v_1, v_2, ..., v_m\}$$


### 一个模型

HMM模型可以表示为：

$$\lambda = \{Q, V, \pi, A, B\}$$

- **Q**：状态值集合 $Q = \{q_1, q_2, ..., q_n\}$
- **V**：观测值集合 $V = \{v_1, v_2, ..., v_m\}$
- **π**：初始概率分布 $\pi = \{\pi_i\}$，其中 $\pi_i = P(H_1 = q_i)$
- **A**：状态转移矩阵 $A = [a_{ij}]$，其中 $a_{ij} = P(H_{t+1} = q_j | H_t = q_i)$
- **B**：发射矩阵 $B = [b_j(k)]$，其中 $b_j(k) = P(O_t = v_k | H_t = q_j)$

### 两个假设

#### 齐次Markov假设
即假设隐状态序列中t时刻的状态，只跟上一时刻t-1有关：

$$P(H_{t+1} | H_t, ..., H_1; O_t, ..., O_1) = P(H_{t+1} | H_t)$$

#### 观测独立假设
即每个时刻的观测值只由该时刻的状态值决定：

$$P(O_t | O_{t-1}, ..., O_1; H_t, ..., H_1) = P(O_t | H_t)$$

### 三个问题

HMM在实际应用中主要用来解决3类问题：

#### 评估问题（概率计算问题）
给定观测序列 $O = \{O_1, O_2, O_3, ..., O_T\}$ 和模型参数 $\lambda = (A, B, \pi)$，怎样有效计算这一观测序列出现的概率 $P(O|\lambda)$。

**解决方法**：Forward-Backward算法

#### 解码问题（预测问题）
给定观测序列 $O = \{O_1, O_2, O_3, ..., O_T\}$ 和模型参数 $\lambda = (A, B, \pi)$，怎样寻找满足这种观察序列意义上最优的隐含状态序列 $H$。

**解决方法**：Viterbi算法、近似算法

#### 学习问题（参数估计问题）
HMM的模型参数 $\lambda = (A, B, \pi)$ 未知，如何求出这3个参数以使观测序列 $O = \{O_1, O_2, O_3, ..., O_T\}$ 的概率尽可能的大。

**解决方法**：Baum-Welch算法（EM算法）

## Viterbi算法

Viterbi 算法是隐马尔可夫模型（HMM）中求解隐状态序列，也就是最大概率路径的算法。

**例子**：一个东京的朋友每天根据天气 $\{下雨，天晴\}$ 决定当天的活动 $\{公园散步, 购物, 清理房间\}$ 中的一种，我每天只能在 twitter 上看到她发的推"啊，我前天公园散步、昨天购物、今天清理房间了！"，那么我可以根据她发的推特推断东京这三天的天气。在这个例子里，显状态是活动，隐状态是天气。

任何一个HMM都可以通过下列五元组来描述：

- **obs**：观测序列 $O = \{O_1, O_2, ..., O_T\}$
- **states**：隐状态集合 $Q = \{q_1, q_2, ..., q_N\}$
- **start_p**：初始概率分布 $\pi = \{\pi_i\}$
- **trans_p**：转移概率矩阵 $A = [a_{ij}]$
- **emit_p**：发射概率矩阵 $B = [b_j(k)]$

python 实现如下：

```python
import numpy as np

states = ('Rainy', 'Sunny') # 隐状态
observations = ('walk', 'shop', 'clean') # 观测状态
start_probability = {'Rainy': 0.6, 'Sunny': 0.4} # 初始概率
transition_probability = {
    'Rainy' : {'Rainy': 0.7, 'Sunny': 0.3}, # 转移概率
    'Sunny' : {'Rainy': 0.4, 'Sunny': 0.6}, # 转移概率
}
emission_probability = {
    'Rainy' : {'walk': 0.1, 'shop': 0.4, 'clean': 0.5}, # 发射概率
    'Sunny' : {'walk': 0.6, 'shop': 0.3, 'clean': 0.1}, # 发射概率
}

def viterbi(obs, states, start_p, trans_p, emit_p):  # 输入五元组，输出最可能的隐状态序列
    V = [{}]  # 状态概率
    path = {}  # 状态路径
    
    # 初始化第一个时间步
    for y in states:
        V[0][y] = start_p[y] * emit_p[y][obs[0]]
        path[y] = [y]
    
    # 动态规划，计算每个时间步的最优路径
    for t in range(1, len(obs)):
        V.append({})
        new_path = {}
        
        for y in states:
            # 找到前一个时间步中能产生最大概率的状态
            (prob, state) = max((V[t-1][y0] * trans_p[y0][y] * emit_p[y][obs[t]], y0) for y0 in states)
            V[t][y] = prob
            new_path[y] = path[state] + [y]
        
        path = new_path
    
    # 找到最后一个时间步中概率最大的状态
    (prob, state) = max((V[len(obs)-1][y], y) for y in states)
    
    return prob, path[state], V  # 返回最终路径和概率矩阵

# 测试算法
obs = ('walk', 'shop', 'clean')
prob, path, V = viterbi(obs, states, start_probability, transition_probability, emission_probability)

print(f"观测序列: {obs}")
print(f"最可能的隐状态序列: {path}")
print(f"概率: {prob:.6f}")

# 输出每个时间步的概率矩阵
print("\n概率矩阵:")
for t in range(len(obs)):
    print(f"时间步 {t}: {V[t]}")

```

#### 算法原理

Viterbi 算法的核心思想是动态规划：

1. **初始化**: 计算第一个观测值对应的每个隐状态的概率
   $$\delta_1(i) = \pi_i \cdot b_i(O_1)$$

2. **递推**: 对于每个后续的观测值，计算从所有前一个状态转移到当前状态的概率，选择最大值
   $$\delta_t(j) = \max_{1 \leq i \leq N} [\delta_{t-1}(i) \cdot a_{ij}] \cdot b_j(O_t)$$

3. **回溯**: 记录每个时间步选择的最优前驱状态
   $$\psi_t(j) = \arg\max_{1 \leq i \leq N} [\delta_{t-1}(i) \cdot a_{ij}]$$

4. **终止**: 选择最后一个时间步中概率最大的状态，然后回溯得到完整路径
   $$P^* = \max_{1 \leq i \leq N} \delta_T(i)$$

#### 时间复杂度

- 时间复杂度: $O(T \times N^2)$，其中 $T$ 是观测序列长度，$N$ 是隐状态数量
- 空间复杂度: $O(T \times N)$



## 中文分词应用

### SBME标注法

在中文分词中，我们经常用SBME的字标注法来标注语料，即通过给每个字打上标签来达到分词的目的：

- **S**（Single）：代表单字成词
- **B**（Begin）：代表多字词的开头
- **M**（Middle）：代表三个及以上字词的中间部分
- **E**（End）：表示多字词的结尾

例如："我是中国人"就可以表示为：$SSBME$

### 数学建模

对于字标注的分词方法来说，输入就是 $n$ 个字，输出就是 $n$ 个标签。我们用 $\lambda = \{\lambda_1, \lambda_2, ..., \lambda_n\}$ 表示输入的句子，$o = \{o_1, o_2, ..., o_n\}$ 表示输出。

那最优的输出从概率的角度来看，就是求条件概率：

$$P(o|\lambda) = P(o_1, o_2, ..., o_n|\lambda_1, \lambda_2, ..., \lambda_n)$$

即要求上式概率最大，根据独立性假设，即每个字的输出只与当前字有关，上式可表示为：

$$P(o_1, o_2, ..., o_n|\lambda_1, \lambda_2, ..., \lambda_n) = \prod_{k=1}^{n} P(o_k|\lambda_k)$$

由贝叶斯定理：

$$P(o|\lambda) = \frac{P(\lambda, o)}{P(\lambda)} = \frac{P(o)P(\lambda|o)}{P(\lambda)} \propto P(o)P(\lambda|o)$$

同样地由独立性假设：

$$P(\lambda|o) = \prod_k P(\lambda_k|o_k), k=1,...,n$$

由HMM的Markov假设：每个输出仅和上一个时刻相关，有：

$$P(o) = P(o_1)P(o_2|o_1)P(o_3|o_2)...P(o_n|o_{n-1})$$

因此，最初的求解可以转化为：

$$P(o|\lambda) \sim P(o)P(\lambda|o) = P(o_1)P(\lambda_1|o_1)P(o_2|o_1)P(\lambda_2|o_2)P(o_3|o_2)...P(o_n|o_{n-1})P(\lambda_n|o_n)$$

其中 $P(\lambda_k|o_k)$ 为发射概率，$P(o_k|o_{k-1})$ 为转移概率。

### 代码实现

#### 实现1：基于词典统计的HMM分词

```python
import os
import math
from collections import Counter

# 构建HMM模型
hmm_model = {i: Counter() for i in 'sbme'}

# 从词典文件统计发射概率

script_dir = os.path.dirname(os.path.abspath(__file__))
dict_path = os.path.join(script_dir, 'dict.txt')
with open(dict_path, encoding='utf-8') as f:
    for line in f:
        lines = line.strip('\n').split(' ')
        if len(lines[0]) == 1:
            hmm_model['s'][lines[0]] += int(lines[1])
        else:
            hmm_model['b'][lines[0][0]] += int(lines[1])
            hmm_model['e'][lines[0][-1]] += int(lines[1])
        for m in lines[0][1:-1]:
            hmm_model['m'][m] += int(lines[1])

# 计算对数概率，防止溢出
log_total = {i: math.log(sum(hmm_model[i].values())) for i in 'sbme'}

# 初始概率，第一个词只可能是b或者s
start_p = {
    'b': -0.26268660809250016,
    'e': -3.14e+100,
    'm': -3.14e+100,
    's': -1.4652633398537678
}

# 转移概率矩阵（对数概率）
P = {
    'B': {'E': -0.510825623765990, 'M': -0.916290731874155},
    'E': {'B': -0.5897149736854513, 'S': -0.8085250474669937},
    'M': {'E': -0.33344856811948514, 'M': -1.2603623820268226},
    'S': {'B': -0.7211965654669841, 'S': -0.6658631448798212}
}

# 转换为小写并构建转移概率字典
trans = {}
for key, values in P.items():
    for k, v in values.items():
        trans[(key + k).lower()] = v

def viterbi(start_p, nodes, trans):
    """Viterbi算法实现"""
    paths = start_p  # 初始状态概率
    
    for l in range(1, len(nodes)):
        paths_ = paths
        paths = {}
        
        for i in nodes[l]:  # 当前时刻的四种状态
            nows = {}
            for j in paths_:
                if j[-1] + i in trans:  # 检查状态转移是否可能
                    # 计算路径概率 = 之前路径概率 + 发射概率 + 转移概率
                    nows[j + i] = paths_[j] + nodes[l][i] + trans[j[-1] + i]
            
            # 选择概率最大的路径
            if nows:
                prob_i, path_i = max((v, k) for k, v in nows.items())
                paths[path_i] = prob_i
    
    # 最后一个字只可能是e或s
    prob, states = max((v, k) for k, v in paths.items() if k[-1] in 'es')
    return prob, states

def hmm_cut(s):
    """HMM分词主函数"""
    # 计算每个字的发射概率
    nodes = [{i: math.log(j.get(t, 0) + 1) - log_total[i] 
              for i, j in hmm_model.items()} for t in s]
    
    _, tags = viterbi(start_p, nodes, trans)
    print(f"标签序列: {tags}")
    
    # 根据标签序列进行分词
    words = [s[0]]
    for i in range(1, len(s)):
        if tags[i] in ['b', 's']:
            words.append(s[i])
        else:
            words[-1] += s[i]
    return words

# 测试
text = '华为手机深得大家的喜欢'
print('分词结果:', ' '.join(hmm_cut(text)))
# 输出: 华为 手机 深得 大家 的 喜欢
```

#### 实现2：结巴分词风格的实现

```python
import math
from collections import Counter

# 构建HMM模型（大写标签）
hmm_model = {i: Counter() for i in 'SBME'}

# 从词典文件统计发射概率
with open('dict.txt.small', encoding='utf-8') as f:
    for line in f:
        lines = line.strip('\n').split(' ')
        if len(lines[0]) == 1:
            hmm_model['S'][lines[0]] += int(lines[1])
        else:
            hmm_model['B'][lines[0][0]] += int(lines[1])
            hmm_model['E'][lines[0][-1]] += int(lines[1])
        for m in lines[0][1:-1]:
            hmm_model['M'][m] += int(lines[1])

log_total = {i: math.log(sum(hmm_model[i].values())) for i in 'SBME'}

# 转移概率矩阵
trans_p = {
    'B': {'E': -0.510825623765990, 'M': -0.916290731874155},
    'E': {'B': -0.5897149736854513, 'S': -0.8085250474669937},
    'M': {'E': -0.33344856811948514, 'M': -1.2603623820268226},
    'S': {'B': -0.7211965654669841, 'S': -0.6658631448798212}
}

# 发射概率矩阵
emit_p = {i: {t: math.log(j.get(t, 0) + 1) - log_total[i] 
              for t in j.keys()} for i, j in hmm_model.items()}

# 初始概率
start_p = {
    'B': -0.26268660809250016,
    'E': -3.14e+100,
    'M': -3.14e+100,
    'S': -1.4652633398537678
}

# 状态转移约束
PrevStatus = {
    'B': 'ES',  # B状态前只可能是E或S
    'M': 'MB',  # M状态前只可能是M或B
    'S': 'SE',  # S状态前只可能是S或E
    'E': 'BM'   # E状态前只可能是B或M
}

MIN_FLOAT = -3.14e100

def jieba_viterbi(obs, states, start_p, trans_p, emit_p):
    """结巴分词风格的Viterbi算法"""
    V = [{}]  # 状态概率矩阵
    path = {}
    
    # 初始化
    for y in states:
        V[0][y] = start_p[y] + emit_p[y].get(obs[0], MIN_FLOAT)
        path[y] = [y]
    
    # 动态规划
    for t in range(1, len(obs)):
        V.append({})
        newpath = {}
        for y in states:
            em_p = emit_p[y].get(obs[t], MIN_FLOAT)
            # 从可能的前驱状态中选择最优的
            (prob, state) = max([(V[t-1][y0] + trans_p[y0].get(y, MIN_FLOAT) + em_p, y0) 
                                for y0 in PrevStatus[y]])
            V[t][y] = prob
            newpath[y] = path[state] + [y]
        path = newpath
    
    # 最后一个字只可能是E或S
    (prob, state) = max((V[len(obs)-1][y], y) for y in 'ES')
    return (prob, path[state])

def hmm_cut(s):
    """HMM分词主函数"""
    prob, tags = jieba_viterbi(s, 'SBME', start_p, trans_p, emit_p)
    print(f"标签序列: {tags}")
    
    # 根据标签序列进行分词
    words = [s[0]]
    for i in range(1, len(s)):
        if tags[i] in ['B', 'S']:
            words.append(s[i])
        else:
            words[-1] += s[i]
    return words

# 测试
text = '小明硕士毕业于中国科学院计算所'
print('分词结果:', ' '.join(hmm_cut(text)))
# 输出: 小明 硕士 毕业于 中国 科学院 计算 所
```

### 算法优势

1. **未登录词识别**：对于词典中没有的词（如人名"王五"），HMM模型可以发现这是个人名，分词时组合在一起，而查字典方法做不到。

2. **概率建模**：通过概率模型，可以处理歧义问题，选择最可能的分词结果。

3. **动态规划**：使用Viterbi算法，避免了穷举所有可能路径的计算复杂度问题。

### 应用场景

- **中文分词**：自然语言处理的基础任务
- **词性标注**：为每个词标注词性
- **命名实体识别**：识别人名、地名、机构名等
- **语音识别**：从语音信号推断最可能的单词序列

