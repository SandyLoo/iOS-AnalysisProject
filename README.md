#前言
> 当前互联网行业的竞争已经是非常激烈了， “功能驱动”的时代已经过去了， 现在更加注重软件的细节， 以及用户的体验问题。 说到用户体验，就不得不提到用户的操作行为。 在我们的软件中，我们会到处进行埋点， 以便提取到我们想要的数据，进而分析用户的行为习惯。 通过这些数据，我们也可以更好的分析出用户的操作趋势，从而在用户体验上把我们的app做的更好。

随着公司业务的发展，数据的重要性日益体现出来。 数据埋点的全面性和准确性尤为重要。 只有拿到精准并详细的数据， 后面的分析才有意义。 然后随着业务的不断变化， 埋点的动态性也越来越重要。为了解决这些问题， 很多公司都提出自己的解决方案， 各中解决方案中，大体分为以下三种：
1. **代码埋点**
由开发人员在触发事件的具体方法里，植入多行代码把需要上传的参数上报至服务端。

2. **可视化埋点**
根据标识来识别每一个事件， 针对指定的事件进行取参埋点。而事件的标识与参数信息都写在配置表中，通过动态下发配置表来实现埋点统计。

3. **无埋点**
无埋点并不是不需要埋点，更准确的说应该是“全埋”， 前端的任意一个事件都被绑定一个标识，所有的事件都别记录下来。 通过定期上传记录文件，配合文件解析，解析出来我们想要的数据， 并生成可视化报告供专业人员分析 ， 因此实现“无埋点”统计。

---
由于考虑到“无埋点”的方案成本较高，并且后期解析也比较复杂，加上view_path的不确定性（具体可以参考: [网易HubbleData无埋点SDK在iOS端的设计与实现](https://neyoufan.github.io/2017/04/19/ios/%E7%BD%91%E6%98%93HubbleData%E6%97%A0%E5%9F%8B%E7%82%B9SDK%E5%9C%A8iOS%E7%AB%AF%E7%9A%84%E8%AE%BE%E8%AE%A1%E4%B8%8E%E5%AE%9E%E7%8E%B0/)）。所以本文重点分享一个 **可视化埋点** 的简单实现方式。

#可视化埋点
首先，可视化埋点并非完全抛弃了代码埋点，而是在代码埋点的上层封装的一套逻辑来代替手工埋点，大体上架构如下图：
![image](http://upload-images.jianshu.io/upload_images/3104472-15d0364de7f22ecd?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

不过要实现可视化埋点也有很多问题需要解决，比如事件唯一标识的确定，业务参数的获取，有逻辑判断的埋点配置项信息等等。接下来我会重点围绕唯一标识以及业务参数获取这两个问题给出自己的一个解决方案。

##唯一标识问题
唯一标识的组成方式主要是又 **target + action** 来确定， 即任何一个事件都存在一个target与action。 在此引入AOP编程，AOP（Aspect-Oriented-Programming）即面向切面编程的思想，基于 Runtime 的 Method Swizzling能力，来 hook 相应的方法，从而在hook方法中进行统一的埋点处理。例如所有的按钮被点击时，都会触发UIApplication的sendAction方法，我们hook这个方法，即可拦截所有按钮的点击事件。
![image](http://upload-images.jianshu.io/upload_images/3104472-3b1942be410c1e02?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

这里主要分为两个部分 ： 
* 事件的锁定 
事件的锁定主要是靠 “事件唯一标识符”来锁定，而事件的唯一标识是由我们写入配置表中的。

* 埋点数据的上报。 
埋点数据的数据又分为两种类型： **固定数据**与**可变的业务数据**， 而固定数据我们可以直接写到配置表中， 通过唯一标识来获取。而对于业务数据，我是这么理解的： 数据是有持有者的， 例如我们Controller的一个属性值， 又或者数据再Model的某一个层级。 这么的话我们就可以通过KVC的的方式来递归获取该属性的值来取到业务数据， 代码后面会有介绍。

## 整体代码示例
由于iOS中的事件场景是多样的， 在此我以UIControl, UITablview(collectionView与tableView基本相同)， UITapGesture， UIViewController的PV统计 为例，介绍一下具体思路。

1. UIViewController PV统计
页面的统计较为简单，利用Method Swizzing hook 系统的viewDidLoad，  直接通过页面名称即可锁定页面的展示代码如下：
```
@implementation UIViewController (Analysis)

+(void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        SEL originalDidLoadSelector = @selector(viewDidLoad);
        SEL swizzingDidLoadSelector = @selector(user_viewDidLoad);
        [MethodSwizzingTool swizzingForClass:[self class] originalSel:originalDidLoadSelector swizzingSel:swizzingDidLoadSelector];
        
    });
}

-(void)user_viewDidLoad
{
    [self user_viewDidLoad];

   //从配置表中取参数的过程 1 固定参数  2 业务参数（此处参数被target持有）
    NSString * identifier = [NSString stringWithFormat:@"%@", [self class]];
    NSDictionary * dic = [[[DataContainer dataInstance].data objectForKey:@"PAGEPV"] objectForKey:identifier];
    if (dic) {
        NSString * pageid = dic[@"userDefined"][@"pageid"];
        NSString * pagename = dic[@"userDefined"][@"pagename"];
        NSDictionary * pagePara = dic[@"pagePara"];
        
        __block NSMutableDictionary * uploadDic = [NSMutableDictionary dictionaryWithCapacity:0];
        [pagePara enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            
            id value = [CaptureTool captureVarforInstance:self withPara:obj];
            if (value && key) {
                [uploadDic setObject:value forKey:key];
            }
        }];
        
        NSLog(@"\n 事件唯一标识为：%@ \n  pageid === %@,\n  pagename === %@,\n pagepara === %@ \n", [self class], pageid, pagename, uploadDic);
    }
}
```


2. UIControl 点击统计。
主要通过hook  **sendAction:to:forEvent:** 来实现, 其唯一标识符我们用 targetname/selector/tag来标记，具体代码如下：
~~~
@implementation UIControl (Analysis)

+(void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL originalSelector = @selector(sendAction:to:forEvent:);
        SEL swizzingSelector = @selector(user_sendAction:to:forEvent:);
        [MethodSwizzingTool swizzingForClass:[self class] originalSel:originalSelector swizzingSel:swizzingSelector];
    });
}


-(void)user_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
{
    [self user_sendAction:action to:target forEvent:event];
    
    NSString * identifier = [NSString stringWithFormat:@"%@/%@/%ld", [target class], NSStringFromSelector(action),self.tag];
    NSDictionary * dic = [[[DataContainer dataInstance].data objectForKey:@"ACTION"] objectForKey:identifier];
    if (dic) {
        
        NSString * eventid = dic[@"userDefined"][@"eventid"];
        NSString * targetname = dic[@"userDefined"][@"target"];
        NSString * pageid = dic[@"userDefined"][@"pageid"];
        NSString * pagename = dic[@"userDefined"][@"pagename"];
        NSDictionary * pagePara = dic[@"pagePara"];
        __block NSMutableDictionary * uploadDic = [NSMutableDictionary dictionaryWithCapacity:0];
        [pagePara enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            
            id value = [CaptureTool captureVarforInstance:target withPara:obj];
            if (value && key) {
                [uploadDic setObject:value forKey:key];
            }
        }];
        
        
        NSLog(@" \n  唯一标识符为 : %@, \n event id === %@,\n  target === %@, \n  pageid === %@,\n  pagename === %@,\n pagepara === %@ \n", identifier, eventid, targetname, pageid, pagename, uploadDic);
    }
}
~~~

3. TableView (CollectionView) 的点击统计。
tablview的唯一标识， 我们使用 delegate.class/tableview.class/tableview.tag的组合来唯一锁定。 主要是通过hook **setDelegate** 方法， 在设置代理的时候再去交互 **didSelect** 方法来实现，  具体的原理是 具体代码如下：

~~~
@implementation UITableView (Analysis)

+(void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        SEL originalAppearSelector = @selector(setDelegate:);
        SEL swizzingAppearSelector = @selector(user_setDelegate:);
        [MethodSwizzingTool swizzingForClass:[self class] originalSel:originalAppearSelector swizzingSel:swizzingAppearSelector];
    });
}



-(void)user_setDelegate:(id<UITableViewDelegate>)delegate
{
    [self user_setDelegate:delegate];
    
    SEL sel = @selector(tableView:didSelectRowAtIndexPath:);

    SEL sel_ =  NSSelectorFromString([NSString stringWithFormat:@"%@/%@/%ld", NSStringFromClass([delegate class]), NSStringFromClass([self class]),self.tag]);
    
    
    //因为 tableView:didSelectRowAtIndexPath:方法是optional的，所以没有实现的时候直接return
    if (![self isContainSel:sel inClass:[delegate class]]) {
        
        return;
    }
    
    
    BOOL addsuccess = class_addMethod([delegate class],
                                      sel_,
                                      method_getImplementation(class_getInstanceMethod([self class], @selector(user_tableView:didSelectRowAtIndexPath:))),
                                      nil);
    
    //如果添加成功了就直接交换实现， 如果没有添加成功，说明之前已经添加过并交换过实现了
    if (addsuccess) {
        Method selMethod = class_getInstanceMethod([delegate class], sel);
        Method sel_Method = class_getInstanceMethod([delegate class], sel_);
        method_exchangeImplementations(selMethod, sel_Method);
    }
}


//判断页面是否实现了某个sel
- (BOOL)isContainSel:(SEL)sel inClass:(Class)class {
    unsigned int count;
    
    Method *methodList = class_copyMethodList(class,&count);
    for (int i = 0; i < count; i++) {
        Method method = methodList[i];
        NSString *tempMethodString = [NSString stringWithUTF8String:sel_getName(method_getName(method))];
        if ([tempMethodString isEqualToString:NSStringFromSelector(sel)]) {
            return YES;
        }
    }
    return NO;
}


// 由于我们交换了方法， 所以在tableview的 didselected 被调用的时候， 实质调用的是以下方法：
-(void)user_tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    SEL sel = NSSelectorFromString([NSString stringWithFormat:@"%@/%@/%ld", NSStringFromClass([self class]),  NSStringFromClass([tableView class]), tableView.tag]);
    if ([self respondsToSelector:sel]) {
        IMP imp = [self methodForSelector:sel];
        void (*func)(id, SEL,id,id) = (void *)imp;
        func(self, sel,tableView,indexPath);
    }
    
    
    NSString * identifier = [NSString stringWithFormat:@"%@/%@/%ld", [self class],[tableView class], tableView.tag];
    NSDictionary * dic = [[[DataContainer dataInstance].data objectForKey:@"TABLEVIEW"] objectForKey:identifier];
    if (dic) {
        
        NSString * eventid = dic[@"userDefined"][@"eventid"];
        NSString * targetname = dic[@"userDefined"][@"target"];
        NSString * pageid = dic[@"userDefined"][@"pageid"];
        NSString * pagename = dic[@"userDefined"][@"pagename"];
        NSDictionary * pagePara = dic[@"pagePara"];
        
        
        
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
        __block NSMutableDictionary * uploadDic = [NSMutableDictionary dictionaryWithCapacity:0];
        [pagePara enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSInteger containIn = [obj[@"containIn"] integerValue];
            id instance = containIn == 0 ? self : cell;
            id value = [CaptureTool captureVarforInstance:instance withPara:obj];
            if (value && key) {
                [uploadDic setObject:value forKey:key];
            }
        }];
        
        NSLog(@"\n event id === %@,\n  target === %@, \n  pageid === %@,\n  pagename === %@,\n pagepara === %@ \n", eventid, targetname, pageid, pagename, uploadDic);
    }
    
}

@end

~~~


4. gesture方式添加的的点击统计。
gesture的事件，是通过 hook **initWithTarget:action:**方法来实现的， 事件的唯一标识依然是target.class/actionname来锁定的， 代码如下：
~~~

@implementation UIGestureRecognizer (Analysis)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [MethodSwizzingTool swizzingForClass:[self class] originalSel:@selector(initWithTarget:action:) swizzingSel:@selector(vi_initWithTarget:action:)];
    });
}

- (instancetype)vi_initWithTarget:(nullable id)target action:(nullable SEL)action
{
    UIGestureRecognizer *selfGestureRecognizer = [self vi_initWithTarget:target action:action];
    
    if (!target || !action) {
        return selfGestureRecognizer;
    }
    
    if ([target isKindOfClass:[UIScrollView class]]) {
        return selfGestureRecognizer;
    }
    
    Class class = [target class];
    
    
    SEL originalSEL = action;
    
    NSString * sel_name = [NSString stringWithFormat:@"%s/%@", class_getName([target class]),NSStringFromSelector(action)];
    SEL swizzledSEL =  NSSelectorFromString(sel_name);
    
    //给原对象添加一共名字为 “sel_name”的方法，并将方法的实现指向本类中的 responseUser_gesture：方法的实现
    BOOL isAddMethod = class_addMethod(class,
                                       swizzledSEL,
                                       method_getImplementation(class_getInstanceMethod([self class], @selector(responseUser_gesture:))),
                                       nil);
    
    if (isAddMethod) {
        [MethodSwizzingTool swizzingForClass:class originalSel:originalSEL swizzingSel:swizzledSEL];
    }
    
    //将gesture的对应的sel存储到 methodName属性中，主要是方便 responseUser_gesture： 方法中取出来
    self.methodName = NSStringFromSelector(action);
    return selfGestureRecognizer;
}


-(void)responseUser_gesture:(UIGestureRecognizer *)gesture
{
    
    NSString * identifier = [NSString stringWithFormat:@"%s/%@", class_getName([self class]),gesture.methodName];
    
    //调用原方法
    SEL sel = NSSelectorFromString(identifier);
    if ([self respondsToSelector:sel]) {
        IMP imp = [self methodForSelector:sel];
        void (*func)(id, SEL,id) = (void *)imp;
        func(self, sel,gesture);
    }
    
    //处理业务，上报埋点
    NSDictionary * dic = [[[DataContainer dataInstance].data objectForKey:@"GESTURE"] objectForKey:identifier];
    if (dic) {
        
        NSString * eventid = dic[@"userDefined"][@"eventid"];
        NSString * targetname = dic[@"userDefined"][@"target"];
        NSString * pageid = dic[@"userDefined"][@"pageid"];
        NSString * pagename = dic[@"userDefined"][@"pagename"];
        NSDictionary * pagePara = dic[@"pagePara"];
        
        __block NSMutableDictionary * uploadDic = [NSMutableDictionary dictionaryWithCapacity:0];
        [pagePara enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            id value = [CaptureTool captureVarforInstance:self withPara:obj];
            if (value && key) {
                [uploadDic setObject:value forKey:key];
            }
        }];
        
        NSLog(@"\n event id === %@,\n  target === %@, \n  pageid === %@,\n  pagename === %@,\n pagepara === %@ \n", eventid, targetname, pageid, pagename, uploadDic);
        
    }
}


~~~

## 配置表结构
首先那， 配置表是一个json数据。 针对不同的场景 （UIControl , 页面PV， Tabeview, Gesture）都做了区分， 用不同的key区别。 对于 "固定参数" ， 我们之间写到配置表中，而对于业务参数， 我们之间写清楚参数在业务内的名字， 以及上传时的 keyName， 参数的持有者。 通过Runtime + KVC来取值。  配置表可以是这个样子：（仅供参考）

> 说明：  json最外层有四个Key, 分别为 ACTION  PAGEPV  TABLEVIEW  GESTURE, 分别对应 UIControl的点击， 页面PV， tableview cell点击， Gesture 单击事件的参数。 每个key对应的value为json格式，Json中的keys， 即为唯一标识符。  标识符下的json有两个key ：  userDefine指的 固定数据， 即直接取值进行上报。 而pagePara为业务参数。 pagePara对应的value也是一个json，  json的keys， 即上报的keys， value内的json包含三个参数： propertyName 为属性名字， containIn 参数只有0 ，1 两种情况， 其实这个参数主要是为tabview cell的点击取参做区别的，因为点击cell的时候， 上报的参数可能是被target持有，又或者是被cell本身持有 。 当containIn = 0的时候， 取参数时就从target中取值，= 1的时候就从cell中取值。 propertyPath 是一般备选项， 因为有时候从instace内递归取值的时候，可能会出现在不同的层级有相同的属性名字， 此时 propertyPath就派上用处了。 例如有属性 self.age 和 self.person.age ， 其实如果需要self.person.age， 就把 propertyPath的值设为 person/age， 接着在取值的时候就会按照指定路径进行取值。
~~~
{
    "ACTION": {
        "ViewController/jumpSecond": {
            "userDefined": {
                "eventid": "201803074|93",
                "target": "",
                "pageid": "234",
                "pagename": "button点击，跳转至下一个页面"
            },
            "pagePara": {
                "testKey9": {
                    "propertyName": "testPara",
                    "propertyPath":"",
                    "containIn": "0"
                }
            }
        }
    },
    
    "PAGEPV": {
        "ViewController": {
            "userDefined": {
                "pageid": "234",
                "pagename": "XXX 页面展示了"
            },
            "pagePara": {
                "testKey10": {
                    "propertyName": "testPara",
                    "propertyPath":"",
                    "containIn": "0"
                }
            }
        }
    },
    "TABLEVIEW": {
        "ViewController/UITableView/0":{
            "userDefined": {
                "eventid": "201803074|93",
                "target": "",
                "pageid": "234",
                "pagename": "tableview 被点击"
            },
            "pagePara": {
                "user_grade": {
                    "propertyName": "grade",
                    "propertyPath":"",
                    "containIn": "1"
                }
            }
        }
    },
    
    "GESTURE": {
        "ViewController/controllerclicked:":{
            "userDefined": {
                "eventid": "201803074|93",
                "target": "",
                "pageid": "123",
                "pagename": "手势响应"
            },
            "pagePara": {
                "testKey1": {
                    "propertyName": "testPara",
                    "propertyPath":"",
                    "containIn": "0"
                }
            }
        }
    }
}

~~~

## 取参方法
~~~
@implementation CaptureTool

+(id)captureVarforInstance:(id)instance varName:(NSString *)varName
{
    id value = [instance valueForKey:varName];

    unsigned int count;
    objc_property_t *properties = class_copyPropertyList([instance class], &count);
    
    if (!value) {
        NSMutableArray * varNameArray = [NSMutableArray arrayWithCapacity:0];
        for (int i = 0; i < count; i++) {
            objc_property_t property = properties[i];
            NSString* propertyAttributes = [NSString stringWithUTF8String:property_getAttributes(property)];
            NSArray* splitPropertyAttributes = [propertyAttributes componentsSeparatedByString:@"\""];
            if (splitPropertyAttributes.count < 2) {
                continue;
            }
            NSString * className = [splitPropertyAttributes objectAtIndex:1];
            Class cls = NSClassFromString(className);
            NSBundle *bundle2 = [NSBundle bundleForClass:cls];
            if (bundle2 == [NSBundle mainBundle]) {
//                NSLog(@"自定义的类----- %@", className);
                const char * name = property_getName(property);
                NSString * varname = [[NSString alloc] initWithCString:name encoding:NSUTF8StringEncoding];
                [varNameArray addObject:varname];
            } else {
//                NSLog(@"系统的类");
            }
        }
        
        for (NSString * name in varNameArray) {
            id newValue = [instance valueForKey:name];
            if (newValue) {
                value = [newValue valueForKey:varName];
                if (value) {
                    return value;
                }else{
                    value = [[self class] captureVarforInstance:newValue varName:varName];
                }
            }
        }
    }
    return value;
}


+(id)captureVarforInstance:(id)instance withPara:(NSDictionary *)para
{
    NSString * properyName = para[@"propertyName"];
    NSString * propertyPath = para[@"propertyPath"];
    if (propertyPath.length > 0) {
        NSArray * keysArray = [propertyPath componentsSeparatedByString:@"/"];
     
        return [[self class] captureVarforInstance:instance withKeys:keysArray];
    }
    return [[self class] captureVarforInstance:instance varName:properyName];
}

+(id)captureVarforInstance:(id)instance withKeys:(NSArray *)keyArray
{
    id result = [instance valueForKey:keyArray[0]];
    
    if (keyArray.count > 1 && result) {
        int i = 1;
        while (i < keyArray.count && result) {
            result = [result valueForKey:keyArray[i]];
            i++;
        }
    }
    return result;
}
@end

~~~

---
# 结尾
>以上是自己的一些想法与实践， 感觉目前的无痕埋点方案都还是不是很成熟， 不同的公司会有不同的方案， 但是可能大部分还是用的代码埋点的方式。 代码埋点的侵入性，维护性成本比较大， 尤其是当埋点特别多的时候， 有时候自己几个月前写的埋点代码，突然需要改，自己都要找半天才能找到。  并且代码埋点很致命的一个问题是无法动态更新， 即每次修改埋点，必须重新上线， 有时候上线后产品经理突然跑过来问：为什么埋点数据不太正常那， 此时你突然发现有一句埋点代码写错了， 这个时候你要么承认错误，承诺下次加上。要么赶快紧急上线解决。 通过以上方式，可以实现埋点的动态追加。 配置表可以通过服务端下载， 每次下载后就存在本地， 如果配置表有更新，只需要重新更新配置表就可以解决 。   方案中可能很多细节还需要完善，例如selector方法中存在业务逻辑判断，即一个标识符无法唯一的锁定一个埋点。 这种情况目前用配置表解决的成本较大， 并且业务是灵活的不好控制。 所以以上方案也只是涵盖了大部分场景， 并非所有场景都适用，具体大家可以根据业务情况来决定使用范围。
