##自定义容器控制器
自定义容器控制器大致分为两部分：添加和移除子控制器；动画切换子控制器。  
</br>
####1，添加和移除子的控制器
添加子控制器时需要保持ViewController的层次结构和View的层次结构相同。</br>
添加子控制器以及AppearanceCallBack的调用顺序：</br>
1）User   - 手动调用container的self.addChildViewController(childController) </br>
2）System - 系统调用子控制器的willMoveToParentViewController:</br>
3）User   - 手动调用container的addSubview(childController.rootView)</br>
4）System - 系统调用子控制器的viewWillAppear</br>
5）User   - 手动调用子视图的didMoveToParentViewController</br>
6）System - 系统调用子控制器的viewDidAppear。</br>
  注意：该方法会等didMoveToParentViewController所在的方法执行完成后才会被系统执行。</br>
     </br>
移除子控制器以及AppearanceCallBack的调用顺序：</br>
1）User   - 手动调用子控制器的willMoveToParentViewController(nil)，此处参数必须是nil</br>
2）User   - 手动调用子控制的view.removeFromSuperview()，移除子控制器的视图</br>
3）System - 系统调用子控制器的viewWillDisappear</br>
4）User   - 手动调用子控制器的removeFromParentViewController</br>
5）System - 系统调用子控制器的viewDidDisappear</br>
  注意：该方法与viewDidAppear相似，直到removeFromParentViewController所在的方法执行完后才会被系统调用</br>
以上方法中User的我们需要手动调用的，System是系统调用的。关于这些方法的详细解释见[苹果官方文档](https://developer.apple.com/library/ios/featuredarticles/ViewControllerPGforiPhoneOS/ImplementingaContainerViewController.html)。</br></br>
ViewController作为MVC中的C，它负责根据相应的场景协调View和Model。场景大致分为两类：</br>
1，视图创建时初始化和消失的处理（例如解除监听）。这个过程我们严重依赖AppearanceCallBack。</br>
2，控制器创建完成后，人为产生业务场景，比如触发按钮事件。</br>
这里只说第一种场景，由于我们严重依赖AppearanceCallBack，因此在添加和移除控制器时需要特别注意单个视图控制器的AppearanceCallBack顺序不能出错。同时，每个视图控制器业务处理只能依赖于自己的AppearanceCallBack，不能与其他视图控制器的AppearanceCallBack产生关系。</br></br>

######视图控制器无动画切换的过程
一次视图切换过程包括上个view的消失和下个view的出现。以下代码实现即该过程，也就是把添加子控制器和移除子控制器合在一起完成。
</br>
<pre>
<code>
     func transitionToChildViewController(toViewController :UIViewController) {
        // 第一步 预处理视图控制器的层级关系
        fromViewController?.willMoveToParentViewController(nil)
        self.addChildViewController(toViewController) // self代表容器控制器
        
        // 第二步 调整toViewController的根视图的frame
        // 这里要把view的最终的frame设置好，包括autolayout的约束
        let toView = toViewController.view
        toView.frame = self.containerView.bounds
        
        // 第三步 把toView添加到容器控制器的containerView上
        self.containerView.addSubview(toView)
        
        // 第四步 移除fromViewController.view以及设定视图控制器的层级关系
        fromViewController?.view.removeFromSuperview()
        fromViewController?.removeFromParentViewController()
        toViewController.didMoveToParentViewController(self)
    }
</code>
</pre>
####2，为子控制器添加动画
其实理论上，上面就已经完成了自定义容器控制器的过程。但是如果想实现动画的出现和消失，以及手势的切换就需要用比较多内容（本文并未实现手势）。添加动画只是把上述无动画切换过程中的第三步（把toView添加到容器控制器的containerView上）交给了动画执行器来完成，其他基本不动。</br>
盗一张图来说明动画的过程：
![](https://github.com/electrmc/CustomContainerController/blob/master/Introduction/动画转场过程.png)
简单来说，要完成动画的转场，容器控制器是做不到的。它只能委托动画执行器来完成。这个过程中它提供各个控制器和视图转场前的状态以及转场后想要的状态，也就是转场上下文。动画执行器拿到该上下文，完成动画。
######视图控制器动画切换的过程
<pre>
<code>
func transitionToChildViewController(toViewController :UIViewController) {
        // 第一步 预处理视图控制器的层级关系
        fromViewController?.willMoveToParentViewController(nil)
        self.addChildViewController(toViewController) // self代表容器控制器
        
        // 第二步 调整toViewController的根视图的frame
        // 这里要把view的最终的frame设置好，包括autolayout的约束
        let toView = toViewController.view
        toView.frame = self.containerView.bounds
        
        // 第三步 创建Animator
        var animator :UIViewControllerAnimatedTransitioning?
        animator = self.delegate?.containerViewController!(self, animationControllerForTransitionFromViewController:fromViewController!, toViewControlller: toViewController)
        if animator == nil {
            animator = Animator()
        }
        
        //第四步 创建动画转场用到的上下文
        let fromIndex = self.viewControllers.indexOf(fromViewController!)
        let toIndex = self.viewControllers.indexOf(toViewController)
        let transitionContext = PrivateTransitionContext(fromViewController: fromViewController!, toViewController: toViewController, goingRight: toIndex>fromIndex)
        transitionContext.animated = true
        transitionContext.interactive = false
        transitionContext.completionBlock = {(didComplete:Bool) -> Void in
            // 移除fromViewController.view以及设定视图控制器的层级关系
            // 在动画执行完成后再执行
            fromViewController?.view.removeFromSuperview()
            fromViewController?.removeFromParentViewController()
            toViewController.didMoveToParentViewController(self)
        }
        
        //第五步 将转场上下文交给动画执行器，执行动画
        animator!.animateTransition(transitionContext)
    }
</code>
</pre>
相比于无动画过程，只是将第三步改为了创建动画执行器，第四步移到了block中。第三步创建动画执行器可以通过代理来完成，也可以提供默认的动画，就像系统的push操作提供默认动画。第四步的自定义容器控制器的转场上下文是需要我们来实现的。系统的push，present操作，上下文都由系统提供，我们仅提供动画执行器就好。</br>
####创建动画执行器和转场上下文
动画执行器和转场上下文都是靠协议来完成的。就像做事约定了规则，只要按照约定做就可以得到想要的结果。如果想做一个规则打破者，不用以下的方式创建这两个对象也可以。比如不创建上下文和动画执行器，而是简单的把self.containerView.addSubview(toView)替换一段动画代码，也是能完成动画切换的。但是不能复用，将会是一段死代码。协议就是整个业务的逻辑链条。</br></br>
以下是将用到的协议：</br>
UIViewControllerAnimatedTransitioning</br>
动画执行器需要遵守的协议。两个必须实现的方法，一个决定动画持续时间，一个决定转场动画。</br>
UIViewControllerContextTransitioning</br>
转场上下文需要遵守的协议。上下文就是一个实现了UIViewControllerContextTransitioning的对象，它为整个动画过程提供必备的信息。我们不应该缓存任何关于该对象的任务信息，而是应该每次都从转场动画上下文中获取(比如fromView和toView)，这样可以保证总是获取到最新的、正确的信息。</br>
-----------------------以下三个协议本例中未用到-----------------------</br>
UIViewControllerInteractiveTransitioning</br>
交互式转场协议。该协议控制交互转场如何操作，不过该协议一般不需要我们自定义类来实现，因为系统已用UIPercentDrivenInteractiveTransition实现了该协议。</br></br>
UIPercentDrivenInteractiveTransition : NSObject</br>
这不是一个协议，而是一个类，是系统实现了UIViewControllerInteractiveTransitioning协议的类。通常我们只需要子类化该类返回给UIViewControllerTransitioningDelegate协议中的交互式方法即可。</br></br>
UIViewControllerTransitioningDelegate</br>
该协议的作用就是为系统转场提供我们自定义的动画执行器。非交互式和交互式的转场动画执行器都是由实现该协议的代理控制，一共四个方法。其中有两个方法是控制转场动画，两个方法是控制交互进度。在本例中也与该协议功能相同的定义协议，如下：</br>
<pre>
<code>
@objc protocol ContainerViewControllerDelegate {
    // 在切换视图时调用。外界可以获知要切换到哪个控制器来做相应的处理。
    optional func containerViewController(containerViewController:ContainerViewController, didSelectViewController viewController:UIViewController)
    
    // 为控制器返回自定义的动画执行器
    optional func containerViewController(containerViewController:ContainerViewController,animationControllerForTransitionFromViewController fromViewController:UIViewController, toViewControlller:UIViewController) -> UIViewControllerAnimatedTransitioning?
}
</code>
</pre>
######动画执行器和转场上下文的详细实现
动画执行器的工作流程如下：</br>
1，拿到三个视图:fromView,toView,containerView。containerView一般是fromView的父视图</br>
2，把toView添加到containerView上</br>
3，从转场上下文中获取fromView和toView的开始和结束frame，并设置动画效果</br>
4，执行动画，调用完成的block</br>
以下是一个动画执行器的必要实现：</br>
<pre>
<code>
class Animator: NSObject,UIViewControllerAnimatedTransitioning {
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.35
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        // 1
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        
        // 2
        transitionContext.containerView()?.addSubview(toViewController!.view)
        
        // 3
        toViewController!.view.alpha = 0
        
        // 4
        UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: { () -> Void in
            fromViewController!.view.transform = CGAffineTransformMakeScale(0.1, 0.1)
            toViewController!.view.alpha = 1
            }) { (finished) -> Void in
                fromViewController!.view.transform = CGAffineTransformIdentity
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
}
</code>
</pre>
当然以上是必要的实现，既然是自定义，我们肯定还可以添加其他的功能，这个根据具体的业务来处理。但是绝不能缓存上下文信息，必须从转场上下文中获得。</br></br>
转场上下文的实现</br>
该协议的最基本作用：</br>
1，为动画器提供to和from的ViewController以及View</br>
2，提供toView和fromView初始位置和最终位置</br>
3，提供转场动画完成后要执行的block</br>
由于该对象要实现的方法比较多，这里就列举了，但是功能大致如上，注意这里不包含交互式动画要实现的功能。当然，这个对象非常重要，除了UIViewControllerContextTransitioning要实现的方法，我们还可以（几乎是必须）为对象添加其他的功能和属性以达到业务需求。


