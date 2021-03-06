---
layout: post
title: "[转载]GObject 学习笔记：GObject 的子类继承"
date: 2012-05-30 04:10:35 +0000
comments: true
post_id: 83776
permalink: /archives/83776.html
categories: ["编程开发"]
tags: ["GObject"]
---

在文档 [1] 中，我们构造了一个 KbBibtex 类，其构造过程看似挺复杂，但实际上只需要动手尝试一下，即可明白 GObject 子类化的各项步骤的意义与作用。许多事物之所以被认为复杂，是因为大家在观望。

本文沿用文档 [1] 中的那个 KbBibtex 示例，学习如何对其进行子类化，构造新类，即面向对象程序设计方法中类的继承。

<b>文献有很多种类</b>

写过论文的人都知道，参考文献的形式有许多种类，例如期刊论文、技术报告、专著等，并非所有的文献格式都能表示文档 [1] 所给出的 KbBibtex 对象属性，即：

``` c
typedef struct _KbBibtexPrivate KbBibtexPrivate;
struct _KbBibtexPrivate {
        GString *title;
        GString *author;
        GString *publisher;
        guint   year;
};
```

对于期刊论文而言，也许我们期望的数据结构是：

``` c
typedef struct _KbBibtexPrivate KbBibtexPrivate;
struct _KbBibtexPrivate {
        GString *title;
        GString *author;
        GString *journal;
        GString *volume;
        GString *number;
        GString *pages;
        guint   year;
        GString *publisher;
};
```

对于技术报告，需求又要变成：

``` c
typedef struct _KbBibtexPrivate KbBibtexPrivate;
struct _KbBibtexPrivate {
        GString *title;
        GString *author;
        GString *institution;
        guint   year;
};
```

这样的变化非常之多。因此，设计一个“万能”的 KbBibtex 类，使之可以表示任何文献类型，看上去会很美好。

<b>类的继承</b>

因为期刊论文这种对象只比文档 [1] 中的 KbBibtex 对象多出 4 个属性，即 journal、volume、number、pages，其他属性皆与 KbBibtex 对象相同。

在程序猿的职业生涯中也许不断听到这样的警告：Don't Repeat Yourself（不要重复）！所以面向对象程序设计方法会告诉我们，既然 KbBibtex 对象已经拥有了一部分期刊论文对象所需要的属性，后者与前者都属于 KbBibtex 类（因为它们都是文献类型），那么只需设计一个期刊论文类，让它可以继承 KbBibtex 类的所以所拥有的一切，那么就可以不用 DRY 了。

那么怎么来实现？和 GObject 子类化过程相似，只需建立一个 kb-article.h 头文件，与继承相关的代码如下：

``` c
#include "kb-bibtex.h"
 
typedef struct _KbArticle KbArticle;
struct _KbArticle {
        KbBibtex parent;
};
 
typedef struct _KbArticleClass KbArticleClass;
struct _KbArticleClass {
        KbBibtexClass parent_class;
};
```

然后，再建立一个 kb-article.c 源文件，其中与继承相关的代码如下：

``` c
G_DEFINE_TYPE (KbArticle, kb_article, KB_TYPE_BIBTEX);
```

另外，KbBibtex 对象的 kb_bibtex_printf 方法也需要被 KbArticle 对象继承，这只需在 kb_article_printf 函数中调用 kb_bibtex_printf 即可实现，例如：

``` c
void
kb_article_printf (KbArticle *self)
{
        kb_bibtex_printf (&self->parent);
 
        /* 剩下代码是 KbArticle 对象的 kb_article_printf 方法的具体实现 */
        ... ...
}
```

当然，kb-article.h 和 kb-article.c 中剩余代码需要类似文档 [1] 中实现 KbBibtex 类那样去实现 KbArticle 类。这部分代码，我希望你能动手去尝试一下。下面，我仅给出测试 KbArticle 类的 main.c 源文件内容：

``` c
#include "kb-article.h"
 
int
main (void)
{
        g_type_init ();
         
        KbArticle *entry = g_object_new (KB_TYPE_ARTICLE,
                                         "title", "Breaking paragraphs into lines",
                                         "author", "Knuth, D.E. and Plass, M.F.",
                                         "publisher", "Wiley Online Library",
                                         "journal", "Software: Practice and Experience",
                                         "volume", "11",
                                         "number", "11",
                                         "year", 1981,
                                         "pages", "1119-1184",
                                         NULL);
        kb_article_printf (entry);
 
        g_object_unref (entry);
        return 0;
}
```

测试结果表明，一切尽在掌握之中：  
```
$ ./test
    Title: Breaking paragraphs into lines
   Author: Knuth, D.E. and Plass, M.F.
Publisher: Wiley Online Library
     Year: 1981
  Journal: Software: Practice and Experience
   Volume: 11
   Number: 11
    Pages: 1119-1184
```

<b>继承真的很美好？</b>

通过类的继承来实现一部分的代码复用真的是很惬意。但是，《C 专家编程》一书的作者却不这么认为，为了说明类的继承通常很难解决现实问题，他运用了一个比喻，将程序比作一本书，并将程序库比作一个图书馆。当你基于一个程序库去写你个人的程序之时，好比你在利用图书馆中的藏书去写你个人的书，显然你不可能很轻松的在那些藏书中复印一部分拼凑出一本书。

就本文开头所举的例子而言，就无法通过继承文档 [1] 所设计的 KbBibtex 类来建立技术报告类，因为技术报告对象是没有 publisher 属性的。

也许你会说，那是 KbBibtex 类设计的太烂了。嗯，我承认这一点，但是你不可能要求别人在设计程序库时候知道你想要什么，就像你不能去抱怨为什么图书馆里的藏书怎么不是为你写书而准备的一样。

基类设计的失误，对于它的所有子类是一场巨大的灾难。要避免这种灾难，还是认真考虑自己所要解决的问题吧。其实很多问题都可以不需要使用继承便可以很好的解决，还有许多问题不需要继承很多的层次也可以很好的解决。

对于本文的问题，不采用继承的实现会更好。比如我们可以这样来改造 KbBibtex 类：

    将 Bibtex 文献所有格式的属性都设为 KbBibtex 的类属性
    为 Bibtex 对象拥有一个链表或数组之类的线性表容器，或者效率更高的 Hash 表容器（GLib 库均已提供），容器的第一个单元存储 Bibtex 对象对应的文献类型，其他单元则存储文献的属性。
    在 kb_bibtex_set_property 与 kb_bibtex_get_property 函数中，实现 Bibtex 类属性与 Bibtex 对象属性的数据交换。

仅此而已。

如果说继承是美好的，那么平坦一些会更美好。如果你不愿意选择平坦，那么可以选择接口（Interface），这是下一篇文档的主题。

~ End ~


原文出处：http://garfileo.is-programmer.com
