### tab切换窗口并打开
<C-Tab> 向前循环切换到每个buffer上,并在当前窗口打开
<C-S-Tab> 向后循环切换到每个buffer上,并在当前窗口打开;　
~~~
let g:miniBufExplMapCTabSwitchBufs = 1
~~~

### ctrl切换编辑区
则可以用<C-h,j,k,l>切换到上下左右的窗口中去
~~~
let g:miniBufExplMapWindowNavVim = 1
~~~



### 参考
[vim插件之MiniBufExplorer](https://blog.csdn.net/qwaszx523/article/details/77877609)