c++项目其实只要强制做到三点就能杜绝大部分内存问题了。

1.不要用c风格数组。用[boost::array](https://zhida.zhihu.com/search?content_id=647975270&content_type=Answer&match_order=1&q=boost%3A%3Aarray&zhida_source=entity)代替静态数组，用[boost::container::vector](https://zhida.zhihu.com/search?content_id=647975270&content_type=Answer&match_order=1&q=boost%3A%3Acontainer%3A%3Avector&zhida_source=entity)代替动态数组。

这样如果发生越界访问的话，debug模式下会直接报assert fail，就不需要你到处debug在哪越界了。

2.不要使用new创建资源，一律用[make_unique](https://zhida.zhihu.com/search?content_id=647975270&content_type=Answer&match_order=1&q=make_unique&zhida_source=entity)或[make_shared](https://zhida.zhihu.com/search?content_id=647975270&content_type=Answer&match_order=1&q=make_shared&zhida_source=entity)。

这条并不是说要完全避免裸指针，在有足够把握裸指针是安全的情况下，为了降低复杂度可以用[unique_ptr](https://zhida.zhihu.com/search?content_id=647975270&content_type=Answer&match_order=1&q=unique_ptr&zhida_source=entity)+裸指针来代替[shared_ptr](https://zhida.zhihu.com/search?content_id=647975270&content_type=Answer&match_order=1&q=shared_ptr&zhida_source=entity)。不过新手的话完全可以强制shared_ptr+[weak_ptr](https://zhida.zhihu.com/search?content_id=647975270&content_type=Answer&match_order=1&q=weak_ptr&zhida_source=entity)+强制检查指针，这样就和[rust](https://zhida.zhihu.com/search?content_id=647975270&content_type=Answer&match_order=1&q=rust&zhida_source=entity)一样麻烦了。

3.资源遵循谁创建谁销毁原则。这个是老话了。

1，2的话会有一点性能损失，但你用rust的话也会有类似的性能损失。vector如果是当作buffer用的话可以用boost的，配合default_init，省去初始化开销，可以减小性能损失。

这在单线程模式下就已经足够安全了，再注意一下不要在遍历容器的时候写入容器就好了。多线程的话就需要经验了。

网络上有太多关于c++的不实谣言，事实上现代c++根本没那么不安全，而一堆人一直在拿c和[c++98](https://zhida.zhihu.com/search?content_id=647975270&content_type=Answer&match_order=1&q=c%2B%2B98&zhida_source=entity)的问题来黑c++。

c++高手使用现代c++，在开发效率上甚至不输给以开发效率高闻名的那些语言，自由度和功能的丰富度更是独一档。rust是望尘莫及的。因此我认为c++不但不会败局已定，反而会越发稳固。

rust真正能威胁到的其实是c和java。因为有些用c的老顽固抗拒c++，但他们又感觉c太不安全开发效率太低，所以会引入rust代替c。但当这些老顽固死了之后，c++可能会反过来代替rust。

java和rust一样，都是聪明人为了让笨一点的人也能写出内存安全的程序而开发的语言。不过java有性能和内存占用的问题，那么那些不是很高明的程序员为了提升性能自然会考虑rust。但我想说的是，完全可以用现代c++代替rust。rust提升的那点安全性，是要以开发效率为代价的，使用rust最后可能反而会得不偿失。