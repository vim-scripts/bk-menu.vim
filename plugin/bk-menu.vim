" -*- vim -*-
" FILE: "/home/matthew/.vim/bk-menu.vim"
" LAST MODIFICATION: "Thu, 17 Jan 2002 15:23:25 +1100 (matthew)"

if has("gui")
	an &BK.&Get\ latest\ version\ of\ open\ file<Tab>bk\ get\ (F3) :call GetBKLatestVersion(expand("%:t"))<CR>
	an &BK.Get\ a\ &version\ of\ open\ file<Tab>bk\ get\ -rxx      :let rev = input("Enter revision number:")<Bar>call GetRevision(expand("%:t"), rev)<CR>
	an &BK.Get\ latest\ version\ of\ &all\ files<Tab>bk\ get\ SCCS :!bk get SCCS<CR>
	an &BK.-SEP1-                                                  <Nop>
	an &BK.Check\ &in\ open\ file<Tab>bk\ delta\ (F5)              :let comm = input("Enter comment:")<Bar>call CheckIn(expand("%:t"), comm)<Bar>:e!<CR>
	an &BK.Check\ &out\ open\ file<Tab>bk\ edit\ (F4)              :!bk edit %:t<CR>:e!<CR>
	an &BK.&Unedit\ open\ file<Tab>bk\ unedit                      :!bk unedit %:t<CR>:e!<CR>
	an &BK.&Uncheckout\ open\ file<Tab>bk\ unget                   :!bk unget %:t<CR>:e!<CR>
	an &BK.&Revert\ back<Tab>bk\ unget/get\ (F10)                  :!bk unget %:t<CR>:!bk get %:t<CR>:e!<CR>
	an &BK.-SEP2-                                                  <Nop>
	an &BK.&Add\ file\ in\ Bitkeeper<Tab>bk\ create                :!bk create %:t<CR>:e!<CR>
	an &BK.-SEP3-                                                  <Nop>
	an &BK.Get\ &log\ of\ open\ file\ in\ Bitkeeper<Tab>bk\ prs\ (F6)  :call BKShowLog("sccs-log", "bk prs")<CR>
	an &BK.Diff\ with\ prev\ version<Tab>(F7)                      :call ShowBKDiff(expand("%:t"))<CR>
	an &BK.Diff\ with\ two\ versions<Tab>                          :let rev1 = input("Enter the first revision number to diff:")<Bar>:let rev2 = input("Enter the secoind revision number to diff:")<Bar>:call ShowBKVersionDiff(expand("%:t"), rev1, rev2)<CR>
endif

if(v:version >= 600)
	map <F3> :call GetBKLatestVersion(expand("%:t"))<CR>
	map <F4> :!bk edit %:t<CR>:e!<CR>
	map <F5> :let comm = input("Enter comment:")<Bar>call CheckIn(expand("%:t"), comm)<Bar>:e!<CR>
	map <F6> :call BKShowLog("sccs-log", "bk prt")<CR>
	map <F7> :call ShowBKDiff(expand("%:t"))<CR>
	map <F10> :!bk unget %:t<CR>:!bk get %:t<CR>:e!<CR>
endif

function GetRevision(filename, revision)
	silent execute ":!bk get -r" . a:revision . " " . a:filename
	call BKUpdateVersion()
endfunction

function CheckIn(filename, comment)
	let quote = "\""
	silent execute ":!bk ci -y" . quote a:comment . quote a:filename
endfunction

function ShowBKDiff(filename)
	let s:fileType = &ft
	silent execute ":!bk get -p " . a:filename . " > tempfile.java"
	if bufexists("diff")
		execute "bd! diff"
	endif
	execute "vnew diff"
	let s:cmdName = "sccs get -p -s " . a:filename
	silent execute "0r!" . s:cmdName
	execute "set filetype=" . s:filetype
	set nomodified
	execute "diffthis"
	execute "wincmd l"
	execute "diffthis"
	execute "wincmd h"
	execute "normal 1G"
endfunction

function ShowBKVersionDiff(filename, rev1, rev2)
	let s:fileType = &ft
	execute "set nodiff"
	if (a:rev1 == a:rev2)
		execute ":redraw"
		echo "Nothing to show diff"
		return
	endif
	let s:curr_ver = BKUpdateVersion()
	let s:rev = ""
	if(match(s:curr_ver, a:rev1) != -1)
		let s:rev = a:rev2
	elseif(match(s:curr_rev, a:rev2) != -1)
		let s:rev = a:rev1
	endif
	if(s:rev != "")
		if bufexists("diff1")
			execute "bd! diff1"
		endif
		execute "vnew diff1"
		let s:cmdName = "bk get -p -s " . a:filename . " -r " . s:rev
		silent execute "0r!" . s:cmdName
		execute "set filetype=" . s:fileType
		set nomodified
		execute "diffthis"
		execute "wincmd l"
		execute "diffthis"
		execute "wincmd h"
		execute "normal 1G"
		return
	endif
	if bufexists("diff1")
		execute "bd! diff1"
	endif
	execute "new diff1"
	let s:cmdName = "bk get -p -s " . a:filename . " -r " . a:rev1
	silent execute "0r!" . s:cmdName
	execute "set filetype=" . s:fileType
	set nomodified
	execute "diffthis"
	if bufexists("diff2")
		execute "bd! diff2"
	endif
	execute "vnew diff2"
	let s:cmdName = "bk get -p -s " . a:filename . " -r " . a:rev2
	silent execute "0r!" . s:cmdName
	execute "set filetype=" . s:fileType
	set nomodified
	execute "diffthis"
	execute "wincmd l"
	execute "diffthis"
	execute "wincmd h"
	execute "normal 1G"
endfunction

function! ReadCommandBuffer(bufferName, cmdName)
  set shortmess+=A
  let currentBuffer = bufname("%")
  if bufexists(a:bufferName)
    execute 'bd! ' a:bufferName
  endif
  execute 'new ' a:bufferName
  execute 'r!' a:cmdName ' ' currentBuffer
  set nomodified
  execute "normal 1G"
  set shortmess-=A
endfunction

function! BKShowLog(bufferName, cmdName)
    call ReadCommandBuffer(a:bufferName, a:cmdName)
endfunction

let b:bk_version = ""

function BKGetVersion()
   if exists("b:bk_version")
      return b:bk_version
   else
      return ""
   endif
endfunction

function BKUpdateVersion()
   let s:filename = expand("%:t")
   if(s:filename  == "")
       let b:bk_version = ""
       return ""
   endif
   let s:cmdName="bk prs " . s:filename 
   let s:version = system(s:cmdName)
   if(strpart(s:version, 0, 1) == "")
       let b:bk_version = " "
       return b:bk_version
   elseif(match(s:version, "nonexistent") != -1)
       let b:bk_version = "Not in Bitkeeper"
       return b:bk_version
   elseif(match(s:version, "%") != -1)
       let b:bk_version = "Not in Bitkeeper"
       return b:bk_version
   endif
   let s:grpCmd = "bk check | grep " . s:filename
   let s:grpRes = system(s:grpCmd)
   if(!v:shell_error)
       let b:bk_version = "Checked out(Locked)"
       return b:bk_version
   endif
   let s:cmdName="bk prs " . s:filename . " | awk '{getline;print $3;}' "
   let s:version = system(s:cmdName)
   let b:bk_version = strpart(s:version, 0, strlen(s:version)-1)
   return b:bk_version
endfunction

function GetBKLatestVersion(filename)
    silent execute ":!bk get " . a:filename
endfunction

" Misc settings
set laststatus=2    "Always have a status line to show SCCS version
"set rulerformat=%60(SCCS-%{SCCSGetVersion()}%)%=%l,%c%V\ %3P%*
set   statusline=%1*[%02n]%*\ %2*%f%*\ %(\[%M%R%H]%)%=BK-%{BKGetVersion()}\ %4l,%02c%2V\ %P%*

" Change to the directory the file in your current buffer is in
autocmd BufEnter * :cd %:p:h 
" Update the SCCS version of file when we open it
autocmd BufEnter * call BKUpdateVersion()
