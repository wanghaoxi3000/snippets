" 行号显示
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
" 输入时高亮
set incsearch
set ignorecase
set smartcase

" 打开状态栏标尺
set ruler

" 打开语法显示
syntax on

" 开启删除键
set backspace=indent,eol,start

" 缩进
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2

" 显示行位空格
set list
set listchars=tab:▸\ ,trail:▫
set scrolloff=5
set tw=0

set scrolloff=5
set laststatus=2
set autochdir

" 关闭兼容模式
"set nocompatible

" 使用系统剪贴板
" set clipboard=unnamedplus

" debian 鼠标粘贴
"set mouse-=a

let mapleader=" "

noremap H 0
noremap L $
noremap J 5j
noremap K 5k
noremap = nzz
noremap - Nzz

" visual 模式下 Y 复制到系统剪贴板
vnoremap Y "+y

map s <nop>
map S :w<CR>
map Q :q<CR>
map <LEADER><CR> :nohlsearch<CR>

map sh :set splitright<CR>:vsplit<CR>
map sl :set nosplitright<CR>:vsplit<CR>
map sk :set nosplitbelow<CR>:split<CR>
map sj :set splitbelow<CR>:split<CR>
map <LEADER>h <C-w>h
map <LEADER>j <C-w>j
map <LEADER>k <C-w>k
map <LEADER>l <C-w>l
map aj :res +5<CR>
map ak :res -5<CR>
map ah :vertical resize-5<CR>
map al :vertical resize+5<CR>

map R :source $MYVIMRC<CR>
