;-------- saved at 星期一 七月 2020-07-27  11:55 UTC --------------
;- Using Google Translate to automate text translation 
;- https://www.autohotkey.com/boards/viewtopic.php?f=6&t=63835

;- https://www.autohotkey.com/boards/viewtopic.php?f=6&t=63835
;- https://www.autohotkey.com/boards/viewtopic.php?f=76&t=71993 ---
;- translator from user teadrinker / with GUI 
/*
modified=20200726  added AUDIO
modified=20200329  ( teadrinker ) edited 2 times in total.
modified=20200130  translate clipboard again in other language with dropdownlist (ddl1)
modified=20191019  ( teadrinker ) edited 1 time in total. 
modified=20190422  EDIT CreateScriptObj() ( teadrinker )
created =20190419
-select language , copy marked text ctrl+c > see translation in selected language
-click AUDIO button to hear the text
*/
;-------------------------------------------------------------------------------
#NoEnv
;#Warn
setworkingdir,%a_scriptdir%
tl1:=""
Gui,1:default
Gui,1: +AlwaysOnTop  
Gui,1: -DPIScale
SS_REALSIZECONTROL := 0x40
wa:=a_screenwidth,ha:=a_screenheight,xx:=100
clipboard=
cl=
transform,s,chr,32
gosub,language
rssini=%a_scriptdir%\translate.ini
ifnotexist,%rssini%    ;- first run
    {
    translateto=pt     ;- portuguese
    IniWrite,%translateto%, %rssini% ,Lang1  ,key1
    }
Gui,1:Color,Black,Black
Gui,1:Font,s14 cYellow ,Lucida Console 
IniRead, tl1, %rssini%,Lang1 ,key1
global tl1,JS,txt22,h1
x:=(wa*2*.5)/xx,W :=(wa*2*18)/xx,H :=(ha*2*10)/xx,y:=(ha*2*.5)/xx
Gui,add,dropdownlist, x%x% y%y% w%w% vDDL1 gddl2 ,%e5x%
x:=(wa*2*20)/xx,W :=(wa*2*8)/xx,H :=(ha*2*2.4)/xx,y:=(ha*2*.5)/xx
Gui,add,button,x%x% y%y%  w%w% h%h% gAudio,AUDIO
x:=(wa*2*.5)/xx,W :=(wa*2*29)/xx , H :=(ha*2*88)/xx , y:=(ha*2*3.5)/xx
Gui,add,edit,x%x% y%y%  w%w% h%h% vED1  -border -E0x200,
W :=(wa*2*30)/xx , H :=(ha*2*25)/xx  , x:=(wa-w),y:=(ha*2*2)/xx
Gui, Show,x%x% y%y% w%w% h%h% ,TRANSLATE
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
;-----  CTRL+C Clipboardchange ---------------------
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
  txt22:=aa
  aa=
  GuiControl, Focus,ED1
  }
 }
return
;--------------------------
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
txt22:=aa
aa=
}
return
;---------------------------------------
;====================== TRANSLATE user teadrinker =============================
;-------- saved at 星期日 七月 2020-07-26  19:57 UTC --------------
;- Using Google Translate to automate text translation 
;- https://www.autohotkey.com/boards/viewtopic.php?f=6&t=63835
;MsgBox, % GoogleTranslate("今日の天気はとても良いです")
;MsgBox, % GoogleTranslate("Hello, World!", "en", "ru")
GoogleTranslate(str, from := "auto", to := "en")  {
   trans:=""
   static JS := CreateScriptObj(), _ := JS.( GetJScript() ) := JS.("delete ActiveXObject; delete GetObject;")
   
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
            trans .= (MainTransText = txt ? "" : "`n+`" txt)
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
   static http
   ComObjError(false)
   if !http
   {
      http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
      ( proxy && http.SetProxy(2, proxy) )
      http.open( "get", "https://translate.google.com", 1 )
      http.SetRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0")
      http.send()
      http.WaitForResponse(-1)
   }
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
   urlstr:=""
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
;============================================================================
;=================================   AUDIO ==================================
AUDIO:
Gui,submit,nohide
global aa2,TL1,text
F1 := a_desktop . "\test.mp3"
tl1=%tl1%
;TL1:="de"
;text:="Good evening , how are you ?"
text:=txt22
;msgbox, 262208, ,LNG=`n%lng%`n---------------------`nTEXT=`n%text%
;return
aa2:= GetAudioFromGoogle(text, TL1, F1)
if (aa2<>1)
  {
  msgbox, 262208, ,AA2=%aa2%`nLanguage = "%Tl1%"
  return
  }
soundplay,%f1%
filedelete,%f1%
return
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
GetAudioFromGoogle(text,TL1, mp3filePath)  {
   url := CreateUrl(text,TL1)
   data := sendrequest2(url)
   if SubStr(data, 1, 6) = "Error!"
      Return data
   
   Return SaveDataToFile(data, mp3filePath)
}
CreateUrl(text, TL1)  {
   JS := CreateScriptObj2(), JS.( GetJscript2() )
   url := "https://translate.google.ru/translate_tts?ie=UTF-8&tl="
         . TL1 . "&total=1&idx=0&client=t&prev=input&textlen="
         . StrLen(text) . "&tk=" . JS.("tk").(text) . "&q=" . uriencode2(text)
   Return url
}
sendrequest2(url) {
   whr := ComObjCreate("Msxml2.XMLHTTP.6.0")
   whr.Open("GET", url, false)
   whr.Send()
   
   if (whr.Status != 200)
      Return "Error! Status: " . whr.Status . "`n`n" . whr.responseBody
   Return whr.responseBody
}
SaveDataToFile(data, filePath) {
   stream := ComObjCreate("ADODB.Stream")
   stream.type := 1  ; Binary data
   stream.Open
   stream.Write(data)
   stream.SaveToFile(filePath, 2)
   stream.Close
   Return true
}
;=====================================================================================
GetJscript2()
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
UriEncode2(str, encoding := "UTF-8")  {
   urlstr:=""
   VarSetCapacity(var, StrPut(str, encoding))
   StrPut(str, &var, encoding)
   While code := NumGet(Var, A_Index - 1, "UChar")  {
      bool := (code > 0x7F || code < 0x30 || code = 0x3D)
      UrlStr .= bool ? "%" . Format("{:02X}", code) : Chr(code)
   }
   Return UrlStr
}
CreateScriptObj2() {
   static doc
   doc := ComObjCreate("htmlfile")
   doc.write("<meta http-equiv='X-UA-Compatible' content='IE=9'>")
   Return ObjBindMethod(doc.parentWindow, "eval")
}
;====================== END AUDIO ========================================
;====================== LANGUAGEs ========================================
language:
e5x:=""
e5x = 
(Ltrim join|
en_English
pt_Portuguese
%s%
%s%
)
return
;====================== END SCRIPT ==================================================
