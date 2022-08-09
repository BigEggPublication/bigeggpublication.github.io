# 容器类

目标

* 理解列表抽象数据类型是一个可以被用来操作顺序集合的通用容器类。

* 了解列表是如何在Python里实现的，以及这个实现对各种列表操作的效率的影响。

* 通过选择排序这样的关于集合的相关算法来激发一些直觉，以及使用Python的运算符重载来创建新的可排序类。

* 了解Python里常用的映射的实现——字典，以及了解字典各种操作的效率。

## 概要

当我们开始构思如何让我们的程序操作大型数据集的时候，程序设计会变得更加有趣。
简单来说，我们需要更高效的算法来处理大集合。
通常，高效算法的关键在于我们应该如何组织数据，也就是算法运行时所谓的*数据结构*（*data structures*）。
面向对象的程序一般使用容器类来管理对象的集合。
一个容器类的实例能够管理一个集合。
同样的，可以在运行时将对象插入容器对象以及从容器对象里进行查找。
Python包含多个容器类作为内置类型。
你可能已经熟悉的有列表和词典，它们是Python里的两个主要容器类。

在本章里，我们将回顾Python列表和字典的基础知识，并且介绍这些容器是怎样在Python里实现的。
了解如何实现一个集合通常对于理解它所支持的操作的效率非常重要。

## Python的列表

列表是Python语言里最主要的数据结构之一。
几乎每个程序都会以某种形式来使用列表。
因此，对于使用Python编写代码的任何人来说，透彻地了解列表非常重要。
鉴于它的实用性之广，所以你并不会感到奇怪，为什么几乎所有的高级编程语言都提供了类似于Python列表这样的容器。

简单来说，列表是按顺序来存储的对象的集合。
例如，列表可能会被用于一个班级里的所有学生或者是一副牌中的扑克牌。
正是因为列表具有顺序这一属性，所以我们才能讨论诸如列表中的第一个对象或列表中的下一个对象之类的事情。

用上一章里的新术语来说，我们可以把Python列表看成为顺序集合而实现的抽象数据类型。
Python在列表里提供了大量的操作。
内置函数和运算符支持了其中的一些操作，而列表自带的方法则提供了其他的一些操作。
以下是一些Python列表提供的操作所对应的规范：

* 连接（`list1 + list2`）：返回一个新列表，其中`list2`的元素紧跟着`list1`的元素包含在这个列表之中。

* 重复（`list1 * int1`或`int1 * list1`）：返回一个新列表，该列表相当于通过将`list1`与其自身连接`int1`次，而获得的列表。

* 长度（`len(list1)`）：返回`list1`里的有多少项。

* 索引（`list1[int1]`）：返回`list1`里`int1`位置的元素。
列表的第一项的索引是`0`，最后一项的索引是`len(list1) - 1`。

* 切片（`list1[int1：int2]`）：返回一个新列表，其中包含`list1`里的元素，这些元素从`int1`位置开始到，到`int2`（不包括）元素为止。
如果`int2 ≤ int1`，则结果列表为空（假设`int1`和`int2`为非负）。

* 检查元素存在状况（`item in list1`）：如果元素存在于`list1`里则返回`True`，否则返回`False`。

* 在末尾添加（`list1.append(obj1)`）：通过在末尾添加`obj1`来修改`list1`。

* 在任意位置插入（`list1.insert(int1，obj1)`）通过在位置`int1`添加`obj1`来修改`list1`。
在位置`int1`之后的那些元素将被“一一后移”来腾出位置给`obj1`。

* 在索引位置删除（`list1.pop(int1)`）：返回`list1[int1]`的元素，并通过从列表中删除此元素来修改`list1`。
位置`int1 + 1`之后的那些元素将向前移动一个位置来“填充”这个间隙。
如果不提供`int1`，则序列中的最后一项元素将被删除。

* 删除对象（`list1.remove(obj1)`）：删除`list1`里从前往后第一次出现的`obj1`。

在刚开始的时候，你可能用了和上面类似的描述，来学习如何使用Python列表。
可以看到，这些描述并没有说明在计算机中Python是如何实现列表的——这也就是抽象数据类型的典型标志。
在后面的内容里，我们将深入了解列表是如何实现的。
就目前而言，我们只需要站在客户端的视角来看，也就是只关注列表的使用方式。

## 顺序集合：扑克牌牌组

由于Python已经提供了关于列表的实现，因此通常我们会使用这样的内置类型来实现各种集合抽象。
让我们继续用上一章里的纸牌游戏为例，现在我们会尝试通过实现一个集合来代表一副牌。
作为开头，我们需要先确定一组对一副扑克牌有用的操作。
因此，很显然的是，我们需要一个用来创建一套新的（完整）扑克牌牌组的方法。
通常，牌组（`Deck`）会先被洗牌，然后再把牌分发到手里。
如果我们使用Python的类对这个抽象数据类型进行建模，我们就可以尝试包含下面这些方法：

```Python
class Deck(object):
    def __init__(self):
        """post: Create a 52-card deck in standard order"""

    def shuffle(self):
        """Shuffle the deck
        post: randomizes the order of cards in self"""

    def deal(self):
        """Deal a single card
        pre: self is not empty
        post: Returns the next card in self, and removes it from self."""
```

对这个规范的快速地检查一下，就能发现一个我们设计里的缺点。
可以看到，发牌（`deal`）方法里包含了一个先验条件，这是因为我们无法从空牌组里分发任何扑克牌。
为了完整性，我们应该为客户端代码添加一个方法来检查这个先验条件。
我们可以添加一个类似于`isEmpty`的方法来告知牌组是否用完。
或者，更常用的情况是，我们可能有一个关于尺寸（`size`）的方法，这个方法可以用来给出当前扑克牌牌组里剩下的扑克牌数量。
在许多纸牌游戏里，知道还剩下多少张牌非常重要，所以后一种方法似乎要好一些。
让我们把它添加到规范里。

```Python
    def size(self):
        """Cards left
        post: Returns the number of cards in self"""
```

把这个操作添加到抽象数据类型里还能让我们能够更精确地来描述发牌（`deal`）方法的先验条件。
下面就是这个改进之后的规范：

```Python
    def deal(self):
        """Deal a single card
        pre: self.size() > 0
        post: Returns the next card in self, and removes it from self."""
```

在考虑了抽象数据类型的接口之后，我们就应该开始准备实现了。
牌组很明显的是一系列扑克牌牌组成的序列，因此很自然的我们可以选择使用Python列表来将扑克牌保存在牌组中。
于是，我们有了牌组（`Deck`）类的构造函数。

```Python
# Deck.py
from random import randrange
from Card import Card

class Deck(object):
    def __init__(self):
        cards = []
        for suit in Card.SUITS:
            for rank in Card.RANKS:
                cards.append(Card(rank,suit))
        self.cards = cards
```

从这段代码里可以看到，我们使用了嵌套循环来生成花色和数字的所有可能的组合。
每一张后续的扑克牌都被附加到了扑克牌列表的末尾，之后，这个列表被作为牌组（`Deck`）对象的实例变量存储了起来。

因此，一旦我们创建了一个牌组（`Deck`）对象，就可以通过简单的列表操作来得到它的尺寸，以及可以从扑克牌牌组里发放扑克牌。

```Python
    def size(self):
        return len(self.cards)

    def deal(self):
        return self.cards.pop()
```

发牌（`deal`）方法会从列表的末尾开始，按照顺序一个一个地返回扑克牌。
因为使用了这种方式来实现，Python列表数据结构中所强加的顺序，将会决定扑克牌的发放顺序。

现在，我们需要一个能够在牌组里洗牌（也就是，把扑克牌都按照随机顺序存放）的方法。
这使得我们有一个能够锻炼我们的算法开发技能的机会。
你可能已经知道了若干种洗牌的方法，但这些方法不太能够很好地被翻译成代码。
另一种考虑这个问题的方法是，把扑克牌放进一个特定的排列之中。
洗牌的操作应该保证，洗牌之后的排列结果是$52!$中的任何一个，且他们出现的概率应该全都相同。
这就表明，牌组里的每一张牌都必须有相同的机会成为第一张牌，而剩下的每一张牌都有相同的机会成为第二张牌，以此类推。

我们可以通过使用原始列表的扑克牌来构建一个新列表，从而实现shuffle算法。
让我们从一个空列表作为开始，并不断地将旧列表里的扑克牌随机的放到到新列表里。
下面就是这个算法在代码里的样子：

```Python
    def shuffle(self):
        cards0 = self.cards
        cards1 = []
        while cards0 != []:
            # delete a card at random from those in original list
            pos = randrange(len(cards0))
            card = cards0.pop(pos)

            # transfer the card to the new list
            cards1.append(card)

        # replace old list with the new
        self.cards = cards1
```

我们可以用本地修改这种方法，来稍微改进洗牌（`shuffle`）这个算法。
也就是说，我们可以不用去构建第二个列表，而是选择一张扑克牌并把它随机的放到现有列表的前面。
就像，我们可以从1到$n$的位置里随机选一张牌，然后把它放在位置1这样。
这种方法有一个需要注意的点是：当我们将扑克牌放入随机的一个位置时，我们必须要记得，不要破坏当前位于该位置的扑克牌。
也就是说，我们需要保存这个正在被替换的扑克牌，从而它仍然在这个已经安放好之后的位置。
这个功能最简单的一个方法是：在这两个位置交换两张牌。
下面就是我们的洗牌（`shuffle`）本地算法版本：

```Python
    def shuffle(self):
        n = self.size()
        cards = self.cards
        for i,card in enumerate(cards):
            pos = randrange(i,n)
            cards[i] = cards[pos]
            cards[pos] = card
```

在这段代码里，可以看到，并没有必要在方法结束的时候执行`self.cards = cards`了。
在紧挨着循环的上一行的赋值语句，把`cards`变量设置为与`self.cards`相同的列表的引用。
因此，对这个列表所做的任何修改（交换扑克牌）也同样会改变`self.cards`。
局部变量`cards`用起来，会更加的方便（因此我们不必继续键入`self.cards`），也会有更好的效率（查找局部变量里的值会比查找实例变量更高效）。

我们现在有了一个完整的牌组（`Deck`）类。
我们可以用交互式测试来进行测试。

```Python
>>> d = Deck()
>>> print d.deal()
King of Spades
>>> print d.deal()
Queen of Spades
>>> print d.deal()
Jack of Spades
>>> d.shuffle()
>>> d.size()
49
>>> print d.deal()
Seven of Hearts
>>> print d.deal()
Nine of Diamonds
```

从输出里，我们可以看到，初始牌组是按照标准顺序发牌的。
而洗牌之后，就像我们期望的那样，扑克牌被随机发放了。

## 有序集合：手牌

在上一节里，我们使用了Python列表作为容器类来实现了一副牌组。
扑克牌牌组有一个隐含的顺序——扑克牌的发放顺序，因此，在这个情况下，使用列表来存储扑克牌是有意义的。
当然，牌组所拥有的特定顺序应该是随机的，这也就是我们需要洗牌的原因。
有些时候我们会希望，容器里的对象根据每一个元素的值按特定顺序来排列。
这个按照集合中的值来排序的过程被称为*排序*（*sorting*）。
在本节中，我们将会看到关于有序集合的例子。

### 创建桥牌的手牌

让我们的把牌组（`Deck`）类用在一个实际的应用程序里。
假设我们正在编写一个程序，可以玩现在非常流行的纸牌游戏——桥牌。
我们会逐步增量的建立这样一个程序。
因此，第一个任务可能是从一个洗过牌的牌组中处理四套扑克牌，每套扑克牌有13张。
同时，我们也想能够很好地展示这些手牌，以便分析它们。
就像报纸里，桥牌栏目通常都是按照花色（按照黑桃、红桃、方片、梅花的顺序）以及每个花色里按照扑克牌的数字从大往小排列（尖，K，Q，……，2）来显示手牌。
在桥牌里，尖（Ace）被认为比K大。

因此，我们要做的就是把扑克牌发放到手牌里，然后按照指定的顺序进行排列。
这个时候，我们应该创建一个新的集合，也就是手牌（`Hand`）类。
最初手牌（`Hand`）类是空的，在发牌的过程中，扑克牌会被逐一添加到手牌里。
因为我们的手牌（`Hand`）类应该是一个抽象数据类型，因此，我们需要操作来创建手牌，添加一张牌到手牌里，将手牌里的扑克牌按顺序排列（排序），并在显示手牌。
所以，这个类的初始版本的规范可以像下面这样：

```Python
# Hand.py
class Hand(object):

    """A labeled collection of cards that can be sorted"""

    def __init__(self, label=""):
        """Create an empty collection with the given label."""

    def add(self, card):
        """ Add card to the hand """

    def sort(self):
        """ Arrange the cards in descending bridge order."""

    def dump(self):
        """ Print out contents of the Hand."""
```

我们在初始版本的描述里添加了为手牌提供名称或标签以识别它的能力。
因为在实际里，桥牌的手牌用罗盘的指针北、东、南和西来表示。
同时，在这里，我们还添加了一个名叫`dump`的方法来显示手牌里的扑克牌。
这个方法对于测试和调试都会非常有用。

由于手牌是有序的，因此Python列表再一次成为实现新集合的首选容器。
大多数操作都很容易实现。
构造函数将会存储手牌标签并且创建一个空集合。
让我们把手牌都存储在名为`cards`的实例变量中：

```Python
# Hand.py
class Hand(object):

    def __init__(self, label=""):
        self.label = label
        self.cards = []
```

添加（`add`）操作将会把扑克牌作为参数，然后把它放入集合里。
因此，简单地在末尾添加（`append`）就能完成了：

```Python
    def add(self, card):
        self.cards.append(card)
```

要输出手牌的扑克牌，我们只需要先打印一个标题，然后遍历列表打印每张扑克牌就行了。

```Python
    def dump(self):
        print self.label + "'s Cards:"
        for c in self.cards:
            print " ", c
```

让我们来试试我们已经实现的功能。

```Python
>>> from Hand import Hand
>>> from Card import Card
>>> h = Hand("North")
>>> h.add(Card(5, "c"))
>>> h.add(Card(10, "d"))
>>> h.add(Card(13, "s"))
>>> h.dump()
North's Cards:
    Five of Clubs
    Ten of Diamonds
    King of Spades
>>>
```

看起来还不错。
并且输出的结果里，手牌里的扑克牌的列表在标题之下是有缩进的。

### 比较扑克牌

现在只剩下了让手牌进行排序的问题。
排序问题是计算机科学里一个非常重要并且已经经过了充分研究的问题。
在这里我们将会快速的浏览一下，在后面的章节里我们会再仔细的学习它。
如果我们想把某些东西按照特定的顺序放置起来，那么我们必须要解决的第一个问题就是应该是什么样的顺序。

在我们的桥牌程序里，我们想要对扑克牌（`Card`）对象进行排序的顺序是：先将它们按照花色分组，然后按照大小进行排序。
一般来说，排序会由诸如“小于”之类的关系来确定。
比如，假设我们想让数字列表将按照递增顺序进行排列，那么就意味着对于列表中的任何两个数字`x`和`y`，如果有`x < y`，则`x`必须排在列表里的`y`之前。
类似的，我们需要一种能够比较扑克牌的方法，从而让我们能够在我们的手牌（`Hand`）对象里对它们进行排序。
在第2章里，我们看到了Python的运算符重载，它们的出现允许我们去构建“类似于”现有类的新类。
这种情况下，我们会希望我们的扑克牌像数字一样，能够让我们使用Python的标准运算符——如`<`，`==`，`>`等等——去比较它们。

我们可以通过在扑克牌（`Card`）类中定义这些操作的对应方法，来实现运算符重载。
下面是这些运算符的“钩子”函数的定义：

```Python
    def __eq__(self, other):
        return (self.suit_char == other.suit_char and
                self.rank_num == other.rank_num)

    def __lt__(self, other):
        if self.suit_char == other.suit_char:
            return self.rank_num < other.rank_num
        else:
            return self.suit_char < other.suit_char

    def __ne__(self, other):
        return not(self == other)

    def __le__(self, other):
        return self < other or self == other
```

我们可以看到，这段代码里`__eq__`和`__lt__`提供了“最原始的”定义。
而后，其它的必要运算符就可以很容易地利用这两个运算符来进行定义。
在这里，我们没有专门为`__gt__`和`__ge__`编写定义，是因为Python可以自动地提供这些定义。
在执行诸如`x > y`这样的表达式的时候，如果没有为`x`实现`>`运算符，Python就会去尝试它的对称运算`y < x`。
类似的，`x >= y`会调用`y <= x`来判断。

现在，我们的扑克牌（`Card`）对象具有了可比性，那么最后一个需要处理的细节，就是清理现有代码。
在我们最初创建扑克牌（`Card`）类的时候，我们使用数字`1`来代表“尖”，但是由于在桥牌中，“尖”是最排序最高的牌，甚至在“K”之后。
所以，我们的当前的比较方法将会让尖由于代表数字`1`，而存在于整个序列的最前面。

我们可以通过这样几种方式来处理这个问题。
其中一种方案是把尖的这一特殊情况比较方法里进行专门的编码。
另一种解决方案是简单地修改扑克牌（`Card`）类，从而让它使用`2`到`14`的数字来代表扑克牌，其中`14`代表“尖”。
如果采用后一种方案，我们修改过的扑克牌（`Card`）类的就会像下面这样：

```Python
class Card(object):
    """A simple playing card. A Card is characterized by two
    components:
    rank: an integer value in the range 2-14, inclusive (Two-Ace)
    suit: a character in "cdhs" for clubs, diamonds, hearts, and
    spades."""

    SUITS = "cdhs"
    SUIT_NAMES = ["Clubs", "Diamonds", "Hearts", "Spades"]

    RANKS = range(2,15)
    RANK_NAMES = ["Two", "Three", "Four", "Five", "Six",
                  "Seven", "Eight", "Nine", "Ten",
                  "Jack", "Queen", "King", "Ace"]
...
```

回想一下，我们的牌组（`Deck`）类必须要生成所有可能的扑克牌来创建一个初始牌套。
因此，牌组（`Deck`）类将会依赖于扑克牌（`Card`）类，因而修改扑克牌（`Card`）类的接口可能会破坏牌组（`Deck`）类，因为它并不知道`14`现在是一个合法的牌号的数字，反而`1`并不是。
好在，当我们最初对`Deck`类进行编码时，我们用的是`Card.RANKS`来得到所有可能的数组，而不是使用`range(1, 14)`这样的硬编码。
所以，这样保证了，在扑克牌（`Card`）类里修改这个常量，也能让我们得到一套完整的牌组。
这件事情表明了一个设计的优势：
使用已有的常量名称，而不是用“魔术值”来填充代码。
在这个例子里，使用已有的常量可以更方便的让我们维护扑克牌（`Card`）类和牌组（`Deck`）类之间的抽象障碍。

由于对扑克牌（`Card`）类进行的这些修改，我们现在就可以像对数字使用关系运算符一样比较扑克牌了：

```Python
>>> Card(14,"c") < Card(2,"d")
True
>>> Card(8,"s") > Card(10,"s")
False
>>> Card(6,"c") == Card(6,"c")
True
>>>
```

可以看到，梅花尖是“小于”方片2的，这是因为我们已经说过任意的梅花扑克牌，都会小于方片。

### 扑克牌排序

既然已经可以比较扑克牌了，那么我们现在只需要再有一个用来把它们按照顺序摆放的算法就行了。
很奇妙的是，可以用一种非常类似于我们用来洗牌的算法来实现这个功能。
不过，这次我们会选择最大的扑克牌，而不是随意选择一张扑克牌成为手牌里的第一张扑克牌。
然后我们从剩下的扑克牌里再选择最大的牌作为下一张牌，依此类推。
这个算法被称为选择排序。
我们稍后就会看到，它虽然不是对列表进行排序的最有效方法，却是一种易于开发和分析的算法。

在Python里，实现选择排序算法的一种特别简单的方法是使用两个列表。
“旧”列表是原始手牌，“新”列表则会是有序手牌，相应的“新”列表会一开始为空。
只要旧列表里还有扑克牌，我们去找到最大的一张扑克牌，然后把它从旧列表中删除，之后再将其添加到新列表的末尾。因此，当旧列表为空时，新列表会按降序包含所有的扑克牌。
这里有一个相对应的实现：

```Python
    def sort(self):
        cards0 = self.cards
        cards1 = []
        while cards0 != []:
            next_card = max(cards0)
            cards0.remove(next_card)
            cards1.append(next_card)
        self.cards = cards1
```

代码里有一点需要注意的是，通过使用Python内置函数`max`来完成查找旧列表中最大扑克牌（`cards0`）的步骤。
这是在实现比较运算符所导致的一个很好的副作用。
而且，因为现在已经可以比较扑克牌（`Card`）对象了，那么对于任何现有的Python序列操作，只要它是基于比较元素的，我们就都可以用在扑克牌（`Card`）对象的集合上。
这使得事情简单了很多，不是吗？

还有一点需要注意的是，我们在这里开发了一种通用的排序算法。
这个算法应该能够适用于对任何类型的对象列表都能进行排序。
虽然现在，它是通过创建一个新的、按照排序顺序的、全新列表来进行的排序。
但是，就像我们之前对洗牌算法所做的修改一样，我们可以轻松的把选择排序转换成本地排序。
把选择排序改成本地选择排序将会是一项练习题。

然而，我们做了很多不必要的工作。
因为，我们的扑克牌（`Card`）对象已经可以进行比较了，我们可以在Python里通过使用Python列表类型里内置的`sort`方法，来进行扑克牌排序。
内置的排序算法会使扑克牌按照升序排列。
为了使扑克牌能够按照降序排列，我们只需要在排序值后将它们反转就行了。
下面的代码是使用这个排序`sort`方法的版本。

```Python
    def sort(self):
        self.cards.sort()
        self.cards.reverse()
```

很明显，这个版本是最简单的，但如果我们直接跳到这个解决方案，就会让我们错过开发我们自己的排序算法的那种兴奋。

那么，我们开发的选择排序算法的效率如何？
显然，这个函数的主要工作都是在`while`循环里完成的。
而且循环会一直继续，直到`cards0`列表为空。
每次循环的时候，还都会从`cards0`中删除一个项目。
因此，这个循环很明显地将会被执行$n$次，其中$n$是原始列表中的元素数量。
然后在每次循环里，我们都需要找到`card0`中最大的扑克牌。
为了找到最大的扑克牌，Python的`max`函数会依次查看列表中的每个扑克牌对象，并且比较当前哪个扑克牌是最大的。
这是一个$Θ(c)$操作，其中$c$是被分析的列表中的项目数。
第一次通过`while`循环时，max检查了$n$个扑克牌。
下一次，它只需要判断$n - 1$个扑克牌，在这之后是$n - 2$，然后以此类推。
因此，在`while`循环的所有迭代里，完成的总工作量是$n + (n - 1) + (n - 2) + ... + 1$。
就像我们在1.3.4小节里曾经讨论过的那样，这个和可以被公式$\frac{n(n + 1)}{2}$求得。
这使得我们的选择排序至少是一个$n^2$算法。
也就是说，它不可能会比$Θ(n^2)$好，甚至可能会更糟。
因为还要取决于`remove`和`insert`方法的效率，而这些方法也在`while`循环体里被执行。
我们将在3.5节中具体研究这些操作。

相比之下，Python里内置的排序方法是$Θ(n \lg n)$的算法，很明显它的效率更高。
对于我们简单的一手13张牌来说，这并没有太大的区别，但对于有大量数据的列表来说，它就可能意味着是在几秒钟内或者几小时甚至几天的时间内完成排序的差异。
我们将在6.5节中看到如何设计更高效的排序算法。

## Python里列表的实现

当我们在分析前面的选择排序时，我们主要关注点在`max`操作上，结果它的效率是$Θ(n)$，但我们忽略了列表的`insert`和`delete`方法所消耗的时间。
事实证明，这两个方法都和`max`方法具有相同的时间复杂度。
我们怎么知道这个复杂度呢？
就像我们选择使用Python列表来实现我们的集合类`Deck`和`Hand`，使得我们可以确定这些类中方法的相对效率一样：
Python列表实现中所用的数据结构的选择也决定了列表的各种操作的效率。
因此，了解这些操作的真实效率需要对Python的底层数据结构有所了解。

### 基于数组的列表

那么我们如何才能在计算机内存里有效地储存和访问那些对象集合呢？
回想一下，计算机内存是一系列存储位置。
每一个存储位置都有一个与之关联的数字（很像索引），这个数字被称为内存的*地址*（*address*）。
一个数据的存储，可以跨过若干连续的存储位置。
要从内存中找出一个元素，我们需要一种方法来查找或者计算对象的起始地址。
那么，当我们想要存储一组对象的时候，我们需要一些系统方法来确定集合中每个对象的位置。

假设一个集合里的所有对象尺寸都相同，也就是说它们都需要相同数量的字节来进行存储。
这是同质（所有相同类型）集合的情况。
存储这个集合的简单方法是分配一块足以容纳整个集合的单个连续存储区域。
然后，就可以一个接一个地存储对象了。
例如，假设一个整数值需要`4`个字节（32位）的内存来存储。
那么，一百个整数的集合可以顺序存储到`400`个字节的内存之中。
假设这个整数集合从地址为`1024`的内存位置开始。
也就是说，列表里索引为`0`处的数字是从地址`1024`开始的；
索引`1`的数字的内存地址位于`1028`；
索引`2`的数字的内存地址位于`1032`，以此类推。
于是乎，对于第$i$个位置的元素，子还需要通过公式$address\_of\_ith = 1024 + 4 * i$就能够计算出它的地址。

我们刚刚描述的是一种被称为*数组*（*array*）的数据结构。
数组是用于存储集合的常用数据结构，许多编程语言都用数组作为基本的容器类型。
数组在内存里非常的高效，而且基于我们刚才讨论过的内存地址索引计算公式，它还支持快速的随机访问（就是说我们可以直接“跳转”到我们想要的元素上）。
然而，就数组而言，它们还是有些限制性的。
其中一个问题是数组通常必须是同质的。
一般来说，通常不可能有一个同时包含整数和字符串的数组。
为了能够使用内存地址索引计算公式，所有的元素都必须具有相同的尺寸。

数组的另一个缺点是，在为其分配内存时需要确定数组的尺寸。
在编程语言的语境中，数组通常都会被认为是静态的。
当我们为100个元素分配一个数组的时候，底层的操作系统会给我们一个足以容纳该集合的内存区域。
但是，数组周围的内存将会被分配给其他对象（甚至是其他正在运行的程序）。
如果，在之后我们还想添加更多的元素，但是数组已经没法变大了。
程序员可以通过这样的操作在某种程度上解决这个集合的这个限制：创建一个足够大的数组，来保持一块从理论上能够得到的最大集合的内存尺寸。
然后通过了解这个数组实际使用了多少个空间，程序员可以允许这个集合增长或缩小到合适的尺寸。
但是，这样做会对数组的内存效率产生负面效应，因为程序员只能请求比实际需要更多的内存来保证工作。
而且，很明显的，如果集合的尺寸还是超出了预期的最大值，我们还是会遇到问题。

与数组相比，Python列表是异质（可以混合不同类型的对象）以及动态（可以按需增长或缩小）的。
在底层，Python列表实际上还是使用数组来实现的。
要知道，Python的变量存储都是对实际数据对象的引用。
如果你不熟悉或不完全理解引用这个概念的话，请不要过于担心，我们将会在下一章里详细地讨论它们。
这里的要点是，存储在Python列表数组的连续内存位置的元素，是实际数据对象的*地址*。
而每一个内存地址的长度都是相同（在现代CPU上通常为32或64位）的。
要从列表中查找一个值，Python解释器首先会使用索引公式来查找对象的引用（地址）的位置，然后使用这个引用来查找对象。
因此，具有固定尺寸元素的数组可用于存储内存地址，然后用来查找任意尺寸的对象。

很明显，Python列表也能够通过调用`insert`和`append`等方法来增长。
在底层，Python会为列表分配一个固定尺寸的数组，并追踪这个固定尺寸作为最大值，并且还会追踪列表的当前尺寸。
在尝试添加的元素时，一旦超出当前的最大尺寸，就必须分配足以存储所有元素的新的连续内存部分。
然后将存储在旧数组中的引用复制到新的更大的数组里，最后释放用于存储旧列表的存储空间（返回给操作系统）。
通过使用动态数组分配的能力，只要有足够的系统内存可以被用于保存新列表，Python列表就可以不断的增长。

### 效率分析

知道了Python列表是通过动态调整数组的尺寸来实现的，我们现在就可以分析各种列表操作的运行时效率了。

分配新的较大数组是一项相对昂贵的操作，因此分配的新数组通常要大得多。
分配更大的数组可防止在把大量额外的元素添加到数组之前，就又要去执行一次调整尺寸的操作。
这也就意味着，把元素添加到Python列表的末尾，偶尔会需要$Θ(n)$的计算量（分配新数组并复制现有项）：
但大多数时候它都会是一个$Θ(1)$的操作。
如果数组的尺寸在每次调整尺寸的时候都加倍的话，那么在执行$n$次在末尾添加（`append`）操作之后，才需要进行一次代价为$Θ(n)$的调整尺寸的操作。
分摊到其他$n$个不需要调整尺寸操作的情况里，在末尾添加（`append`）操作的平均时间复杂度为$Θ(1)$。

在列表中的任意位置插入（`insert`）这个操作的情况则略有不同。
因为数组的元素是存储在一块连续的内存位置的，为了插入到数组的中间，我们必须首先把所有后面的元素向后移动一位来制造出一个可供插入的“空洞”。
当插入的位置处于列表的最前面时，Python解释器就必须要移动当前已经存在于数组中的所有$n$个元素。
因此即使用了数组满时尺寸翻倍的技巧，在任意位置插入（`insert`）这一操作的时间复杂度仍然是$Θ(n)$。

Python列表还支持从现有列表中删除一个元素的方法。
删除操作的分析和插入操作是相同的。
如果我们删除位于位置4的元素，那么位置5和之后位置的所有元素必须向前移动一个位置。
因此删除操作就像插入操作一样，是$Θ(n)$操作。
删除一个元素时，我们不需要去更改列表的最大尺寸。
因此，如果列表在短时间内变得非常大，然后变小并且在程序的其他时候都保持这种小得多的状态，分配来用于存储最大尺寸的内存将始终处于被使用的状态，而不会被释放。

## Python的字典（选读）

Python列表是顺序数据结构的一个例子。
这说明存在一个数据的固有顺序。
换句话说就是在我们随机洗牌算法的实现里，基础列表里的元素仍然是由自然数字（0、1、2、...）来索引，从而让集合有一种自然的顺序。
事实上，人们可以抽象地将列表视为从索引到列表中的元素的一种一一映射。
也就是，每个有效的索引都和（映射到）列表中特定的元素相关联。

映射的想法非常普遍，甚至都不需要限制使用数字作为索引。
如果你仔细想一想，你可能会想出各种涉及到其他类型的映射的各种有用的集合。
比如，电话簿是从姓名到电话号码的映射。
映射在的编程中随处可见，这也就是为什么Python提供了叫做字典的一个有效的内置数据结构来管理它们的原因。

## 字典抽象数据类型

你之前可能已经用过Python字典，但可能从来没有仔细地去思考它。
字典是一种数据结构，它允许我们将键与值相关联，也就是实现了映射。
抽象地说，我们可以把字典视为一组有序的键值对（`(key, value)`）。
当从抽象数据类型的角度来看时，我们只需要不多的操作就可以得到一个有用的容器类型。

* 创建（`Create`)

    * 后置条件：返回一个空字典。

* 添加（`put(key, value`)）

    * 后置条件：在字典里，将值（`value`）与键（`key`）相关联。在给定一个键（`key`）的时候，字典里有且只有一个键值对（`(key, value)`）。

* 获取（`get(key)`）

    * 先验条件：存在一个`X`，使得键值对`(key，X)`存在于字典中。

    * 后置条件：返回`X`。

* 删除（`delete(key)`）

    * 先验条件：存在一个`X`，使得键值对`(key，X)`存在于字典中。

    * 后置条件：把键值对（`(key, X)`）从字典里删除。

有许多编程情况需要用到类似字典的结构。
一些编程语言（如Python和Perl）为这个重要的抽象数据类型提供了内置实现。
其他语言（如C++和Java）则把它们作为标准集合库的一部分来提供。

## Python的字典

Python字典提供了字典抽象数据类型的一个特定实现。
让我们通过一个简单的例子来理解它:
我们已经知道了，在扑克牌例子里，我们需要能够把用字符串代表的花色转换成完整的花色名称。
这对于字典来说是非常完美的工作。
因此，我们可以像这样定义一个合适的Python字典：

```Python
suits = { "c": "Clubs", "d": "Diamonds", "h": "Hearts", "s": "Spades" }
```

就像这段代码里显示的一样，字典的语法就像是我们在字典的抽象描述里说的，是一对一对的。
在Python里，键值对通过冒号来连接。
因此，在这个例子中，我们将字符串`"c"`映射到了字符串`"Clubs"`，`"d"`映射到了`"Diamonds"`，其他的也是这样。

之后，我们可以通过使用`get`方法来从Python字典里找到对应的值，同时Python也允许像用列表一样对字典进行用索引来获得对应的值。
下面是一些命令行交互操作的例子：

```Python
>>> suits
{"h": "Hearts", "c": "Clubs", "s": "Spades", "d": "Diamonds"}
>>> suits.get("c")
'Clubs'
>>> suits["c"]
'Clubs'
>>> suits["s"]
'Spades'
>>> suits["j"]
Traceback (most recent call last):
    File "<stdin>", line 1, in ?
KeyError: "j"
>>> suits.get("j")
>>> suits.get("x", "Not There")
'Not There'
```

可以看到，在拿到对应的花色（`suits`）时，键值对的输出顺序和创建字典时的顺序是不相同的。
字典里，不会去保留项目的顺序，而只会保留映射。
后面的命令行交互操作，显示出了利用索引和`get`操作之间的少许不同。
当尝试使用不存在的键作为索引时，字典会抛出`KeyError`异常。
但是，在同样的情况下，`get`方法则只返回`None`作为默认值。
就像上面的一次交互操作所体现的，如果键不存在，`get`方法还允许通过使用可选的第二个参数提供备用的默认值。

修改字典里的条目或者添加新条目来扩展字典的抽象操作（`put`）是通过Python里的赋值运算符实现的。
就和先前一样，这使得使用字典的语法和使用列表的语法非常的相似。
下面是一个关于这个操作的例子：

```Python
>>> suits["j"] = "Joker"
>>> suits
{'h': 'Hearts', 'c': 'Clubs', 'j': 'Joker', 's': 'Spades', 'd': 'Diamonds'}
>>> suits["j"]
'Joker'
>>> suits["c"] = "Clovers"
>>> suits["s"] = "Shovels"
>>> suits
{'h': 'Hearts', 'c': 'Clovers', 'j': 'Joker', 's': 'Shovels', 'd': 'Diamonds'}
```

而要删除一个元素，就像Python列表一样，Python字典也能够理解del函数。
同时，你还可以使用`clear`方法来从字典里删除所有条目：

```Python
>>> suits
{'h': 'Hearts', 'c': 'Clovers', 'j': 'Joker', 's': 'Shovels', 'd':
'Diamonds'}
>>> del suits['j']
>>> suits
{'h': 'Hearts', 'c': 'Clovers', 's': 'Shovels', 'd': 'Diamonds'}
>>> suits.clear()
>>> suits
{}
```

除了这些基本操作之外，Python还为使用字典提供了很多的便利。
比如说，我们经常会去对字典中的每个元素都执行某些操作。
因此，能够以顺序方式来处理字典还是非常有用的。
Python字典支持三种从字典组件生成为列表的方法：
所有的键（`keys`）方法会返回一个包含所有键的列表；
所有的值（`values`）方法会返回一个包含所有值的列表；
所有的元素（`items`）方法会返回一个包含所有键值对（`(key, value)`）的列表。[^1]
同时，你也可以在通过使用`for`循环来直接遍历字典里的所有键，也可以使用`in`运算符来检查给定的键是不是存在于字典之中。

> [^1] 在Python 3.0里，这些方法会返回一个迭代器（`iterator`）对象（参见第4章）。
> 迭代器（`iterator`）对象可以像这三种方法一样，通过`list(myDictionary.items())`就能很容易被地转换为列表。

```Python
>>> suits.keys()
['h', 'c', 's', 'd']
>>> suits.values()
['Hearts', 'Clovers', 'Shovels', 'Diamonds']
>>> suits.items()
[('h', 'Hearts'), ('c', 'Clovers'), ('s', 'Shovels'), ('d', 'Diamonds')]
>>> for key in suits:
...     print key, suits[key]

h Hearts
c Clovers
s Shovels
d Diamonds
>>> 'c' in suits
True
>>> 'x' in suits
False
```

### 字典的实现

和几乎任何其他的抽象数据类型一样，我们有很多种方式能够实现字典。
不同实现的选择将会决定各种操作的效率。
一个简单的存储方式是：
将字典条目存储为一个键值对的列表。
`get`操作将从这个列表上以某种形式来查找这个键，从而能够找到相对应的键值对。
其他的各种操作，也可以通过对这个列表进行简单的操作来完成。
然而，遗憾的是，这种方案的效率并不高，因为这里的一些操作会需要`Θ(n)`的复杂度。
（对各个操作的精确分析将会被留作练习。）

Python里的实现用了一种被称为*散列表*（*hash table*，也被称为哈希表）的更高效的数据结构。
散列表将会在第13.5节里详细介绍。
在这里，我们会简单的向你介绍一下，从而能够让你可以理解各种字典操作的效率。
这将能够让你有足够的能力来判断使用Python字典的算法效率。

散列表的核心是*散列函数*（*hashing function*，也被称为哈希函数）。
散列函数会把键作为参数，然后对它执行一些简单的计算从而生成一个数字。
由于计算机上的所有数据最终都按比特（二进制数）存储，因此可以很容易的能够找到一个合适散列函数。
Python也有一个内置的函数`hash`来实现这个散列函数。
你可以通过下面这样的交互操作来进行尝试：

```Python
>>> hash(2)
2
>>> hash(3.4)
-751553844
>>> hash("c")
-212863774
>>> hash("hello")
-1267296259
>>> hash(None)
135367456
>>> hash((1,"spam",4,"U"))
40436063
>>> hash([1,"spam",4,"U"])
Traceback (most recent call last):
    File "<stdin>", line 1, in ?
TypeError: list objects are unhashable
```

提供任何“能够被散列”的东西给`hash`函数都会产生一个`int`结果。
注意看最后两次交互操作。
元组是可以被散列的，但列表则不行。
散列函数的一个要求是，无论何时，调用它去处理特定的对象，它都必须始终计算出完全相同的结果。
由于散列函数依赖于对象的底层存储方式来生成散列值，因此在对象的底层存储方式不会发生变化的时候，能够保证这个值是有效的。
换句话说，我们只能散列贫血对象（不可变的对象）。
像数字，字符串和元组都是不可变的，因此它们可以被散列。
然而，因为列表是可以被修改的，所以Python不允许对它们进行散列操作。

只要有一个合适的散列函数，就可以简单的创建一个散列表来实现字典了。
散列表实际上只是一个用来存储（`(key, value)`）键值对的大型列表。
然而，这些“对”并不是一个接一个地被顺序存储的。
反而，它们会被存储在列表中的散列键所确定的索引处。
比如，假设我们分配了一个大小为1000的列表（这就是我们的“表”）。
为了存储这个键值对`("c"，"Clubs")`，我们会先计算`hash("c") % 1000 = 226`。
因此，这个元素将会被存储在位置226。
在这里，余数操作可以保证我们得到的结果在范围内：`range(1000)`，因此，这个值会是我们表里的一个有效索引。
当有一个恰当的散列函数，元素将会以相对平均的方式分布在整个表格之中。

只要字典中没有两个键被散列到完全相同的位置，这个实现就会非常的高效。
插入一个新元素需要花费常量时间，因为我们只需要应用散列函数，然后把这个元素分配给列表中的对应的位置就行了。
查找会有类似的复杂性：我们还会是先计算散列值，然后我们就能够知道应该去哪里找到元素了。
要删除一个元素，我们只需用一个特殊的标记（例如，`Node`）放到相应的位置就行了。
因此，所有基本的字典操作都可以在常量（`Θ(1)`）时间内完成。

那么，当两个键被散列（散列）到同一个位置时会发生什么呢？
这种现象被称为*碰撞*（*collision*）。
处理碰撞问题是第13.5节中涉及的一个重要话题。
现在，你只需要知道已经有很好的技术来处理这个问题就行了。
在使用了这些技术并确保有足够大小的表格之后，就可以建立一个允许常量时间操作的数据结构了。
所以，Python的词典非常高效，只要你有足够多的可用内存，你就可以轻松地处理数成千上万甚至是几百万条条目了。
并且，Python解释器本身就在很大程度上依赖于使用字典来维护命名空间，所以字典的实现已经经过了高度的优化。

## 扩展示例：马尔可夫链

让我们把新学的与字典相关的知识应用到这样一个程序，这个程序会通过使用多个Python的容器类来构建一个马尔可夫（Markov）模型。
马尔可夫模型是用来对随时间变化的系统进行建模的统计技术。
马尔可夫模型的一个应用场景是对自然语言的理解。
就好比，语音识别系统可以通过对句子中接下来可能出现的单词进行预测，从而能够更好的分辨“他们”（their）、“他们是”（they're）和“那里”（there）这样的同音异义词。

我们现在需要的是开发一个可以被用于这类应用程序的马尔可夫（Markov）类。
之后，我们会通过使用这个类，来构建一个可以生成特定样式的“随机”语言的程序作为展示。
我们可以，通过提供给它一些神秘小说来训练程序，之后它就能够生成一些看起来像是来自（非常）糟糕的神秘小说里的胡言乱语。

马尔可夫语言模型背后的基本思想是：
通过查看单词前面的一部分不长的序列，就可以预测想要说的下一个单词。
例如，三元的trigram模型会查看前两个单词，从而预测序列中可能会出现的下一个（第三个）单词。
根据程序，可以使用更多或更少的单词来作为“窗口”。
例如，一个二元的bigram模型将会仅仅根据前一个单词来预测下一个单词出现的概率。
我们的一开始的设计将会用于三元模型（trigram）。
将程序扩展到任意长度的前序序列，将会留作练习。

这里有一个马尔可夫（Markov）类的简单的规范。

```Python
class Markov(object):

    """A simple trigram Markov model. The current state is a sequence
       of the two words seen most recently. Initially, the state is
       (None, None), since no words have been seen. Scanning the
       sentence "The man ate the pasta" would cause the
       model to go through the sequence of states: [(None,None),
       (None, 'The'), ('The', 'man'), ('man','ate'), ('ate','the'),
       ('the','pasta')]"""

    def __init__(self):
        """post: creates an empty Markov model with initial state
                 (None, None)."""

    def add(self, word):
    """post: Adds word as a possible following word for current
             state of the Markov model and sets state to
             incorporate word as most recently seen.

       ex: If state was ("the", "man") and word is "ate" then
           "ate" is added as a word that can follow "... the man" and
           the state is now ("man", "ate")"""

    def randomNext(self):
        """post: Returns a random choice from among the possible choices
                 of next words, given the current state, and updates the
                 state to reflect the word produced.

           ex: If the current state is ("the", "man"), and the known
               next words are ["ate", "ran", "hit", "ran"], one of
               these is selected at random. Suppose "ran" is selected,
               then the new state will be: ("man", "ran"). Note the
               list of next words can contain duplicates so the
               relative frequency of a word in the list represents its
               probability of being the next word."""

    def reset(self):
        """post: The model state is reset to its initial
                 (None, None) state.

           note: This does not change the transition information that
                 has been learned so far (via add()), it
                 just resets the state so we can start adding
                 transitions or making predictions for a "fresh"
                 sequence."""
```

仔细阅读这个规范，就可以发现里面使用了许多的容器结构，我们必须把它们柔和在一起才能有一个可用的类。
马尔可夫（Markov）类的一个实例必然地始终都能够知道它的当前状态——它遇到的最后两个单词所组成的序列。
我们可以将这个序列存储为列表或元组。
在这里，我们还需要某种模型，这种模型可以让我们查找到可能的下一个单词的集合。
这不就是一个映射吗？
因此，我们可以使用字典来实现这个模型。
字典的键将是那个单词对；而值则会是可能的下一个单词的列表。
注意我们必须使用元组来表示单词对，因为Python列表不能够被散列。

现在，我们可以为这个类编写代码了。

```Python
import random

    class Markov(object):

        def __init__(self):
            self.model = {} # maps states to lists of words
            self.state = (None, None) # last two words processed

        def add(self, word):
            if self.state in self.model:
                # we have an existing list of words for this state
                # just add this new one (word).
                self.model[self.state].append(word)
            else:
                # first occurrence of this state, create a new list
                self.model[self.state] = [word]
            # transition to the next state given next word
            self._transition(word)

        def reset(self):
            self.state = (None, None)

        def randomNext(self):
            # get list of next words for this state
            lst = self.model[self.state]
            # choose one at random
            choice = random.choice(lst)
            # transition to next state, given the word choice
            self._transition(choice)
            return choice

        def _transition(self, next):
            # help function to construct next state
            self.state = (self.state[1], next)
```

你应该仔细地阅读这段代码，来确保自己已经了解了这个类是如何使用Python里的词典、列表和元组的。

距离完成我们的“胡言乱语程序”，还剩下编写一些代码来用大量的输入文本样本去“训练”这个模型，然后使用这个训练好了的模型来生成输出流。
下面是符合这些要求的功能。

```Python
# test_Markov.py
def makeWordModel(filename):
    # creates a Markov model from words in filename
    infile = open(filename)
    model = Markov()
    for line in infile:
        words = line.split()
        for w in words:
            model.add(w)
    infile.close()
    # Add a sentinel at the end of the text
    model.add(None)
    model.reset()
    return model

def generateWordChain(markov, n):
    # generates up to n words of output from a model
    words = []
    for i in range(n):
        next = markov.randomNext()
        if next is None: break # got to a final state
        words.append(next)
    return " ".join(words)
```

于是乎，在用路易斯·卡罗（Lewis Carroll）的《爱丽丝梦游仙境》作为训练集，所训练出来的模型能够输出下面这样一段内容：

> Alice was silent. The King looked anxiously at the mushroom for a rabbit! 'I suppose I ought to have it explained,' said the Caterpillar angrily, rearing itself upright as it was written to nobody, which isn't usual, ‘Oh, don't talk about cats or dogs either,' if you want to go nearer till she got up and down in an encouraging opening for a minute or two. ‘They couldn't have wanted it much,' said Alice, swallowing down her anger as well as she did not get dry again: they had a little before she made it out to sea. So they began solemnly dancing round and round
Alice, every now and then treading on her face brightened up at the Caterpillar's making such a curious appearance in the middle of one!

从这个输出流里，你可以看到，里面的内容非常接近于连贯的句子了。
作为对比，这里有一个完全由随机选择单词来输出的程序，下面就是它的输出内容：

> of cup,' sort!' forehead you However, house the went to me unhappy up impossible settled We had help the always in see, forgot tree of you ‘for night? because hadn't her ear. all confused sit took the care went quite do up, ‘How three An Turtle, the was soldiers, solemnly, so went of the sharply. to Rabbit 'Tis there last, a with that o'clock and below, he Writhing, don't to wig, she into three, But said there,' offended. turning This some (she together."' such be because and what the had to hatters better This Mouse new said the pool whiting. with could from bank-the mile said I she all! turning when ‘Begin By how as head them, little, and Latitude he

很明显，三元的trigram模型能够获取到语言中的一些重要规律。
这也就是为什么它会被用在许多语言处理任务里，这些任务包括：
生成让人讨厌的可以躲避垃圾邮件过滤器的垃圾邮件。
虽然知识就是力量，但是请不要滥用你新学的技能！

## 章节总结

这一章里，我们介绍了容器类作为处理对象集合的机制这一思想。
下面是关于这些关键思想的摘要。

* 容器对象被用来管理集合。
可以在运行时对容器进行添加和删除元素的操作。

* 内置Python列表是容器类的一个示例。

* 列表定义了顺序集合，在里面存在第一个元素，并且每个元素（除了最后一个）都具有天然的后继元素。

* 列表可以被用于存储已排序和未排序的序列。
选择排序是一个可以被用于对序列进行排序的$Θ(n^2)$算法。

* Python列表使用了引用数组来实现。
当列表对于当前数组而言变得太大时，Python会自动分配一个更大的数组供列表使用。
这项技术让在最后添加（`append`）操作能够在$Θ(1)$（平摊下来）时间内完成，但插入或删除列表中间的元素的操作则需要$Θ(n)$的时间。

* Python字典是通过通用的映射来实现的容器对象。

* 字典是使用散列表来实现的。
散列表支持非常高效地对新的映射进行查找、插入和删除，但是不会保留元素一开始的排序（序列）。

* 马尔可夫链是一种数学模型，它可以根据元素之前的一个固定窗口来预测序列中的下一个元素。
它有时会被用作自然语言处理应用程序里的自然语言的简单模型。

## 练习

**判断题**

1. Python是唯一具有内置用于顺序集合的容器类型的高级语言。

2. 列表上的索引操作能够返回最初的子列表。

3. 本章中介绍的牌组（`Deck`）类的构造函数里，创建了一组随机排序的扑克牌。

4. Python类如果实现了特定的钩子函数，它的实例就能够使用标准关系运算符（比如说`<`，`==`和`>`）。

5. Python列表使用了连续数组来实现。

6. Python列表是一个同性容器。

7. 数组不支持高效的随机访问。

8. 平均而言，Python列表的末尾添加一个元素是$Θ(n)$的复杂度。

9. 在Pythond的列表中间插入一个元素是$Θ(n)$的复杂度。

10. `Card(6，"c") < Card(3，"s")`

11. Python的独特之处在于它有一个由通用映射而实现的内置的容器类型（字典）。

12. Python字典的键必须是不可变对象。

13. 在Python字典中查找一个元素是$Θ(n)$操作。

**选择题**

1. 以下哪个选项不适用于Python列表？

    a) 它们在底层是用连续数组来实现的。

    b) 列表中的所有元素必须属于同一类型。

    c) 它们可以动态地增长和缩小尺寸。

    d) 它们支持高效的随机访问。

2. 以下哪项是$Θ(n)$操作？

    a) 添加元素到Python列表的末尾。

    b) 使用选择排序对列表进行排序。

    c) 从Python列表的中间删除元素。

    d) 在Python列表里查找第$i$个元素。

3. 以下哪一项不是本章里介绍的牌组（`Deck`）类中提供的方法？

    a) 大小（`size`）

    b) 洗牌（`shuffle`）

    c) 发牌（`deal`）

    d) 以上所有都是该类的方法。

4. 以下哪一项不是本章里介绍的手牌（`Hand`）类中提供的方法？

    a) 添加（`add`）

    b) 排序（`sort`）

    c) 发牌（`deal`）

    d) 以上所有都是该类的方法。

5. 选择排序算法的时间复杂度是多少？

    a) $Θ(\lg n)$

    b) $Θ(n \lg n)$

    c) $Θ(n)$

    d) $Θ(n^2)

6. Python内置列表方法的排序时间复杂度是多少？

    a) $Θ(\lg n)$

    b) $Θ(n \lg n)$

    c) $Θ(n)$

    d) $Θ(n^2)

7. `max(myList)`操作的时间复杂度是多少？

    a) $Θ(\lg n)$

    b) $Θ(n \lg n)$

    c) $Θ(n)$

    d) $Θ(n^2)

8. Python字典不支持哪些操作？

    a) 元素的插入

    b) 元素的删除

    c) 元素的查找

    d) 元素的序列（排序）

9. 以下哪个选项不适用于Python字典？

    a) 它们是由散列表实现的。

    b) 值必须是不可变的。

    c) 查找非常高效。

    d) 以上所有都是真的。

10. 自然语言的三元（trigram）模型

    a) 使用三个单词作为前缀来预测下一个单词。

    b) 使用两个单词作为前缀来预测下一个单词。

    c) 比马尔可夫模型更有用。

    d) 用于向海外汇款。

**简答题**

1. 利用本章中的牌组（`Deck`）类和手牌（`Hand`）类，编写代码片段来执行以下各项操作：

    a) 打印出所有52张扑克牌的名称。

    b) 打印出13张随机扑克牌的名称。

    c) 从52张扑克牌中随机选择13张扑克牌，然后按照扑克牌的价值作为顺序来显示扑克牌（桥牌手牌）。

    d) 发牌并展示从洗过的牌组里发出的四套13张手牌。

2. 本章讨论的两种（通过两个列表来完成，或者就地完成）打散（洗牌）算法的时间复杂度（$Θ$）是多少。
在章节讨论里我们认为后者效率更高。
这与你的$Θ$分析一致吗？尝试说明为什么。

3. 假设你正在参与设计一个必须要能够维护大量个人信息（比如，客户记录或健康记录）的系统。
每个人都将会用一个包含所有关键信息的对象来表示。
你现在的工作是要设计一个容器类来保存所有的这些记录。
这个容器类必须要支持下列操作：
    * `add(person)` - 将`person`对象添加到集合之中
    * `remove(name)` - 从集合里删除名叫`name`的人。
    * `lookup(name)` - 返回名叫`name`的人的记录。
    * `list_all` - 以名称作为顺序返回一个列表，列表里包含集合里所有记录。

    对于以下每种组织数据的方案，请分析上述操作的效率。
    你应该通过一两句话来描述你对每个算法的效率的分析。
    尝试为每个组织数据的方案都提出最佳实现方法。

    (a) 对象按添加顺序存储在Python列表中。

    (b) 对象按名称顺序存储在Python列表中。

    (c) 对象存储在由`name`索引的Python字典中。

4. Python有一个高效的实现了数学集的集合（`set`）类型。
你可以通过查阅参考文档或在Python命令行里输入`help(set)`来获取有关此容器类的相关信息。
假设你正在实现你自己的集合`Set`类，其中包括添加（`add`），删除（`remove`），清空（`clear`），包含（`__contains__`），交集（`intersection`），并集（`union`）和差集（`difference`）操作。
如果使用下面的每一个具体数据结构，请分析说明应该如何实现所需的操作，并且分析每个操作的时间复杂度。

    (a) 无序的Python列表。

    (b) 排序的Python列表。

    (c) Python字典。（注意：在这里，集合里的元素将作为键来使用，你可以用`None`或`True`作为值。）

5. 假设你使用的编程语言是一个包含字典，但是不包含列表/数组的语言。
你要怎样才能实现顺序集合？
如果按照你的方法实现了基本列表抽象数据类型，请分析它的各项操作的效率。

**编程练习**

1. 修改牌组（`Deck`）类，以便可以使用实例变量来检测牌组当前的大小尺寸。
这是否会改变尺寸操作的时间复杂度？
请先做一些研究再来回答这个问题。

2. 查看Python的随机（`random`）模块所提供的函数，从而简化牌组（`Deck`）类中的洗牌相关的代码。

3. 假设我们希望能够将扑克牌放回牌组中。
尝试去修改牌组（`Deck`）类，从而让它包含`addTop`（将扑克牌插入到扑克牌牌组的最前面），`addBottom`（将扑克牌插入到扑克牌牌组的最后边）和`addRandom`（将扑克牌插入扑克牌牌组里的随机位置）这些操作。

4. 如果不用洗牌的话，还有一种能够随机分配扑克牌的方法是：
从当前有序的牌组里的随机位置处发牌。
请实现使用这个方法的牌组（`Deck`）类。
并分析你提供的这个新操作的效率。

5. 如果扑克牌总是以随机的顺序来发牌，那么在我们在测试涉及到扑克牌牌组的程序的时候可能会不太方便。
一种解决方案是允许牌组能够以某种特定顺序被“堆叠”起来。
设计一个可以从文件里读取扑克牌牌组相关内容的牌组（`Deck`）类。

6. 修改手牌（`Hand`）类里的`sort`方法，让它能够在“本地”对手牌进行排序。
提示：可以参考本地打乱（洗牌）算法。

7. 还有一种能够使手牌按照特定顺序排列的方法是：
在添加扑克牌的时候，就把它放进适当的位置。
这个算法被称为*插入排序*（*insertion sort*）。
实现一个使用这个算法来保证手牌顺序的手牌（`Hand`）类。

8. 实现一个牌组（`Deck`）类的扩展，来让它可以被用来玩纸牌游戏大战。
你需要能够创建一个空的牌组并将扑克牌放入其中。

9. 编写一个程序来玩下面这个简单的单人纸牌游戏。
有$N$张扑克牌面朝上的摆放在桌子上。
如果其中有任意两张扑克牌具有相同的大小，则面朝上的发出新的扑克牌。
一直发牌，直到扑克牌牌组为空，或者再也没有两个扑克牌具有相同的大小。
如果所有扑克牌都被发出，则玩家获得胜利。
多运行几次这个单人纸牌游戏来找到在使用不同$N$的值时的获胜的概率。

10. 编写一个程序来发牌以及评估当前的手牌。

11. 编写一个程序来模拟二十一点游戏。

12. 编写一个程序来发牌以及评估当前的桥牌手牌，以确定他们能不能有开叫。

13. 修改马尔可夫（Markov）胡言乱语生成器，让它在字符级别而不是单词级别上工作。
注意：你并不需要修改类来执行此操作，只需要修改它的使用方式就行了。

14. 扩展马尔可夫（Markov）胡言乱语生成器，从而让它能够在创建模型时确定前缀的大小。
构造函数将提供一个参数来获得指定的前缀长度。
在不同大小的文本上尝试不同的前缀长度，看看会发生什么。
再把这个版本的生成器和上面问题里的生成器相结合，现在你就有了一个具备输出功能多样并且极具娱乐性的乱码发生器了。

15. 通过实现映射抽象数据类型的各种操作，来编写一个自己的字典类。
使用键值对列表作为具体的数据存储方式。
为你的这个类编写恰当的测试，并为每个操作都提供相应的$θ$分析。
