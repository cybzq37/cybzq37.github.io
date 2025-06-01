# 第一周

## 介绍

### 什么是机器学习

对于机器学习的两种定义：

* "the field of study that gives computers the ability to learn without being explicitly programmed."    - Arthur Samuel
* "A computer program is said to learn from experience E with respect to some class of tasks T and performance measure P, if its performance at tasks in T, as measured by P, improves with experience E."    - Tom Mitchell

任何机器学习问题可以归于两大类之一：  
- **监督学习（Supervised Learning）**  
- **无监督学习（Unsupervised Learning，或称非监督学习）**

当然，还有半监督学习、强化学习等，尚不在讨论范围内。

### 监督学习

监督学习使用有标签的数据集，其任务是学习一个模型，使模型能够对任意给定的输入，对其相应的输出做出一个好的预测。

监督学习问题被分为 **回归（Regression）** 和 **分类（Classification）** 问题：

* 回归问题：将输入变量映射到某个连续函数，即预测一个连续值；
* 分类问题：将输入变量映射到离散的类别中，即预测一个离散值。

### 无监督学习

在无监督学习中，使用的数据集没有标签，不知道结果会是什么样子，但可以通过聚类的方式从数据中提取一个特殊的结构。

## 模型和成本函数

假设函数、代价函数和优化代价函数之间的关系如下：

- 假设函数：假设函数是机器学习模型的预测函数，它根据输入数据来预测输出结果。假设函数的形式取决于所选的模型类型，例如线性回归、逻辑回归或神经网络等。

- 代价函数：代价函数用来衡量模型预测值与实际值之间的差异。它为模型的训练提供了一个优化目标，即最小化代价函数。常见的代价函数包括均方误差、交叉熵等。

- 优化代价函数：优化代价函数是指通过调整模型参数来最小化代价函数的过程。这一过程通常使用梯度下降或其他优化算法来实现。

总之，假设函数是模型的预测函数，代价函数衡量预测值与实际值之间的差异，而优化代价函数则是通过调整模型参数来最小化代价函数，从而改善模型性能的过程。



### 模型表示

为了描述监督学习问题，我们的目标是，通过一个训练集，学习一个函数 $h : X \rightarrow Y$，使得 $h(x)$ 对于对应值 $y$ 是一个很好的预测器。由于历史原因，$h(x)$ 被称为假设函数（hypothesis function）。

# 线性回归模型（Linear Regression）

## 假设函数

$$f_{w,b}(x)=w_{1}x_{1}+w_{2}x_{2}+...+w_{n}x_{n}+b$$

如何确定模型中的参数取什么值? 用代价函数

## 代价函数

[代价函数](如何最简单、通俗地理解代价函数？.md)（Cost Function）是用来衡量预测值与实际值之间的误差。它的目的是找到一组参数，使得预测值与实际值之间的误差最小（确定最优参数）。评价模型是否拟合的准确，值越小，拟合的越准确。

**线性回归的代价函数**：最小二乘法。所谓“二乘”就是平方的意思。

$$J(w,b)=\frac{1}{2m}\sum_{i=1}^m\bigl(f_{w,b}\bigl(x^{(i)}\bigr)-y^{(i)}\bigr)^2$$

>此处1/2m中的2仅为了后续求导计算时，简化计算步骤


**注意：**

代价函数中的
$$\bigr(f_{w,b}\bigl(x^{(i)}\bigr)-y^{(i)}\bigr)^2$$
部分叫损失函数（Loss Function）用L表示
$$L=(f_{w,b}\bigl(x^{(i)}\bigr)-y^{(i)}\bigr)^2$$
损失函数衡量的是你在一个训练样例上的表现如何，它是通过总结你随后获得的所有训练样列的损失；而代价函数衡量你在整个训练集上的表现。

因此，代价函数值是在损失函数值求和后除以训练量。

### 成本函数

**成本函数（cost function）**用于测量假设函数的准确度，即模型预测的好坏：

$$J(\theta\_0, \theta\_1) = \frac{1}{2m}\sum^m\_{i=1}(\hat y\_i - y\_i)^2 = \frac{1}{2m}\sum^m\_{i=1}(h\_{\theta}(x\_i) - y\_i)^2$$

这个函数也被称为“平方误差函数（Squared error function）”或者“均方误差（Mean squared error）”。在取平均时多了一个 $\frac{1}{2}$，这是为了方便计算梯度下降，求导时 $\frac{1}{2}$ 将被消掉。

## 参数学习

### 梯度下降

在已有假设函数和成本函数的情况下，用**梯度下降（Gradient Descent）**可以估计得到假设函数中的参数。迭代使用：

$$\theta\_j := \theta\_j - \alpha \frac{\partial}{\partial \theta\_j}J(\theta\_0, \theta\_1)$$

直到收敛或到达预定的迭代次数。

其中，$j = 0,1$ 表示特征的 index，$\alpha$ 为学习率。

<!--### 线性回归的梯度下降

对于线性回归

$$\theta\_0 := \theta\_0 - \alpha \frac{1}{m}\sum^m\_{i=1}(h\_{\theta}(x\_i) - y\_i)$$

$$\theta\_1 := \theta\_1 - \alpha \frac{1}{m}\sum^m\_{i=1}((h\_{\theta}(x\_i) - y\_i)x\_i)$$-->

<script type="text/x-mathjax-config">
 MathJax.Hub.Config({
   tex2jax: {inlineMath: [ ['$', '$'] ],
         displayMath: [ ['$$', '$$']]}
 });
</script>


<script src="https://cdn.bootcss.com/mathjax/2.7.4/latest.js?config=default"></script>