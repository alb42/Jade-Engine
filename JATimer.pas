unit JATimer;
{$mode objfpc}{$H+}
{$i JA.inc}

interface

uses
   exec, timer, amigados,
   JATypes, JALog;

const
   JATimer_SecondsPerMinute = 60;
   JATimer_SecondsPerHour = JATimer_SecondsPerMinute*60;
   JATimer_SecondsPerDay = JATimer_SecondsPerHour*24;

   {V50 of timer.device (morphOS AROS?)}
   UNIT_CPUCLOCK     = 5;
   UNIT_WAITCPUCLOCK = 6;

type
   TJATimer = record
      TimerPort : pMsgPort;
      TimerIORequest : ptimerequest;
      TimePrevious : ttimeval;
      TimeCurrent : ttimeval;
   end;
   PJATimer = ^TJATimer;

function JATimerCreate() : PJATimer;
function JATimerDestroy(ATimer : PJATimer) : boolean;
procedure JATimerUpdate(ATimer : PJATimer; ATime : ptimeval);
procedure JATimerGetTicksMS(ATimer : PJATimer; ATicksMS : PFloat32);
procedure JATimerGetTicksMicro(ATimer : PJATimer; ATicksMicro : PFloat32);
function JATimerLap(ATimer : PJATimer) : Float32; {just returns how long it's been since the last time it was called for this timer}
procedure JATimerWait(ATimer : PJATimer; UntilTime : ptimeval);

implementation

function JATimerCreate : PJATimer;
begin
   Log('JATimerCreate','Creating Timer');

   Result := JAMemGet(SizeOf(TJATimer));

   Result^.TimerPort := CreatePort(Nil, 0);
   if (Result^.TimerPort = nil) then
   begin
      JAMemFree(Result,SizeOf(TJATimer));
      exit(nil);
   end;

   Result^.TimerIORequest := pTimeRequest(CreateExtIO(Result^.TimerPort,sizeof(tTimeRequest)));

   if (Result^.TimerIORequest = nil) then
   begin
      DeletePort(Result^.TimerPort);
      JAMemFree(Result,SizeOf(TJATimer));
      exit(nil);
   end;

   //if OpenDevice(JADeviceNameTimer, UNIT_VBLANK, pIORequest(Result^.TimerIORequest), 0) <> 0 then
   if OpenDevice(JADeviceNameTimer, UNIT_MICROHZ, pIORequest(Result^.TimerIORequest), 0) <> 0 then
   begin
      DeleteExtIO(pIORequest(Result^.TimerIORequest));
      DeletePort(Result^.TimerPort);
      JAMemFree(Result,SizeOf(TJATimer));
      exit(nil);
   end;

   {TODO : the UNIT_MICROHZ and creation of the port etc - does this affect multiple JATimers?
   do we have lots of JATimers all querying the same amiga timer or is it useful to have
   one amiga timer per JATimer?}
   TimerBase := pointer(Result^.TimerIORequest^.tr_Node.io_Device);
end;

function JATimerDestroy(ATimer : PJATimer) : boolean;
var
    TimerPort : pMsgPort;
begin
   Log('JATimerDestroy','Destroying Timer');
   TimerPort := ATimer^.TimerIORequest^.tr_Node.io_Message.mn_ReplyPort;
   if (TimerPort<>nil) then
   begin
      CloseDevice(pIORequest(ATimer^.TimerIORequest));
      DeleteExtIO(pIORequest(ATimer^.TimerIORequest));
      DeletePort(TimerPort);
   end;
   JAMemFree(ATimer,SizeOf(TJATimer));
   Result := true;
end;

procedure JATimerUpdate(ATimer : PJATimer; ATime : ptimeval);
begin
   ATimer^.TimerIORequest^.tr_node.io_Command := TR_GETSYSTIME;
   DoIO(pIORequest(ATimer^.TimerIORequest));
   ATimer^.TimePrevious := ATimer^.TimeCurrent;
   ATimer^.TimeCurrent := ATimer^.TimerIORequest^.tr_time;
   if (ATime<>nil) then ATime^ := ATimer^.TimeCurrent;
end;

procedure JATimerGetTicksMS(ATimer : PJATimer; ATicksMS : PFloat32);
begin
   ATimer^.TimerIORequest^.tr_node.io_Command := TR_GETSYSTIME;
   DoIO(pIORequest(ATimer^.TimerIORequest));
   ATicksMS^ :=
      (((ATimer^.TimerIORequest^.tr_time.tv_secs * 1000) * 1000) +
      (ATimer^.TimerIORequest^.tr_time.tv_micro)) / 1000;
end;

procedure JATimerGetTicksMicro(ATimer : PJATimer; ATicksMicro : PFloat32);
begin
   ATimer^.TimerIORequest^.tr_node.io_Command := TR_GETSYSTIME;
   DoIO(pIORequest(ATimer^.TimerIORequest));
   ATicksMicro^ :=
      ((ATimer^.TimerIORequest^.tr_time.tv_secs * 1000) * 1000) +
      (ATimer^.TimerIORequest^.tr_time.tv_micro);
end;

function JATimerLap(ATimer : PJATimer) : Float32;
begin
   ATimer^.TimerIORequest^.tr_node.io_Command := TR_GETSYSTIME;
   DoIO(pIORequest(ATimer^.TimerIORequest));
   ATimer^.TimePrevious := ATimer^.TimeCurrent;
   ATimer^.TimeCurrent := ATimer^.TimerIORequest^.tr_time;
   Result :=
      ((ATimer^.TimeCurrent.tv_secs - ATimer^.TimePrevious.tv_secs) * 1000) +
      ((ATimer^.TimeCurrent.tv_micro - ATimer^.TimePrevious.tv_micro) / 1000);
end;

procedure JATimerWait(ATimer : PJATimer; UntilTime : ptimeval);
begin
	{ add a new timer request }
   ATimer^.TimerIORequest^.tr_node.io_Command := TR_ADDREQUEST; 
   { structure assignment }
   ATimer^.TimerIORequest^.tr_time.tv_secs := UntilTime^.tv_secs;
   ATimer^.TimerIORequest^.tr_time.tv_micro := UntilTime^.tv_micro;
   { post request to the timer -- will go to sleep till done }
   DoIO(pIORequest(ATimer^.TimerIORequest));
end;

end.
