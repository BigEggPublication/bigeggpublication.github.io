# 链式结构和迭代器

目标

* 了解Python的内存模型以及名称和引用的概念。

* 分析列表的不同设计方案，评估每个设计方案在什么情况下是最合适的，并且对每个实现的方法的效率进行分析。

* 学习如何在Python里编写链式结构。

* 了解迭代器设计模式，并且学习如何在Python里为容器类编写迭代器。

## 概要

在你刚开始学习Python的时候，你可能并不会仔细地去理解和关心Python解释器在内部是如何存储变量以及它的值的。
对于很多简单程序来说，你只需要知道变量是用来存储值的就行了。
但是，当你编写比较大的程序并开始使用更高级的功能的时候，准确地理解Python解释器在你为一个变量名赋予一个值（一个对象）的时候所执行的操作就非常重要了。
了解这些细节，将会帮助你避免某些类型的错误，能够让你更好地了解代码的效率，并且为实现数据结构的新方法而打开大门。
而且，它还能够让你更容易的学习支持类似的内存模型的其他编程语言，从而在你学习具有不同内存模型的语言时理解它所做的权衡和决策。

在我们介绍了Python内存模型的相关细节之后，我们将会使用所学到的知识，来以一种全新的方式去实现列表——也就是使用所谓的*链式*结构。
链式结构的实现能够使得某些操作更为有效，而其他的某些操作的效率将会低于内置的Python列表。
了解这些利弊权衡，将能够允许你根据应用程序所需要的操作来选择最恰当的技术来实现。
在这个学习过程中，我们还会去讨论迭代器模式。
这是一种技术，它可以被用来允许客户端程序访问集合里的元素，但是并不需要对集合的实现方式做任何假设。

如果你已经了解过了Python的引用和Python的内存模型，那么你可能会想要跳过下一节。
但是，我们仍然建议你仔细阅读这章的内容，因为这里的概念对于理解后面将会讨论的许多主题都至关重要。
因此，除非你已经是Python的专家了，我们想，你还是能够在本材料中学到一些新的东西的。

## Python的内存模型

在传统的编程语言中，变量通常会被认为是被命名的内存位置。
如果把这个想法应用于Python的话，你可能就会认为Python里的变量是一个——某种小型的——与计算机内存中可以存储对象的位置相对应的东西。
这种思维方式对于简单的程序来说非常有效，但对于Python实际管理事物的方式来说，这并不是一个非常准确的表述。
因此，为了避免和其他语言相混淆，一些人更喜欢在Python里用*名称*（*name*）来代表，而不是使用传统的术语——*变量*（*variables*）。

在Python里的名称，始终指的是：
存储在内存中的某个对象。
当把Python的名称分配给一个对象时，Python解释器将会在内部使用字典将这个名称，映射到存储对象的实际内存位置。
这个维护从名称到对象的映射的字典称为*命名空间*。
如果在之后，把这个名称分配给另一个对象，命名空间字典就会被修改，从而能够将这个名称映射到新的内存位置。
我们将通过一个交互式的案例来演示“幕后发生的事情”。
我知道，这个细节有些单调无聊，但当你能够完全理解这些知识之后，你将会更容易地理解后面将会讨论的许多主题。

让我们从几个简单的赋值语句开始。

```Python
>>> d = 'Dave'
>>> j = d
```

执行语句`d ='Dave'`时，Python会分配一个包含`Dave`的字符串对象。
赋值语句`j = d`则会使名称`j`引用到与名称`d`相同的对象。
它不会去创建新的字符串对象。

一个很好的类比是：赋值可以被视为将一个带有其名称的便签放在对象上。
这个时候，数据对象`Dave`上会有两个粘着的便笺：一个名称为`d`，另一个名称为`j`。
图4.1应该有助于帮你理解正在发生的事情。
在这个的图里，我们使用箭头作为直观的方式来表示“值”。
而计算机实际存储的数字是我们的箭头所指向的地址。

图4.1：分配给一个对象的两个变量

当然，Python解释器并不是用的便笺纸，而是使用命名空间字典，在内部跟踪这些关联。
我们其实可以用名为本地（`locals()`）的内置函数来访问这个命名空间字典。

```Python
>>> print locals()
{'__builtins__': <module '__builtin__' (built-in)>, '__name__': '__main__',
'j': 'Dave', '__doc__': None, 'd': 'Dave'}
```

在这个例子里，你可以看到本地字典包含着一些你可能认识的Python的特殊名称：
`__builtins__`、`__name__`以及`__doc__`。
在这里，我们并不需要去关心这些特殊名称。
然而，应该注意的是，我们的赋值语句将两个名称`d`和`j`添加到了字典里。
可以看出，在输出这个字典的时候，Python会把名称显示为键，并将实际数据对象的存储形式显示为值。
请记住，命名空间字典实际上存储的是对象的内存地址（也称为对象的引用）。
但是，由于我们通常关心的都是数据，而不是它的内存地址，因此Python解释器会自动向我们显示存储在这个内存地址中的内容，而不是这个地址本身。

当然，如果你好奇的话，我们还是会想要知道一个对象的实际地址。
我们是可以做到这一点的，Python里的`id`函数将会返回每个对象的唯一标识符。
而在大多数的Python版本里，`id`函数会返回存储对象的内存地址。

```Python
>>> print id(d), id(j)
432128 432128
```

就像你可以通过`id`函数的输出所看到的那样。
在赋值语句`j = d`之后，名称`j`和`d`都引用着相同的数据对象。
在内部，Python解释器会持续地跟踪，现在有两个引用指向了“`Dave`”字符串对象。
这通常被称为对象的*引用计数*（*reference count*）。

让我们做更多的命令，来继续这个例子。

```Python
>>> j = 'John'
>>> print id(d), id(j)
432128 432256
>>> d = 'Smith'
>>> print id(d), id(j)
432224 432256
```

当我们执行`j = 'John'`的时候，就会创建一个包含“`John`”的新字符串对象。
还是用我们的便笺纸来作为类比，相当于我们把便笺`j`移动到了另一个包含字符串“`John`”的新创建的数据对象。
你可以看到，语句`j = 'John'`之后的`id`函数的输出显示，名称`d`仍然引用之前相同的对象，但名称`j`现在引用了另一个不同的内存位置的对象。
在这个时候，两个字符串对象中每个字符串对象的引用计数将会是1。

之后的语句`d = 'Smith'`将会让名称`d`引用包含“`Smith`”的新字符串对象。
要请注意看的是，字符串对象“`Smith`”的地址和字符串对象“`Dave`”并不相同。
同样，当名称被分配给不同的对象的时候，名称所映射到的地址也会更改。
这是一个需要注意的重点：
*赋值会改变变量引用的对象，但是它对对象本身没有任何影响*。
在这种情况下，字符串“`Dave`”并不会被修改为字符串“`Smith`”，而是会去创建一个包含“`Smith`”的新字符串对象。

在这个时候，由于没有任何名称在引用字符串“`Dave`”，因此它的引用计数现在是零。
因为不再有办法去访问包含“`Dave`”的字符串对象，Python解释器会自动地去释放这个地方的内存。
通过释放无法再被访问的对象（当它们的引用计数变为零时），Python解释器就能够在以后为新对象重新使用相同的内存位置。
此个过程被称为*垃圾回收*（*garbage collection*）。
垃圾收集会增加Python解释器的开销，从而会减慢执行速度。
但是它所能提供的好处是：它减轻了程序员去担心内存分配和释放的相关负担，这个过程在没有自动内存管理的语言中会非常的糟糕且容易出错。

当然，程序员也可以显式删除给定名称的映射。

```Python
>>> del d
>>> print locals()
{'__builtins__': <module '__builtin__' (built-in)>, '__name__': '__main__',
'j': 'John', '__doc__': None}
```

语句`del d`将会从命名空间字典里删除名称`d`，因此你就再也不能访问它了。
如果你现在去尝试执行语句`print d`的话，就好像我们从没有把对象分配给`d`一样，会导致抛出`NameError`异常。
删除这个名称会把字符串“`Smith`”的引用计数从1减少到0，因此，现在它也会被垃圾回收。

Python的这个内存模型有很多好处。
因为变量只会包含对象的引用，所以所有变量的大小都相同（计算机的标准地址大小，通常为4或8个字节）。
而且，数据类型信息会和对象一起存储，这一技术的术语叫做*动态类型*（*dynamic typing*）。
这也就意味着同一个名称可以在程序执行的时候去引用不同的类型，而且名称能够被重新分配。
这也就使得诸如像：
列表、元组和字典这类的容器非常容易的实现对异质（包含多种类型）的支持，因为它们也只是去维护它所包含对象的（地址）的引用。

Python的这个内存模型也使得赋值操作非常高效。
Python里的赋值表达式将会始终被用来操作对某个对象的引用。
将结果分配给名称只需要把名称这个四字节或八字节的引用添加到命名空间字典（如果它还不存在的话）就行了。
在像`j = d`这样的简单赋值中，它的效果就是将`d`的引用复制到`j`的命名空间条目而已。

现在我们可以很清晰的知道，Python的内存模型能够使得多个名称引用完全相同的对象，而且这个操作（通常来说）非常的简单易行。
这称为*别名*（*aliasing*），这个别名可能会导致一些有趣的情况。
比如：当多个名称引用同一对象的时候，通过其中一个名称对对象的修改将会修改所有名称引用的数据。
在这个时候，通过访问其他名称，也可以看到使用这个名称对数据的更改。
这里有一个使用列表来做的简单说明。

```Python
>>> lst1 = [1, 2, 3]
>>> lst2 = lst1
>>> lst2.append(4)
>>> lst1
[1, 2, 3, 4]
```

由于`lst1`和`lst2`引用了同一个对象，因此向`lst2`追加`4`也会影响到`lst1`。
除非你理解了这里潜在的语义，否则`lst1`就好像是“神奇地”被改变了一样，因为从交互式操作的第一行和最后一行之间，我们并没有对`lst1`进行任何修改。
当然，只有共享的对象是可以被改变（非贫血类型）的时候，这些会令人惊讶的混叠结果才会出现。
字符串（`string`）、整数（`int`）和浮点数（`float`）这类的变量根本无法改变，所以对于这些类型，用别名不会产生问题。

当我们想要避免使用别名时所产生的副作用，就需要获得一个对象的独立副本，从而能够对这个副本的更改时不会影响到其他的副本。
当然，诸如列表之类的复杂对象，它本身可能也会包含对其他对象的引用，因此我们必须要斟酌，如何在复制过程中处理这些引用。
有两种不同类型的复制，它们分别被称为*浅拷贝*（*shallow copies*）和*深拷贝*（*deep copies*）。
浅拷贝的副本会有自己单独的引用，但这个引用所引用的对象是和原始对象相同的对象。
深拷贝的副本则会是一个完全独立的副本，它可以被用来创建一个新的对象引用，并且创建每一级的所有的新的数据对象。
Python的复制（`copy`）模块包含能够被用来复制任意Python对象的非常有用的函数。
下面是一个使用列表来进行演示的交互式操作示例。

```Python
>>> import copy
>>> b = [1, 2, [3, 4], 6]
>>> c = b
>>> d = copy.copy(b) # creates a shallow copy
>>> e = copy.deepcopy(b) # creates a deep copy
>>> print b is c, b == c
True True
>>> print b is d, b == d
False True
>>> print b is e, b == e
False True
```

在这段代码里，`c`和`b`是同一个引用，`d`是浅拷贝，`e`则是深拷贝。
顺便说一下，有很多方法都能够可以获得Python列表的浅拷贝副本。
比如，我们也可以使用切片（`d = b[:]`）或者列表的构造函数（`d = list(b)`）来创建浅拷贝副本。

那么，这段代码的输出都代表着什么呢？
Python的“是（`is`）”运算符会检测左右两个表达式是否引用的是完全相同的一个对象，而Python的“比较（`==`）”运算符则会检测两个表达式是否有相同的数据。
这就是说：
`a is b`可以得出`a == b`，但是，反之并不成立。
在这段示例里，你可以看出，赋值并不会创建新的对象，因为在初始赋值后`b is c`。
但是，通过切片来创建的浅拷贝`d`以及深拷贝得到的`e`都是包含与`b`相等数据的不同的新对象。
虽然这些副本都包含着相同的数据，但它们的内部结构并不相同。
如图4.2所示，浅拷贝只会包含列表最顶层引用的副本，而深拷贝则会包含所有级别里的可变部分的结构的副本。
要注意的是，深拷贝并不需要去复制不可变的数据项，因为就像之前提到过的一样，不可变对象的别名并不会引起任何特殊的问题。

图4.2：浅拷贝和深拷贝的图形表示

由于在浅拷贝中还残留有数据共享，我们仍然会得到混叠副作用。
可以考虑下，当我们开始修改其中一些列表时会发生什么。

```Python
>>> b[0] = 0
>>> b.append(7)
>>> c[2].append(5)
>>> print b
[0, 2, [3, 4, 5], 6, 7]
>>> print c
[0, 2, [3, 4, 5], 6, 7]
>>> print d
[1, 2, [3, 4, 5], 6]
>>> print e
[1, 2, [3, 4], 6]
```

根据图4.2，你应该能够理解这里的输出结果是怎么产生的了。
修改`b`引用的列表的顶级结构会导致对象`c`的改变，这是因为它引用了同一个对象。
而这个对顶级结构的更改对`d`或`e`则没有影响，因为它们引用了一个从`b`拷贝出的独立的副本这一单独对象。

然而，当我们通过修改`c`的子列表`[3, 4]`的时候，事情就有趣起来了。
很明显，`b`也会得到这些变化（因为`b`和`c`是同一个对象）。
但是，现在`d`也看到了这些变化，这是因为这个子列表仍然是浅拷贝里的共享子结构。
与此同时，深拷贝`e`并没有看到任何和这些相关的修改，这是由于所有可变结构都已经在每个级别上被复制，因此`b`所引用的对象的修改并不会影响到它。
图4.3显示了在这个例子结束时的内存的样子。

图4.3：浅拷贝和深拷贝示例结束时的内存表示

在最后，我们在这一节内容中所使用的完整的、基于引用的图表会占用大量空间，以至于有些时候变得非常难以解释。
而由于引用和值之间的区别在不可变对象的情况下并不重要。
为了能够使这个图表尽可能的简单，当它们被包含在另一个对象里的时候，我们通常不会将不可变对象作为单独的数据对象进行绘制。
图4.4以更紧凑的方式绘制了这个例子在结束时候的内存的样子，显示了与图4.3相同的情况。

图4.4：浅拷贝和深拷贝示例末尾的简化内存表示

### 传递参数

虽然很多程序员有时会对Python的参数传递机制感到非常的困惑不解，但是一旦你理解了Python的内存模型，Python里的参数传递机制就非常简单了。
计算机科学家们使用术语*形式参数*（形参，*formal parameters*）来指代调用函数时所提供的参数的名称，使用*实际参数*（实参，*actual parameters*）来引用函数定义中所给出的参数的名称。
有一个可以简单记住这一点的方法是：
实参是在实际调用函数的地方。
在下面这个示例中，`b`、`c`和`d`都是实参，而`e`、`f`和`g`则是形参。

```Python
# parameters.py
def func(e, f, g):
    e += 2
    f.append(4)
    g = [8, 9]
    print e, f, g

def main():
    b = 0
    c = [1, 2, 3]
    d = [5, 6, 7]
    func(b, c, d)
    print b, c, d

main()
```

这个例子的输出是

```Python
2 [1, 2, 3, 4] [8, 9]
0 [1, 2, 3, 4] [5, 6, 7]
```

要理解Python里是如何传递参数的，一个简单方法是：
在调用函数的时候将形参分配给实参。
我们自己并不能这样做，这是因为名称`e`、`f`和`g`只能在`func`函数里被访问，而名称`b`、`c`和`d`只能在`main`函数中被访问。
而当`main`函数调用`func`函数的时候，Python解释器会为我们在幕后处理相应的赋值。
结果就是，当函数开始执行的时候，`e`会指向和`b`相同的对象，`f`会指向和`c`相同的对象，并且`g`会指向和`d`相同的对象。
语句`e += 2`会导致名称`e`引用一个新的对象，而`b`则仍然会引用那个值为零的对象。
由于`f`和`c`引用相同的对象，所以当我们将`4`添加到这个对象的结尾的时候，我们会在输出`c`时看到相同的结果。
在之后，我们将名称`g`分配给了新的对象，因此`g`和`d`现在会引用不同的对象，因此`d`的输出的值会保持不变。

从这里，我们可以看出，有一个非常重要的是：
要注意函数是可以改变实参所引用的对象状态的，然而，*函数并不能修改实参所引用的对象*。
因此，我们可以通过传递可变对象给函数，并让这个函数对相应的形参进行修改，进而把信息传递给调用者。
但请记住这一点，在函数或方法内，将新对象分配给形参将*永远不会*以任何方式更改实参，无论实参是否可变。

## 链表实现

在了解了Python名称和引用之后，我们可以开始去了解另一种实现顺序集合的方法。
我们在上一章里已经知道了，Python内部实现的列表是通过数组来实现的。
数组实现有一个缺点，就是：
插入和删除元素的效率问题。
由于数组是作为一个连续的内存块来维护的，因此插入的新元素如果需要位于数组的中间，那么就需要将原始内存里的值都向后移动，从而为新元素腾出空间。
同样的，执行删除操作也会以类似的方法，产生一样的情况。
因此，这个问题的最基本原因是，由于序列的顺序是通过在内存中所使用的有序的内存地址序列来维持的。

但这不是维护一个序列数据的唯一可行的方法。
除了通过用它在内存中的位置来隐式地维护元素的序列信息，我们也可以显式地表示顺序。
换句话说，我们可以将序列中的元素分散到内存中的任何位置，并且让每一个元素都去“记住”序列中的下一个元素所在的位置。
这个方法会导致*链式*（*linked*）序列的产生。
举一个具体的例子，假设我们有一个序列的数字，这个序列被称为`myNums`。
图4.5显示了序列的连续和链式实现。

图4.5：左侧的连续数组和右侧的链式版本的数组

可以看到，序列的链式版本并没有使用单个连续的内存部分。
恰恰相反，我们创建了许多的对象（通常称为*节点*（`node`）），每个对象都包含了对数据值的引用以及指向列表中下一个元素的指针/引用。
通过这种显式的引用，每一个节点都可以被存储在内存中的任何位置。

基于`myNums`的链式实现，我们可以执行那些基于数组的版本相同的所有操作。
比如，要输出序列里的所有元素，我们可以使用下面这个算法：

```Python
current_node = myNums
while <current_node is not at the end of the sequence>:
    print current_node’s data
    current_node = current_node’s link to the next node
```

要实现这个算法，需要知道节点的具体存储方式，这个存储方式应该包括获取节点中的两部分信息（数据和指向下一元素的链接）的方法，以及某种能够知道是否已经到达序列的末尾的方式。
我们可以通过多种方式来做到这一点。
而可行的最直接的方式就是，创建一个简单的链表节点（`ListNode`）类来完成这项工作。

```Python
# ListNode.py
class ListNode(object):

    def __init__(self, item = None, link = None):
        """creates a ListNode with the specified data value and link
        post: creates a ListNode with the specified data value and link"""

        self.item = item
        self.link = link
```

链表节点（`ListNode`）对象具有两个变量：
`item`——用来存储和节点相关联的数据的实例变量；
以及`link`——用来存储序列中的下一个元素的实例变量。
由于Python支持动态类型，所以`item`实例变量可以是对任何数据类型的引用。
因此，就像你可以在内置Python列表中存储任何数据类型或混合数据类型一样，我们的链式实现也可以完成相应的功能。
这个时候，我们还剩下了这样一个问题——如何处理`link`字段来以表明我们已经到了序列的末尾。
在Python里的特殊对象`None`，通常会被用来处理这个问题。

现在，让我们用一用链表节点（`ListNode`）类。
下面的代码里，我们创建了包含三个元素的链式序列。

```Python
n3 = ListNode(3)
n2 = ListNode(2, n3)
n1 = ListNode(1, n2)
```

如果我们追踪这段代码的执行结果，就能够得到图4.6中所描述的情况。
在这个图里，每个双框图案都代表着一个链表节点（`ListNode`）对象，这个对象会有相应的数据元素和一个指向下一个链表节点（`ListNode`）对象的链接。
需要注意的一点是，为了简化这个图例，我们在链表节点（`ListNode`）的第一个框内直接显示了数字（不可变），而不是从链表节点（`ListNode`）的`item`部分（第一个框）绘制一个向数字对象的引用。
`n2`和`n1.link`都是对包含数据值`2`的同一个链表节点（`ListNode`）对象的引用，同样的，`n3`和`n2.link`都是对包含数据值`3`的同一对象的引用。
当然，我们还可以通过`n1.link.link`来访问包含数据值`3`的链表节点（`ListNode`）对象，以及通过`n1.link.link.item`来得到相应的数据值。
一般来说，我们不会用这样的方式去编写代码，但它展示了如何在链式结构里，通过开头的元素怎样能够找到它之后的每一个对象和数据值的。
通常而言，我们只会去存储对第一个链表节点（`ListNode`）对象的引用，然后通过第一个元素里的链接来访问列表中的其他元素。

图4.6：链接在一起的三个链表节点（`ListNode`）

假设我们要将值2.5插入到这个序列里，同时还要保持整个序列有序。
下面的代码就能够完成这项操作：

```Python
n25 = ListNode(2.5, n2.link)
n2.link = n25
```

图4.7以图示方式显示了这段代码的执行过程：
语句`n25 = ListNode(2.5，n2.link)`分配了一个新的链表节点（`ListNode`）并调用它的`__init__`方法。
`__init__`的第一行——`self.item = item`在这个链表节点（`ListNode`）里设置了对`2.5`的引用。
下一行的`self.link = link`则存储的这个链式参数的引用，这个参数是链表节点（`ListNode`）`n3`对象。
在`__init__`方法执行完以后，语句`n2.link = n25`设置了链表节点（`ListNode`）`n2`对象的`link`实例变量，因此它之后会引用这个新创建的叫做`n25`的链表节点（`ListNode`）对象。
在整个过程中，我们并没有对链表节点（`ListNode`）`n1`对象里的任何引用进行更改。
可以看到，在链式结构中插入一个节点，只需要对需要插入节点之前的那个节点的链接进行更新就可以了。
所以，由于插入新数据到链式结构里并不需要移动任何的现有数据，因此可以非常高效地完成这个操作。

> 1. 在`__init__`方法里的`self.item = item`语句被执行之后
>
> 2. 在`__init__`方法里的`self.link = link`语句被执行之后
>
> 3. 在`n2.link = n25`语句被执行之后

图4.7：在链式结构中插入一个节点

在这段代码里，需要注意的一点是，我们更新链接的顺序非常重要。
如果我们把这一段代码改成下面这样来插入`2.5`，它将会不能正常完成操作。

```Python
# Incorrect version. It won’t work!
n25 = ListNode(2.5)
n2.link = n25
n25.link = n2.link
```

在这种情况下，语句`n2.link = n25`会导致对包含`3`的链表节点（`ListNode`）的引用被覆盖。
这个链表节点（`ListNode`）的引用计数将会减少`1`，而这个时候如果没有其他的引用，这个链表节点（`ListNode`）将会被释放。
这之后，语句`n25.link = n2.link`会把链表节点（`ListNode`）`n25`里的`link`实例变量设置为链表节点（`ListNode`）`n25`。
这样的操作破坏了我们链式结构中的连接——因为它不再包含数据值为`3`的链表节点（`ListNode`）。
不仅如此，它还会在我们的链式结构里产生一个循环。
在这个时候，如果我们编写一个从链表节点（`ListNode`）`n1`开始，并依照`link`实例变量来一个一个往下走的循环，这个循环会在遇到值为`None`的链接的时候退出。
这个循环将会是一个无限循环。
因为链表节点（`ListNode`）`2.5`的链接（`link`）指向的是链表节点（`ListNode`）`2.5`它自己。
我们的程序将会持续不断的执行下去。
这也就是为什么使用链式结构进行编程可能会变得非常麻烦，而可以确保你的操作不出差错的最好方法是：
一步一步的跟随你的代码并绘制出相应的图来描述它。

现在，让我们考虑一下要从序列中删除一个元素会发生什么。
要删除数字`2`的话，我们需要更新包含`1`的链表节点（`ListNode`）对象的链接（`link`）字段，从而能够让它“跳过”节点`2`。
代码`n1.link = n25`就能够完成这项操作。
而这就是全部所需要的代码了。
所以，从序列中删除一个元素会比插入一个元素更容易。
而且，如果没有其他对已删除节点的引用，通常会自动释放这个节点所占用的内存。

## 链表抽象数据类型的实现

希望你现在对链式结构是如何用被用来表示一个序列有了深刻的感悟。
从纯粹的概念上来说，这个技术会相对的比较简单，但我们必须要非常小心地使用链式操作，才能让元素不会丢失或者损坏序列的结构。
这是一个表明抽象数据类型理念的完美场合。
这是因为，我们可以封装链式结构的所有细节，让客户端通过插入和删除元素这样的一些高级操作来修改这个数据结构。
在这一节里，我们将会通过借用Python列表的API中的一个子集来展示：如何使用我们的链表节点（`ListNode`）类来构建一个具有类似功能的列表。

在开始实现我们的抽象数据类型列表之前，我们需要最终敲定链表节点（`ListNode`）类的一些详细信息。
你一定已经注意到了，到目前为止，在示例的代码里，我们一直是显示直接访问链表节点（`ListNode`）中的实例变量。
在2.2.3章节里，我们曾经说过，通常我们并不希望客户端去直接访问类的实例变量。
但是，对于这个链表节点（`ListNode`）类来说，这个类的唯一目的就是打包这两个值。
因此链表节点（`ListNode`）类实际上不是一个抽象数据类型，而仅仅是一种实现技术。
如果需要，我们当然可以通过向链表节点（`ListNode`）类添加其他方法来获取和设置实例变量的值，从而构建一个真正的抽象数据类型。

```Python
    def get_item(self):
        """returns the data element stored at the node
        pre: none
        post: returns the data element stored at the node"""

        return self.item

    def set_item(self, item):
        """sets the data element stored at the node
        pre: none
        post: sets the data element stored at the node to item"""

        self.item = item

    def get_link(self):
        """returns the next link stored at the node
        pre: none
        post: returns the next link stored at the node"""

        return self.link

    def set_link(self, link):
        """returns the next link stored at the node
        pre: none
        post: sets the next link stored at the node to link"""

        self.link = link
```

为数据项创建这些`set`和`get`方法会使得这个类非常的长。
但是，我们只会用链表节点（`ListNode`）类来帮助我们实现列表抽象数据类型的链式实现。
也就是说，我们将会创建一个利用链表节点（`ListNode`）类的链表（`LList`）类。
而且，链表（`LList`）类将会是唯一一个使用链表节点（`ListNode`）类，因此让链表（`LList`）中的代码直接访问这两个在链表节点（`ListNode`）里的实例变量似乎会更简单一些。

一般来说，Python不会强制地实施数据保护，而是允许程序员使用他们自己的判断来决定代码是否能够直接访问实例变量。
数据隐藏的主要原因是：
避免和防止类的客户端能够通过直接将实例变量设置成为不正确的值而破坏数据结构。
对于大多数类来说，客户端都应该去调用类的方法来确保能够正确的操作实例变量。
在我们的例子里，客户端程序只会去调用链表（`LList`）的各个方法，这些链表（`LList`）的方法将会去更新相应的链表节点（`ListNode`）的实例变量。
这样一来，链表（`LList`）和链表节点（`ListNode`）一起为我们提供了列表抽象数据类型的实现。
而且，即便是使用那些提供数据保护机制的语言，比如说C++或者Java等等，也可能并不值得为链表节点（`ListNode`）提供额外的`set`/`get`方法。
让链表（`LList`）类直接访问实例变量的实现将会更加简洁。

有了链表节点（`ListNode`）类，我们就可以将注意力转向应该如何实现链表（`LList`）类了。
这个类将会包含操作列表的各个方法。
我们的链表（`LList`）类会将数据维护成一个由链表节点（`ListNode`）组成的链式序列。
链表（`LList`）对象需要有一个能够指向这个序列中第一个节点的实例变量。
通常，这个变量会被叫做`head`（头）。
再维护一个跟踪列表中元素数量的实例变量也会让我们更加方便。
因为有了这个变量，我们就能够一直都知道当前列表的长度，而不必去遍历整个列表来计算节点数量了。

用类的不变量来总结链表（`LList`）的各个部分之间的关系是非常有效的。
*类的不变量*（*class invariant*）是一个属性或一套属性集，它（们）定义了类实例的常量状态。
类的不变量只能通过类的方法来进行维护。
实际上，它是每个方法的一组隐含的先验条件与后置条件。
当我们在方法中更新实例变量时，不变量可能暂时会不成立，但在方法结束之后它们一定是正确的。
对于我们的列表类来说，我们会定义下面这些不变量：

1. `self.size`是列表中当前节点的数量

2. 如果`self.size == 0`则`self.head`为`None`；不然的话`self.head`是对列表中第一个链表节点（`ListNode`）的引用。

3. 列表中的最后一个链表节点（`ListNode`）（位置`self.size - 1`）的链接（`link`）字段应该被设置为`None`，而所有的其他链表节点（`ListNode`）的链接都会引用列表中的下一个链表节点（`ListNode`）。

构造函数（`__init__`方法）必须要初始化所有的实例变量，从而满足这些不变属性。
为了匹配Python列表的接口（API），我们将会编写这样一个`__init__`方法，它将会能够接受一个被用于初始化列表中的元素的Python序列。
由于我们还计划要在类里实现`append`方法，所以构造函数可以简单地重复使用`append`方法来完成工作。
而为了能够调用`append`方法，我们还需要由一个链表（`LList`）的实例来进行添加。
由于这个实例和我们构建的链表（`LList`）的实例相同，因此我们需要用`self`作为这个实例。
下面是相应的代码：

```Python
# LList.py
from ListNode import ListNode

class LList(object):
    def __init__(self, seq=()):
        """creates an LList
        post: Creates an LList containing items in seq"""

        self.head = None
        self.size = 0

        # if passed a sequence, place items in the list
        for x in seq:
            self.append(x)
```

可以很清楚的看到，这段代码建立了我们的类的不变量。
代码首先为空列表设置了正确的状态值（`self.head is None`以及`self.size == 0`）。
然后，在初始化序列中的每一个元素（如果有的话）都会被附加到这个列表中。
如果添加到结尾（`append`）操作也服从不变量的话，一切都应该是能够正常工作的。

在Python里编写容器类的时候，编写`__len__`方法是一个很正常的做法。
当`len`这个内置函数被应用于程序员定义的对象时，Python就会去调用这个方法，就像下面这样：

```Python
a = LList()
print len(a) # outputs 0
```

这个`__len__`方法是一个钩子函数，它可以使得我们自己的容器类能够像那些可以响应`len`函数调用的内置Python容器类一样的工作。
当然，我们也可以通过`a.__len__()`之类的代码来直接调用这个方法，但这并不是一个Python通常的使用方式。

`__len__`方法实现起来非常的简单，因为`size`实例变量（根据类的不变量）始终指示这个列表里的元素总数。

```Python
    def __len__(self):
        """post: returns number of items in the list"""

        return self.size
```

许多列表的API方法都要求我们能够访问列表中特定位置的节点。
我们将编写一个方法来访问这个指定的节点，从而能够让其他方法可以直接调用该方法来获得节点，而不是在每个方法里都编写这段代码。
为了表明这个方法只应该被其他链表（`LList`）的方法所调用，而并不是，可以被客户端代码所使用的API的一部分，我们将使用Python的习惯来为这个方法名加上一个下划线。
也就是，`_find(self，position)`方法会被用来返回指定位置上的链表节点（`ListNode`）。
它的工作方式是从`head`实例变量开始，然后根据链接依次往后移动，最终到达指定节点所需要的次数。
和Python列表一样，我们将使用从零开始的索引。

```Python
    def _find(self, position):
        """private method that returns node that is at location position
        in the list (0 is first item, size-1 is last item)
        pre: 0 <= position < self.size
        post: returns the ListNode at the specified position in the
              list"""

        assert 0 <= position < self.size

        node = self.head
        # move forward until we reach the specified node
        for i in range(position):
            node = node.link
        return node
```

就像你能够在这段代码里所看见的那样，`_find`方法非常的简单。
在使用断言检查先验条件之后，使用局部变量`node`来跟踪在列表中的当前节点。
我们从列表的最前面开始（`node = self.head`），然后会循环`position`次。
每次循环都会让当前节点前进到下一个节点在列表中的位置（`node = node.link`）。
循环完成之后，`node`将会包含目标链表节点（`ListNode`）。

既然已经有了`_find`方法，那么`append`方法也就不会很长了。
根据列表当前是否包含任何元素，会有两种情况需要考虑。
在空列表的情况下，需要将`self.head`设置为新创建的这个`ListNode`对象。
而对于非空列表来说，我们需要找到最后一个链表节点（`ListNode`）——它会位于`self.size - 1`这个位置——并将这个对象的链接设置为新创建的`ListNode`对象。
在任何一种情况下，我们都需要将`size`实例变量加`1`从而能够保持不变量。
在这里，需要理解的一个关键概念是：当一个新节点（使用`append`和`insert`方法）被添加到列表中时，我们只会调用`ListNode`的构造函数。

```Python
    def append(self, x):
        """appends x onto end of the list
        post: x is appended onto the end of the list"""

        # create a new node containing x
        newNode = ListNode(x)

        # link it into the end of the list
        if self.head is not None:
            # non-empty list
            node = self._find(self.size - 1)
            node.link = newNode
        else:
            # empty list
            # set self.head to new node
            self.head = newNode
        self.size += 1
```

注意看这段代码里，当列表为空时，它是如何检测到这个特殊情况的：如果`self.head`不是`None`（`if self.head is not None`）。
检查一个变量引用的是（或不是）`None`对象是Python里常见的习语。
在编写使用链式结构的代码时，这种检测会经常出现。

还有许多其他的方法编写代码可以用来检测`None`。
在我们的这个例子里，任何实现都会有相同的结果，但它们会导致不同的方法被调用到。
一种选择是使用`is`运算符，就像我们在上面的代码实例中所做的那样。
回想一下，`is`运算符被用来检查一个对象的标识，因此当表达式`node is None`时，会检查`node`和`None`是否是同一个对象。
Python解释器可以快速地通过查看两个对象的引用（地址）是否相同来检查。
有些时候，你会看到使用比较（`==`）运算符的代码，比如说，`if node == None`。
这个判断语句将会调用节点的`__eq__`方法（如果已定义了的话）。
因为这涉及到了方法的调用，所以它的效率会稍微低一点。
它也可能在`__eq__`方法不期望`None`作为可能参数的类里出现问题。
第三种选择是简单地写`if node：`。
如果类定义了`__nonzero__`方法，这个语句就会去调用这个方法。
但是，如果没有定义`__nonzero__`方法，则会去调用`__len__`方法。
如果两个方法都没有被定义，那么类的实例将被解释为布尔值`True`。
与之相反的是，`None`对象则会被表示为布尔值`False`。
虽然这段代码优雅并且简洁，但由于需要去查找需要调用的方法，这种方法效率也比较低。
而且它可能会容易出现一些其他的细微错误，因为除了`None`之外的一些对象也可能被判断为`False`。
因此在Python里，我们建议你总是使用`is None`或者`is not None`来检查一个变量是否为`None`。

这样，我们就有了一个链表（`LList`）类，它允许我们构建一个列表并且检查它的长度。
让我们把索引添加到列表中。
我们可以通过定义`__getitem__(self，position)`以及`__setitem__(self，position，value)`方法来让我们的类能够完成这些操作。
Python里还有很多其他的钩子函数等待你的发现。
当方括号被用于访问列表中的元素时，前者会被调用，而当在赋值语句的左侧使用了方括号时会调用后者。
同样的，实现了这些方法就能够让我们的链表（`LList`）对象像内置的Python列表对象一样被使用，就像编写的下面的代码一样：

```Python
a = LList((1, 2, 3)) # call constructor with the tuple (1, 2, 3)
print a[0] # calls a.__getitem__(0)
a[0] = 4 # calls a.__setitem__(0, 4)
```

下面是这些方法的例子。
你可以注意到，因为我们已经有`_find`方法来定位适当的节点，它们的实现是多么的简单。

```Python
    def __getitem__(self, position):
        """return data item at location position
        pre: 0 <= position < size
        post: returns data item at the specified position"""

        node = self._find(position)
        return node.item

    def __setitem__(self, position, value):
        """set data item at location position to value
        pre: 0 <= position < self.size
        post: sets the data item at the specified position to value"""

        node = self._find(position)
        node.item = value
```

我们刚刚差不多完成了基本的容器操作。
我们仍然缺少一个从列表中删除元素的方法。
对于内置的Python列表，有两个常见的删除元素的方法。
一种方法是使用Python的`del`语句，比如`del a[1]`。
正如你现在猜想的那样，Python提供了另外一个钩子函数，这个函数可以被用于在我们自己的集合中实现这个行为。
这个方法就是`__delitem__(self，position)`。

从Python列表中进行删除的另一种常见的技术是调用列表的`pop`方法，这个方法会删除这个元素并且返回这个被删除的元素。
由于`pop`和`__delitem__`两个方法都从列表中删除了一个元素，因此我们可以把这个通用功能提取成一个辅助方法`_delete`，然后让这两个方法都使用它。
当我们有了`_delete`方法之后，`__delitem__`方法就会非常的简单。

```Python
    def __delitem__(self, position):
        """delete item at location position from the list
        pre: 0 <= position < self.size
        post: the item at the specified position is removed from
              the list"""

        assert 0 <= position < self.size

        self._delete(position)
```

实际上，实现`_delete(self，position)`方法可能会更加复杂。
因为，执行删除操作通常需要修改链表节点（`ListNode`）中的链接（`link`实例变量）。
这和`append`方法类似；
但不同的是，我们还需要对删除位于零位置的元素的情况进行特殊处理，因为这个操作需要修改`self.head`实例变量。
如果列表不为空的话，我们就必须要去找到并修改被删除的节点的*前序*节点。
为了维护整个序列，*前序*（*precedes*）节点的链接（`link`)字段将被设置成已删除节点的链接（`link`)字段。
最后，我们还要考虑的是，因为我们想使用`_delete`来实现`pop`方法，所以`_delete`会需要返回我们正在删除的链表节点（`ListNode`）的数据项。

```Python
    def _delete(self, position):
        # private method to delete item at location position from the list
        # pre: 0 <= position < self.size
        # post: the item at the specified position is removed from the list
        #       and the item is returned (for use with pop)

        if position == 0:
            # save item from the initial node
            item = self.head.item

            # change self.head to point "over" the deleted node
            self.head = self.head.link
        else:
            # find the node immediately before the one to delete
            prev_node = self._find(position - 1)

            # save the item from node to delete
            item = prev_node.link.item

            # change predecessor to point "over" the deleted node
            prev_node.link = prev_node.link.link

        self.size -= 1
        return item
```

你可以通过使用一些简单的例子来跟踪这些代码，从而向自己证明，这个实现是能够完成我们设想的工作的。
一个非常重要的很微妙的点是：被删除的链表节点（`ListNode`）元素的内存会发生什么。
一旦删除的节点被移除出链表，它的引用计数就会降到零（因为没有任何地方还会引用或指向它），然后Python的垃圾回收过程就会自动地释放这部分内存。
在没有垃圾回收的语言里，就必须要更加谨慎地显式地去释放已被删除的节点。

还有一件需要考虑的事情是：当我们从列表的末尾删除一个元素时会发生什么。
列表末尾的链表节点（`ListNode`）对象的链接会是`None`。
因此，这一行`prev_node.link = prev_node.link.link`代码能够有效地将前序节点的链接（`link`）字段设置为`None`。
而且，由于`None`是列表的终止符，因此前序节点现在成为了列表的最后一个元素，这正好是我们想要的。
在删除列表中的最后一个剩余元素的这个特殊情况时，通过设置`self.head = self.head.link`会使得`self.head`变为`None`，而这是空列表的正确状态（根据类的不变量）。
归纳前面所述，处理从列表的最后删除元素时并不需要添加特殊代码。
`None`对象的引用将会被恰当地复制到该去的地方。

完成了`_delete`方法之后，`pop`方法的实现就很简单了。
我们使用`None`作为默认的位置（`i`）参数来表示没有传递这个参数，在这种情况下，列表中的最后一项是要被弹出（`pop`）的项。
但是如果传递了位置参数，我们就需要去删除并返回指定位置的元素。
由于`_delete`方法能够返回我们正在删除的链表节点（`ListNode`）元素，我们只需要让`pop`方法把这个值返回给调用者就可以了。

```Python
    def pop(self, i=None):
        """returns and removes at position i from list; the default is to
        return and remove the last item
        pre: self.size > 0 and (i is None or (0 <= i < self.size))
        post: if i is None, the last item in the list is removed
              and returned; otherwise the item at position i is removed
              and returned"""

        assert self.size > 0 and (i is None or (0 <= i < self.size))

        # default is to delete last item
        # i could be zero so need to compare to None
        if i is None:
            i = self.size - 1

        return self._delete(i)
```

将元素插入链表也非常的简单。
我们只需要记住要去处理在第一项元素之前插入新元素这一个特殊情况就行了，因为在这个情况下，我们需要去更新`self.head`。
对于插入到列表中的任意其他位置，我们都只需找到在位置（`position - 1`）之后的那一个前序链表节点（`ListNode`），然后在这个节点之后创建一个新的链表节点（`ListNode`）并相应地更新链接就行了。

```Python
    def insert(self, i, x):
    """inserts x at position i in the list
    pre: 0 <= i <= self.size
    post: x is inserted into the list at position i and
          old elements from position i..oldsize-1 are at positions
          i+1..newsize-1"""

    assert 0 <= i <= self.size

    if i == 0:
        # insert before position 0 requires updating self.head
        self.head = ListNode(x, self.head)
    else:
        # find item that node is to be inserted after
        prev = self._find(i - 1)
        prev.link = ListNode(x, prev.link)
    self.size += 1
```

要注意的是，在这段代码里，我们并没有做任何特殊的操作来处理插入到列表的最后或者是插入一个空列表。
你可以在这两个边界情况跟踪这段代码的执行情况和过程来了解会发生什么。

另一个可能会非常有用的方法是创建一个列表的副本。
正如我们在4.2节里讨论的内置的Python列表那样，存在浅拷贝和深拷贝这样的区别。
回顾一下，它们的不同之处在于浅拷贝得到的副本只能获得顶层的引用的副本，而深拷贝得到的副本会创建对象中每一个引用和可变对象的单独副本。
Python允许我们来定义我们自己的拷贝方法。
因此，当使用用户定义的类时，如果调用复制（`copy`）模块中的浅拷贝（`copy`）和深拷贝（`deepcopy`）功能时，这些方法就会被调用。
执行这些操作的方法是`__copy__(self)`（对于浅拷贝）和`__deepcopy__(self，visit)`（对于深拷贝）。
在这里，我们先不去考虑`deepcopy()`方法，让我们来看看应该如何实现浅拷贝。
在自定义类里提供`__copy__`方法，将会允许我们类的客户端执行下面这样的浅拷贝：

```Python
import copy
a = LList([0, 1, 2, 3])
b = copy.copy(a)
del a[2]
print b[2] # outputs 2
```

`__copy__`创建的浅拷贝副本将会为列表中的每一个元素都创建一个全新的链表节点（`ListNode`）。
因此，就像这个例子里出现的那样，这个浅拷贝方法能够让我们在不影响副本的情况下插入或删除列表中的元素。
这个浅拷贝（`copy`）方法的一种实现是

```Python
    def __copy__(self):
        """post: returns a new LList object that is a shallow copy of self"""

        a = LList()
        node = self.head
        while node is not None:
            a.append(node.item)
            node = node.link
        return a
```

这个方法首先会创建一个新的（空的）列表对象，然后遍历原始列表中的每一个节点，并且把每个元素都添加到新列表的结尾。
每次调用追加（`append`）方法都会创建一个新的链表节点（`ListNode`）来包含这个元素。
甚至，我们可以省去对节点的引用，而通过使用我们之前定义的索引操作来简单地实现：

```Python
    def __copy__(self):
        a = LList()
        for i in range(len(self)):
            a.append(self[i])
        return a
```

这两个实现都不是特别的高效，因为我们的追加（`append`）方法总是从列表的头部开始并且遍历它的所有节点，从而到达列表的末尾来添加新的节点。
毫无疑问，聪明的读者们也一定注意到了，当传递了初始化序列时，我们的`__init__()`方法同样的效率非常低下。
既然我们已经实现了足够的Python列表的API来让我们的链表（`LList`）够用，那么现在可能是退后一步来分析算法的时间复杂度的一个很好的时间点。

在这一节的开头，我们提到列表的链式实现的主要优点与数组实现恰恰相反——因为我们永远不必移动元素来腾出空间或移除空隙，插入和删除操作会更加高效。
很明显，链式实现的缺点是我们失去了进行高效的随机访问的能力。
为了找到列表中的特定元素，我们只能从头开始并且依照链接进行遍历，直到我们找到那个我们想找到的元素。
在我们的实现中，这个查找操作是通过`_find(i)`这个辅助方法来完成的。

让我们仔细地看看我们的算法，从而能够分析那些常见列表操作的运行时效率。
从列表创建开始，假设我们执行下面这样的一些代码：

```Python
myLList = LList(someSequence)
```

这个代码片段的$Θ$（Theta）分析是什么？
很明显，创建链表（`LList`）的时间取决于我们用于构建初始链表（`LList`）的`someSequence`的长度。
咋一看，这个操作应该是$Θ(n)$的复杂度，其中$n$是`someSequence`的长度。
但如果仔细查看这段代码的话，你就会发现，这个值太乐观了。

链表（`LList`）的构造函数里包含了一个`for`语句，它会被用来遍历`someSequence`中的每一项，但循环体里使用了添加到结尾（`append`）操作。
要知道，添加到结尾（`append`）操作必须要遍历需要附加的整个列表，从而能够从链表的头部到末尾都插入新的链表节点（`ListNode`）。
这使得添加到结尾（`append`）操作就是一个$Θ(n)$的复杂度。
如果你真的去计算了在循环主体里的所有的执行语句中所必须要遍历的链接总数，你将会得到一个类似$0 + 1 + 2 + 3 ... + (n-1)$的序列。
就像我们已经多次看到的那样，这种公式的总和会代表所有操作将会是$Θ(n^2)$的复杂度。
另一个考虑这个效率的简单方法是：复杂度为$Θ(n)$的添加到结尾（`append`）操作执行了$n$次，所以我们实际上有一个$Θ(n^2)$算法。

好在，修改构造函数可以相对容易的让我们提高运行效率。
正如我们发现的那样，问题是使用了加到结尾（`append`）操作来构建这个列表。
而且，我们知道了只要我们能够掌握元素必须插入的位置，我们就可以通过去找几个合适的引用来添加元素到链表中。
如果我们一直跟踪列表末尾的位置，我们就可以在$Θ(1)$时间里插入下一个节点。
下面是一个使用这种方法的构造函数的版本。

```Python
    def __init__(self, seq=()):
        """create an LList
        post: creates a list containing items in seq"""

        if seq == ():
            # No items to put in, create an empty list
            self.head = None
        else:
            # Create a node for the first item
            self.head = ListNode(seq[0], None)

            # Add remaining items keeping track of last node added
            last = self.head
            for item in seq[1:]:
                last.link = ListNode(item, None)
                last = last.link

        self.size = len(seq)
```

如果你研究这段代码，你就应该能够证明，我们新的列表创建算法是$Θ(n)$的时间复杂度。
因此，我们值得为这一点额外代码付出努力。
甚至，这种实现可以被推广到其他方法里。
通过添加最后（`last`）这个实例变量，链表（`LList`）将始终“知道”哪个节点位于列表的末尾，然后添加到结尾（`append`）操作就可以被写为只需要$Θ(1)$的操作。
当然，这会在我们的类的不变量中引入一个新的条件，即对于空列表，`last`是`None`（`last is None`）；
而对于非空列表，`last`应该是最后一个链表节点（`ListNode`）。
这个类里的所有方法都必须遵守这个新的不变量。
实现这个优化会被当作一项练习在后面出现。
顺便说一句，当添加到结尾（`append`）操作成为一个常量时间操作时，你可以把`__init__`恢复成之前的更简单的形式。

我们已经看到了，通过一些调整，链表（`LList`）的创建可以在$Θ(n)$的时间复杂度内完成，并且添加到结尾（`append`）操作可以在$Θ(1)$时间内完成。
因此，这些是非常高效的操作。
我们来看看遍历整个列表来处理每一个元素。
假设我们要输出出列表中的所有元素。
由于我们已经实现了列表的索引操作，我们可以像下面这样做。

```Python
for i in range(len(myLList)):
    print myLList[i]
```

同样，这段代码看起来似乎应该是$Θ(n)$的复杂度，这和我们使用Python的内置列表是相同的。
然而，遗憾的是，索引操作遇到了与之前添加到结尾（`append`）操作所遇到相同的问题。
获取链表中的第$i$个元素是一个$Θ(i)$的操作。
再想一想每次迭代循环必须遍历的链表节点（`ListNode`）的数量。
分析结果看起来就像我们最早的`__init__`方法一样。
以这种方式进行列表遍历是一个$Θ(n^2)$的时间复杂度！

更不幸的是，和添加到结尾（`append`）操作的情况不同，我们通常不能做任何事情来提高效率，从而让链表的索引操作变为一个常量时间操作。
我们知道添加到结尾（`append`）操作总是在最后一个节点上运行，但索引的整个要点是客户端可以请求任意节点的内容。
这就需要每次都要从头开始计数（或者可能是某些其他固定位置开始）才能到达请求的节点。
这里总会有一个$Θ(n)$操作。
这就是我们要使用链表所必须要付出的代价。

这种对随机访问的效率的缺乏，也让我们忽略掉了链式结构对插入和删除的优势。
由于我们已经实现了Python列表的API，因此能够根据索引位置来执行插入和删除操作。
非常不幸的是，找到用于执行相应操作的整个链表节点（`ListNode`）是一个$Θ(n)$的操作，因此即使实际的插入或者删除节点可以通过几个引用来高效的完成，整个操作也是$Θ(n)$的时间复杂度。
这是因为，在`insert`和`_delete`中调用了`_find`方法。

到目前为止，看起来好像我们的链式实现完全是在浪费精力。
我们的$Θ$（Theta）分析告诉我们，我们的操作并不能比Python列表更高效，并且遍历这个列表的性能实际上会更糟糕。
然而，我们也不必感到太沮丧，这是因为Python列表的API是围绕着对使用数组而实现的列表有效的操作而设计的。
我们并不能去期望在完全相同的API下能够发挥出链式实现的优势。

## 迭代器

在上一节中，我们看到了通过连续的索引位置来遍历链表是非常低效的（$Θ(n^2)$）。
但是我们知道有更高效的方式来遍历链表，我们只需要从头开始并按照链接进行移动就行了。
如果我们可以访问链表（`LList`）的内部结构，我们就可以像下面这样编写代码：

```Python
node = myLList.head
while node is not None:
    print node.item
    node = node.link
```

这里变量`node`只是在列表里不断向后移动，就能输出所有元素。

这就让我们陷入了实现容器的一个有趣的困境。
遍历所有元素对于几乎任何容器来说都是一个非常有用的操作，但是为了能够更高效的执行，似乎需要利用到容器的内部结构。
如果我们可以编写通用的客户端代码，并且能够高效的遍历*任何*容器，那会非常的美妙。
实际上，我们希望每个容器都能够按照对这个容器最有效的方式进行遍历。

解决通用的遍历问题的一种方法是使用被称为*迭代器*（*iterator*）的通用设计模式。
简而言之，迭代器是一个知道如何从容器里生成一系列元素的对象。
当我们想要遍历容器里的元素时，我们就去要求容器给我们一个迭代器，然后我们使用这个迭代器来生成元素。
如果我们确保所有迭代器都遵循相同的API，那么我们可以通过编写通用迭代器的代码来遍历任何类型的集合。
可能听起来这个设计模式非常的复杂，但实际上它却很简单。

### Python的迭代器

不同的设计者会为迭代器选择稍有不同的API。
迭代器已被设计在了Python语言内部，并且Python的迭代器的API是最简单的一种。
下面是使用迭代器来遍历Python列表中的元素的示例。

```Python
>>> myList = [2, 3, 4]
>>> it = iter(myList)
>>> type(it)
<type ’listiterator’>
>>> it.next()
2
>>> it.next()
3
>>> it.next()
4
>>> it.next()
Traceback (most recent call last):
    File "<stdin>", line 1, in <module>
StopIteration
```

`iter`函数用于“要求”集合提供一个迭代器的对象。
可以看见，这个生成的对象`it`是`listiterator`类型。
在Python里，迭代器对象只有一个名为`next()`[^1]的方法，它会生成序列中的下一个元素。
正如交互式操作中显示的那样，当迭代器用完所有的元素时，它会抛出`StopIteration`异常。

> [^1] Python 3.0里使用了钩子函数`__next__`，新的内置函数`next(iterator)`会调用这个钩子函数。

通过这个简单的接口，我们可以编写通用代码，从而去遍历任何支持迭代器的容器对象里的元素。
我们只需要获取一个迭代器并重复调用它的`next`方法，直到它抛出`StopIteration`异常就行了。
下面的代码就通过`while`实现了这样一个通用的遍历代码。

```Python
items = iter(myContainer)
while True:
    try:
        item = items.next()
    except StopIteration:
        break
    # process item here
```

你可以看到，这段代码有一个非常尴尬的地方，因为我们需要去捕获`StopIteration`异常来检测集合的结束，从而能够中断循环。
好在，我们并不需要直接和迭代器打交道。
一个普通的`for`循环就会隐式地使用迭代器。

用Python的方法来编写这段简单的代码

```Python
for item in myContainer:
    # process item here
```

在这段代码的背后，这个`for`循环会使用`iter`函数向容器请求迭代器，然后调用`next`来得到每次循环所对应的元素。
当迭代器抛出`StopIteration`时，循环结束。
因此，我们可以通过使容器实现合适的迭代器来让任何容器都能够在`for`循环中被使用。

### 在链表（`LList`）里添加迭代器

在我们的链表（`LList`）类中添加迭代器非常的简单。
我们的迭代器将是一个用来跟踪列表中当前位置的对象。
每次调用`next`时，我们都会返回当前位置的元素，并将迭代器指向下一个元素。
对于链表来说，这就意味着我们的迭代器只需要跟踪哪个链表节点（`ListNode`）是当前节点就行了。
一开始的时候，这个节点是列表的头部。
当然，这个链表迭代器（`LListIterator`）会是一个全新的对象。
因此，我们需要一个类来定义它。

```Python
# LList.py
class LListIterator(object):
    def __init__(self, head):
        self.currnode = head

    def next(self):
        if self.currnode is None:
            raise StopIteration
        else:
            item = self.currnode.item
            self.currnode = self.currnode.link
            return item
```

由于这个类也是链表（`LList`）的另一个辅助类，因此把它同样放在LList.py模块文件中是可行的。

剩下的就是稍微修改我们的链表（`LList`）类，从而能够在被调用时返回适当的链表迭代器（`LListIterator`）类的实例。
你可能已经猜到了，这可以通过另一个Python钩子方法`__iter__`来实现。
当在对象上调用Python的`iter`函数时，它会返回对象的`__iter__`方法的结果。
所以，我们对链表（`LList`）类的更新就像下面这样：

```Python
class LList(object):
    ...
    def __iter__(self):
        return LListIterator(self.head)
```

通过添加的这部分代码，我们的链表（`LList`）类现在就可以使用Python传统的`for`循环来进行高效的遍历了。
让我们来测试一下它。

```Python
>>> from LList import *
>>> nums = LList([1,2,3,4])
>>> for item in nums:
...     print item
1
2
3
4
```

如你所见，迭代器设计模式是一个功能非常强大的工具，它能够在不暴露集合实际实现的细节下，允许访问集合里的元素。

### 通过Python的生成器来迭代

实现迭代器的关键思想是：迭代器对象需要记住遍历一系列元素的当前状态。
在我们的链表（`LList`）示例中，只需保存对当前节点的引用就能够轻松获得这个状态。
一般来说，这种保存遍历或其他计算状态的想法非常有用。
通常，一个能够在我们离开的地方“重新启动”进行计算的方法都会很有用。
Python支持一种被称为*生成器*（*generator*）的特殊结构，它就能够允许我们这样“重新启动”进行计算。

生成器的定义看起来非常像一个常规函数，但它允许我们在计算的过程中返回一个值，当需要下一个值的时候，它会继续执行，并且是从中断处继续执行。
举个简单的例子，这里有一个生成自然数平方序列的生成器：1，4，9，以此类推。

```Python
def squares():
    num = 1
    while True:
        yield num * num
        num += 1
```

你可以看到，这段代码看起来就像是一个普通的函数定义，但是函数是用`return`语句返回值的情况下，生成器使用的是特殊关键字`yield`（生成）。
这段代码里的想法是这样的：我们有一个无限循环（`while True`），每次循环的时候，我们都去`yield`（生成）序列中的下一个平方数。

调用这个生成器时，它里面的代码实际上并不会被执行。
恰恰相反，它会返回一个遵循迭代器API的生成器对象。
比如，我们可以像下面这样生成一系列的平方数。

```Python
>>> seq = squares()
>>> seq.next()
1
>>> seq.next()
4
>>> seq.next()
9
```

每次我们调用`next`的时候，生成器代码都会从中断的位置（紧接在`yield`之后）继续运行，直到遇到下一个`yield`语句。
产生的值会作为结果返回。
如果生成器通过调用`return`来退出或者只是“从最下面掉下去了”（没有更多的元素），就像任何正常的Python迭代器一样，生成器将会抛出`StopIteration`异常。

由于调用生成器会生成一个迭代器对象，因此生成器对于让容器类可以迭代就非常有用了。
我们可以将类的`__iter__`方法转换为生成器，而不是像以前那样编写单独的迭代器类来实现。
下面是链表（`LList`）类在这样改进之后的样子。

```Python
class LList(object):
    ...
    def __iter__(self):
        node = self.head
        while node is not None:
            yield node.item
            node = node.link
```

从本质上来说，这是我们遍历链表的标准代码。
只需要在我们到这里的时候生成（`yield`）每个元素就好了。
我们将`while`循环语句转换为了生成器，因此可以根据需要一次生成一个值。
这是新的通过生成器来增强的这个类的实际应用。

```Python
>>> from LList import *
>>> nums = LList([1,2,3,4])
>>> for item in nums:
...     print item
1
2
3
4
```

生成器为我们提供了一个可迭代的容器，从而不用在去创建一个单独的迭代器类。
生成器是Python里一个非常酷的功能，它里面包含的功能比我们在这里展示的要多得多。
你可以查阅相关的Python文档来了解更多关于它的信息。

## 基于游标的列表API（选读）

我们现在有了一个可用的链表，它实现了Python列表的API，但我们没有办法通过利用链式实现来展现真正的优势。
要知道，链式方法的主要优点是：我们不必在插入或删除时移动元素，我们只需要调整相应的引用就可以了。
但是，到目前为止，我们的列表API要求我们能够使用索引来定位插入或删除的地方，并且对于链表，索引需要$Θ(n)$的时间复杂度。
也许我们应该考虑换一个API。

从一个角度来看，索引只是一种“指向”列表中特定位置的方式。
如果我们的列表是基于数组的，那么使用数字（索引）就是非常自然的事情，因为底层内存地址的计算可以非常有效地完成。
但是使用链表不同，用对列表节点的引用来指定位置则显得更加自然。
实际上，在上一节中，我们构建的链表迭代器（`LListIterator`）类实际上只是一个节点引用的包装。
如果我们扩展迭代器的API从而允许它不仅仅能够执行元素的检索，会发生什么？
通过添加允许我们在*迭代器的当前位置*进行修改列表的操作，我们将能够创建一个基于位置而不是基于索引的新的列表API。
我们将这种扩展的迭代器类型称为*游标*（*Cursor*）。

### 游标（`Cursor`）的API

要了解游标是为什么会有用的，可以考虑从列表中过滤元素的问题。
也就是说，我们希望从列表中删除符合特定条件的元素。
作为一个具体的例子，考虑这样一个（有点傻）的功能，这个功能会用来审查一个单词列表。
假设我们要删除列表中出现在另一个违禁词列表中的所有单词。
这是一个简单的函数规范。

```Python
def censor(wordList, forbiddenWords):
    """ deletes forbidden words from wordList

    post: all words in forbiddenWords have been deleted
        from wordList."""
```

在继续往下阅读之前，你可以先思考一下应该如何使用我们当前的列表API来解决这个问题。
一个非常明显的算法是遍历`wordList`对象，来依次查看每一个元素，然后删除那些恰好出现在`forbiddenWords`（违禁词）里的任何元素。
很不幸的是，我们当前的API并没有提供一个能够实现这个算法的直接方法（至少说，没有高效的算法）。

现在，假设我们有一种方法可以向列表中查询从列表头部开始的游标，并允许我们在列表中依次前进并且删除元素。
我们可以创造一个小小的游标API来允许我们表达出上面提出的`censor`（审查）算法。

```Python
def censor(wordList, forbiddenWords):
    cursor = wordList.getCursor()
    while not cursor.done():
        if cursor.getItem() in forbiddenWords:
            cursor.deleteItem()
        else:
            cursor.advance()
```

你应该能够通过阅读这个算法，就能够非常清楚的了解到我们提出的游标操作将会做些什么。
`getCursor`的调用将会给我们返回一个游标对象，这个对象会“指向”列表中的第一个元素。
我们可以通过调用各种游标方法来操作当前元素：`getItem`返回当前元素，`deleteItem`从列表中删除当前元素。
调用`advance`（前移）可以使游标移动到列表中的下一个元素。
当游标当前位于列表中的最后一项时，调用`advance`将会导致`cursor.done()`返回`true`。
要注意的一点是：
删除元素的时候，我们不需要再前移游标。
删除将会自动把游标设置为下一个元素，因为我们不能让游标指向任何已经不在列表中的内容。

我们的完整游标API会像下面这样。

```Python
class Cursor(object):
    def done(self):
        """post: True if cursor has advanced past the last item
                 of the sequence, false otherwise"""

    def getItem(self):
        """ pre: not self.done()
           post: Returns the item at the current cursor position"""

    def replaceItem(self, value):
        """ pre: not self.done()
           post: The current item in the sequence is value"""

    def deleteItem(self):
        """ pre: not self.done()
           post: The item that cursor was pointing to is removed
                 and the cursor now points to the following item
           note: removing last item causes self.done() to be True"""

    def insertItem(self, value):
        """ post: value is added to the sequence at the position of
                  cursor.
            note: If self.done() holds before the call, value will be
                  added to the end of the sequence. In other cases,
                  the item that was at current position becomes the
                  next item."""

    def advance(self):
        """ post: cursor has advanced to the next position in the
                  sequence. Advancing from the last item causes
                  self.done() to be True"""
```

### Python的CursorList（游标列表）

最终，我们希望我们的小小的`censor`算法能够适用于基于Python的列表和基于链表（`LList`）的·wordLists·。
很明显，Python列表的游标实现将不同于链表的游标实现。
前者必须使用索引来跟踪当前的位置，而后者则应该使用链表节点（`ListNode`）引用。
这也就体现了`getCursor`操作的用武之地——利用多态，我们可以让每种列表都返回一个适合该类型列表的游标。
这就意味着，我们不仅需要创建两种不同的游标，我们还需要发明两种新的列表。
`PyCursorList`就像一个包含`getCursor`方法的标准Python列表，而`LinkedCursorList`则会是一个带有`getCursor`的链表（`LList`）。
听起来好像现在变得非常复杂了！

实际上，情况并不像听起来那么糟糕。
我们只想用我们的新的游标API来扩展现有的列表类。
因此，这是一个使用继承的理想场所。
就像我们在2.3.4节里讨论的那样，继承允许我们扩展现有类的行为。
在这种情况下，`PyCursorList`应该看起来像，而且各个行为也像一个Python列表，并且它还在需要的时候能够提供游标。
如果我们将`PyCursorList`作为`list`的子类，那么`PyCursorList`的任何实例本身都会是一个列表，我们将自动获得所有内置的列表功能。
所以，我们的新类可以这样的开始：

```Python
# PyCursorList.py
from PyListCursor import PyListCursor

class PyCursorList(list):

    def getCursor(self):
        return PyListCursor(self)
```

可以看到，在类的定义部分，`PyCursorList`是内置列表的子类（也就是继承自内置列表）。
我们并没有为子类定义任何构造函数，因为这个类会继承自内置的Python列表类型的构造函数。
我们的新类型将会和Python列表一样，就像下面这个交互式操作所显示的：

```Python
>>> lst = PyCursorList([1,2,3,4])
>>> lst
[1, 2, 3, 4]
>>> lst.append(5)
>>> lst
[1, 2, 3, 4, 5]
>>> lst[1]
2
>>> type(lst)
<class ’__main__.PyCursorList’>
```

现在我们只需要一个合适的`PyListCursor`（列表游标）定义就可以了。
要知道，游标只是封装了一个位置的想法。
对于Python列表来说，我们可以只跟踪当前位置的索引，然后使用常规列表的方法在这个位置上执行各种游标操作。
这里是实现它的代码：

```Python
# PyListCursor.py
class PyListCursor(object):

    def __init__(self, pylist):
        self.index = 0
        self.lst = pylist

    def done(self):
        return self.index == len(self.lst)

    def getItem(self):
        return self.lst[self.index]

    def replaceItem(self, value):
        self.lst[self.index] = value

    def deleteItem(self):
        del self.lst[self.index]

    def insertItem(self, value):
        self.lst.insert(self.index, value)

    def advance(self):
        self.index += 1
```

列表游标（`PyListCursor`）的构造函数将会存储整个列表并在最前面（位置0）的地方开始索引。
其他的方法都是单行的，这是因为Python列表的操作就能够完成相应的工作。
在继续学习如果去实现链表的游标之前，请确保你已经能够完全理解这部分代码。

为了完整起见，让我们通过尝试这个审查问题来测试一下我们新的类。

```Python
>>> from PyCursorList import PyCursorList
>>> words = PyCursorList("Curse you and the horse you rode in on".split())
>>> censor(words, ["Curse", "horse", "you"])
>>> words
['and', 'the', 'rode', 'in', 'on']
```

### 链式结构的CursorList（游标列表）

我们可以用类似于`PyCursorList`的方法来实现`LinkedCursorList`。
但是，这一次我们会继承自底层的链式实现。

```Python
# LinkedCursorList.py
from LList import LList
from LListCursor import LListCursor

class LinkedCursorList(LList):

    def getCursor(self):
        return LListCursor(self)
```

这之后，就让我们剩下了实现`LListCursor`（链表游标）类。
在某些方面，它将类似于Python列表的游标，但在很多其他方面它会是完全不同的。
这里有一些我们需要注意的细微之处。
首先，为了使游标高效，我们将利用链表（`LList`）的内部结构，就像我们对列表迭代器所做的那样。
从这个意义上说，链表游标（`LListCursor`）实际上并不是一个独立于链表（`LList`）的抽象数据类型，而是一种为底层数据结构提供另一个API的机制。
这两个类是密切相关的，改变其中一个类就可能需要同时去改变另一个类。

Python的列表游标（`PyListCursor`）和链表游标（`LListCursor`）之间的另一个区别是：
后者将跟踪当前的链表节点（`ListNode`）而不是保留当前的索引。
首先，游标看起来就像是链接的迭代器一样，我们只会保留对当前节点的引用，然后通过链接来在需要的时候进行前移。
但是，如果进一步的思考，会发现这种方法存在问题。
正如在之前对链表的讨论里所知道的，为了添加或删除一个节点，我们需要修改*前序*节点中的链接。
这导致了这样一种设计，我们总是保留对当前节点之前的那个节点的引用
让我们将其保存在名为`self.prev`的实例变量之中。
当然，在这之后，我们会遇到另一个问题，当最初创建游标的时候，第一个节点应该是当前节点，但这个节点并没有它的前序节点。
那么`self.prev`的初始值应该是什么呢？

处理第一个节点缺少前序问题的一种方法是，将`self.prev`设置为`None`作为特殊标记，然后在整个代码中检测这个特殊情况。
这和我们在处理最早的链表（`LList`）的代码中的特殊情况是一样的方式，这种方法当然可以在这里被再次使用。
但是，在所有的方法中进行这个特殊情况的检查，可能会变得非常繁琐而且容易出错。
另一种方法则是，确保列表中的每个节点都有一个有效的前序节点。
我们可以简单地通过创建一个额外的节点来做到这一点，这个节点通常被称为*虚*（*dummy*）节点。
放置在列表前面的虚节点也通常被称为*标头*（*header*）节点。
我们将使用这个标头（`header`）节点来实现我们的链表游标（`LListCursor`）。

这是实现我们的审查算法所需要的基本操作的代码：

```Python
# LListCursor.py
from ListNode import ListNode

class LListCursor(object):

    def __init__(self, llist):
        self.lst = llist

        # create a dummy node at the front of the list
        self.header = ListNode("**DUMMY HEADER NODE**", llist.head)

        # point prev to just before the first actual ListNode
        self.prev = self.header

    def done(self):
        return self.prev.link is None

    def getItem(self):
        return self.prev.link.item

    def advance(self):
        self.prev = self.prev.link

    def deleteItem(self):
        self.prev.link = self.prev.link.link

        # first listnode may have changed, update list head
        self.lst.head = self.header.link
```

从这段代码里，你可以看到，构造函数存储了这个初始列表，然后创建了一个标头（`header`）节点，并且把`prev`实例变量设置成了第一个真正的节点之前的那个人造前序节点（标头节点）了。
我们需要保存这个初始列表以及标头（`header`）节点。
这是因为如果游标在列表的最前面进行插入或者删除操作，我们将需要更新链表（`LList`）中的`head`实例变量。
而我们保存起来的标头（`header`）节点，它的链接将会始终指向列表的`head`实例变量。
我们稍后会回到这一点。

前三种常规的方法非常直接。
要记住的一点是，实际的当前节点始终是`self.prev`引用的节点之后的那个节点。
当`self.prev`是列表中的最后一个节点（链接为`None`的节点）时，我们也能够知道游标已经被移到了列表的末尾。
`getItem`方法只需要在`self.prev`之后的节点里获取`item`字段就可以了，而`advance`方法则只是将`self.prev`移动到列表中的下一个节点。

`deleteItem`方法会稍微复杂一些。
为了删除当前节点，我们必须要能够修改前序节点的链接来跳过当前节点。
`self.prev.link = self.prev.link.link`这一行代码可以解决这个问题。
我们反复强调过，`self.prev.link`是当前节点，因此这个语句将会把`prev.link`设置为当前节点之后的节点。
这里唯一可能会发生的复杂情况是，当`self.prev`是标头节点时，我们刚刚删除了列表中的第一个节点。
这就意味着我们还需要对`self.lst`修改它的`head`实例变量。
最后一行代码保证了链表（`LList`）对象本身能够被正确的更新。
当然，只有当`self.prev`是标头节点的时候，我们才需要这样做，但每次都执行这个赋值语句也是一样的高效的——即使列表的前面没有被改变也不会影响到效率。
在这里，避免条件判断，能够让代码更整洁；
在这里，标头（`header`）节点为我们处理了这个特殊情况。

我们的`LinkedCursorList`现在能够执行我们的审查算法了，但是它还缺少了一些操作。
仔细研究这段代码，你是可以也能够把缺少的操作补充上的。

现在，我们可以看到链式实现的一些优点了。
列表游标（`PyListCursor`）上的插入和删除操作将会依赖于底层的列表操作，因此是一个复杂度为$Θ(n)$的操作。
链表游标（`LListCursor`）上的相应操作则仅仅会修改一对引用，所以它们很明显是复杂度为$Θ(1)$的操作。
我们将会留给你来判断，是什么决策，让我们的审查方法产生了这些影响。

## 链表 vs. 数组

我们现在用两种不同的方式：数组和链接，详细的了解了如何维护序列信息。
正如我们所看到的那样，链式结构提供了高效的插入和删除操作。
但是，为此我们放弃了对元素的随机访问，这还意味着我们必须要放弃执行二分搜索的可能性。
链式实现的另一个缺点是内存的使用。
由于链接指针，列表中的每个元素都需要一个额外的内存（32位系统上的四个字节）空间。
如果存储的对象的数据类型很小，这实际上可以让整个列表所需的内存量增加一倍以上。

使用基于数组的列表或链表的决定应该基于可能执行的操作类型。
如果会在已知的位置插入或删除许多元素，则链式的实现是合适的。
在大多数情况下，内置的Python列表反而会是简单序列的一个更为恰当的选择。
但是，在后面的章节中，我们将会看到在更复杂的数据结构中，使用的链式实现是怎样为我们提供更好的性能的。
虽然链表可能并不是那么令人兴奋或者有用，那是因为它们只是一个非常强大的想法里的一个最简单的例子。

## 章节总结

这一章里，我们通过引入列表的链式实现来介绍了链式结构的概念。
下面是关于这些关键思想的摘要。

* 在Python里，所有的变量都包含着（对象的地址的）引用。
通过使用引用，我们可以在Python里实现数据结构的链式实现。

* 链式结构能够存储数据元素以及对其他链式结构的一个或多个引用。

* 列表的链式实现可以提供比数组实现更高效的元素插入和删除操作，但它们在随机访问的性能并不太好，而且需要更多内存。

* 链式实现通常比数组实现更难正确编写，这是因为程序员必须小心仔细地跟踪必要的引用。

* 迭代器设计模式允许客户端在不知道集合的底层结构的情况下有效地遍历集合。
Python的生成器为新的容器类提供了一种更高效而且优雅的实现迭代器的方法。

* 类的不变量是类中实现的每个方法的一组隐式先验条件与后置条件。
声明和遵循类的不变量，可以让你更容易的确定你的类的实现是否保持着一个正常状态并且是被正确实现的。

## 练习

**判断题**

1. 在链式结构中，节点包含着对其他节点的引用。

2. 使用链式结构实现的列表需要比用数组实现的列表占据更多的内存。

3. 由于Python列表的方法是用编译了的C代码编写的，因此使用Python列表编写的程序总是比使用Python实现的链表更快。

4. 类的不变量是一组在执行类的每个方法之前和之后都必须满足的属性。

5. 确定链表（`LList`）的长度需要$Θ(n)$的时间复杂度。

6. 在基于数组的列表的开头插入的时间复杂度的最坏情况，与在基于数组的列表的末尾插入的时间复杂度相同。

7. 如果你有列表中最后一个节点的链接，则在基于链式结构实现的列表的开头插入的时间复杂度，和在基于基于链式结构实现的列表的末尾插入的时间复杂度是相同的。

8. 在Python里编写迭代器，你必须要编写`next`方法。

9. 如果链表（`LList`）或内置Python列表仅包含不可变对象（贫血对象），则无需创建列表的深拷贝方法，浅拷贝就足够了。

10. 在Python里，从链式结构中删除一个节点时必须使用`del`语句才能释放节点所使用的内存。

**选择题**

1. 在基于数组的列表的开头插入项目的方法的最坏情况运行时间是多少？

    a) $Θ(1)$

    b) $Θ(\log_2 n)$

    c) $Θ(n)$

    d) $Θ(n^2)$

2. 在基于链接的列表的开头插入项目的方法的最坏情况运行时间是多少？

    a) $Θ(1)$

    b) $Θ(\log_2 n)$

    c) $Θ(n)$

    d) $Θ(n^2)$

3. 在基于数组的列表末尾插入项目的方法的最坏情况运行时间是多少？

    a) $Θ(1)$

    b) $Θ(\log_2 n)$

    c) $Θ(n)$

    d) $Θ(n^2)$

4. 如果你只有一个引用列表中第一个节点的实例变量，那么在基于链接的列表末尾插入项目的方法的最坏情况运行时间是多少？

    a) $Θ(1)$

    b) $Θ(\log_2 n)$

    c) $Θ(n)$

    d) $Θ(n^2)$

5. 与基于数组的列表相比，列表的简单链式实现需要多少内存？

    a) 他们需要相同数量的内存。

    b) 只需要额外的内存给每个实例变量（如head）。

    c) 每个实例变量的额外内存，加上用于让列表中的每个元素保存对下一个节点的引用的内存（32位系统上的4个字节）。

    d) 需要两倍内存。

6. 如果为容器类编写`__len__`方法，对于这个类的实例`b`，这个方法是如何被调用的？

    a) `b.len()`

    b) `len(b)`

    c) `b.__len__()`

    d) `len(b)`或`b.__len__()`

7. 链表游标（`LListCursor`）的`insertItem`方法在最坏情况下的运行时间是多少？

    a) $Θ(1)$

    b) $Θ(\log_2 n)$

    c) $Θ(n)$

    d) $Θ(n^2)

8. 如果要编写使用`yield`语句的迭代器，你必须要编写哪些方法？

    a) `__iter__`和`next`方法。

    b) 只有`__iter__`方法。

    c) 只有`next`方法。

    d) 你不能使用`yield`语句编写出迭代器。

9. 如果不使用`yield`语句来编写迭代器，那么你必须编写哪些方法？

    a) `__iter__`和`next`方法。

    b) 只有`__iter__`方法。

    c) 只有`next`方法。

    d) 如果没有`yield`语句，你不能写出一个迭代器。

10. 以下哪项不是游标API里的方法？

    a) `next`

    b) `getItem`

    c) `replaceItem`

    d) `done`

**简答题**


1. 浅拷贝和深拷贝之间的权衡和区别是什么？

2. 执行下面的代码之后，绘制表示内存的图形。

    ```Python
    import copy
    b = [[1, 2], [3, 4, 5], 6]
    c = b
    c[0] = 0
    d = c[:]
    e = copy.deepcopy(d)
    c.append(7)
    ```

3. 如果在图4.7中执行语句`n25 = ListNode(2.5，n3)`，那么这四个链表节点（`ListNode`）对象中每个对象的引用计数是多少？

4. 如果在图4.7中执行语句`n.link = n25`，那么四个链表节点（`ListNode`）对象中每个对象的引用计数是多少？

5. 内置的Python列表在必要时调整大小的最坏情况的时间复杂度分析是什么？

6. 假设可以实现最有效的实现，内置的Python列表的`insert`，`append`，`__getitem__`，`pop`，`remove`，`count`和`index`的最坏情况下的运行时间是多少？

7. 对于链表实现，问题6中列出的每种方法的最坏情况下的运行时分析是什么？

8. 如果我们添加一个`tail`实例变量，来引用列表中最后一个链表节点（`ListNode`），那么问题6中的每个列表方法的运行时间是多少？

9. 对于我们的链表（`LList`）来说，基于本章里所描述的添加到结尾（`append`）方法，每一个`__copy__`方法的版本的最坏情况下的运行时分析是什么？
你会如何编写一个更高效的`__copy__`方法（在不修改添加到结尾（`append`）方法的情况下）？

10. 在同一个`LinkedCursorList`对象上，迭代器模式是否适用于，运行时的嵌套`for`循环？
解释为什么能或者为什么不能。

**编程练习**

1. 通过实现内置Python列表所支持的其他的一些方法来扩展链表（`LList`）类，比如说`__min__`、`__max__`、`index`、`count`和`remove`。

2. 对于在内置的Python列表的最前面的插入元素的效率，和在链表（`LList`）的最前前面插入元素的效率进行实验比较。
在开始之前，先构思一个关于你所期望看到的情况的假设。
进行一些实验来检验你的假设。
撰写一个完整的实验报告，来解释你的发现。
请务必详细说明你的假设和你所运行的实验。
请确保在你的报告里，说明了你的假设是否得到实验的支持。

3. 像本章节里所建议的那样，添加`last`实例变量到链表（`LList`）类里，从而能够可以在$Θ(1)$的时间内实现添加到结尾（`append`）方法。
这将会要求你修改很多其他的方法来确保`self.last`始终是对链式结构中最后一个链表节点（`ListNode`）的引用。

4. 完成链表游标（`LListCursor`）类的实现，并且按照列表的游标API，为`LinkedCursorList`类提供一整套完整的单元测试。

5. 假设我们希望列表的游标能够做到向两个方向移动。
也就是说，除了前移（`advance`）操作，我们还想有一个后退（`backup`）的操作。
将这个功能添加到列表游标（`PyListCursor`）类里。
请为你修改过的游标编写完整的单元测试。

6. 将上一个练习的功能添加到链表游标（`LListCursor`）类里。
为了能够实现这个功能，你的游标必须要能够跟踪先前的所有节点所形成的“一串”数据。
你可以使用Python列表来实现这个目的：
每个节点的前序节点在游标前移的时候，都会被附加到列表的末尾，然后在游标后退的时候，从列表的末尾弹出。

7. 修改Python列表API的链式实现，让它成为一个*双向链表*。
也就是说，每个链表节点（`ListNode`）都有一个对它之前的链表节点（`ListNode`）和之后的链表节点（`ListNode`）的引用。
再添加一个名为`reverse_iter`的方法，这个方法使用`yield`关键字来以相反的顺序迭代列表。
更新你的单元测试代码，以便能够测试反向链接的相关操作。
通过使用这个双向链表，修改链表游标（`LListCursor`）在不保留前序节点的内部列表的情况下，解决上一个问题。

8. 埃拉托斯特尼筛法（Sieve of Eratosthenes）是一种著名的算法，它被用来找出一定范围内所有的素数。
以下是使用游标来查找所有$≤n$的素数的算法概要：

    ```
    place the numbers 2 through n in a list
    start primecursor at the front of the list
    while primecursor is not done
        prime = value at primecursor
        create checkcursor as a copy of primecursor
        advance checkcursor
        while checkcursor is not done:
            if item at checkcursor is divisible by prime:
                delete the item from the list
            else:
                advance checkcursor
        advance primecursor
    output values left in the list, they are prime
    ```

    编写实现此算法的程序。
    要注意的是，你需要有一种方法来制作游标的副本。
    你一定能自己摸索其中的知识点，并且弄清楚该如何完成这个任务的。
