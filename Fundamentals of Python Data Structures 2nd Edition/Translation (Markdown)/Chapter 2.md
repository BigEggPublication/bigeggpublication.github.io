# 多项集的概述

在完成这一章的学习之后，你就能够：

* 定义多项集的四个通用类型：线性多项集、分层多项集、图多项集以及无序多项集；
* 知道四个多项集类型的独特之处；
* 知道哪些多项集适合被用在什么应用程序里；
* 描述每种多项集类型的常用操作;
* 描述多项集的抽象类型和实现之间的区别。

顾名思义，**多项集**（**Collection**）是指由零个或者多个元素组成的概念单元。在现实里，除非是特别小的软件，几乎所有软件都会涉及到对多项集的使用。尽管你在计算机科学领域学到的不少东西会随着技术的变化而变化，但是构成多项集的基本原理仍然是一样的。虽然不同多项集的结构和用途都可能会有所不同，但是它们都具有相同的基本用途：它们都能帮助程序员有效地组织程序里的数据，并且帮助程序员对现实世界里的对象的结构和行为进行建模。

我们可以从两个角度来查看多项集。多项集的用户或者说客户端，会关心它们在不同的应用程序里是如何工作的；多项集的开发者或者说实现者，则会关心如何才能让它们成为最好的通用资源去被使用。

这一章会从这些多项集的用户的角度来概述各个不同类型的多项集，还会介绍这些多项集上所支持的常用操作以及它们的常用实现。

## 多项集类型

就像你已经知道的那样，Python包括了几种内置的多项集类型：字符串、列表、元组、集合以及字典。字符串和列表可能是最常见的也是最基本的多项集类型了。多项集的一些其它重要类型包括：堆栈、队列、优先队列、二叉查找树、堆、图、包以及各种类型的有序多项集。多项集可以是同质的，换句话说，多项集里的所有元素都必须是同一类型的；也可以是异构的，换句话说，里面的元素可以是不同类型的。在许多的编程语言里多项集都是同质的，但大多数Python多项集都是可以包含多种类型的对象。

多项集通常来说不是**静态**（**static**）的，而是**动态**（**dynamic**）的，这就意味着它们可以根据问题的需要来扩大或者缩小。此外，多项集里的内容也是可以在程序的整个的过程中被改变的。这个规则的一个例外是**不可变多项集**（**Immutable Collection**），比如说像是Python里的字符串或是元组。不可变多项集的元素会在创建的过程中就被添加进去，创建成功之后就不能再添加、删除或者是替换任何元素了。

多项集的另一个重要区别特征是它的构成方式。我们接下来会按照构成形式来了解几种被广泛使用的多项集类别：线性多项集、分层多项集、图多项集、无序多项集以及有序多项集。

### 线性多项集

**线性多项集**（**Linear Collection**）里的元素——就像人们排成一排那样——会按照位置进行排列。除了第一个元素，其它的每个元素都有且只有一个前序，而除最后一个元素之外，其它的每个元素都有且只有一个后序。就像图2-1里那样：D2的前序是D1，D2的后序是D3。

![Figure 2-1](../Resources/Chapter2/Figure%202-1.png)

图2-1 线性多项集

一些在日常生活中可以发现的线性多项集的例子有：要买的杂货的清单、堆在一起的餐盘以及在排队等待使用ATM机的顾客等等。

### 分层多项集

**分层多项集**（**Hierarchical Collection**）里的数据元素会以类似于倒着的树的结构进行排列。除了顶部的数据元素之外，其它的每个数据元素都有且只有一个前序（被称为**父元素**（**Parent**）），但它们可以有许多的后序（被称为**子元素**（**Children**））。就像图2-2里那样：D3的前序（父元素）是D1，D3的后序（子元素）是D4、D5和D6。

![Figure 2-2](../Resources/Chapter2/Figure%202-2.png)

图2-2 分层多项集

文件目录系统、公司的组织架构以及书籍里的目录等都是分层多项集的例子。

### 图多项集

**图多项集**（**Graph Collection**）（也被称为**图**（**Graph**））是这样一个多项集：它的每一个数据元素都可以有多个前序和多个后序。就像图2-3里那样：连接到D3的所有元素都会被当作它的前序和后序，它们也因此被称为D3的*邻居*。

![Figure 2-3](../Resources/Chapter2/Figure%202-3.png)

图2-3 图多项集

图的例子可以有：城市之间的航线图、建筑物的电气接线图以及万维网等。

### 无序多项集

顾名思义，**无序多项集**（**Unordered Collection**）里的元素没有特定的顺序，并且不会有任何明确的意义来指出元素的前序或者是后序。图2-4展示了这种结构。

![Figure 2-4](../Resources/Chapter2/Figure%202-4.png)

图2-4 无序多项集

一袋大理石弹珠是无序多项集的一个例子。虽然你可以把所有弹珠都放进袋子里去，然后以你所希望的顺序从袋子里去取出弹珠，但是在袋子里的时候，弹珠并没有什么特定的顺序。

### 有序多项集

**有序多项集**（**Sorted Collection**）会对它里面的元素进行**自然排序**（**Natural Ordering**）。比如说像是：电话簿里的条目（20世纪的那种纸质书籍）以及班级名册上的名称等都是有序多项集。

要进行自然排序的话，就必须要有一些——像是$item_i <= item_{i + 1}$这样的——规则来对有序多项集里的元素进行比较。

虽然有序列表是最常见的有序多项集，但是有序多项集并不必须是线性的或者是按照位置进行排序的。从客户端的角度来看，对于集合、包以及字典来说，虽然不能按照位置来访问它们的元素，但它们都可以是有序的。一种特殊的分层多项集类型（被称为二叉查找树）也会对它里面的元素进行自然排序。

有序多项集能够让客户按照排序之后的顺序来访问它的所有元素。对于某些比如说像是搜索这样的操作来说，在有序多项集里的效率会比在无序多项集里更高效。

### 多项集类型的分类

在了解了多项集的主要类别之后，你现在可以把不同的常用多项集类型进行分类，如图2-5所示。这个分类将能够帮助你对本书后续章节里提到的这些类型的Python类进行总结。

![Figure 2-5](../Resources/Chapter2/Figure%202-5.png)

>         多项集
>         |
>         |-------图多项集
>         |
>         |-------分层多项集
>         |       |
>         |       |------二叉查找树
>         |       |
>         |       |------堆
>         |
>         |-------线性多项集
>         |       |
>         |       |------列表
>         |       |      |
>         |       |      |------有序列表
>         |       |
>         |       |------队列
>         |       |      |
>         |       |      |------优先队列
>         |       |
>         |       |------堆栈
>         |       |
>         |       |------字符串
>         |
>         |-------无序多项集
>         |       |
>         |       |------包
>         |       |      |
>         |       |      |------有序包
>         |       |
>         |       |------字典
>         |       |      |
>         |       |      |------有序字典
>         |       |
>         |       |------集合
>         |       |      |
>         |       |      |------有序集合

图2-5 多项集类型的分类

在这里需要注意的是，这个分类里的类型名称并不是指多项集的特定实现。就像你很快就能在后面看到的那样，一种特定类型的多项集可以有多个实现。另外，某些名称（比如说“多项集”以及“多项集上的线性操作”）指代的是某个多项集的类型，而不是指特定的多项集。虽然有些需要注意的地方，但是这样的分类能够让人们在构建不同多项集的共同特征和行为的时候非常有用。

## 多项集操作

你可以对多项集进行的操作，会基于你所使用的多项集的类型不同而有所不同。但是通常来说，这些操作都可以被分到表2-1里简单描述的几大类里去。

表2-1 多项集方法的类别

| 方法的类别 | 描述 |
| --- | --- |
| 确定大小 | 使用Python的`len`函数来获取当前多项集里的元素数量。 |
| 检测元素成员资格 | 使用Python的`in`运算符在多项集里搜索给定的目标元素。如果找到了这个元素，那么就返回`True`，不然返回`False`。 |
| 遍历多项集 | 使用Python的`for`循环访问多项集里的每一个元素。元素的访问顺序取决于多项集的类型。 |
| 获取多项集的字符串表达 | 使用Python的`str`函数来获取多项集的字符串表达形式。 |
| 相等检测 | 使用Python的`==`运算符来确定两个多项集是否相等。如果两个多项集具有相同的类型并且包含了相同的元素，那么它们就是相等的。比较这些元素对的顺序取决于多项集的类型。 |
| 连接两个多项集 | 使用Python的`+`运算符来得到一个和操作数相同类型的新的多项集，并且包含两个操作数里的所有元素。 |
| 转换为其它类型的多项集 | 创建一个与源多项集具有相同元素的新多项集。克隆操作是类型转换的一种特殊情况，因为输入输出的两个多项集具有相同的类型。 |
| 插入一个元素 | 如果可以的话，在给定的位置，将对应的元素添加到多项集里去。 |
| 删除一个元素 | 如果可以的话，在给定的位置，从多项集里删除对应的元素。 |
| 替换一个元素 | 将删除和插入合并为一项操作。 |
| 访问或者获取元素 | 如果可以的话，在给定的位置，获取元素。 |

### 所有多项集类型都有的基本操作

需要注意的是这些操作里，有几个操作和标准的Python运算符、函数或者是控制语句是相关联的，比如说：`in`、`+`、`len`、`str以及for`循环。你已经通过对Python的字符串和列表的使用，熟悉了这些运算符、函数以及控制语句。

Python里，不同多项集类型的插入、删除、替换或者是访问操作都没有统一的名称，但是会有一些标准变体。比如说，方法`pop`会被用来从Python列表里移除指定位置的元素，或者是从Python的字典里移除掉给定键所对应的值。方法`remove`会被用来从Python的多项集或是Python的列表里删除指定的元素。对于我们接下来会开发出的、Python还不支持的新多项集类型，我们应当尽可能地使用标准的运算符、函数以及方法名称来对它们进行操作。

### 类型转换

一种你可能不太熟悉的多项集操作是类型转换。通过对输入的数字进行使用，你已经知道什么是类型转换。在那个例子里，你可以通过将`int`或`float`函数应用于输入的字符串，从而把数字字符串从文字转换为`int`或`float`类型。（有关这部分的详细内容，可以参见第1章：“Python的基础编程”。）

你也可以通过类似的方式将一种类型的多项集转换为另一种类型的多项集。比如说，你可以把Python的字符串转换为Python的列表，然后再把这个Python的列表转换为Python的元组，就像下面这段交互操作里那样：

![Code 2-1](../Resources/Chapter2/Code%202-1.png)

`list`或是`tuple`函数的参数并不必须是另一个多项集，它也可以是任何的**可迭代对象**（**iterable object**）。一个可迭代的对象是指：能够让程序员通过使用Python的`for`循环来访问的一系列元素。（是的，这个描述听起来像是一个多项集。这是因为所有的多项集也都是可迭代的对象！）比如说，你可以从一个范围里创建出一个列表，就像下面这样：

![Code 2-2](../Resources/Chapter2/Code%202-2.png)

对于其它的一些函数，像是转换为字典的`dict`函数，则会需要更特殊的可迭代对象来作为参数，比如说一个包含（键，值）元组的列表。

通常来说，如果省略了类型转换的参数，那么多项集的类型转换函数将会返回一个这个类型的新的空的多项集。

### 克隆和相等性

我们提到过类型转换的一种特殊情况是克隆，它的功能是返回一个转换函数的参数的完整副本。在这种情况下，参数的类型和转换函数是相同的。比如说，下面这个代码片段将会复制一个列表，然后使用`is`和`==`运算符来对这两个列表进行比较。由于两个列表不是同一个对象，因此`is`会返回`False`。然而，虽然这两个列表是不同的对象，但是因为它们是相同的类型并且有相同的结构（每对元素在两个列表里的每个位置都相同），所以`==`返回的是`True`。

![Code 2-3](../Resources/Chapter2/Code%202-3.png)

这个例子里的两个列表不仅有相同的结构，而且它们是共享着相同的元素。也就是说，`list`函数对它的参数列表进行的是**浅拷贝**（**Shallow Copy**）。这些元素的本身在添加到新列表之前是不会被克隆的，在这个过程中只会复制对这些对象的引用。当元素是不可变的（数字、字符串或者是Python的元组）时候，这个策略不会引起问题。但是，当多项集里包含的是可变元素的时候，就可能会有副作用产生。为了防止这种情况的发生，程序员可以通过编写一个对源多项集的`for`循环来创建**深拷贝**（**deep Copy**）。在这个循环里，会把元素显式地克隆之后再添加到新的多项集里去。

后面的各个章节将会采取为大多数多项集类型都提供类型转换函数的策略。这个转换函数将会有一个可以迭代的对象作为可选参数，它会对所有被访问到的元素进行浅拷贝。你还会学习到如何通过给定多项集类型里的元素的组织方式去实现等于运算符`==`。比如说，要认为列表多项集是相等的，那么两个列表必须具有相同的长度，并且在每个位置上都有相同的元素；但是对于集合多项集来说，只需要包含完全相同的元素就行了，并不需要关心有没有特定的顺序。

## 迭代器和高阶函数

每种类型的多项集都支持一个迭代器或者说支持`for`循环，这个循环能够遍历这个多项集的所有元素。`for`循环拿到的多项集的元素的顺序取决于多项集的组织方式。比如说，列表里的元素会从头到尾按照位置进行访问；有序多项集里的元素会按从小到大的升序进行访问；而对于集合或者是字典里的元素来说不会有特定的顺序进行访问。

迭代器可以说是多项集提供的最关键也是最强大的操作。`for`循环会被用在许多的应用程序里，并且它在实现其它的一些基本的多项集操作（​​比如说：`+`、`str`以及类型转换）的时候也起着非常大的作用，同时它也会被用在一些标准的Python函数里，像是`sum`、`max`和`min`函数。很明显，`sum`、`max`和`min`函数分别会返回数字列表的总和、最大值和最小值。由于这些函数在它的实现里使用了`for`循环，因此它们可以自动地和任何其它提供`for`循环的多项集类型一起使用，比如说集合、包或者是树。

`for`循环或者说迭代器还支持使用高阶函数：`map`、`filter`和`reduce`（在第1章里有介绍）。每一个这样的告诫函数都会期望有另一个函数和一个多项集来作为参数。同样的，因为所有的多项集都支持`for`循环，因此`map`、`filter`和`reduce`函数可以与任何类型的多项集一起使用，而不仅仅只支持列表类型。

## 多项集的实现

很显然，使用多项集来编写程序的程序员对这些多项集的看法和负责实现它们的程序员的看法是截然不同的。

使用多项集的程序员需要知道如何实例化和使用每一种多项集。从他们的角度来看，多项集是一种以某种预定的行为来进行存储和访问数据元素的方式，而并不会去关心多项集实现的细节。换句话说，从用户的角度来看，多项集是一种抽象。因此，在计算机科学中，多项集也被称为**抽象数据类型**（**Abstract Data Types**，**ADT**）。抽象数据类型的用户只会去关注学习它的接口以及这个类型对象所提供的一组操作。

另一方面来看，多项集的开发人员则会为了能够向多项集的用户提供最佳性能，而去关心应该如何以最有效的方式来实现多项集的各项行为。通常来说，会有许多不同的实现方式。但是，许多实现方式会占据大量的空间或是运行过程非常缓慢，因此可以将它们视作毫无意义的实现方式。剩下的那些实现方式则往往会基于几种基本方法来进行组织以及对计算机内存进行访问。第3章“搜索、排序和复杂度分析”以及第4章“数组和链接结构”详细探讨了这些方法。

某些编程语言（如Python）仅仅为每种可用的多项集类型提供了一种实现。其它的编程语言（如Java）则会提供几种不同的实现。比如，Java的`java.util`包里就包含了列表的两个不同的实现，它们分别被称为`ArrayList`和`LinkedList`；除此之外，集合和映射（有点像Python的字典）也有两个不同的实现，分别叫做`HashSet`和`TreeSet`以及`HashMap`和`TreeMap`。Java程序员会通过相同的接口（一组操作）来使用不同的实现，但是会根据这些实现的性能特征以及一些其它的标准来自由选择应该使用哪一种实现。

这本书的目的是为Python程序员提供像Java程序员那样的选择权，并且会介绍这两种语言都无法使用的抽象多项集类型和它的实现。
对于多项集的每一种类别（线性、分层、图、无序、有序）来说，你将会看到一种或多种抽象多项集类型以及每种类型的一种或多种方式的实现。

抽象概念并不只是针对多项集进行讨论时才会用到。不论在计算机科学还是其它学科，它都是一项重要的原则。比如说，当研究重力对坠落物体的影响时，你可能会去尝试创建一种实验情况，在这种情况下，你可以忽略掉那些不重要的细节，比如：物体的颜色和味道（假设是掉在牛顿头上的那只苹果的话）。在学习数学的时候也是这样，你不必去考虑计算鱼钩或者箭头应该使用什么公式得到什么值，而应该会去尝试发现那些抽象并且一直有效的代数原理。房屋的平面图是实体房屋的抽象概念，它可以让你专注在结构元素里，而不会被其它不重要的细节（比如厨柜的颜色）所分心，虽然这些细节对于已经建成的房屋的整体外观来说是非常重要的，但对于房屋的各个主要部分之间的关系来说却并不重要。

在计算机科学中，抽象被用来忽略或隐藏当前不重要的那些细节。软件系统通常是逐层构建的，上一层会把它基于并且使用的下一层视为抽象或者是“理想类型”。如果没有抽象的话，那么在构建软件系统的时候就需要同时考虑系统的所有方面，而这通常来说是不可能完成的任务。当然，在最后你还是需要去考虑细节，但是这个时候你已经可以在一个比较小并且方便管理的环境下去考虑这些细节了。

在Python里，函数和方法是最小的抽象单元，类的大小次之，模块是最大的抽象单元。这本书里将会把抽象多项集类型的实现当作模块里的类或者是一组相关的类来进行描述。构建这些类的通用技术就是面向对象编程，这部分内容会在第5章“接口、实现和多态”以及第6章“继承与抽象类”里进行介绍。同时在第6章里会给出在这本书里所涵盖的多项集类的完整列表。

## 章节总结

* 多项集是包含零个或多个其它对象的对象。多项集可以进行这些操作：获取它的对象、插入对象、删除对象、确定多项集的大小以及遍历或访问这个多项集的对象。

* 多项集的五个主要类别是：线性、分层、图、无序和有序。

* 线性多项集会按照位置对元素进行排序，其中每个元素除了第一个，都有且只有一个前序，每个元素除了最后一个，都有且只有一个后序。

* 在分层多项集里，除了一个元素，它的所有元素都有且自会有一个前序以及零个或多个后序。被称为根的那个额外的元素没有前序。

* 图里的元素可以有零个或多个前序以及零个或多个后续。

* 无序多项集里的元素没有特定的顺序。

* 多项集是可迭代的——也就是说，可以使用`for`循环来访问多项集里所包含的所有元素。程序员们也可以使用高阶函数`map`、`filter`和`reduce`来简化多项集的数据处理。

* 抽象数据类型是一组对象和对这些对象的操作。因此，多项集是抽象数据类型。

* 数据结构是一个用来代表多项集里包含的数据的对象。

## 复习题

1. 线性多项集的一个例子是：

    a) 集合和树

    b) 列表和堆栈

2. 无序多项集的一个例子是：

    a) 队列和列表

    b) 集合和字典

3. 分层多项集可以用来表示：

    a) 银行排队的客户

    b) 文件目录系统

4. 图多项集最能代表：

    a) 一组数字

    b) 城市之间的航线图

5. 在Python里，两个多项集的类型转换操作：

    a) 在源多项集里创建对象的副本，并且把这些新对象添加到目标多项集的新实例里

    b) 将会把源多项集对象的引用添加到目标多项集的新实例里

6. 两个列表的`==`操作必须：

    a) 比较每个位置的元素对是否相等

    b) 只会验证一个列表里的每一个元素是否也在另一个列表里

7. 两个集合的`==`操作必须：

    a) 比较每个位置的元素对是否相等

    b) 验证集合的大小相同，并且一个集合里的每一个元素也在另一个集合里

8. 对列表进行`for`循环会怎样访问它的元素：

    a) 从头到尾的所有位置

    b) 不会按照特别的顺序

9. `map`函数会创建一个什么样的序列：

    a) 给定的多项集里通过布尔测试的元素

    b) 对给定多项集里的元素执行函数的结果

10. `filter`函数会创建一个什么样的序列：

    a) 给定的多项集里通过布尔测试的元素

    b) 对给定多项集里的元素执行函数的结果

## 编程项目

1. 在Shell窗口的提示符下通过使用`dir`和`help`函数，来探索Python的内置多项集类型`str`、`list`、`tuple`、`set`以及`dict`的接口。使用它们的语法是`dir(<type name>)`和`help(<type name>)`。

2. 请在[*https://docs.oracle.com/javase/8/docs/api/*](https://docs.oracle.com/javase/8/docs/api/)查看`java.util`包里所提供的Java多项集类型，并和Python的多项集类型进行比较。

    > 译者注：原文里的网址是以http为开头的，随着2015年HTTP/2标准的推出，以及大多数常用浏览器都已经支持这个标准。应该使用https这一更安全的协议。
