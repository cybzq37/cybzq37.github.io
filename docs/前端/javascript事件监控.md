介绍完上面三个事件触发阶段，我们来看下这个问题。

所有介绍事件的文章都会说，在使用 addEventListener​​ 函数来监听事件时，第三个参数设置为 false​​，这样监听事件时只会监听冒泡阶段发生的事件。

这是因为 IE 浏览器不支持在捕获阶段监听事件，为了统一而设置的，毕竟 IE 浏览器的份额是不可忽略的。

IE 浏览器在事件这方面与标准还有一些其他的差异，我们会在后面集中介绍。

### 使用事件代理（Event Delegate）提升性能

因为事件有冒泡机制，所有子节点的事件都会顺着父级节点跑回去，所以我们可以通过监听父级节点来实现监听子节点的功能，这就是事件代理。

使用事件代理主要有两个优势：

1. 减少事件绑定，提升性能。之前你需要绑定一堆子节点，而现在你只需要绑定一个父节点即可。减少了绑定事件监听函数的数量。
2. 动态变化的 DOM 结构，仍然可以监听。当一个 DOM 动态创建之后，不会带有任何事件监听，除非你重新执行事件监听函数，而使用事件监听无须担忧这个问题。

看一个例子：

上面例子中，为了简便，我使用 jQuery 来实现普通事件绑定和事件代理。我的目标是监听所有 a​​ 链接的单击事件，.ul1​​ 是常规的事件绑定方法，jQuery 会循环每一个 .ul > a​​ 结构并绑定事件监听函数。.ul2​​ 则是事件监听的方法，jQuery 只为 .ul2​​ 结构绑定事件监听函数，因为 .ul2​​ 下面可能会有很多无关节点也会触发click​​ 事件，所以我在 on​​ 函数里传递了第二个参数，表示只监听 a​​ 子节点的事件。

它们都可以正常工作，但是当我动态创建新 DOM 结构的时候，第一个 ul​​ 问题就出现了，新创建结构虽然还是.ul1 > a​​，但是没有绑定事件，所以无法执行回调函数。而第二个 ul​​ 工作的很好，因为点击新创建的 DOM ，它的事件会冒泡到父级节点进行处理。

如果使用原生的方式实现事件代理，需要注意过滤非目标节点，可以通过 id、class 或者 tagname 等等，例如：

```js
element.addEventListener('click', function(event) {
    // 判断是否是 a 节点
    if ( event.target.tagName == 'A' ) {
        // a 的一些交互操作
    }
}, false);
```

### 停止事件冒泡（stopPropagation）

所有的事情都会有对立面，事件的冒泡阶段虽然看起来很好，也会有不适合的场所。比较复杂的应用，由于事件监听比较复杂，可能会希望只监听发生在具体节点的事件。这个时候就需要停止事件冒泡。

停止事件冒泡需要使用事件对象的 stopPropagation​​ 方法，具体代码如下：

```js
element.addEventListener('click', function(event) {
    event.stopPropagation();
}, false);
```

在事件监听的回调函数里，会传递一个参数，这就是 Event​​ 对象，在这个对象上调用 stopPropagation​​ 方法即可停止事件冒泡。举个停止事件冒泡的应用实例：

[JS Bin](http://jsbin.com/aparot/3/embed?html,js,output)

在上面例子中，有一个弹出层，我们可以在弹出层上做任何操作，例如 click​​ 等。当我们想关掉这个弹出层，在弹出层外面的任意结构中点击即可关掉。它首先对 document​​ 节点进行 click​​ 事件监听，所有的 click​​ 事件，都会让弹出层隐藏掉。同样的，我们在弹出层上面的单击操作也会导致弹出层隐藏。之后我们对弹出层使用停止事件冒泡，掐断了单击事件返回 document​​ 的冒泡路线，这样在弹出层的操作就不会被 document​​ 的事件处理函数监听到。

更多关于 Event​​ 对象的事情，我们会在下面介绍。

## 事件的 Event 对象

当一个事件被触发的时候，会创建一个事件对象（Event Object），这个对象里面包含了一些有用的属性或者方法。事件对象会作为第一个参数，传递给我们的毁掉函数。我们可以使用下面代码，在浏览器中打印出这个事件对象：

```
<button>打印 Event Object</button>
<script>
    var btn = document.getElementsByTagName('button');
    btn[0].addEventListener('click', function(event) {
        console.log(event);
    }, false);
</script>
```

就可以看到一堆属性列表：

​![事件属性列表](https://sslstatic.ktanx.com/images/release/201513/rfYBGqrXB7qmGGzS.png)​

事件对象包括很多有用的信息，比如事件触发时，鼠标在屏幕上的坐标、被触发的 DOM 详细信息、以及上图最下面继承过来的停止冒泡方法（stopPropagation）。下面介绍一下比较常用的几个属性和方法：

### ​type​​(string)

事件的名称，比如 “click”。

### ​target​​(node)

事件要触发的目标节点。

### ​bubbles​​ (boolean)

表明该事件是否是在冒泡阶段触发的。

### ​preventDefault​​ (function)

这个方法可以禁止一切默认的行为，例如点击 a​​ 标签时，会打开一个新页面，如果为 a​​ 标签监听事件 click​​同时调用该方法，则不会打开新页面。

### ​stopPropagation​​ (function)

停止冒泡，上面有提到，不再赘述。

### ​stopImmediatePropagation​​ (function)

与 stopPropagation​​ 类似，就是阻止触发其他监听函数。但是与 stopPropagation​​ 不同的是，它更加 “强力”，阻止除了目标之外的事件触发，甚至阻止针对同一个目标节点的相同事件，Demo：[http://jsfiddle.net/yujiangshui/ju2ujmzp/2/。](http://jsfiddle.net/yujiangshui/ju2ujmzp/2/%E3%80%82)

### ​cancelable​​ (boolean)

这个属性表明该事件是否可以通过调用 event.preventDefault​​ 方法来禁用默认行为。

### ​eventPhase​​ (number)

这个属性的数字表示当前事件触发在什么阶段。none：0；捕获：1；目标：2；冒泡：3。

### ​pageX​​ 和 pageY​​ (number)

这两个属性表示触发事件时，鼠标相对于页面的坐标。Demo：[http://api.jquery.com/event.pagex/。](http://api.jquery.com/event.pagex/%E3%80%82)

### ​isTrusted​​ (boolean)

表明该事件是浏览器触发（用户真实操作触发），还是 JavaScript 代码触发的。

## jQuery 中的事件

如果你在写文章或者 Demo，为了简单，你当然可以用上面的事件监听函数，以及那些事件对象提供的方法等。但在实际中，有一些方法和属性是有兼容性问题的，所以我们会使用 jQuery 来消除兼容性问题。

下面简单的来说一下 jQuery 中事件的基础操作。

### 绑定事件和事件代理

在 jQuery 中，提供了诸如 click()​​ 这样的语法糖来绑定对应事件，但是这里推荐统一使用 on()​​ 来绑定事件。语法：

```
.on( events [, selector ] [, data ], handler )
```

​events​​ 即为事件的名称，你可以传递第二个参数来实现事件代理，具体文档[.on()](http://api.jquery.com/on/) 这里不再赘述。

### 处理过兼容性的事件对象（Event Object）

事件对象有些方法等也有兼容性差异，jQuery 将其封装处理，并提供跟标准一直的命名。

如果你想在 jQuery 事件回调函数中访问原来的事件对象，需要使用 event.originalEvent​​，它指向原生的事件对象。

### 触发事件 trigger​​ 方法

点击某个绑定了 click​​ 事件的节点，自然会触发该节点的 click​​ 事件，从而执行对应回调函数。

​trigger​​ 方法可以模拟触发事件，我们单击另一个节点 elementB，可以使用：

```
$(elementB).on('click', function(){
    $(elementA).trigger( "click" );
});
```

来触发 elementA 节点的单击监听回调函数。详情请看文档 [.trigger()](http://api.jquery.com/trigger/)。

## 事件进阶话题

### IE 浏览器的差异和兼容性问题

IE 浏览器就是特立独行，它对于事件的操作与标准有一些差异。不过 IE 浏览器现在也开始慢慢努力改造，让浏览器变得更加标准。

#### IE 下绑定事件

在 IE 下面绑定一个事件监听，在 IE9- 无法使用标准的 addEventListener​​ 函数，而是使用自家的attachEvent​​，具体用法：

```
element.attachEvent(<event-name>, <callback>);
```

其中 `<event-name>`​​参数需要注意，它需要为事件名称添加 on​​ 前缀，比如有个事件叫 click​​，标准事件监听函数监听 click​​，IE 这里需要监听 onclick​​。

另一个，它没有第三个参数，也就是说它只支持监听在冒泡阶段触发的事件，所以为了统一，在使用标准事件监听函数的时候，第三参数传递 false。

当然，这个方法在 IE9 已经被抛弃，在 IE11 已经被移除了，IE 也在慢慢变好。

#### IE 中 Event 对象需要注意的地方

IE 中往回调函数中传递的事件对象与标准也有一些差异，你需要使用 window.event​​ 来获取事件对象。所以你通常会写出下面代码来获取事件对象：

```
event = event || window.event
```

此外还有一些事件属性有差别，比如比较常用的 event.target​​ 属性，IE 中没有，而是使用 event.srcElement​​来代替。如果你的回调函数需要处理触发事件的节点，那么需要写：

```
node = event.srcElement || event.target;
```

常见的就是这点，更细节的不再多说。在概念学习中，我们没必要为不标准的东西支付学习成本；在实际应用中，类库已经帮我们封装好这些兼容性问题。可喜的是 IE 浏览器现在也开始不断向标准进步。

### 事件回调函数的作用域问题

与事件绑定在一起的回调函数作用域会有问题，我们来看个例子：

[Events in JavaScript: Removing event listeners](http://jsbin.com/atoluy/1/embed?html,js,output)

回调函数调用的 user.greeting​​ 函数作用域应该是在 user​​ 下的，本期望输出 My name is Bob​​ 结果却输出了My name is undefined​​。这是因为事件绑定函数时，该函数会以当前元素为作用域执行。为了证明这一点，我们可以为当前 element​​ 添加属性：

```
element.firstname = 'jiangshui';
```

再次点击，可以正确弹出 My name is jiangshui​​。那么我们来解决一下这个问题。

#### 使用匿名函数

我们为回调函数包裹一层匿名函数。

[Events in JavaScript: Removing event listeners](http://jsbin.com/onomud/1/embed?html,js,output)

包裹之后，虽然匿名函数的作用域被指向事件触发元素，但执行的内容就像直接调用一样，不会影响其作用域。

#### 使用 bind 方法

使用匿名函数是有缺陷的，每次调用都包裹进匿名函数里面，增加了冗余代码等，此外如果想使用removeEventListener​​ 解除绑定，还需要再创建一个函数引用。Function​​ 类型提供了 bind​​ 方法，可以为函数绑定作用域，无论函数在哪里调用，都不会改变它的作用域。通过如下语句绑定作用域：

```
user.greeting = user.greeting.bind(user);
```

这样我们就可以直接使用：

```
element.addEventListener('click', user.greeting);
```

### 常用事件和技巧

用户的操作有很多种，所以有很多事件。为了开发方便，浏览器又提供了一些事件，所以有很多很多的事件。这里只介绍几种常用的事件和使用技巧。

#### ​load​​

​load​​ 事件在资源加载完成时触发。这个资源可以是图片、CSS 文件、JS 文件、视频、document 和 window 等等。

比较常用的就是监听 window 的 load​​ 事件，当页面内所有资源全部加载完成之后就会触发。比如用 JS 对图片以及其他资源处理，我们在 load​​ 事件中触发，可以保证 JS 不会在资源未加载完成就开始处理资源导致报错。

同样的，也可以监听图片等其他资源加载情况。

#### ​beforeunload​​

当浏览者在页面上的输入框输入一些内容时，未保存、误操作关掉网页可能会导致输入信息丢失。

当浏览者输入信息但未保存时关掉网页，我们就可以开始监听这个事件，例如：

```
window.addEventListener("beforeunload", function( event ) {
    event.returnValue = "放弃当前未保存内容而关闭页面？";
});
```

这时候试图关闭网页的时候，会弹窗阻止操作，点击确认之后才会关闭。当然，如果没有必要，就不要监听，不要以为使用它可以为你留住浏览者。

#### ​resize​​

当节点尺寸发生变化时，触发这个事件。通常用在 window 上，这样可以监听浏览器窗口的变化。通常用在复杂布局和响应式上。

常见的视差滚动效果网站以及同类比较复杂的布局网站，往往使用 JavaScript 来计算尺寸、位置。如果用户调整浏览器大小，尺寸、位置不随着改变则会出现错位情况。在 window 上监听该事件，触发时调用计算尺寸、位置的函数，可以根据浏览器的大小来重新计算。

但需要注意一点，当浏览器发生任意变化都会触发 resize​​ 事件，哪怕是缩小 1px 的浏览器宽度，这样调整浏览器时会触发大量的 resize​​ 事件，你的回调函数就会被大量的执行，导致变卡、崩溃等。

你可以使用函数 throttle 或者 debounce 技巧来进行优化，throttle 方法大体思路就是在某一段时间内无论多次调用，只执行一次函数，到达时间就执行；debounce 方法大体思路就是在某一段时间内等待是否还会重复调用，如果不会再调用，就执行函数，如果还有重复调用，则不执行继续等待。关于它们更详细的信息，我后面会介绍一下发表在我的博客上，这里不再赘述。

#### ​error​​

当我们加载资源失败或者加载成功但是只加载一部分而无法使用时，就会触发 error​​ 事件，我们可以通过监听该事件来提示一个友好的报错或者进行其他处理。比如 JS 资源加载失败，则提示尝试刷新；图片资源加载失败，在图片下面提示图片加载失败等。该事件不会冒泡。因为子节点加载失败，并不意味着父节点加载失败，所以你的处理函数必须精确绑定到目标节点。

需要注意的是，对于该事件，你可以使用 addEventListener​​ 等进行监听，但是有时候会出现失效情况（看[这个例子](http://jsbin.com/esimAWA/2/quiet)），这是因为 error​​ 事件都触发过了，你的 JS 监听处理代码还没有加载进来执行。为了避免这种情况，用内联法更好一些：

```
<img src="not-found.jpg" onerror="doSomething" />
```

如果还有其他常用事件，欢迎留言补充。

### 用 JavaScript 模拟触发内置事件

内置的事件也可以被 JavaScript 模拟触发，比如下面函数模拟触发单击事件：

```
function simulateClick() {
  var event = new MouseEvent('click', {
    'view': window,
    'bubbles': true,
    'cancelable': true
  });
  var cb = document.getElementById('checkbox'); 
  var canceled = !cb.dispatchEvent(event);
  if (canceled) {
    // A handler called preventDefault.
    alert("canceled");
  } else {
    // None of the handlers called preventDefault.
    alert("not canceled");
  }
}
```

可以看这个 [Demo](https://developer.mozilla.org/samples/domref/dispatchEvent.html) 来了解更多。

### 自定义事件

我们可以自定义事件来实现更灵活的开发，事件用好了可以是一件很强大的工具，基于事件的开发有很多优势（后面介绍）。

与自定义事件的函数有 Event​​、CustomEvent​​ 和 dispatchEvent​​。

直接自定义事件，使用 Event​​ 构造函数：

```
var event = new Event('build');
// Listen for the event.
elem.addEventListener('build', function (e) { ... }, false);
// Dispatch the event.
elem.dispatchEvent(event);
```

​CustomEvent​​ 可以创建一个更高度自定义事件，还可以附带一些数据，具体用法如下：

```
var myEvent = new CustomEvent(eventname, options);
```

其中 options 可以是：

```
{
    detail: {
        ...
    },
    bubbles: true,
    cancelable: false
}
```

其中 detail​​ 可以存放一些初始化的信息，可以在触发的时候调用。其他属性就是定义该事件是否具有冒泡等等功能。

内置的事件会由浏览器根据某些操作进行触发，自定义的事件就需要人工触发。dispatchEvent​​ 函数就是用来触发某个事件：

```
element.dispatchEvent(customEvent);
```

上面代码表示，在 element 上面触发 customEvent 这个事件。结合起来用就是：

```
// add an appropriate event listener
obj.addEventListener("cat", function(e) { process(e.detail) });
// create and dispatch the event
var event = new CustomEvent("cat", {"detail":{"hazcheeseburger":true}});
obj.dispatchEvent(event);
```

使用自定义事件需要注意兼容性问题，而使用 jQuery 就简单多了：

```
// 绑定自定义事件
$(element).on('myCustomEvent', function(){});
// 触发事件
$(element).trigger('myCustomEvent');
```

此外，你还可以在触发自定义事件时传递更多参数信息：

```
$( "p" ).on( "myCustomEvent", function( event, myName ) {
  $( this ).text( myName + ", hi there!" );
});
$( "button" ).click(function () {
  $( "p" ).trigger( "myCustomEvent", [ "John" ] );
});
```

更详细的用法请看 [Introducing Custom Events](http://learn.jquery.com/events/introduction-to-custom-events/)，这里不再赘述。

### 在开发中应用事件

当我们操作某一个 DOM，发出一个事件，我们可以在另一个地方写代码捕获这个事件执行处理逻辑。触发操作和捕获处理操作是分开的。我们可以根据这个特性来对程序解耦。

#### 用事件解耦

我们可以将一个整个的功能，分割成独立的小功能，每个小功能绑定一个事件，由一个“控制器”负责根据条件触发某个事件。这样，在外面触发这个事件，也可以调用对应功能，使其更加灵活。

​![应用事件对程序解耦](https://sslstatic.ktanx.com/images/release/201513/5mn2K2k8DFiWFDYS.png)​

在《基于 MVC 的 JavaScript Web 富应用开发》一书中，有更加具体的实例，有兴趣的朋友可以买本看看。

#### 发布（Publish）和订阅（Subscribe）模式

针对上面这种用法，继续抽象一下，就是发布和订阅开发模式。正如其名，这种模式有两个角色：发布者和订阅者，此外有一条信道，发布者被触发往这个信道里面发信，订阅者从这个信道里面收信，如果收到特定信件则执行某个对应的逻辑。这样，发布者和订阅者之间是完全解耦的，只有一条信道连接。这样就非常容易扩展，也不会引入额外的依赖。

这样如果需要添加新功能，只需要添加一个新的订阅者（及其执行逻辑），监听信道中某一类新的信件。再在应用中通过发布者发送一类新的信件即可。

具体实现，这里推荐 cowboy 开发的 [Tiny Pub Sub](https://github.com/cowboy/jquery-tiny-pubsub)，通过 jQuery 实现，非常简洁直观，jQuery 太赞。代码就这几行：

```
(function($) {
  var o = $({});
  $.subscribe = function() {
    o.on.apply(o, arguments);
  };
  $.unsubscribe = function() {
    o.off.apply(o, arguments);
  };
  $.publish = function() {
    o.trigger.apply(o, arguments);
  };
}(jQuery));
```

定义一个对象作为信道，然后提供了三个方法，订阅者、取消订阅、发布者。

## 总结和扩展阅读

事件有关的基础知识基本就这些，更多的还有待你继续挖掘。本文资料参考和推荐扩展阅读如下（感谢他们）：

- [DOM-Level-3-Events](http://www.w3.org/TR/DOM-Level-3-Events/)
- [Event on MDN](https://developer.mozilla.org/en/docs/Web/API/Event)
- [Events of jQuery](http://api.jquery.com/category/events/)
- [Introducing Custom Events](http://learn.jquery.com/events/introduction-to-custom-events/)
- [An Introduction To DOM Events](http://www.smashingmagazine.com/2013/11/12/an-introduction-to-dom-events/)
- 《基于 MVC 的 JavaScript Web 富应用开发》
- [https://ld246.com/article/1582987084602](https://ld246.com/article/1582987084602) 讲的比较好

[https://juejin.cn/post/6844903834075021326](https://juejin.cn/post/6844903834075021326)

[https://zh.javascript.info/bubbling-and-capturing](https://zh.javascript.info/bubbling-and-capturing)

[https://cloud.tencent.com/developer/article/1920879](https://cloud.tencent.com/developer/article/1920879)

在 JavaScript 中，可以使用事件委托来监听页面上所有元素的点击事件。事件委托是一种利用事件冒泡的技术，将事件处理程序附加到页面上的一个父元素，并通过检测事件冒泡是否发生在某个子元素上来确定是否需要执行处理程序。

```less
document.addEventListener("click", function(event) {
  console.log("Clicked on an element:", event.target);
}, true);
// 或者
window.addEventListener("click", function(e){
    console.log(e.target.tagName);
});
```

这段代码将事件处理程序附加到整个页面，并在任意元素被点击时打印事件目标。

[https://segmentfault.com/q/1010000009266553](https://segmentfault.com/q/1010000009266553)