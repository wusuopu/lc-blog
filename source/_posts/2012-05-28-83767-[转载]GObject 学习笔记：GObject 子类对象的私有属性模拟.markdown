---
layout: post
title: "[转载]GObject 学习笔记：GObject 子类对象的私有属性模拟"
date: 2012-05-28 12:54:39 +0000
comments: true
post_id: 83767
permalink: /archives/83767.html
categories: ["编程开发"]
tags: ["GObject"]
---

上一篇文章“使用 GObject 库模拟类的数据封装形式”讲述了 GObject 子类化过程，本文以其为基础，进一步讲述如何对数据进行隐藏，即对面向对象程序设计中的“私有属性”概念进行模拟。

<b>非类类型数据的隐藏</b>

第一个问题，可以称之为非类类型数据结构的隐藏，因为 PMDListNode 是普通的 C 结构体。隐藏这个结构体成员的方法有多种。

第一种方法尤为简单，如下：

``` c
typedef struct _PMDListNode PMDListNode;
struct  _PMDListNode {
/* private */
        PMDListNode *prev;
        PMDListNode *next;
/* public */
        void *data;
};
```

只需要向结构体中添加一条注释，用于标明哪些成员是私有的，哪些是可以被直接访问的。

也许你会认为这是开玩笑呢吧！但，这是最符合 C 语言设计理念的做法。C 语言认为，程序员应当知道自己正在干什么，而且保证自己的所作所为是正确的。

倘若你真的这么认为这是在开玩笑，那也没什么。我们还可以使用第二种隐藏的方法，即在 pm-dlist.h 文件中保留下面代码：

``` c
typedef struct _PMDListNode PMDListNode;
```

并将以下代码：

``` c
struct  _PMDListNode {
        PMDListNode *prev;
        PMDListNode *next;
        void *data;
};
```

转移到 pm-dlist.c 文件中。

这下隐藏的非常彻底。当然，这并不能防止用户打开 pm-dlist.c 文件查看 PMDListNode 的定义。不过，我们是自由软件，不怕你看。

如果想半遮半掩，稍微麻烦一些。可以在 pm-dlist.h 中写入以下代码：

``` c
typedef struct _PMDListPriv PMDListPriv;
typedef struct _PMDListNode PmdListNode;
struct _PMDListNode {
        PMDListPriv priv;
        void *data;
};
```

然后，将 PMDListPriv 的定义放在 pm-dlist.c 文件中，如下：	

``` c
struct _PMDListPriv {
        PMDListNode *prev;
        PMDListNode *next;
};
```

<b>GObject 子类对象的属性隐藏</b>

GObject 子类对象的属性即继承 GObject 类的类的实例结构体所包含的属性，这句话说起来还真拗口。

考虑一下如何隐藏 PMDList 类的实例结构体中的成员。先回忆一下这个结构体的定义：

``` c
typedef struct _PMDList PMDList;
struct  _PMDList {
        GObject parent_instance;
        PMDListNode *head;
        PMDListNode *tail;
};
```

我们希望 head 与 tail 指针不容他人窥视，虽然可以使用上一节的方式进行数据隐藏，但是 GObject 库为 GObject 子类提供了一种私有结构体的机制，基于它也可以实现数据隐藏，而且更像是隐藏。

首先，我们将 pm-dlist.h 中 PMDList 结构体的定义修改为：

``` c
typedef struct _PMDList PMDList;
struct  _PMDList {
        GObject parent_instance;
};
```

然后，在 pm-dlist.c 文件中，定义一个结构体：

``` c
typedef struct _PMDListPrivate PMDListPrivate;
struct  _PMDListPrivate {
        PMDListNode *head;
        PMDListNode *tail;
};
```

再在 dm-dlist.c 中定义一个宏：

``` c
#define PM_DLIST_GET_PRIVATE(obj) (\
        G_TYPE_INSTANCE_GET_PRIVATE ((obj), PM_TYPE_DLIST, PMDListPrivate))
```

这个宏可以帮助我们从对象中获取所隐藏的私有属性。例如，在 PMDList 类的实例结构体初始化函数中，使用 PM_DLIST_GET_PRIVATE 宏获取 PMDList 对象的 head 与 tail 指针，如下：

``` c
static void
pm_dlist_init (PMDList *self)
{
        PMDListPrivate *priv = PM_DLIST_GET_PRIVATE (self);
         
        priv->head = NULL;
        priv->tail = NULL;
}
```

但是，那个 PMDListPrivate 结构体是怎样被添加到 PMDList 对象中的呢？答案存在于 PMDList 类的类结构体初始化函数之中，如下：

``` c
static void
pm_dlist_class_init (PMDListClass *class)
{
        g_type_class_add_private (klass, sizeof (PMDListPrivate));
}
```

由 于 pm_dlist_class_init 函数会先于 pm_dlist_init 函数被 g_object_new 函数调用，GObject 库的类型管理系统可以从 pm_dlist_class_init 函数中获知 PMDListPrivate 结构体所占用的存储空间，从而 g_object_new 函数在为 PMDList 对象的实例分配存储空间时，便会多分出一部分以容纳 PMDListPrivate 结构体，这样便相当于将一个 PMDListPrivate 结构体挂到 PMDList 对象之中。

GObject 库对私有属性所占用的存储空间是由限制的。一个 GObject 子类对象，它的私有属性及其父类对象的私有属性累加起来不能超过 64 KB。
<b>将一切放到一起</b>

将本文的示例代码综合到一起，便可以得到数据隐藏方法的全貌。

完整的 pm-dlist.h 文件，内容如下：

``` c
#ifndef PM_DLIST_H
#define PM_DLIST_H
  
#include <glib-object.h>
  
#define PM_TYPE_DLIST (pm_dlist_get_type ())
  
typedef struct _PMDList PMDList;
struct  _PMDList {
        GObject parent_instance;
};
  
typedef struct _PMDListClass PMDListClass;
struct _PMDListClass {
        GObjectClass parent_class;
};
  
GType pm_dlist_get_type (void);
  
#endif
```

完整的 pm-dlist.c 文件，内容如下：

``` c
#include "pm-dlist.h"
 
G_DEFINE_TYPE (PMDList, pm_dlist, G_TYPE_OBJECT);
#define PM_DLIST_GET_PRIVATE(obj) (\
        G_TYPE_INSTANCE_GET_PRIVATE ((obj), PM_TYPE_DLIST, PMDListPrivate))
 
typedef struct _PMDListNode PMDListNode;
struct  _PMDListNode {
        PMDListNode *prev;
        PMDListNode *next;
        void *data;
};
 
typedef struct _PMDListPrivate PMDListPrivate;
struct  _PMDListPrivate {
        PMDListNode *head;
        PMDListNode *tail;
};
 
static void
pm_dlist_class_init (PMDListClass *klass)
{
        g_type_class_add_private (klass, sizeof (PMDListPrivate));
}
 
static void
pm_dlist_init (PMDList *self)
{
        PMDListPrivate *priv = PM_DLIST_GET_PRIVATE (self);
         
        priv->head = NULL;
        priv->tail = NULL;
}
```

测试源代码文件 main.c 内容如下：

``` c
#include "pm-dlist.h"
  
int
main (void)
{
        /* GObject 库的类型管理系统的初始化 */
        g_type_init ();
     
        PMDList *list;
 
        list = g_object_new (PM_TYPE_DLIST, NULL);
        g_object_unref (list);
          
        return 0;
}
```

<b>总结</b>

从上述各源文件来看，经过数据隐藏处理之后，pm-dlist.h 被简化，pm-dlist.c 变得更复杂。

事实上，PMDList 类实现完毕后，第三方（即类的使用者）如果要使用这个类，那么他面对的只是 pm-dlist.h 文件，因此一个简洁的 pm-dlist.h 是他最希望看到的。

pm-dlist.c 变得更加复杂，但是这并不是坏事情。因为我们已经尽力将细节隐藏在类的实现部分，而且这部分代码通常也是第三方并不关注的。

这就是数据隐藏的意义。

原文出处：http://garfileo.is-programmer.com
