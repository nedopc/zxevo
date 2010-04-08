program LOG2TXT;

{$APPTYPE CONSOLE}

uses
  SysUtils;

var
 b0, b1, b2     :byte;
 w              :word;
 lw,
 fseek, fsize   :longword;
 s, s2, fname   :string;
 fb             :file of byte;
 ft             :text;

function hexbyte(b:byte):string;
 const
  hex :array[$0..$f] of char='0123456789ABCDEF';
 begin
  hexbyte:=hex[b shr 4]+hex[b and $f];
 end;
{
function symb(b:byte):string;
 begin
  if (b<$20) or (b>$7f)
   then symb:=''
   else symb:='   ;"'+chr(b)+'"';
 end;
}
begin
 if paramcount<>1 then
  begin
   writeln('Usage: LOG2TXT FileName');
   halt
  end;
 fname:=paramstr(1);
 assign(fb,fname);
{$I-}
 reset(fb);
{$I+}
 if ioresult<>0 then
  begin
   writeln('Can''t open file ',fname);
   halt
  end;
 fsize:=filesize(fb);
 b0:=pos('.',fname);
 if b0<>0 then fname:=copy(fname,1,b0-1);
 assign(ft,fname+'.txt');
 rewrite(ft);
 fseek:=1;
 while (fseek<=fsize) do
  begin
   read(fb,b0); inc(fseek);
   case b0 of
    $01: begin
          read(fb,b1,b2); inc(fseek,2);
          s:='OUT '+hexbyte(b1)+', IN '+hexbyte(b2);
          writeln(ft,s);
         end;
    $02: begin
          writeln(ft,'Read  .0 .1 .2 .3 .4 .5 .6 .7 .8 .9 .A .B .C .D .E .F');
          w:=0;
          repeat
           s:=hexbyte(hi(w))+hexbyte(lo(w))+' ';
           s2:='  ';
           for b1:=0 to 15 do
            begin
             read(fb,b2); inc(fseek);
             s:=s+' '+hexbyte(b2);
             if b2>=$20 then s2:=s2+chr(b2) else s2:=s2+'.';
            end;
           s:=s+s2;
           writeln(ft,s);
           w:=w+$0010;
          until w>=$0200;
         end;
    $04: begin
          read(fb,b1); inc(fseek);
          s:=';';
          repeat
           read(fb,b2); inc(fseek);
           s:=s+chr(b2);
           dec(b1);
          until b1=0;
          writeln(ft,s);
         end;
    $05: begin
          s:=';Read sector ';
          read(fb,b1); inc(fseek);
          lw:=b1;
          s:=s+hexbyte(b1);
          read(fb,b1); inc(fseek);
          lw:=(lw shl 8) or b1;
          s:=s+hexbyte(b1);
          read(fb,b1); inc(fseek);
          lw:=(lw shl 8) or b1;
          s:=s+hexbyte(b1);
          read(fb,b1); inc(fseek);
          lw:=(lw shl 8) or b1;
          s:=s+hexbyte(b1)+' ('+IntToStr(lw)+')';
          writeln(ft,s);
         end;
    else
     writeln(ft,'!!! error !!!');
   end;
  end;
 close(fb);
 close(ft);
 writeln('Created file ',fname,'.txt');
end.

