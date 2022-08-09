# C++的链式结构

目标

* 学习如何用C++来编写链式结构。

* 加强C++动态内存以及如何编写动态内存类的相关概念。

## 简介

和Python类似的，链式结构可在C++里实现许多数据结构，比如说：列表和树结构。
我们在10.2节里了解到了Python的引用和C++的指针本质上是相同的概念，因此要在C++里实现链式结构的话，你就需要使用动态内存以及指针。
编写Python和C++链式结构类之间的主要区别是：
是否需要为类编写析构函数、复制构造函数以及赋值运算符（或者像我们在10.4节里提到的那样，你可以把复制构造函数和赋值运算符声明为私有的，但不去实现它们）。
你的C++类还必须要显式地释放掉内存，而Python里并不需要这么做。
在阅读这一章之前，你需要完全理解我们在前面章节里讨论过的关于C++的内存分配和释放的底层细节，我们将在这一章里对动态内存相关的主题进行强化。

你在使用Python的链式结构的时候，即使你设置了一个对错误的链接对象的引用，Python也并不会去阻止你编写这样的语义错误（比如说，插入节点的时候，可能会弄混`link`所指向的到下一个节点的链接，从而导致跳过了一个节点，或者把节点的`link`指向它自己或更早的节点，从而导致循环链式结构）。
C++环境同样也不会自动地去捕获这些类型的语义错误。
要找到这种类型的错误的最好的办法是广泛地测试你的代码。
但是，Python也还是会去捕获一些C++编译器和运行时环境可能不会去捕获的错误。
比如，Python不允许你使用名称来访问还没有指向有效对象的引用上的数据（例如，尚未定义的名称或者值为`None`的时候）。
如果名称`node`引用的是`None`，那么在当你尝试执行`node.link`或者`node.item`的时候，Python解释器将会始终捕获这个问题，并且在你没有捕获这个异常的时候，产生相应的异常以及回溯执行堆栈。
在C++里，如果你尝试解引用一个还没有初始化的指针或者是引用一个已经被释放的对象的指针的话，那么运行时环境将会继续尝试访问这个内存位置，从而导致获取到垃圾数据，或者是内存故障从而导致程序崩溃。
这部分内容我们在前一章里已经讨论过了。

在C++里，它并不允许你直接将一种类型的指针分配给另一个不同类型的指针（比如说，如果`x`是指向`int`的指针而`y`是指向`double`的指针，那么你不能写`y = x`这样的代码）。
你可以使用`reinterpret_cast`来把一种类型的指针转​​换成另一种类型（它的语法类似于第8.9节里讨论的`static_cast`），但它并不是被用来做这件事情的，而且`reinterpret_cast`也并不是那么的常用。
C++编译器会去检查数据类型是否匹配，但C++的运行时环境则不会去检查指针实际上所指向的有效内存位置，是不是包含这个类型的值。
当你解引用一个没有指向有效内存位置的指针的时候，你的程序有可能会崩溃，就算这个程序可能能够继续运行，但是你的程序结果并不正确，就像我们在10.5节里讨论的那样。

在这一章后面你将会看到，C++里的链式结构的代码并不会比Python版本长。
通常来说，你都可以把Python链式结构的代码逐行转换为C++代码。
但是，从头开始编写C++动态内存和链式结构的代码将会比编写Python的链式结构更困难，这是因为Python会避免你产生某些类型的错误，从而可以更容易地查找和修复这些类型的错误。
在我们讨论了C++里的链式结构的一些其他问题之后，我们将把我们的Python链式结构的一个例子翻译成C++版本。

## C++链式结构的类

在Python里，我们使用了一个包含两个数据元素的`ListNode`类，它们分别是：
数据值和对链表里下一个`ListNode`的引用。
我们可以在C++里使用相同的技术来保存数据元素以及指向链表里下一个节点的指针。
C++版本和Python版本之间的一个显著区别是：
我们的C++的`ListNode`类只能包含一种类型的元素（在我们的例子里，我们用的是`int`），这是因为所有的C++变量都必须有一个确定的类型。
我们将在第12章里学习模板相关的知识，通过它们将能够让我们编写一个可以容纳任何类型的`ListNode`类。
下面是C++的`ListNode`类的一个简单例子，我们将在这一节的后面部分对它进行扩展。

```C++
class ListNode {
public:
  int item_;
  ListNode *link_;
};
```

对于初学者来说，一个容易犯的简单错误是会忘记了`link_`实例变量前面代表指针的星号。
你的C++编译器会要求一定要加上这个星号，是因为你在`ListNode`的定义里又包含了`ListNode`。
而因为每一个`ListNode`都包含一个`ListNode`作为其数据成员，在本质上这也就是一种无限递归，会让`ListNode`消耗掉无穷无尽的内存。
我们上面提到过，因为指针需要存储某个类型的对象的地址，而不是实际对象，因此指向任何数据类型的指针在32位系统上都需要四个字节。
也就是说，除了需要存储的数据所需要的类型相关的内存大小之外，`ListNode`还需要四个额外的字节来存储这个指针。

通常来说我们不会在C++的类里把实例变量写成公有的。
但就像我们在实现Python的`ListNode`类的时候所讨论的那样，允许这个类的客户端直接访问这些实例变量在这里是有意义的，这是因为`ListNode`类只能由另一个需要直接使用这些数据元素和链接的类来进行访问的（在我们的Python的例子里，是`LList`类）。
当然，另一种办法是把`LList`类定义为`ListNode`类的友元。
在9.4节里，我们为`Rational`类编写输入和输出操作符的时候，我们就有提到过把函数声明为友元的相关部分。
就像我们在那个部分里提到的那样，你还可以把一个类也声明为友元。
下面这个我们的新版本的`ListNode`类就展示了这个方法，而且它还包含了一个构造函数，因此我们可以像在Python里使用`ListNode`类那样去使用这个类了：

```C++
#ifndef _LISTNODE_H
#define _LISTNODE_H

#include <cstdlib>

class ListNode {
  friend class LList;

public:
  ListNode(int item = 0, ListNode* link = NULL);

private:
  int item_;
  ListNode *link_;
};

inline ListNode::ListNode(int item, ListNode *link)
{
  item_ = item;
  link_ = link;
}
#endif // _LISTNODE_H
```

`ListNode`的构造函数将能够让我们使用零个、一个或者是两个参数来调用构造函数。
我们为`int`类型的参数提供了默认值零，这样我们就可以得到一个不需要任何参数的默认构造函数。
`link`参数的默认值是`NULL`。
和Python的`None`值的判断结果为`false`一样，`NULL`值（其实也就是零）的判断结果也是`false`，所以我们可以通过它来检查尚未初始化或者是无效的指针。
因此，我们可以编写像是：`if (node != NULL)`或者它的简写版本`if (node)`这样的代码来检查有效指针，因为`NULL`会被判断为`false`，而对于任何有效指针地址的判断结果则会是`true`。
我们在Python的章节里讨论过了在代码里使用`is`运算符的链式结构，比如说：`if node is not None`是在Python里执行这种判断的最好方法。
但是在C++里并没有`is`运算符，因此我们会使用`if (node)`或`if (node != NULL)`来进行判断。
就C++的性能而言，这两个语句并没有任何的区别。
为了方便阅读，一些程序员会更喜欢写成`if (node != NULL)`，但是大多数程序员都会使用简写`if (node)`。

由于构造函数只有两行，因此我们把它定义成了内联函数，从而避免函数调用的额外开销。
可以看到，我们遵循了在实例变量名称后添加下划线的约定。
这样做可以除了有下划线这部分的不同之外，实例变量和形参使用的是相同的名称。

由于C++为实例成员提供了显式的保护，因此我们在`ListNode`类里可以使用这一特性。
把`item_`和`link_`声明为了私有的实例变量，但同时也让`LList`类成为我们`ListNode`类的友元。
在这个时候，编译器并不知道会有一个`LList`类，因为在这个文件里并没有对它添加引用。
我们并不能在这个头文件里去包含LList.h文件，这是因为LList.h文件需要包含这个头文件（不然的话，我们就会有一个循环引用）。
为了表明将会有一个名叫`LList`的类，我们可以把代码行`class LList;`放在`class ListNode {`行之前。
这样的做法被称为*前向声明*（*forward declaration*），但大多数（如果不是全部的话）的编译器在声明友元的时候并不需要前向声明。
当然，还有一个选择是像我们一开始那样在公有的部分声明实例变量，但是这样会像Python里那样让任何类都能够访问它们。

回想一下10.2节里我们的`Rational`类的例子，在那个例子里，我们不能解引用指针，而且由于优先级问题，也不能使用没有括号的点运算符。
那个时候我们提到了，常见的用法是使用`->`。
但是，像下面这个例子展示的那样，有两种正确的方法都可以完成这一功能。

```C++
ListNode *node;
node = new ListNode(2); // item parameter is required
node->item_ = 3; // this is correct
*node.item_ = 3; // this is not correct
(*node).item_ = 3; // this is correct
```

## C++链表

通过我们的C++的`ListNode`类，我们可以创建出一个列表的链式实现，就像我们在第4章里用Python所做的那样。
在那个时候，我们用和内置Python列表相同的API编写了列表的链式实现。
在这一节里，我们将编写一个列表的链式实现的C++版本，这个列表也会和内置的Python列表的API相匹配。
这个版本的语法将会有所不同，要处理的唯一的语义差异是：
在从列表里删除元素的时候，我们需要显式地释放`ListNode`实例；
而Python则是通过实例的引用计数机制来自动处理这个过程。
就像我们在前一章里对动态内存类所做的那样，我们必须要编写一个析构函数来进行最终的内存释放。
而且，就像你需要对任何分配了动态内存的实例变量都会做的那样，你还需要编写复制构造函数和赋值运算符（`operator=`），或者阻止它们被调用。
你可以通过在`private`部分里声明复制构造函数和赋值运算符来阻止它们被使用，当你把方法声明为`private`之后，你就并不需要为它们提供实现了。
如果没有私有方法的实现，那么在调用方法的时候，编译器就会生成错误。
下面这个LList.h头文件向我们展示了我们需要去实现的`LList`类的接口：

```C++
#ifndef _LLIST_H
#define _LLIST_H

#include "ListNode.h"

class LList {

public:
  LList();
  LList(const LList& source);
  ~LList();

  LList& operator=(const LList& source);
  int size() { return size_; }
  void append(const ItemType &x);
  void insert(int i, const ItemType &x);
  ItemType pop(int i=-1);
  ItemType& operator[](int position);

private:
  // methods
  void copy(const LList &source);
  void dealloc();
  ListNode* _find(int position);
  ItemType _delete(int position);

  // data elements
  ListNode *head_;
  int size_;
};

#endif // _LLIST_H
```

你可能已经注意到了，在这里我们有着比`LList`类的Python实现更多的方法。
这是因为我们需要能够正确地分配和释放内存。
而且，由于复制构造函数和赋值运算符共享着一部分功能，我们也就声明了可以被两个方法都调用的私有的`copy`方法。
析构函数和赋值运算符也共享着一部分功能，因此我们声明了`dealloc`方法来让这两个方法调用。

我们的`ListNode`和`LList`类的一个缺点是它们只能使用一种数据类型（在我们的例子里是整数）。
到目前为止，我们将渐进式地改进这一点，并且会使用C/C++的关键字`typedef`，这个关键字能够让我们定义新的类型名称。
在下面的例子里，我们创建了一个叫做`ItemType`的类型，它现在是`int`的同义词。
接下来，我们可以更新我们的`ListNode`和`LList`类，从而在和列表里存储的值相应的位置使用`ItemType`类型而不是`int`类型。
可以看到，我们并没有把所有`int`类型出现的地方都改成`ItemType`类型。
因为，不管是什么数据类型，`LList`的大小仍然是一个整数。
现在，如果我们想要创建一个可以包含不同类型的`LList`的话，比如说`double`或者是`Rational`，我们只需要去修改ListNode.h文件里的那个`typedef`行就行了（如果它不是内置类型的话，还需要包含相对应的头文件）。

`typedef`语句并不允许我们在同一个程序里去存储不同的类型。
因此，在一个程序里的每个`ListNode`都必须使用我们在`typedef`命令所指定的那个类型。
也就是说，因为程序中只能包含有一个名为`LList`的类和一个名为`ListNode`的类，一个程序只能有一个类型的`LList`。
我们也可以复制这部分代码并创建一批像`ListNodeInt`/`LListInt`以及`ListNodeDouble`/`LListDouble`这样的类，并且修改每个文件里的`typedef`行，这样也就可以在一个程序里简单重用现有的代码来实现不同的功能了。
在第12章里，我们将讨论模板，模板将能够让我们在一个程序里，在不需要为每一种类型都复制一个类文件的情况下，包含不同类型的列表。
在这里，我们通过使用`typedef`语句可以让我们在之后更容易地将这个程序转换成基于模板的版本。
下面的代码是我们的包含`typedef`版本的`ListNode`和`LList`类头文件：

```C++
// ListNode.h
#ifndef _LISTNODE_H
#define _LISTNODE_H

#include <cstdlib>
typedef int ItemType;

class ListNode {
  friend class LList;
public:
  ListNode(ItemType item, ListNode* link = NULL);
private:
  ItemType item_;
  ListNode *link_;
};
inline ListNode::ListNode(ItemType item, ListNode *link)
{
  item_ = item;
  link_ = link;
}
#endif // _LISTNODE_H
```

```C++
// LList.h
#ifndef _LLIST_H
#define _LLIST_H

#include "ListNode.h"

class LList {
public:
  LList();
  LList(const LList& source);
  ~LList();

  LList& operator=(const LList& source);
  int size() { return size_; }
  void append(ItemType x);
  void insert(size_t i, ItemType x);
  ItemType pop(int i=-1);
  ItemType& operator[](size_t position);

private:
  // methods
  void copy(const LList &source);
  void dealloc();
  ListNode* _find(size_t position);
  ItemType _delete(size_t position);

  // data elements
  ListNode *head_;
  int size_;
};

#endif // _LLIST_H
```

接下来，让我们看看`LList`类的C++的实现文件。
我们将从和Python版本类似的方法开始。
在研究了这些方法之后，我们将开始研究其他那些需要正确处理内存的方法。
首先，我们的LList.cpp文件需要包含类定义的LList.h头文件。
接下来，除了需要声明变量、使用指针、从列表里删除节点的时候需要释放内存、以及一些Python和C++之间的其他语法差异之外，`LList`方法和相应的Python版本的方法应该是相同的。
下面的例子里，我们都会包含Python版本的代码，以及和它对应的C++版本的构造函数、`_find`、`_delete`、`insert`以及`pop`方法，从而能够让你可以更方便的比较它们。
在Python版本里，我们删除了一些`assert`语句、文档字符串、以及注释，从而保持代码更短。

构造函数的目的是初始化实例变量。
我们将对指针变量使用`NULL`值来表示它没有指向任何有效节点。
因为我们只有两个实例变量来初始化`LList`类，因此默认构造函数会非常的简单：

```Python
    def __init__(self):
        self.head = None
        self.size = 0
```

```C++
// LList.cpp
#include "LList.h"

LList::LList()
{
  head_ = NULL;
  size_ = 0;
}
```

除了很明显的语法差异之外，`_find`方法的代码是基本相同对：

```Python
    def _find(self, position):

        node = self.head
        for i in range(position):
            node = node.link
        return node
```

```C++
ListNode* LList::_find(size_t position)
{
  ListNode *node = head_;
  size_t i;

  for (i = 0; i < position; i++) {
    node = node->link_;
  }
  return node;
}
```

`_delete`方法会有一些差异，这是因为我们需要从列表里删除一个元素。
在C++的版本里，我们必须要使用`delete`语句来释放需要删除的`ListNode`实例相应的内存：

```Python
    def _delete(self, position):
        if position == 0:
            item = self.head.item
            self.head = self.head.link
        else:
            node = self._find(position - 1)
            item = node.link.item
        node.link = node.link.link
        self.size -= 1
        return item
```

```C++
ItemType LList::_delete(size_t position)
{
  ListNode *node, *dnode;
  ItemType item;

  if (position == 0) {
    dnode = head_;
    head_ = head_->link_;
    item = dnode->item_;
    delete dnode;
  }
  else {
    node = _find(position - 1);
    if (node != NULL) {
      dnode = node->link_;
      node->link_ = dnode->link_;
      item = dnode->item_;
      delete dnode;
    }
  }
  size_ -= 1;
  return item;
}
```

Python里其实也有一个叫做`del`语句，它可以被用来从可访问的名称的字典里删除标识符来在当前名称空间里删除名称（如果你需要回顾一下关于Python的名称字典的相关知识的话，可以去参阅第4.2节）。
就像你知道的那样，当你删除一个名称的时候，名称所引用的对象的引用计数将会减1。
当对象的引用计数减少到零的时候，Python就会去释放这个对象的内存。
下面这个Python版本的代码显示了`del`语句的用法：

```Python
    def _delete(self, position):
        if position == 0:
            dnode = self.head
            self.head = self.head.link
            x = dnode.item
            del dnode # not necessary in Python
        else:
            node = self._find(position - 1)
            if node is not None:
                dnode = node.link
                node.link = dnode.link
                x = dnode.item
                del dnode # not necessary in Python
        self.size -= 1
        return x
```

就像注释里说的那样，`del`语句并不是必须的；
但是，用了它也不会造成任何的问题。
除非在调用`_delete`方法的函数/方法的调用链里还有另一个Python的名称引用着名称`dnode`，不然的话它应该是唯一一个引用这个对象的名称。
这是因为：
只要没有其他的名称在引用这个对象的话，那么`del`语句将会把`ListNode`对象的引用计数减少到零，然后Python会释放这个对象；
或者，如果不用`del`语句的话，那么在函数结束并且从本地名称字典中删除`dnode`名称的时候，引用计数也将被减少到零。
在我们最早的Python版本里，被删除的`ListNode`对象的引用计数会在语句`self.head = self.head.link`或者语句`node.link = node.link.link`之后减少，所以原始版本和带有`del`语句的新版本具有相同的最终结果。

虽然Python的`del`和C++的`delete`关键字在这个例子里看起来完成了相似的工作，而且工作方式非常的类似，但它们原理上并不会执行相同的操作。
Python的`del`语句是从当前命名空间里删除一个名称，而C++的`delete`语句则会去释放内存。
在这个例子里，我们必须要用C++的`delete`语句，不然的话你的代码将会出现内存泄漏。
应该注意到的一个关键概念是：
`delete`语句会为对象释放内存，而不管是否有其他的指针变量去指向同一个对象。
如果还有任何其他的指针指向这个对象的话，那么在执行`delete`语句之后，解引用这些指针就会产生错误。
我们在第10.5.3节里已经讨论过这个问题。

Python程序员在学习C++的时候经常犯的一个错误是：
会忘记在想要分配节点的时候使用`new`关键字（也就是，他们会写成`node-> link_ = ListNode(x)`）。
如果忘记`new`语句的话，编译器将会生成错误。
当你想要分配一个节点的时候，就需要使用`new`语句，而当你想要释放一个节点的时候，就应该使用`delete`语句。
Python里的内存分配是类似的：
当你想要分配节点的时候，只需要调用构造函数（例如，`node = ListNode(x)`）就行了。
接下来，我们可以看到，`append`和`insert`方法在Python里和C++里是基本相同的：

```Python
def append(self, x):

    newNode = ListNode(x)
    if self.head is not None:
        node = self._find(self.size - 1)
        node.link = newNode
    else:
        self.head = newNode
    self.size += 1
```

```C++
void LList::append(ItemType x)
{
  ListNode *node, *newNode = new ListNode(x);

  if (head_ != NULL) {
    node = _find(size_ - 1);
    node->link_ = newNode;
  }
  else {
    head_ = newNode;
  }
  size_ += 1;
}
```

```Python
    def insert(self, i, x):
        if i == 0:
            self.head = ListNode(x, self.head)
        else:
            node = self._find(i - 1)
            node.link = ListNode(x, node.link)
        self.size += 1
```

```C++
void LList::insert(size_t i, ItemType x)
{
  ListNode *node;

  if (i == 0) {
    head_ = new ListNode(x, head_);
  }
  else {
    node = _find(i - 1);
    node->link_ = new ListNode(x, node->link_);
  }
  size_ += 1;
}
```

`pop`方法会有些不同，因为在Python里，我们会通过使用默认的参数值`None`来表示我们想要删除的列表里的最后一项元素。
但是，因为C++没有动态类型以及`None`这样的特殊值，我们必须要使用一个特定的整数来表示默认值。
在这里，我们选择用数字`-1`来表示我们将要删除最后一项。
除了这个区别之外，`pop`方法在两个语言里是相同的。
当然，在这里我们还是忽略了测试参数`i`是在`0`到`size_ - 1`之间：

```Python
    def pop(self, i = None):

        if i is None:
            i = self.size - 1

        return self._delete(i)
```

```C++
ItemType LList::pop(int i)
{
  if (i == -1) {
    i = size_ - 1;
  }
  return _delete(i);
}
```

为了能够像我们在使用Python序列和C++数组那样，使用方括号来访问列表的元素，我们需要使用运算符重载。
下面这个例子还展示了在C++里应该使用的引用返回类型。
这能够让我们只需要在一个方法里就可以编写出Python的`__getitem__`和`__setitem__`方法。
在这里我们只包含了Python的`__getitem__`方法来进行比较：

```Python
    def __getitem__(self, position):

        node = self._find(position)
        return node.item
```

```C++
ItemType& LList::operator[](size_t position)
{
  ListNode *node;

  node = _find(position);
  return node->item_;
}
```

下一个例子我们展示了这个方法的用法。
如果返回类型不是引用的话，那么语句`x = a[1]`是可以起作用的，但是因为没有返回引用，那么语句`a[2] = 40`将不能正常工作。
和Python一样，赋值语句左侧的元素必须是一个可以用来存储值的地方。
计算机科学里对这种地方所使用的技术术语是*左值*（*l-value*）。
同时，赋值语句右侧的元素可以是变量、常量或者是表达式。
通过返回引用，我们相当于是返回了第二个`ListNode`里的`item_`的内存位置。
当在赋值运算符的左侧使用返回的引用类型的时候，赋值语句的结果（语句右侧的表达式的值）将会被存储在由方法或者函数返回的变量的内存位置里去。
当在右侧使用引用返回类型或者把它作为表达式的一部分的时候，将会使用实际数据值而不是返回的变量的内存地址。
我们曾经在第10.4.5节里讨论过了返回引用的一些常见问题。

```C++
#include "LList.h"

int main()
{
  LList a;
  int x;

  a.append(10);
  a.append(20);
  a.append(30);

  // both of these methods cause the operator[] method to be called
  x = a[1]; // returns 20 which is stored in x
  a[2] = 40; // changes the 30 at the last ListNode’s item to 40

  return 0;
}
```

我们现在再去看看那些需要处理链表的动态内存的其他方法。
由于Python会自动地处理内存释放，因此在Python的代码里没有相应的代码来和这些方法的C++版本进行比较。
复制构造函数被用来生成`LList`对象的深拷贝，它需要为它正在复制的原始源`LList`里的每一个现有的`ListNode`实例都创建一个新的`ListNode`实例。
我们提到过，当按值传递这个类型的对象的时候，将会调用复制构造函数。
同样的，因为我们也需要在赋值运算符里复制整个列表，所以我们会编写一个能够让这两个方法都可以调用的`copy`方法。
我们会通过遍历源列表里的所有`ListNode`对象，并且在这个循环里，为新列表创建一系列新的`ListNode`对象，并恰当地连接`link_`链接，从而创建一个深拷贝。
要更简单地编写这个`copy`方法的话，我们还可以通过迭代所有元素并且使用`append`方法将它们添加到新的`LList`对象里去。
但是如果没有`tail_`实例变量来代表列表尾部的话，这样做的效率是不高的。

我们之前说过，在Python里是不用编写赋值运算符的，这是因为Python里的赋值只会把另一个名称绑定到同一个对象上（也就是，使这个名称成为对同一个对象的引用）。
C++的赋值运算符则需要首先去释放掉存储元素的现有的`ListNode`对象，不然的话我们的代码就会发生内存泄漏。
我们将会调用`dealloc`方法，来释放现有的`ListNode`对象。
下面的例子将会展现这些内容：

```C++
LList::LList(const LList& source)
{
  copy(source);
}

void LList::copy(const LList &source)
{
  ListNode *snode, *node;

  snode = source.head_;
  if (snode) {
    node = head_ = new ListNode(snode->item_);
    snode = snode->link_;
  }
  else {
    head_ = NULL;
  }
  while (snode) {
    node->link_ = new ListNode(snode->item_);
    node = node->link_;
    snode = snode->link_;
  }
  size_ = source.size_;
}

LList& LList::operator=(const LList& source)
{
  if (this != &source) {
    dealloc();
    copy(source);
  }
  return *this;
}
```

类的析构函数需要释放掉当前列表里的每个`ListNode`对象，这是因为这些对象是还没有被释放掉的`ListNode`实例。
这样做能够确保每当`LList`对象被释放的时候，任何动态分配的内存都会被释放。
提醒一下，析构函数会在非指针实例超出作用域，或者是对指向`LList`对象的指针调用了`delete`语句之后，被自动调用。
由于我们也会在赋值运算符里去释放`ListNode`实例，因此我们会用一个`dealloc`方法来包含这些逻辑，并让赋值运算符和析构函数都去调用它。
我们可以通过重复地调用`pop`方法或者是使用`_delete`方法来为我们的`dealloc`方法编写代码，因为它们都会从列表里一次删除一个元素。
但考虑到效率因素，我们将直接实现相关的逻辑。
代码将会遍历每一个`ListNode`并且使用`delete`语句来释放它的内存。
要注意的是，在释放当前`ListNode`之前，我们必须前进到下一个`ListNode`去。
因为一旦我们释放了一个`ListNode`，我们就再也不能去访问它了，也就会导致我们没有办法找到下一个节点。
因为我们在执行列表操作的时候，会经常需要访问当前节点和这个节点之前的那个节点，因此通过两个指针来跟踪——一个用于当前节点，一个用于前一个节点——是单链式结构里常见的使用技术。

```C++
LList::~LList()
{
  dealloc();
}

void LList::dealloc()
{
  ListNode *node, *dnode;

  node = head_;
  while (node) {
    dnode = node;
    node = node->link_;
    delete dnode;
  }
}
```

当你查看这些方法的代码的时候，你可能会想要知道我们是如何确定每个`new`语句都有一个相应的`delete`语句，从而释放掉由`new`语句分配的`ListNode`对象的内存的。
我们将会使用下面这个简单的程序来讨论它。
在阅读下面这段代码之后的段落前，先尝试看你能不能去确定这段代码一共执行了多少个`new`和`delete`语句，以及它们分别是在什么时候被执行的：

```C++
#include "LList.h"
int main()
{
  LList b, c;
  int x;

  b.append(1);
  b.append(2);
  b.append(3);
  c.append(4);
  c.append(5);
  c = b;
  x = b.pop();
}
```

每个变量都会调用一次构造函数，但这不会去执行任何`new`或`delete`语句。
对`append`方法的五次调用将会导致执行五次`new`语句。
`c = b`语句会执行两次`delete`语句，这是因为`operator=`会用调用`dealloc`方法，而且实例`c`会去删除掉包含`4`和`5`的`ListNode`对象。
然后这一步会调用`copy`方法，来执行三个`new`语句，所以到目前为止，我们一共由六个`ListNode`对象：
变量`b`有三个`ListNode`对象，包含数字`1`，`2`和`3`，变量`c`也有三个`ListNode`对象，包含`1`，`2`和`3`。
语句`x = b.pop()`会执行`delete`语句来释放`LList`的对象`b`里包含`3`的`ListNode`对象。
当函数结束的时候，`LList`的析构函数会自动被调用两次：一次是给变量`b`的，一次是给变量`c`的。
当调用`b`的析构函数的时候，它会调用`dealloc`方法来删除包含`1`和`2`的`ListNode`对象。
当调用`c`的析构函数的时候，它会删除包含`1`，`2`和`3`的三个`ListNode`对象。

> * `c = b`之前
>
>   | 内存地址 | 变量名称 | 数据的值 |
>   | ----- | ----- | ----- |
>   | 1000 | b.head | `2000`|
>   | 1004 | b.size | `3`|
>   | 1008 | c.head | `2100`|
>   | 1012 | c.size | `2`|
>
>
>
>          item_ link_     item_ link_     item_ link_
>
>            1   2016   ->   2   2048   ->   3   NULL
>
>              2000            2016            2045
>
>          item_ link_     item_ link_
>
>            4   2024   ->   5   NULL
>
>              2100            2024
>
>
> * `x = b.pop();`之后
>
>   | 内存地址 | 变量名称 | 数据的值 |
>   | ----- | ----- | ----- |
>   | 1000 | b.head | `2000`|
>   | 1004 | b.size | `2`|
>   | 1008 | c.head | `2200`|
>   | 1012 | c.size | `3`|
>
>          item_ link_     item_ link_
>
>            1   2016   ->   2   2048
>
>              2000            2016
>
>          item_ link_     item_ link_     item_ link_
>
>            1   2148   ->   2   2024   ->   3   NULL
>
>              2200            2148            2024

图11.1：`LList`例子的图形表示

图11.1通过图形向我们展示了上面那个例子的两个时间点的执行情况。
上面部分展示的是语句`c = b`之前的情况，下面部分则显示了在程序结束之后的情况。
在这里我们用从`1000`开始的内存地址来作为堆栈动态变量，同时动态堆从`2000`开始。
我们使用的内存地址可以是在内存里的任何位置。
从这个例子可以看到，我们在`operator=`方法里调用了`dealloc`方法去释放了一些内存之后，又重用了一些内存地址。
就像之前提到过的那样，实际使用的内存地址会有所不同，内存地址可能会在被释放之后立即被重复使用，也可能并不会被立即使用。

我们通过向列表里添加元素的方法来分配`ListNode`对象，以及从列表里删除元素的方法去释放`ListNode`对象。
因此，只要所有的方法都是正确的实现，`ListNode`对象将始终保持链接在一起。
当`LList`实例的变量超出作用域的时候，`LList`里的任何剩余的`ListNode`对象都会被释放。
同时我们也必须正确地去实现赋值运算符、复制构造函数以及析构函数，从而确保在使用这些方法的时候，能够正确地分配和释放所有的`ListNode`对象。
我们也提到过，还有另一种选择是把赋值运算符和复制构造函数都声明为私有方法，并且不去实现它们。
这将会阻止编译器为它们生成任何默认代码，于是，当有其他代码尝试调用它们的时候，编译器就会生成语法错误。

在什么时候指针会调用析构函数？作为对这个问题的提醒，我们将通过下面这个例子来讨论析构函数是在什么时候调用的：

```C++
LList* f()
{
  LList b;
  LList *c;

  b.append(1);
  c = new LList;
  c->append(2);
  return c; // the function returns a pointer to an LList instance
  // destructor is automatically called for b when the function ends
}

int main()
{
  LList *p;

  p = f();
  p->append(3);
  delete p; // delete statement causes destructor to be called
}
```

变量`b`的析构函数会在函数`f`的末尾被调用，这是因为`b`只是一个局部变量，它的生命周期在函数完成执行的时候就结束了。
这也代表着，包含值`1`的`ListNode`对象也会被释放。
变量`c`在函数`f`的末尾的时候超出了作用域，但是由于它是一个指针变量，因此只会释放这个存储`LList`对象地址的四个字节。
包含值`2`的`ListNode`的`LList`对象将会继续存在。
而且，当函数结束的时候，并不会为变量`c`调用析构函数。
如果我们想在函数`f`里调用析构函数的话，我们就需要在函数的代码体里添加语句`delete c`来强制执行它。
函数`f`将会返回由`c = new LList`语句创建的`LList`对象。
然后`main`函数会把整数`3`添加到这个列表里去。
而当执行`delete p`语句的时候，就会调用`LList`的析构函数。
这个时候，就会把由函数`f`里的`c = new LList`语句所创建的`LList`对象释放掉。
析构函数也同时会释放掉它所包含的两个`ListNode`对象。
当函数完成之后，指针`p`的四个字节也将会被自动释放，所有的本地堆栈动态变量的字节也是同样的操作。

## C++链接的动态内存错误

我们在10.5节里讨论过关于动态内存的相关问题，也同样适用于使用动态内存的链式结构，因此再去看一看这部分内容是一个很好的主意。
如果你有一个`ListNode`变量`*node`的话，你需要记得`node->item_`和`node->link_`都是解引用指针。
因此，如果`node`没有保存一个关于`ListNode`的有效地址的话，那么这些语句都是不正确的，可能会导致程序崩溃或者是产生不正确的结果。
如果我们在连接`ListNode`实例的时候错误地更新了`link_`实例变量的话，那么我们就会丢失掉对列表的一部分的访问权限。
下面这段代码是一个把我们的`insert`方法改成这种错误的例子

```C++
// this code is incorrect
void LList::insert(size_t i, ItemType x)
{
  ListNode *node;

  if (i == 0) {
    head_ = new ListNode(x, head_);
  }
  else {
    node = _find(i - 1);
    node->link_ = new ListNode(x); // incorrect
  }
  size_ += 1;
}
```

基于这段代码，新创建的`ListNode`实例的`link_`实例变量将会被设置为`NULL`，因为这是构造函数的第二个参数的默认值。
而这就会无法访问在新插入的节点之后的那些元素，也就是断开了我们的列表。
在C++里，我们将没办法再去访问列表的一部分从而会导致内存泄漏，因此完整地测试C++代码，从而确保没有内存错误是非常重要的。
而在Python里，类似的代码会断开我们的列表，但并不会有内存泄漏，这是因为Python使用了引用计数来进行自己的内存释放管理。

## 章节总结

这一章我们介绍了如何使用指针和动态内存在C++里实现链式结构的相关问题。
我们在这里总结了一些重要部分。

* 由于Python的引用和C++的指针本质上是相同的，因此链式结构的代码在Python和C++里也是类似的。
不同的是，在C++里，必须在不再需要链接节点的时候去显式地释放它们。

* 链式结构类包含着它自己类型的指针（例如，我们的`ListNode`类里就包含一个实例变量，它是一个`ListNode`类型的指针）。

* 链式结构类通常会将用这个链式结构的类声明为友元，从而方便它去直接访问链式结构里的数据和链接。

* 使用动态内存的类必须要实现析构函数，这个析构函数会在实例超出作用域的时候释放掉类的实例里仍然在使用的任何动态内存。
动态内存类同时还必须要编写复制构造函数和`operator=`方法来去生成动态内存的深拷贝，或者也可以把这些方法声明为私有的，从而不能去调用它们。

## 练习

**判断题**

1. 如果要声明一个指向`ListNode`类型的指针，就必须要使用`new`运算符来为指针指定一个有效地址。

2. 如果类`A`声明了类`B`是它的友元，那么类`B`的方法可以访问类`A`的私有方法和数据。

3. 如果类`A`声明了类`B`是它的友元，那么类`A`的方法可以访问类`B`的私有方法和数据。

4. 要创建`LList`的副本，我们必须为它所包含的每个`ListNode`实例都创建一个单独的副本。

5. `ListNode`的`item_`实例变量可以是一个指针。

**选择题**

1. 列表的链式实现

    a) 总是需要比这个列表的数组版本更多的内存。

    b) 总是需要比这个列表的数组版本更少的内存。

    c) 可能需要比列表的数组版本更少的内存，取决于具体的数据类型（两者都存储相同的数据类型的情况下）。

    d) 可能需要比列表的数组版本更多的内存，取决于具体的数据类型（两者都存储相同的数据类型的情况下）。

2. 具有$n$个元素的`LList`的`copy`方法的时间复杂度是

    a) $Θ(1)$.

    b) $Θ(\log_2 n)$.

    c) $Θ(n)$.

    d) $Θ(n^2)$.

3. 具有$n$个元素的`LList`的复制方法的最好情况下的时间复杂度是

    a) $Θ(1)$.

    b) $Θ(\log_2 n)$.

    c) $Θ(n)$.

    d) $Θ(n^2)$.

4. 具有$n$个元素的`LList`的析构函数的时间复杂度是

    a) $Θ(1)$.

    b) $Θ(\log_2 n)$.

    c) $Θ(n)$.

    d) $Θ(n^2)$.

5. 具有$n$个元素的`LList`的析构函数的最好情况下的时间复杂度是

    a) $Θ(1)$.

    b) $Θ(\log_2 n)$.

    c) $Θ(n)$.

    d) $Θ(n^2)$.

**简答题**

1. 在上一章里的动态数组`List`类对于有`n`个整数的列表来说需要多少的内存？

2. 这一章里的`LList`类对于有`n`个整数的列表来说需要多少的内存？

3. 如果需要一个存储整数的列表的话，应该如何确定程序应该使用动态数组实现的`List`类还是链式实现的`LList`类？

4. 如果`ListNode`的`item_`实例变量是指向动态分配的内存的指针，那么会有哪些潜在的问题？

5. 为什么在类里面包含一个指向它自己类型的实例的指针是合法的，但包含自己类型的实例就是非法的（换句话说，为什么`ListNode`类可以包含一个指向`ListNode`的指针，但不能包含一个`ListNode`的实例）？

**编程练习**

1. 通过添加`tail_`实例变量和一个外部迭代器类来完成列表的链式实现。
之后编写代码来测试所有的列表的方法。
这里并没有自动迭代，因此你需要编写一个外部迭代器，从而能够让下面这样的代码去调用它：

    ```C++
    LList l;
    LListIterator li;
    int x;

    li.init(l);
    while (li.next(x)) {
      cout << x << endl;
    }
    ```

2. 编写这样一个列表的链式实现，其中每个列表的节点元素都同时包含着指向列表里的上一个和下一个元素的指针。

3. C++也支持继承。
继承的基本语法是：

    ```C++
    class CursorLList : public LList {

    };
    ```

    如果要在C++里使用继承的话，那么你还需要学习许多各种各样的知识。
    但是对于这个练习来说，你只需要知道在派生类的构造函数被执行之前会自动调用基类的构造函数。
    当派生类的析构函数完成之后，将自动调用基类的析构函数。
    按照4.6.2节里的描述来创建一个C++的派生出来的游标列表以及游标类。

4. 用C++实现一个基于节点的二叉搜索树。
为这个类提供复制构造函数、赋值运算符以及析构函数。
