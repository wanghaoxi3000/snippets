" 开启行号显示
set number

" 命令补全
set wildmenu

" 插入括号时，短暂地跳转到匹配的对应括号
set showmatch

" 突出显示当前行
set cursorline

" 自动换行
set wrap

" 显示指令输入
set showcmd

" 搜索时高亮显示被找到的文本
set hlsearch
" 初始化时关闭高亮
exec "nohlsearch"
" 一面输入一面高亮
set incsearch

" 打开状态栏标尺
set ruler

" 打开语法显示
syntax on

let mapleader=" "

noremap = nzz
noremap - Nzz

map s <nop>
map S :w<CR>
map Q :q<CR>
map R :source $MYVIMRC<CR>
map <LEADER><CR> :nohlsearch<CR>
