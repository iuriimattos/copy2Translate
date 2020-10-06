;- translator from user teadrinker / with GUI 
/*
modified=20200131 maybe #warn can be desactivated , sometimes error but script runs
modified=20200130  translate clipboard again in other language with dropdownlist (ddl1)
modified=20200129  warn / translate when language change (ddl1) 
modified=20191019  ( teadrinker ) edited 1 time in total. 
modified=20190422  EDIT CreateScriptObj() ( teadrinker )
created =20190419
select language , copy marked text ctrl+c > see translation in selected language
*/
;-------------------------------------------------------------------------------
#NoEnv
;#Warn  ;- can desactivate it / sometimes error but script runs
;SendMode Input
setworkingdir,%a_scriptdir%
tl1:=""

Gui,1:default
Gui,1: +AlwaysOnTop  
Gui,1: -DPIScale
SS_REALSIZECONTROL := 0x40
wa:=a_screenwidth
ha:=a_screenheight
xx:=100
clipboard=
cl=
ex:=""
transform,s,chr,32
gosub,language
rssini=%a_scriptdir%\translate.ini
ifnotexist,%rssini%    ;- first run
    {
    translateto=pt     ;- portuguese
    IniWrite,%translateto%, %rssini% ,Lang1  ,key1
    }
Gui,1:Color,Black,Black
Gui, Font,s12 cYellow ,Lucida Console 
IniRead, tl1, %rssini%,Lang1 ,key1
global tl1,js

Gui,add,dropdownlist, x10 y10 w320 vDDL1 gddl2 ,%e5x%

W :=(wa*29)/xx , H :=(ha*89)/xx , y:=(ha*2)/xx
;Gui,add,edit,x1 y%y%  w%w% h%h% vED1  -vscroll -border -E0x200,
Gui,add,edit,x1 y50  w%w% h%h% vED1 readonly -border -E0x200,
;Gui,add,text,x0 y0 w0 vT1 ,
W :=(wa*30)/xx , H :=(ha*92)/xx  , x:=(wa-w)
Gui, Show,x%x% y1 w%w% h%h% ,TRANSLATE
GuiControl,1:Choose,ddl1,%tl1%
GuiControl, Focus,ED1
WinID := WinExist("A")
WinSetTitle, ahk_id %WinID%,, TRANSLATE_to_%tl1%
E0x200 = WS_EX_CLIENTEDGE
RETURN
;--------------------------
esc::exitapp
;--------------------------
Guiclose:
cl=
clipboard=
exitapp


/*
;------- Hotkey alt+F7 -------------------
!F7::
  send, ^c
  sleep,500
  clipwait,
  Gui, Show,
  GuiControl, Focus,ED1
 if (!ErrorLevel)
  {
  cl:=clipboard
  aa:=GoogleTranslate(cl)
  ControlSetText,edit1,%aa%, ahk_class AutoHotkeyGUI
  aa=
  ;cl=
  ;clipboard=
  GuiControl, Focus,ED1
  }
return
;--------------------------
*/

;-------------- OR : ------
;/*
;----- ( Hotkey) CTRL+C Clipboardchange ---------------------
OnClipboardChange:
If (A_EventInfo=1)
 {
 Gui, Show,
 GuiControl, Focus,ED1
 ClipWait,
 if (!ErrorLevel)
  {
  cl:=clipboard
  aa:=GoogleTranslate(cl)
  ControlSetText,edit1,%aa%, ahk_class AutoHotkeyGUI
  aa=
  ;cl=
  ;clipboard=
  GuiControl, Focus,ED1
  }
 }
return
;--------------------------
;*/


;--------------------------
ddl2:
Gui,1:submit,nohide
h1:=""
h2:=""
if DDL1<>
{
StringSplit,h,ddl1,`_
if h1<>
  {
  IniWrite,%h1%, %rssini% ,Lang1  ,key1
  tl1:=h1
  WinSetTitle, ahk_id %WinID%,, TRANSLATE_to_%h2%
  gosub,translateddlchange
  }
}
return
;----------------------------------------

;------- translate changed language -----
translateddlchange:
Guicontrolget,ed1
if ed1<>
{
aa:=GoogleTranslate(cl)      ;- translate clipboard again in other language
ControlSetText,edit1,%aa%, ahk_class AutoHotkeyGUI
aa=
}
return
;---------------------------------------


;;-------- https://www.autohotkey.com/boards/viewtopic.php?p=273621#p273621 ---
;- Last edited by teadrinker on Sat Oct 19, 2019 9:58 pm, edited 1 time in total. 
;MsgBox, % GoogleTranslate("今日の天気はとても良いです")
;MsgBox, % GoogleTranslate("Hello, World!", "en", "ru")
GoogleTranslate(str, from := "auto", to := "en")  {
   JS:=""
   trans:=""
   json:=""
   static JS := CreateScriptObj(), _ := JS.( GetJScript() ) := JS.("delete ActiveXObject;delete GetObject;")
   json := SendRequest(JS, str, to, from, proxy := "")
   oJSON := JS.("(" . json . ")")
   if !IsObject(oJSON[1])  {
      Loop % oJSON[0].length
         trans .= oJSON[0][A_Index - 1][0]
   }
   else  {
      MainTransText := oJSON[0][0][0]
      Loop % oJSON[1].length  {
         trans .= "`n+"
         obj := oJSON[1][A_Index-1][1]
         Loop % obj.length  {
            txt := obj[A_Index - 1]
            trans .= (MainTransText = txt ? "" : "`n" txt)
         }
      }
   }
   if !IsObject(oJSON[1])
      MainTransText := trans := Trim(trans, ",+`n ")
   else
      trans := MainTransText . "`n+`n" . Trim(trans, ",+`n ")
   from := oJSON[2]
   trans := Trim(trans, ",+`n ")
   Return trans
}

SendRequest(JS, str, tl, sl, proxy) {
   ComObjError(false)
   http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
   ( proxy && http.SetProxy(2, proxy) )
   tl1=%tl1%
   ;http.open( "POST", "https://translate.google.com/translate_a/single?client=t&sl="
   ;                   "https://translate.google.com/#view=home&op=translate&client=t&sl="  ;- usual in web
   http.open( "POST", "https://translate.google.com/translate_a/single?client=webapp&sl="
      . sl . "&tl=" . tl1 . "&hl=" . tl1
      . "&dt=at&dt=bd&dt=ex&dt=ld&dt=md&dt=qca&dt=rw&dt=rm&dt=ss&dt=t&ie=UTF-8&oe=UTF-8&otf=0&ssel=0&tsel=0&pc=1&kc=1"
      . "&tk=" . JS.("tk").(str), 1 )
   http.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded;charset=utf-8")
   http.SetRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0")
   http.send("q=" . URIEncode(str))
   http.WaitForResponse(-1)
   Return http.responsetext
}
URIEncode(str, encoding := "UTF-8")  {
   urlstr:=""-
   VarSetCapacity(var, StrPut(str, encoding))
   StrPut(str, &var, encoding)
   While code := NumGet(Var, A_Index - 1, "UChar")  {
      bool := (code > 0x7F || code < 0x30 || code = 0x3D)
      UrlStr .= bool ? "%" . Format("{:02X}", code) : Chr(code)
   }
   Return UrlStr
}
GetJScript()
{
   script =
   (
      var TKK = ((function() {
        var a = 561666268;
        var b = 1526272306;
        return 406398 + '.' + (a + b);
      })());
      function b(a, b) {
        for (var d = 0; d < b.length - 2; d += 3) {
            var c = b.charAt(d + 2),
                c = "a" <= c ? c.charCodeAt(0) - 87 : Number(c),
                c = "+" == b.charAt(d + 1) ? a >>> c : a << c;
            a = "+" == b.charAt(d) ? a + c & 4294967295 : a ^ c
        }
        return a
      }
      function tk(a) {
          for (var e = TKK.split("."), h = Number(e[0]) || 0, g = [], d = 0, f = 0; f < a.length; f++) {
              var c = a.charCodeAt(f);
              128 > c ? g[d++] = c : (2048 > c ? g[d++] = c >> 6 | 192 : (55296 == (c & 64512) && f + 1 < a.length && 56320 == (a.charCodeAt(f + 1) & 64512) ?
              (c = 65536 + ((c & 1023) << 10) + (a.charCodeAt(++f) & 1023), g[d++] = c >> 18 | 240,
              g[d++] = c >> 12 & 63 | 128) : g[d++] = c >> 12 | 224, g[d++] = c >> 6 & 63 | 128), g[d++] = c & 63 | 128)
          }
          a = h;
          for (d = 0; d < g.length; d++) a += g[d], a = b(a, "+-a^+6");
          a = b(a, "+-3^+b+-f");
          a ^= Number(e[1]) || 0;
          0 > a && (a = (a & 2147483647) + 2147483648);
          a `%= 1E6;
          return a.toString() + "." + (a ^ h)
      }
   )
   Return script
}
CreateScriptObj() {
   static doc
   doc := ComObjCreate("htmlfile")
   doc.write("<meta http-equiv='X-UA-Compatible' content='IE=9'>")
   Return ObjBindMethod(doc.parentWindow, "eval")
}
;-----------------------------------------------------------------

;-- some examples to select 
language:
e5x:=""
e5x=
(Ltrim join|
nl_Nederlands
af_Suid-Afrika
fy_Fryslân
eu_Basque
ca_Catalan
de_Deutsch
da_Dansk
sv_Sverige
no_Norge
is_Iceland
fi_Suomen
en_English
pt_Portugues
es_Español
it_Italia
fr_Français
ru_Rossija
zh-CN_Chinese
ja_Nippon
ko_Korea
ro_Romania
bg_Bulgaria
mk_Macedonia
el_Greek
tr_Turkiye
sq_Albania
hr_Croatia
sr_Serbia
sl_Slovenia
hu_Hungary
cs_Czech
sk_Slovakia
pl_Poland
be_Belarus
uk_Ukraina
et_Estonia
lv_Latvija
lt_Lituania
az_Azerbaijan 
ka_Georgian
ar_Arabic
iw_Hebrew
hi_Hindi
id_Indonesia
ms_Malaysia
vi_Vietnam
th_Thai
ta_Tamil
ur_Urdu
sw_Swahili
bn_Bengal
%s%
)
return
;====================== END SCRIPT ==================================================
