unit JAList;
{$mode objfpc}{$H+}
{$i JA.inc}

interface

uses
   JATypes;

type
   PJAListItem = ^TJAListItem;
   TJAListItem = record
      Data : pointer;
      Previous : PJAListItem;
      Next : PJAListItem;
   end;

   TJAListItemCallback = function(AItem : PJAListItem) : boolean;

   { TJAList }

   TJAList = record
      Head : PJAListItem;
      Tail : PJAListItem;
      Count : SInt32;
   end;
   PJAList = ^TJAList;

function JAListItemCreate : PJAListItem; {creates memory for item}
function JAListItemDestroy(AItem : PJAListItem) : boolean; {frees memory of item}
function JAListItemCopy(AItem : PJAListItem) : PJAListItem; {creates memory for a new item and copies existing item to it}

function JAListCreate : PJAList;
function JAListDestroy(AList : PJAList) : boolean;

{Item routines}
function JAListInsertBefore(AList : PJAList; AItem, ABeforeItem : PJAListItem) : PJAListItem; {Insert Item Before Item, Return AItem or NIL on Error}
function JAListInsertAfter(AList : PJAList; AItem, AAfterItem : PJAListItem) : PJAListItem; {Insert Item After Item, Return AItem or NIL on Error}
function JAListPushHead(AList : PJAList; AItem : PJAListItem) : PJAListItem; {Push AItem to Head, Return AItem or NIL on Error}
function JAListPushTail(AList : PJAList; AItem : PJAListItem) : PJAListItem; {Push AItem to Tail, Return AItem or NIL on Error}
function JAListPopHead(AList : PJAList) : PJAListItem; {Unlink Head Item, Return Item or NIL on Error}
function JAListPopTail(AList : PJAList) : PJAListItem; {Unlink Tail Item, Return Item or NIL on Error}
function JAListPeekHead(AList : PJAList) : PJAListItem; {Return Head Item or NIL on Error}
function JAListPeekTail(AList : PJAList) : PJAListItem; {Return Tail Item or NIL on Error}
function JAListExtract(AList : PJAList; AItem : PJAListItem) : PJAListItem; {Unlink AItem, Return AItem or NIL on Error}

{List interacions}
function JAListInsertListBefore(AList, AListSource : PJAList; ABeforeItem : PJAListItem) : PJAList; {Insert List Before Item, Reset Source, Return Self or NIL on Error}
function JAListInsertListAfter(AList, AListSource : PJAList; AAfterItem : PJAListItem) : PJAList; {Insert List After Item, Reset Source, Return Self or NIL on Error}
function JAListPushListHead(AList, AListSource : PJAList) : PJAList; {Push List to Head, Reset Source, Return Self or NIL on Error}
function JAListPushListTail(AList, AListSource : PJAList) : PJAList; {Push List to Tail, Reset Source, Return Self or NIL on Error}
function JAListPushListCopyHead(AList, AListSource : PJAList) : PJAList; {Push a copy of the List to Head, Return Self or NIL on Error}
function JAListPushListCopyTail(AList, AListSource : PJAList) : PJAList; {Push a copy of the List to Tail, Return Self or NIL on Error}
function JAListClear(AList : PJAList) : PJAList; {Destroy All Items, Reset to default state, return Self or NIL on Error}

{callback routines}
procedure JAListCallbackHeadToTail(AList : PJAList; ACallBack : TJAListItemCallback); {Callback Head To Tail}
procedure JAListCallbackTailToHead(AList : PJAList; ACallBack : TJAListItemCallback); {Callback Tail to Head}

implementation

function JAListItemCreate() : PJAListItem;
begin
   Result := JAMemGet(SizeOf(TJAListItem));
   Result^.Data := nil;
   Result^.Previous := nil;
   Result^.Next := nil;
end;

function JAListItemDestroy(AItem : PJAListItem) : boolean;
begin
   //if (AItem^.Previous<>nil) then AItem^.Previous^.Next := nil;
   //if (AItem^.Next<>nil) then AItem^.Next^.Previous := nil;
   JAMemFree(AItem, SizeOf(TJAListItem));
   Result := true;
end;

function JAListItemCopy(AItem : PJAListItem) : PJAListItem;
begin
   Result := JAMemGet(SizeOf(TJAListItem));
   Result^.Data := AItem^.Data;
   Result^.Previous := AItem^.Previous;
   Result^.Next := AItem^.Next;
end;

function JAListCreate() : PJAList;
begin
   Result := JAMemGet(SizeOf(TJAList));
   Result^.Count := 0;
   {Create Dummy Head and Tail}
   Result^.Head := JAListItemCreate();
   Result^.Tail := JAListItemCreate();
   {Setup Initial links}
   Result^.Head^.Next := Result^.Tail;
   Result^.Tail^.Previous := Result^.Head;
end;

function JAListDestroy(AList : PJAList) : boolean;
begin
   {must destroy all items and dummy items}
   JAListClear(AList);
   JAListItemDestroy(AList^.Head);
   JAListItemDestroy(AList^.Tail);
   JAMemFree(AList, SizeOf(TJAList));
end;

function JAListClear(AList : PJAList) : PJAList;
var
   CurrentItem : PJAListItem;
begin
   Result := AList;
   if (AList^.Count=0) then exit;
   CurrentItem := AList^.Head^.Next;
   while (CurrentItem <> AList^.Tail) do
   begin
      CurrentItem := CurrentItem^.Next;
      JAListItemDestroy(CurrentItem^.Previous);
   end;
   AList^.Head^.Next := AList^.Tail;
   AList^.Tail^.Previous := AList^.Head;
   AList^.Count := 0;
end;

function JAListInsertBefore(AList : PJAList; AItem, ABeforeItem : PJAListItem) : PJAListItem;
begin
   Result := nil;
   if (AItem=nil) or (ABeforeItem=nil) then exit;
   AItem^.Previous := ABeforeItem^.Previous;
   AItem^.Next := ABeforeItem;
   ABeforeItem^.Previous^.Next := AItem;
   ABeforeItem^.Previous := AItem;
   AList^.Count += 1;
   Result := AItem;
end;

function JAListInsertAfter(AList : PJAList; AItem, AAfterItem : PJAListItem) : PJAListItem;
begin
   Result := nil;
   if (AItem=nil) or (AAfterItem=nil) then exit;
   AItem^.Previous := AAfterItem;
   AItem^.Next := AAfterItem^.Next;
   AAfterItem^.Next^.Previous := AItem;
   AAfterItem^.Next := AItem;
   AList^.Count += 1;
   Result := AItem;
end;

function JAListPushHead(AList : PJAList; AItem : PJAListItem) : PJAListItem;
begin
   Result := JAListInsertAfter(AList, AItem, AList^.Head);
end;

function JAListPushTail(AList : PJAList; AItem : PJAListItem) : PJAListItem;
begin
   Result := JAListInsertBefore(AList, AItem, AList^.Tail);
end;

function JAListPopHead(AList : PJAList) : PJAListItem;
begin
   if (AList^.Count>0) then
   begin
      Result := AList^.Head^.Next;
      AList^.Head^.Next := Result^.Next;
      AList^.Head^.Next^.Previous := AList^.Head;
      Result^.Previous := nil;
      Result^.Next := nil;
      AList^.Count -= 1;
   end else Result := nil;
end;

function JAListPopTail(AList : PJAList) : PJAListItem;
begin
   if (AList^.Count>0) then
   begin
      Result := AList^.Tail^.Previous;
      AList^.Tail^.Previous := Result^.Previous;
      AList^.Tail^.Previous^.Next := AList^.Tail;
      Result^.Previous := nil;
      Result^.Next := nil;
      AList^.Count -= 1;
   end else Result := nil;
end;

function JAListPeekHead(AList : PJAList) : PJAListItem;
begin
   if (AList^.Count>0) then Result := AList^.Head^.Next
   else Result := nil;
end;

function JAListPeekTail(AList : PJAList) : PJAListItem;
begin
   if (AList^.Count>0) then Result := AList^.Tail^.Previous
   else Result := nil;
end;

function JAListExtract(AList : PJAList; AItem : PJAListItem) : PJAListItem;
begin
   Result := nil;
   if (AItem=nil) then exit;
   AItem^.Previous^.Next := AItem^.Next;
   AItem^.Next^.Previous := AItem^.Previous;
   AList^.Count -= 1;
   Result := AItem;
end;

function JAListInsertListBefore(AList, AListSource : PJAList; ABeforeItem : PJAListItem) : PJAList;
begin
   Result := nil;
   if (AListSource=nil) or (ABeforeItem=nil) or (AListSource=AList) then exit;
   if (AListSource^.Count=0) then exit;

   {Insert List}
   JAListPeekTail(AListSource)^.Next := ABeforeItem;
   JAListPeekHead(AListSource)^.Previous := ABeforeItem^.Previous;
   ABeforeItem^.Previous^.Next := JAListPeekHead(AListSource);
   ABeforeItem^.Previous := JAListPeekTail(AListSource);

   AList^.Count += AListSource^.Count;

   {Set Source List to Default State}
   AListSource^.Head^.Next := AListSource^.Tail;
   AListSource^.Tail^.Previous := AListSource^.Head;
   AListSource^.Count := 0;

   Result := AList;
end;

function JAListInsertListAfter(AList, AListSource : PJAList; AAfterItem : PJAListItem) : PJAList;
begin
   Result := nil;
   if (AListSource=nil) or (AAfterItem=nil) or (AListSource=AList) then exit;
   if (AListSource^.Count=0) then exit;

   {Insert List}
   JAListPeekTail(AListSource)^.Next := AAfterItem^.Next;
   JAListPeekHead(AListSource)^.Previous := AAfterItem;
   AAfterItem^.Next^.Previous := JAListPeekTail(AListSource);
   AAfterItem^.Next := JAListPeekTail(AListSource);

   AList^.Count += AListSource^.Count;

   {Set Source List to Default State}
   AListSource^.Head^.Next := AListSource^.Tail;
   AListSource^.Tail^.Previous := AListSource^.Head;
   AListSource^.Count := 0;

   Result := AList;
end;

function JAListPushListHead(AList, AListSource : PJAList) : PJAList;
begin
   Result := JAListInsertListAfter(AList, AListSource, AList^.Head);
end;

function JAListPushListTail(AList, AListSource : PJAList) : PJAList;
begin
   Result := JAListInsertListBefore(AList, AListSource, AList^.Tail);
end;

function JAListPushListCopyHead(AList, AListSource : PJAList) : PJAList;
var
   CurrentItem : PJAListItem;
begin
   Result := nil;
   if (AListSource=nil) then exit;
   CurrentItem := JAListPeekTail(AListSource);
   While (CurrentItem<>AListSource^.Head) do
   begin
      JAListPushHead(AList, JAListItemCopy(CurrentItem));
      CurrentItem := CurrentItem^.Previous;
   end;
   Result := AList;
end;

function JAListPushListCopyTail(AList, AListSource : PJAList) : PJAList;
var
   CurrentItem : PJAListItem;
begin
   Result := nil;
   if (AListSource=nil) then exit;
   CurrentItem := JAListPeekHead(AListSource);
   While (CurrentItem<>AListSource^.Tail) do
   begin
      JAListPushTail(AList, JAListItemCopy(CurrentItem));
      CurrentItem := CurrentItem^.Next;
   end;
   Result := AList;
end;

procedure JAListCallbackHeadToTail(AList : PJAList; ACallBack : TJAListItemCallback);
var
   CurrentItem : PJAListItem;
begin
   if (AList^.Count=0) then exit;
   CurrentItem := AList^.Head^.Next;
   while (CurrentItem<>AList^.Tail) do
   begin
      ACallBack(CurrentItem);
      CurrentItem := CurrentItem^.Next;
   end;
end;

procedure JAListCallbackTailToHead(AList : PJAList; ACallBack : TJAListItemCallback);
var
   CurrentItem : PJAListItem;
begin
   if (AList^.Count=0) then exit;
   CurrentItem := AList^.Tail^.Previous;
   while (CurrentItem<>AList^.Head) do
   begin
      ACallBack(CurrentItem);
      CurrentItem := CurrentItem^.Previous;
   end;
end;

end.
