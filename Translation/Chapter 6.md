# 第6章 miniKanren

By Jack Moffitt

在花费了数十年来告诉计算机如何做事之后，我发现只有逻辑编程能够让我脱离苦海。
因为在使用逻辑编程的时候，你只需要描述问题的关系及其约束，计算机就会自动得出满足问题的解。

我还记得我第一次意识到逻辑编程是如此的与众不同的场景。
那是在一个会议上，当时Dan Friedman和William Byrd正在介绍一个用miniKanren编写的小型语言解释器。
他们首先展示了它可以计算一些简单的数学公式，并得能够得出正确答案。
之后就像神奇的巫术一样，他们用这个解释器反向执行了程序，并且得到原来的问题。

我们能接触到的最接近真正意义的魔法可能就是逻辑编程了。
当用逻辑来编程的时候，我并不需要担心每一细节的实现。
就像哈利波特里一样，我只是需要说“星星点灯”——然后灯就亮了。

当前有很多对miniKanren<sup>[1]</sup>的实现。
在这一章里，我们将对内嵌在Clojure中的miniKanren——core.logic进行探索。
和Prelog类似，因为对规则和约束的注重，miniKanren对于某些问题可以迎刃而解，但对于另外一些问题则没有什么好办法去解决。
而core.logic作为一个良好的实用工具，它能够在神秘的逻辑的领域和我们每天的日常工作之间架起一道方便的桥梁。

[1]: http://minikanren.org

## 第一天：代码的一致性匹配

其实只需要3天就能够让你学会并且熟练地使用逻辑。
而由于core.logic是内嵌在Clojure里的，所以如果你有函数式编程的经验，会让更加的轻松。

第一天里，我们将会了解一些逻辑的基本知识。
之后会通过一个充满因子的数据库，来了解core.logic是怎样使用它们的。
最后我们还会讲讲逻辑判断相关的知识。

在第二天，我们将会对头一天的内容进行补充，例如：
模式匹配以及一些语法糖。
之后我们会关注与散列图相关的知识。

最后一天，我们会通过学习有限域，并回顾前两天的知识。
相信到了这个时候，你也能够处理一些复杂的问题了。

虽然时间短暂，但是在学习之余，你还是可以继续探索逻辑编程，并且将其带入到自己的工作之中。

### 安装core.logic

要安装core.logic，首先需要安装Java虚拟机（JVM）以及Leiningen——一个可以让你远离繁重地管理获取各种Java库地解决方案的构建工具。

关于JVM，你可以在你的系统包管理程序里或者通过Oracle的Java下载页面<sup>[2]</sup>获取到它。
至于Leiningen以及它在各种操作系统上的安装说明，则可以从它的官方主页<sup>[3]</sup>得到相应的信息。

[2]: https://www.oracle.com/technetwork/java/javase/downloads/index.html

[3]: https://leiningen.org/

当所有的准备工作已经做好之后，你可以用命令`lein new`来创建一个新项目：

```shell
$ lein new logical
Generating a project called logical based on the 'default' template. To see other templates (app, lein plugin, etc), try `lein help new`.
```

这个命令会在`logical`目录下创建一个项目的基本结构。
我们还需要在项目文件`project.clj`里面添加一些引用，才能够在项目中使用core.logic。
修改之后的`logical/project.clj`文件应该是这样的：

**minikanren/logical/project.clj**
```shell
(defproject logical "0.1.0-SNAPSHOT" 
  :dependencies [[org.clojure/clojure "1.5.1"]
                 [org.clojure/core.logic "0.8.5"]])
```

现在，你就能够在项目目录里使用Clojure REPL并且加载core.logic了。

```shell
$ lein repl
nREPL server started on port 48235 on host 127.0.0.1 
REPL-y 0.3.0
Clojure 1.5.1
    Docs: (doc function-name-here)
          (find-doc "part-of-name-here")
  Source: (source function-name-here)
 Javadoc: (javadoc java-object-or-class-here)
    Exit: Control+D or (exit) or (quit)
 Results: Stored in vars *1, *2, *3, an exception in *e

user=> (use 'clojure.core.logic)
WARNING: == already refers to: #'clojure.core/== in namespace: user, being
  replaced by: #'clojure.core.logic/== 
nil
user=>
```

注意到那个警告了吗？
这并不是件坏事，恰恰相反，它表明有一个core.logic的符号替换掉了默认值。
逻辑就在你的指尖徘徊！

### 目标一定要成功

就像是一个只包含规则和少量数字的数独，或者是一个只能看到部分图片及其形状的拼图游戏一样，逻辑编程就像是一个只知道一部分信息的谜题，而它的解就是去找到那些剩下的信息。

简单来说，用逻辑来编程就是：
提供谜题的初始值以及相应的规则，之后core.logic会去做整个求解过程，并且解出所有可能的解。

让我们来看一个简单的逻辑程序吧。
为了让我们的探索过程更简单，这里将会用REPL来编写。
试试下面的代码：

```Clojure
user=> (run* [q] (== q 1))
(1)
```

虽然这段代码写出的逻辑程序一看就非常简单，但还是有很多点可以谈及的。

`run*`用来启动一个逻辑程序，并且返回它的所有解。
`q`叫做逻辑变量。
当逻辑变量被创建的时候，它们没有绑定在任何的值上。
正是因为它们没有值，所以它们可以代表任何的东西。
在我们的例子里，`q`的值是解的集合。
至于为什么`q`会成为最常用的逻辑变量名，或许是因为其来自于单词“查询（query）”。

关于逻辑变量的一个直观理解可以是：
在数独里每一个小块都可以当作为一个逻辑变量，其中一些小块是空的（*自由的，未绑定的*），而另外一些则被填上了值（*已绑定的*）。

在我们的逻辑程序里，还包含了一条表达式——`(==q 1)`，这并不是你曾经用到过的相等判定。
在core.logic里，`==`被称为一致性函数。
这个表达式代表的是，尝试让数字`1`和逻辑变量`q`保持一致。

与模式匹配相似，一致性是你让程序在假设可能的情况下，尝试让左右两边值相同。
当左右两边用普通的相等判定得出解的时候，未绑定的逻辑变量将会被绑定到这个值上。
在我们的例子里：
`q`会被绑定到数字`1`上，而因为没有其他的约束条件，也就得出了这个程序的解。
现在可能看起来比较奇怪，当我们看过更多的例子之后，你就能更清晰的感受到发生了什么。

在逻辑程序里，表达式被称作目标。
它们返回**成功**或**失败**，而不是**真**或**假**。
当成功的时候，可能会找到多个不同的解法，而如果没有任何解，则返回失败。
这就引申到来我们例子里的最后一部分：结果。

就像之前说的`run*`将会返回所有目标结果为成功的`q`的值。
在我们的例子中：
`q`和`1`绑定之后与数字`1`保持一致并且返回成功，因此例子里的结果为`(1)`。
这个结果集也正好是符合条件的唯一一个`q`的绑定。

让我们再来看一个失败的目标：

```Clojure
user=> (run* [q] (== q 1) (== q 2))
()
```

这个程序有2个表达式，每一个表达式都是一个目标。
当一个程序有多个目标的时候，就像其他语言中的`&&`和`and`关键词一样，只有当所有的目标都返回成功的情况下才会返回成功。
在这个例子里，第一个一致性判定会像之前的例子里一样把`q`绑定到数字`1`并返回成功。
而因为`1`并不能和`2`保持一致性，所以第二个一致性判定将会返回失败。
这样，由于没有任何一个`q`的绑定能够同时让两个目标都返回成功，程序的结果集将会为空。

### 使用关系

让我们再来看看这个逻辑方法：

```Clojure
user=> (run* [q] (membero q [1 2 3]))
(1 2 3)
```

`membero`是一个关系。
它的意思是第一个参数是第二个参数所提供的集合里的一员。
因为这也是一个目标，所以它的结果也会是成功或失败，同时当结果为成功时，
会将`q`绑定到相应的值上。在我们这个例子里，成功的返回了值`1`、`2`、`3`。
需要注意的一点是：
我这个例子里我们并没有告诉core.logic怎么解这个问题，只告诉了它关系。

`run*`会返回所有结果为成功的绑定，也就是包含了所有成功值的列表。
在我们这个简单的程序里，可以凭直觉简单地知道答案都是正确的。
这个小技巧，我们以后也能用上。

同样的，你也可以在使用`run`的时候指定需要的结果大小：

```Clojure
user=> (run 2 [q] (membero q [1 2 3]))
(1 2)
```

这个功能是非常有用的，因为在某些情况下，可能会出现满足目标的无数个解。

逻辑编程还有很多神奇的功能藏在夹袋里呢。
让我们来看看如果我们调换了`membero`的参数之后会发生什么：

```Clojure
user=> (run 5 [q] (membero [1 2 3] q))
(([1 2 3] . _0) (_0 [1 2 3] . _1) (_0 _1 [1 2 3] . _2) (_0 _1 _2 [1 2 3] . _3)
(_0 _1 _2 _3 [1 2 3] . _4))
```

我们来仔细看看这个奇妙的答案。
在原来的方法`membero q [1 2 3]`里，我们是想得到集合里面所有的元素。
但是在新的方法`membero [1 2 3] q`里，求得是什么集合包含了元素`[1 2 3]`。
正因为会有无限多种可能的集合包含元素`[1 2 3]`，所有我们要求只取得5个结果。

第一个结果是`(([1 2 3] . _0)`。
其中`.`代表的是列表的构造操作符。
`.`左边的部分是这个列表的第一个元素（头），右边的部分是这个列表的其余部分（尾）。
那个神奇的`_0`代表的是一个未绑定的逻辑变量，在这个例子里它表示列表的尾可以是任何元素。
换句话说，第一个结果说明，对于任何列表，只要它的第一个元素是`[1 2 3]`就能满足目标了。

其他的结果也是类似的，例如第二个结果就表明，对于任何列表，不论第一个元素和最后一个元素是什么，只要它的第二个元素是`[1 2 3]`就满足目标了。

这就像是对于一个已经解出来的数独，求它可能的开始状况一样。
这很酷不是吗？
我还从来没有见过其他的编程语言支持这样反向执行程序的。

> **后缀"o"是什么意思？**
> 
> 在《The Reasoned Schemer》*[FBK05]*这本书里，用上标"o"代表关系。
> 之后在miniKanren和core.logic社区里，也遵循了这一传统。
>
> 当在逻辑程序里混合了标准Clojure代码时，会发现这一个可以表示特定函数的小小视觉提示，会非常的有用。
> 起初可能看起来比较奇怪，之后你会慢慢习惯它的。并且在对其他人解释你的程序的时候会更加的方便。

### 用因子编程

我们之前介绍了core.logic的基本功能，并且发现它会找到并绑定所有能够满足程序目标的`q`。
我们同样也讲解了一个内置的关系——找到集合里的元素——`membero`。
现在，我们来自己写一个关系。

core.logic包含了一个数据库`pldb`，它可以让我们通过一组因子来构建一个简单的关系。
这和传统数据库系统的表是一样的。
比如说：
我们可以创建2个关系分别叫做`mano`和`womano`。
为了达到目的，我们需要使用`db-rel`命令。
它的第一个参数是关系的名称，其他的参数都是占位符。

```Clojure
user=> (use 'clojure.core.logic.pldb)
nil
user=> (db-rel mano x)
#'user/mano
user=> (db-rel womano x)
#'user/womano
```

这样，我们就创建了2个关系。他们都只接受一个参数，并且当这个参数分别是男性（man）和男性（woman）时返回成功。

我们可以通过给数据库里的方法绑定一组因子来构建关系。每个因子都是一个包含关系和它的参数的一个向量。

```Clojure
user=> (def facts
  #_=>   (db
  #_=>     [mano :alan-turing]
  #_=>     [womano :grace-hopper]
  #_=>     [mano :leslie-lamport]
  #_=>     [mano :alonzo-church]
  #_=>     [womano :ada-lovelace]
  #_=>     [womano :barbara-liskov]
  #_=>     [womano :frances-allen]
  #_=>     [mano :john-mccarthy]))
#'user/facts
```

之后，在数据库里查找就很简单了。让我们来试着找出所有的女性（woman）：

```Clojure
user=> (with-db facts
  #_=>   (run* [q] (womano q)))
(:grace-hopper :ada-lovelace :barbara-liskov :frances-allen)
```

`with-db`方法将数据源设置成了数据库关系。
它既支持同时使用若干个数据库，也支持使用单个数据库。
在我们的例子里，当`q`是女性时，会返回成功。
因此，结果是所有的女性成员。

让我们在多加些关系：`vitalo`和`turingo`。
它们分别代表那些人的当前的状态以及什么时候获得的图灵奖：

```Clojure
user=> (db-rel vitalo p s)
#'user/vitalo

user=> (db-rel turingo p y)
#'user/turingo

user=> (def facts
  #_=>   (-> facts
  #_=>       (db-fact vitalo :alan-turing :dead)
  #_=>       (db-fact vitalo :grace-hopper :dead)
  #_=>       (db-fact vitalo :leslie-lamport :alive)
  #_=>       (db-fact vitalo :alonzo-church :dead)
  #_=>       (db-fact vitalo :ada-lovelace :dead)
  #_=>       (db-fact vitalo :barbara-liskov :alive)
  #_=>       (db-fact vitalo :frances-allen :alive)
  #_=>       (db-fact vitalo :john-mccarthy :dead)
  #_=>       (db-fact turingo :leslie-lamport :2013)
  #_=>       (db-fact turingo :barbara-liskov :2008)
  #_=>       (db-fact turingo :frances-allen :2006)
  #_=>       (db-fact turingo :john-mccarthy :1971)))
#'user/facts
```

现在我们有足够多的因子来回答一些有趣的问题了：

```Clojure
user=> (with-db facts
  #_=>   (run* [q]
  #_=>     (womano q)
  #_=>     (vitalo q :alive)))
(:barbara-liskov :frances-allen)
```

这个目标是：所有或者的女性。需要注意的一点是，当一个目标成功，并且将值绑定到逻辑变量`q`之后，满足其他的关系的值也得要满足这个目标。

为了扩展到更复杂的逻辑程序，我们通常需要更多的逻辑变量。我们可以用`fresh`方法来创建一个新的，未绑定的逻辑变量。

```Clojure
  user=> (with-db facts
    #_=>   (run* [q]
❶   #_=>     (fresh [p y]
❷   #_=>       (vitalo p :dead)
❸   #_=>       (turingo p y)
❹   #_=>       (== q [p y]))))
([:john-mccarthy :1971])
```

1. 我们用`fresh`创建了两个未绑定的逻辑变量

2. 将`p`作为参数传给关系`vitalo`会让它被绑定到所有已经去世的人

3. 当`p`已经绑定好之后，我们可以用`turingo`关系来绑定这个人获得图灵奖的年份。
当然，这个人必须得过图灵奖才能满足关系。

4. 最后，我们将`q`绑定到一个包含了人以及年份的向量

因此这个问题可以被表述为：
“那位去世的人获得过图灵奖？”
在逻辑编程里有趣的一点是，目标的顺序并不重要。
所以在这个例子里，我们先绑定了`p`，然后是`y`，最后绑定了`q`，但这只是定义了目标，并不是执行顺序，让我们来看看改变顺序会怎样：

```Clojure
user=> (with-db facts
   #_=>   (run* [q]
   #_=>     (fresh [p y]
   #_=>       (turingo p y)
   #_=>       (== q [p y])
   #_=>       (vitalo p :dead))))
([:john-mccarthy :1971])
```

这次我们改变了目标的顺序，特别是，`q`在`p`被绑定之前就被设置了一致性。
core.logic会在逻辑变量被绑定的时候去替换未绑定的占位符。
或者，就像我们之前看到过的一样，如果那些占位符到最后都没有被绑定，就会显示成`_0`，`_1`之类的。

### 平行宇宙

在逻辑编程里，还有一个宏命令我们没有讲过：`conde`。
之前看到过的`run`，`run*`以及`fresh`都是只有当所有的目标都成功的时候才会返回成功。
这就有点像是其他语言里的`and`或者`&&`。
而`conde`则有点像`or`或`||`。

和`or`类似，当任何一个目标成功时`conde`就会返回成功。
而不同的是，`conde`会独立的返回每一个成功的目标。
就像是在平行宇宙里跑你的程序一样，不同分支的`conde`会跑在一个全新的宇宙里，然后检测到所有可能的成功。
让我们来看个例子：

```Clojure
user=> (run* [q]
  #_=>   (conde
  #_=>     [(== q 1)]
  #_=>     [(== q 2) (== q 3)]
  #_=>     [(== q :abc)]))
(1 :abc)
```

`conde`的每一个分支就是列表中的一个目标。
只有分支的目标成功时，分支才会成功。
而当每一个分支都执行结束之后`conde`返回成功。
在这个例子里：
第一个分支成功的将`q`绑定到了`1`；
在另一个宇宙里的，第二个分支返回失败；
在第三个宇宙里，第三个分支成功的将`q`绑定到`:abc`。
这样，结果就是在各个宇宙中成功绑定`q`的列表。

### 咒语的秘密

在今天早些时候，我们看到了找集合元素的`membero`关系。
在我们学习了`conso`之后，你就能够实现自己的`membero`关系了。

Lisp语言里，列表的构造函数是`cons`。
因此，`conso`毫无意外的与它是表亲关系。
`conso`是用来将一个列表的头和尾合成在一起的。
并且因为它是关系，所以它接受3个参数——和`cons`类似，最后一个参数接受一个逻辑变量来获得列表构造的结果。

```Clojure
user=> (run* [q] (conso :a [:b :c] q))
((:a :b :c))
```

我们也可以获得列表的尾部。

```Clojure
user=> (run* [q] (conso :a q [:a :b :c]))
((:b :c))
```

如果反向执行`conso`，会把列表分解成为它的头和尾。
这个例子里，我们创建了2个逻辑变量来获得列表的头和尾，然后将`q`绑定到结果的向量上。

```Clojure
user=> (run* [q] (fresh [h t] (conso h t [:a :b :c]) (== q [h t])))
([:a (:b :c)])
```

现在，你知道了怎么提取与合并列表，怎么用`conde`对时空进行操作。
所以我们可以创建一个强大的递归关系了。

让我们创建一个和内置的`membero`具有相同功能的关系`insideo`：

```Clojure
  user=> (defn insideo [e l]
    #_=>   (conde
    #_=>     [(fresh [h t]
    #_=>       (conso h t l)
❶   #_=>       (== h e))]
    #_=>     [(fresh [h t]
    #_=>       (conso h t l)
❷   #_=>       (insideo e t))]))
  #'user/insideo
```

1. 第一个分支用`conde`对集合进行分解，并且当集合的头部与传入的值相等时返回成功。

2. 第二个分支将会递归的对集合的尾部调用`insideo`关系。

我们可以用下面的公式来验证`insideo`和我们预期的结果是一样的：

```Clojure
user=> (run* [q] (insideo q [:a :b :c]))
(:a :b :c)
user=> (run 3 [q] (insideo :a q))
((:a . _0) (_0 :a . _1) (_0 _1 :a . _2))
user=> (run* [q] (insideo :d [:a :b :c q]))
(:d)
```

`insideo`也可以正向和反向工作。
并且在最后一个例子里，它甚至能够判断什么元素会让自己成功。

### 第一天我们学到了什么

现在，你已经通过在时间和空间上初步掌握了逻辑。
也知道了你并不需要知道解决方案的每一步，只需要将问题和常量用公式表达出来。

今天我们学到了很多逻辑相关的知识。
有如何用`run*`和`run`来写逻辑程序，还有逻辑变量和一致性是怎么工作的——告诉电脑一些数据和规则之后它会自动的帮你解出答案。
通过这些，我们看到了在其他语言里不存在，只存在于逻辑编程里的第一个特殊用法——`membero`关系的正向和反向执行。

存放因子的数据库可以让我们为逻辑程序创建一些基础的知识库。
随后可以用这个知识库来创建推理和查询，并且数据库也可以与其他的数据库进行合并或者扩展。

`conde`让你有能力在多重宇宙中计算并且观察到所有的可能性。
它逻辑上和其他语言的`if`或者`cond`是类似的分支结构。
但是所有的分支都会被执行，并且只有成功的路径会回馈给结果集。

最后，我们学习了如何创建我们自己的关系。
我们甚至还创建了一个递归关系。
这些内容看起来好像不多，但是已经能够让你构建一些自己的东西了。

### 轮到你了

是时候让你用core.logic来独立完成一些练习了。
别担心，我们会从一些简单的开始。

#### 查看... 

* core.logic的官方主页

* David Nolen，Dan Friedman或William Byrd的关于core.logic或者miniKanren的精彩视频

* core.logic的基本介绍

* 一些其他用core.logic的项目

#### 练习（简单）

* 尝试执行一个有两个`membero`目标并且`q`都是其第一个参数的逻辑程序。
当2个集合里有相同的元素时会发生什么？

* `appendo`是core.logic内嵌的功能，可以用来合并2个列表。
模仿`membero`的例子写几个逻辑程序来感受它是怎么工作的。
一定要试试将`q`放在3个不同参数位置上，来看看不同的结果。

* 创建2个数据库关系：
`languageo`和`systemo`，并且根据平时工作时的分类来添加相关的因子。

#### 练习（一般）

* 用`conde`创建一个关系`scientisto`，当对于任意的男性和女性时，返回成功。

* 写一个逻辑程序来找出所有获得过图灵奖的科学家。

#### 练习（困难）

* 用家族树数据库以及2个关系`childo`和`spouseso`来构建一个基因图谱。
然后再写出几个可以获得家族树的关系，例如：`ancestoro`、`descendanto`或者`cousino`。

* 实现一个与简单练习里提到过的内嵌关系`appendo`具有相同功能的`extendo`。

## 第二天：混合逻辑与函数

《The Reasoned Schemer》*[FBK05]*这本奇妙的书里，只用了2页来描述如何实现miniKanren。
如果联想到它能做到的强大功能，这真的是非常的了不起。
core.logic的实现则会大很多，因为它更注重于性能的提升以及为Clojure提供很多扩展功能。

那些介绍core.logic代码的额外的书页并不会浪费。
今天，让我们来深入了解混合Clojure和逻辑编程能够为我们带来的好处。
一开始你可能还是会感觉像是麻瓜而不是个巫师，但只要坚持下去，很快你就能混合出属于自己的独一无二的药水。

### 模式，那里都是模式

函数式编程语言的一个基本功能就是模式匹配。
但Clojure在其解构的方法里对模式匹配的支持还是非常有限，因此世面上就有了很多能够提供强大模式匹配的库。
比如说写出了core.logic的David Nolen也写处了一个世上最好的模式匹配库——core.match。
当然core.logic也毫无意外的内嵌了模式匹配功能。

让我们再来看看昨天用`conde`来测试`insideo`的不同情况的例子：

```Clojure
(defn insideo [e l]
  (conde
    [(fresh [h t]
      (conso h t l)
      (== h e))]
    [(fresh [h t]
      (conso h t l)
      (insideo e t))]))
```

`conde`每一个分支做的第一个事情都是将列表拆分成头和尾。
只需要想想就可以知道，还有很多其他的方法也会有这一重复的功能。

#### 用`matche`来匹配

`matche`可以被看作是`conde`的模式匹配版本，它可以让代码看起来更加清晰和简洁。
让我们来看看`insideo`关系用`match`重写之后的样子：

```Clojure
(defn insideo [e l]
  (matche [l]
    ([[e . _]])
    ([[_ . t]] (insideo e t))))
```

`matche`的第一个参数是我们会用去匹配的变量列表。
每一个子句就是它自身的列表，它的第一个元素就是将要匹配的模式。
可以看到，这个模式就像是参数列表一样包含了一对括号。

第一个期望被`l`匹配的模式是`[e . _]`，这个点还是列表构造操作符，点左边是列表头，后边是列表中剩下的元素。
`_`可以表示一个虚拟值，它就像是被`fresh`命令创建的新变量一样。
不同的是，它的值不会被使用，而会被直接忽略掉。
当`e`是`l`的第一个元素时，这个模式能够被匹配上。

第二个模式包含了一个我们还没有提到的变量。
`matche`会自动为在模式匹配出来的未知逻辑变量调用`fresh`命令。
因此这样代码就显得更简洁了，随后`t`会与列表的尾部进行一致化，然后我们就能够递归的使用它来保持搜索过程了。

这些模式都很简单，但是由于可以对嵌套很深的元素进行新建与一致化，模式也可以是非常复杂的。
这就让其在实践中变得非常有用：
可以直接分解输入并得到自己想要的数据，而不是对输入不断地操作来获得需要的数据。

#### 函数模式

当开始使用模式匹配的时候，你或许会注意到几乎所有的方法最后都会跟着一个巨大的`matche`块。
也正是因为这样，core.logic有另外一个模式匹配的命令——`defne`——来避免这个问题。

`defne`定义了一个为自己的参数使用模式匹配的方法。
让我们来看看下面这个例子，你会发现它能够让代码更加简洁。

```Clojure
(defne exampleo [a b c]
  ([:a _ _])
  ([_ :b x] (membero x [:x :y :z])))

;; expands to:

(defn exampleo [a b c]
  (matche [a b c]
    ([:a _ _])
    ([_ :b x] (membero x [:x :y :z]))))
```

可以看到参数列表被重复填充到了`matche`的内部。
这和有内嵌正则函数的Erlang或者Haskell有点类似。

让我们把`insideo`再用`defne`重写下。
我觉得，你应该不能写出更简单的版本了。

```Clojure
(defne insideo [e l]
  ([_ [e . _]])
  ([_ [_ . t]] (insideo e t)))
```

因为我们并不关心在不同子句里的第一个参数，所以我们用`_`来忽略掉它。
`defne`的一个不好的地方是，所有的参数都必须要满足模式，而不是仅仅满足自身的需要的就行了。
不过在通常情况下，这一点小问题还是值得的。

用现在这个`defne`的版本与前面我们一开始写的`insideo`关系进行比较，可以看出来：
模式匹配，让这个方法回归了其本质。

### 用上散列图

不管你最喜欢的编程语言叫它什么——散列图、哈希表或是词典，它都是最常用也是最重要的数据结构。
Clojure从Lisp得到并创新的一点就给予对散列图的第一等公民待遇，同样的core.logic也会这样去支持它。

在core.logic里，散列图和在Clojure里基本没有区别。
你也可以将它用在模式匹配上。

```Clojure
user=> (run* [q]
  #_=>   (fresh [m]
  #_=>     (== m {:a 1 :b 2})
  #_=>     (matche [m]
  #_=>       ([{:a 1}] (== q :found-a))
  #_=>       ([{:b 2}] (== q :found-b))
  #_=>       ([{:a 1 :b 2}] (== q :found-a-and-b)))))
(:found-a-and-b)
```

这段代码可以看出，散列图的使用非常的简单，以及它和你预期的效果并不一样。
首先这个程序用一个简单的散列图与`m`设置了一致性，然后用`matche`来匹配多个模式。如果你熟悉Clojure的话，你或许会期望所有的3个模式的目标都判定成功，但是为什么只有最后一个目标成功了呢？

答案很简单，和Clojure去解析每一个键值不同，core.logic的散列图模式必须要求完全匹配。
当你知道散列图里有那些值并且要去匹配他们的时候，这个功能还是很有用的。
但是如果你只想查找里面的一部分，就需要其他的方法了。

我们需要的是一个能够找到散列图里包含的某个值并且为其构造一个逻辑变量的方法。
在core.logic里，它被叫做`featurec`，我们来看看这个例子：

```Clojure
user=> (run* [q]
  #_=> (featurec q {:a 1}))
((_0 :- (clojure.core.logic/featurec _0 {:a 1})))
```

我们首先创建了一个包含键`:a`和值`1`的散列图`q`，然后查找`q`里所有可能的值。
这个结果稍微读起来有点麻烦，`:-`符号可以读作“满足”。
因此整句话可以理解为：
对于任意的散列图，当`{:a 1}`是的组成部分时，都能够满足为解。
这也是core.logic怎么在解里面表达约束条件的。

让我们用`conde`和`featurec`来重写之前的散列图模式：

```Clojure
  user=> (run* [q]
    #_=>   (fresh [m a b]
    #_=>     (== m {:a 1 :b 2})
    #_=>     (conde
❶   #_=>       [(featurec m {:a a}) (== q [:found-a a])]
❷   #_=>       [(featurec m {:b b}) (== q [:found-b b])]
    #_=>       [(featurec m {:a a :b b}) (== q [:found-a-and-b a b])])))
❸ ([:found-a 1] [:found-b 2] [:found-a-and-b 1 2])
```

1. 当散列图里包含键值为`:a`的元素是这个分支返回成功，并且不关心其具体的值。
要注意的是，这里也会创建一个新的变量`a`绑定到键值对里的值。

2. 和上一个分支一样，不过是判断包含键`:b`。

3. 和上次不同，这次的结果包含了所有的3个分支结果。
同时可以注意到，我们同样的取得了键值对里面的值。

你可以看到`featurec`是一个很有用的工具，因为它可以在逻辑编程中引入部分或者全部散列图，所以可以更清晰的表达很多问题。

你或许会问为什么是`featurec`而不是`featureo`。
简单说来，它并不是一个关系。
即使散列图里的值是个逻辑变量，第二个参数也必须是个散列图。
因此，它不能由一个散列图来得到它的所有可能组合信息，也就是不能被反向执行。

```Clojure
user=> (run* [q]
  #_=>   (featurec {:a 1 :b 2 :c 3} q))
ClassCastException clojure.core.logic.LVar cannot be cast to
clojure.lang.IPersistentMap
clojure.core.logic/eval3753/map->PMap--3764 (logic.clj:2443)
```

当然，这一点小小的限制并不会阻碍我们用部分散列图来做更厉害的事情。

### 另一种判定

在你熟悉的语言里都只有一种判定：
依次按顺序判定每一个条件，当成功的时候，执行当前分支里的代码。
当时当你发现core.logic里有多种判定方式的时候，请不要吃惊。
我们昨天已经看到了`conde`，今天我们会学习2个新的判定`conda`和`condu`。

就像之前说的一样，你可以当作core.logic将每一个分支都执行在平行宇宙里，而不同类型的`cond`命令则会控制有多少个宇宙，以及有多少个结果会被收集到最终的结果集里。

#### 单一宇宙

最简单理解`conda`命令的方法还是通过例子。
让我们来创建一个关系：
`whicho`，它会告诉我们某一个元素是否出现在2个列表里。
它的参数会接收1个元素，2个列表，以及结果。
最终结果会根据元素所在的列表来分别显示出：`one`，`two`，`:both`中的一个。
让我们先用之前学过的`conde`命令来写：

```Clojure
user=> (defn whicho [x s1 s2 r]
  #_=>   (conde
  #_=>     [(membero x s1)
  #_=>       (== r :one)]
  #_=>     [(membero x s2)
  #_=>       (== r :two)]
  #_=>     [(membero x s1)
  #_=>       (membero x s2)
  #_=>       (== r :both)]))
#'user/whicho
user=> (run* [q] (whicho :a [:a :b :c] [:d :e :c] q))
(:one)
user=> (run* [q] (whicho :d [:a :b :c] [:d :e :c] q))
(:two)
user=> (run* [q] (whicho :c [:a :b :c] [:d :e :c] q))
(:one :two :both)
```

在最后一个结果之前，程序都能够满足我们的需求。
那么为什么最后一个结果里会包含更多的内容呢？

core.logic会将每个分支跑在其自己独立的宇宙里，然后收集所有成功目标的结果并呈现它们。
在我们的例子里`:c`能够让3个分支都成功，因此这个解里包含了3个结果。

有些时候，这正是我们期望的，但是在这个例子里，我们还是只期望最后一个解只显示`:both`。
让我们用`conda`重写它。

```Clojure
user=> (defn whicho [x s1 s2 r]
  #_=>   (conda
  #_=>     [(all
  #_=>       (membero x s1)
  #_=>       (membero x s2)
  #_=>       (== r :both))]
  #_=>     [(all
  #_=>       (membero x s1)
  #_=>       (== r :one))]
  #_=>     [(all
  #_=>       (membero x s2)
  #_=>       (== r :two))]))
#'user/whicho
user=> (run* [q] (whicho :a [:a :b :c] [:d :e :c] q))
(:one)
user=> (run* [q] (whicho :d [:a :b :c] [:d :e :c] q))
(:two)
user=> (run* [q] (whicho :c [:a :b :c] [:d :e :c] q))
(:both)
```

现在结果就是我们所期待的了。
所以`conda`做了些什么？

`conda`只会关心当第一个成功的分支出现时的结果。
也就是说，在之前的多重宇宙的比喻里，`conda`会忽略掉其他的宇宙以及他们的结果。

在现在的`whicho`里，`conda`首先判定第一个分支的第一个目标，当这个目标成功的时候，它就会忽略掉其他的目标。
只有当这个目标失败的时候，它才会去找下一个目标。
一旦找到了一个成功的目标，不论其他的分支是否也会成功，都会被忽略掉。

你可能注意到了，在新的代码里我们调换了顺序，并且把所有的目标都用`all`包起来了。
和`conde`不同的是，`conda`是和顺序相关的，所以我们必须调换顺序。
如果`:both`分支不是第一个的话，当其他分支成功的时候，它就总会被忽略掉。
也因为在判定分支的时候是根据其第一个目标是否成功，而不是整个分支是否成功，所以`all`在这里也是必须的。
如果我们不用`all`的话，当`(membero x s1)`成功的时候，不论`(membero x s2)`是成功还是失败，都会执行到第一个分支。
也就会导致`(whicho :b [:a :b c:] [:d :e :c] q)`没有结果，而不是`:one`。

`conda`在逻辑编程里虽然不像`conde`那样常见，不过它应该和你常用的判定更相似。

#### 单一结果

`condu`和`conda`类似，只不过它会在找到第一个结果时就返回成功，而不是将解限制在一个分支里。

在我们实际操作`condu`之前，让我们再反向执行一次`insideo`：

```Clojure
user=> (run* [q] (insideo q [:a :b :c :d]))
(:a :b :c :d)
```

如果你还能记得的话，`insideo`是我们自己实现的`membero`，它会返回所有在第二个参数里的元素。
现在，让我们用`condu`来替换掉实现里的`conde`：

```Clojure
user=> (defn insideo [e l]
  #_=>   (condu
  #_=>     [(fresh [h t]
  #_=>       (conso h t l)
  #_=>       (== h e))]
  #_=>     [(fresh [h t]
  #_=>       (conso h t l)
  #_=>       (insideo e t))]))
#'user/insideo
user=> (run* [q] (insideo q [:a :b :c :d]))
(:a)
```

当第一个结果返回的时候，即使我们用`run*`来要求返回所有的解，`insideo`还是会停下来。
正因为它只要找到了任何成功的选择，就会选择那个解，`condu`也被称作*委托选择*命令。

#### 三种判定

你需要根据你所需要做的事情来选择用哪一种判定命令。
当你不太清楚该用哪一个的是偶，先从`conde`开始。
在结果不正确的情况下，当你不需要那么多分支成功的时候可以用`conda`，或者只需要一个解的时候用`condu`。
明天我们将会看到一个不能用`conde`，只能用`conda`的例子。

不同类型的`cond`命令都有其对应的`match`和`defn`命令。
对于`conde`我们已经看到过了用来做模式匹配的`matche`，以及定义模式函数的`defne`。
同样的，core.logic也为`conda`提供了`matcha`和`defna`命令，为`condu`提供了`matchu`和`defnu`命令。

要完全理解多种判定命令需要一些时间，在沉淀知识的这段时间里，我们休息一下，看看和core.logic创造者的对话。

### 对David Nolen的采访

David Nolen不光写出了一个对miniKanren的实现，也就是我们一直在用的core.logic。他还同样是很多Clojure以及JavaScript的优秀类库的作者。今天他向我们分享了逻辑编程的魅力。

**我们**：你是怎么对逻辑编程产生兴趣的？以及是什么让你创作了core.logic？

**David**：我第一次见到逻辑编程是在2009年。当时我读了Jim Duey的一篇关于逻辑编程的博客——他用Clojure移植了一个简单的miniKanren实现，并且用声明的方式解决了那个经典的逻辑问题（爱因斯坦谜题）。这既让我惊讶也让我倍感有趣，所以发邮件给他询问这一切是怎么工作的。他向我介绍了《The Reasoned Schemer》，这本我在去第一届Clojure大会的路上带着的书。而后，因为好玩，所以我决定自己实现一个简单的miniKanren。但是《The Reasoned Schemer》里并没有太多的实现细节，所以我到处找相关的信息。最终我找到William Byrd的论文，也正是这个论文澄清了很多疑问，并且在一开始实现miniKanren的路上指导了我。不久之后Clojure引入了deftype，defrecord以及protocols，也就是这个时候，我觉得通过这些知识以及功能可以写出一个合理有效的miniKanren实现。在4到5个月后，我的实现可以和SWI-Prolog一样，非常快地解掉爱因斯坦谜题。这大大的鼓励了我，随后我沉浸在逻辑和约束逻辑编程的文献里，并且不断移植一些我遇到的有趣的点子，最终就形成了core.logic。

**我们**：你觉得逻辑编程最适合去解什么类型的问题？

**David**：任何能够从声明式解决方案中受益，并且性能不是最优先考虑的问题都可以。

**我们**：有什么是在core.logic里面能做的但是在其他语言里，比如说Prelog，不能做的？

**David**：新Prelog由于灵活以及方便的自定义化，是一个非常强大的语言。我认为miniKanren和Prelog相比最大的优势是在于，它是浅埋在函数式编程语言里的。因此miniKanren能够让你用手边最好的范例去解决问题。

**我们**：你希望core.logic有什么新功能吗？

**David**：我最希望的是集成Clojure的数据结构。我也希望将所有的有限域的功能都移植到ClojureScript，但这就需要等待一个更好的官方交叉编译了。除此之外，我还有一大堆需要找到时间来评估和实施的性能优化的想法。

### 第二天我们学到了什么

声明式编程是强大且简洁的。
当我们将Clojure的功能融合到miniKanren之后，可以通过命令来创建新的方法，以及使用像散列图一样的数据结构。

我们通过用`matche`让`conde`命令更简单来学习了模式匹配。
而正因为像`matche`和`defne`这样的命令的存在，Clojure的命令才可以让逻辑编程更加的简单。

接下来我们尝试对散列图进行匹配，发现core.logic通过约束来支持部分散列图。
我们用`featurec`命令来约束散列图，并且从中取到我们需要的值的键。

最后，我们探索了三种类型的判定：
`conde`，`conda`以及`condu`。

### 轮到你了

明天我们会将整合所有的知识来实现一个例子。
所以，今天一定要练习新学到的这些知识。

#### 查看...

* `featurec`的示例代码

* core.logic里`membero`的源码

#### 练习（简单）

* 用`matche`或`defne`来重写第一天问题里的`extendo`。

* 创建一个接受`:username`作为键的散列图的关系`not-rooto`，当`:username`的值为“root”时，返回成功。

* 反向执行`whicho`来找到，只在一个列表里或者同时存在在两个列表里的元素。

* 在`whicho`里添加一个分支`:none`。当`whicho`是用`conde`实现的时候，在执行到`:none`分支时会发生什么。

#### 练习（一般）

* 用昨天的数据库来创建关系：`unsungo`。
它可以接受一个包含电脑科学家的列表，并且当所有人都没有得过图灵奖时，返回成功。
在这里用`conda`应该会很有用。

#### 练习（困难）

* 反复执行`(insideo :a [:a :b :a])`，看看它会返回多少个成功？
让它只返回一次成功，并且当执行`(insideo q [:a :b :a])`的时候，返回所有不重复的元素。
提示：可以用`!=`操作符。

## 第三天：用逻辑来写故事

在前两天，你已经见到了core.logic的很多功能。
现在是到了让我们整合这些知识，并且实现一个大型的例子的时候了。

世面上有许许多多涉及到路线规划的问题。
例如，你如何飞到一个遥远的城市？有时会有直达的航班，但也有些时候，路径会涉及到多条线路：不同的飞机，以及甚至几家航空公司。
或者是一个卡车运送的问题。
你必须从所有可能的路线里选出最快或者最短的线路。

如果你想，其实可以有一个相似但更有趣的问题。
并不需要去连接不同的城市，相反可以是有很多情节点，通过这些情节点构成了整个故事。
然后，作为一个作家，为了达到最佳的效果，你需要不断地优化它：因此这个故事应该很短吗？还是应该在结尾的时候让每个人都死掉呢？

我们将会用目前学到的逻辑知识来构建一个故事生成器。
这里我们会用到和那些路径规划问题相同的技术，因此结果可能会显得很简单。

在我们构建故事生成器之前，我们还有最后一个core.logic的功能需要提及：有限域。

### 用有限域编程

逻辑编程的背后其实都是定向搜索算法。
你指定约束条件，然后程序就会去找到满足的解。

到目前为止，我们在逻辑编程里接触到了元素，列表以及散列图。
虽然这些解可能会无限大，但是他们还是由有限的一组具体元素组成合成的。
因此，为了找到`(membero q [1 2 3])`的解，core.logic只需要依次遍历每一个元素。

那当我们对数字进行操作的时候会发生什么呢？假设我们查找`(<= q 1)`的整数解，这里有无数的解，甚至更糟的是有无数种可能性去尝试。
于是，根据你从哪里开始，以及怎么去搜索，你有可能永远得不到解。

当我们限定`q`是正整数或者其他一组数字集合的时候，这个问题就迎刃而解了。
在core.logic里，我们可以用有限域来对施加约束，它能够为搜索的问题添加一套有效状态集的知识。
让我们来看一个用了有限域的`(<= q 1)`例子：

```Clojure
  user=> (require '[clojure.core.logic.fd :as fd])
  nil
  user=> (run* [q]
❶   #_=>   (fd/in q (fd/interval 0 10))
    #_=>   (fd/<= q 1))
❷ (0 1)
```

1. 通过这个约束，`q`被限定在给定区间里的整数。

2. 正因为约束域，所以解是有限的，并且能够很快的得出结果。

有限域不光能够在数字上使用，也更够让你在逻辑变量上的进行数学操作。
我们可以让core.logic帮我们找出不相等的三个相加和为100的数的所有解。

```Clojure
  user=> (run* [q]
❶   #_=>   (fresh [x y z a]
    #_=>     (== q [x y z])
❷   #_=>     (fd/in x y z a (fd/interval 1 100))
❸   #_=>     (fd/distinct [x y z])
❹   #_=>     (fd/< x y)
    #_=>     (fd/< y z)
    #_=>     (fd/+ x y a)
    #_=>     (fd/+ a z 100)))
❺ ([1 2 97] [2 3 95] [1 3 96] [1 4 95] [3 4 93] [2 4 94] ...)
```

1. `x`，`y`和`z`是我们需要解出的数字，`a`只是一个临时使用的变量。

2. 将所有的逻辑变量都约束在1到100这个有限的范围里。

3. `fd/distinct`设置了一个逻辑变量之间彼此不能相等的约束。
可以防止类似解：`[1 1 98]`的发生。

4. 我们限定`x`必须要小于`y`，同样的`y`必须要小于`z`。
如果我们没有加这一步的话，就会出现`[6 28 66]`和`[66 28 6]`这样重复的解。

5. core.logic并不慢，因为总共有784个解，而我的机器只用了5毫秒就全部得到了它们。

除了用一个临时逻辑变量来辅助3个数相加比较蠢之外，整个代码是没有问题的。
并且，core.logic在数学计算上还提供了一个语法糖：`fd/eq`。
它可以让我们用正常的表达式来表达我们的等式。
在将它转换到代码的时候，它会自动创建合适的临时逻辑变量，以及用合适这个临时变量的有限域来对它进行约束。

```Clojure
user=> (run* [q]
  #_=>   (fresh [x y z]
  #_=>     (== q [x y z])
  #_=>     (fd/in x y z (fd/interval 1 100))
  #_=>     (fd/distinct [x y z])
  #_=>     (fd/< x y)
  #_=>     (fd/< y z)
  #_=>     (fd/eq
  #_=>       (= (+ x y z) 100))))
([1 2 97] [2 3 95] ...)
```

最后一行显然更简单了，也让整个程序更易读了。

让我们花些时间回顾一下发生了什么。
命令让逻辑变成了普通的语法，有限域将搜索的问题约束到一个小的范围，而后程序会返回所有可能的解，而不是单独的解。
最重要的是，它是声明式的，因此读起来就像是问题的描述，而不是解决的方法。

### 神奇的故事

到目前为止，我们的例子都是为了让你能够更好的理解core.logic中的单独功能。
不过现在，我们会把你所学到的所有功能放到一个更现实，更复杂的例子里进行练习。
这之后，你就能像是哈利·波特一样，可以用咒语来开门或者完成其他的普通任务了。

就像是逻辑编程擅长于解决的：
通过路线，调度交货或者路径规划问题等等这些问题一样，我们的任务将会是一个添加了约束条件的路径查找。

和寻找送货卡车的路线或者用合适的通过路线来到达另一个城市不同，我们会生成故事。
利用数据库里的情节元素，我们可以得出一个能够达到某一特定结局的故事。
也就是，由你控制的逻辑以及结果，使得情节元素通过特定的路径并且成为一个故事。

> **灵感的源泉**
>
> 2013年的Strange Loop里的一个奇妙的演讲催生了这个例子。
> 那个演讲是Chris Martens的“线性逻辑编程”<sup>[a]</sup>。
> 她同样也是“线性逻辑编程创造小故事生成器”论文的合作者<sup>[b]</sup>。
> Chris在里面解释了线性逻辑编程，然后用《包法利夫人》为参考，让这一技术生成并探索故事。
> 因此我强烈推荐你可以去研究一下她的工作。
> 
> [a]: http://www.infoq.com/presentations/linear-logic-programming
> [b]: https://www.cs.cmu.edu/~cmartens/lpnmr13.pdf

core.logic会生成很多各种各样可能性的故事，然后我们会去选出一条最有趣的来。
我们会让Clojure根据我们的条件选出合适的故事。
比如说，我们可能会为了看更长更有趣的故事，而筛掉短故事。

#### 问题的细节

在开始之前，让我们对这个问题先下一些定义。

首先，我们需要一个存放故事元素的集合，还要一个可以推动故事元素的方法。
虽然我们需要去创造很多情节点，但是我们可以很轻松的把他们当作因子存放在数据库里。
我们可以直接用上好莱坞的惊悚喜剧电影《妙探寻凶》的情节，来省去创造情节点的麻烦。
这个故事讲述了：
六个客人被邀请到一座奇怪的房子中做客，在那里发生了一起谋杀事件，他们必须配合那里的职员找出这起案件的凶手。

这里是一些电影里的故事片段：

1. Wadsworth打开门，并在一个辆抛锚的车旁边发现了一名滞留的司机。
这个司机希望能够用电话，因此Wadsworth将他带到了会客厅。
调查小组的人将这个司机锁在了会客厅里，一边在其他房间里继续搜索杀手。

2. 过了会儿，警察找到了这个废弃的车，并且开始着手调查发生了什么。

3. 同时，有人用扳手杀掉了司机。

我们可以用线性逻辑来模拟并管理电影从情节点1进展到情节点2。
线性逻辑是你可能已经非常熟悉的逻辑的延伸，它可以让你使用并且操作某些资源。
比如说，逻辑命题可能需要和使用特定的资源，我们会说“A消费了Z并且生成了B”，其中Z是某种特殊的资源，而不是“A蕴含B”。
那么回到之前的故事片段里，情节3消费了一名司机，生成了一名死掉的司机。
同样的情节2消费了一名司机，生成了一名警察。

我们可以在core.logic的基础上创建一个简单的线性逻辑。
因为每个情节元素都会有它需要一些资源以及它会生成的一些资源，所以我们会用一种2个元素的向量来表是需要以及生成的资源。
例如：`[:motorist :policeman]`代表为了让这一幕发生，我们必须要有一个可用的`:motorist`然后它会生成`:policeman`。
在电影里，这名滞留的司机按响了门铃去寻求帮助，紧接着一名警察发现了他的车，并且走进去找他。
如果没有这名司机，警察永远也不会出现。

我们将会有一组初始可用元素来作为起始状态，也会有一个用来把已经存在的故事元素推进到新的故事元素的关系，并且在结束状态里放上我们的需求来控制整个故事的走向。
比如说：当某个特定的人被抓或者被杀死的时候，整个故事结束。

在最后一步，我们将会把生成的故事按照可阅读的版本打印出来。

#### 故事元素

我们的故事元素需要包含所有被消费以及被生成的资源。
此外我们还会为这些元素添加被用于打印出可读故事的片段。

我们会需要大量的元素集来生成精彩的故事，但是《妙探寻凶》的剧情太多了。
你可能已经注意到了不同的人能够被不同的方式谋杀掉；甚至《妙探寻凶》呈现出了3个不同的结局。

让我们先添加一些元素`story-elements`到`story.clj`文件里：

**minikanren/logical/src/logical/story.clj**
```Clojure
(def story-elements
  [[:maybe-telegram-girl :telegram-girl
    "A singing telegram girl arrives."]
   [:maybe-motorist :motorist
    "A stranded motorist comes asking for help."]
   [:motorist :policeman
    "Investigating an abandoned car, a policeman appears."]
   [:motorist :dead-motorist
    "The motorist is found dead in the lounge, killed by a wrench."]
   [:telegram-girl :dead-telegram-girl
    "The telegram girl is murdered in the hall with a revolver."]
   [:policeman :dead-policeman
    "The policeman is killed in the library with a lead pipe."]
   [:dead-motorist :guilty-mustard
    "Colonel Mustard killed the motorist, his old driver during the war."]
   [:dead-motorist :guilty-scarlet
    "Miss Scarlet killed the motorist to keep her secrets safe."]
   ;; ...])
```

这里用的数据结构是向量的向量。
内部的向量会包含3个元素：2个资源以及一段描述。
为了让我们得到精彩的故事，`story-elements`一共存放了27个元素。

我们还是需要对它进行一些处理，来使的它能够被存放到我们在core.logic里的故事数据库里。

#### 构建数据库和初始状态

我们的首要目标是把`story-elements`向量转换成core.logic能用的数据库因子。
我们可以用一个简单的关系`ploto`来把输入元素关联到输出元素。
所以当做完这件事之后，我们应该能够有和下面相似的代码：

```Clojure
(db-rel ploto a b)

(def story-db
  (db
   [ploto :maybe-telegram-girl :telegram-girl]
   [ploto :wadsworth :dead-wadsworth]
   ;; ...))
```

我们可以用Clojure的`reduce`方法来执行这种转换。

**minikanren/logical/src/logical/story.clj**
```Clojure
  (db-rel ploto a b)

  (def story-db
❶   (reduce (fn [dbase elems]
              (apply db-fact dbase ploto (take 2 elems)))
❷           (db)
❸           story-elements))
```

1. `reduce`方法接受2个参数。
第一个参数是一个能够包含方法初始、中间或者最终结果的蓄能器。
第二个参数是当前执行的元素。
在我们这里我们用`ploto`关系提取故事元素向量里元素的头2个元素，关系生成的因子被用来填充数据库。
最后再把数据库作为第一个参数传进去。

2. 我们的初始状态只是一个空白的数据库。

3. 对`story-elements`执行命令会导致故事元素那个向量的向量成为core.logic的数据库因子。

在有了故事元素之后，我们还需要一个初始状态。
这个状态包含所有可能会出现的人物，以及所有已经在房子里，即将被杀害的人们。
要注意的是，这里我们只需要列出故事元素里会被消费的资源。

**minikanren/logical/src/logical/story.clj**
```Clojure
(def start-state
  [:maybe-telegram-girl :maybe-motorist
   :wadsworth :mr-boddy :cook :yvette])
```

包含故事元素的数据库和初始状态定义了我们故事里所有需要的数据。
正如你过会儿会见到的一样，这些数据的准备会比真正生成故事的代码还要长。

#### 情节的演进

我们下一步任务是创建一个能够选择合适的故事元素，并将其演进到下一状态的剧情关系。
这也正是我们生成器的核心部分：

**minikanren/logical/src/logical/story.clj**
```Clojure
  (defn actiono [state new-state action]
    (fresh [in out temp]
❶     (membero in state)
❷     (ploto in out)
❸     (rembero in state temp)
❹     (conso out temp new-state)
      (== action [in out])))
```

1. 在`in`里的资源必须是在当前状态里的。
在故事资源变为可用之前，我们并不能使用它。

2. 一旦我们在`in`里有了一个资源，`ploto`就需要去找到对应的资源，并且生成`out`变量。

3. 这个资源在故事过程中被消费了，因此需要从当前状态里删掉它。

4. 新生成的资源需要被添加到状态里，形成新的状态集。

我们可以在REPL里引入`logical.story`，并且调用`actiono`来进行测试：

```Clojure
user=> (require '[logical.story :as story])
user=> (with-db story/story-db
  #_=>   (run* [q]
  #_=>     (fresh [action state]
  #_=>       (== q [action state])
  #_=>       (story/actiono [:motorist] state action))))
([[:motorist :policeman] (:policeman)]
 [[:motorist :dead-motorist] (:dead-motorist)])
```

这个查询语句里包含了起始状态`[:motorist]`，并且期望得到所有可能的剧情以及它们相对应的新状态。
也就是警察能够去寻找滞留的司机，或者是司机能够被谋杀的这些状态。

我们需要把这个转换反向执行来生成我们的故事，也就是在开始的时候就有一些目标条件——那些我们期望在结束状态里存在的资源——然后我们期望能够找出一个能够从开始状态到这些目标的剧情流程。

**minikanren/logical/src/logical/story.clj**
```Clojure
  (declare story*)

  (defn storyo [end-elems actions]
❶   (storyo* (shuffle start-state) end-elems actions))

  (defn storyo* [start-state end-elems actions]
    (fresh [action new-state new-actions]
❷     (actiono start-state new-state action)
❸     (conso action new-actions actions)
      (conda
❹      [(everyg #(membero % new-state) end-elems)
        (== new-actions [])]
❺      [(storyo* new-state end-elems new-actions)])))
```

1. `storyo`作为`storyo*`的简写可以可以让用户不用每次都输入初始状态。
对初始状态的打乱则会让每次生成的解的顺序都不同。

2. 我们通过某些剧情来使得某些状态转变成新的状态。

3. 我们将会在一个列表里准备我们得到的剧情。

4. `everyg`命令是，只有当第二个参数里提供的集合里的所有元素，都能够让第一个参数里的目标函数返回成功时，才会返回成功。
当在`end-elems`里的所有资源都属于`new-state`的时候，我们的故事也就结束了。
而因为之后不会有更多的剧情，因此将`new-actions`置为空向量。

5. 如果我们的目标并没有完全成功，则递归调用`storyo*`直到故事结束。

让我们在REPL里调用`storyo`来生成一些简单的故事：

```Clojure
user=> (with-db story/story-db
  #_=>   (run 5 [q]
  #_=>     (story/storyo [:dead-wadsworth] q)))
(([:wadsworth :dead-wadsworth])
 ([:maybe-motorist :motorist] [:wadsworth :dead-wadsworth])
 ([:maybe-telegram-girl :telegram-girl] [:wadsworth :dead-wadsworth])
 ([:maybe-motorist :motorist] [:motorist :policeman]
  [:wadsworth :dead-wadsworth])
 ([:maybe-motorist :motorist] [:motorist :dead-motorist]
  [:dead-motorist :guilty-mustard] [:wadsworth :dead-wadsworth]))
```

core.logic用我们的故事数据库生成了5个结局是Wadsworth死掉的故事。
每个解都是由一些列的剧情组成的，如果你还记得所有的故事元素，并且仔细研究这些解，那你应该能够知道到底发生了什么。
比如，在最后这个故事里，滞留的司机出现后被Mustard上校杀掉了，之后Wadsworth在走廊里被被左轮手枪杀害。

所以我们还有些事情需要做。
生成的故事不应该是这样单调的剧情，而应该是人类直接可读的故事。
因此我们需要把故事内容给提取出来，生成更加有趣的结果。

#### 可读的故事

要生成可读的故事只需要把在`story-elements`里存放的解释给提取出来并输出为结果。
因此我们可以把`story-elements`从剧情转换成文字的散列图，然后就能够在结尾处输出人类可读的故事了。

**minikanren/logical/src/logical/story.clj**
```Clojure
  (def story-map
❶   (reduce (fn [m elems]
              (assoc m (vec (take 2 elems)) (nth elems 2)))
            {}
            story-elements))
  (defn print-story [actions]
    (println "PLOT SUMMARY:")
❷   (doseq [a actions]
      (println (story-map a))))
```

1. 我们的命令会为每一个元素创造一个新的键值对，并将它放在一个散列图里。
和之前的剧情向量类似，我们的键还是包含了输入输出的2个资源的向量，值是故事元素里的解释。

2. `print-story`只是从之前生成的散列图里找到对应剧情的解释，并且输出出来成为结果。

让我们来试着生成一个故事：

```Clojure
  user=> (def stories
    #_=>   (with-db story/story-db
❶   #_=>     (run* [q]
    #_=>       (story/storyo [:guilty-scarlet] q))))
  #'user/stories
❷ user=> (story/print-story (first (drop 10 stories)))
  PLOT SUMMARY:
  A stranded motorist comes asking for help.
  The motorist is found dead in the lounge, killed by a wrench.
  Colonel Mustard killed the motorist, his old driver during the war.
  The cook is found stabbed in the kitchen.
  Miss Scarlet killed the cook to silence her.
  nil
```

1. `run*`会生成所有的故事的流。
不过因为它是延迟加载的，所以它会马上返回，并且等到我们真的需要结果的时候才输出解。
Clojure的一个有用的功能就是延迟流。

2. 为了得到更长，更有趣的故事，我们可以忽略掉一些初始故事。
在这里我们忽略了前10个故事，并从剩下的流中选取了第一个故事作为结果。

到现在为止，我们的进展还是不错的。
生成的故事虽然有点短，不过读起来还是蛮有趣的。
随后，我们将会用上Clojure强大的流操作功能来对我们的故事流进行处理。

#### 挖掘故事

Clojure有对各种数据进行分解、筛选以及操作的大量工具。
在前面的例子里，你以及可以了解到用这些工具对core.logic产生的延迟流进行操作是多么的简单。

我们可以通过使用这些工具来从`run*`以及`storyo`生成的故事里找出更有趣的来。
通过同时使用流处理以及目标状态，我们可以直接得到最有趣的结果。

```Clojure
user=> (defn story-stream [& goals]
  #_=>   (with-db story/story-db
  #_=>     (run* [q]
  #_=>       (story/storyo (vec goals) q))))
#'user/story-stream

user=> (story/print-story
  #_=>   (first
  #_=>     (filter #(> (count %) 10)
  #_=>             (story-stream :guilty-peacock :dead-yvette))))
PLOT SUMMARY:
A stranded motorist comes asking for help.
Investigating an abandoned car, a policeman appears.
The policeman is killed in the library with a lead pipe.
Mrs. Peacock killed the policeman.
Mr. Boddy's body is found in the hall beaten to death with a candlestick.
Wadsworth is found shot dead in the hall.
Mr. Green, an undercover FBI agent, shot Wadsworth.
A singing telegram girl arrives.
The telegram girl is murdered in the hall with a revolver.
Miss Scarlet killed the telegram girl so she wouldn't talk.
Yvette, the maid, is found strangled with the rope in the billiard room.
nil
```

正因为我们要求故事里至少包含10个元素，Yvette被杀，以及Mrs. Peacock是一名凶手，我们生成了一个形势非常严峻的故事。

你可以继续执行，来看看还能得到什么有趣的故事。
在今天的练习里，我们会对这个系统进行扩展。

### 第三天我们学到了什么

今天我们从更实用的角度了解了core.logic。
逻辑编程并不只是能解谜题，很多现实中的问题也可以被它解决。

我们首先了解了在需要约束求解时非常有用的有限域。
例如：Mac OS X操作系统的界面引擎就是一个约束求解器。
而对core.logic来说，它不光能够让这类的问题更容易表达，还能够很快地得到问题的解。

之后，我们用逻辑实现了一个不是解决城市连接路线，而是通过不同的情节点来生成故事的路径规划问题。
通过使用简单的线性逻辑，递归函数以及Clojure提供的数据操作工具，我们成功的用几行代码就创建了一个故事生成器的原型。

### 轮到你了

如果你还没有玩过这章里的任何代码的话，现在是到了你来用今天学到的这些工具的时候了。

#### 查看...

* 其他人用core.logic的有限域的例子

* 由逻辑引擎为核心的商业产品。
提示：可以搜搜Prolog。

#### 练习（简单）

* 写一些其他的数学等式，并让core.logic解它。

* 生成一个包含司机从来没出现并且有至少两个杀人犯的故事。

#### 练习（一般）

* 如果在故事的结尾我们才能够知道谁是杀手的话，整个故事将会变得更加的悬疑。
用Clojure的数据操作工具来将这些故事事件放到结尾。

* 如果警察提前到来，那名司机就永远不会被杀。
因为在我们的线性逻辑里，输入永远会被消费，所以这是一个的缺陷。
请尝试扩展故事生成器来使得故事元素能够有多个输出。
然后用这个新的生成器来生成警察和司机都被杀害的故事。

#### 练习（困难）

* 请尝试用有限域来实现一个数独求解器。
提示：你可以用`lval`来为所有的空格子创建匿名逻辑变量。
需要为每一个行，每一列，以及每一个块都创建相应的规则。

* 用你最喜欢的书来创建一套全新的故事元素以及它的初始状态。
并且用故事生成器来生成一个你觉得最有趣的版本。

## miniKanren的回顾

逻辑编程与其他的语言比较起来，有点奇怪。
因为它可以反向执行，甚至无需任何具体的解法的步骤就可以实现一个程序。
虽然需要一个适应的过程，但是，对于某些问题来说，逻辑编程更为简单。
而如果你打算用其他工具解决这类问题的时候，很难写出更好或者更短的程序。

将一个功能强大的系统内嵌到像Clojure这样的一个实际的编程语言里，可以让逻辑与你的普通代码无缝的连接起来。
也使得解决问题更为容易。

### 优势

miniKanren最大的优势是，它能够用声明式语言来完成几乎我们所有期望的功能。
另一个优势是它可以反向执行，以及对于目标顺序的不在乎。
这也就使得它对于约束求解、调度或者寻找路径这类的问题非常易于表达。

core.logic将这一切集成到了Java生态圈里的一个实际的日常编程语言——Clojure——里。
因此，你可以使用现有的SQL数据库，以及数不清的现有类库。

试想一下，与core.logic相比，如果用Java或者Ruby来制作一个故事生成器。
它还是能够那么容易的被修改和扩展吗？

### 不足

逻辑编程并不十分易懂，当出现问题的时候，很难说清在背后到底发生了什么导致的这一切。
我在写这一章的时候，就曾花费了若干小时去调试其中的一个例子，而且到最后，我都没能让它正常工作。

虽然这是一门新语言，但是逻辑编程很难让你像其他新语言那样找到共同处来加快学习。

### 写在最后

与其说miniKanren是一个类库，倒不如说它是一个有着新的编程范式的编程语言。
它也是我遇到的最有趣的编程语言，因为每次反向执行程序生成的结果都会让我惊喜万分。

当问题能够满足它的作用域的时候，解法是如此的简单，表达也是如此的简明。
因此，我为其他任何语言都没有内嵌一个像miniKanren这样的逻辑系统而感到惊讶。
正因为集成了Clojure以及用上了很多Clojure的优势，core.logic在逻辑编程上展现出了了非常优秀的本领。
我非常期待看到core.logic以及miniKanren的发展，以及将他们扩展到各个角落。
