---
layout: post
title: "[转载]GObject 学习笔记：使用 GObject 库模拟类的数据封装形式"
date: 2012-05-27 11:20:47 +0000
comments: true
post_id: 83764
permalink: /archives/83764.html
categories: ["编程开发"]
tags: ["GObject"]
---

事实上，有关 GObject 库的学习与使用，GObject 库参考手册提供了一份简短且过于晦涩的指南。如果你能够理解它，那么完全可以无视这篇以及后续的几篇文章。倘若没有明白那份指南，那么建议最好能克制一下，先不要急于去做文档 [1] 中所列举那些探索，谨记 Knuth 所说的，过早优化是诸恶之源。

这篇文档主要讲述如何使用 GObject 库来模拟面向对象程序设计的最基本的要素，即基于类的数据封装，所采用的具体示例是一个双向链表的设计。

<b>从一个双向链表的数据结构开始</b>

对于双向链表这种数据结构，即便是 C 语言的初学者也不难创建一个名为 double-list.h 的头文件并写出以下代码：

``` c
/* file name: double-list.h */
 
#ifndef DOUBLE_LIST_H
#define DOUBLE_LIST_H
 
struct double_list_node {
        struct doule_list_node *prev;
        struct double_list_node *next;
        void *data;
};
 
struct double_list {
        struct double_list_node *head;
        struct double_list_node *tail;
};
 
#endif
```

较为熟悉 C 语言的人自然不屑于写出上面那种新手级别的代码，他们通常使用 typedef 关键字去定义数据类型，并且将 double_list 简写为 dlist，以避免重复的去写 "struct double_list_xxxxx" 这样的代码，此外还使用了 Pascal 命名惯例，即单词首字母大写[2]，具体如下：

``` c
/* file name: dlist.h（版本 2）*/
 
#ifndef DLIST_H
#define DLIST_H
 
typedef struct _DListNode DListNode;
struct  _DListNode {
        DListNode *prev;
        DListNode *next;
        void *data;
};
 
typedef struct _DList DList;
struct  _DList {
        DListNode *head;
        DListNode *tail;
};
 
#endif
```

现在，代码看上去稍微专业了一点。

但是，由于 C 语言没有为数据类型提供自定义命名空间的功能，程序中所有的数据类型（包括函数）均处于同一个命名空间，这样数据类型便存在因为同名而撞车的可能性。为了避免这一问题，更专业一点的程序员会为数据类型名称添加一些前缀，并且通常会选择项目名称的缩写。我们可以为这种命名方式取一个名字，叫做 PT 格式，P 是项目名称缩写，T 是数据类型的名称。例如，对于一个多面体建模（Polyhedron Modeling）的项目，如果要为这个项目定义一个双向链表的数据类型，通常是先将 dlist.h 文件名修改为 pm-dlist.h，将其内容改为：

``` c
/* file name: pm-dlist.h*/
 
#ifndef PM_DLIST_H
#define PM_DLIST_H
 
typedef struct _PMDListNode PMDListNode;
struct  _PMDListNode {
        PMDListNode *prev;
        PMDListNode *next;
        void *data;
};
 
typedef struct _PMDList PMDList;
struct  _PMDList {
        PMDListNode *head;
        PMDListNode *tail;
};
 
#endif
```

在以上一波三折的过程中，我们所做的工作就是仅仅是定义了两个结构体而已，一个是双向链表结点的结构体，另一个是双向链表的结构体，并且这两个结构体中分别包含了一组指针成员。这样的工作，用面向对象编程方法中的术语，叫做”数据封装“。借用《C++ Primer》中的定义，所谓数据封装，就是一种将低层次的元素组合起来，形成新的、高层次实体的技术。对于上述代码而言，指针类型的变量属于低层次的元素，而它们所构成的结构体，则是高层次的实体。在面向对象程序设计中，类是数据封装形式中的一等公民。

接下来，我们更进一步，使用 GObject 库模拟类的数据封装形式，如下：

``` c
/* file name: pm-dlist.h*/
 
#ifndef PM_DLIST_H
#define PM_DLIST_H
 
#include <glib-object.h>
 
typedef struct _PMDListNode PMDListNode;
struct  _PMDListNode {
        PMDListNode *prev;
        PMDListNode *next;
        void *data;
};
 
typedef struct _PMDList PMDList;
struct  _PMDList {
        GObject parent_instance;
        PMDListNode *head;
        PMDListNode *tail;
};
 
typedef struct _PMDListClass PMDListClass;
struct _PMDListClass {
        GObjectClass parent_class;
};
 
#endif
```

上述代码与 dlist.h 版本 2 中的代码相比，除去空行，多出 6 行代码，它们的作用是实现一个双向链表类。也许你会感觉这样很滑稽，特别当你特别熟悉 C++、Java、C# 之类的语言之时。

但是，上述代码的确构成了一个类。在 GObject 世界里，类是两个结构体的组合，一个是实例结构体，另一个是类结构体。例如，PMDList 是实例结构体，PMDListClass 是类结构体，它们合起来便可以称为 PMDList 类（此处的“PMDList 类”只是一个称谓，并非是指 PMDList 实例结构体。下文将要谈及的“GObject 类”的理解与此类似）。

也许你会注意到，PMDList 类的实例结构体的第一个成员是 GObject 结构体，PMDList 类的类结构体的第一个成员是 GObjectClass 结构体。其实，GObject 结构体与 GObjectClass 结构体分别是 GObject 类的实例结构体与类结构体，当它们分别作为 PMDList 类的实例结构体与类结构体的第一个成员时，这意味着 PMDList 类继承自 GObject 类。

也许你并不明白 GObject 为什么要将类拆解为实例结构体与类结构体，也不明白为什么将某个类的实例结构体与类结构体，分别置于另一个类的实例结构体与类结构体的成员之首便可实现类的继承，这些其实并不重要，至少是刚接触 GObject 时它们并不重要，应当像对待一个数学公式那样将它们记住。以后每当需要使用 C 语言来模拟类的封装形式时，只需要构建一个基类是 GObject 类的类即可。就像我们初学 C++ 那样，对于下面的代码，

``` c
class PMDListNode {
public:
        PMDListNode *prev;
        PMDListNode *next;
        void *data;
}
 
class PMDList : public GObject {
public:
        PMDListNode *head;
        PMDListNode *tail;
};
```

也许除了 C++ 编译器的开发者之外，没人会对为什么使用“class”关键字便可以将一个数据结构变成类，为什么使用一个冒号便可以实现 DList 类继承自 GObject 类，为什么使用 public 便可以将 DList 类的 head 与 tail 属性对外开放之类的问题感兴趣。

<b>继承 GObject 类的好处</b>

为什么 DList 类一定要将 GObject 类作为父类？主要是因为 GObject 类具有以下功能：

    基于引用计数的内存管理
    对象的构造函数与析构函数
    可设置对象属性的 set/get 函数
    易于使用的信号机制

现在即使并不明白上述功能的意义也无关紧要，这给予了我们对其各个击破的机会。

虽然，我们尚且不是很清楚继承 GObject 类的好处，但是不继承 GObject 类的坏处是显而易见的。在 cloverprince 所写的 11 篇文章[3]中，从第 2 篇到第 5 篇均展示了不使用 GObject 的坏处，虽然它们对理解 GObject 类的实现原理有很大帮助，但是对于 GObject 库的使用并无太多助益。

<b>概念游戏</b>

我承认，我到现在也不是很明白面向对象程序设计中的”类“、”对象“和”实例“这三者的关系。不过看到还有人同我一样没有搞明白[4]，心里便略微有些安慰，甚至觉得 C 语言不内建支持面向对象程序设计是一件值得庆幸的事情。暂时就按照文档[4]那样理解吧，对于上面所设计的 PMDList 类，可以用下面的代码模拟类的实例化与对象的实例化。

``` c
PMDList *list; /* 类的实例化 */
list = g_object_new (PM_TYPE_DLIST, NULL); /* 对象的实例化 */
```

也就是说，对于 PMDList 类，它的实例是一个对象，例如上述代码中的 list，而对象的实例化则是让这个对象成为计算机内存中的实体。

也许，对象的实例化比较令人费解，幸好，C 语言的表示会更加直观，例如：

``` c
PMDList *dlist; /* 类的实例化，产生对象 */
 
dlist = g_object_new (PM_TYPE_DLIST, NULL); /* 创建对象的一个实例 */
g_object_unref (dlist); /* 销毁对象的一个实例 */
 
dlist = g_object_new (PM_TYPE_DLIST, NULL); /* 再创建对象的一个实例 */
```

这里需要暂停，请回溯到上一节所说的让一个类继承 GObject 类的好处的前两条，即 GObject 类提供的“基于引用计数的内存管理”与“对象的构造函数与析构函数”，此时体现于上例中的 g_object_new 与 g_object_unref 函数。

g_object_new 用于构建对象的实例，虽然其内部实现非常繁琐和复杂，但这是 GObject 库的开发者所要考虑的事情。我们只需要知道 g_object_new 可以为对象的实例分配内存与初始化，并且将实例的引用计数设为 1。

g_object_unref 用于将对象的实例的引用计数减 1，并检测对象的实例的引用计数是否为 0，若为 0，那么便释放对象的实例的存储空间。

现在，再回到上述代码的真正要表述的概念，那就是：类的实例是对象，每个对象皆有可能存在多个实例。

下面，继续概念游戏，看下面的代码：

``` c
PMDList *list = g_object_new (PM_TYPE_DLIST, NULL);
```

这是类的实例化还是对象的实例化？自然是类的实例化的实例化，感觉有点恶心，事实上这只不过是为某个数据类型动态分配了内存空间，然后用指针指向它！我们最好是不再对“对象”和“实例”进行区分，对象是实例，实例也是对象，只需要知道它们所指代的事物在同一时刻是相同的，除非有了量子计算机。

<b>PM_TYPE_DLIST 引发的血案</b>

上一节所使用的 g_object_new 函数的参数是 PM_TYPE_DLIST 和 NULL。对于 NULL，虽然我们不知道它的真实意义，但是至少知道它表示一个空指针，而那个 PM_TYPE_DLIST 是什么？

PM_TYPE_DLIST 是一个宏，需要在 pm-dlist.h 头文件中进行定义，于是最新版的 pm-dlist.h 内容如下：

``` c
#ifndef PM_DLIST_H
#define PM_DLIST_H
 
#include <glib-object.h>
 
#define PM_TYPE_DLIST (pm_dlist_get_type ())
 
typedef struct _PMDListNode PMDListNode;
struct  _PMDListNode {
        PMDListNode *prev;
        PMDListNode *next;
        void *data;
};
 
typedef struct _PMDList PMDList;
struct  _PMDList {
        GObject parent_instance;
        PMDListNode *head;
        PMDListNode *tail;
};
 
typedef struct _PMDListClass PMDListClass;
struct _PMDListClass {
        GObjectClass parent_class;
};
 
GType pm_dlist_get_type (void);
 
#endif
```

嗯，与之前的 pm-dlist.h 相比，现在又多了两行代码

``` c
#define PM_TYPE_DLIST (pm_dlist_get_type ())
GType pm_dlist_get_type (void);
```

显然，PM_TYPE_DLIST 这个宏是用来替代函数 pm_dlist_get_type 的，该函数的返回值是 GType 类型。

我们将 PM_TYPE_DLIST 宏作为 g_object_new 函数第一个参数，这就意味着向 g_object_new 函数传递了一个看上去像是在获取数据类型的函数。不需要猜测，也不需要去阅读 g_object_new 函数的源代码，g_object_new 之所以能够为我们进行对象的实例化，那么它必然要知道对象对应的类的数据结构，pm_dlist_get_type 函数的作用就是告诉它有关 PMDList 类的具体结构。

现在既然知道了 PM_TYPE_DLIST 及其代表的函数 pm_dlist_get_type，那么 pm_dlist_get_type 具体该如何实现？很简单，只需要再建立一个 pm-dlist.c 文件，内容如下：

``` c
#include "pm-dlist.h"
 
G_DEFINE_TYPE (PMDList, pm_dlist, G_TYPE_OBJECT);
 
static
void pm_dlist_init (PMDList *self)
{
        g_printf ("\t实例结构体初始化！\n");
 
        self->head = NULL;
        self->tail = NULL;
}
 
static
void pm_dlist_class_init (PMDListClass *klass)
{
        g_printf ("类结构体初始化!\n");
}
```

这样，在源代码文件的层次上，pm-dlist.h 文件存放这 PMDList 类的声明，pm-dlist.c 文件存放的是 PMDList 类的具体实现。

在上述的 pm-dlist.c 中，我们并没有看到 pm_dlist_get_type 函数的具体实现，这是因为 GObject 库所提供的 G_DEFINE_TYPE 宏可以为我们生成 pm_dlist_get_type 函数的实现代码。

G_DEFINE_TYPE 宏，顾名思义，它可以帮助我们最终实现类类型的定义。对于上例，

``` c
G_DEFINE_TYPE (PMDList, pm_dlist, G_TYPE_OBJECT);
```

G_DEFINE_TYPE 可以让 GObject 库的数据类型系统能够识别我们所定义的 PMDList 类类型，它接受三个参数，第一个参数是类名，即 PMDList；第二个参数则是类的成员函数（面向对象术语称之为”方法“或”行为“）名称的前缀，例如 pm_dlist_get_type 函数即为 PMDList 类的一个成员函数，"pm_dlist" 是它的前缀；第三个参数则指明 PMDList 类类型的父类型为 G_TYPE_OBJECT……嗯，这又是一个该死的宏！

也许你会注意到，PMDList 类类型的父类型 G_TYPE_OBJECT 与前面所定义的宏 PM_TYPE_DLIST 非常相像。的确是这样，G_TYPE_OBJECT 指代 g_object_get_type 函数。

为了便于描述，我们可以将 PMDList 类和 GObject 类这种形式的类类型统称为 PT 类类型，将 pm_dlist_get_type 和 g_object_get_type 这种形式的函数统称为 p_t_get_type 函数，并将 PM_TYPE_DLIST 和 G_TYPE_OBJECT 这样的宏统称为 P_TYPE_T 宏。当然，这种格式的函数名与宏名，只是一种约定。

若想让 GObject 库能够识别你所定义的数据类型，那么必须要提供一个 p_t_get_type 这样的函数。虽然你不见得非要使用 p_t_get_type 这样的函数命名形式，但是必须提供一个具备同样功能的函数。p_t_get_type 函数的作用是向 GObject 库所提供的类型管理系统提供要注册的 PT 类类型的相关信息，其中包含 PT 类类型的实例结构体初始化函数 p_t_init 与类结构体初始化函数 p_t_class_init，例如上例中的 pm_list_init 与 pm_list_class_init。

因为 p_t_get_type 函数是 g_object_new 函数的参数，当我们首次调用 g_object_new 函数进行对象实例化时，p_t_get_type 函数便会被 g_object_new 函数调用，从而引发 GObject 库的类型管理系统去接受 PT 类类型（例如 PMDList 类型）的申请并为其分配一个类型标识码作为 p_t_get_type 函数的返回值。当 g_object_new 函数从 p_t_get_type 函数那里获取 PT 类类型标识码之后，便可以进行对象实例的内存分配及属性的初始化。

<b>将一切放在一起</b>

这篇文章居然出乎意料的长，原本没打算涉及任何细节，结果有些忍不住。不过，倘若你顺利的阅读到这里，便已经掌握了如何使用 GObject 库在 C 语言程序中模拟面向对象程序设计中基于类的数据封装，并且我们完成了一个双向链表类 PMDList 的数据封装。

为了验证 PMDList 类是否可用，可以再建立一份 main.c 文件进行测试，内容如下：

``` c
#include "pm-dlist.h"
 
int
main (void)
{
        /* GObject 库的类型管理系统的初始化 */
        g_type_init ();
 
        int i;
        PMDList *list;
 
        /* 进行三次对象实例化 */
        for (i = 0; i < 3; i++){
                list = g_object_new (PM_TYPE_DLIST, NULL);
                g_object_unref (list);
        }
 
        /* 检查实例是否为 GObject 对象 */
        list = g_object_new (PM_TYPE_DLIST, NULL);
        if (G_IS_OBJECT (list))
                g_printf ("\t这个实例是一个 GObject 对象！\n");
         
        return 0;
}
```

编译上述测试程序的命令为：	  
$ gcc $(pkg-config --cflags --libs gobject-2.0) pmd-dlist.c main.c -o test

测试程序的运行结果如下：  

```
$ ./test  
类结构体初始化!  
    实例结构体初始化！  
    实例结构体初始化！  
    实例结构体初始化！  
    实例结构体初始化！  
    这个实例是一个 GObject 对象！  
```

从输出结果可以看出，PMDList 类的类结构体初始化函数只被调用了一次，而实例结构体的初始化函数的调用次数等于对象实例化的次数。这意味着，所有实例共享的数据，可保存在类结构体中，而所有对象私有的数据，则保存在实例结构体中。

上述的 main 函数中，在使用 GObject 库的任何功能之前，必须先调用 g_type_init 函数初始化 GObject 库的类型管理系统，否则程序可能会出错。

main 函数中还使用了 G_IS_OBJECT 宏，来检测 list 对象是否为 G_TYPE_OBJECT 类型的对象：  
G_IS_OBJECT (list)

因为 PMDList 类继承自 GObject 类，那么一个 PMDList 对象自然是一个 G_TYPE_OBJECT 类型的对象。

<b>总结</b>

也许我讲的很明白，也许我一点都没有讲明白。但是使用 GObject 库模拟基于类的数据封装，或者用专业术语来说，即 GObject 类类型的子类化，念起来比较拗口，便干脆简称 GObject 子类化，其过程只需要以下四步：

    在 .h 文件中包含 glib-object.h；
    在 .h 文件中构建实例结构体与类结构体，并分别将 GObject 类的实例结构体与类结构体置于成员之首；
    在 .h 文件中定义 P_TYPE_T 宏，并声明 p_t_get_type 函数；
    在 .c 文件中调用 G_DEFINE_TYPE 宏产生类型注册代码。

也许让我们感到晕眩的，是那些命名约定。但是，从工程的角度来说，GObject 库所使用的命名风格是合理的，值得 C 程序员借鉴。

~ End ~

原文出处：http://garfileo.is-programmer.com
