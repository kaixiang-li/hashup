---
title: antlr v4 notes
tags: [parsing, notes]
date: 2013-05-02 20:53:58 +0800
---

h1#basic 入门知识
h2#intro 介绍

h5#basic-commands 基本命令
- antlr4用来通过g4生成lexer/parser
- grun用来测试
1. -tokens
2. -tree: lisp form
3. -gui
4. -ps file.ps: 生成postscript
5. -encoding encodingname:
6. -trace: 指出rule名和当前的token
7. -diagnostics: 开启诊断信息, 解决多义性..
8. -sll: 更快但更弱的解析策略


h2#picture 背景知识

h5#picture-intro 介绍
知道语言应用所需的重要过程，术语还有相关的数据结构

h5#meta-language meta-language
- 语言是一系列有效的句子，句子由短语组成， 短语由词汇组成
- 运算并执行语句的叫解释器
- 识别语言的叫解析器或语法分析器: lexer/parser
- 一个语法就是一系列规则， 每个规则表达一个短语的结构

- 传统的解析器允许在语法中嵌入代码action

h5#parser-implementation parser的实现
- 从语法规则生成一个递归下降解析
递归下降解析器就是一条规则对应一个递归方法,  match用来处理叶子节点
下降指的是解析从解析树的根(开始符号)开始, 一直沿着叶子而去
- 加入新规则，只需要加一个新方法，和给match加一个新叶子节点的处理操作
- 更一般的说法是，这类解析是top-down解析, 递归下降解析是一种自顶向下解析的实现..


h5#picture-ambious 语言的二义性
- antlr优先选择第一条，消除二义

h5#syntax-tree 使用语法树构建语言应用
- CharStream, Lexer, Token, Parser, ParseTree
- ParseTree有子类RuleNode,TerminalNode
- StatContext, AssignContext, ExprContext


h2#starter 起步应用
h5#generated 生成的文件
1. ArrayInitParser.java
包含每条规则所对应的方法...
2. ArrayInitLexer.java
ANTLR从我们定义的语法文件中自动抽出单独的解析器和词法说明..
3. ArrayInit.tokens
给每一个词法单元赋一个值...当把一个大语法分成几个小语法文件的时候很有用..
4. ArrayInitListener.java, ArrayInitBaseListener.java
定义了一些我们可以实现的回调接口

这里不使用正则，是因为正则不能识别嵌套的初始化, 
而且正则无法记住之前匹配的部分, 所以不知道如何匹配一对括号

starter/Test.java 里面有一些antlr运行时常用的类


h5#recognize 识别之后，建立语言应用
- 一个语言应用必须从解析树抽出数据, 可以通过parse-tree walker来触发一系列回调
比较接近GUI挂件的回调...或者XML解析器的SAX事件..

- 翻译意味着我们需要知道如何把每个输入字符串转换为输出字符串
这里把{99, 3, 451}翻译成"\u0063\u0003\u01c3"

对应一系列的"X goes to Y"的规则


h2#tour 功能特性
h5#match 匹配算术表达式语言
- 规则是小写字母开头
- 词法单元是大写字母开头
- ANTLR可以处理左递归
- 可以建立一个t.expr文件用来测试解析
- 可以把词法语法文件分离出来lexer grammar

h5#tour-visitor 通过一个vistor构建一个计算器(求值)
- 需要给不同的alternatives加上label
如果没有lable，每条规则只会有一个visitor方法
- label用#开头，加上不同的label，这样就可以处理不同种类的输入了
- 会为每一个有label的选项生成一个visitor的接口方法 还生成一个默认实现文件用来继承, 我们只需要重载就可以
- 基于label的不同情况
- visit方法

h5#tour-listener 通过一个listener构建一个翻译器(翻译)
- 比如解决一个从过java类定义的文件生成一个java接口文件
- listener是基于事件的
- listener方法是被antlr提供的walker对象调用的，然而vistor方法必须遍历子代然后显式调用, 忘记在一个节点调用visit的话意味着那些子树不会被访问到
- enter/exit方法

h5#tour-parser 在parse过程就把事情搞定
- 可以在此做语义推断, 一种特殊的行为: semantic predicates
- 这些代码会直接复制到生成的递归下降解析器中去, 这样也就不用构建解析树了

h5#tour-lex 很酷的词法特性
- XML内部和外部有着不一样的词法结构
1. island grammar: 必须区别对待
2. lexical modes可以用来处理混合语法的情况, 通过特殊字符切换模式
比如看到`<`就切换到内部模式,看到`>或/>`就切回去

- 如何在java类中插入一个域，通过改变input stream
- 如何做最小的变化，对源文件做改变
1. TokenStreamRewriter
- 如何在不抛弃注释和空白的情况下忽略它们
1. 把tokens发往不同的频道`-> channel(HIDDEN)`


h1#more 语法识别与解析
h2#design 语法设计
h5#more-intro 介绍
- 学习构建内部数据结构，抽出信息，生成输入的翻译

h5#more-design-pattern 语言模式
- 语言模式是一个递归的语法结构，比如主谓宾 
- 我们需要学习语言模式，并识别出他们，提炼出语言的结构，然后用antlr语言表达它
- 语言们总是趋向于相似，因为设计者总是追寻一些数学里面的常用记法
- 即便是词法级别，语言也总是喜欢复用同样的结构,比如标识符，整数，字符串等等...

- 根据自然语言的词序还有依赖关系的约束，有四类抽象计算机语言模式
1. sequence: 元素序列，比如数组
2. choice: 多个，可以选的短语...  类似语言中不同种类的语句
3. token dependence: 比如括号配对
4. nested phrase: 比如嵌套的算术表达式

- 实现这些模式需要alternatives, token references, rule references(BNF)
我们可以使用`?*+`来循环识别一些结构(EBNF)

h5#language-sample 从语言样本推导语法
- 写语法就像写软件， 除了我们是处理规则，而不是函数或者过程(antlr为我们的规则生成了函数)
- 写语法常常需要对语法的熟悉和输入样本的表示，手册更好，甚至别的格式的parser generator..

- 合适的语法设计反映的是功能的分解或者自顶向下的设计
首先找出最泛化的语言结构(start rule)
比如英语的sentence, xml的document, java的compilationUnit

然后顺着start rule逐步分解右手边的式子
右手边的名词通常是tokens或者将要被定义的规则
tokens是我们通常认为是字，标点符号或者操作符一类的东西(tokens are atoms in a parser generator)

当我们没有规则可以定义的时候，我们就大致有了一个语法草稿了

- 从最高层次一直往下..

h5#language-grammar 使用已经存在的语法推导语法
- 盲目的参考已经存在的语法，也有可能会误导
把它当参考，而不是当代码
- 参考手册因为要解释语法，所以会比较松散, 有时候又限制的太过
- XML不过是一系列内嵌文本的标签，所以语法结构其实很直接..唯一的难点就是内部和外部的语法处理方案不一致


h5#antlr-pattern 用ANTLR语法识别常见语言模式(4种)
- 首先是自顶向下的解析策略
- 需要关注sequence, choice, token dependence, nested phrase这四种基本模式

h6#sequence Sequence
- 计算机中最常见的数据结构就是一序列元素，比如类里的一序列的方法, 协议里的一序列命令
我们可以定义一个序列的词法单元 + *
- sequence, sequence with terminator, sequence with separator

h6#choice choice(alternatives)
- 语法总是充满选择

h6#token-dependency token dependency
- 注意括号的配对

h6#nested nested phrase
- 处理一种自相似关系
- 分直接递归，和不直接递归


h5#more-details 处理优先级，左递归，关联性
- 表达式经常会出现多义性，经常会出现左递归...
- 传统的语法工具通常需要特别指定优先级, antlr采用优先匹配的方法, 隐式的允许我们指定优先级
- 指定关联`expr : expr '^'<assoc=right> expr`
- antlr4可以直接处理直接的左递归，但是不能处理间接的左递归

- 有经验的编译器writers经常手写压榨性能而不喜欢写长串的规则，然后他们经常使用operator precedence parsers
- antlr用一个可以推断的比较优先级的方法来取代左递归..(通过语法变换)

h5#common-structure 识别常用词法结构
- 编程语言在词法上十分相似: 无论是函数式的，过程式的，声明式的还是面向对象语言都看起来极为相似..
- 词法解析处理的是character stream, 语法解析的是token stream...
- 当开始一个新语法的时候, 通常cp一些常用词法结构: identifiers, numbers, strings, comments, whitespace

- 关键字不需要词法单元，或者还是用一个词法规则来引用, 需要在所有的词法单元规则之前指定
- fragment说明一个规则只是用来引用的，而不是一条单独的词法规则

- 字符串词法单元需要考虑一些escape的情况..因为.里面并不包括，所以要加上这一些escape的选择

- 注释和空白一开始就应该skip掉，以免之后还要考虑，很麻烦

- 一般编程语言把空白作为词法单元分隔符，其他的则忽略，而python却使用空白有特别的语法含义, 用来确定嵌套的层级
换行既可以作为被忽略的whitespace也可以作为命令终止符的时候，newline就成为了case-sensitive了(后面会讲..)

- 78页有词法单元的参考手册!!!

h5#lex-parser 分清lexer和parser的界限
- antlr的词法规则可以使用递归，所以功能和parser一样强大
- 如果有需要忽略的结果就放到lexer
- 常见的结构就放到lexer
- 如果可以并在一起就放到一个lexer rule里面
- 控制好lexer rule的粒度
- 如果有需要做更细致的处理，就放到parser里面

h2#real-world 真实案例
h5#csv CSV
- 特殊对待header，加一个特别规则

h5#json JSON
- 嵌套结构,可以尝试递归规则
- json可以是一个对象，也可以是一个值的数组 `->` choice
- 对象是没有顺序的键值对。一个对象以左括号开始，每个名字后跟一个:,键值对用，分隔
没有排序属于语义范畴的, 或者说是名字的意义
- 不能使用循环语法指定结构的时候通常使用尾递归
- 数组是一个有序的值，[开头， 值通过，分隔
- 字符串是unicode字符的集合， 双引号包住，用\做转义| 除了\\和"

h5#dot DOT
- 声明式, 用来描述图。可以尝试更复杂的词法结构

h5#cymbol Cymbol
- 命令式非面向对象语言, 有函数，变量，语句和表达式

h5#r R
- 函数式，表达式很复杂

h2#decouple 解藕
h5#decouple-intro 介绍
- 为了构建语言应用，我们必须让解析器在看到特定的输入的时候触发特定的动作
- `phrase->action`对的集合构成了我们的语言应用..或者说是在语法和一个应用间的最小接口..
- 我们需要使用parse-tree listener或者visitors来构建语言应用
- listener是一个对象，可以对规则做反应，enterRule, exitRule
- 为了对遍历有更精细的控制可以使用vistors, 必须显式的触发visit函数，使遍历继续下去
- event method指的是listener callback或者vistor method
- 我们要理解tree-walker facilities给我们带来了什么

h5#decouple-listeners 把内嵌的actions展开为listeners
- 不再内嵌代码
- @members定义一些可以用来被重载的方法, 实例化parser的时候就使用那个子类, 但这样仍然有一些内嵌的耦合

h5#parse-tree-listeners 使用parse-tree listeners
- xxContext对象(rule context对象)是parse-tree节点指定的一些方法的实现，有很多有用的方法，作为listener方法的参数
1. token名都是得到token引用的方法
2. getText()/getSymbol()

- 这里是继承BaseListener而不是parser, BaseListener有xxFileListener和antlr库的ParseTreeListener的方法, 供parsetreewaker调用
- 是`Antlr library<=>generated files <=> Application code`的三者关系

h5#decouple-visitors 使用visitors
- 用-visitor选项生成visitor接口
- 生成的加base的类就是用来继承的
- 与创建一个walker不同，直接创建一个visitor来visit(tree)

h5#decouple-events label给listener添加合适的事件方法
- 给listener/visitor生成的事件加大粒度
- 不用label可以用getChildCount得到个数，getType得到类型
- 对应每个label生成一个Context

h5#decouple-infos 在事件方法中分享信息
1. 使用vistor方法的返回值
2. 定义一个field,在事件方法中共享,用一个栈来存储
3. 给parse tree的结点加注释






























