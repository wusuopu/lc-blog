---
layout: post
title: "[转载]GObject 学习笔记：GObject 子类私有属性的外部访问"
date: 2012-05-29 05:31:41 +0000
comments: true
post_id: 83770
permalink: /archives/83770.html
categories: ["编程开发"]
tags: ["GObject"]
---

之前，写了一篇 GObject 劝学的文章 [1]，还有两篇有关 GObject 子类对象数据封装的文章 [2, 3]。

虽然，创建一个 GObject 子类对象需要一些辅助函数和宏的支持，并且它们的内幕也令人费解，但是只要将足够的信任交托给 GObject 开发者，将那些辅助函数和宏当作“语法”糖一样享用，一切还是挺简单的。至于细节，还是等较为全面的掌握 GObject 库的用法之后再去挖掘！

现在，我们基本上知道了如何将数据封装并藏匿于 GObject 子类的实例结构体中。本文打算再向前走一步，关注如何实现在外部比较安全的访问（读写）这些数据。

<b>简单的做法</b>

像下面这样的双向链表数据结构：

``` c
typedef struct _PMDListNode PMDListNode;
struct _PMDListNode {
        PMDListNode *prev;
        PMDListNode *next;
};
 
typedef struct _PMDList PMDList;
struct _PMDList {
        PMDListNode *head;
        PMDListNode *tail;
};
```

现在，我们希望能够安全访问 PMDList 结构题的两个成员，即链表的首结点指针 head 和尾结点指针 tail，以便进行一些操作，例如将两个双向链表 list1 和 list2 链接到一起。

所谓安全访问，意味着不要像下面这样简单粗暴：

``` c
/* 将 list1 与 list2 链接在一起 */
list1->tail->next = list2->head;
list2->head->prev = list1->tail;
```

而应当委婉一些：

``` c
PMDListNode *list1_tail, *list2_head;
 
list1_tail = pm_dlist_get (list1, TAIL);
list2_head = pm_dlist_get (list2, HEAD);
 
pm_dlist_set (list1, TAIL, NEXT, list2_head);
pm_dlist_set (list2, HEAD, PREV, list1_tail);
```

这样委婉的访问，有什么好处？答案很简单，可以将数据的变化与程序的功能隔离开，数据的变化不影响程序的功能。

试想，如果有一天，上述 PMDList 结构体的设计者使用 GObject 子类化的方法将双向链表定义为建 PMDList 类的形式，并且将链表的首结点指针 head 与尾结点都隐匿起来，那么上述的那个简单粗暴的数据访问方法便失效了。更糟糕的是，PMDList 类的设计者明知道很多人会受到这种数据变化的影响，对此也毫无办法。

如果 PMDList 结构体的设计者提供了 pm_dlist_set 与 pm_dlist_get 函数，那么即便设计者基于 GObject 子类化的方式定义了 PMDList 类，他只需要修改 pm_dlist_set 和 pm_dlist_get 函数，便可以让上述那种委婉方式访问 PMDList 结构体成员的代码不会受到任何影响。

既然 pm_dlist_set 与 pm_dlist_get 函数这样有用，我们可以像下面这样实现它们。

``` c
typedef enum _PM_DLIST_PROPERTY PM_DLIST_PROPERTY
enum _PM_DLIST_PROPERTY {
        PM_DLIST_HEAD,
        PM_DLIST_TAIL,
        PM_DLIST_NODE_PREV,
        PM_DLIST_NODE_NEXT
};
 
PMDListNode *
pm_dlist_get (PMDList *self, PM_DLIST_PROPERTY property)
{
        PMDListNode *node = NULL;
 
        switch (property) {
        case PM_DLIST_HEAD:
                node = self->head;
                break;
        case PM_DLIST_TAIL:
                node = self->tail;
                break;
        default:
                g_print ("对不起，你访问的成员不存在!\n");
        }
 
        return node;
}
 
void
pm_dlist_set (PMDList *self, 
              PM_DLIST_PROPERTY property,
              PM_DLIST_PROPERTY subproperty,
              PMDListNode *node)
{
        switch (property) {
        case PM_DLIST_HEAD:
                if (subproperty == PM_DLIST_NODE_PREV)
                        self->head->prev = node;
                else if (subproperty == PM_DLIST_NODE_NEXT)
                        self->head->next = node;
                break;
        case PM_DLIST_TAIL:
                if (subproperty == PM_DLIST_NODE_PREV)
                        self->tail->prev = node;
                else if (subproperty == PM_DLIST_NODE_NEXT)
                        self->tail->next = node;
                break;
        default:
                g_print ("对不起，你访问的成员不存在!\n");
        }
}
```

事实上，上述代码所实现的功能仅仅是实现下面这 6 种赋值运算：

``` c
PMDList *list;
 
list->head->prev = aaaa;
list->head->next = bbbb;
 
list->tail->prev = cccc;
list->tail->next = dddd;
 
node = list->head;
node = list->tail;
```

对于区区一个链表的最原始形态的属性访问模拟便已如此，那些内建支持面向对象的编程语言、动态编程语言以及函数编程语言，它们所提供的语法越高级，那么它们等价的 C 代码量便会越庞大。

如果你所解决的问题，需要很多层的数据抽象，如果使用 C 语言的话，就不得不写很多的模拟代码。倘若这些模拟代码在你全部代码所占的比重超过了你的容忍限度，可以考虑换一种更合适的编程语言。当然，你不可能是先用 C 写完代码后，再去评估那部分模拟代码所占的比重，但是这并不妨碍你凭借现有的经验去粗略估计。

我将 gtk+ 作为使用 C 语言应用的典范，gtk+ 3.0 的全部代码大约 515500 行，而 GObject 的代码大概 20000 行，其所占比重大约为 4%，这其中还不算 GTK+ 的那些基于 GObject 的底层库的代码量。我觉得 GTK+ 开发者使用 GObject 实现足够的面向对象支持，是比较划算的。

<b>那个很二的参数</b>

回顾一下文档 [2] 和 [3] 中出现过的 g_object_new 函数的参数：

``` c
PMDList *list = g_object_new (PM_TYPE_DLIST, NULL);
```

该函数第一个参数 PM_TYPE_DLIST 的含义在文档 [2] 中已有较为详细的解释，而第二个参数的含义一直被故意的忽略，现在才是分析它的最好时机。事实上，g_object_new 接受的是可变参数[4]，第二个参数后面，还可以有第三个、第四个...理论上的无穷个。这些参数的作用可以用下面的代码来表现：

``` c
PMDList *list = g_object_new (PM_TYPE_DLIST,
                              "head", NULL,
                              "tail", NULL,
                              NULL);
```

如果采用这种方式调用 g_object_new 函数，意味着在文档 [3] 中的 dlist.c 文件中，不需要再在 PMDList 类的实例结构体初始化函数 pm_dlist_init 中对链表首结点和尾结点指针进行赋值了，即 pm_dlist_init 函数：

``` c
static void
pm_dlist_init (PMDList *self)
{
        PMDListPrivate *priv = PM_DLIST_GET_PRIVATE (self);
          
        priv->head = NULL;
        priv->tail = NULL;
}
```

可以为空：

``` c
static void
pm_dlist_init (PMDList *self)
{ 
}
```

换句话说，就是你在使用 g_object_new 函数进行对象实例化的过程中，可直接通过 g_object_new 函数的输入参数去初始化对象的属性，这是通过“属性名-属性值”参数来实现的，即 g_object_new 的第二个参数为属性名，第三个参数为属性值，它们在 g_object_new 内部会被合成为“属性名-属性值”结构；同理，第四个参数与第五个参数也可以形成“属性名-属性值”结构，依次类推，当属性名参数为 NULL 时，g_object_new 会认为“属性名：属性值”结构序列结束。上面示例中的 g_object_new 可形成 2 个“参数名：参数值”结构：

``` c
"head" : NULL
"tail" : NULL
```

g_object_new 函数会根据属性名匹配对象的相应属性，并将属性值赋予该属性，但是这需要 PMDList 类的设计者去实现一部分比较丑陋的代码。

<b>将丑陋封锁在内部</b>

要想实现上一节所讲述的让 g_object_new 函数中通过“属性名-属性值”结构为 GObject 子类对象的属性进行初始化，我们需要完成以下工作：

实现 p_t_set_property 与 p_t_get_property 函数，让它们来完成 g_object_new 函数的“属性名-属性值”结构向 GObject 子类属性的映射。
在GObject 子类的类结构体初始化函数中，让 GObject 类（基类）的两个函数指针 set_property 与 get_property 分别指向 p_t_set_property 与 p_t_get_property 函数。
在 GObject 子类的类结构体初始化函数中，为 GObject 子类安装属性。
前两个步骤，可以理解为 GObject 的两个虚函数的实现。第三个步骤，可以视为为比文档 [3] 中 GObject 子类私有属性更高级一些的模拟。

现在，开始动手吧。

首先，pm_dlist_set_property 和 pm_dlist_get_property 函数，可以像下面这样实现：

``` c
static void
pm_dlist_set_property (GObject *object, guint property_id,
                       const GValue *value, GParamSpec *pspec)
{
        PMDList *self = PM_DLIST (object);
        PMDListPrivate *priv = PM_DLIST_GET_PRIVATE (self);
         
        switch (property_id) {
        case PROPERTY_DLIST_HEAD:
                priv->head = g_value_get_pointer (value);
                break;
        case PROPERTY_DLIST_HEAD_PREV:
                priv->head->prev = g_value_get_pointer (value);
                break;
        case PROPERTY_DLIST_HEAD_NEXT:
                priv->head->next = g_value_get_pointer (value);
                break;
        case PROPERTY_DLIST_TAIL:
                priv->tail = g_value_get_pointer (value);
                break;
        case PROPERTY_DLIST_TAIL_PREV:
                priv->tail->prev = g_value_get_pointer (value);
                break;
        case PROPERTY_DLIST_TAIL_NEXT:
                priv->tail->next = g_value_get_pointer (value);
                break;
        default:
                G_OBJECT_WARN_INVALID_PROPERTY_ID (object, property_id, pspec);
                break;
        }
}
 
static void
pm_dlist_get_property (GObject *object, guint property_id,
                       GValue *value, GParamSpec *pspec)
{
        PMDList *self = PM_DLIST (object);
        PMDListPrivate *priv = PM_DLIST_GET_PRIVATE (self);
         
        switch (property_id) {
        case PROPERTY_DLIST_HEAD:
                g_value_set_pointer (value, priv->head);
                break;
        case PROPERTY_DLIST_HEAD_PREV:
                g_value_set_pointer (value, priv->head->prev);
                break;
        case PROPERTY_DLIST_HEAD_NEXT:
                g_value_set_pointer (value, priv->head->next);
                break;
        case PROPERTY_DLIST_TAIL:
                g_value_set_pointer (value, priv->tail);
                break;
        case PROPERTY_DLIST_TAIL_PREV:
                g_value_set_pointer (value, priv->tail->prev);
                break;
        case PROPERTY_DLIST_TAIL_NEXT:
                g_value_set_pointer (value, priv->tail->next);
                break;
        default:
                G_OBJECT_WARN_INVALID_PROPERTY_ID (object, property_id, pspec);
                break;
        }
}
```

哇，代码很多！但是请不要恐惧，因为所有 GObject 子类属性的 set 与 get 函数的实现，思路上均与上述代码相似。要理解这些代码，只需注意以下几点：

PM_DLIST (object) 宏的作用是将一个基类指针类型转换为 PMDList 类的指针类型，它需要 GObject 子类的设计者提供，我们可以将其定义为：

``` c
#define PM_DLIST(object) \
        G_TYPE_CHECK_INSTANCE_CAST ((object), PM_TYPE_DLIST, PMDList))
```

PROPERTY_DLIST_XXXX 宏，可以采用枚举类型实现。
GValue 类型是一个变量容器，可用于存放各种变量的值，例如整型数、指针、GObject 子类等等，上述代码主要用 GValue 存放指针变量的值。
GParamSpec 类型是比 GValue 高级一点的变量容器，它不仅可以存放各种变量的值，还能为这些值命名，因此它比较适合用于表示 g_object_new 函数的“属性名-属性值”结构。不过，在上述代码中，GParamSpec 类型只是昙花一现，没关系，反正下文它还会出现。
在理解了上述代码之后，我们继续前进，迈入 PMDList 类的类结构体初始化函数，首先要覆盖 GObject 类的两个函数指针：

``` c
static void
pm_dlist_class_init (PMDListClass *klass)
{
        /* 对象私有属性的安装，详见文档 [3] */
        g_type_class_add_private (klass, sizeof (PMDListPrivate));
 
 
        GObjectClass *base_class = G_OBJECT_CLASS (klass);
        base_class->set_property = pm_dlist_set_property;
        base_class->get_property = pm_dlist_get_property;
 
/* 未完，下文待续 */
```

set_property 和 get_property 是两个函数指针，它们位于 GObject 类的类结构体中。如果你看过文档 [2]，也许你还记得 GObject 库中，类是由实例结构体与类结构体构成的。对象的属性，应当存储在实例结构体中，而所有对象共享的数据，应当存储于类结构体中。因此，set_property 和 get_property 是两个函数指针可以被 GObject 类及其子类的所有对象共享，并且各个对象都可以让这两个函数指针指向它所期望的函数。

类似的机制，在 C++ 中被称为“虚函数”，主要用于实现多态。不过，即便你不知道虚函数与多态是什么东西，这也无所谓，你只需要知道 PMDList 类从它的父类——GObject 类中继承了 2 个函数指针，在 PMDList 类的类结构体初始化函数中，将这 2 个函数指针指向了前文中定义的 pm_dlist_set_property 与 pm_dlist_get_property 函数，这些就足够了。

接下来，就是向 PMDList 类安装属性，紧接上面的代码：

``` c
/* 接前文尚未完成的 pm_dlist_class_init 函数 */
        GParamSpec *pspec;
        pspec = g_param_spec_pointer ("head",
                                      "Head node",
                                      "The head node of the double list",
                                      G_PARAM_READABLE | G_PARAM_WRITABLE | G_PARAM_CONSTRUCT);
        g_object_class_install_property (base_class, PROPERTY_DLIST_HEAD, pspec);
/* 未完，下文待续 */
```

在 pm_dlist_set_property 与 pm_dlist_get_property 函数中昙花一现的 GParamSpec 类型终于又出现了。我知道，它看起来似乎很恐怖，但是它所作的事情却很简单，就是对一个键值对打包成一个数据结构，然后将之安装到相应的 GObject 子类中。

g_param_spec_pointer 函数，可以将“属性名：属性值”参数打包为 GParamSpec 类型的变量，该函数的第一个参数用于设定键名，第二个参数是键名的昵称，第三个参数是对这个键值对的详细描述，第四个参数用于表示键值的访问权限，G_PARAM_READABLE | G_PARAM_WRITABLE 是指定属性即可读又可写，G_PARAM_CONSTRUCT 是设定属性可以在对象示例化之时被设置。

g_object_class_install_property 函数用于将 GParamSpec 类型变量所包含的数据插入到 GObject 子类中，其中的细节可以忽略，只需要知道该函数的第一个参数为 GObject 子类的类结构体，第二个参数是 GParamSpec 对应的属性 ID。GObject 子类的属性 ID 在前文已经提及，它是 GObject 子类设计者定义的宏或枚举类型。第三个参数是要安装值向 GObject 子类中的 GParamSpec 类型的变量指针。

但是，一定要注意，g_object_class_install_property 函数的第二个参数值不能为 0。在使用枚举类型来定义 ID 时，为了避免 0 的使用，一个比较笨的技巧就是像下面这样设计一个枚举类型：

``` c
enum PropertyDList {
        PROPERTY_DLIST_0,
        PROPERTY_DLIST_HEAD,
        PROPERTY_DLIST_HEAD_PREV,
        PROPERTY_DLIST_HEAD_NEXT,
        PROPERTY_DLIST_TAIL,
        PROPERTY_DLIST_TAIL_PREV,
        PROPERTY_DLIST_TAIL_NEXT
};
```

其中的 PROPERTY_DLIST_0，只是占位符，它不被使用。

按照上面的属性的安装方式，我们可以陆续写处其它属性的安装代码，即 pm_dlist_class_init 函数的剩余部分：

``` c
/* 接前文尚未完成的 pm_dlist_class_init 函数 */
        pspec = g_param_spec_pointer ("head-prev",
                                      "The previous node of the head node",
                                      "The previous node of the head node of the double list",
                                      G_PARAM_READABLE | G_PARAM_WRITABLE);
        g_object_class_install_property (base_class, PROPERTY_DLIST_HEAD_PREV, pspec);
        pspec = g_param_spec_pointer ("head-next",
                                      "The next node of the head node",
                                      "The next node of the head node of the double list",
                                      G_PARAM_READABLE | G_PARAM_WRITABLE);
        g_object_class_install_property (base_class, PROPERTY_DLIST_HEAD_NEXT, pspec);
        pspec = g_param_spec_pointer ("tail",
                                      "Tail node",
                                      "The tail node of the double list",
                                      G_PARAM_READABLE | G_PARAM_WRITABLE | G_PARAM_CONSTRUCT);
        g_object_class_install_property (base_class, PROPERTY_DLIST_TAIL, pspec);
        pspec = g_param_spec_pointer ("tail-prev",
                                      "The previous node of the tail node",
                                      "The previous node of the tail node of the double list",
                                      G_PARAM_READABLE | G_PARAM_WRITABLE);
        g_object_class_install_property (base_class, PROPERTY_DLIST_TAIL_PREV, pspec);
        pspec = g_param_spec_pointer ("tail-next",
                                      "The next node of the tail node",
                                      "The next node of the tail node of the double list",
                                      G_PARAM_READABLE | G_PARAM_WRITABLE);
        g_object_class_install_property (base_class, PROPERTY_DLIST_TAIL_NEXT, pspec);
}
```

这些代码又冗余又无趣，但是并不难理解。

<b>将简洁留给外部</b>

对于上一节所实现的 PMDList 类，可以采用下面的代码在对象实例化时便进行属性的初始化，即将链表的首结点和尾节点指针设为 NULL：

``` c
PMDList *list = g_object_new (PM_TYPE_DLIST,
                              "head", NULL,
                              "tail", NULL,
                              NULL); /* 要记得键值对参数之后，要以 NULL 收尾 */
```

也可以调用 g_object_get_property 函数获取 PMDList 类的实例属性，例如获取链表 list 的首结点指针：

``` c
GValue val = { 0, };
 
g_value_init(val,G_TYPE_POINTER);
g_object_get_property(G_OBJECT(list),"head",val);
g_value_unset (val);
```

也可以调用 g_object_set_property 函数设置 PMDList 类的实例属性，例如将链表 list1 的尾结点指针所指向的结点地址赋给链表 list2 的首结点的前驱结点指针：

``` c
GValue val = {0};
 
g_value_init (val,G_TYPE_POINTER);
g_object_get_property (G_OBJECT(list1), "tail", val);
g_object_set_property (G_OBJECT(list2), "head-prev", val);
g_value_unset (val);
```

如果我们要解决本文开始时的那个 list1 与 list2 链接的问题，可以这样：

``` c
GValue list1_tail = {0};
GValue list2_head = {0};
 
g_value_init (&list1_tail, G_TYPE_POINTER);
g_value_init (&list2_head, G_TYPE_POINTER);
 
g_object_get_property (G_OBJECT(list1), "tail", &list1_tail);
g_object_set_property (G_OBJECT(list2), "head-prev", &list1_tail);
 
 
g_object_get_property (G_OBJECT(list2), "head", &list2_head);
g_object_set_property (G_OBJECT(list1), "tail-next", &list2_head);
 
g_value_unset (&list2_head);
g_value_unset (&list1_tail);
```

看上去还不错。当然，前提是你需要了解一下 GValue 容器的用法，并且上述代码已经展示了它的基本用法，但是最好还是阅读文档 [5, 6]。

上述代码中使用的 g_object_set_property 与 g_object_get_property 函数，看上去很无趣，每次只能设置或获取一个属性值，并且还要借助 GValue 容器，事实上它们是为那些基于 GObject 库的语言绑定使用的。对于在 C 程序中直接使用 GObject 库的用户，可以使用 g_object_set 和 g_object_get 函数一次进行多个属性的设置与获取，它们的用法与 g_object_new 相似，可以处理以 NULL 结尾的“属性名-属性值”参数序列。

<b>将一切放在一起</b>

本文示例源码可从 http://garfileo.is-programmer.com/user_files/garfileo/File/test/pm-dlist.tar.gz 下载。

~End~

原文出处：http://garfileo.is-programmer.com

