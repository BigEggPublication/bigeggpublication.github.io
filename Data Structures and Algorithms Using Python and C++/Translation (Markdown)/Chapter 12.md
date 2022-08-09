# C++模板

目标

* 了解为什么编译代码的时候会需要知道所操作的变量的数据类型。

* 了解如何使用模板来编写函数。

* 简要介绍C++的标准模板库（STL）。

* 学习如何使用模板来编写类。

## 简介

我们已经了解过了关于定义C++变量的时候必须要有一个确定的类型，从而可以让编译器去生成操作这个变量所需要的特定的机器指令。
在Python里可以用动态类型的原因是因为，解释器会在把代码转换为机器语言之前一直等待，直到准备完所需要执行的Python语句。
这就让我们在Python里可以编写适用于任何类型的泛型函数和类。
因此，只要一个对象有我们可以尝试使用的属性的话，代码就可以正常工作。
一些程序员把这种类型称为*鸭子类型*（*duck typing*，简单来说是，如果一个东西像鸭子一样走路，像鸭子一样呱呱叫，那么它就是一只鸭子）。
在这一章里，我们将学习一种被称为*模板*（*templates*）的新的C++的机制，它能够让我们用C++来编写类似于Python的鸭子类型的功能的函数和类。

在Python里，我们可以编写一个自己的`maximum`函数（尽管没有必要，因为Python内置了`max`和`min`函数），这个函数会适用于所有的支持大于运算符的数据类型（也就是所有的内置类型，以及实现了`__gt__`的类）：

```Python
def maximum(a, b):
    if a > b:
        return a
    else:
        return b
```

在C++里，所有的参数和变量都有一个确定了的类型，而且这个类型在变量的生命周期内是不能修改的（除非使用了继承）。
这也就意味着，我们必须为我们想要使用`maximum`函数的每个类型编写一个单独的`maximum`函数，就像下面这个例子里这样：

```C++
int maximum_int(int a, int b)
{
  if (a > b) {
    return a;
  }
  else {
    return b;
  }
}

double maximum_double(double a, double b)
{
  if (a > b) {
    return a;
  }
  else {
    return b;
  }
}
```

这两个C++函数里的代码是完全相同的，这一点你应该能够从适用于任何支持大于运算符的类型的Python代码而预测到。
我们在第11章里看到过了`typedef`语句的使用，它可以让我们更容易地编写支持多种类型的代码；
但是，由于生成的机器语言代码还是需要特定于某个类型，即使用了`typedef`语句，也并不允许能够把相同的代码用于多种类型。
C++的模板将能够让我们只编写一个版本的代码，之后编译器会根据需要自动为每种数据类型生成不同版本的代码。
模板能够让我们只编写一个`maximum`函数，这个函数将能够适用于所有支持大于运算符的类型。
除此之外，模板还能让我们编写容器类，比如说：可以包含任何类型的列表、堆栈以及队列。
我们将在这一章的其余部分里介绍和学习模板的语法以及它所涉及的一些问题。

## 模板方法

模板函数的语法是：
在函数名称前面，有关键字`template`，以及它后面跟着的`<typename Item>`。
当然你也可以用任何合法标识符而不只是`Item`，但C++程序员们通常还是会使用`Item`或者是`Type`。
`Item`名称被用来代表任何有效类型的占位符。
你也可以用关键字`class`而不是关键字`typename`（`template <class Item>`）。
这两者之间没有任何的语义差异，但是使用`class`可能会让人觉得它只适用于类对象而不是内置的原始数据类型，虽然情况并不是这样。
但是，无论使用哪个关键字，在调用模板函数的时候，使用的实际数据类型都不需要是一个类。
整个类型可以是内置类型、数组或者是类。
下面整个例子向我们展示了模板版本的`maximum`函数：

```C++
// maximum.cpp
#include <iostream>
using namespace std;

template <typename Item>
Item maximum(Item a, Item b)
{
  if (a > b) {
    return a;
  }
  else {
    return b;
  }
}

int main()
{
  int a = 3, b = 4;
  double x = 5.5, y = 2.0;

  cout << maximum(a, b) << endl;
  cout << maximum(x, y) << endl;
  return 0;
}
```

在这个例子里，C++编译器会生成两个版本的`maximum`函数。
一个被用于`int`类型，会在调用`maximum(a，b)`的时候使用；
另一个被用于`double`类型，会在调用`maximum(x，y)`的时候使用。
由于用来比较两个整数和两个双精度浮点数的机器语言的指令不同，因此需要不同版本的代码。
而且，由于我们的`Rational`类重载了大于运算符，我们还可以把这个模板函数与这个类一起使用。
很明显，比较两个整数和两个`Rational`对象的代码不会是一模一样的。
比较两个整数只需要一条机器语言指令就足够了，而比较两个`Rational`对象需要执行`Rational`类的`operator>`的机器代码。

如果不调用模板函数的话，C++编译器不会生成任何代码。
根据你的编译器，它可能会也可能不会捕获没有被调用的模板函数里的语法错误。
因此，测试所有的模板功能是非常重要的。
术语*实例化*（*instantiate*）就被用来表示编译器为特定类型生成代码。
在上面的那个例子里，编译器会实例化`int`版本和`double`版本的`maximum`函数。

由于在遇到使用某个类型去调用模板函数的代码之前，编译器是不会为具有特定类型的模板函数生成代码的。
因此编译器在编译调用这个函数的文件的时候，就需要访问模板函数的源代码。
这是由于编译器在遇到函数调用之前是不知道需要生成的机器语言指令所对应的数据类型的。
也就是说，在我们有了类型之后，我们还需要模板函数的源代码来为这个数据类型生成相应的机器指令。
如果所有的代码内容都像上面那个例子里一样，是放在一个文件里的话，那么这不会有什么问题。
然而，如果要在多个C++源文件里访问模板函数，那就需要把它写到每个源文件包含的头文件里去。

`Type`模板参数可以是任何一种数据类型，但在方法的代码的同一个实例里，是不能用两种不同的类型的。
还是用上面那个例子来解释，我们不能像`maximum(x，b)`这样来使用函数，这是因为`x`是`double`，但是`b`是`int`。
C++也同样支持多个模板类型。
但是，编写`maximum`函数去支持多个模板类型是没有意义的。
下面这个例子则很好的展示了具有多个模板参数类型的函数的语法。
在这个例子里，它会使用两个模板参数，但是，至于你可以使用的模板参数数量是没有特定限制的。

```C++
template <typename T1, typename T2>
T1 maximum(T1 a, T2 b)
{
  if (a > b) {
    return a;
  }
  else {
    return b;
  }
}
```

如果我们执行函数`maximum(x，b)`的话，那么我们的C++编译器（g++的第4版）编译代码的时候不会有任何的警告或者是错误。
参数`T1`是`double`，`T2`是`int`，所以返回的类型是`double`。
如果需要的话，编译器甚至会以静默方式把`int`转换为`double`类型。
如果我们执行函数`maximum(b，x)`的话，大多数编译器都会产生警告，但是仍然会生成可以被执行的机器代码。
下面的输出展示了g++编译器所生成的警告。
和之前提到过的一样，即使编译器仍然可以生成可执行的程序，你也不应该忽略掉编译器产生的警告。

```
maximum.cpp: In function ‘T1 maximum(T1, T2) [with T1 = int, T2 = double]’:
maximum.cpp:35: instantiated from here
maximum.cpp:23: warning: converting to ’int’ from ’double’
```

我们提到过，编译器会在调用函数的时候，对每一种数据类型都创建一个模板函数的单独副本。
所以，为了更好的编程效率，我们应该让编译器去编写一个函数的多个数据类型版本，而不是让程序员去编写每一个版本。
而且，就像上面这个例子里提到的那样，如果你写的代码和编译器生成的代码是一样的话，你还是会遇到警告以及错误。

## 模板类

前面提到过，你还可以使用模板来编写类，从而可以编写一个可容纳任何C++内置数据类型或者是用户自定义的类的容器类。
C++还提供了一个被称为*标准模板库*（*Standard Template Library*，通常缩写为*STL*）的库，它为许多常用的数据结构以及操作这些数据结构的算法提供了模板类。
标准模板库相当复杂，并且已经有了介绍它的书籍，因此我们将只设计STL里的一个类以及一些简单例子来介绍如何使用它。
之后，我们也会向你展示如何编写自己的模板类。

### 标准模板库的`vector`类

STL里的其中一个很简单的类是`vector`类。
它提供的功能类似于我们在这本书的前面所介绍、开发的动态数组类。
在`vector`类的内部，它是通过动态数组实现的，因此它的使用和效率都类似于我们开发的C++版本的动态数组类，也和内置的Python列表差不多。
`vector`类是在`<vector>`头文件里被定义的，而且也在`std`命名空间里，因此我们需要通过`std::vector`来使用它，也可以在我们的文件里添加`using std::vector`或`namespace std`来使用它。
当然，如果你在定义一个自己会使用的`vector`类，或者是正在编写一个返回值或者参数是`vector`类的函数，那么就不能在你的头文件里使用`using namespace std`或`using std::vector`语句了（如果你需要复习为什么不能这样做的话，可以参阅第8.13节）。
在这种情况下，你应该在头文件里使用它的全名`std::vector`来引用它。
当然，你可以像在我们的例子里做的那样，在实现文件里添加`using namespace std`语句。

声明`vector`类的实例的时候，必须指定`vector`将会在它的动态数组里包含的数据类型。
一个简单例子是：`std::vector <int> iv;`。
你可以在同一个文件里声明两个具有不同类型的`vector`，像下面这个例子这样：

```C++
// vec1.cpp
#include <iostream>
#include <vector>
using namespace std;

int main()
{
  vector<int> iv;
  vector<double> dv;
  int i;

  for (i = 0; i < 10; ++i) {
    iv.push_back(i);
    dv.push_back(i + 0.5);
  }
  for (i = 0; i < 10; ++i) {
    cout << iv[i] << " " << dv[i] << endl;
  }
  return 0;
}
```

这个例子还展示了`vector`类支持一个叫做`push_back`的方法（类似于Python列表的`append`方法）。
`push_back`方法接受一个参数，这个参数和实例化的`vector`的类型是一样的。
`vector`类还重载了括号运算符，因此可以让我们使用方括号数组表示法来访问这个向量里的每一个元素。

就像上面那个例子里展示的那样，`vector`类也支持默认构造函数。
除此之外，它还有一个带有一个或两个默认参数的构造函数。
默认构造函数会生成一个没有元素的`vector`实例。
如果只指定一个参数的话，这个参数应该是一个整数，它会指定需要创建的初始动态数组的大小。
第二个默认参数是用来初始化动态数组里的每一个元素的默认值，因此它的类型也应该是你`vector`所需要的类型。
下面这个例子说明了这一点：

```C++
// vec2.cpp
#include <iostream>
#include <vector>
using namespace std;

int main()
{
  // creates a vector with 5 int elements, each set to 3
  vector<int> iv(5, 3);
  // creates a vector with 5 double elements, each set to 0.0
  vector<double> dv(5);
  int i;

  for (i = 0; i < 5; ++i) {
    cout << iv[i] << " " << dv[i] << endl;
  }
}
```

如果我们指定了大小但是不去指定第二个参数的话，那么会为`vector`里的每个元素都调用默认构造函数（如果存储在`vector`里的是类的话）；
这也就是为什么我们说你应该总是为你的类提供默认构造函数的另一个原因。
对于数字类型，就像例子里的注释说的那样，`vector`里的元素将会被默认为零。

后面这个代码片段里列出了`vector`类提供的一些（但不是全部）方法的原型。
在这里，我们使用名称`Item`来指定`vector`实例所需要包含的数据类型。
C++里定义的`typedef size_type`和`unsigned int`（也就是非负整数）是一样的：

```C++
// allocates the dynamic array so the capacity of the array is n elements
void reserve(size_type n);

// appends x onto the end of the vector
void push_back(Item x);

// removes and returns the last element in the vector
Item pop_back();

// returns True if the vector has no items in it, False otherwise
bool empty() const;

// returns the number of items in the vector
size_type size() const;

// returns the largest possible size for the vector
size_type max_size() const;

// returns the size of the dynamic array (i.e., the largest number of
// elements that can be stored in the vector without resizing it)
size_type capacity() const
```

`vector`类也重载了赋值运算符。
当你把一个`vector`变量赋值给另一个变量的时候，赋值运算符右边的`vector`实例里的每个元素都会被赋值给左侧的`vector`实例里的相应位置。
而且如果需要的话，左侧的`vector`实例会调整自身的大小，从而可以让它保存右侧实例里的所有元素。

许多STL的类也提供迭代的支持。
我们将会提供一个关于迭代的简单的例子，但并不会去涵盖所有细节。
支持迭代器的STL类都会包括返回`iterator`对象的方法`begin()`和`end()`。
有些类还支持通过`rbegin()`和`rend()`方法，以相反的顺序来迭代整个容器。
下面这个例子展示了如何使用`vector`类的迭代器。

```C++
// vec3.cpp
#include <iostream>
#include <vector>
using namespace std;

int main()
{
  vector<int> iv;
  vector<int>::iterator iter;
  int i;

  for (i = 0; i < 10; ++i) {
    iv.push_back(i);
  }

  for (iter = iv.begin(); iter != iv.end(); ++iter) {
    cout << *iter << endl;
  }
  return 0;
}
```

这个例子的输出是数字`0`到`9`。
在例子里，我们声明了一个叫做`iter`的迭代器变量，这个变量可以被用来迭代包含整数的`vector`。
`vector`类的`begin()`方法用来初始化迭代器。
在`for`循环里，我们使用`end()`方法来判断迭代器是否已经处理了所有的元素，我们也使用了前缀增量运算符（`++iter`）来把迭代器移动到下一个元素。
这就是我们在之前的`for`循环例子里，也使用前缀增量运算符的原因。
在循环内部，可以使用指针的引用符号（`*iter`）来访问每一个元素。

除了`vector`模板类之外，标准模板库还提供了队列、列表、集合以及散列表的模板类实现，还有用于许多类的算法和相应的迭代器。
如果你有兴趣要了解更多的有关STL的知识，你可以去找一些专门讨论STL的详细信息的书籍。

### 用户定义的模板类

如果STL里没有定义你需要使用的数据结构，或者是你使用的是一个不支持STL的老版本的编译器的话，那么你也可以自己编写一个自己的模板类。
和非模板类一样，模板类通常也会分为两个文件：头文件和实现文件。
就像我们前面提到过的那样，模板函数在使用它之前，实际上都不会生成任何的代码。
模板类和它里面定义的方法也是这样的。
我们也提到过，编译器在编译调用这个模板函数/方法的文件的时候，还需要访问模板函数/方法的源代码。
因此，一些程序员会把这些所有的模板函数或者方法的所有代码都放在头文件里。
但是，对于非模板函数和类来说，你就不能这么做了，因为这样做了就会导致生成函数和类的多个定义。
而对于模板来说，由于它的声明实际上不会生成任何代码，因此是可以把它们包含在多个文件里的。

另一些程序员会把模板函数或方法的相关代码放在一个带有后缀名.template的文件里，然后让头文件在它的底部去包含这个.template文件。
这样做和把所有的代码都放在头文件里是一样的效果，但同时也能够让使用我们的类的程序员只能看到头文件里的模板函数以及类的接口，而不用去关心具体的实现细节。
当然，我们并不能完全地向用户隐藏我们的实现，这是因为他们的编译器需要能够访问我们的实现文件。
我们将会使用单独的.template文件来构建我们的例子。

在编写模板类的时候，类的定义以及所有方法的实现都必须表明它是一个模板。
模板方法的语法和模板函数的语法是一样的。
我们将会使用堆栈类的模板实现来展示模板类的语法：

```C++
// Stack.h
#ifndef __STACK__H__
#define __STACK__H__
#include <cstdlib> // for NULL

template <typename Item>
class Stack {

public:
  Stack();
  ~Stack();

  // const member functions
  int size() const { return size_; }
  bool top(Item &item) const;

  // modification member functions
  bool push(const Item &item);
  bool pop(Item &item);

private:
  // prevent these methods from being called
  Stack(const Stack &s);
  void operator=(const Stack &s);

  void resize();
  Item *s_;
  int size_;
  int capacity_;
};

#include "Stack.template"

#endif // _STACK_H__
```

在这里，唯一额外的语法是在类声明之前有一行`template <typename Item>`。
和模板函数一样，你也可以使用任何标识符来代替`Item`。
这个`Stack`类会使用动态数组来存储堆栈里的元素。
代码`Item *s_`声明了指向这个保存数据的动态数组的指针。
由于我们在类的声明之前使用了`template <typename Item>`，因此在这里我们需要使用`Item`作为数据类型，从而能够让它匹配上。
前面说过，我们可以在头文件的底部，包含一个有实现细节的Stack.template文件，也可以把这些模板方法的实现都放那里。
在我们的例子里，我们把复制构造函数和赋值运算符都声明成了`private`，但没有在.template文件里为它们提供是实现代码。
这也就意味着这个类不能像我们在第10.4.2节里提到过的那样去调用这些方法。

```C++
// Stack.template
template <typename Item>
Stack<Item>::Stack()
{
  s_ = NULL;
  size_ = 0;
  capacity_ = 0;
}

template <typename Item>
Stack<Item>::~Stack()
{
  delete [] s_;
}

template <typename Item>
bool Stack<Item>::top(Item &item) const
{
  if (size_ > 0) {
    item = s_[size_-1];
    return true;
  }
  else
    return false;
}

template <typename Item>
bool Stack<Item>::push(const Item &item)
{
  if (size_ == capacity_) {
    resize();
  }
  if (size_ != capacity_) {
    s_[size_] = item;
    size_++;
    return true;
  }
  else
    return false;
}

template <typename Item>
bool Stack<Item>::pop(Item &item)
{
  if (size_ > 0) {
    size_--;
    item = s_[size_];
    return true;
  }
  else
    return false;
}

template <typename Item>
void Stack<Item>::resize()
{
  Item *temp;
  int i;

  if (capacity_ == 0) {
    capacity_ = 4;
  }
  else {
    capacity_ = 2 * capacity_;
  }
  temp = new Item[capacity_];
  for (i = 0; i < size_; i++) {
    temp[i] = s_[i];
  }
  delete [] s_;
  s_ = temp;
}
```

在这个`Stack`模板类的实现里，我们为许多方法都返回了一个用来表示这个方法是否成功的布尔值。
而且，因为在C++里我们只能返回一个值，所以我们需要按引用传递从`top`和`pop`方法里返回数据。
可以看到，我们把引用参数传递给`push`方法的时候把这个参数标记成了`const`，这是因为我们并不知道这个值是一个像`int`这样的轻量级数据类型，还是一个包含了许多数据成员的类。
我们还在分配动态内存的方法里通过使用`if`语句来判断它们是否成功（比如说，`push`方法需要保证在数组里有空间，或者可以在必要的时候分配一个更大的数组，而如果这个分配过程失败了，就会返回`false`）。
这些额外的检查会让这些方法的实现比没有`if`语句的时候会稍微慢一些。
在多数情况下，你都可以在没有这些判断的情况下编写代码，这是因为分配内存一般都会成功，除非你处理的堆栈接近了计算机可以访问的内存大小（在大多数现代架构的计算机里至少为2GB的内存）。

要声明模板类的实例的话，就像我们在使用STL里的`vector`类一样，我们需要在声明里指定堆栈将会保存的数据类型。
下面这个代码片段展示了相关的语法。
为了保持简洁，这个例子不会测试堆栈的所有方法。
但是你需要记得的是，你应该测试你定义的模板类的所有方法，这是因为某些编译器不会去检查没有实例化的方法的语法错误。

```C++
// test_Stack.cpp
#include "Stack.h"

int main()
{
  Stack<int> int_stack;
  Stack<double> double_stack;

  int_stack.push(3);
  double_stack.push(4.5);
  return 0;
}
```

在这个简短的例子里，我们忽略了`push`方法的返回值。
当然，为了安全并且通过检查来确保所有的内存分配都是成功的，我们可以把它写成：

```C++
  if (!int_stack.push(3)) {
    cerr << "stack.push failed\n";
  }
  if (!double_stack.push(4.5)) {
    cerr << "stack.push failed\n";
  }
```

像这个样编写所有的检测是非常繁琐的，而且对于只会把少量元素推送到堆栈里的小程序来说，这些操作都应该是不必要的，因为这些小程序永远都不会有内存分配失败的情况发生。
但是，对于更大的、执行关键任务的程序来说，是需要检测这些值的。
在Python里，我们可能会使用异常处理来处理这些问题。
C++也支持异常处理，但它并不像Python里那样常用。
在C++里使用异常处理的时候，如果使用了动态内存分配的话，会需要非常地小心。
因为如果在可能已分配了内存的指令序列期间发生了异常，那么需要确保能够正确地去释放内存。
而且你还需要知道在产生异常之前内存分配有没有发生，这样你才可以不会去尝试释放还没有分配的那部分内存。
我们不会在这本书里介绍编写C++异常处理代码的相关细节。

## 章节总结

这一章介绍了使用C++模板函数和类的基础知识，以及怎么去编写自己的模板函数和类。

* 模板能够让你编写出可以使用多种类型的函数和类。
编译器会为所有使用过的不同类型生成对应的机器代码的单独版本。

* 除非使用了模板函数或方法，否则编译器不会生成任何代码。
这也就是说除非用了模板函数或类，不然编译器可能并不会去检查模板代码的语法错误。
因此，你应该为你编写的所有模板函数和类都进行完整的测试，从而确保它们不包含错误。

* C++提供了包含许多类和算法的标准模板库（STL）。

## 练习

**判断题**

1. 模板允许你编写一次代码并把这个代码重用到多种类型里去。

2. 编译器将会始终捕获到C++模板函数或方法里的语法错误。

3. 对于每种调用了模板函数的数据类型，编译器都会为这个函数生成一个相应的机器语言指令的单独副本。

4. 你可以将模板函数或方法实现放在实现文件（.cpp）中，链接器将正确链接代码，以便可以从其他实现文件中调用它。

5. 模板为你提供Python动态类型所具有的相同灵活性。

**选择题**

1. 编写模板函数的时候，

    a) 编译器会为所有类型生成一组机器语言指令。

    b) 编译器会为你调用了模板函数的每种类型生成一组单独的机器语言指令。

    c) 编译器会为每个内置类型和程序使用了的每一个类都生成一组单独的机器语言指令，不论这些类型有没有调用过模板函数。

    d) 当使用不同类型来调用模板函数的时候，C++运行时环境会根据需要来生成机器语言指令。

2. 使用模板而不是`typedef`语句加上剪切和粘贴代码的优点是什么？

    a) 生成的可执行程序需要较少的内存。

    b) 生成的可执行程序运行得更快。

    c) 你不用去编写尽可能多的代码，以及不用冒着在复制代码的时候出错的风险。

    d) 以上所有内容

3. 以下哪项是编写C++模板类的技巧？

    a) 你可以像往常一样编写类头文件，然后在头文件的底部包含模板方法的实现文件。

    b) 你可以像往常一样编写类的头文件，然后使用`inline`关键字来编写这些方法的实现。

    c) 你可以像往常一样编写类的头文件，然后在没有`inline`关键字的情况下编写这些方法的实现。

    d) a和b

4. 如果你的程序只用了一种数据类型来创建一个模板类的实例的话：

    a) 如果调用了所有方法，那么会比不使用模板需要的更少的内存。

    b) 如果调用了所有方法，那么会比不使用模板需要的更多的内存。

    c) 如果调用了所有方法，那么和不使用模板需要的一样的内存。

    d) 执行速度比不使用模板要慢。

5. 基于使用`vector`类的那个例子，`iter`变量对应着什么？

    a) `iv`变量的地址

    b) 数组里当前元素的地址

    c) 数组里当前元素的值

    d) 以上都不是

**简答题**

1. 如果没有运算符重载的话，能不能创建基于模板的`maximum`函数？
如果不行的话，请解释为什么；如果可以的话，请说明你将会如何去实现它。

2. 在上一章的`LList`类的基于模板的版本能不能在一个列表里包含多种类型？
解释为什么能或者为什么不能。

3. 如何确定模板类需不需要编写析构函数、复制构造函数以及赋值运算符？

4. 从模板生成的函数和方法，在执行速度上是更慢、更快、还是与没有用模板编写的相同代码相同？
为什么？

5. 能不能在编写模板代码之后，不允许使用模板代码的人查看模板代码的源代码？
（使用非模板代码的时候，用户只用去查看头文件，因为实现是已经编译了的目标文件或者是库。）
为什么可以或者为什么不能呢？

**编程练习**

1. 编写模板版本的`mergesort`（归并排序）算法，并且用多种类型对它进行测试。

2. 使用模板来实现队列，然后编写相应的代码对它进行测试。

3. 使用模板来实现`List`动态数组，然后编写相应的代码对它进行测试。

4. 使用模板来实现我们的`LList`链表，然后编写相应的代码实它来测试它。

5. 使用模板来实现二叉搜索树，然后编写相应的代码对它进行测试。
