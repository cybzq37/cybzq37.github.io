---
title: 09-其他
date: 2026-02-03
tags:
  - 图形学
---

## snell law
![](assets/snell_law.png)

斯涅尔定律表明，当光波从介质1传播到介质2时，假若两种介质的折射率不同，则会发生折射现象，其入射光和折射光都处于同一平面，称为"入射平面"，并且与界面法线的夹角满足如下关系：

$$ n_1 \sin \theta_1 = n_2 \sin \theta_2 $$

其中，$n_1$、$n_2$分别是两种介质的折射率，$\theta_1$和$\theta_2$分别是入射光、折射光与界面法线的夹角，分别叫做"入射角"、"折射角"。

**向量形式的折射公式**

在光线追踪中，我们需要计算折射方向的向量。设：
- $\vec{I}$ 为入射方向（单位向量）
- $\vec{N}$ 为表面法线（单位向量）
- $\vec{T}$ 为折射方向（单位向量）
- $\eta = \frac{n_1}{n_2}$ 为相对折射率

根据 Snell 定律和向量几何关系，折射方向的向量计算公式为：

$$ \vec{T} = \eta \vec{I} + (\eta \cos \theta_i - \cos \theta_t) \vec{N} $$

其中：
- $\cos \theta_i = \vec{I} \cdot \vec{N}$（入射角的余弦值）
- $\cos \theta_t$ 需要通过 Snell 定律计算

### 推导过程

1. **计算 $\cos \theta_t$**：
   由 Snell 定律：$n_1 \sin \theta_1 = n_2 \sin \theta_2$，可得：
   $$ \sin \theta_t = \eta \sin \theta_i $$
   
   利用三角恒等式 $\cos^2 \theta + \sin^2 \theta = 1$：
   $$ \cos^2 \theta_t = 1 - \sin^2 \theta_t = 1 - \eta^2 \sin^2 \theta_i = 1 - \eta^2 (1 - \cos^2 \theta_i) $$
   
   因此：
   $$ \cos \theta_t = \sqrt{1 - \eta^2 (1 - \cos^2 \theta_i)} $$

2. **全反射判断**：
   当 $\eta^2 (1 - \cos^2 \theta_i) > 1$ 时，即 $1 - \eta^2 (1 - \cos^2 \theta_i) < 0$ 时，会发生全反射（total internal reflection），此时没有折射光线。

3. **最终公式**：
   设 $k = 1 - \eta^2 (1 - \cos^2 \theta_i)$，则：
   - 如果 $k < 0$，发生全反射，返回零向量
   - 如果 $k \geq 0$，折射方向为：
   $$ \vec{T} = \eta \vec{I} + (\eta \cos \theta_i - \sqrt{k}) \vec{N} $$

```cpp
Vector3f refract(const Vector3f &I, const Vector3f &N, const float &ior) {
    float cosi = clamp(-1, 1, dotProduct(I, N));  // cos θ_i
    float etai = 1.0f;  // 入射介质折射率（通常为空气）
    float etat = ior;   // 透射介质折射率
    Vector3f n = N;
    
    // 判断光线在物体内部还是外部
    if (cosi < 0) {
        // 光线在物体外部（从空气射向物体）
        cosi = -cosi;
    } else {
        // 光线在物体内部（从物体射向空气）
        std::swap(etai, etat);
        n = -N;
    }
    
    float eta = etai / etat;  // 相对折射率 η
    float k = 1 - eta * eta * (1 - cosi * cosi);  // 判断是否全反射
    
    // k < 0 表示全反射，返回零向量；否则返回折射方向
    return k < 0 ? 0 : eta * I + (eta * cosi - sqrtf(k)) * n;
}
```

**关键步骤说明**：
- `cosi = dotProduct(I, N)`：计算入射角的余弦值
- `eta = etai / etat`：计算相对折射率
- `k = 1 - eta²(1 - cos²θ_i)`：判断是否发生全反射
- `eta * I + (eta * cosi - sqrt(k)) * n`：计算折射方向向量
