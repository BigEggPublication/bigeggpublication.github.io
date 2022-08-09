# C++类

目标

* 编写非动态内存的C++类。

* 学习如何使用内置C++字符串类。

* 学习如何用C++读写ASCII文件。

* 学习如何在C++里像方法和函数那样重载运算符。

* 学习如何在C++里编写类的变量以及方法。

## 基本的语法和语义

在C++里使用类的原因和好处和在Python里是一样的。
类能够让我们把用来与数据进行交互的数据和方法封装到一个语法单元里。
数据的隐藏允许程序员们使用这个类而不用去担心或是去理解它的内部实现细节。
如果使用这个类的程序员只能调用与数据交互的方法而不能直接去修改里面的实例变量的话，我们还可以保证类的数据完整性（也就是，假设类的实现都是正确的，通过操作类的方法来修改这个类并不会导致类的实例里的数据不一致）。
类还可以很简单地在多个应用程序里重用这部分代码。
这一节里将会介绍C++类的基本语法和语义。
我们将在后面的章节里去探讨一些更高级的类的相关主题。

在我们开始了解C++类的语法之前，我们需要先看一下Python与C++之间的一些术语方面的差异。
Python对于类的成员的正式叫法叫做*属性*（*attributes*），属性既可以是变量，也可以是函数。
Python有一个叫做`getattr`的内置函数，它是“获取属性（get attribute）”的缩写，被用来访问类的属性。
对于一个在2.5节里定义的`Rational`类的实例`r`来说，下面这两个语句的结果是一样的：

```C++
print r.num
print getattr(r, 'num')
```

可以看到，`getattr`函数接受一个对象以及一个字符串作为参数，然后会返回这个对象的用字符串所指定的那个属性。
返回的属性可以是数据，也可以是函数或是方法。
Python还有一个叫做`hasattr`的内置函数，它也使用了相同的两个参数类型，但是它会返回`True`或`False`，来表示这个对象是否有一个叫这个名称的属性。
Python还有一个叫做`setattr`的内置函数，它接受三个参数：
一个对象、一个字符串以及一个为这个属性进行赋值的对象。
举个例子：代码`setattr(r，'num'，4)`就相当于`r.num = 4`。

我们之前使用过*实例变量*（*instance variables*）、*实例方法*（*instance methods*）或者就只是*方法*（*methods*）这些术语来表示Python的类的属性，这是因为它们是面向对象编程里更常用的术语。
C++里用*实例变量*（*instance variables*）或者*数据成员*（*data members*）这个术语来代表数据，而*实例方法*（*instance methods*）或者是被简称为*方法*（*methods*）的这个术语被用来表示函数成员。
*成员*（*members*）则是通常被用来代表所有的数据成员以及数据方法的术语，就像Python的术语*属性*（*attributes*）那样。

C++允许类的接口和类的实现分离到比Python更大的程度，但这并不是强制的。
通常来说，方法和实例变量的声明会放在带有`.h`扩展名的头文件里，而实现则会放在另一个具有相同名称的文件里，只不过这个文件会用`.C`，`.cpp`或`.cc`作为扩展名。
对于这本书里的例子，我们将会使用`.cpp`扩展名。

头文件定义了类的名字，它提供的方法，以及它的实例变量，有些时候，它还会包含一些简短的方法的实现。
实现文件会使用`#include`预处理器命令来包含头文件，再为每个方法都提供相应的实现（除非在头文件里已经编写了这个方法的实现）。
我们现在先看一个简化版的C++的`Rational`类，通过这个类，我们可以从头文件开始到相对应的实现文件，了解C++类的一些其他细节：

```C++
#ifndef _RATIONAL_H
#define _RATIONAL_H

class Rational {

public:
  // constructor
  Rational(int n = 0, int d = 1);

  // sets to n / d
  bool set(int n, int d);

  // access functions
  int num() const;
  int den() const;

  // returns decimal equivalent
  double decimal() const;

private:
  int num_, den_; // numerator and denominator
};

#endif
```

在`#ifndef`和`#define`这两个预处理器命令之后就是类的定义了。
可以看到，即使这个头文件里只包含了各个函数的原型，它也是一个*类的定义*（*class definition*），而不是*类的声明*（*class declaration*）。
对于`Rational`类的声明而言，只需要这样一行的代码`class Rational;`就够了。
类的声明会告诉编译器这个类名的存在，而类的定义则代表着除了类名之外的实例变量以及方法。
由于头文件里包含了类的定义，因此，在这里使用`#ifndef`和`#define`预处理器会比只是包含各种函数声明或原型的头文件更加重要。
如果没有这些预处理命令，当头文件被包含了两次的时候，就会有两个这个类的定义，而这是不被允许的。

和Python一样，`class`关键字后面跟着类的名称会被用作类的定义的开始。
C++里会使用左右大括号（`{`和`}`）来标记类的定义的开头和结尾。
在类的定义的右括号之后，还会使用分号。
在C++里会在右括号之后使用分号的地方有：
类的定义、结构的定义（本书没有涉及到结构相关的话题）、以及静态初始化数组这几个地方。
如果在右括号之后忘记了分号，通常会导致编译器错误。
大多数编译器都会在包含这个头文件的文件里的include语句之后那一行指出错误。
于是很多程序员会在输入左大括号之后马上输入右括号以及分号，然后再在两个大括号之间输入代码，这样他们就不会忘记这个问题了，从而能够避免这个错误。
在Python里，你通常会通过在构造函数里通过赋值实例变量来初始化它们（比如像：`self.num = 0`这样），但是在其他方法里，也是可以用同样的语法来创建其他的实例变量的。
但是在C++里，必须在类的定义里定义出所有的实例变量的名称和它的类型，你并不能够像在Python里那样在实现文件里添加新的实例变量。

C++支持强制的数据以及方法保护。
你可以通过`public`（公开），`private`（私有）以及`protected`（受保护）这些关键字来指定不同的访问权限。
就像在示例里的`Rational`类的定义一样，这些访问修饰符的后面会紧跟一个冒号，这样在遇到另一个访问修饰符之前，就会指定它后面的代码部分的所有成员的访问权限了。
从示例里的`Rational`类里我们可以看到，它所有的方法都是公开（`public`）的，而所有的实例变量都是私有（`private`）的。
只要愿意，你其实可以在类的定义里对各个访问权限的修饰符使用多次，但是，在大多数情况下，你用一次来设置访问权限就行了。

和Python没有强制保护不一样的是，任何其他的代码都可以访问所有`public`的数据成员以及方法。
我们曾经提到过，编写Python代码的时候的惯例是：只有方法才能被其他的代码访问。
当然也有一些特例，比如说用来帮助我们实现另一个类的`ListNode`类以及`TreeNode`类，它实例变量就能够直接被类的方法调用。
在C++里，声明为`private`的实例变量和方法就只能被这个类的方法访问，如果这个类之外的代码试图访问任何私有成员的话，编译器都会生成错误。
因此，在大多数情况下，实例变量都应该被声明为`private`。
在某些情况下，我们还希望类的一些方法也只能通过类的其他一些方法来调用，就像前面我们在链表的实现里用到的`_find`方法那样。
对于这些私有方法，Python里的约定是将他们的名称以一个或两个下划线开头来完成的。
而在C++里，它是通过把方法放在类的定义里的`private`或者是`protected`里来显式声明这个方法为私有的。
当你打算声明这样的方法以及实例变量的时候，你就应该把他们放`private`或者是`protected`里。
如果在这个类的外面的代码尝试访问私有方法的话，编译器就会报错。

`protected`修饰符类似于`private`修饰符，但不同的是，子类可以访问父类的受保护（`protected`）的成员。
如果除了类本身或者它的子类里的代码之外的任何代码尝试访问受保护的方法的话，编译器将报错。
就目前而言，我们只会学习`public`和`private`修饰符。

和Python一样，C++里的构造函数的目的是用来初始化实例变量。
C++的构造函数和类具有相同的名称，并且它也没有返回类型。
与Python类似的，你可以定义一个带有参数的构造函数，但最好还是去定义一个不需要任何参数的构造函数。
这个你手工编写的，或者是编译器自动生成的不带任何参数的构造函数被称为*默认构造函数*（*default constructor*）。
我们通过默认参数来允许用户使用零个、一个或者两个参数来调用Rational构造函数。
而因为这个构造函数可以在没有任何参数的情况下被调用，因此它也是默认构造函数。
当定义这个类型的变量的时候，就会自动调用C++的构造函数（也就是说，代码`Rational r1，r2;`将会为变量`r1`和`r2`分别调用构造函数）。
你并不需要也不能直接调用构造函数（也就是，在声明`Rational`类型的`r1`变量的时候，你不能像`r1.Rational()`或者是`r1.Rational(2,3)`这样来编写），你只能在定义变量的时候指定参数（比如说，你应该写成`Rational r1(2,3);`）。
因此，和Python不一样的是，你不用写像`r1 = Rational()`这样的代码来调用构造函数（在使用动态内存的时候会写一些类似的代码，这部分内容将会在第10章里讨论），恰恰相反，你可以像内置类型一样去声明具有特定类型的变量（比如说，`int i;`以及`Rational r;`）。

如果你不编写任何构造函数，C++编译器就会隐式地创建一个空的函数体的默认构造函数（它并不会出现在你的实现文件里），也就是说，编译器并不会自动地初始化任何实例变量。
而由于编译器定义的默认构造函数没有代码，因此通常我们需要编写这个构造函数来保证我们有初始化所有的实例变量。
同时，在声明对象的数组的时候也会调用默认构造函数。
后面这个变量的定义将会导致`Rational`类的构造函数被调用10次，因为对于数组中的每个元素都会调用一次：`Rational r[10]`。

一些`Rational`类的方法（比如说像是：`num()`、`den()`以及`decimal()`这些方法）在方法的声明之后有一个关键字`const`。
这种`const`关键字的用法代表着这个方法不会改变这个类的任何实例变量。
同时要注意的是，标记为`const`的方法将会只能调用其他的`const`方法（因为如果它调用了任何一个非`const`的方法，那么这个方法会修改实例变量）。
你可能还记得我们也可以使用`const`关键字来对形参进行标记。
例如，我们可以编写这样一个独立的函数`void f(const Rational r)`。
这段代码代表着：函数`f`不允许修改参数，因此，它只能调用`Rational`类里被指定为`const`的方法。
接下来，我们将用`Rational`类的实现来作为例子，从而了解实现文件里的语法细节。
为了减少空间，我们略过了注释语句、先验条件和后置条件：

```C++
#include "Rational.h"

Rational::Rational(int n, int d)
{
  set(n, d);
}

bool Rational::set(int n, int d)
{
  if (d != 0) {
    num_ = n;
    den_ = d;
    return true;
  }
  else
    return false;
}

int Rational::num() const
{
  return num_;
}

int Rational::den() const
{
  return den_;
}

double Rational::decimal() const
{
  return num_ / double(den_);
}
```

`Rational`类的实现文件包含头文件`Rational.h`，因此它可以访问每个方法的原型，而且编译器还可以检查这些实现里是否使用了正确的类型以及参数数量。
编写方法的语法是这样的顺序：
它的返回类型、空格、类的名称、两个冒号、然后是带有参数的方法。
如果方法在类的定义里有被声明为`const`，那么这个指定也必须在实现文件里被明确地标记出来。
我们可以看到，与之前说的一样，构造函数没有任何的返回类型。
方法的原型必须与在头文件里定义的返回类型、参数类型以及常量指定完全匹配。
如果他们没有完全匹配的话，你就会收到编译器错误。
同样的，和之前说的一样，我们并没有在实现文件里放任何的默认参数值（对于这个例子里的构造函数来说），默认参数只会出现在头文件里的方法原型中。

分隔类名和方法名的两个冒号被称为*作用域解析运算符*（*scope resolution operator*）。
在使用Python的时候，方法是在类里被定义的，而且我们通过缩进来表示这个方法是类的一部分。
在C++里则不一样，由于方法的实现与类的定义是分别在不同文件里进行编写的，因此类的名称以及两个冒号就被用来指示这个方法是指定类的一部分。
你也可以在实现文件里，通过不使用类的名称以及两个冒号来编写不属于任何C++的类的独立函数。
在C++的类的实现文件里编写的独立函数，通常来说只会在类的方法里使用这个函数，而不会被任何其他代码使用。

C++不像Python那样会在每个方法里使用显式的`self`参数。
由于类的定义里指定了所有的实例变量的名称，因此编译器是知道所有的实例变量的名称的，也就不需要类似于`self`这样的东西来表明这个元素属于这个类了。
调用类的方法的时候也是一样的。
你可以在没有前缀的情况下直接调用这些方法，就像我们在构造函数里调用了`set`方法那样。
但是，C++也还是包含了一个叫做`this`的指针，它对应着Python里的`self`；我们会在第10章讨论了C++的指针之后，再来讨论它。

由于在C++里并不需要明确指示你引用的是实例成员，因此许多程序员会在实例变量的名称前加上下划线或者在名称的后面加上下划线。
通过使用下划线，你就可以清楚地知道你引用的是实例变量了；
而且，C++允许你对于方法的参数使用和实例变量类似的名称也这样做。
如果一个方法有一个与实例变量同名的形参的话，那么除非使用了`this`指针，不然的话这个参数会让实例变量变得不可访问。
如果你一不小心使用了相同的名称，那么在方法里面，这个名称的所调用的都会是这个参数，而不是实例变量，因此你的实例变量不会被赋值或者是被修改。
当形参的名字和实例变量的名称一样的时候，编译器并不会生成错误。
因此，这是一个非常难以追踪的错误，这也是为什么许多程序员会在实例变量的名称里添加下划线的原因之一。
在Python里可以通过显式地使用`self`来避免这个错误。
Python程序员经常会依赖于`self`来区分参数名称和实例变量。
因此，学习C++的Python程序员经常会犯这个错误。
在C++里，需要保证所使用的形参的名称与类的实例变量是不同的。
下面这个例子展示了这个问题。
而且这个例子还展示了你其实是可以把类的定义和实现代码放在一个文件里的。
然而，除非整个程序都在一个文件里，不然的话，你通常来说都不会这样做。
这是因为，为了允许你的程序能够在其他程序里被重用，必须要有多个文件以及对类的分割，那么也就需要为各个类创建单独的头文件和实现文件：

```C++
#include <iostream>
using namespace std;

class Rational {

public:
  Rational(int num_ = 0, int den_ = 1);
  int num() const { return num_; }
  int den() const { return den_; }

private:
  int num_, den_;
};

// this is incorrect
// do not use the same name for formal parameters and instance variables
Rational::Rational(int num_, int den_)
{
  num_ = num_;
  den_ = den_;
  cout << num_ << " / " << den_ << endl;
}

int Rational::num() const
{
  return num_;
}

int Rational::den() const
{
  return den_;
}

int main()
{
  Rational r(2, 3);

  cout << r.num() << " / " << r.den() << endl;
}
```

这个程序在我们电脑上的输出是：

```
2 / 3
-1881115708 / 0
```

而且，就像下面这个例子里一样，如果声明了和实例变量同名的局部变量的话，也会出现同样的问题：

```C++
#include <iostream>
using namespace std;
class Rational {

public:
  Rational(int num = 0, int den = 1);
  int num() const;
  int den() const;

private:
  int num_, den_;
};

Rational::Rational(int num, int den)
{
  // this is incorrect
  // do not declare local variables with the same name as
  // instance variables
  int num_, den_;

  num_ = num;
  den_ = den;
  cout << num_ << " / " << den_ << endl;
}

int Rational::num() const
{
  return num_;
}

int Rational::den() const
{
  return den_;
}

int main()
{
  Rational r(2, 3);

  cout << r.num() << " / " << r.den() << endl;
}
```

在我们的计算机上这个例子的输出与上一个例子的输出是一样的。
对于这两个例子的任何一个来说，它们都不会去初始化实例变量，因此它们的值是程序启动的时候，被分配给它们的内存位置里的任何值。
在这两种情况下，实际的实例变量在构造函数里都被隐藏了。
在第一个例子里，与实例变量同名的形参是在构造函数里被实际访问的变量。
在第二个例子里，在构造函数里访问的是局部变量而不是实例变量。
因此，千万不要对实例变量、局部变量或者是形参使用相同的名称。
所以，实例变量的名称使用下划线（但不对局部变量或形参添加下划线）是一种常用的能够避免这个问题的技术。

另一个常见的初学者容易犯的错误是编写像`r.num() = 3`这样的代码，在这个代码里，`r`是`Rational`类的实例。
这样的代码在Python以及C++里都是不正确的。
`r.num()`的返回值是一个数字，而不是可以存储值的变量。
因此，它就相当于像`4 = 3;`或者是`sqrt(5) = x;`这样的错误代码。
赋值语句的左侧的元素必须是一个变量。
用来描述这个变量的术语是*左值*（*l-value*），因为它总是出现在赋值语句的左侧。
当然，C++也确实支持引用返回类型，这个返回类型将会允许为类的方法的返回值进行赋值。
我们将在第10章介绍这方面的细节。

对于非常短的函数和方法（通常来说，少于五行的C++代码）而言，进行函数调用的开销会比执行函数里的实际代码还要花费更多的时间。
在这种情况下，通常对于避免这种函数调用的开销会很有必要。
C++提供了一种称为*内联*（*inlining*）的机制，它允许你把代码编写为函数或方法，但避免了函数调用的开销。
实际上，编译器会把函数调用替换成这个函数的实际代码主体。
在复制这个函数或者方法的时候，编译器也会正确地处理传递参数以及返回值。
对于类的方法，有两种不同的方法可以把它们编写为内联方法。
下面这个对`Rational`类的重写展示了这两种方法。
其中`num()`和`den()`方法展示了其中一种方法，而`decimal`方法则展示了另一种方法。

```C++
class Rational {

public:
  // constructor
  Rational(int n = 0, int d = 1);

  // sets to n / d
  bool set(int n, int d);
  // access functions
  int num() const { return num_; }
  int den() const { return den_; }
  // returns decimal equivalent
  double decimal() const;

private:
  int num_, den_; // numerator and denominator
};

inline double Rational::decimal() const
{
  return num_ / double(den_);
}
```

在函数声明的时候，`num()`和`den()`都是内联写入的。
在方法定义之后，并没有使用分号，而是直接跟着大括号内的代码。
当代码的长度适合被放在方法名称的同一行的时候，通常都会用这个办法。
对于`decimal()`方法来说，它在类的声明之后被内联编写。
这和我们在第8.13节里讨论过的，编写独立的内联函数的方法是一样的。
使用关键字`inline`后，接下来就像在实现文件中编写普通方法一样的代码就行了。
这个办法，通常会在代码有几行的时候使用。
当有多个文件包含这个头文件的时候，`inline`关键字会被用来防止这个方法有多个定义。
但是，如果在这里你忘记了用`inline`关键字的话，那么当有多个文件包含这个带有方法实现代码的头文件的时候，就会出现链接错误，这个错误会标明这个函数具有多个定义。
所有的内联方法应该写在头文件里，而不应该写在实现文件里。
唯一的例外情况是，如果只会从实现文件里调用这个内联方法的话，那么就应该在这个实现文件的最上面编写这个内联方法。

我们的`Rational`类的构造函数调用了`set`方法。
可以看到，在这里，方法的调用看起来很像是普通的函数调用，而不像在Python里我们需要使用`self`来标识所有的需要调用的方法。
用这个`set`方法的原因是为了防止有两段重复的代码执行相同的操作。
但是这样做的话，它会在构造函数里添加额外的函数调用的开销。
为了解决这个问题，我们可以把构造函数或者是`set`方法设置成为内联方法。
避免代码的重复通常来说都是一个好习惯，这是因为，如果你不这么做的话，那么当你需要在一个地方修改它的时候，你还需要记住在其他地方进行同样的修改。

通过这两种在头文件里编写内联方法的技术，编译器就只需要把这些方法的代码复制到调用它的函数或方法里去就好了，从而避免了函数调用的相关开销。
如果内联函数或者是方法太长的话，因为复制大函数的代码会增加整个可执行程序的大小，所以大多数编译器都只会为它创建一个普通的函数或方法。
遗憾的是，编译器实际上会不会去创建内联函数对于程序员来说是透明的。
在这两种编写内联方法的情况下，编译器都会去检查方法的返回类型以及参数类型，并且按照指定的机制（通过值或引用）有效地传递参数。
编写内联函数的唯一原因就是为了避免函数调用的开销。

## 字符串

现在我们已经学习了C++的类的一些基础知识，我们将开始研究作为C++标准库的一部分的`string`类。
C++的字符串对应着Python的`string`数据类型，都可以被用来表示通常被（但不总是）作为一个整体来进行处理的字符序列。
由于C++语言的大部分功能都向前兼容C语言的，因此，它也支持C语言风格的字符串。
而且，有一部分C++的库函数会要求按照C语言的字符串作为实际的参数进行传递，所以，我们将会简单的探讨一下C语言风格的字符串。
C语言使用`char`的数组来存储字符串数据，并使用特殊字符`\0`来表示字符串的结尾，因此整个数组的大小会比要存储的字符串至少大一个单位。
而且，由于C语言并不直接支持类，C语言的库提供了用来操作字符数组的单独函数。

C++的字符串的实现是包含一个`char`数组的实例变量的类。
就像你期望的那样，C++的字符串方法将会允许你，在不需要考虑内部实现的情况下，访问以及操作字符串。
C++的`string`类还提供了许多用来操作字符串数据的方法，但是并没有包含所有的Python字符串的功能。
除了C++的`string`类所支持的方法之外，它还重载了许多运算符，从而让你能够对字符串进行赋值以及比较。
你可以使用`<iostream>`头文件里定义的`cin`和`cout`实例以及文件类来读写C++的`string`变量。
在这一节的内容里，我们不会涵盖所有的字符串的方法，但会介绍关于C++的`string`类的一些基础知识。

要使用C++的`string`类，就必须在文件的顶部包含其他头文件的地方加上`#include <string>`。
`string`类也是在标准命名空间里定义的，因此，要使用它的话，你必须在文件的顶部加上`using namespace std`语句，或者是在使用整个类的时候用`std::string`。
当C++的可执行程序使用`>>`运算符读取字符串的时候，它会在遇到第一个空白字符（空格、制表符或新行）的地方停下来。
比如说，当需要读取一个人的用空格分开的姓氏和名字的时候，你就需要使用两个字符串：

```C++
string first, last;
cout << "Enter your first and last name (separated by a space): ";
cin >> first >> last;
```

你可以创建和输出一个包含空格的字符串，比如说这段代码：`string name; name = "Dave Reed"; cout << name << endl;`将会按照你的预期那样输出`Dave Reed`然后跟着一个新行。
但在使用`>>`运算符的时候，你需要记住的是，在每次遇到空白字符的时候，它都会停止读取。
C++提供了一个叫做`getline`的函数，它会从当前的输入指针处开始读取数据，直到遇到一个分隔符，分隔符的默认情况是`\n`这个行尾字符。
`getline`函数需要两个参数：
一个用来读取的输入流；
以及一个通过引用传递的字符串，这个字符串会被用来存储读取的内容。
第一个参数的输入流可以是`cin`实例或者是用来从磁盘文件里读取数据的文件句柄。
`getline`函数的第三个参数是可选参数，它被用来设置分隔符的字符。
在执行过程种，`getline`函数将会读取包括分隔符在内的所有字符，并且返回除了分隔符之外读取的所有字符组成的字符串。
通过使用`getline`函数，我们就可以用一个字符串来读取姓氏和名字了：

```C++
string name;
cout << "Enter your first and last name: ";
getline(cin, name);
```

你可以把`getline`函数和包含`>>`运算符的`cin`或文件句柄混合使用，但这样做的话，你就需要非常仔细地处理输入内容。
当你使用`cin`读取变量的时候，它会跳过前面的空格，但会留下后面的（包括输入流里的新行字符这样的）空格。
`getline`函数则会读取包括分隔符在内的，分隔符之前的所有内容，因此如果`getline`函数紧跟着一个读取了一行里的所有内容的`cin`实例的话，它将得到一个空字符串。
在这种情况下，你就必须要对`getline`调用两次，只有第二次调用才会在下一行的输入里获取数据。

C++的`string`类支持标准的比较运算符`<`、`<=`、`>`、`> =`、`==`以及`!=`。
比较的规则和Python是类似的，会按照字典顺序，并且由于小写字母的ASCII代码较大，小写字母将会大于大写字母。
但是和Python字符串不同的是，C++的字符串是可变的。
你可以通过使用括号运算符（`[]`）来访问单个字符并且设置单个字符。
和你猜想的一致，索引是从零开始的，而因为字符串内部是一个C++数组，因此你不能使用负值作为索引。
和C++的数组一样，这个括号运算符不会进行范围检查，因此，你需要自己去保证给定的索引不会超出字符串的末尾。
C++的字符串还支持赋值运算符`=`，它会将赋值语句右侧的字符串变量或表达式赋给左侧的字符串变量。

C++的字符串赋值运算符会创建一个单独的数据副本，这一点与Python里对同一个数据可以有两个引用是不一样的。
也就是说，如果在把一个C++的字符串变量赋值给另一个C++的字符串变量之后，你去修改其中一个字符串，另一个字符串是不会被修改的。
对于`+`和`+=`运算符来说，它们的工作方式与它们在Python里的工作方式是一样的。
下面这个例子展示了其中的一些概念：

```C++
// stringex.cpp
#include <iostream>
#include <string>
using namespace std;

int main()
{
  string first = "Dave";
  string last = "Reed";
  string name;

  name = first + " " + last;
  cout << name << endl;

  first[3] = 'i';
  first += "d";

  name = first + " " + last;
  cout << name << endl;
  cout << name.substr(6, 4) << endl;
  return 0;
}
```

这个示例会把`Dave Reed`，`David Reed`以及`Reed`输出到三行里。
有一点需要注意的是，单引号会和括号运算符一起使用，这是因为`first[3]`只是一个字符。
在这里，你并不能像Python那样使用切片语法来访问子字符串，你只能使用C++提供的`substr`方法。
这个方法的原型是`string substr(int position，int length)`。
它会返回一个，从指定的起始位置开始的具有指定长度的字符串。
这和Python里的切片是不一样的，Python里采用的是起始位置和结束位置。
`string`类还有一个名为`c_str()`的方法，它被用来返回C语言风格的字符数组。
在你需要一个C语言风格的字符串而不是C++的字符串去调用一个函数的时候，这个方法会非常有用。
`string`类的`find`方法需要一个字符串来进行搜索以及一个可选的搜索起始位置。
它会返回字符串里第一次出现被搜索的字符串的索引。
这个类还有许多其他的方法，但这里列出来的都是一些常用的方法。

## 文件输入和输出

尽管你可以直接输入ASCII数字数据，或者是像计算机存储内部数据类型那样直接按照二进制格式读取文件（在这本书里，我们不会去介绍二进制文件的读取），文件的输入和输出通常会涉及到字符串的使用。
C++像对待键盘和监视器输入和输出一样，使用类的实例来处理文件的输入和输出。
`fstream`头文件包含了用于文件输入和输出的`ifstream`和`ofstream`两个类的声明。
这两个类也在命名空间`std`里。
和在Python里类似的，你必须使用`open`方法来关联上文件名与文件变量。
下面这个例子会通过提示用户输入一个文件名，然后把字符串`David Reed`写入这个文件来展示C++里的文件输入和输出操作。
在写入这个文件之后，程序会再次打开这个文件进行读取，并且使用`getline`函数来读取文件里的第一行，最后使用`cout`语句进行输出：

```C++
// getline.cpp
#include <iostream>
#include <fstream>
using namespace std;

int main()
{
  string filename, name, first, last;
  ofstream outfile;
  ifstream infile;

  cout << "Enter file name: ";
  cin >> filename;
  outfile.open(filename.c_str());
  outfile << "David" << " " << "Reed" << endl;
  outfile.close();
  infile.open(filename.c_str());
  getline(infile, name);
  cout << name << endl;
  infile.close();
  return 0;
}
```

可以看到的是，`open`方法需要的字符串是C语言风格的版本，也就是一个字符数组。
因此，我们需要在打开文件的时候，使用字符串类的`c_str()`方法。
和Python一样，你需要关闭这个文件来确保写入文件的数据被刷新到了磁盘里。
在这个例子里，我们使用了`getline`函数来读取数据。
但是我们可以像下面这个代码片段里这样，使用与写文件的时候相同的模式来读取两个单独的字符串，然后再使用`+`运算符进行组合：

```C++
infile.open(filename.c_str());
infile >> first >> last;
infile.close()
name = first + " " + last;
cout << name << endl;
infile.close();
```

你还可以使用类似的方法从ASCII文件里去读取数字数据。
你首先需要打开文件，然后指定数值数据变量（`int`、`float`或者是`double`）。
和读取键盘输入的数值一样，空白字符（空格、制表符或换行符）会被用来分隔数值，但是空白的数量并没有关系。
每次再尝试读取一个值的时候，它都会跳过任何数量的空白来尝试找到一个数值。
在尝试读取数字的时候，在跳过前面的空白之后，如果遇到的是任何非数字的字符的话，那么就会生成运行时错误。
但是，当读取到了一个数字之后的非数字字符的时候，它会只读取数字，而不会包含其他的非数字字符，然后会把文件指针留在这个字符的位置。
之后，下一次的输入获取将会以这个字符作为开头。
下面这段代码将会读取一个名为`in.txt`的文件，然后在读取出它之后会在新的一行上输出这个数字。
这个文件里包含了10个ASCII文本的整数值，每个数字会被任意数量的空白进行分隔：

```C++
// readfile.cpp
#include <iostream>
#include <fstream>
using namespace std;
int main()
{
  ifstream ifs;
  int i, x;
  ifs.open("in.txt");
  for (i = 0; i < 10; i++) {
    ifs >> x;
    cout << x << endl;
  }
  return 0;
}
```

`ifstream`类和`ofstream`类的`open`方法都有第二个参数被用来指定打开文件的模式。
从前面的例子中可以很明显的知道，第二个参数是有默认值的。
这本书将不会去介绍这第二个参数的详细信息，也不会去介绍如何使用C++来读取或写入二进制文件。

## 运算符重载

在讨论字符串的时候，你应该就已经发现了C++也支持用户去定义的运算符重载。
和Python一样，运算符重载的目的是让代码更简洁，更可读。
这是因为，C++在默认情况下并不是使用的引用，所以就必须要使用运算符重载来覆盖掉使用动态内存的类的赋值运算符。
我们将会在第10章里详细讨论这个问题。

在C++里，你可以选择在类里创建运算符方法或者是独立的函数（一部分功能必须通过独立函数来实现）。
一些程序员更喜欢使用独立函数，这是因为二元运算符的函数都有两个参数，而这两个参数都对应于应用这个运算符的相同类的两个实例。
但是如果把运算符通过类的方法来实现的话，这个方法的原型里就只会有一个参数，这个时候，调用这个方法的实例将会把运算符左边的那个参数作为的隐式参数。
在Python里，因为`self`参数是被显式定义的，因此运算符的两个参数都会出现在定义里。
同时，使用独立函数来实现运算符重载的话，还有一个缺点是：它们不能去访问类的私有数据。
因此，这个类就必须提供一个能够访问和修改私有数据的方法。
为了能够允许其他类的某些函数或方法访问这个实例的私有数据，C++提供了友元结构。
我们会在学习如何去重载输入和输出运算符的时候研究这个技术。

C++通过使用单词`operator`，以及它后面跟着的正在重载的运算符的实际符号来命名运算符重载的方法。
我们将会首先关心当运算符不是类的成员的情况，在这个情况下，我们将会需要编写独立的函数来实现相应的功能。
下面这段代码是通过独立函数来编写的加法运算符的`Rational`类的头文件和实现文件：

```C++
// Rationalv1.h
class Rational {

public:
  // constructor
  Rational(int n = 0, int d = 1) { set(n, d); }
  // sets to n / d
  bool set(int n, int d);

  // access functions
  int num() const { return num_; }
  int den() const { return den_; }

  // returns decimal equivalent
  double decimal() const { return num_ / double(den_); }

private:
  int num_, den_; // numerator and denominator
};

// prototype for operator+ standalone function
Rational operator+(const Rational &r1, const Rational &r2);
```

```C++
// Rationalv1.cpp
#include "Rationalv1.h"

bool Rational::set(int n, int d)
{
  if (d != 0) {
    num_ = n;
    den_ = d;
    return true;
  }
  else
    return false;
}

Rational operator+(const Rational &r1, const Rational &r2)
{
  int num, den;

  num = r1.num() * r2.den() + r2.num() * r1.den();
  den = r1.den() * r2.den();
  return Rational(num, den);
}
```

可以看到，由于运算符是一个独立函数，因此，类名和两个冒号（`Rational::`)将不会被放在函数名称（`operator+`）之前。
调用这个运算符的示例程序是：

```C++
// mainv1.cpp
#include "Rationalv1.h"
int main()
{
  Rational r1(2, 3), r2(3, 4), r3;

  r3 = r1 + r2; // common method of calling the operator function
  r3 = operator+(r1, r2); // direct method of calling the function
}
```

由于这个函数并不是这个类的成员，因此它不能直接访问这个类里的私有数据成员，这时就需要使用公共方法来得到分子和分母相应的值。
下面这个表里列出了对于这个类可以编写的许多运算符的独立函数版本的函数原型（这并不是一个完整的列表）。
对于其他类，很明显你需要把`Rational`替换为那个类的相对应的名称。
我们把参数按照`const`常量的引用进行传递，这就表明了，这些函数只能调用`Rational`类里的`const`方法。
而正因为在使用任何运算符的时候都不应该去修改参数，所以这样做并不会出现什么问题。
我们之前曾经提到过，参数通过`const`以及引用传递来传递类的实例的原因是：
当通过引用传递的时候，只会传递对象的地址。
因此，与按值传递相比，这样做会让复制的数据更少，于是速度就会更快，占用的内存也会更少。
这个表里的第一列显示了各个函数的原型；
第二列则显示了如何调用`Rational`类的函数/运算符来对两个实例进行计算，并返回相应的结果。

| 函数 | 计算 |
| :------- | :------- |
| `Rational operator+(const Rational& r1, const Rational& r2)` | `r1 + r2` |
| `Rational operator-(const Rational& r1, const Rational& r2)` | `r1 - r2` |
| `Rational operator*(const Rational& r1, const Rational& r2)` | `r1 * r2` |
| `Rational operator/(const Rational& r1, const Rational& r2)` | `r1 / r2` |
| `Rational operator-(const Rational& r1)` | `-r1` |
| `bool operator<(const Rational& r1, const Rational& r2)` | `r1 < r2` |
| `bool operator<=(const Rational& r1, const Rational& r2)` | `r1 <= r2` |
| `bool operator>(const Rational& r1, const Rational& r2)` | `r1 > r2` |
| `bool operator>=(const Rational& r1, const Rational& r2)` | `r1 >= r2` |
| `bool operator==(const Rational& r1, const Rational& r2)` | `r1 == r2` |
| `bool operator!=(const Rational& r1, const Rational& r2)` | `r1 != r2` |

运算符重载的逻辑也可以被写成方法（也就是类的成员）。
一般来说，在这样做的时候，运算符相应的逻辑将会写在.cpp文件里，而它相对应的函数原型将会写在.h文件里。
这是因为，我们编写成员方法的时候，都需要在类的声明的`public`部分声明这个函数的原型。
调用这个方法的对象将会是这个函数里隐式的第一个参数`r1`，因此，它不会被写在方法里。
下面的代码片段展示了作为类的方法来编写的加法运算符的头文件和实现文件。

```C++
// Rationalv2.h
class Rational {

public:
  // constructor
  Rational(int n = 0, int d = 1) { set(n, d); }

  // sets to n / d
  bool set(int n, int d);

  // access functions
  int num() const { return num_; }
  int den() const { return den_; }

  // returns decimal equivalent
  double decimal() const { return num_ / double(den_); }

  Rational operator+(const Rational &r2) const;

private:
  int num_, den_; // numerator and denominator
};
```

```C++
// Rationalv2.cpp
#include "Rationalv2.h"

// code for set method is also required
// see previous example for the code

Rational Rational::operator+(const Rational &r2) const
{
  Rational r;

  r.num_ = num_ * r2.den_ + den() * r2.num();
  r.den_ = den_ * r2.den_;
  return r;
}
```

由于这个方法是类的成员，因此它可以直接访问这个类的任何一个实例的私有数据成员。
而且可以看到，就像所有的C++类的方法一样，它的第一个参数被隐含在方法的原型里了。
因此，你可以在不使用变量名的情况下，直接通过数据/方法成员的名称来访问这个实例的数据和方法，同时通过第二个参数（`r2`）的名称以及它后面的那个句点来显式地访问第二个参数的数据。
在上面的例子里，我们使用了`num_`和`den()`两种不同的方式分别展示了，直接访问隐含参数的实例变量以及方法，一般来说，你会选择其中一种风格，然后在代码里一直保持这种风格。
一些程序员会更喜欢使用非成员函数，因为这样做的话，函数原型是对称的而且两个参数都被显示的表示了出来。
对于其他的一些程序员来说，他们会更喜欢使用类的成员方法，因为这样做所有代码都会被封装在类里，并且这些方法可以直接访问实例的私有数据。

通常来说，就像我们在使用函数来编写运算符重载的时候那样，会直接使用运算符来调用这个类方法。
当然，你也可以像调用方法的标准语法（也就是：类实例名称，后跟句点，后跟方法名）那样直接调用这个方法。

```C++
// mainv2.cpp
#include "Rationalv2.h"
int main()
{
  Rational r1(2, 3), r2(3, 4), r3;

  r3 = r1 + r2; // common method of calling the operator method
  r3 = r1.operator+(r2); // direct method of calling the operator
}
```

下面这个表格显示了当运算符重载作为类的成员的时候的函数原型。
同样的，表格的第二列也显示了应该如何调用相应的方法来进行运算符计算以及返回的计算结果。

| 方法 | 计算 |
| :------- | :------- |
| `Rational operator+(const Rational& r2)` | `r1 + r2` |
| `Rational operator-(const Rational& r2)` | `r1 - r2` |
| `Rational operator*(const Rational& r2)` | `r1 * r2` |
| `Rational operator/(const Rational& r2)` | `r1 / r2` |
| `Rational operator-()` | `-r1` |
| `bool operator<(const Rational& r2)` | `r1 < r2` |
| `bool operator<=(const Rational& r2)` | `r1 <= r2` |
| `bool operator>(const Rational& r2)` | `r1 > r2` |
| `bool operator>=(const Rational& r2)` | `r1 >= r2` |
| `bool operator==(const Rational& r2)` | `r1 == r2` |
| `bool operator!=(const Rational& r2)` | `r1 != r2` |

如果要重载输入运算符（`>>`）和输出运算符（`<<`）的话，就只能把它们写为独立的函数。
这样做的原因是：这个方法的第一个参数必须是这个类的实例。
思考一下这样的代码`cin >> r1`。
如果你想把它写成成员方法的话，就意味着这个方法将只能像`cin.operator>>(r1)`这样被调用。
这是因为`cin`并不是`Rational`类的实例，因此输入运算符并不是`Rational`类的成员，也就是为什么它必须作为独立函数来进行编写的原因。
同样的，在使用输出运算符`<<`以及`ostream`类的实例（`cout`）的时候也是这样。
`Rational`类的输出运算符的独立函数应该被写为：

```C++
std::ostream& operator<<(std::ostream &os, const Rational &r)
{
  os << r.num() << "/" << r.den();
  return os;
}
```

可以看到，这个运算符函数需要返回`ostream`类型的输出流变量的实例`os`，来让它可以和其他语句链接在一起（也就是这样使用：`cout << r1 << r2`）被使用。
在这个例子里，`cout << r1`的返回结果是`ostream`类的实例`cout`，因此它现在是输出`r2`的函数的第一个参数。
因为在把变量输出到流的时候会更改这个流，所以`ostream`类型的参数`os`也需要通过引用来进行传递，而且返回的也应该是引用。
我们将在第10章里更详细地介绍返回引用，但是就现在而言，你只需要了解到通过引用进行返回的语法就行了——这个语法就是在返回类型上附加一个`&`符号就行了（就像输出运算符重载里的`ostream&`这样）。

由于运算符操作是一个非成员函数，因此它不能也无法访问`Rational`类里的私有数据。
但是，有些时候我们会希望能够允许某些其他的类或者函数也能访问这个类的私有数据。
C++提供了一种使用`friend`（友元）关键字来允许这个操作的机制。
允许非成员函数直接访问私有成员的一个常见的例子是输入/输出运算符的重载函数。
我们还可以在我们的`ListNode`类找到另一个例子。
因为`LList`类和`ListNode`类这两个类紧密地耦合在了一起，所以我们会希望能够让`LList`类直接访问`ListNode`类的数据成员。
函数或者类可以在想要被作为朋友（友元）的类里被指定为`friend`（友元）。
下面这个代码片段在我们的`Rational`类里展示了这个用法。
另外，如果我们想让整个类都成为另一个类的朋友的话，那么相对应的语法就是`friend class LList`。
如果我们将这一行代码放在`ListNode`类里的话，那么所有的`LList`方法都可以直接访问`ListNode`类的私有数据了。
当我们在第11章里用C++来编写链式结构的时候，我们将会展示一个相关的完整的例子。

下面这个代码片段是一个完整的、简化的`Rational`类的头文件，它展示了运算符重载和友元的使用。
为简洁起见，所有的方法都不包含先验条件与后置条件以及注释。

```C++
// Rationalv3.h
#ifndef _RATIONAL_H
#define _RATIONAL_H

// needed for definition of ostream and istream classes
#include <iostream>

class Rational {

// declare input and output operators functions as friends
// to the class so they can directly access the private data
friend std::istream& operator>>(std::istream& is, Rational &r);
friend std::ostream& operator<<(std::ostream& os, const Rational &r);

public:
  // constructor
  Rational(const int n = 0, const int d = 1) { set(n, d); }

  // sets to n / d
  bool set(const int n, const int d);

  // access functions
  int num() const { return num_; }
  int den() const { return den_; }

  // returns decimal equivalent
  double decimal() const;

private:
  int num_, den_; // numerator and denominator
};

// prototypes for operator overloading
Rational operator+(const Rational &r1, const Rational &r2);

// declare the non-member input output operator functions
std::istream& operator>>(std::istream &is, Rational &r);
std::ostream& operator<<(std::ostream &os, const Rational &r);

#endif
```

相对应的.cpp实现文件是：

```C++
// Rationalv3.cpp
using namespace std;
#include "Rationalv3.h"

bool Rational::set(const int n, const int d)
{
  if (d != 0) {
    num_ = n;
    den_ = d;
    return true;
  }
  else
    return false;
}

Rational operator+(const Rational &r1, const Rational &r2)
{
  int num, den;

  num = r1.num() * r2.den() + r2.num() * r1.den();
  den = r1.den() * r2.den();
  return Rational(num, den);
}

std::istream& operator>>(std::istream &is, Rational &r)
{
  char c;

  is >> r.num_ >> c >> r.den_;
  return is;
}

std::ostream& operator<<(std::ostream &os, const Rational &r)
{
  os << r.num() << "/" << r.den();
  return os;
}
```

传递给输入运算符函数的`Rational`对象必须通过引用传递，这是因为我们会希望把读取出来的值存储在发送的实际参数里（也就是说，当我们在执行`cin >> r`时候，我们会把用户输入的值存储在`r`里）。
因此，这也是这个参数不能被标记为`const`的原因。
为了能够允许我们输入像`2/3`这类的值，我们需要在输入运算符的函数里去读取这个斜杠。
我们声明了`char`类型的变量`c`来存储这个斜杠，但会在读取之后会忽略这个值，因为我们的`Rational`类只会存储两个整数来封装这个实数。

另外从我们的例子里可以看到，我们并没有在头文件里使用`using namespace std`语句。
于此相反，我们在使用`std`命名空间中定义的`ostream`和`istream`类的时候会使用前缀`std::`。
这样做的原因是如果我们把`using namespace std`语句放在头文件里的话，那么任何包含我们的Rational.h头文件的文件都会再包含`using namespace std`这一行代码。
因此，在头文件里你不应该使用`using`语句。
但是，我们在Rational.cpp文件里使用了`using namespace std`语句，这样我们就可以在实现逻辑的时候，在所有在命名空间里定义的名称前面都加上`std::`了。
这样做也不会导致出现任何问题，因为你的代码并不会去包含实现（.cpp）文件。

## 类变量和方法

C++还支持创建类变量的机制。
你可能还记得我们在2.3.2小节里曾经讨论过如何在Python里创建类变量。
如果使用实例变量的话，类的每个实例都会获得一个自己的实例变量的单独副本。
对于类变量来说，类的所有的实例都共享相同的变量（也就是说，无论存在多少个类的实例，有且只有一个类变量的副本）。
我们在2.3.2小节里讨论过的`Card`类就是一个很好的例子，在这个类里使用类变量是有意义的。
接下来，我们将使用C++的类变量在本节里创建一个类似的`Card`类。

```C++
// Card.h
#ifndef __CARD_H__
#define __CARD_H__
#include <string>

class Card {
public:
  Card(int num=0) { number_ = num; }
  void set(int num) { number_ = num; }
  std::string suit() const;
  std::string face() const;
private:
  int number_;
  static const std::string suits_[4];
  static const std::string faces_[13];
};
inline std::string Card::suit() const
{
  return suits_[number_ / 13];
}
inline std::string Card::face() const
{
  return faces_[number_ % 13];
}
#endif // __CARD_H__
```

在声明它们的时候使用`static`前缀，就可以创建类变量了。
在C++里，`static`关键字有许多不同的用途，所以很容易混淆它们的意思。
在这个地方，`static`关键字的使用和我们在前一章里提到的静态`static`关键字的使用有着完全不同的含义，上一章里，`static`关键字会创建一个始终使用相同内存位置的局部变量。
而吧一个实例变量声明为`static`则代表它是一个类变量，因此这个类的所有实例都会共享这个变量的同一个副本。
在我们的这个例子里，使用类变量是有意义的，这是因为，我们并不需要为类的每个实例都去创建一个花色和数字的单独副本。
因为这样做的话，这些实例变量会浪费大量的内存。
如果使用类变量的话，这个类的每个实例都只需要四个字节的内存就能够使用它了。
但是，如果花色和数字变量不是类变量的话，我们的扑克牌（`Card`）类的每个实例都需要大概100个字节来存储相应的数字和字符串。
下面这段代码片段是`Card`类的实现文件。

```C++
// Card.cpp
#include "Card.h"
const std::string Card::suits_[4] = {
  "Hearts", "Diamonds", "Clubs", "Spades" };
const std::string Card::faces_[13] = {
  "Ace", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine",
  "Ten", "Jack", "Queen", "King" };
```

类变量是像非局部变量一样被定义的（也就是在任何函数之外），并且使用赋值语句来初始化这个变量，这个赋值语句在程序刚开始的时候会被执行。
由于只会存在一个类变量的副本，因此我们不会在构造函数里对这个值进行分配。
我们在头文件里在声明这个类变量的时候还使用了`const`前缀，因此一旦这些语句初始化了变量之后，我们就不能再去修改它们的值了。
即使在声明类变量的时候没有使用`const`前缀，我们仍然需要在实现文件里再定义它们一次（不论是否提供了初始值）。
这是因为，类的定义实际上不会导致任何内存的分配，只有当我们创建一个类的实例的时候，相应的内存才会被分配。
这也就是为什么我们必须要在实现文件里去定义类变量的原因——为了能够为它们分配相应的内存。

下面的这个示例程序使用了这个包含类变量的`Card`类。

```C++
// test_Card.cpp
#include <iostream>
using namespace std;
#include "Card.h"

int main()
{
  Card c[52];
  int i;

  for (i=0; i<52; ++i) {
    c[i].set(i);
  }
  for (i=0; i<52; ++i) {
    cout << c[i].face() << " of " << c[i].suit() << endl;
  }
  return 0;
}
```

虽然我们没有这样做，还是可以假设一下：
如果我们试图在`main`函数里用语句`cout << Card::faces_[0] << endl;`的话，会发生什么呢？
虽然这一句代码使用了类名后跟两个冒号后跟类变量名来访问类变量的正确用法。
但是，我们的类变量被声明为了`private`，因此，虽然类变量的定义并不在类里，它们也不能够从类的外部进行访问。
然而要注意的是，如果我们是在`public`里面声明了类变量的话，那么这句代码是会起作用的。

你可能会想知道为什么当所有的方法都在头文件里被内联定义之后，我们还是需要创建一个单独的实现文件。
这是因为，如果我们像下面这段代码一样，把类变量的定义放在头文件里的话，我们最终可能会多次定义这个相同的名称。
然而我们曾经提到过，每个变量或者函数都只能有一个定义。

```C++
// this code should not be used

#ifndef __CARD_H__
#define __CARD_H__

#include <string>

class Card {
public:
  Card(int` num=0) { number_ = num; }
  void set(int num) { number_ = num; }
  std::string suit() const;
  std::st`ring face() const;
private:
  int n`umber_;
  static const std::string suits_[4];
  stati`c const std::string faces_[13];
};

const std::string Card::suits_[4] = {
  "Hearts", "Diamonds", "Clubs", "Spades" };

const std::string Card::faces_[13] = {
  "Ace", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine",
  "Ten", "Jack", "Queen", "King" };

//--------------------------------------------------------------------

inline std::string Card::suit() const
{
  return suits_[number_ / 13];
}

inline std::string Card::face() const
{
  return faces_[number_ % 13];
}

//--------------------------------------------------------------------

#endif // __CARD_H__
```

如果只有一个文件包含这个头文件的话，那么这个头文件是能够正常工作的，这是因为它只为类变量`suit_`和`faces_`创建了一个定义。
但是，如果用来创建一个可执行程序的多个实现文件都包含了这个头文件的话，那么我们就会有多个类变量的定义了，于是我们会得到一个链接器错误来提示我们有一个对符号的多次定义。
因此，就像我们在一开始的那个例子里做的那样，类变量应该始终在实现文件里被定义。

在我们的例子里，类变量被声明为了`const`，这是因为对它们进行修改是没有意义的。
但在某些情况下，你可能会希望相应的类变量不是`const`的。
比如，非`const`的类变量的一种常见用途是用来跟踪创建了的类的实例数。
为了能够实现这个功能，我们将会创建一个会在构造函数里添加类变量的类。
这个类变量的值将会告诉我们已经创建了的类的实例总数。
因此，我们可以在头文件里的类的定义的下一行，向这个类添加一个类变量：`static int count_;`；
然后我们把代码行`int Card::count_ = 0;`添加到实现文件里。
如果我们时在头文件的`public`部分声明的这个类变量的话，那么我们就可以直接访问它了。
因此，我们可以在`main`函数里直接使用这一行代码：`cout << Card::count_ << endl;`。
当然，通常来说，你并不会在`public`部分声明类的数据成员。
这是因为有人可以把`Card::count_ = 100;`这样的代码放在他们的代码里，从而破坏掉了`count_`的值的完整性。
因此，它储存的值将不再是已经创建了的`Card`类的实例数了。

类也可以包含在没有类的实例的情况下可以被调用的类方法。
同时，能够保证数据完整性的正确访问方法是使用类的方法来访问类变量`count_`。
因此，我们将需要添加一个返回类变量值的类方法。
这个类方法也是通过使用`static`前缀来进行声明的。
这个方法的声明和定义是：`static int count() { return count_; }`。
要调用这个方法，我们可以使用代码`cout << Card::count（） << endl;`来完成。
这个时候，你应该注意到了一件事情：
类方法可以访问类变量，但它们不能访问类的实例变量。
这是因为，在调用类方法的时候，你并没有一个类的实例能够像我们在调用实例方法时那样被明确指定（例如，`Card::count()`与`c.face()`两种调用）。
而因为在调用方法的时候没有指定相应的实例，类方法并不会知道应该使用哪一个实例的数据。

你可能发现了，在我们用来计算扑克牌数量的示例代码里，存储这个数值的类变量永远都不会减少。
也就是说，即使其中的一些实例可能已经不存在了，这个类变量还是会储存所有曾经创建过的实例的数量。
在程序执行时，为了能够让这个类变量正确地表示当前存在的类的实例数，我们还需要在`Card`类的实例的生命周期结束的时候，减小这个类变量的值。
我们将在第10章C++的动态内存里学习关于析构函数的相关内容，这个函数可以被用来完成这项任务。

## 章节总结

这一章里，我们介绍了编写和使用C++类的语法和概念。
下面是这些重要概念的摘要：

* C++的类通常由两个放在不同文件里的部分构成：头文件里的类定义和实现文件里的函数的代码。

* 在类定义的结束括号之后，必须要放置一个分号。

* C++的类的构造函数和类具有相同的名称，并在定义这个类的变量的时候会被自动调用。

* 程序员们通常会在实例变量名称的前面或者后面加上下划线，这是为了防止意外地在形参或者局部变量调用的时候，使用了与实例变量相同的名称。

* C++提供了一个内置的`string`（字符串）类，它可以与标准的输入/输出技术一起进行使用。
C++的`string`（字符串）类还像Python那样实现了相同的常用运算符（`[]`、`+`和`+=`）。

* 内置类型和`string`（字符串）类也可以使用相同的标准的输入和输出语法来读取和写入文件。

* C++允许程序员为自己的类进行运算符重载。
大多数运算符都可以作为独立函数或者是作为类的成员来进行编写。
这些函数/方法的名称是`operator`，以及跟在它后面的实际的运算符符号。

* 当所有的类的实例都只需要一个数据副本的时候，就应该使用类变量。
类方法只能访问类里的数据。
在C++里，使用`static`关键字来指定类变量和类方法。

## 练习

**判断题**

1. C++类包含一个与类同名的构造函数。

2. C++的构造函数将会被自动调用。

3. 你必须为你编写的所有的C++类的构造函数编写相应的代码。

4. C++类的方法可以创建或者添加更多的实例变量。

5. 方法可以被声明在类的定义的`private`部分里。

6. 必须在类定义的`private`部分声明实例变量。

7. 如果方法里有一个与实例变量同名的变量，那么会产生编译器错误。

8. 方法可以在头文件里`inline`内联写入。

9. `string`（字符串）类是在`std`命名空间里定义的。

10. 字符串的默认输入运算符会像Python里的`raw_input`函数一样，读取一行文本。

11. `string`（字符串）类有一个被叫做`getline`的方法。

12. 使用`getline`方法的时候，将会从输入流里删除换行符。

13. C++使用类实例来从键盘或者文件里进行读取，以及使用类实例来向屏幕和文件里进行写入。

14. 在重载C++运算符的时候，你可以将大多数重载方法编写为函数或方法。

15. 类方法可以访问实例变量。

16. 类方法可以访问类变量以及实例变量。

**选择题**

1. 在C++里，实例变量可以被声明为

    a) 仅限私有（`private`）。

    b) 仅限公共（`public`）。

    c) 仅限受保护（`protected`）。

    d) 公共（`public`），私有（`private`）或者受保护（`protected`）。

2. 在C++里，实例方法可以被声明为

    a) 仅限私有（`private`）。

    b) 仅限公共（`public`）。

    c) 仅限受保护（`protected`）。

    d) 公共（`public`），私有（`private`）或者受保护（`protected`）。

3. 可以访问被声明为私有（`private`）的类的成员的有

    a) 只有通类的方法。

    b) 只有通类的方法或者是类的友元。

    c) 只有通类的方法，类的子类或者是类的友元。

    d) 任何代码都能访问。

4. 可以访问被声明为受保护（`protected`）的类的成员的有

    a) 只有通类的方法。

    b) 只有通类的方法或者是类的友元。

    c) 只有通类的方法，类的子类或者是类的友元。

    d) 任何代码都能访问。

5. 可以访问被声明为公共（`public`）的类的成员的有

    a) 只有通类的方法。

    b) 只有通类的方法或者是类的友元。

    c) 只有通类的方法，类的子类或者是类的友元。

    d) 任何代码都能访问。

6. 声明为`const`的方法可以

    a) 在方法里声明常量。

    b) 不能修改任何实例变量。

    c) 所有参数都必须有被标记为`const`。

    d) 必须返回常数。

7. 如果你正在查看别人写的C++类，你应该如何去确定一个变量是局部变量还是实例变量？

    a) 在多个方法里使用了相同的变量名。

    b) 变量在构造函数里被使用。

    c) 实例变量总是以下划线开头。

    d) 实例变量在类定义里声明的，而不是在其中一个方法里声明的。

8. 如何编写C++的运算符重载？

    a) 它们只能被写成类的成员。

    b) 它们只能被写成函数。

    c) 它们可以被写成一个类的成员或者是一个函数。

    d) 有些只能作为函数进行编写，而大多数都可以作为函数或者方法进行编写。

9. C++的类变量可以在哪里被访问？

    a) 它们的访问取决于它们是被定义为公共（`public`）、私有（`private`）或者受保护（`protected`）的。

    b) 只能通过类的方法来访问它们。

    c) 只能通过类方法来访问它们。

    d) 任何地方都能访问它们。

10. C++类变量在声明时候应该

    a) 在变量类型之前使用关键字`class`。

    b) 在变量类型之前使用关键字`static`。

    c) 把它们放在头文件里，但是应该在在类的结束括号之后。

    d) 在构造函数里声明它们。

**简答题**

1. 由于C++不需要类似于在Python中使用self的语法，因此通常被用来指示实例变量，让它们会与方法中的局部变量混淆的约定是什么？

2. 方法的规范里的`const`是什么意思？

3. 如果在头文件里编写了方法，但是没有把它指定为`inline`（内联）方法的话，会出现什么问题。

4. 当输入文件getline.txt包含下面的内容的时候：

    ```C++
    Dave Reed
    John Zelle
    Jane Doe
    ```

    下面这个程序的会输出什么：

    ```C++
    #include <iostream>
    #include <fstream>
    #include <string>

    using namespace std;

    int main()
    {
      ifstream ifs;
      string first, last, name1, name2, name3;

      ifs.open("getline.txt");
      ifs >> first >> last;
      getline(ifs, name1);
      getline(ifs, name2);
      getline(ifs, name3);

      cout << first << " " << last << endl;
      cout << name1 << endl;
      cout << name2 << endl;
      cout << name3 << endl;
    }
    ```

5. 哪些操作符不能作为类的成员，而只能作为函数进行编写，为什么会有这样的限制？

6. 为什么类方法不能访问类的实例变量？

7. 类变量和实例变量之间有什么区别？

**编程练习**

1. 编写一个用来代表一副扑克牌组的类，然后用这个类来玩二十一点游戏。
你可能还会需要用另一个类来代表二十一点游戏。

2. 使用C++类编写第3章里的Markov乱码生成器。
并且扩展它，从而能够在创建模型的时候确定前缀的大小。
构造函数将会通过一个参数来获取前缀的长度。

3. 在`Rational`类里添加四个基本数学运算符`+`、`-`、`*`和`/`，六个比较运算符`<`、`<=`、`>`、`>=`、`==`和`!=`以及输入和输出运算符。
把数学运算符和比较运算符按照函数进行写成。
将分子和分母保存为已经约分了的形式。

4. 把上一个练习里列出的运算符作为方法添加到`Rational`类里。

5. 编写一个用来把数字存储为单个数字的数组（也就是说，数组里的每个元素都是`0`到`9`之间的数字）的`LongInt`类。
你的这个类需要能够支持不超过100位数字。
使用运算符重载来让你的类支持加法、减法和乘法。
同时编写一个`set`方法来让你通过传递一个字符串形式的数字，并且基于这个字符串设置这个数字。
字符串里的每个`char`元素都可以被视为从`0`到`127`之间的数字；当减去`48`——也就是`0`的ASCII值——之后，你就可以把`char`类型转换为`0`到`9`之间的数字了。
除了这个方法，你还需要再提供一个输出数字的方法。
编写一个程序来测试这个`LongInt`类。

6. 编写一个类来表示多项式。
这个类需要存储系数和多项式次数的数组。
你可以假设多项式的最大度数为`100`。
编写加法、减法和乘法运算符的重载方法，并且为这个类编写输入和输出运算符。
除此之外，你还需要提供一个用来计算多项式再特定值处的结果的方法。
编写一个程序来测试这个`Polynomial`类`。

7. 编写一个被用来表示集合的类。
它需要包括`addElement`、`removeElement`、`removeAll`、`union`、`intersect`和`isSubset`这些方法。
