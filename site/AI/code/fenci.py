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