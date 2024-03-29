# 堆栈和队列

目标

* 了解堆栈抽象数据类型，并且熟悉实现高效堆栈的各种策略。

* 熟悉堆栈的行为，并且理解和分析基本的基于堆栈的算法。

* 了解队列抽象数据类型，并且熟悉实现高效队列的各种策略。

* 熟悉队列的行为，并且理解和分析基本的基于队列的算法。

## 概要

在过去的两章里，我们详细的介绍了列表数据结构。
就像你已经学习到的一样，列表是一个顺序结构。
我们还了解了有序列表，有序列表是指列表中的元素顺序由元素的“值”来决定。
当然，有些时候根据添加元素的时间来排序，而不是按照特定元素的顺序来排序的顺序集合是非常有用的。
在本章里，我们将会介绍这种结构的两个简单示例，它们被称为堆栈和队列。

## 堆栈

*堆栈*（*stack*）是最简单的容器类之一。
然而，正如你即将看到的那样，尽管堆栈很简单，但它会令人惊讶的非常有用。

### 堆栈抽象数据类型

想象有一个这样的列表（一个顺序数据结构），你只能在列表的一端来访问数据。
也就是说，你可以从列表的这一端插入和删除元素。
同时，你可以查看列表末尾（被称为顶部）的单个元素的内容。
刚刚描述的相当严格的数据结构被称为*堆栈*（*stack*）。
你可以把它看作是对真实世界的元素的堆栈进行的建模：
你只能（安全地）在堆栈的顶部添加或删除元素。
如果事物都被堆叠得很整齐，那么就只有顶部元素可以被看见。

如果你喜欢甜点的话，你也可能把堆栈当作是计算机科学里的Pez糖果分配器。
按照惯例，我们的堆栈是通过“弹簧加载的”，因此将一个元素添加到堆栈的操作被称为将元素推入（`push`）堆栈。
而从堆栈中删除顶部元素则被称为弹出（`pop`）元素。
请注意，在堆栈上推入的最后一个元素必须始终是要弹出的第一个元素。
因此，堆栈也被称为是一个后进先出（last in, first，LIFO）的数据结构。
你也可以把它称为FILO（先进后出）结构，这是因为一堆FILO（非常薄的无酵母的）面团可以做出好吃的糕点。
典型的堆栈抽象数据类型的规范如下所示：

```Python
class Stack(object):

    def __init__(self):
        """post: creates an empty LIFO stack"""

    def push(self, x):
        """post: places x on top of the stack"""

    def pop(self):
        """pre: self.size() > 0
           post: removes and returns the top element of
                 the stack"""

    def top(self):
        """pre: self.size() > 0
           post: returns the top element of the stack without
                 removing it"""

    def size(self):
        """post: returns the number of elements in the stack"""
```

### 堆栈的简单应用

即使堆栈非常的简单，它能够被用在很多地方。
毫无疑问，你已经在计算中遇到过很多使用堆栈的地方，虽然你可能根本并不知道这些地方使用了堆栈。
比如，你可能已经使用了一些包含“撤消”功能的应用程序。
就像是，你正在文字处理程序中编辑的文档，突然意外地删除了一堆文本。
怎么办呢？
这时你可以快速的到“编辑”菜单里去选择撤消命令，然后就“魔法般”的恢复了被删除的文本。
需要再撤回一些操作吗？
许多应用程序都允许你使用撤消命令来回滚到几乎任何以前的状态。
在内部，这就是使用堆栈来完成的。
每次执行一个操作时，有关这个操作的信息就会被保存在堆栈里。
当执行“撤消”时，最后一个操作将会从堆栈里弹出，并且进行反向操作。
在这时，堆栈的尺寸决定了可以撤消的操作数量。

另一个使用堆栈的例子就是计算机本身。
你知道函数是编程语言的一个重要组成部分，现代操作系统里提供了硬件功能来支持广泛使用函数的程序。
调用一个函数时，像局部变量的值和返回地址（程序在调用函数之前停止的位置），这样的有关函数的信息将会被推如到被称为运行时的堆栈里。
调用的最后一个函数始终都是第一个返回的函数，所以当函数结束的时候，它的信息将会从运行时堆栈里弹出，返回地址会被用来告诉CPU下一条需要执行的指令的位置。
随着函数越来越多的被调用，堆栈会越来越大，同样的，当每次有函数返回时，堆栈都会缩小。
你可能已经注意到过，当你在Python中收到错误消息时，解释器会输出一个回溯来显示错误消息是如何产生的。
此回溯将会显示引发这个异常的时候的运行时里堆栈的内容。

堆栈对于计算机程序的句法分析也非常重要。
编程语言的结构必须要始终能够被正确的嵌套。
例如，你可以将一个`if`完全置于一个循环的内部，或者你可以把它放在循环之外（之前或之后），但是如果要“跨越”循环的边界的话，则是不可以的。
堆栈是用来处理嵌套结构的非常合适的数据结构。
我们可以使用一个更简单的嵌套示例（比如说，括号）来说明这一点。
在数学里，计算方程通常使用括号来进行分组。
这里有一个简单的例子：$(x + y) * x)/(3 * z)$。
在一个正确的计算方程中，括号始终是正确嵌套的，或者说，是*平衡*（*balanced*）的。
如果我们仅仅查看括号的话，前面这个计算方程的结构是$(())()$。
每个左括号都有一个与之相匹配的右括号，并且左右括号没有与其他括号对“交错”排列。

假设你正在编写一个算法来检查括号序列是否是正确平衡的。
你应该怎么做呢？
简单来说，我们必须保证每次看到右括号的时候，都会有一个能够和它相匹配的左括号。
我们可以通过检查是否有相同数量的左括号和右括号来完成这项操作，并且在处理序列的时候，我们从来没有遇到过右括号比左括号更多的情况。
因此，一种简单的实现方法是保持左括号的“平衡”，并确保当我们从左到右扫描字符串的时候它始终为非零。
下面是一个简单的Python函数，它会扫描字符串来确定括号是否平衡。

```Python
# parensBalance1.py
def parensBalance1(s):
    open = 0
    for ch in s:
        if ch == '(':
            open += 1
        elif ch == ')':
            open -= 1
            if open < 0:
                # there is no matching opener, so check fails
                return False
    return open == 0 # everything balances if no unmatched opens
```

到目前为止，这看起来并不像是一个堆栈。
但是，如果我们开始引入了不同类型的括号，事情会变得非常好玩。
例如，数学家（和编程语言设计者）经常会使用多种类型的分组标记，例如圆括号：$()$；方括号：$[]$以及花括号：${}$。
假设它们以这个方程的样子进行混合使用：$[(x + y) * x]/(3 * z)/[ \sin(x) + \cos(y)]$。
这个时候，我们上面的那个简单计数的方法就不起作用了，这是因为我们必须要能够确保每个右括号都要能够和它相对应的正确类型的左括号相匹配。
而且，即使方程里具有相同数量的左括号和右括号，具有这样结构的方程是合法的：
$[()]()$，但方程$[(])()$则是不合法的。
这样的情况下，我们就可以用堆栈来帮助我们完成这个任务了。

为了能够确保使用多个分组符号的时候也能满足平衡和嵌套，我们必须要检查当找到右括号时，它与最近的尚未进行匹配的左括号相匹配。
这是一个非常容易通过堆栈来解决的LIFO（后进先出）问题。
我们只需要从左到右扫描字符串，当找到左括号时，将其推入到堆栈的顶部。
当每次找到右括号时，堆栈的顶部元素必须是与之相匹配的左括号，然后弹出顶部元素。
在完成所有的操作之后，堆栈应该为空。
下面是实现这个功能的相应代码：

```Python
# parensBalance2.py

from Stack import Stack

def parensBalance2(s):
    stack = Stack()
    for ch in s:
        if ch in "([{":         # push an opening marker
            stack.push(ch)
        elif ch in ")]}":       # match closing with top of stack
            if stack.size() < 1: # no pending open to match it
                return False
            else:
                opener = stack.pop()
                if opener+ch not in ["()", "[]", "{}"]:
                    # not a matching pair
                    return False
    return stack.size() == 0    # empty stack means everything matched up
```

图5.1显示了处理方程：${[2 * (7 - 4) + 2] + 3} * 4$的时候，跟踪整个算法执行的中间步骤。
它显示了五个堆栈“快照”，每个快照都包含了到目前为止处理的字符以及它们下面的当前堆栈内容。
你可以手动追踪这个算法，从而向自己证明它的有效性。

图5.1：跟踪括号匹配的示例

### 堆栈的实现

在像Python这样的语言中，实现堆栈的最简单方法是使用内置的列表来完成。
由于Python列表的灵活性，每个堆栈操作都只需要单行代码就能完成。

```Python
# Stack.py
class Stack(object):

    def __init__(self):
        self.items = []

    def push(self, item):
        self.items.append(item)

    def pop(self):
        return self.items.pop()

    def top(self):
        return self.items[-1]

    def size(self):
        return len(self.items)
```

回顾一下，我们之前对Python列表的分析，这里使用的每一个操作都是能够在常量时间内执行的，因此堆栈非常的高效。
当然，在列表末尾插入元素时，有些时候可能会需要额外的工作来创建一个新数组并将所有元素的值都复制到这个新数组中，但Python会自动执行这个操作。
就像在小节3.5.1里所介绍的那样，添加到列表末尾操作的平均时间复杂度是保持不变的，因为数组大小会根据需要按比例增加。

如果没有提供列表类型的话，使用数组来实现堆栈也很容易。
可以通过为堆栈分配所需最大尺寸的数组，并使用一个实例变量来跟踪实际使用了的数组的“空间”，这样我们就能够获得一个有固定的最大尺寸的堆栈了。
如果堆栈的最大尺寸未知，那么`push`（推入）操作就必须要能够在堆栈超过当前数组尺寸的时候，去分配一个更大的数组，并且复制所有的元素。

堆栈的另一个合理的实现策略是，使用单链表的节点来包含堆栈数据。
堆栈对象只需要有一个实例变量就行了，这个变量将会有指向链表的第一个节点的引用，这也就是堆栈的顶部。
和用Python列表一样的是，使用链式结构可以在常量时间内轻松完成推入（`push`）和弹出（`pop`）操作。
同时，我们也建议添加一个实例变量来跟踪堆栈的当前已被使用的大小，从而让`size`操作能够直接返回值，而不用去遍历整个列表里的所有元素。

### 应用程序：处理算术方程

在本节中，我们将会研究一些使用堆栈来处理算术方程的算法。
算术方程的最常用的存储方式被称为*中缀表示法*（*infix notation*）。
方程$(2 + 3) * 4$是中缀表示法的一个示例。
运算符介于两个数字之间。
方程也可以被表现为其他的样子：
$* + 2 3 4$或$2 3 + 4 *$。
第一种表示法被称为*前缀表示法*（*prefix notation*）或*波兰表示法*（*Polish prefix notation*），因为它是由波兰数学家（扬·武卡谢维奇）发明的。
第二种表示法则通常被称为*逆波兰表示法*（*reverse Polish notation*）或*后缀表示法*（*postfix notation*）。

前缀和后缀表示法的优点是不需要通过括号来改变操作的顺序。
中缀方程$3 * (4 + 5) - 2 + (3 * 6)$于后缀方程$3 4 5 + * 2 - 3 6 * +$是等价的。
这是因为，方程本身，就体现了执行操作的顺序。
后缀方程利用堆栈之后，就可以轻松的得出结果。
每次遇到一个数字时，都将它推入（`push`）堆栈。
而遇到运算符时，则会从堆栈中弹出（`pop`）两个数字，把运算符应用于这两个数字，再将结果推入到堆栈之中就行了。

在我们的例子里，在处理三个数字后，堆栈将会包含`<3,4,5>`（顶部在右侧）。
当遇到第一个加号运算符时，我们会弹出`5`和`4`，让他们相加，然后把结果推入到堆栈里。
现在，堆栈里会包含`<3,9>`了。
接着，我们需要处理乘法运算符，我们会弹出`9`和`3`，让它们相乘，然后将结果`27`推入到堆栈里。
在处理`2`之后，堆栈里会包含`<27,2>`。
接下来，我们通过弹出`2`和`27`来处理减法运算符，并且把结果`25`推入堆栈。
处理完下后面的两个数字之后，堆栈里会包含`<25,3,6>`。
然后我们处理乘法运算符，堆栈现在包含`<25,18>`。
最后，在处理完最后一个加号运算符之后，堆栈里包含了最终结果，也就是`43`。
图5.2以图形方式显示了这些步骤。
在图里，方程的下划线部分代表已处理过的输入，于此对应的时间里，堆栈的内容会显示方程的下面。

图5.2：处理后缀方程

由于处理后缀方程的算法非常简单，所以我们在处理更常见的中缀方程的时候应该怎么办呢？
处理它的一种方法是：
先把它转换为后缀方程。
这一步也可以通过简单的堆栈算法实现。
为了解释整个算法，我们先假设我们已经把方程拆分成了由“符号”组成的序列，其中每一个符号都是一个数字、运算符或者括号。
为简单起见，我们的算法还假设这个算术方程在语法上是正确的。
下面的伪代码就是实现了中缀方程到后缀方程的转换器：

```Python
create an empty stack
create an empty list to represent the postfix expression

for each token in the expression:
    if token is a number:
        append it onto the postfix expression
    elif token is a left parenthesis:
        push it onto the stack
    elif token is an operator:
        while (stack is not empty and the top stack item is an operator
              with precedence greater than or equal to token):
            pop and append the operator onto the postfix expression
        push the token onto the stack
    else token must be a right parenthesis
        while the top item on the stack is not a left parenthesis:
            pop item from the stack and append it onto the postfix expression
        pop the left parenthesis

while the stack is not empty
    pop an item from the stack and append it onto the postfix expression
```

图5.3展示了将方程$3 * (4 + 5) -  2 + (3 * 6)$转换为后缀方程的算法步骤。
图里的每一个步骤都显示的是处理过程的状态，这是因为每个步骤都代表着从中缀方程里读取了一个符号。
读者可能不会觉得，这个算法能够适用于所有情况。
一些简单的观察结果能够帮助你更清晰的理解。
首先，要注意的是，前缀方程和后缀方程中的操作数（数字）始终以相同的顺序出现。
其次，后缀方程中运算符的从左到右的顺序对应着中缀方程里的运算的求值顺序。
有了这些观察结果，就能够很容易的理解这个算法了。

图5.3：将中缀方程$3 * (4 + 5) -  2 + (3 * 6)$转换为后缀方程

在处理数字时，它们会立即附加到后缀方程中，因此我们知道数字将保持相同的顺序。
而对于运算符的顺序，可以看到，我们通过将运算符推入（`push`）堆栈来延迟处理运算符符号，从而能够将后面紧跟着的数字先添加到输出的方程里。
因此方程$3 * 4$变成了$3 4 *$。
当存在多个运算符时，输出中的顺序由它们的相对优先级来确定。
首先会执行更高优先级的操作，因此，我们必须将它们在输出的时候添，加在低优先级的运算符之前。
可以考虑处理这个方程的情况：$3 * 4 + 5$。
当我们到达$+$符号的时候，输出序列里会包含`3 4`，而且这个时候堆栈里会包含`<*>`。
然后因为，$*$具有更高的优先级，所以在继续处理后面的符号之前，需要先弹出它并且把它添加到输出序列里，因此这个方程的最终输出结果是$3 4 * 5 +$。
当遇到相同优先级的运算符的时候，将会按照从左到右的顺序添加到输出序列。

然后就剩下了处理括号的情况。
当处理左括号时，会先将它推入堆栈里。
当处理到相匹配的右括号时，我们将会弹出两个括号之间的，还没有被添加到输出序列的所有运算符。
这就保证了：
这些操作符在后缀方程里，会比中缀方程的右括号之后的其他操作符在后缀方程里的位置更靠前。

现在，你应该已经基本了解这个算法的工作原理以及为什么会这么做的理由。
即使你仍然并不能完全地理解它，你依然可以实现前面列出的伪代码。
一般来讲，为软件系统设计算法和数据结构，会比实现它们更加困难。

### 应用程序：语法的处理（选读）

就像处理算术方程那个例子告诉我们的一样，堆栈在操纵——像计算机编程语言这样的——形式语言的时候非常有用。
用来处理计算机和自然语言的句法规则的最常用的工具之一是*上下文无关文法*（*context-free grammar*，*CFG*）。
就像你知道的语法那样，它是一套用来描述语言的合法句子的规则。
上下文无关文法是根据一组重写的规则来定义语言的。

让我们来看一个这样的简单例子。
下面是一套用来描述（非常）短的英语句子的规则。

```Python
1: S -> NP VP
2: NP -> ART N
3: NP -> PN
4: VP -> V NP
5: V -> chased
6: ART -> the
7: N -> dog
8: N -> cat
9: PN -> Emily
```

可以看到，每个规则的形式（定义）都是用箭头来分隔了规则的左侧和右侧。
左侧始终是单个符号，右侧则是一个符号的序列。
第一条规则可以理解为：
一个句子（sentence，`S`）是由名词短语（noun phrase，`NP`）和动词短语（verb phrase，`VP`）组成的。
名词短语和动词短语则由后续的规则来定义。
规则2规定了，组成名词短语的一种方式是冠词（article，`ART`）以及它后面的名词（noun，`N`）。
规则3则提供了另一种组成名词短语的方法：它可以由一个专有名词（proper noun，`PN`）来组成。

我们可以使用这些规则来组成一个简单的句子。
我们先从符号S开始，然后使用规则1来重写它，从而生成序列`NP VP`。
我们继续对符号序列应用这些规则，直到没有可以适用的规则为止。
最后的序列就是我们将会生成的句子。
下面就是一个推导出句子：“狗追逐猫”的示例。
每一行的数字代表在这一步应用了哪条规则。

```Python
     S
=1=> NP VP
=2=> ART N VP
=6=> the N VP
=7=> the dog VP
=4=> the dog V NP
=5=> the dog chased NP
=2=> the dog chased ART N
=6=> the dog chased the
=8=> the dog chased the cat
```

由于在最终序列里，所有的单词都没有出现在我们的示例语法中的任何一个规则的左侧，所以这个句子就不再需要被重写了。
最后产生的序列“狗追逐猫”就是一个由这个语法所生成（或能够被接受）的句子。

用术语来描述的话：
出现在语法规则左侧的符号被称为*非终结*（*non-terminal*）符；
而只在右侧出现的符号则被成为*终结*（*terminal*）符。
重写不断重复，直到我们得到了一个完全由终结符组成的序列。
因此，终结符集（在这种情况下都是单词）就是一个可以出现在由这个语法所描述的语言的句子中的符号。
非终结符并不是所描述语言的一部分，它是语法本身的内部组件。
你可以将非终结符看作描述这个语言的短语类型。
相比之下，自然语言会是：名词短语和动词短语这样的类别；
类似的，编程语言会有：表达式和语句这样的类别。

上下文无关文法与堆栈数据结构密切相关。
事实上，理论计算机科学中一个有趣的结果表明：
能够被特定语法描述的语言集合，也完全可以能够被*下推自动机*所识别，下推自动机是一种基于堆栈的有限自动机。
在现实里，这就意味着许多语言处理任务，比如说：分析计算机程序的语法，或者是理解自然语言的句子，通常都能够采用基于堆栈的算法。

为了说明这一点，我们将通过设计一个简单的语法抽象数据类型，让我们能够使用上下文无关文法来生成句子。
我们的语法类将会使用一个非常简单的API来管理一组语法规则。
要创建一个语法，我们会向最初为空的`Grammar`对象添加一系列规则。
比如，像下面这个交互式操作这样，我们就能创建在上面看到的示例语法：

```Python
>>> gram = Grammar()
>>> gram.addRule("S -> NP VP")
>>> gram.addRule("NP -> ART N")
>>> gram.addRule("NP -> PN")
```

一旦我们创建了一个语法，我们就希望能够从语法中生成一个随机的短语和句子。

```Python
>>> gram.generate("ART")
'the'
>>> gram.generate("N")
'dog'
>>> gram.generate("VP")
'chased the cat'
>>> gram.generate("S")
'the cat chased the dog'
```

可以看到，`generate`方法将会把语法里的非终结符作为参数，然后生成一个以这个非终结符开始的短语。
为了生成一个完整的句子，我们需要使用参数`"S"`。

让我们来尝试设计这个类。
在第一个步，我们可以使用Python列表来存储我们的语法规则。
虽然规则是按照字符串的形式呈现的，但从结构上来说，它们实际上是由：左侧的单个非终结符和右侧的一系列非终结符和终结符组成的。
我们可以把每个规则都表示为一个有序对`(non-terminal, expansion)`（非终结符，扩展结果），其中的扩展结果就是右侧的符号列表。
我们可以把这些有序对保存在列表里，来存储语法的所有规则。
这是我们的类的构造函数：

```Python
# Grammar.py
from Stack import Stack

class Grammar(object):

    def __init__(self):
        self.rules = []
        self.nonterms = []
```

`nonterms`列表将会追踪语法里的所有的非终结符（出现在任何规则左侧的符号），从而能够让我们在后面区分终结符和非终结符。

要在语法中添加规则，我们只需将其拆分为它的组成部分，再把它们添加到`rules`（规则列表）里就行了。
同时在需要的时候，去更新`nonterms`列表。

```Python
    def addRule(self, rule):
        # split the rule at the arrow
        lhs, rhs = rule.split("->")

        # extract the non-terminal, ignoring spaces
        nt = lhs.strip()

        # split the rhs into a list of symbols and reverse it
        symbols = rhs.split()
        symbols.reverse()

        # pair the non-terminal with the symbol sequence and store it
        self.rules.append((nt, symbols))

        # update the non-terminal list
        if nt not in self.nonterms:
            self.nonterms.append(nt)
```

这段代码中唯一比较奇特的地方是：
在存储到规则列表的时候，规则的右侧数据是反向存储的。
这样做是为了让后面基于堆栈的处理更简单。
右侧的序列将会被先推入堆栈，而且我们希望在这个序列里的最左侧的符号能够在堆栈的顶部，所以推入的顺序是把原始规则列表的从右到左一一推入。
在推入的时候就进行了这个反转，就能够让我们在每次使用规则的时候，都不用再去进行反转了。

现在我们准备生成句子了。
如果你回到“狗追逐猫”这个句子的推导示例，你就会注意到：我们总是选择在序列里扩展最左边的非终结符。
这就意味着，我们总是再处理这样一个（可能是空的）句子：
它开始的时候是一串单词序列，然后跟一系列非终结符，这些非终结符还需要被继续扩展才能完成整个句子。
我们可以使用堆栈来模拟剩下的非终结符，其中最左侧的非终结符会处于堆栈的顶部。
这样，我们开始执行这样一个循环：
从堆栈中弹出在顶端的元素，如果它是一个终结符（一个单词），那么我们将它添加到输出序列里。
如果是一个非终结符的话，我们选择一个规则来扩展它，并且把扩展结果（规则右侧的符号）推入到堆栈里。
当堆栈为空时，我们就完成了扩展，也就是产生了句子。

这就是实现整个算法的Python代码：

```Python
    def generate(self, start):
        s = Stack()
        s.push(start)
        output = []
        while s.size() > 0:
            top = s.pop()
            if self.isTerminal(top):
                # doesn’t expand, it’s part of the output
                output.append(top)
            else:
                # choose one expansion from all that might be used
                cands = self.getExpansions(top)
                expansion = random.choice(cands)
                # push the chosen expansion onto the stack
                for symbol in expansion:
                    s.push(symbol)
        return " ".join(output)

    def isTerminal(self, term):
        return term not in self.nonterms

    def getExpansions(self, nt):
        expansions = []
        for (nt1, expansion) in self.rules:
            if nt1 == nt: # this rule matches
                copy = list(expansion)
                expansions.append(copy)
        return expansions
```

可以看到，输出序列是使用列表来构建的。
之后，把整个列表里的所有单词连接（`join`）成一个字符串，再把整个字符串作为函数的结果返回。
还有一点需要注意的是，我们用了一些辅助方法来简化整个代码。
`getExpansions`方法会去查看规则集，从而找到规则左侧和当前非终结符相匹配的所有规则。
然后，它会返回一个包含所有与整个非终结符相对应的右侧的列表。
现在我们就有了一个：能够根据上下文无关文法生成随机句子的完整的类。
你可以尝试编写一些简单的语法，然后看看你能生成的句子。

## 队列

根据元素到达的时间来对它进行排序的另一种常见的数据结构是：*队列*（*queue*）。
堆栈是后进先出的结构，而队列的顺序则是先进先出（first in, first out，FIFO）。
毫无疑问的，你非常熟悉这个概念，这是因为你经常在队列里花费时间。
当你来到餐馆或商店，人非常多的时候，你就和其他人一起排起了长队。
对了，英式英语的使用者们不会排起长队，他们会“在队列等候”。

### 队列抽象数据类型

从概念上来说，队列是一种允许两端受限访问的顺序结构。
元素可以在一端被添加，但是只能在另一端被删除。
和其他情况一样，计算机科学家们对这些操作都有他们自己的术语。
将元素添加到队列的后面被称为`enqueue`（进队），从前面删除元素的操作则被称为`dequeue`（出队）。
和堆栈一样，队列也能够很方便的查看最前面的元素而不必删除它。
这个元素通常被称为`front`，但有时候也会使用其他术语来表示，比如说：`head`或者`first`。

下面就是关于队列抽象数据类型的规范：

```Python
class Queue(object):

    def __init__(self):
        """post: creates an empty FIFO queue"""

    def enqueue(self, x):
        """post: adds x at back of queue"""

    def dequeue(self):
        """pre: self.size() > 0
           post: removes and returns the front item"""

    def front(self):
        """pre: self.size() > 0
           postcondition: returns first item in queue"""

    def size(self):
        """postcondition: return number of items in queue"""
```

### 队列的简单应用

队列通常在计算机编程中被用来，当作计算过程的不同阶段之间的一种缓冲。
比如，当你打印文档的时候，你的“作业请求”将被放置在计算机操作系统的队列中，而且这些作业通常以先到先得的方式进行顺序打印。
在这个例子里，队列被用来协调横跨不同进程（请求打印的应用程序，和实际向打印机发送指令和信息的计算机操作系统）的操作。
队列也经常被单个计算机程序用来当作中间部分——数据传输站点。
比如，编译器或解释器可能需要对程序进行一系列的“传递”工作，从而能够把代码转换成为机器代码。
第一个传递工作通常是所谓的*词法分析*（*lexical analysis*），它能够把程序分成一段段有意义的部分，也就是符号。
这些符号组成的序列则会被用于下一阶段的后续处理，通常来说是某种基于语法的句法分析。
因此，队列是用来存储符号序列的完美的数据结构。

一个使用队列用于中间部分的数据结构的例子是，考虑一个短语是否是回文的问题。
回文是这样的一个句子或短语：
这个句子或者短语，不论向前还是向后阅读，都具有相同的字母序列。
一些著名的例子是：“女士，我是亚当”（“Madam, I’m Adam”）或者是“我更喜欢PI”（“I prefer PI.”）。
像“赛车”（“racecar”）这样的词语，它本身就是回文。
让我们编写一个程序来分析用户的输入并判断它是不是为回文。
这个程序的核心部分就是`isPalindrome`方法：

```Python
def isPalindrome(phrase):

    """pre: phrase is a string
       post: returns True if the alphabetic characters in phrase
             form the same sequence reading either left-to-right
             or right-to-left.
    """
```

`isPalindrome`方法最麻烦的地方在于，短语的回文性质仅仅是由字母来决定的。
其中的空格、标点符号和大小写都不重要。
我们需要从两个方向上来看字母序列是否相同。
解决这个问题的一种方法是把这个问题分解成几个阶段。
在第一个阶段，我们去除掉无关的部分，从而让这个字符串简化成只有它组成的字母的情况。
然后，第二个阶段的时候，我们就可以从前后两个方向上来比较字母序列了，也就能知道它们是否相同了。
队列数据结构可以很方便的，被用来存储字符，从而能够按照原始的顺序再次访问它们。
而同时，堆栈也可以很方便的，被用来存储这些字符，从而能够让我们以相反的顺序访问它们（堆栈会反转它的数据）。

把这个两阶段算法写成一个Python程序，就能得到下面这样的结果：

```Python
# palindrome.py
from MyQueue import Queue
from Stack import Stack

def isPalindrome(phrase):
    forward = Queue()
    reverse = Stack()
    extractLetters(phrase, forward, reverse)
    return sameSequence(forward, reverse)
```

现在我们就只需要定义这两个函数：`extractLetters`和`sameSequence`，来实现两个阶段的算法就行了。
前面这个方法必须要处理整个短语，并把这个短语里的每一个字母都添加到中间数据的堆栈和队列里。
这里有一种实现的方法：

```Python
import string
def extractLetters(phrase, q, s):
    for ch in phrase:
        if ch.isalpha():
            ch = ch.lower()
            q.enqueue(ch)
            s.push(ch)
```

`sameSequence`函数则需要比较堆栈和队列上的字母。
如果所有字母都匹配的话，代表着我们有一个回文。
然而，一旦有任意两个字母不相等的话，我们就能够知道我们的短语没能通过测试。

```Python
def sameSequence(q, s):
    while q.size() > 0:
        ch1 = q.dequeue()
        ch2 = s.pop()
        if ch1 != ch2:
            return False
    return True
```

有了这个`isPalindrome`方法，你现在应该能够轻松的完成我们的回文检查程序了。
试试看这两个例子：“我能够，我看到厄尔巴岛”（“Able was I, ere I saw Elba”）和“邪恶就是我，我看到了猫王”（“Evil was I, ere I saw Elvis”）。很明显，这两个例子里只有一个是真正的回文。
在互联网上随便搜搜，都能够找到很多有趣的测试数据。
队列，你还需要实现队列才能能够让你的程序可以正常运行。
后面的内容会有一些关于实现的提示。

## 队列的实现

使用Python的内置列表实现队列非常简单。
我们只需要在列表的一端插入再从另一端进行删除就行了。
由于Python列表是用一个数组来实现的，所以，如果列表很长的话，那么在列表开头进行插入操作是一个非常低效的操作。
而且，从列表的开头删除一个元素也是非常低效的。
所以这两种选择都不太理想。

另一种实现的方案是使用链接。
元素序列可以用单链表来维护。
然后，队列对象自己分别对指向队列的第一个和最后一个节点的引用维护一个的实例变量就行了。
只要我们在链表的末尾进行插入并从前面进行删除，这两个操作都可以在常量（$Θ(1)$）时间内轻松完成。
当然，链接的实现代码会要复杂得多。
在用这个或其他办法之前，考虑一下著名计算机科学家托尼·霍尔（Tony Hoare）的话可能会比较明智：
“过早的优化是所有邪恶的根源。”
这个陈述有很多理由。
比如：在确定瓶颈是什么（即大多数时间都会花在哪里）之前，去思考优化代码是没有任何意义的。
还有，如果把只占程序总执行时间5%的代码的运行速度翻倍了，那么整个程序的执行速度仅仅会提高大约3％。
但是，如果把占程序总执行时间50%的代码的运行速度都翻倍了，那么整个程序的执行速度将会提高大约33％。
就像我们已经看到过的二分搜索算法一样，更高效的代码通常更复杂，也就更难编写正确。
在你思考把特定部分的代码段变得更有效之前，你应该确保它会对整个程序的速度产生重大影响。

要在Python里实现队列，还需要考虑Python列表的操作是用非常高效的C语言代码编码的，而且它可以利用系统级调用来快速移动内存块。
从理论上来说，我们也许能够编写具有更好的渐近（$θ$）行为的利用链接的代码，但在链表实现的代码性能超越优化过的Python列表代码之前，队列的尺寸必然会非常的大。
编码链式队列实现是使用链式结构的一个很好的练习，但是在实际使用中，它的性能并不会过分高于基于内置列表实现的队列。

在支持固定大小数组的C/C++以及Java等语言中，数组通常是用来实现队列的最适当结构，特别是在如果提前知道队列的最大尺寸的情况下。
我们可以通过跟踪队列的前面/头部以及后面/尾部的索引，而不是通过在`enqueue`（入队）和`dequeue`（出队）操作的时候移动整个数组中的元素来实现我们的队列。
这样，只要能保证队列在任何一个时间点的最大元素数量都不超过数组的尺寸，这就是实现队列的绝佳方法。
每次将元素添加到队列的时候，尾部（`tail`）索引都会增加`1`。
如果我们在加`1`的同时还使用了模数运算符，那么我们就可以轻松地将索引绕回到数组的开头，也就模拟出了一个循环数组的存储方式。
对于尺寸为`10`的数组，我们可以像这样来增加尾部索引：

```Python
tail = (tail + 1) % 10
```

由于索引位置式从`0`开始的，因此最后一个位置是索引`9`。
当我们把1加到`9`上时，我们就会得到`10`，而`10`在`10`的模数（余数）正好是0。
这就是许多计算机算法里在达到最大值后用来绕回到`0`的常用技术。
当元素出队（`dequeue`）的时候，我们可以把相同的技术用来增加`head`（头部）索引。
这样的结果就是：`head`（头部）索引会在数组里一圈一圈的追赶`tail`（尾部）索引。
只要还有元素留在队列中，`head`（头部）索引永远不会追上`tail`（尾部）索引。

在Python里，也可以简单地通过从适当大小的列表开始来使用循环数组技术。
有一种简单的方法可以被用来执行列表的复制。

```Python
...
self.items = [None] * 10
```

队列的循环数组/列表方法有一个微妙的地方。
我们需要仔细考虑一下，在队列为满或空的情况下，`head`（头部）索引和`tail`（尾部）索引的值。
为了保证我们所做的是正确的，为这个类写一个和这些值相关的不变量，是一种很好的技巧。
我们希望`head`（头部）索引能够指示队列中的前面的元素所在数组中的位置。
`tail`（尾部）索引则应该指示队列中最后一个元素的位置，或者是下一个可插入队列的元素的位置。
当队列为空时，我们并不清楚`head`（头部）索引和`tail`（尾部）索引的值应该是什么。
这是因为我们使用的是循环数组，因此`tail`（尾部）索引的值可能会小于`head`（头部）索引。
插入几个元素之后，再去删除这些元素，会让`head`（头部）索引和`tail`（尾部）索引位于数组/列表的中间。
因此，我们不能使用任何`head`（头部）索引和`tail`（尾部）索引的绝对值来代表空队列。
与此相反，我们应该用它们的相对值来做判断。

假设一开始我们的空队列的`head`（头部）索引和`tail`（尾部）索引都设置为`0`。
那么很明显，当`head == tail`的时候队列为空。
假设循环数组的大小为$n$。
现在，让我们考虑一下，如果在没有任何队列的情况下入队$n$个元素会发生什么。
当`tail`（尾部）索引指针增加$n$次的时候，它将会绕回到0。
因此，对于一个满队列，我们还是有这个条件`head == tail`。
这就导致了一个问题。
由于满队列和空队列“看起来”完全相同，我们并不能够通过查看`head`（头部）索引和`tail`（尾部）索引的值，来判断我们现在处于什么情况之下。
我们可以通过简单地让“满”队列仅仅包含$n-1$个元素来避免这种情况的发生，但这样就会浪费一个单元格。
甚至，还有一个更简单的方法可以做到这一点，就是使用一个额外的实例变量来跟踪队列中的元素的个数。
这种方法能够让我们得到下面这个不变量：

1. 实例变量`size`表示队列中的元素数量，有`0 <= size <= capacity`，其中`capacity`是数组/列表的固定尺寸。
2. 如果$size > 0$，对于$i$在`range(size)`里的情况下，在位置`[(head + i) % capacity]`可以找到队列里的元素，其中`items[head]`是队列的最前面，队列的尾部则是`tail == (head+size-1) % capacity`。
3. 如果有`size == 0`，则会有`head == (tail + 1) % capacity`。

利用这个不变量，你应该能够不用太费多少力气，就可以完成队列的循环列表实现了。

## 应用程序示例：队列的模拟（选读）

队列的一个常见用途是对真实世界的队列行为进行建模。
你可以在世界各个地方都能找到队列，从银行，到剧院，再到洗车的地方，装配线和餐厅，统统都有。
在我们的下面的例子里，让我们看看这样一个只有一个结账点的零售店——时尚的妈妈。
这家商店最近生意越来越好，客户已经开始抱怨他们排队等待的时间越来越长了。
店主正在就两个不同的方案进行思考：
是否应该升级结账点，从而能够让单个收银台能够更快速地工作；
或者是否应该改造商店布局，从而能够让它可以有更多个的结账窗口。
很明显，后一种方案成本会高很多，而且她现在并不知道这样做是不是物有所值。

我们可以编写一个模拟商店结账队列的模型，以便能够尝试各个选项来回答这些问题：
比如，客户平均排队等待的时间，等待的最长时间，以及排队的队伍有多长？
我们还可以参数化我们的模拟，从而让我们可以尝试不同的结账率，这样就能够查看更快的结账所可能带来的影响。
我们的模拟将体现一个非常重要的应用数学领域的一个分支，它被称为运筹学。

我们的模拟将会是一个简单的结账流程模型。
客户在到结账台排队的时候，会有一定数量的商品，然后他们会按照到达的顺序来结账。
很明显，客户不会以恒定的速度到达。
他们的来来往往有一定的随机性。
类似的，根据客户购买的商品的数量和类型的不同，客户的结账时间也会随机变化。
和任何模拟一样，我们必须要抽象掉大部分具体的细节，从而能够让我们可以模拟问题的核心。

首先，我们需要一些方法来跟踪时间的流逝。
抽象地来说，我们使用的时间单位其实无关紧要，我们只是需要选择一个适合我们模拟的内容的时间单位就行了。
以秒为单位来测量处理客户的时间似乎很方便，然而我们可以通过使用“时钟节拍”来让我们的模型变得更加的通用。
对于我们的模拟，一个节拍可能是一秒；
对于计算机系统的模拟，一个节拍就可能是一毫秒；
对于气候的模拟，一个节拍则可能是一年。
我们的模拟将从时间0开始，我们将对一个计数器进行递增来表示时间的流逝。

现在我们需要考虑如何代表客户。
最终，我们感兴趣的是他们花了多少时间排队。
如果我们有一个能够跟踪当前时间的`time`（时间）变量的话，我们就能够通过查看这个“时钟”，来知道我们开始处理这个客户的购买商品是什么时候。
如果我们还知道了他们到达的时间，那么一个简单的减法就能够告诉我们他们等了多久。
我们还需要知道，客户的结账时间，因为在我们必须要经过那么多时间才能开始处理下一个客户。
我们可以简单地通过将多个商品与每个客户进行关联，然后将这个商品数量乘以处理单个商品的平均时间来对此进行建模。
因此，在最后我们决定需要知道关于每个客户的信息有两条：
他们到达时间（`arrivalTime)`）以及他们拥有的商品数量（`itemCount`）。

我们模拟的原始数据将是一系列随机生成的拥有不同到达时间和商品数量的客户。
为了使模拟尽可能的逼真，运营研究人员将会利用依靠统计模型来模拟现实世界的方式来产生事件。
例如，如果我们要查看像`itemCount`（商品数量）这样的简单变量，我们可以分析实际的客户的样本，从而得到在商店购物的客户所购买的商品的“平均”数量。
但这个平均值并不能说明整个故事。
因为，并不是每个客户都会买平均数量的商品。
各个人的购物车里的实际商品数量应该会分布在这个平均值附近。
这个问题还能进一步复杂化，因为这个分布可能并不对称，这是由于客户可以拥有的商品数量最少为`1`，但是他们可以拥有的商品数量（实际上）并没有上限。
这样的现象也适用于客户的到达时间。
它们到达的时间会有一定的平均值，但它们不会以固定的比例出现。
有些时候他们会聚集在一起，而有些时候整个商店里并不会有很多的人。

由于这不是一本关于运筹学的书，我们将用一些相当简单的方法来生成我们的客户序列。
我们假设客户购买的商品数量均匀分布在`1`和一个可设置参数`MAX_ITEMS`之间。
这时，我们就可以使用Python的`randrange`函数来为每个客户生成一个随机的`itemCount`。
我们将通过一个平均到达率来设置客户的到达时间，然后使用标准正态随机生成器来得到客户实际到达的时间。
有了这么多的分析之后，我们已经准备好编写代码，来生成事件序列（客户到达结账处）了，这些代码所生成的序列将作为我们模拟的输入。

我们可以在运行这个模拟的时候，就像在现实世界中发生的那样，“持续不断”地生成到达事件。
但是，我们如果首先生成事件序列，然后把这些信息保存到文件中的话，会给我们更多的优势。
首先，它允许我们在完全相同的事件序列上尝试不同的模拟。
比如，对于预生成的事件序列，我们可以对两种不同的结账速度进行模拟，这样就能够对差异进行从头到尾的比较了。
另一个优点是，它可以把模拟本身分成两个阶段，从而能够让我们在这之后可以修改输入数据的生成方式。
比如说，我们可能会用不同的概率分布来代替现有的分布，而这样的修改并不需要对模拟代码进行任何的改变。

让我们编写一些代码来生成我们的客户信息，来让整个模拟更加具体。
就像之前说的，我们只需要为每个客户生成`arrivalTime`和`itemCount`就行了。
我们会把这个信息保存在文件里，文件的每一行会对应一个事件。
每行里都包含了一个`arrivalTime`，在它后面跟着的是`itemCount`。
下面就是示例文件的前几行：

```Python
49 39
143 20
205 26
237 44
```

从这些数据里，我们可以知道，第一个客户有`39`个商品，在时间`49`的时候到达。
而后，第二个客户有`20`个商品，在时间`143`的时候到达，依此类推。
可以看到，`arrivalTimes`将会按照递增顺序列出。

这是生成模拟数据的函数：

```Python
# simulation.py
from random import random, randrange

def genTestData(filename, totalTicks, maxItems, arrivalInterval):
    outfile = open(filename, "w")
    # step through the ticks
    for t in range(1, totalTicks):
        if random() < 1./arrivalInterval:
            # a customer arrives this tick
            # with a random number of items
            items = randrange(1, maxItems+1)
            outfile.write("%d %d\n" % (t, items))
    outfile.close()
```

在参数列表里：
`filename`代表输出文件的文件名；
`totalTicks`是模拟运行的总时间长度；
`maxItems`是客户将会购买的商品数量的上限；
而`arrivalInterval`表示客户到达的平均节拍。
假设这个商店通常来说，平均每小时大约`30`名顾客。
也就是说每两分钟会进来一个客户。
如果我们的节拍代表的是一秒的话，那么我们预计客户与客户之间会有大约`120`个刻度。
请仔细看看，这段代码里是如何处理到达时间的。
如果我们期望每`120`个刻度有一个客户，那么对于每个刻度来说，客户到达的可能性为`120`分之`1`。
而表达式`random() < 1./arrivalInterval`将会以$1 / arrivalInterval$的概率成功（计算结果为`True`）。
这也就赋予了我们程序有了客户到达的随机事件，从长远来看，到达时间还是以期望的速率发生的。
如果要生成一个三小时的模拟，并且在模拟里，平均每两分钟会有一个客户购买最多50个商品，我们应该这样调用函数：

```Python
genTestData("checkerData.txt", 3 * 60 * 60, 50, 120)
```

我们的模拟程序将在客户开始排队的时候与他们打交道。
从程序的角度来看，无论客户数据是从文件中读取、还是由其他程序实时提供、亦或是任何其他的过程，这对于模拟程序来说都是无关紧要的。
因此，这是一个使用队列来作为创建数据和模拟结账的这些进程之间的媒介的理想场所。
首先，让我们创建一个`Customer`（客户）类来封装每个客户的详细信息：

```Python
class Customer(object):

    def __init__(self, arrivalTime, itemCount):
        self.arrivalTime = int(arrivalTime)
        self.itemCount = int(itemCount)

    def __repr__(self):
        return ("Customer(arrivalTime=%d, itemCount=%d)" %
                (self.arrivalTime, self.itemCount))
```

由于我们的客户信息是只包含了`arrivalTime`和`itemCount`数据的“记录”，因此我们在后面将会直接访问这里的信息（例如，`customer.itemCount`）。
`__repr__`方法为客户（`Customer`）类提供了一个清晰的可打印输出方式。
于是我们可以很方便地在测试和调试期间检查我们的数据结构。
现在，编写一个用来导入数据文件，并且创建相应的客户事件队列的函数，就很简单了：

```Python
def createArrivalQueue(fname):
    q = Queue()
    infile = open(fname)
    for line in infile:
        time, items = line.split()
        q.enqueue(Customer(time,items))
    infile.close()
    return q
```

实际的模拟将会在`CheckerSim`对象中执行。
它的构造函数接受一个事件队列和平均商品处理的时间来作为参数。
下面是`CheckerSim`类的一种实现方法：

```Python
# CheckerSim.py
from MyQueue import Queue

class CheckerSim(object):

    def __init__(self, arrivalQueue, avgTime):
        self.time = 0 # ticks so far in simulation
        self.arrivals = arrivalQueue # queue of arrival events to process
        self.line = Queue() # customers waiting in line
        self.serviceTime = 0 # time left for current customer
        self.totalWait = 0 # sum of wait time for all customers
        self.maxWait = 0 # longest wait of any customer
        self.customerCount = 0 # number of customers processed
        self.maxLength = 0 # maximum line length
        self.ticksPerItem = avgTime # time to process an item

    def run(self):
        while (self.arrivals.size() > 0 or
               self.line.size() > 0 or
               self.serviceTime > 0):
            self.clockTick()

    def averageWait(self):
        return float(self.totalWait) / self.customerCount

    def maximumWait(self):
        return self.maxWait

    def maximumLineLength(self):
        return self.maxLength

    def clockTick(self):
        # one tick of time elapses
        self.time += 1
        # customer(s) arriving at current time enter the line
        while (self.arrivals.size() > 0 and
               self.arrivals.front().arrivalTime == self.time):
            self.line.enqueue(self.arrivals.dequeue())
            self.customerCount += 1
        # if line has reached a new maximum, remember that
        self.maxLength = max(self.maxLength, self.line.size())
        # process items
        if self.serviceTime > 0:
            # a customer is currently being helped
            self.serviceTime -= 1
        elif self.line.size() > 0:
            # help the next customer in line
            customer = self.line.dequeue()
            #print self.time, customer # nice tracing point
            # compute and update statistics on this customer
            self.serviceTime = customer.itemCount * self.ticksPerItem
            waitTime = self.time - customer.arrivalTime
            self.totalWait += waitTime
            self.maxWait = max(self.maxWait, waitTime)
```

我们可以通过调用这个类的`run`方法来执行模拟。
这个方法会执行一个调用`clockTick`的循环，直到整个模拟完成为止。
这种特殊方法是*时间驱动模拟*的一个例子。
我们只需将时钟一次增加一个节拍，然后执行在这个刻度里必须要完成的任务就行了。
`arrivalQueue`（到达队列）中发生的任何事件都会传递到`line`（队伍）里。
如果收银台当前正在服务一个客户，那么处理客户商品所需的时间会被存储在`serviceTime`中。
这时，我们只需要减少这个变量的值就行了。
如果服务时间为`0`了，也就代表收银台可以开始服务下一位客户了。
如果`line`（队伍）空了，收银台就不用去做任何操作。
你应该仔细研究这段代码，保证自己了解了它的工作原理。

对于这个特定问题来说，时间驱动的解决方案或许不一定是最好的方法。
我们在时钟节拍的循环里，许多周期基本上都是空闲时间。
另一种方案是使用*事件驱动模拟*（*event-driven simulation*）。
事件驱动方法背后的想法是：
我们并不需要时钟的每个节拍都进行建模，而会直接“跳到”下一个必须处理的事件上就行了。
比如说，如果排队的下一个客户需要50个节拍来处理，我们实际上不需要将时钟一个节拍一个节拍的运行50下，我们可以直接推进这50个节拍。
当然，这也就意味着，我们必须要向队伍里添加这50个节拍的窗口中所有的到达事件。
时间驱动的版本很容易理解，但事件驱动的方法的优点是：
对于每一个客户，我们都只需要一次循环，而不用对每一个时钟节拍循环一次。
时间长度为三个小时的模拟会涉及到10,800个刻度，然而客户数量可能会少于100个。
因此，事件驱动可以节省很多时间。
完成我们这个模拟的事件驱动版本将会是一项练习题。

## 章节总结

这一章里，我们讨论了两个简单但非常常见的数据结构：堆栈和队列。
这些结构的关键思想的是：

* 堆栈是一个顺序容器，它只允许访问一个元素，这个元素被称为堆栈的“顶部”。
堆栈以后进先出（LIFO）的方式添加和删除元素。
堆栈会自然而然地反转序列，并且支持这些标准操作：
`push`、`pop`、`top`和`size`。

* 堆栈的应用程序包括：维护“撤消”列表，在正在运行的程序中的跟踪函数调用，以及检查分组符号的正确嵌套。

* 使用基于列表，基于数组或者基于链表的技术可以轻松实现堆栈。

* 方程可以使用前缀，中缀或后缀表示法来存储。
基于堆栈的算法可以让方程在不同表示法之间切换，也可以用来计算方程的结果。

* 上下文无关文法（CFG）是一种用来表示各种语言的语法的简单形式。
CFG与基于堆栈的计算密切相关。

* 队列是一个顺序容器对象，它能够允许对序列的前面和后面进行受限访问。
元素只能被添加到序列的后面，并且只能从序列的前面被移除。
队列是先进先出（FIFO）的结构。
队列支持这些标准操作：
`enqueue`、`dequeue`、`front`和`size`。

* 队列被广泛用于不同计算过程或单个过程的不同阶段之间的“缓冲区”。

* 使用Python列表实现的队列对于入队或出队操作都是$Θ(n)$的时间复杂度，但是，对于大多数应用程序来说，这也可能足够高效了。
通过利用循环数组或者用链表来实现对联，会让所有的操作都提供$Θ(1)$的时间复杂度。

* 队列的一个用途是模拟运营研究。
这种模拟可以是时间驱动的，也可以是事件驱动的。
时间驱动的模拟一次增加一个模拟时钟节拍，并检查每个时钟节拍点所发生的事件。
事件驱动的模拟一次处理一个事件，并用处理下一个事件之前经过的时间量来调整时钟节拍。

## 练习

**判断题**

1. 元素会按照他们进入堆栈的顺序从堆栈里出来。

2. 将元素添加到堆栈的操作被称为`push`（推入）。

3. `top`操作不会修改堆栈的内容。

4. 如果方程里包含相同数量的左括号和右括号，那么这个方程所有的括号对是平衡的。

5. Python列表不是实现堆栈的一个非常好的选择。

6. 元素会按照它们进入队列的顺序从队列中出来。

7. 队列允许检查任意一端的元素。

8. 从队列前面删除元素的操作被称为`front`。

9. 单词“Racecar”是一个回文。

10. 使用Python列表上的插入和弹出操作实现的队列对所有操作都有$Θ(1)$的时间复杂度。

**选择题**

1. 根据定义，堆栈必须是一个

    a) FIFO结构

    b) LIFO结构

    c) 链式结构

    d) 基于数组的结构

2. 以下哪项不是堆栈操作？

    a) `push`（推入）

    b) `unstack`（拆散）

    c) `pop`（弹出）

    d) `top`（顶端）

3. 以下哪项不是利用堆栈实现的应用程序？

    a) 为“撤消”功能来跟踪操作的历史记录。

    b) 在正在运行的程序中跟踪函数调用。

    c) 检查括号的正确嵌套。

    d) 以上所有都是利用堆栈实现的应用程序。

4. 计算后缀方程$5 4 3 + 2 * -$的结果是什么？

    a) $-2$

    b) $3$

    c) $15$

    d) 这些都不是

5. $3 + 4 * 5$的正确后缀形式是什么？

    a) $3 4 + 5 *$

    b) $3 4 * 5 +$

    c) $3 4 5 + *$

    d) $3 4 5 * +$

6. 根据定义，队列必须是一个

    a) FIFO结构

    b) LIFO结构

    c) 链式结构

    d) 基于数组的结构

7. 以下哪项不是队列抽象数据类型的操作？

    a) `enqueue`（入队）

    b) `dequeue`（出队）

    c) `requeue`（重新排队）

    d) `front`（前部）

8. 队列的哪个实现不能保证所有操作都有$Θ(1)$的时间复杂度：

    a) 循环列表/循环数组的实现。

    b) 具有前后引用的链表实现。

    c) 使用Python列表的`insert`和`pop`的实现。

    d) 上面的所有实现都能够有$Θ(1)$的时间复杂度。

9. 将字符串拆分为有意义的部分的过程被称为

    a) 分隔。

    b) 语义阶段。

    c) 句法阶段。

    d) 词法分析。

10. 使用链表实现的队列里，应该在哪里插入新元素？

    a) 在链表的前面（头部）

    b) 链表的末尾（尾部）

    c) 在链表的中间

    d) 选项a) 或b) 都能起作用

**简答题**

1. 用下列方法实现的堆栈的方法的运行时分析是什么？

    a) 链表实现。

    b) Python列表实现。

2. 根据方程中的符号的数量，中缀到后缀转换的运行时分析是什么？

3. 用下列方法实现的队列的方法的运行时分析是什么？

    a) Python列表（非循环）实现。

    b) 循环列表/数组实现。

    c) 只有头部引用的链表实现。

    d) 具有头部引用和尾部引用的链表实现。

4. 假设你有这样一种编程语言，它里面的唯一的内置容器类型是：堆栈。
解释去如何实现下面的各个抽象数据类型，并为提供基本操作的运行时间。
请尽量提出最有效的实现方案。
提示：你可能会使用多个堆栈来实现给定的抽象数据类型。

    a) 队列

    b) 基于游标的列表

    c) 基于索引的列表（随机访问）

5. 使用收银台模拟来验证不同的场景。
按照平均到达率接近平均购买率的情况下，你认为的排队队伍的最大长度是什么？
运行一些模拟来验证你的假设。

**编程练习**

1. 为堆栈和队列都实现一个类，并且为这个类编写相应的单元测试代码。
使用你实现的堆栈类和队列类来测试本章里的回文程序。

2. 实现本章里描述的中缀到后缀转换的算法。

3. 编写一个接受有效后缀方程，并对其进行求值计算的函数。

4. 假设正在使用队列来存储数字，我们想要查看当前队列中的数字是否有序。
编写并测试函数`queueInOrder(someQueue)`，这个函数会返回一个布尔值，用来表示`someQueue`是否是按照顺序排列的。
调用这个函数之后，队列应该与被函数调用之前完全一样。
你的函数应该只使用可用的队列抽象数据类型的操作。
并不允许访问队列的底层存储方式。

5. 超文本标记语言（HTML）是用于描述网页内容的符号。
最新的HTML标准是XHTML。
网络浏览器会读取HTML/XHTML来确定应该如何显示网页。
HTML的标记括在尖括号（`<`和`>`）之中。
在XHTML里，标记通常按照开始标记和结束标记这样成对的出现。
开始标记的格式为`<name attributes>`。
与之相匹配的结束标记则只包含以`/`开头的标记名称。
例如，一段文本可能的会像下面这样的格式：

    ```HTML
    <p align="center"> This is a centered paragraph </p>
    ```

    XHTML同时还允许使用`<name attributes />`这样的自闭合标签。
    在一个合格的XHTML文件里，标记将总会以正确的嵌套对出现。
    每个开始标记都有一个与之相应的结束标记进行匹配，并且一个结构可以嵌入到另一个结构内。
    但是，不同结构之间不能相互重叠。
    例如`<p> ... <ol> ... </ ol> ... </ p>`是可以的，但是`<p> ... <ol> ... </ p> ... </ ol>`就不是一个合法的XHTML文件了。
    自闭合标记相当于它自己就包含的开始标记和结束标记。

    编写一个程序来检查XHTML文件（网页），看看里面的XHTML标签是否有正确的平衡性。
    这个程序将从文件中读取XHTML的输入，然后会打印出对这个文件的分析。
    文件中的标签序列应该被输出出来。
    XHTML文件中的任何其他文本都将会被忽略。
    如果存在标记的平衡错误或者程序在标记的中间就到达了文件的末尾，那么程序应该退出并打印出错误消息。
    如果到达文件末尾的时候没有任何错误，也应该打印一条相应的消息。

6. 弹珠时钟是一种新的计时方式，它会通过其托盘上的弹珠配置来显示当前时间。
通常来说，这样的时钟在底层会有一个弹珠的储存器，它的作用类似于队列。
也就是说，弹珠进入存储器的一端，并且从另一端被移除。
时钟通过一个吊臂来保持时间，这个吊臂每分钟都会循环一次，在这个循环里，它会从存储器的前面提起弹珠，然后把这个弹珠放在时钟的顶部。
时钟有一系列的三个托盘来用于显示时间。
弹珠仅能从一端进入和离开托盘（也就是说，它们像堆栈一样被使用）。

    顶部的托盘是分钟盘，它标有数字`1-4`。
    第一个弹珠滚动到位置`1`，下一个弹珠滚动到`2`，依此类推。
    进入到托盘的第五个弹珠会让整个托盘失去平衡，从而侧倾让所有的弹珠都掉出去。
    这个时候，最后一个弹珠会落到下一个托盘上，而剩下的四个弹珠则会返回到存储器里。
    时钟中的第二个托盘有`11`个位置，分别被标记为：`5`，`10`，`15`，`20`，……，`55`。
    当第十二个弹珠进入这个托盘时，它也会倾倒出里面的所有弹珠。
    这里的最后一个弹珠将会同样的落入到下一个托盘里，同样的，其他的`11`个弹珠会返回到存储器里。
    第三个也就是最后一个托盘被用来显示小时。
    它会有一个被永久固定在1号位的弹珠，之后，它还有`11`个空位，分别被标记为`2`，`3`，`4`，……，`12`。
    当第`12`个弹珠落入这个托盘时，它会进行提示并且让所有的`12`个弹珠都会返回到存储器里。
    在那个时候，这个时钟已经完成了`12`个小时的循环，并且任何托盘都没有留下（可活动的）弹珠。

    你需要编写一个模拟弹珠时钟行为的程序来回答有关其行为的一些问题。
    随着时钟的运行，存储器里的弹珠将会被打散。
    我们想要知道，需要多少个12个小时的周期，才能让弹珠重新回到开始的顺序。
    你的程序应该能够允许用户输入一个数字`N`（`> = 27`），来表示开始的时候，存储器里的弹珠数量。
    你的程序应该模拟时钟的行为，并计算这些弹珠经过多少个12小时的循环，才在存储器里回到了原始的顺序。
    你的程序应该打印出这个结果。

    提示：你可以使用$0$到$(N-1)$之间的`ints`（整数）来代表弹珠。
    你将需要编写一个函数（参见练习4），来确定，存储器里已经重新按照顺序进行排列了。
    对于$N = 27$的情况，答案是$25$。

7. 上一个练习里，提到了模拟弹珠时钟，直到存储器里再次按照顺序排列的时候进行返回。
解决该问题的另一种方法是将时钟的单个周期定义为一个置换。
也就是说，我们可以从存储器里直接提取出弹珠的当前顺序，它就能够告诉我们接下来弹珠们会被如何打散。
例如，如果队列中的第一个数字是`8`，那么就代表着位置8中的数字移动到了位置`0`。

    设计一个排列类来表示重新排列的结果。
    你需要一个构造函数和一个用列表实现的置换的方法。
    然后通过只运行时钟的一个周期，来重新解决时钟问题。
    在这个周期里，它会提取出当前排列，然后重复执行置换方法，直到得到一个按照原本顺序的列表。

8. 在把序列恢复到它原始顺序之前所必须应用的置换的次数被称为“置换的顺序”。
置换的顺序可以通过将置换划分为它的循环操作，然后通过找到循环操作长度的最小公倍数来确定。
比如说，将`[0,1,2,3,4]`变为`[4,3,0,1,2]`的置换包含了两个循环操作：
`(0,2,4)`和`(1,3)`。
第一个循环操作表示：
位置`0`的项目移动到了位置`2`；
位置`2`的项目移动到了位置`4`；
位置`4`的项目移动到了位置`0`。
第二个循环操作表示：
位置`1`和`3`交换了位置。
因此，这个置换的顺序是$3(2)= 6$。
也就是说，重新排列六次，将会使这个序列按照顺序排列。

    使用计算置换的顺序的方法，对上一个练习中的排列类进行扩展。
    使用你的新方法来再次解决弹珠时钟问题。
    通过实验来比较这个方法和之前版本的效率。

9. 编写一个事件驱动版本的收银台模拟器。
请确保它产生的结果和这一章里的时间驱动模拟具有相同结果。

10. 假设我们的零售店将从一个升级到两个收银台。
那么，我们可以只有一个排队队伍，并且让在队伍最前面的人能够到任何一个没人的收银台处结账（就像是，航空公司办理登机手续的情况，以及一些银行也会这样）；
或者我们可以有两条相互独立的排队队伍，我们假设到达的客户将会选择最短的一个队伍进行排队等候。
编写一个模拟器来判断，是否有一种方法相对于另一种方法，在客户的平均等待时间方面有明显的优势。
