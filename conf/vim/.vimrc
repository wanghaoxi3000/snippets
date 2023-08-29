" 开启行号显示
set number

" 插入括号时，短暂地跳转到匹配的对应括号
set showmatch

" 搜索时高亮显示被找到的文本
set hlsearch

" 打开状态栏标尺
set ruler

" 打开语法显示
syntax enable
syntax on

" 突出显示当前行
set cursorline

" 开启新行时使用智能自动缩进
set smartindent

" 编码显示顺序, 方便显示中文
set fileencodings=ucs-bom,utf-8,gb18030,default

" 关闭 vi 兼容模式
set nocompatible
"不设定在插入状态无法用退格键和 Delete 键删除回车符"set backspace=indent,eol,start

" debian 鼠标粘贴
set mouse-=a
